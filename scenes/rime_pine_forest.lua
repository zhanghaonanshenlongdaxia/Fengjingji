-- 风景集 / No.17  雾凇林海  Rime Pine Forest
-- 雾凇松 · 雪原 · 朝阳金光 · 鹿 · 脚印 · 冰凌 · 远山
local M = { name = "rime_pine_forest" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop   = {0.65, 0.78, 0.92},
    skyMid   = {0.95, 0.85, 0.78},
    skyHor   = {1.00, 0.92, 0.85},
    sun      = {1.00, 0.95, 0.80},
    sunGlow  = {1.00, 0.78, 0.50},
    snowL    = {0.98, 0.99, 1.00},
    snowM    = {0.85, 0.90, 0.95},
    snowD    = {0.65, 0.75, 0.85},
    trunk    = {0.25, 0.22, 0.20},
    trunkDk  = {0.15, 0.12, 0.10},
    pine     = {0.20, 0.32, 0.22},
    pineLt   = {0.45, 0.60, 0.50},
    rime     = {0.92, 0.96, 1.00},
    rimeDk   = {0.70, 0.80, 0.92},
    deer     = {0.45, 0.30, 0.18},
    deerLt   = {0.65, 0.50, 0.35},
    iceBlue  = {0.55, 0.78, 0.95},
}

-- 雾凇松
local function drawPine(x, baseY, h, t, hasRime)
    -- 投影
    love.graphics.setColor(0.10, 0.15, 0.20, 0.25)
    love.graphics.ellipse("fill", x + 5, baseY + 1, 30, 4)
    -- 主干
    love.graphics.setColor(C.trunk[1], C.trunk[2], C.trunk[3], 1)
    love.graphics.polygon("fill", {
        x - 5, baseY, x + 5, baseY,
        x + 2, baseY - h, x - 2, baseY - h,
    })
    -- 松针层 (5 层, 由下到上)
    for k = 0, 4 do
        local p = k / 4
        local yk = baseY - h * (0.3 + p*0.65)
        local w  = (1 - p) * 35 + 8
        local sway = math.sin(t*0.8 + k) * 2
        -- 暗底
        love.graphics.setColor(C.pine[1]*0.5, C.pine[2]*0.5, C.pine[3]*0.5, 1)
        love.graphics.polygon("fill", {
            x - w - 4, yk + 4, x + w + 4, yk + 4,
            x, yk - 18,
        })
        -- 主松针
        love.graphics.setColor(C.pine[1], C.pine[2], C.pine[3], 1)
        love.graphics.polygon("fill", {
            x - w + sway, yk, x + w + sway, yk,
            x + sway, yk - 20,
        })
        -- 亮边
        love.graphics.setColor(C.pineLt[1], C.pineLt[2], C.pineLt[3], 0.7)
        love.graphics.polygon("fill", {
            x - w + sway, yk, x + sway, yk,
            x + sway, yk - 18,
        })
        -- 雾凇 (白边)
        if hasRime then
            love.graphics.setColor(C.rime[1], C.rime[2], C.rime[3], 0.92)
            love.graphics.polygon("fill", {
                x - w + sway, yk, x + w + sway, yk,
                x + w*0.7 + sway, yk - 2,
                x + w*0.3 + sway, yk - 1,
            })
            -- 雾凇冰晶 (右角)
            love.graphics.setColor(C.rimeDk[1], C.rimeDk[2], C.rimeDk[3], 0.9)
            love.graphics.polygon("fill", {
                x + w*0.5 + sway, yk, x + w + sway, yk,
                x + w*0.85 + sway, yk - 6,
            })
        end
    end
    -- 顶尖冰
    if hasRime then
        love.graphics.setColor(C.rime[1], C.rime[2], C.rime[3], 1)
        love.graphics.polygon("fill", {
            x - 2, baseY - h, x + 2, baseY - h, x, baseY - h - 12,
        })
    end
end

-- 鹿
local function drawDeer(x, baseY, t, dir)
    dir = dir or 1
    local bob = math.sin(t*2 + x*0.01) * 1.5
    -- 投影
    love.graphics.setColor(0, 0, 0, 0.30)
    love.graphics.ellipse("fill", x + 3, baseY + 1, 30, 3)
    -- 腿
    love.graphics.setColor(C.deer[1], C.deer[2], C.deer[3], 1)
    love.graphics.rectangle("fill", x - 12*dir, baseY - 22 + bob, 2.5, 22)
    love.graphics.rectangle("fill", x - 4*dir,  baseY - 22 - bob, 2.5, 22)
    love.graphics.rectangle("fill", x + 6*dir,  baseY - 22 + bob, 2.5, 22)
    love.graphics.rectangle("fill", x + 12*dir, baseY - 22 - bob, 2.5, 22)
    -- 身体
    love.graphics.setColor(C.deer[1], C.deer[2], C.deer[3], 1)
    love.graphics.ellipse("fill", x, baseY - 26, 18, 8)
    -- 颈部
    love.graphics.setColor(C.deer[1], C.deer[2], C.deer[3], 1)
    love.graphics.polygon("fill", {
        x + 14*dir, baseY - 26, x + 18*dir, baseY - 26,
        x + 22*dir, baseY - 38, x + 17*dir, baseY - 38,
    })
    -- 头
    love.graphics.ellipse("fill", x + 22*dir, baseY - 42, 5, 4)
    -- 耳
    love.graphics.polygon("fill", {
        x + 19*dir, baseY - 44, x + 21*dir, baseY - 48, x + 23*dir, baseY - 44,
    })
    -- 鹿角
    love.graphics.setColor(C.deerLt[1], C.deerLt[2], C.deerLt[3], 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(x + 22*dir, baseY - 45, x + 25*dir, baseY - 56)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(x + 25*dir, baseY - 56, x + 28*dir, baseY - 60)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(x + 25*dir, baseY - 56, x + 22*dir, baseY - 60)
    love.graphics.setLineWidth(2)
    love.graphics.line(x + 22*dir, baseY - 45, x + 19*dir, baseY - 56)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(x + 19*dir, baseY - 56, x + 16*dir, baseY - 60)
    -- 浅色腹部
    love.graphics.setColor(C.deerLt[1], C.deerLt[2], C.deerLt[3], 0.7)
    love.graphics.ellipse("fill", x, baseY - 22, 14, 3)
end

-- 冰凌
local function drawIcicle(x, y, h, w, t)
    love.graphics.setColor(C.iceBlue[1], C.iceBlue[2], C.iceBlue[3], 0.7)
    love.graphics.polygon("fill", {
        x - w, y, x + w, y,
        x, y + h,
    })
    love.graphics.setColor(0.95, 1.0, 1.0, 0.8)
    love.graphics.line(x, y, x, y + h)
end

-- 远山
local function drawMtn(cx, baseY, w, h, c)
    love.graphics.setColor(c[1], c[2], c[3], 0.7)
    love.graphics.polygon("fill", {
        cx - w*0.5, baseY, cx + w*0.5, baseY,
        cx,           baseY - h,
    })
    -- 雪顶
    love.graphics.setColor(0.95, 0.98, 1.0, 0.85)
    love.graphics.polygon("fill", {
        cx - w*0.10, baseY - h*0.78,
        cx, baseY - h,
        cx + w*0.10, baseY - h*0.78,
    })
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 天空 (朝霞)
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.5 then
            r = lerp(C.skyTop[1], C.skyMid[1], p/0.5)
            g = lerp(C.skyTop[2], C.skyMid[2], p/0.5)
            b = lerp(C.skyTop[3], C.skyMid[3], p/0.5)
        else
            local q = (p - 0.5) / 0.5
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 太阳 (低角度, 偏暖)
    love.graphics.setColor(C.sunGlow[1], C.sunGlow[2], C.sunGlow[3], 0.18)
    love.graphics.circle("fill", W*0.20, H*0.35, 130)
    love.graphics.setColor(C.sunGlow[1], C.sunGlow[2], C.sunGlow[3], 0.35)
    love.graphics.circle("fill", W*0.20, H*0.35, 80)
    love.graphics.setColor(C.sun[1], C.sun[2], C.sun[3], 0.95)
    love.graphics.circle("fill", W*0.20, H*0.35, 38)

    -- 3) 远山
    drawMtn(W*0.45, H*0.50, 480, 150, {0.55, 0.60, 0.68})
    drawMtn(W*0.85, H*0.50, 420, 130, {0.50, 0.55, 0.65})
    drawMtn(W*0.10, H*0.52, 380, 110, {0.55, 0.60, 0.68})

    -- 4) 远树 (小雾凇)
    for k = 0, 18 do
        local x = (k * 67 + 30) % W
        local h = 25 + rnd(k*3) * 15
        drawPine(x, H*0.65, h, t + k*0.1, false)
    end

    -- 5) 雪原 (3 层)
    love.graphics.setColor(C.snowD[1], C.snowD[2], C.snowD[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.65, 200, H*0.60, 500, H*0.64, 800, H*0.58,
        1200, H*0.62, 1200, H, 0, H,
    })
    love.graphics.setColor(C.snowM[1], C.snowM[2], C.snowM[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.80, 300, H*0.75, 600, H*0.78, 900, H*0.73,
        1200, H*0.76, 1200, H, 0, H,
    })
    love.graphics.setColor(C.snowL[1], C.snowL[2], C.snowL[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.92, 400, H*0.88, 800, H*0.90, 1200, H*0.87, 1200, H, 0, H,
    })

    -- 6) 中树 (雾凇)
    drawPine(W*0.10, H*0.78, 70, t, true)
    drawPine(W*0.25, H*0.80, 60, t + 0.5, true)
    drawPine(W*0.40, H*0.79, 65, t + 1.0, true)
    drawPine(W*0.55, H*0.81, 55, t + 1.5, true)
    drawPine(W*0.70, H*0.79, 68, t + 2.0, true)
    drawPine(W*0.85, H*0.81, 60, t + 2.5, true)
    drawPine(W*0.95, H*0.79, 50, t + 3.0, true)

    -- 7) 近树 (大雾凇)
    drawPine(W*0.08, H*0.92, 110, t, true)
    drawPine(W*0.20, H*0.95, 100, t + 0.3, true)
    drawPine(W*0.92, H*0.93, 105, t + 1.0, true)

    -- 8) 鹿
    drawDeer(W*0.50, H*0.86, t, 1)
    drawDeer(W*0.65, H*0.88, t + 0.5, -1)

    -- 9) 脚印 (雪地)
    for i = 0, 5 do
        local px = W*0.30 + i * 40
        local py = H*0.85 + math.sin(i)*3
        love.graphics.setColor(0.65, 0.72, 0.80, 0.6)
        love.graphics.ellipse("fill", px, py, 4, 2)
    end

    -- 10) 冰凌 (挂树枝)
    for k = 0, 4 do
        local ix = W*0.15 + k * 20
        local iy = H*0.85 + math.sin(k)*3
        drawIcicle(ix, iy, 18, 1.5, t)
    end
    for k = 0, 4 do
        drawIcicle(W*0.85 + k * 15, H*0.86 + math.sin(k*2)*3, 14, 1.2, t)
    end

    -- 11) 飘雪
    for i = 1, 50 do
        local ph = i * 2.3
        local x = (i*53) % W + math.sin(t*0.7 + ph) * 10
        local y = (i*37 + t*15) % H
        love.graphics.setColor(1, 1, 1, 0.85)
        love.graphics.circle("fill", x, y, 0.8 + rnd(i*11+ph)*0.7)
    end

    -- 12) 阳光射线 (低角度)
    for k = 1, 6 do
        local ang = 0.3 + k * 0.05
        love.graphics.setColor(1.0, 0.92, 0.70, 0.08)
        love.graphics.setLineWidth(25)
        love.graphics.line(W*0.20, H*0.35,
            W*0.20 + math.cos(ang) * 800,
            H*0.35 + math.sin(ang) * 800)
    end

    -- 13) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.90,0.95,1.00,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(1, 0.98, 0.95, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.17  ·  雾凇林海  ·  Rime Pine Forest", 24, 12)
    love.graphics.setColor(0.95, 0.95, 1.0, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("雾凇松 · 雪原 · 朝阳金光 · 鹿 · 脚印 · 冰凌 · 远山", 24, 48)
    love.graphics.setColor(0.85, 0.90, 0.95, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 14) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.95, 0.98, 1.0, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("霜给松穿了白袍 — 林子比教堂还安静", 24, H-23)
end
return M
