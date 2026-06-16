-- 风景集 / No.11  草原晨雾  Grassland Dawn
-- 草 · 雾 · 朝霞 · 远山 · 帐篷 · 篝火 · 飞鸟 · 露珠
local M = { name = "grassland_dawn" }
local W, H = 1200, 700
local HORIZON = H * 0.55
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop   = {0.18, 0.30, 0.55},
    skyMid   = {0.70, 0.55, 0.50},
    skyHor   = {0.95, 0.78, 0.55},
    sunGlow  = {1.00, 0.85, 0.60},
    sun      = {1.00, 0.95, 0.78},
    mountain = {0.42, 0.48, 0.55},
    mountainN= {0.30, 0.38, 0.48},
    grassFar = {0.55, 0.65, 0.40},
    grassMid = {0.42, 0.55, 0.30},
    grassNear= {0.28, 0.42, 0.18},
    tent     = {0.78, 0.55, 0.35},
    tentDk   = {0.45, 0.30, 0.20},
    fire     = {1.00, 0.55, 0.18},
    bird     = {0.18, 0.16, 0.20},
}

-- 远山
local function drawMountain(cx, baseY, w, h, c)
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.polygon("fill", {
        cx - w*0.5, baseY,
        cx,           baseY - h,
        cx + w*0.5,   baseY,
    })
    -- 雪顶
    love.graphics.setColor(0.92, 0.94, 0.97, 0.85)
    love.graphics.polygon("fill", {
        cx - w*0.10, baseY - h*0.78,
        cx,          baseY - h,
        cx + w*0.10, baseY - h*0.78,
    })
end

-- 帐篷
local function drawTent(x, baseY, w, h, c)
    -- 主体三角
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.polygon("fill", {
        x - w*0.5, baseY, x + w*0.5, baseY,
        x,          baseY - h,
    })
    -- 暗面 (右侧)
    love.graphics.setColor(c[1]*0.55, c[2]*0.55, c[3]*0.55, 1)
    love.graphics.polygon("fill", {
        x, baseY, x + w*0.5, baseY,
        x,          baseY - h,
    })
    -- 帐篷门 (深色三角)
    love.graphics.setColor(0.18, 0.10, 0.08, 1)
    love.graphics.polygon("fill", {
        x - w*0.10, baseY, x + w*0.10, baseY,
        x,            baseY - h*0.55,
    })
    -- 顶旗
    love.graphics.setColor(0.85, 0.20, 0.20, 1)
    love.graphics.rectangle("fill", x - 0.6, baseY - h - 6, 1.2, 6)
    love.graphics.setColor(0.85, 0.20, 0.20, 1)
    love.graphics.polygon("fill", {
        x + 0.6, baseY - h - 6, x + 6, baseY - h - 4,
        x + 0.6, baseY - h - 2,
    })
    -- 投影
    love.graphics.setColor(0, 0, 0, 0.18)
    love.graphics.ellipse("fill", x + w*0.15, baseY + 2, w*0.55, 5)
end

-- 篝火 (火苗跳)
local function drawCampfire(x, baseY, t)
    local flick = math.sin(t * 6) * 1.5 + math.sin(t * 11) * 1.0
    -- 光晕
    love.graphics.setColor(1.0, 0.55, 0.18, 0.18)
    love.graphics.circle("fill", x, baseY - 10, 38)
    love.graphics.setColor(1.0, 0.70, 0.30, 0.28)
    love.graphics.circle("fill", x, baseY - 12, 22)
    -- 火苗
    love.graphics.setColor(1.0, 0.30, 0.10, 1)
    love.graphics.polygon("fill", {
        x - 5,  baseY - 4, x + 5, baseY - 4,
        x + 2 + flick*0.3, baseY - 14 - flick,
        x,                  baseY - 22 - flick,
        x - 2 - flick*0.3, baseY - 14 - flick,
    })
    love.graphics.setColor(1.0, 0.78, 0.30, 0.9)
    love.graphics.polygon("fill", {
        x - 3,  baseY - 4, x + 3, baseY - 4,
        x,                  baseY - 16 - flick*0.7,
    })
    -- 圆木
    love.graphics.setColor(0.30, 0.20, 0.12, 1)
    love.graphics.rectangle("fill", x - 8, baseY - 2, 16, 2)
    love.graphics.rectangle("fill", x - 7, baseY - 4, 14, 2)
end

-- 草
local function drawGrassStrip(y, density, hMin, hMax, c)
    for i = 1, density do
        local x = (i * 37) % W
        local h = hMin + rnd(i*7 + y*0.01) * (hMax - hMin)
        love.graphics.setColor(c[1] + (rnd(i*3 + y*0.02)-0.5)*0.05,
                               c[2] + (rnd(i*5 + y*0.03)-0.5)*0.05,
                               c[3] + (rnd(i*11+ y*0.04)-0.5)*0.04, 1)
        love.graphics.line(x, y, x - 1, y - h)
    end
end

-- 飞鸟
local function drawBird(x, y, s, t)
    local flap = math.sin(t * 5 + x * 0.01) * 4 * s
    love.graphics.setColor(C.bird[1], C.bird[2], C.bird[3], 0.9)
    love.graphics.line(x - 6*s, y + flap*0.5, x, y)
    love.graphics.line(x, y, x + 6*s, y + flap*0.5)
    love.graphics.line(x - 3*s, y + flap*0.3, x, y - 1)
    love.graphics.line(x, y - 1, x + 3*s, y + flap*0.3)
end

-- 露珠
local function drawDew(x, y, r, c)
    love.graphics.setColor(c[1], c[2], c[3], 0.55)
    love.graphics.circle("fill", x, y, r)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.circle("fill", x - r*0.3, y - r*0.3, r*0.3)
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 天空 (晨曦渐变)
    for i = 0, 100 do
        local p = i / 100
        local col
        if p < 0.5 then
            local q = p / 0.5
            col = {
                lerp(C.skyTop[1], C.skyMid[1], q),
                lerp(C.skyTop[2], C.skyMid[2], q),
                lerp(C.skyTop[3], C.skyMid[3], q),
            }
        else
            local q = (p - 0.5) / 0.5
            col = {
                lerp(C.skyMid[1], C.skyHor[1], q),
                lerp(C.skyMid[2], C.skyHor[2], q),
                lerp(C.skyMid[3], C.skyHor[3], q),
            }
        end
        love.graphics.setColor(col[1], col[2], col[3], 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 太阳 + 大光晕
    love.graphics.setColor(C.sunGlow[1], C.sunGlow[2], C.sunGlow[3], 0.18)
    love.graphics.circle("fill", W*0.72, HORIZON - 30, 130)
    love.graphics.setColor(C.sunGlow[1], C.sunGlow[2], C.sunGlow[3], 0.32)
    love.graphics.circle("fill", W*0.72, HORIZON - 30, 80)
    love.graphics.setColor(C.sun[1], C.sun[2], C.sun[3], 0.95)
    love.graphics.circle("fill", W*0.72, HORIZON - 30, 38)

    -- 3) 远山 (两层)
    drawMountain(W*0.20, HORIZON,  340, 130, C.mountainN)
    drawMountain(W*0.45, HORIZON,  420, 170, C.mountainN)
    drawMountain(W*0.70, HORIZON,  360, 150, C.mountainN)
    drawMountain(W*0.92, HORIZON,  280, 110, C.mountainN)
    drawMountain(W*0.10, HORIZON+5, 280, 100, C.mountain)
    drawMountain(W*0.60, HORIZON+5, 320, 120, C.mountain)

    -- 4) 晨雾 (横向柔带)
    for k = 1, 5 do
        local yk = HORIZON + k * 8
        love.graphics.setColor(0.95, 0.85, 0.75, 0.10)
        love.graphics.rectangle("fill", 0, yk, W, 14)
    end

    -- 5) 远草地
    love.graphics.setColor(C.grassFar[1], C.grassFar[2], C.grassFar[3], 1)
    love.graphics.rectangle("fill", 0, HORIZON + 6, W, H*0.10)
    -- 中草地
    love.graphics.setColor(C.grassMid[1], C.grassMid[2], C.grassMid[3], 1)
    love.graphics.rectangle("fill", 0, HORIZON + 40, W, H*0.18)

    -- 6) 飞鸟 (远处)
    drawBird(W*0.20, HORIZON - 80, 0.9, t)
    drawBird(W*0.30, HORIZON - 100, 0.7, t + 1.0)
    drawBird(W*0.42, HORIZON - 70, 0.8, t + 2.0)
    drawBird(W*0.55, HORIZON - 95, 0.6, t + 0.5)
    drawBird(W*0.78, HORIZON - 60, 0.7, t + 1.7)

    -- 7) 帐篷
    drawTent(W*0.30, HORIZON + 90, 130, 90, C.tent)
    drawTent(W*0.42, HORIZON + 95, 100, 70, C.tentDk)

    -- 8) 篝火
    drawCampfire(W*0.36, HORIZON + 110, t)

    -- 9) 烟雾 (篝火上方)
    for k = 1, 4 do
        local yo = HORIZON + 110 - 30 - k * 16
        local xo = W*0.36 + math.sin(t*1.3 + k) * 6
        love.graphics.setColor(0.85, 0.85, 0.85, 0.18 - k*0.03)
        love.graphics.circle("fill", xo, yo, 12 + k*2)
    end

    -- 10) 近草 (细密)
    drawGrassStrip(HORIZON + 130,  90, 5, 10, C.grassNear)
    drawGrassStrip(HORIZON + 150,  120, 7, 14, C.grassNear)
    drawGrassStrip(HORIZON + 175,  150, 10, 18, C.grassNear)

    -- 11) 露珠
    for i = 1, 40 do
        local x = (i * 91) % W
        local y = HORIZON + 145 + (i*7) % 30
        drawDew(x, y, 1.2 + rnd(i)*0.8, {0.85, 0.95, 1.0})
    end

    -- 12) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.90,0.70,0.45,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(1, 0.95, 0.85, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.11  ·  草原晨雾  ·  Grassland Dawn", 24, 12)
    love.graphics.setColor(0.95, 0.90, 0.80, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("草 · 雾 · 朝霞 · 远山 · 帐篷 · 篝火 · 飞鸟 · 露珠", 24, 48)
    love.graphics.setColor(0.85, 0.85, 0.80, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 13) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.95, 0.88, 0.75, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("晨光爬上草尖 — 露珠还没决定要不要落下来", 24, H-23)
end
return M
