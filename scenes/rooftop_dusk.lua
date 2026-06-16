-- 风景集 / No.18  城市黄昏  Rooftop Dusk
-- 天台 · 烟囱 · 晾衣绳 · 鸽子 · 暖灯 · 远城 · 黄昏
local M = { name = "rooftop_dusk" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop   = {0.30, 0.30, 0.55},
    skyMid   = {0.95, 0.55, 0.45},
    skyHor   = {1.00, 0.80, 0.55},
    sun      = {1.00, 0.85, 0.55},
    sunGlow  = {1.00, 0.65, 0.35},
    concrete = {0.55, 0.50, 0.45},
    concreteD= {0.32, 0.28, 0.25},
    brick    = {0.45, 0.25, 0.20},
    brickLt  = {0.62, 0.40, 0.32},
    window   = {1.00, 0.85, 0.50},
    windowLt = {1.00, 0.92, 0.70},
    chimney  = {0.35, 0.30, 0.28},
    smoke    = {0.60, 0.55, 0.55},
    pigeon   = {0.45, 0.42, 0.48},
    pigeonLt = {0.65, 0.62, 0.68},
    lamp     = {1.00, 0.78, 0.45},
    lampGlow = {1.00, 0.85, 0.55},
    cloth1   = {0.90, 0.30, 0.30},
    cloth2   = {0.30, 0.60, 0.85},
    cloth3   = {0.95, 0.85, 0.30},
    cloth4   = {0.20, 0.55, 0.40},
    plant    = {0.20, 0.45, 0.25},
}

-- 远处城市天际线
local function drawCitySkyline(baseY)
    local heights = {40, 65, 80, 50, 90, 70, 55, 85, 60, 75, 45, 70, 55, 80, 60}
    for i = 0, 14 do
        local h = heights[i+1]
        love.graphics.setColor(C.concreteD[1], C.concreteD[2], C.concreteD[3], 0.85)
        love.graphics.rectangle("fill", i*80, baseY - h, 76, h)
        -- 窗
        for k = 0, 6 do
            for j = 0, 1 do
                local on = ((i*7 + k*3 + j) % 3) == 0
                if on then
                    love.graphics.setColor(C.window[1], C.window[2], C.window[3], 0.85)
                    love.graphics.rectangle("fill",
                        i*80 + 8 + j*32, baseY - h + 8 + k*9, 6, 5)
                end
            end
        end
    end
end

-- 烟囱
local function drawChimney(x, baseY, h, t)
    love.graphics.setColor(C.chimney[1], C.chimney[2], C.chimney[3], 1)
    love.graphics.rectangle("fill", x - 8, baseY - h, 16, h)
    love.graphics.setColor(C.concrete[1], C.concrete[2], C.concrete[3], 1)
    love.graphics.rectangle("fill", x - 10, baseY - h, 20, 4)
    -- 烟
    for k = 0, 5 do
        local yo = baseY - h - k*16 - t*8 % 16
        local a = 0.5 - k*0.08
        love.graphics.setColor(C.smoke[1], C.smoke[2], C.smoke[3], a)
        love.graphics.circle("fill", x + math.sin(t*0.5 + k)*4, yo, 6 + k*2)
    end
end

-- 晾衣绳 + 衣服
local function drawClothesLine(x1, x2, y, t)
    love.graphics.setColor(0.20, 0.18, 0.18, 1)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(x1, y, x2, y)
    local cloths = {C.cloth1, C.cloth2, C.cloth3, C.cloth4}
    for i = 1, 4 do
        local cx = x1 + 30 + (i-1) * 40
        local sag = math.sin(t*0.5 + i) * 1
        love.graphics.setColor(cloths[i][1], cloths[i][2], cloths[i][3], 1)
        love.graphics.rectangle("fill", cx - 10, y + sag + 1, 20, 22)
        -- 衣架钩
        love.graphics.setColor(0.30, 0.30, 0.30, 1)
        love.graphics.setLineWidth(1)
        love.graphics.line(cx, y, cx, y + sag + 1)
    end
end

-- 鸽子
local function drawPigeon(x, y, s, t, flying)
    local flap = flying and (math.sin(t*8) * 4) or 0
    -- 身体
    love.graphics.setColor(C.pigeon[1], C.pigeon[2], C.pigeon[3], 1)
    love.graphics.ellipse("fill", x, y, 10*s, 5*s)
    -- 头
    love.graphics.circle("fill", x + 9*s, y - 3*s, 3.5*s)
    -- 喙
    love.graphics.setColor(0.85, 0.65, 0.30, 1)
    love.graphics.polygon("fill", {
        x + 12*s, y - 3*s, x + 15*s, y - 2.5*s, x + 12*s, y - 2*s,
    })
    -- 颈环
    love.graphics.setColor(0.30, 0.30, 0.40, 1)
    love.graphics.rectangle("fill", x + 7*s, y - 4*s, 2*s, 2*s)
    -- 翅
    love.graphics.setColor(C.pigeonLt[1], C.pigeonLt[2], C.pigeonLt[3], 1)
    love.graphics.polygon("fill", {
        x - 4*s, y, x + 4*s, y - 2*s,
        x + 5*s, y - 4*s - flap,
        x - 2*s, y - 5*s - flap,
    })
    -- 尾
    love.graphics.setColor(0.30, 0.30, 0.35, 1)
    love.graphics.polygon("fill", {
        x - 10*s, y, x - 5*s, y - 2*s, x - 5*s, y + 2*s,
    })
end

-- 路灯
local function drawStreetLamp(x, baseY, t)
    love.graphics.setColor(0.15, 0.15, 0.18, 1)
    love.graphics.rectangle("fill", x - 1.5, baseY - 100, 3, 100)
    -- 臂
    love.graphics.rectangle("fill", x - 1.5, baseY - 100, 25, 2)
    -- 灯
    love.graphics.setColor(1.0, 0.85, 0.55, 1)
    love.graphics.circle("fill", x + 24, baseY - 99, 4)
    love.graphics.setColor(1.0, 0.85, 0.55, 0.18 + 0.04*math.sin(t*2))
    love.graphics.circle("fill", x + 24, baseY - 99, 18)
end

-- 盆栽
local function drawPot(x, baseY)
    love.graphics.setColor(0.55, 0.35, 0.25, 1)
    love.graphics.polygon("fill", {
        x - 10, baseY, x + 10, baseY,
        x + 7, baseY + 12, x - 7, baseY + 12,
    })
    love.graphics.setColor(0.40, 0.25, 0.18, 1)
    love.graphics.rectangle("fill", x - 11, baseY - 1, 22, 2)
    -- 叶
    love.graphics.setColor(C.plant[1], C.plant[2], C.plant[3], 1)
    love.graphics.polygon("fill", {
        x, baseY - 1, x - 8, baseY - 14, x - 4, baseY - 18,
        x, baseY - 6,
    })
    love.graphics.polygon("fill", {
        x, baseY - 1, x + 9, baseY - 12, x + 5, baseY - 16,
        x, baseY - 6,
    })
end

-- 烟囱烟(再次用到)
local SMOKES = {}
for i = 1, 20 do
    SMOKES[i] = {
        x = rnd(i*3) * W,
        y = rnd(i*5) * H*0.5,
        r = 2 + rnd(i*7) * 4,
        v = 5 + rnd(i*11) * 6,
        ph = rnd(i*13) * 6.28,
    }
end

-- 飞鸟群(剪影)
local BFLOCK = {}
for i = 1, 6 do
    BFLOCK[i] = {
        x = rnd(i*3) * W,
        y = H*0.20 + rnd(i*5) * H*0.20,
        ph = rnd(i*11) * 6.28,
    }
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 黄昏天空
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.4 then
            r = lerp(C.skyTop[1], C.skyMid[1], p/0.4)
            g = lerp(C.skyTop[2], C.skyMid[2], p/0.4)
            b = lerp(C.skyTop[3], C.skyMid[3], p/0.4)
        else
            local q = (p - 0.4) / 0.6
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 太阳 (贴近地平)
    love.graphics.setColor(C.sunGlow[1], C.sunGlow[2], C.sunGlow[3], 0.18)
    love.graphics.circle("fill", W*0.80, H*0.62, 130)
    love.graphics.setColor(C.sunGlow[1], C.sunGlow[2], C.sunGlow[3], 0.40)
    love.graphics.circle("fill", W*0.80, H*0.62, 75)
    love.graphics.setColor(C.sun[1], C.sun[2], C.sun[3], 1)
    love.graphics.circle("fill", W*0.80, H*0.62, 38)

    -- 3) 远城天际线
    drawCitySkyline(H*0.72)

    -- 4) 中城 (近)
    for i = 0, 8 do
        local h = 80 + (i*13) % 70
        local x = i * 150
        love.graphics.setColor(C.brick[1], C.brick[2], C.brick[3], 1)
        love.graphics.rectangle("fill", x, H*0.85 - h, 130, h)
        -- 顶
        love.graphics.setColor(C.concreteD[1], C.concreteD[2], C.concreteD[3], 1)
        love.graphics.rectangle("fill", x, H*0.85 - h - 4, 130, 4)
        -- 窗
        for k = 0, 4 do
            for j = 0, 3 do
                local on = ((i*7 + k*3 + j) % 2) == 0
                if on then
                    love.graphics.setColor(C.window[1], C.window[2], C.window[3], 0.85)
                    love.graphics.rectangle("fill",
                        x + 8 + j*30, H*0.85 - h + 10 + k*15, 8, 8)
                end
            end
        end
    end

    -- 5) 屋顶 (近景)
    love.graphics.setColor(C.concrete[1], C.concrete[2], C.concrete[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.85, 250, H*0.85, 280, H*0.80, 600, H*0.78,
        640, H*0.82, 1000, H*0.80, 1050, H*0.85, 1200, H*0.85, 1200, H, 0, H
    })
    -- 屋顶暗影
    love.graphics.setColor(C.concreteD[1], C.concreteD[2], C.concreteD[3], 0.7)
    love.graphics.polygon("fill", {
        250, H*0.85, 280, H*0.80, 600, H*0.78,
        640, H*0.82, 600, H*0.84, 280, H*0.86, 250, H*0.87,
    })
    -- 屋顶纹
    for k = 0, 30 do
        local yk = H*0.83 + k*4
        love.graphics.setColor(C.concreteD[1], C.concreteD[2], C.concreteD[3], 0.3)
        love.graphics.line(0, yk, W, yk)
    end

    -- 6) 烟囱
    drawChimney(W*0.18, H*0.78, 60, t)
    drawChimney(W*0.32, H*0.79, 45, t + 1.5)
    drawChimney(W*0.70, H*0.80, 70, t + 0.8)
    drawChimney(W*0.85, H*0.81, 50, t + 2.0)

    -- 7) 晾衣绳
    drawClothesLine(W*0.10, W*0.45, H*0.75, t)
    drawClothesLine(W*0.55, W*0.95, H*0.74, t + 0.5)

    -- 8) 鸽子 (站 / 飞)
    drawPigeon(W*0.25, H*0.78, 1.2, t, false)
    drawPigeon(W*0.30, H*0.79, 1.0, t + 0.5, false)
    drawPigeon(W*0.78, H*0.79, 1.1, t + 1.0, false)
    -- 飞
    drawPigeon(W*0.40 + math.sin(t*0.3)*30, H*0.45, 1.0, t, true)
    drawPigeon(W*0.55 + math.cos(t*0.4)*40, H*0.40, 0.9, t+1, true)
    drawPigeon(W*0.70 + math.sin(t*0.5+1)*30, H*0.50, 1.0, t+2, true)

    -- 9) 路灯
    drawStreetLamp(W*0.08, H*0.85, t)
    drawStreetLamp(W*0.92, H*0.85, t + 0.5)

    -- 10) 盆栽
    drawPot(W*0.42, H*0.83)
    drawPot(W*0.50, H*0.83)
    drawPot(W*0.65, H*0.83)

    -- 11) 飞鸟群
    for _, B in ipairs(BFLOCK) do
        local bx = (B.x + t*8) % (W + 50) - 25
        local by = B.y + math.sin(t*0.3 + B.ph) * 3
        local flap = math.sin(t*7 + B.ph) * 3
        love.graphics.setColor(0.15, 0.10, 0.10, 0.85)
        love.graphics.line(bx - 5, by + flap, bx, by)
        love.graphics.line(bx, by, bx + 5, by + flap)
    end

    -- 12) 远散烟
    for _, S in ipairs(SMOKES) do
        local sx = S.x + math.sin(t*0.2 + S.ph) * 8
        local sy = (S.y - t * S.v) % (H*0.7)
        if sy < 0 then sy = sy + H*0.7 end
        love.graphics.setColor(C.smoke[1], C.smoke[2], C.smoke[3], 0.18)
        love.graphics.circle("fill", sx, sy, S.r)
    end

    -- 13) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(1.00,0.55,0.40,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(1, 0.95, 0.85, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.18  ·  城市黄昏  ·  Rooftop Dusk", 24, 12)
    love.graphics.setColor(1, 0.80, 0.65, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("天台 · 烟囱 · 晾衣绳 · 鸽子 · 暖灯 · 远城 · 黄昏", 24, 48)
    love.graphics.setColor(0.95, 0.80, 0.70, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 14) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(1, 0.85, 0.65, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("天台上的风 — 总比下面多一份", 24, H-23)
end
return M
