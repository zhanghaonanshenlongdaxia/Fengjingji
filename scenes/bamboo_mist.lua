-- 风景集 / No.07  竹林晨雾  Bamboo Mist
-- 冷白 · 翠绿 · 雾气 · 远山 · 鸟
local M = { name = "bamboo_mist" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop = {0.55, 0.65, 0.70},
    skyMid = {0.80, 0.85, 0.85},
    skyHor = {0.95, 0.95, 0.92},
    mtn1   = {0.60, 0.70, 0.68},
    mtn2   = {0.50, 0.62, 0.60},
    mtn3   = {0.40, 0.55, 0.55},
    bamboo = {0.20, 0.55, 0.30},
    bambooD= {0.15, 0.42, 0.22},
    bambooL= {0.35, 0.70, 0.42},
    ground = {0.55, 0.62, 0.50},
    bird   = {0.15, 0.20, 0.18},
}

-- 鸟 (8只, 飞)
local BIRDS = {}
for i = 1, 8 do
    BIRDS[i] = {
        x = rnd(i*1.1) * W,
        y = H*0.15 + rnd(i*2.3) * H*0.25,
        v = 25 + rnd(i*3.1) * 30,
        s = 0.6 + rnd(i*4.7) * 0.6,
        ph= rnd(i*5.9) * 6.28,
    }
end

-- 雾团 (横向)
local MISTS = {}
for i = 1, 12 do
    MISTS[i] = {
        x  = rnd(i*1.3) * W,
        y  = H*0.40 + rnd(i*2.1) * H*0.35,
        r  = 80 + rnd(i*3.3) * 100,
        a  = 0.20 + rnd(i*4.5) * 0.30,
        v  = 8 + rnd(i*5.7) * 12,
        ph = rnd(i*6.9) * 6.28,
    }
end

-- 落叶 (空中飘)
local LEAVES = {}
for i = 1, 25 do
    LEAVES[i] = {
        x  = rnd(i*1.1) * W,
        y  = rnd(i*2.1) * H,
        s  = 1.2 + rnd(i*3.3) * 1.5,
        v  = 15 + rnd(i*4.5) * 25,
        d  = 1 + rnd(i*5.7),
        ph = rnd(i*6.9) * 6.28,
        c  = rnd(i*7.1) < 0.5 and C.bamboo or {0.30, 0.60, 0.35},
    }
end

-- 一根竹 (有节)
local function drawBamboo(x, baseY, h, s, col, colD)
    -- 干
    love.graphics.setColor(col[1], col[2], col[3], 0.95)
    love.graphics.polygon("fill", {
        x - 3*s, baseY, x + 3*s, baseY,
        x + 3*s, baseY - h, x - 3*s, baseY - h
    })
    -- 节 (深色横纹)
    for k = 1, math.floor(h/(15*s)) do
        love.graphics.setColor(colD[1], colD[2], colD[3], 0.7)
        love.graphics.rectangle("fill", x - 4*s, baseY - k*15*s, 8*s, 1.5*s)
    end
    -- 暗面
    love.graphics.setColor(colD[1], colD[2], colD[3], 0.4)
    love.graphics.polygon("fill", {
        x + 1*s, baseY, x + 3*s, baseY,
        x + 3*s, baseY - h, x + 1*s, baseY - h
    })
    -- 顶端叶
    for k = 1, 4 do
        local ang = (k-1) * 1.2 + 0.3
        local ex = x + math.cos(ang) * 14*s
        local ey = baseY - h + math.sin(ang) * 14*s * 0.3 - 4
        love.graphics.setColor(0.30, 0.65, 0.35, 0.85)
        love.graphics.polygon("fill", {
            x, baseY - h, ex, ey - 2, ex + 2, ey + 1, x, baseY - h + 4
        })
    end
end

-- 一只鸟 (M字)
local function drawBird(x, y, s, t)
    local flap = math.sin(t*4) * 1.5*s
    love.graphics.setColor(C.bird[1], C.bird[2], C.bird[3], 0.7)
    love.graphics.line(x - 4*s, y + flap, x, y)
    love.graphics.line(x, y, x + 4*s, y + flap)
end

-- 远山
local function drawMountain(yBase, col, h, j)
    love.graphics.setColor(col[1], col[2], col[3], 0.85)
    local pts = {}
    pts[1] = 0; pts[2] = H
    for i = 0, 20 do
        local p = i / 20
        local x = p * W
        local y = yBase - math.abs(math.sin(p*4 + j)) * h - (i%3)*h*0.1 - 20
        pts[#pts+1] = x; pts[#pts+1] = y
    end
    pts[#pts+1] = W; pts[#pts+1] = H
    love.graphics.polygon("fill", pts)
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 天空 (青灰→冷白)
    for i = 0, 100 do
        local p = i / 100
        local r = lerp(C.skyTop[1], C.skyMid[1], p)
        local g = lerp(C.skyTop[2], C.skyMid[2], p)
        local b = lerp(C.skyTop[3], C.skyMid[3], p)
        if p > 0.5 then
            local q = (p - 0.5) / 0.5
            r = lerp(r, C.skyHor[1], q)
            g = lerp(g, C.skyHor[2], q)
            b = lerp(b, C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 太阳柔光 (右)
    love.graphics.setColor(0.95, 0.95, 0.85, 0.20)
    love.graphics.circle("fill", W*0.80, H*0.20, 80)
    love.graphics.setColor(0.98, 0.95, 0.85, 0.50)
    love.graphics.circle("fill", W*0.80, H*0.20, 35)

    -- 3) 远山 (3层)
    drawMountain(H*0.45, C.mtn1, 80, 1)
    drawMountain(H*0.50, C.mtn2, 60, 2)
    drawMountain(H*0.55, C.mtn3, 50, 3)

    -- 4) 地面 (草坡)
    love.graphics.setColor(C.ground[1], C.ground[2], C.ground[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.75, W*0.2, H*0.72, W*0.5, H*0.78, W*0.8, H*0.74, W, H*0.78,
        W, H, 0, H
    })
    -- 草高光
    love.graphics.setColor(0.70, 0.80, 0.60, 0.4)
    love.graphics.polygon("fill", {
        0, H*0.74, W*0.2, H*0.71, W*0.5, H*0.77, W*0.8, H*0.73, W, H*0.77,
        W, H*0.78, 0, H*0.78
    })

    -- 5) 后景竹 (深, 密)
    for i = 1, 12 do
        local x = 30 + i * 100
        local h = 280 + (i%3) * 50
        local s = 0.8 + (i%2) * 0.3
        drawBamboo(x, H*0.78, h, s, C.bambooD, C.bamboo)
    end

    -- 6) 雾团 (在山和后景竹之间)
    for _, M_ in ipairs(MISTS) do
        local mx = (M_.x + t * M_.v) % (W + 200) - 100
        love.graphics.setColor(0.90, 0.92, 0.90, M_.a)
        love.graphics.circle("fill", mx, M_.y, M_.r)
        love.graphics.setColor(0.95, 0.97, 0.95, M_.a*0.6)
        love.graphics.circle("fill", mx + 20, M_.y - 5, M_.r*0.8)
    end

    -- 7) 飞鸟
    for _, B in ipairs(BIRDS) do
        local bx = (B.x + t * B.v) % (W + 50) - 25
        local by = B.y + math.sin(t*0.5 + B.ph) * 8
        drawBird(bx, by, B.s, t + B.ph)
    end

    -- 8) 中景竹 (中)
    drawBamboo(W*0.20, H*0.85, 380, 1.4, C.bamboo, C.bambooD)
    drawBamboo(W*0.30, H*0.87, 420, 1.5, C.bambooL, C.bambooD)
    drawBamboo(W*0.45, H*0.84, 360, 1.3, C.bamboo, C.bambooD)
    drawBamboo(W*0.55, H*0.86, 400, 1.5, C.bambooL, C.bambooD)
    drawBamboo(W*0.70, H*0.85, 380, 1.4, C.bamboo, C.bambooD)
    drawBamboo(W*0.85, H*0.86, 360, 1.3, C.bambooL, C.bambooD)

    -- 9) 前景竹 (大, 暗)
    drawBamboo(W*0.05, H*0.95, 520, 1.9, C.bambooD, C.bamboo)
    drawBamboo(W*0.12, H*0.96, 480, 1.7, C.bamboo, C.bambooD)
    drawBamboo(W*0.90, H*0.96, 500, 1.8, C.bambooD, C.bamboo)
    drawBamboo(W*0.96, H*0.97, 460, 1.7, C.bamboo, C.bambooD)

    -- 10) 落叶
    for _, L in ipairs(LEAVES) do
        local lx = (L.x + t * L.v * 0.5) % (W + 20)
        local ly = (L.y + t * L.v) % H
        love.graphics.setColor(L.c[1], L.c[2], L.c[3], 0.85)
        love.graphics.polygon("fill", {
            lx, ly, lx + L.s*3, ly + L.s, lx + L.s*4, ly + L.s*2.5,
            lx + L.s*2, ly + L.s*3, lx - L.s, ly + L.s*1.5
        })
    end

    -- 11) 顶部信息条
    love.graphics.setColor(0,0,0,0.45)
    love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.55,0.80,0.65,0.6)
    love.graphics.rectangle("fill", 0, 75, W, 1)

    love.graphics.setColor(0.90,0.95,0.90,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.07  ·  竹林晨雾  ·  Bamboo Mist", 24, 12)
    love.graphics.setColor(0.80,0.90,0.82,0.95); love.graphics.setFont(subFont)
    love.graphics.print("翠竹 · 远山 · 飞鸟 · 晨雾 · 落叶", 24, 48)
    love.graphics.setColor(0.70,0.85,0.75,0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 12) 底部
    love.graphics.setColor(0,0,0,0.35); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.80,0.90,0.82,0.85); love.graphics.setFont(subFont)
    love.graphics.print("雨后初晴，竹叶滴翠 — 一次呼吸 40 步", 24, H-23)
end
return M
