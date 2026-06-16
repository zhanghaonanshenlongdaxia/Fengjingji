-- 风景集 / No.19  萤火森林  Firefly Wood
-- 夏夜 · 萤火虫 · 树 · 月 · 蘑菇 · 小路 · 蟋蟀 · 苔藓
local M = { name = "firefly_wood" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop   = {0.02, 0.04, 0.12},
    skyMid   = {0.05, 0.10, 0.20},
    skyHor   = {0.12, 0.15, 0.25},
    moon     = {1.00, 0.95, 0.80},
    moonGlow = {0.80, 0.78, 0.60},
    star     = {1.00, 0.97, 0.85},
    trunk    = {0.12, 0.10, 0.08},
    trunkDk  = {0.05, 0.04, 0.03},
    leaf     = {0.10, 0.18, 0.10},
    leafLt   = {0.18, 0.28, 0.18},
    moss     = {0.20, 0.30, 0.15},
    mossDk   = {0.12, 0.20, 0.10},
    path     = {0.30, 0.25, 0.20},
    pathLt   = {0.45, 0.38, 0.30},
    mushR    = {0.85, 0.30, 0.30},
    mushR2   = {0.65, 0.20, 0.20},
    mushDk   = {0.20, 0.15, 0.12},
    firefly  = {0.95, 0.95, 0.40},
    fireflyG = {0.95, 0.85, 0.30},
    cricket  = {0.25, 0.20, 0.10},
}

-- 月亮
local function drawMoon(x, y, r)
    love.graphics.setColor(C.moonGlow[1], C.moonGlow[2], C.moonGlow[3], 0.20)
    love.graphics.circle("fill", x, y, r * 2.5)
    love.graphics.setColor(C.moonGlow[1], C.moonGlow[2], C.moonGlow[3], 0.40)
    love.graphics.circle("fill", x, y, r * 1.6)
    love.graphics.setColor(C.moon[1], C.moon[2], C.moon[3], 1)
    love.graphics.circle("fill", x, y, r)
    love.graphics.setColor(0.85, 0.80, 0.65, 0.5)
    love.graphics.circle("fill", x - r*0.3, y - r*0.2, r*0.15)
    love.graphics.circle("fill", x + r*0.3, y + r*0.3, r*0.12)
end

-- 萤火虫
local FIREFLIES = {}
for i = 1, 70 do
    FIREFLIES[i] = {
        x = rnd(i*3) * W,
        y = rnd(i*5) * H*0.75 + H*0.20,
        r = 1.5 + rnd(i*7) * 1.5,
        vx = (rnd(i*11) - 0.5) * 10,
        vy = (rnd(i*13) - 0.5) * 5,
        ph = rnd(i*17) * 6.28,
        freq = 0.5 + rnd(i*19) * 1.5,
    }
end

-- 树 (近, 大)
local function drawBigTree(x, baseY, h, t)
    -- 投影
    love.graphics.setColor(0, 0, 0, 0.30)
    love.graphics.ellipse("fill", x + 5, baseY + 1, 50, 5)
    -- 主干
    love.graphics.setColor(C.trunk[1], C.trunk[2], C.trunk[3], 1)
    love.graphics.polygon("fill", {
        x - 8, baseY, x + 8, baseY,
        x + 5, baseY - h, x - 5, baseY - h,
    })
    -- 主枝 (4 枝)
    for k = 0, 3 do
        local p = 0.3 + k*0.18
        local yk = baseY - h * p
        local ang = -0.7 + k * 0.45
        local len = 30 + k*5
        local ex = x + math.cos(ang) * len
        local ey = yk - 25 + math.sin(t*0.5 + k) * 2
        love.graphics.setColor(C.trunk[1], C.trunk[2], C.trunk[3], 1)
        love.graphics.line(x, yk, ex, ey)
        -- 小枝
        love.graphics.line(ex, ey, ex + math.cos(ang+0.5)*15, ey - 8)
    end
    -- 树冠
    love.graphics.setColor(C.leaf[1], C.leaf[2], C.leaf[3], 1)
    love.graphics.circle("fill", x, baseY - h*0.9, 35)
    love.graphics.circle("fill", x - 20, baseY - h*0.8, 25)
    love.graphics.circle("fill", x + 22, baseY - h*0.85, 28)
    -- 亮叶
    love.graphics.setColor(C.leafLt[1], C.leafLt[2], C.leafLt[3], 0.6)
    love.graphics.circle("fill", x - 5, baseY - h*0.95, 18)
    love.graphics.circle("fill", x + 10, baseY - h*0.9, 15)
    -- 苔藓
    love.graphics.setColor(C.moss[1], C.moss[2], C.moss[3], 0.85)
    love.graphics.polygon("fill", {
        x - 10, baseY - 2, x + 10, baseY - 2,
        x + 12, baseY, x - 12, baseY,
    })
end

-- 远树 (剪影)
local function drawFarTree(x, baseY, h)
    love.graphics.setColor(0.06, 0.08, 0.10, 0.85)
    love.graphics.polygon("fill", {
        x - h*0.15, baseY, x + h*0.15, baseY,
        x + h*0.08, baseY - h*0.7, x, baseY - h,
        x - h*0.08, baseY - h*0.7,
    })
    -- 树冠
    love.graphics.circle("fill", x, baseY - h*0.9, h*0.45)
    love.graphics.circle("fill", x - h*0.25, baseY - h*0.8, h*0.30)
    love.graphics.circle("fill", x + h*0.25, baseY - h*0.85, h*0.30)
end

-- 蘑菇
local function drawMushroom(x, baseY, sz, kind)
    sz = sz or 1
    -- 茎
    love.graphics.setColor(0.92, 0.85, 0.70, 1)
    love.graphics.rectangle("fill", x - 4*sz, baseY - 12*sz, 8*sz, 12*sz)
    -- 盖
    local c = (kind == 1) and C.mushR or C.mushR2
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.ellipse("fill", x, baseY - 14*sz, 18*sz, 11*sz)
    -- 暗面
    love.graphics.setColor(c[1]*0.7, c[2]*0.7, c[3]*0.7, 1)
    love.graphics.ellipse("fill", x + 2*sz, baseY - 12*sz, 14*sz, 7*sz)
    -- 白点
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.circle("fill", x - 5*sz, baseY - 16*sz, 1.5*sz)
    love.graphics.circle("fill", x + 4*sz, baseY - 18*sz, 1.2*sz)
    love.graphics.circle("fill", x - 2*sz, baseY - 12*sz, 1.0*sz)
    love.graphics.circle("fill", x + 6*sz, baseY - 13*sz, 1.3*sz)
end

-- 蟋蟀
local function drawCricket(x, baseY, t)
    love.graphics.setColor(C.cricket[1], C.cricket[2], C.cricket[3], 1)
    love.graphics.ellipse("fill", x, baseY, 6, 3)
    -- 触角
    love.graphics.setColor(0.20, 0.15, 0.10, 1)
    love.graphics.setLineWidth(0.8)
    love.graphics.line(x - 5, baseY - 1, x - 9, baseY - 6)
    love.graphics.setLineWidth(0.8)
    love.graphics.line(x - 5, baseY - 1, x - 7, baseY - 7)
end

-- 星星
local STARS = {}
for i = 1, 60 do
    STARS[i] = {
        x = rnd(i*3) * W,
        y = rnd(i*5) * H*0.40,
        r = 0.4 + rnd(i*7) * 0.8,
        ph = rnd(i*11) * 6.28,
    }
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 夏夜天空
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

    -- 2) 星星
    for _, S in ipairs(STARS) do
        local flick = 0.5 + 0.5 * math.sin(t*1.5 + S.ph)
        love.graphics.setColor(C.star[1], C.star[2], C.star[3], flick)
        love.graphics.circle("fill", S.x, S.y, S.r)
    end

    -- 3) 月亮
    drawMoon(W*0.78, H*0.18, 28)

    -- 4) 远山
    love.graphics.setColor(0.05, 0.06, 0.10, 1)
    love.graphics.polygon("fill", {
        0, H*0.50, 200, H*0.40, 400, H*0.45, 700, H*0.38,
        1000, H*0.42, 1200, H*0.40, 1200, H*0.50,
    })

    -- 5) 远树
    for k = 0, 12 do
        local x = (k * 95 + 30) % W
        local h = 30 + rnd(k*3) * 25
        drawFarTree(x, H*0.52, h)
    end

    -- 6) 地面 (森林地)
    love.graphics.setColor(0.05, 0.10, 0.05, 1)
    love.graphics.polygon("fill", {
        0, H*0.55, 300, H*0.50, 600, H*0.55, 900, H*0.48,
        1200, H*0.52, 1200, H, 0, H
    })
    love.graphics.setColor(0.04, 0.08, 0.04, 1)
    love.graphics.polygon("fill", {
        0, H*0.75, 400, H*0.70, 800, H*0.75, 1200, H*0.70, 1200, H, 0, H
    })
    love.graphics.setColor(0.02, 0.05, 0.02, 1)
    love.graphics.polygon("fill", {
        0, H*0.90, 500, H*0.85, 900, H*0.88, 1200, H*0.85, 1200, H, 0, H
    })

    -- 7) 远蘑菇 (发光)
    for k = 0, 4 do
        local x = (k * 280 + 100) % W
        drawMushroom(x, H*0.78, 0.6, k % 2)
    end

    -- 8) 大树
    drawBigTree(W*0.10, H*0.88, 200, t)
    drawBigTree(W*0.30, H*0.90, 170, t + 1.0)
    drawBigTree(W*0.70, H*0.90, 180, t + 2.0)
    drawBigTree(W*0.92, H*0.88, 165, t + 3.0)

    -- 9) 中树
    drawFarTree(W*0.20, H*0.72, 50)
    drawFarTree(W*0.50, H*0.74, 55)
    drawFarTree(W*0.80, H*0.73, 50)

    -- 10) 小路 (透视)
    love.graphics.setColor(C.path[1], C.path[2], C.path[3], 0.85)
    love.graphics.polygon("fill", {
        W*0.50, H*0.65, W*0.48, H*0.65,
        0, H, W, H,
    })
    love.graphics.setColor(C.pathLt[1], C.pathLt[2], C.pathLt[3], 0.4)
    love.graphics.polygon("fill", {
        W*0.495, H*0.65, W*0.505, H*0.65,
        W*0.50, H, W*0.50, H,
    })

    -- 11) 近蘑菇
    drawMushroom(W*0.15, H*0.92, 1.2, 1)
    drawMushroom(W*0.20, H*0.93, 0.9, 2)
    drawMushroom(W*0.75, H*0.92, 1.1, 1)
    drawMushroom(W*0.85, H*0.94, 0.8, 2)
    drawMushroom(W*0.50, H*0.95, 0.7, 1)
    -- 蘑菇发光 (自光)
    love.graphics.setColor(0.95, 0.40, 0.30, 0.10)
    love.graphics.circle("fill", W*0.15, H*0.85, 30)
    love.graphics.circle("fill", W*0.75, H*0.85, 30)

    -- 12) 苔藓斑
    for i = 1, 25 do
        local x = (i * 47) % W
        local y = H*0.85 + (i*7) % 60
        love.graphics.setColor(C.moss[1], C.moss[2], C.moss[3], 0.7)
        love.graphics.ellipse("fill", x, y, 8, 3)
    end

    -- 13) 蟋蟀
    drawCricket(W*0.35, H*0.93, t)
    drawCricket(W*0.62, H*0.94, t + 1.0)
    drawCricket(W*0.88, H*0.95, t + 2.0)

    -- 14) 萤火虫
    for _, F in ipairs(FIREFLIES) do
        -- 漂浮
        local fx = (F.x + math.sin(t*F.freq + F.ph) * 30 + t * F.vx * 0.3) % (W + 60) - 30
        local fy = F.y + math.cos(t*F.freq*0.7 + F.ph) * 20
        -- 闪烁
        local pulse = 0.5 + 0.5 * math.sin(t*F.freq*2 + F.ph)
        -- 外晕
        love.graphics.setColor(C.fireflyG[1], C.fireflyG[2], C.fireflyG[3], pulse * 0.18)
        love.graphics.circle("fill", fx, fy, F.r * 4)
        -- 中层
        love.graphics.setColor(C.firefly[1], C.firefly[2], C.firefly[3], pulse * 0.5)
        love.graphics.circle("fill", fx, fy, F.r * 2)
        -- 核心
        love.graphics.setColor(1, 1, 0.85, pulse)
        love.graphics.circle("fill", fx, fy, F.r)
    end

    -- 15) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.95,0.95,0.40,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(1, 1, 0.78, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.19  ·  萤火森林  ·  Firefly Wood", 24, 12)
    love.graphics.setColor(0.95, 0.95, 0.75, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("夏夜 · 萤火虫 · 树 · 月 · 蘑菇 · 小路 · 蟋蟀 · 苔藓", 24, 48)
    love.graphics.setColor(0.85, 0.85, 0.65, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 16) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.95, 0.95, 0.65, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("萤火一盏盏 — 像有人提着灯笼散步", 24, H-23)
end
return M
