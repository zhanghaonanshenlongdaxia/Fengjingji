-- 风景集 / No.16  樱花隧道  Sakura Tunnel
-- 樱花树 · 花瓣雨 · 石板路 · 路灯 · 远山口 · 猫 · 鸟
local M = { name = "sakura_tunnel" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop   = {0.70, 0.80, 0.95},
    skyMid   = {0.95, 0.85, 0.92},
    skyHor   = {1.00, 0.90, 0.92},
    ground   = {0.55, 0.45, 0.42},
    groundLt = {0.70, 0.60, 0.55},
    stone    = {0.65, 0.55, 0.50},
    stoneDk  = {0.42, 0.35, 0.32},
    trunk    = {0.30, 0.22, 0.18},
    trunkDk  = {0.18, 0.12, 0.10},
    bloomLt  = {1.00, 0.85, 0.90},
    bloom    = {1.00, 0.70, 0.78},
    bloomDk  = {0.92, 0.55, 0.65},
    bloomDp  = {0.78, 0.40, 0.55},
    petal    = {1.00, 0.80, 0.85},
    lampDk   = {0.20, 0.18, 0.15},
    lampGlow = {1.00, 0.90, 0.65},
    cat      = {0.20, 0.18, 0.18},
    catLt    = {0.40, 0.36, 0.34},
    bird     = {0.30, 0.20, 0.25},
}

-- 远山
local function drawMtn(cx, baseY, w, h, c)
    love.graphics.setColor(c[1], c[2], c[3], 0.55)
    love.graphics.polygon("fill", {
        cx - w*0.5, baseY, cx + w*0.5, baseY,
        cx,           baseY - h,
    })
end

-- 樱花树 (近)
local function drawSakuraTree(x, baseY, h, t, full)
    -- 投影
    love.graphics.setColor(0.10, 0.08, 0.08, 0.20)
    love.graphics.ellipse("fill", x + 4, baseY + 1, 50, 4)
    -- 主干
    love.graphics.setColor(C.trunk[1], C.trunk[2], C.trunk[3], 1)
    love.graphics.polygon("fill", {
        x - 6, baseY, x + 6, baseY,
        x + 4, baseY - h*0.6, x - 4, baseY - h*0.6,
    })
    love.graphics.setColor(C.trunkDk[1], C.trunkDk[2], C.trunkDk[3], 1)
    love.graphics.polygon("fill", {
        x, baseY, x + 6, baseY,
        x + 4, baseY - h*0.6, x, baseY - h*0.6,
    })
    -- 主分枝
    for k = 0, 2 do
        local yk = baseY - h * (0.3 + k*0.15)
        local ang = -0.5 + k * 0.5
        local ex = x + math.cos(ang) * 25
        local ey = yk - 15
        love.graphics.setColor(C.trunk[1], C.trunk[2], C.trunk[3], 1)
        love.graphics.line(x, yk, ex, ey)
    end
    -- 花团 (4~6 大团)
    local clusters = full and 6 or 4
    for k = 0, clusters-1 do
        local ang = k / clusters * math.pi * 2
        local r = 30 + rnd(k*7) * 12
        local cx = x + math.cos(ang) * 18
        local cy = baseY - h*0.7 + math.sin(ang) * 12
        local wob = math.sin(t*0.8 + k) * 2
        -- 暗底
        love.graphics.setColor(C.bloomDk[1], C.bloomDk[2], C.bloomDk[3], 1)
        love.graphics.circle("fill", cx + wob, cy + 2, r)
        -- 主花
        love.graphics.setColor(C.bloom[1], C.bloom[2], C.bloom[3], 1)
        love.graphics.circle("fill", cx + wob, cy, r * 0.85)
        -- 亮花
        love.graphics.setColor(C.bloomLt[1], C.bloomLt[2], C.bloomLt[3], 1)
        love.graphics.circle("fill", cx + wob - r*0.2, cy - r*0.2, r * 0.5)
        -- 深花点
        love.graphics.setColor(C.bloomDp[1], C.bloomDp[2], C.bloomDp[3], 0.6)
        love.graphics.circle("fill", cx + wob + r*0.2, cy + r*0.15, r * 0.25)
    end
    -- 小花瓣点
    for i = 1, 12 do
        local a = i * 0.9
        local d = 20 + rnd(i*3) * 20
        love.graphics.setColor(C.petal[1], C.petal[2], C.petal[3], 0.95)
        love.graphics.circle("fill", x + math.cos(a)*d, baseY - h*0.8 + math.sin(a)*d, 2)
    end
end

-- 单片花瓣 (下落)
local PETALS = {}
for i = 1, 50 do
    PETALS[i] = {
        x = rnd(i*3) * W,
        y = rnd(i*5) * H,
        v = 20 + rnd(i*7) * 25,
        ph = rnd(i*11) * 6.28,
        sz = 2 + rnd(i*13) * 3,
        spin = 0.5 + rnd(i*17) * 1.5,
    }
end

-- 路灯
local function drawLamp(x, baseY, t)
    -- 杆
    love.graphics.setColor(0.20, 0.18, 0.15, 1)
    love.graphics.rectangle("fill", x - 1.5, baseY - 130, 3, 130)
    -- 灯罩
    love.graphics.setColor(0.30, 0.25, 0.18, 1)
    love.graphics.polygon("fill", {
        x - 8, baseY - 130, x + 8, baseY - 130,
        x + 6, baseY - 145, x - 6, baseY - 145,
    })
    -- 灯芯
    love.graphics.setColor(1.0, 0.95, 0.78, 1)
    love.graphics.circle("fill", x, baseY - 137, 4)
    -- 光晕
    love.graphics.setColor(1.0, 0.90, 0.65, 0.15 + 0.05*math.sin(t*2))
    love.graphics.circle("fill", x, baseY - 137, 30)
    love.graphics.setColor(1.0, 0.92, 0.70, 0.25)
    love.graphics.circle("fill", x, baseY - 137, 18)
end

-- 猫
local function drawCat(x, baseY, t)
    local wag = math.sin(t*4) * 0.2
    -- 投影
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.ellipse("fill", x + 2, baseY + 1, 18, 2)
    -- 身体
    love.graphics.setColor(C.cat[1], C.cat[2], C.cat[3], 1)
    love.graphics.ellipse("fill", x, baseY - 5, 14, 6)
    -- 头
    love.graphics.circle("fill", x + 12, baseY - 8, 5)
    -- 耳
    love.graphics.polygon("fill", {
        x + 8, baseY - 12, x + 10, baseY - 15, x + 12, baseY - 11,
    })
    love.graphics.polygon("fill", {
        x + 12, baseY - 12, x + 14, baseY - 15, x + 16, baseY - 11,
    })
    -- 尾
    love.graphics.setColor(C.catLt[1], C.catLt[2], C.catLt[3], 1)
    love.graphics.setLineWidth(3)
    love.graphics.line(x - 14, baseY - 5, x - 20, baseY - 14 + wag*3)
    love.graphics.setLineWidth(1)  -- 还原, 避免后续 line 都变粗
    -- 眼
    love.graphics.setColor(0.6, 0.85, 0.4, 1)
    love.graphics.circle("fill", x + 13, baseY - 9, 0.8)
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 天空
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

    -- 2) 远山
    drawMtn(W*0.30, H*0.55, 400, 130, {0.50, 0.55, 0.62})
    drawMtn(W*0.65, H*0.55, 380, 110, {0.55, 0.60, 0.65})
    drawMtn(W*0.85, H*0.55, 320, 100, {0.50, 0.55, 0.62})

    -- 3) 远樱花 (剪影, 透视)
    for k = 0, 5 do
        local x = 50 + k * 230
        love.graphics.setColor(C.bloom[1], C.bloom[2], C.bloom[3], 0.7)
        love.graphics.circle("fill", x, H*0.55, 35)
    end

    -- 4) 路面 (透视)
    love.graphics.setColor(C.ground[1], C.ground[2], C.ground[3], 1)
    love.graphics.polygon("fill", {
        0, H, W, H,
        W*0.55, H*0.55, W*0.45, H*0.55,
    })
    -- 路面亮带
    love.graphics.setColor(C.groundLt[1], C.groundLt[2], C.groundLt[3], 0.4)
    love.graphics.polygon("fill", {
        W*0.48, H, W*0.52, H,
        W*0.51, H*0.55, W*0.49, H*0.55,
    })
    -- 石板 (横纹, 由近到远)
    for k = 0, 7 do
        local yk = H - 40 - k * (H*0.06)
        local wW = 30 + k * 30
        love.graphics.setColor(C.stoneDk[1], C.stoneDk[2], C.stoneDk[3], 0.5)
        love.graphics.line(W*0.5 - wW, yk, W*0.5 + wW, yk)
    end

    -- 5) 樱花树 (近景, 双侧)
    drawSakuraTree(W*0.05, H*0.85, 150, t, true)
    drawSakuraTree(W*0.20, H*0.83, 130, t + 1.0, true)
    drawSakuraTree(W*0.85, H*0.85, 145, t + 2.0, true)
    drawSakuraTree(W*0.95, H*0.83, 125, t + 3.0, true)
    -- 中景
    drawSakuraTree(W*0.13, H*0.72, 95, t + 0.5, false)
    drawSakuraTree(W*0.88, H*0.72, 90, t + 1.5, false)
    -- 远景
    drawSakuraTree(W*0.30, H*0.62, 60, t + 0.8, false)
    drawSakuraTree(W*0.70, H*0.62, 55, t + 2.5, false)

    -- 6) 路灯 (透视排列, 双侧)
    drawLamp(W*0.18, H*0.90, t)
    drawLamp(W*0.82, H*0.90, t + 0.5)
    -- 远灯 (更小)
    for k = 0, 2 do
        local lx = 0.50 + (k - 1) * 0.18
        local ly = 0.65 + math.abs(k - 1) * 0.12
        love.graphics.setColor(1.0, 0.95, 0.78, 0.9)
        love.graphics.circle("fill", W*lx, H*ly, 2)
        love.graphics.setColor(1.0, 0.92, 0.70, 0.3)
        love.graphics.circle("fill", W*lx, H*ly, 7)
    end

    -- 7) 猫
    drawCat(W*0.40, H*0.83, t)
    drawCat(W*0.65, H*0.84, t + 1.5)

    -- 8) 鸟 (远飞)
    for i = 1, 4 do
        local bx = W*0.30 + (i*150) % W
        local by = H*0.30 + (i*47) % 80
        local flap = math.sin(t*5 + i)*3
        love.graphics.setColor(C.bird[1], C.bird[2], C.bird[3], 0.8)
        love.graphics.line(bx - 5, by + flap, bx, by)
        love.graphics.line(bx, by, bx + 5, by + flap)
    end

    -- 9) 花瓣飘落
    for _, P in ipairs(PETALS) do
        local px = (P.x + math.sin(t*P.spin + P.ph) * 30) % W
        local py = (P.y + t * P.v) % H
        if py < 0 then py = py + H end
        local rot = t * P.spin + P.ph
        love.graphics.setColor(C.petal[1], C.petal[2], C.petal[3], 0.92)
        love.graphics.push()
        love.graphics.translate(px, py)
        love.graphics.rotate(rot)
        love.graphics.ellipse("fill", 0, 0, P.sz, P.sz*0.6)
        love.graphics.pop()
    end

    -- 10) 地面花瓣堆积 (近景)
    for i = 1, 80 do
        local px = (i * 41) % W
        local py = H - 20 - (i*7) % 80
        love.graphics.setColor(C.petal[1], C.petal[2], C.petal[3], 0.9)
        love.graphics.circle("fill", px, py, 2)
    end

    -- 11) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(1.00,0.70,0.80,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(1, 0.92, 0.95, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.16  ·  樱花隧道  ·  Sakura Tunnel", 24, 12)
    love.graphics.setColor(1, 0.85, 0.88, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("樱花树 · 花瓣雨 · 石板路 · 路灯 · 远山口 · 猫 · 鸟", 24, 48)
    love.graphics.setColor(0.95, 0.80, 0.85, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 12) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(1, 0.85, 0.90, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("花瓣落了 — 路上也开了一季", 24, H-23)
end
return M
