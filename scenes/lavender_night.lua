-- 风景集 / No.04  夜·薰衣草花田  Lavender Night
-- 星空 · 银河 · 萤火虫 · 远教堂 · 月光 · 紫色花海
local M = { name = "lavender_night" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end
local function clamp(v,a,b) if v<a then return a elseif v>b then return b else return v end end

-- 调色板
local C = {
    skyTop   = {0.02, 0.02, 0.10},   -- 深夜蓝
    skyMid   = {0.10, 0.05, 0.25},   -- 暗紫
    skyHor   = {0.20, 0.10, 0.30},   -- 地平线微紫
    starW    = {1.0, 0.98, 0.92},    -- 星色
    starBlu  = {0.7, 0.85, 1.0},     -- 冷星
    moon     = {0.97, 0.95, 0.85},
    moonHalo = {0.85, 0.80, 1.0},
    mtFar    = {0.18, 0.10, 0.25},
    mtMid    = {0.10, 0.06, 0.18},
    mtNear   = {0.06, 0.04, 0.12},
    church   = {0.05, 0.05, 0.10},
    churchLt = {0.85, 0.75, 0.55},   -- 窗里暖光
    fieldA   = {0.20, 0.10, 0.30},   -- 暗花田
    fieldB   = {0.30, 0.18, 0.40},   -- 亮花田
    lavender = {0.55, 0.40, 0.80},   -- 薰衣草紫
    lavender2= {0.70, 0.55, 0.90},   -- 亮紫
    glowWarm = {1.0, 0.85, 0.40},    -- 萤火虫
    glowCool = {0.70, 0.95, 0.55},   -- 萤火虫冷
}

-- 星星
local STARS = {}
for i = 1, 220 do
    STARS[i] = {
        x = rnd(i) * W,
        y = rnd(i*2.1) * H * 0.55,
        s = 0.4 + rnd(i*3.7) * 1.6,
        c = (rnd(i*4.3) < 0.65) and 1 or 2,  -- 1=warm, 2=cool
        ph = rnd(i*5.1) * math.pi * 2,
        tw = 0.4 + rnd(i*6.7) * 0.6,         -- 闪烁强度
    }
end

-- 银河 (粗略的星带)
local function milkyX(p)  -- p in [0,1] -> x
    return W * (0.05 + 0.9 * p) + math.sin(p * 8) * 60
end
local function milkyY(p)
    return H * (0.20 + 0.20 * p) + math.cos(p * 6) * 25
end

-- 萤火虫
local FIREFLIES = {}
for i = 1, 60 do
    FIREFLIES[i] = {
        x = rnd(i*7.1) * W,
        y = H*0.55 + rnd(i*8.3) * H*0.30,
        s = 1.2 + rnd(i*9.7) * 1.6,
        sp = 8 + rnd(i*10.1) * 14,
        ph = rnd(i*11.3) * math.pi * 2,
        wob = 0.3 + rnd(i*12.7) * 0.5,
        c = (rnd(i*13.1) < 0.5) and 1 or 2,
        tw = 0.4 + rnd(i*14.3) * 0.6,
    }
end

-- 一根薰衣草
local function drawLavender(x, baseY, h, sway)
    -- 茎
    love.graphics.setColor(0.18, 0.30, 0.20, 1)
    love.graphics.line(x, baseY, x + sway, baseY - h)
    -- 花穗 (小圆点)
    local c = (x + baseY) % 1 < 0.5 and C.lavender or C.lavender2
    local n = 6
    for i = 1, n do
        local pp = i / n
        local px = x + sway * pp
        local py = baseY - h * pp
        love.graphics.setColor(c[1], c[2], c[3], 0.95)
        love.graphics.circle("fill", px, py, 2 + (1-pp)*1.5)
        -- 小高光
        love.graphics.setColor(c[1]+0.1, c[2]+0.1, c[3]+0.1, 0.6)
        love.graphics.circle("fill", px - 0.5, py - 0.5, 1.2)
    end
end

-- 月亮
local function drawMoon(x, y, r)
    for k = 6, 1, -1 do
        love.graphics.setColor(C.moonHalo[1], C.moonHalo[2], C.moonHalo[3], 0.05*k)
        love.graphics.circle("fill", x, y, r + k*8)
    end
    love.graphics.setColor(C.moon[1], C.moon[2], C.moon[3], 1)
    love.graphics.circle("fill", x, y, r)
    -- 月面斑
    love.graphics.setColor(0.80, 0.78, 0.70, 0.5)
    love.graphics.circle("fill", x - r*0.30, y - r*0.20, r*0.20)
    love.graphics.circle("fill", x + r*0.25, y + r*0.10, r*0.15)
    love.graphics.circle("fill", x - r*0.10, y + r*0.30, r*0.12)
    -- 亮面
    love.graphics.setColor(1.0, 0.98, 0.95, 0.5)
    love.graphics.circle("fill", x - r*0.40, y - r*0.30, r*0.25)
end

-- 远山
local function drawMt(yBase, col, j, amp)
    love.graphics.setColor(col[1], col[2], col[3], 1)
    local pts = {}
    pts[1] = 0; pts[2] = yBase
    for i = 0, 14 do
        local p = i / 14
        local x = p * W
        local top = yBase - amp*0.4 - (math.sin(p*3 + j) * amp*0.3) - (i%3)*amp*0.10
        pts[#pts+1] = x; pts[#pts+1] = top
    end
    pts[#pts+1] = W; pts[#pts+1] = yBase
    love.graphics.polygon("fill", pts)
end

-- 教堂剪影
local function drawChurch(x, y)
    -- 主堂
    love.graphics.setColor(C.church[1], C.church[2], C.church[3], 1)
    love.graphics.rectangle("fill", x, y - 50, 60, 50)
    -- 钟楼
    love.graphics.rectangle("fill", x + 20, y - 110, 20, 60)
    -- 塔顶
    love.graphics.polygon("fill", {
        x + 20, y - 140, x + 30, y - 110, x + 40, y - 110
    })
    -- 十字架
    love.graphics.line(x + 30, y - 140, x + 30, y - 152)
    love.graphics.line(x + 27, y - 146, x + 33, y - 146)
    -- 屋顶
    love.graphics.polygon("fill", {
        x, y - 50, x + 30, y - 75, x + 60, y - 50
    })
    -- 窗户 (暖光)
    love.graphics.setColor(C.churchLt[1], C.churchLt[2], C.churchLt[3], 1)
    -- 拱形
    love.graphics.rectangle("fill", x + 24, y - 80, 12, 16)
    love.graphics.circle("fill", x + 30, y - 80, 6)
    -- 侧窗
    love.graphics.rectangle("fill", x + 8, y - 38, 8, 14)
    love.graphics.rectangle("fill", x + 44, y - 38, 8, 14)
    -- 门
    love.graphics.rectangle("fill", x + 26, y - 18, 8, 18)
    love.graphics.circle("fill", x + 30, y - 18, 4)
    -- 窗光晕
    love.graphics.setColor(1.0, 0.85, 0.40, 0.18)
    love.graphics.circle("fill", x + 30, y - 70, 25)
end

-- 流星
local function drawShootingStar(x, y, t, life)
    local phase = (t * 0.3) % 1
    if phase > life then return end
    local p = phase / life
    local px = W*0.7 + (1 - p) * 400
    local py = H*0.10 + p * 200
    local len = 60 * (1 - p)
    -- 拖尾
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.line(px, py, px - len, py - len*0.5)
    -- 头
    love.graphics.setColor(1, 1, 0.9, 1)
    love.graphics.circle("fill", px, py, 2)
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 夜空 (顶深蓝→中暗紫→地平线微紫)
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.55 then
            local q = p / 0.55
            r = lerp(C.skyTop[1], C.skyMid[1], q)
            g = lerp(C.skyTop[2], C.skyMid[2], q)
            b = lerp(C.skyTop[3], C.skyMid[3], q)
        else
            local q = (p - 0.55) / 0.45
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 银河 (一层淡色带)
    love.graphics.setColor(0.55, 0.45, 0.75, 0.16)
    for k = -8, 8 do
        local pts = {}
        for i = 0, 30 do
            local p = i / 30
            local x = milkyX(p) + k*8
            local y = milkyY(p) + k*3
            pts[#pts+1] = x; pts[#pts+1] = y
        end
        for i = 30, 0, -1 do
            local p = i / 30
            local x = milkyX(p) + k*8
            local y = milkyY(p) + 22 - k*3
            pts[#pts+1] = x; pts[#pts+1] = y
        end
        love.graphics.polygon("fill", pts)
    end
    -- 银河核心
    love.graphics.setColor(0.95, 0.85, 0.70, 0.12)
    for i = 0, 30 do
        local p = i / 30
        love.graphics.circle("fill", milkyX(p), milkyY(p), 14)
    end

    -- 3) 月亮 (右上空)
    local moonX, moonY = W*0.78, H*0.18
    drawMoon(moonX, moonY, 38)

    -- 4) 星星 (闪烁)
    for _, S in ipairs(STARS) do
        local a = 0.5 + 0.5*math.sin(t*1.5 + S.ph) * S.tw
        local col = (S.c == 1) and C.starW or C.starBlu
        love.graphics.setColor(col[1], col[2], col[3], clamp(a, 0.15, 1))
        love.graphics.circle("fill", S.x, S.y, S.s)
        -- 十字光芒 (亮星)
        if S.s > 1.3 then
            love.graphics.setColor(col[1], col[2], col[3], a*0.5)
            love.graphics.line(S.x - S.s*3, S.y, S.x + S.s*3, S.y)
            love.graphics.line(S.x, S.y - S.s*3, S.x, S.y + S.s*3)
        end
    end

    -- 5) 流星 (偶发)
    drawShootingStar(0, 0, t, 0.20)

    -- 6) 远山 3 层
    drawMt(H*0.55, C.mtFar,  1, 60)
    drawMt(H*0.60, C.mtMid,  2, 50)
    drawMt(H*0.66, C.mtNear, 3, 40)

    -- 7) 花田 (远)
    -- 整体暗色
    love.graphics.setColor(C.fieldA[1], C.fieldA[2], C.fieldA[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.60, W, H*0.60,
        W, H, 0, H
    })
    -- 亮带
    love.graphics.setColor(C.fieldB[1], C.fieldB[2], C.fieldB[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.72, W, H*0.72,
        W, H, 0, H
    })
    -- 紫色花海散点 (远)
    love.graphics.setColor(C.lavender[1]*0.5, C.lavender[2]*0.5, C.lavender[3]*0.5, 0.7)
    for i = 0, 80 do
        local x = (i * 19 + 3) % W
        local y = H*0.72 + ((i*13) % 50)
        love.graphics.circle("fill", x, y, 1.2)
    end
    love.graphics.setColor(C.lavender2[1]*0.6, C.lavender2[2]*0.6, C.lavender2[3]*0.6, 0.55)
    for i = 0, 60 do
        local x = (i * 27 + 7) % W
        local y = H*0.78 + ((i*17) % 40)
        love.graphics.circle("fill", x, y, 1.5)
    end

    -- 8) 远教堂 (小剪影, 带暖窗光)
    drawChurch(W*0.20, H*0.62)

    -- 9) 中景薰衣草丛 (散)
    local swayBase = math.sin(t*0.4) * 2
    for i = 0, 30 do
        local x = (i * 41 + 11) % W
        local y = H*0.82 + ((i*7) % 30)
        local h = 8 + (i % 5) * 3
        local sway = swayBase + math.sin(t*0.6 + i) * 3
        drawLavender(x, y, h, sway)
    end

    -- 10) 前景薰衣草 (大, 多)
    for i = 0, 18 do
        local x = i * (W/18) + math.sin(i)*8
        local y = H*0.93 + (i%3) * 4
        local h = 18 + (i%4) * 5
        local sway = math.sin(t*0.5 + i*0.7) * 4
        drawLavender(x, y, h, sway)
    end

    -- 11) 萤火虫 (在花田上)
    for _, F in ipairs(FIREFLIES) do
        local fx = F.x + math.sin(t*0.6 + F.ph) * 30 * F.wob
        local fy = F.y + math.cos(t*0.5 + F.ph*1.3) * 12 * F.wob
        local a = 0.5 + 0.5*math.sin(t*3 + F.ph) * F.tw
        a = clamp(a, 0.15, 1)
        local col = (F.c == 1) and C.glowWarm or C.glowCool
        -- 光晕
        love.graphics.setColor(col[1], col[2], col[3], 0.12*a)
        love.graphics.circle("fill", fx, fy, F.s*5)
        love.graphics.setColor(col[1], col[2], col[3], 0.25*a)
        love.graphics.circle("fill", fx, fy, F.s*2.5)
        -- 核心
        love.graphics.setColor(1.0, 1.0, 0.85, a)
        love.graphics.circle("fill", fx, fy, F.s)
    end

    -- 12) 顶部信息条
    love.graphics.setColor(0,0,0,0.55)
    love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.70,0.55,0.95,0.6)
    love.graphics.rectangle("fill", 0, 75, W, 1)

    love.graphics.setColor(0.92,0.85,1.0,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.04  ·  夜·薰衣草花田  ·  Lavender Night", 24, 12)
    love.graphics.setColor(0.85,0.75,0.95,0.95); love.graphics.setFont(subFont)
    love.graphics.print("星空 · 银河 · 萤火虫 · 远教堂 · 月光", 24, 48)
    love.graphics.setColor(0.80,0.70,0.90,0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 13) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.85,0.75,0.95,0.85); love.graphics.setFont(subFont)
    love.graphics.print("灵感取自普罗旺斯之夜 — 风里有薰衣草与旧钟声", 24, H-23)
end
return M
