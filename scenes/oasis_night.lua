-- 风景集 / No.15  沙漠绿洲  Oasis Night
-- 沙丘 · 月亮 · 棕榈 · 湖水 · 倒影 · 篝火 · 驼队 · 星空
local M = { name = "oasis_night" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop   = {0.04, 0.06, 0.16},
    skyMid   = {0.10, 0.10, 0.25},
    skyHor   = {0.30, 0.20, 0.30},
    sandL    = {0.92, 0.78, 0.55},
    sandM    = {0.78, 0.62, 0.40},
    sandD    = {0.55, 0.40, 0.25},
    sandDk   = {0.30, 0.20, 0.12},
    palm     = {0.25, 0.20, 0.10},
    palmDk   = {0.15, 0.10, 0.05},
    leaf     = {0.20, 0.35, 0.18},
    leafDk   = {0.12, 0.22, 0.10},
    water    = {0.10, 0.25, 0.40},
    waterLt  = {0.30, 0.55, 0.70},
    moon     = {1.00, 0.95, 0.80},
    moonGlow = {0.90, 0.80, 0.55},
    star     = {1.00, 0.97, 0.85},
    fire     = {1.00, 0.55, 0.18},
    camel    = {0.55, 0.40, 0.25},
    camelDk  = {0.35, 0.25, 0.15},
}

-- 沙丘
local function drawDune(points, c)
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.polygon("fill", points)
end

-- 棕榈
local function drawPalm(x, baseY, h, t)
    -- 投影
    love.graphics.setColor(0, 0, 0, 0.30)
    love.graphics.ellipse("fill", x + 30, baseY + 4, 60, 4)
    -- 弯树干 (弧线)
    local segs = 8
    for k = 0, segs-1 do
        local p1 = k / segs
        local p2 = (k+1) / segs
        local lean = math.sin(p1 * math.pi) * 18  -- 弯曲量
        local x1 = x + lean * 0.6
        local x2 = x + math.sin(p2 * math.pi) * 18 * 0.6
        local y1 = baseY - h * p1
        local y2 = baseY - h * p2
        local w1 = 6 * (1 - p1*0.5)
        local w2 = 6 * (1 - p2*0.5)
        love.graphics.setColor(C.palm[1], C.palm[2], C.palm[3], 1)
        -- 用 polygon 画梯形树干段 (两端不同宽度)
        love.graphics.polygon("fill", {
            x1 - w1, y1,
            x1 + w1, y1,
            x2 + w2, y2,
            x2 - w2, y2,
        })
    end
    -- 顶部叶 (8 片)
    local topX = x + math.sin(1) * 18 * 0.6
    local topY = baseY - h
    for k = 0, 7 do
        local ang = k / 8 * math.pi * 2 + math.sin(t + k) * 0.05
        local len = 40 + math.sin(t*1.5 + k) * 3
        local drop = -10 + math.cos(t*1.2 + k*0.5) * 4
        local ex = topX + math.cos(ang) * len
        local ey = topY + math.sin(ang) * len * 0.4 + drop
        -- 叶片 (多段线, 中间深两边亮)
        local c1 = (k % 2 == 0) and C.leaf or C.leafDk
        love.graphics.setColor(c1[1], c1[2], c1[3], 1)
        love.graphics.polygon("fill", {
            topX, topY, ex, ey,
            topX - math.cos(ang) * 2, topY - math.sin(ang) * 2,
        })
        -- 椰果
        if k < 3 then
            love.graphics.setColor(0.20, 0.10, 0.05, 1)
            love.graphics.circle("fill", topX + math.cos(ang) * 8, topY + math.sin(ang) * 4, 3)
        end
    end
    -- 树节
    for k = 1, 4 do
        love.graphics.setColor(C.palmDk[1], C.palmDk[2], C.palmDk[3], 1)
        local py = baseY - h * (0.2 + k*0.15)
        local px = x + math.sin(py/baseY * math.pi) * 18 * 0.6
        love.graphics.rectangle("fill", px - 4, py - 1, 8, 2)
    end
end

-- 篝火 (近)
local function drawFire(x, baseY, t)
    local flick = math.sin(t*8) * 2 + math.sin(t*13) * 1.5
    -- 光晕
    love.graphics.setColor(1.0, 0.55, 0.18, 0.20)
    love.graphics.circle("fill", x, baseY - 8, 50)
    love.graphics.setColor(1.0, 0.70, 0.30, 0.32)
    love.graphics.circle("fill", x, baseY - 10, 30)
    -- 火苗
    love.graphics.setColor(1.0, 0.30, 0.10, 1)
    love.graphics.polygon("fill", {
        x - 6, baseY - 3, x + 6, baseY - 3,
        x + 3, baseY - 16 - flick,
        x,     baseY - 26 - flick,
        x - 3, baseY - 16 - flick,
    })
    love.graphics.setColor(1.0, 0.78, 0.30, 0.9)
    love.graphics.polygon("fill", {
        x - 4, baseY - 3, x + 4, baseY - 3,
        x,     baseY - 20 - flick*0.6,
    })
    -- 圆木
    love.graphics.setColor(0.30, 0.20, 0.12, 1)
    love.graphics.rectangle("fill", x - 9, baseY - 2, 18, 2)
end

-- 骆驼 (剪影带驼峰)
local function drawCamel(x, baseY, s, t)
    local walk = math.sin(t*2 + x*0.01) * 1.5 * s
    -- 投影
    love.graphics.setColor(0, 0, 0, 0.30)
    love.graphics.ellipse("fill", x + 2*s, baseY + 1, 25*s, 3)
    -- 腿
    love.graphics.setColor(C.camelDk[1], C.camelDk[2], C.camelDk[3], 1)
    love.graphics.rectangle("fill", x - 12*s, baseY - 14*s + walk, 3*s, 14*s)
    love.graphics.rectangle("fill", x - 6*s,  baseY - 14*s - walk, 3*s, 14*s)
    love.graphics.rectangle("fill", x + 3*s,  baseY - 14*s + walk, 3*s, 14*s)
    love.graphics.rectangle("fill", x + 9*s,  baseY - 14*s - walk, 3*s, 14*s)
    -- 身体
    love.graphics.setColor(C.camel[1], C.camel[2], C.camel[3], 1)
    love.graphics.ellipse("fill", x, baseY - 18*s, 22*s, 6*s)
    -- 双峰
    love.graphics.setColor(C.camel[1], C.camel[2], C.camel[3], 1)
    love.graphics.polygon("fill", {
        x - 12*s, baseY - 22*s, x - 6*s, baseY - 22*s,
        x - 8*s, baseY - 30*s,
    })
    love.graphics.polygon("fill", {
        x + 2*s, baseY - 22*s, x + 8*s, baseY - 22*s,
        x + 5*s, baseY - 32*s,
    })
    -- 脖子
    love.graphics.setColor(C.camel[1], C.camel[2], C.camel[3], 1)
    love.graphics.polygon("fill", {
        x + 18*s, baseY - 18*s, x + 22*s, baseY - 18*s,
        x + 25*s, baseY - 32*s, x + 22*s, baseY - 32*s,
    })
    -- 头
    love.graphics.ellipse("fill", x + 24*s, baseY - 34*s, 4*s, 3*s)
end

-- 星星
local STARS = {}
for i = 1, 80 do
    STARS[i] = {
        x = rnd(i*3) * W,
        y = rnd(i*5) * H*0.55,
        r = 0.5 + rnd(i*7) * 1.4,
        ph = rnd(i*11) * 6.28,
    }
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 夜空
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.55 then
            r = lerp(C.skyTop[1], C.skyMid[1], p/0.55)
            g = lerp(C.skyTop[2], C.skyMid[2], p/0.55)
            b = lerp(C.skyTop[3], C.skyMid[3], p/0.55)
        else
            local q = (p - 0.55) / 0.45
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 星星 (闪烁)
    for _, S in ipairs(STARS) do
        local flick = 0.6 + 0.4 * math.sin(t*2 + S.ph)
        love.graphics.setColor(C.star[1], C.star[2], C.star[3], flick)
        love.graphics.circle("fill", S.x, S.y, S.r)
        -- 大星加十字光芒
        if S.r > 1.2 then
            love.graphics.setColor(C.star[1], C.star[2], C.star[3], flick * 0.3)
            love.graphics.line(S.x - 4, S.y, S.x + 4, S.y)
            love.graphics.line(S.x, S.y - 4, S.x, S.y + 4)
        end
    end

    -- 3) 月亮
    love.graphics.setColor(C.moonGlow[1], C.moonGlow[2], C.moonGlow[3], 0.18)
    love.graphics.circle("fill", W*0.20, H*0.20, 90)
    love.graphics.setColor(C.moonGlow[1], C.moonGlow[2], C.moonGlow[3], 0.30)
    love.graphics.circle("fill", W*0.20, H*0.20, 55)
    love.graphics.setColor(C.moon[1], C.moon[2], C.moon[3], 1)
    love.graphics.circle("fill", W*0.20, H*0.20, 32)
    -- 月坑
    love.graphics.setColor(0.80, 0.75, 0.65, 0.5)
    love.graphics.circle("fill", W*0.20 - 8, H*0.20 - 4, 4)
    love.graphics.circle("fill", W*0.20 + 6, H*0.20 + 8, 3)
    love.graphics.circle("fill", W*0.20 - 4, H*0.20 + 10, 2)

    -- 4) 远沙丘
    drawDune({0, H*0.65, 200, H*0.55, 400, H*0.62, 700, H*0.50,
              1000, H*0.60, 1200, H*0.55, 1200, H*0.85, 0, H*0.85}, C.sandM)
    -- 中沙丘
    drawDune({0, H*0.78, 300, H*0.70, 600, H*0.78, 900, H*0.68,
              1200, H*0.75, 1200, H, 0, H}, C.sandL)
    -- 前景沙丘
    drawDune({0, H*0.90, 200, H*0.86, 500, H*0.92, 800, H*0.85,
              1200, H*0.88, 1200, H, 0, H}, C.sandD)

    -- 5) 绿洲湖 (水洼, 椭圆形)
    love.graphics.setColor(C.water[1], C.water[2], C.water[3], 1)
    love.graphics.ellipse("fill", W*0.55, H*0.82, 220, 28)
    love.graphics.setColor(C.waterLt[1], C.waterLt[2], C.waterLt[3], 0.7)
    love.graphics.ellipse("fill", W*0.55, H*0.82, 180, 22)
    -- 月亮在湖面反射 (水平拉长)
    love.graphics.setColor(C.moon[1], C.moon[2], C.moon[3], 0.55)
    love.graphics.ellipse("fill", W*0.55, H*0.82, 30, 4)
    -- 水面波光
    for k = 1, 8 do
        local yo = H*0.82 + math.sin(t*2 + k)*0.5
        love.graphics.setColor(0.80, 0.92, 1.0, 0.30)
        love.graphics.ellipse("fill", W*0.40 + k*30, yo, 14, 1)
    end

    -- 6) 棕榈 (4 棵)
    drawPalm(W*0.30, H*0.75, 110, t)
    drawPalm(W*0.42, H*0.78, 95,  t + 1.0)
    drawPalm(W*0.78, H*0.76, 115, t + 2.0)
    drawPalm(W*0.88, H*0.79, 90,  t + 3.0)

    -- 7) 篝火
    drawFire(W*0.62, H*0.80, t)

    -- 8) 驼队 (远处剪影)
    for i = 1, 4 do
        local px = W*0.10 + i * 80
        local py = H*0.78
        local s = 0.7 - i*0.05
        drawCamel(px, py, s, t + i*0.3)
    end

    -- 9) 沙纹 (近景波纹)
    for k = 1, 30 do
        local yk = H*0.88 + k * 2
        love.graphics.setColor(C.sandDk[1], C.sandDk[2], C.sandDk[3], 0.6)
        love.graphics.line(0, yk, W, yk)
    end
    -- 弧形沙纹
    for i = 1, 15 do
        local x = (i * 89) % W
        local y = H*0.92 + (i*7) % 8
        love.graphics.setColor(C.sandDk[1], C.sandDk[2], C.sandDk[3], 0.7)
        love.graphics.arc("line", x, y, 20, 0, math.pi)
    end

    -- 10) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.90,0.75,0.45,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(1, 0.95, 0.78, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.15  ·  沙漠绿洲  ·  Oasis Night", 24, 12)
    love.graphics.setColor(0.95, 0.85, 0.70, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("沙丘 · 月亮 · 棕榈 · 湖水 · 倒影 · 篝火 · 驼队 · 星空", 24, 48)
    love.graphics.setColor(0.85, 0.78, 0.65, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 11) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(1, 0.88, 0.65, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("渴的人看见水, 不渴的人看见月", 24, H-23)
end
return M
