-- 风景集 / No.09  极光雪原  Aurora Snow
-- 深青 · 极光 (绿/紫) · 星空 · 雪松 · 雪
local M = { name = "aurora_snow" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop = {0.02, 0.05, 0.12},
    skyMid = {0.05, 0.12, 0.20},
    skyHor = {0.10, 0.20, 0.30},
    mtn1   = {0.15, 0.20, 0.30},
    mtn2   = {0.10, 0.15, 0.25},
    mtn3   = {0.20, 0.25, 0.35},
    snow   = {0.85, 0.92, 0.95},
    pine   = {0.05, 0.20, 0.15},
    pineL  = {0.10, 0.30, 0.20},
}

-- 星星
local STARS = {}
for i = 1, 200 do
    STARS[i] = {
        x  = rnd(i*1.1) * W,
        y  = rnd(i*2.3) * H*0.55,
        s  = 0.4 + rnd(i*3.7) * 1.5,
        a  = 0.5 + rnd(i*4.1) * 0.5,
        ph = rnd(i*5.7) * 6.28,
    }
end

-- 雪花
local FLAKES = {}
for i = 1, 90 do
    FLAKES[i] = {
        x  = rnd(i*1.1) * W,
        y  = rnd(i*2.3) * H,
        s  = 0.8 + rnd(i*3.3) * 2.0,
        v  = 20 + rnd(i*4.5) * 50,
        ph = rnd(i*5.7) * 6.28,
    }
end

-- 极光带 (3道)
local AURORAS = {}
for i = 1, 3 do
    AURORAS[i] = {
        y0 = 50 + i*40,
        h  = 180 + i*30,
        amp= 50 + i*15,
        ph = rnd(i*2.1) * 6.28,
        a  = 0.4 - i*0.1,
    }
end

-- 一棵雪松 (三角塔)
local function drawPine(x, baseY, h, s, col, colL)
    -- 干
    love.graphics.setColor(0.30, 0.20, 0.10, 1)
    love.graphics.rectangle("fill", x - 1.5*s, baseY, 3*s, h*0.15)
    -- 3层冠
    for k = 0, 2 do
        local layerY = baseY - h*0.15 - k * h*0.30
        local layerH = h*0.5 - k * h*0.12
        local layerW = h*0.45 - k * h*0.10
        love.graphics.setColor(col[1], col[2], col[3], 1)
        love.graphics.polygon("fill", {
            x - layerW*s, layerY, x + layerW*s, layerY,
            x, layerY - layerH*s
        })
        -- 亮面
        love.graphics.setColor(colL[1], colL[2], colL[3], 0.5)
        love.graphics.polygon("fill", {
            x, layerY, x + layerW*s*0.4, layerY,
            x, layerY - layerH*s
        })
        -- 雪顶
        love.graphics.setColor(C.snow[1], C.snow[2], C.snow[3], 0.9)
        love.graphics.polygon("fill", {
            x - layerW*s*0.4, layerY - layerH*s*0.05,
            x + layerW*s*0.4, layerY - layerH*s*0.05,
            x, layerY - layerH*s*0.7
        })
    end
end

-- 远山
local function drawMountain(yBase, col, h, j)
    love.graphics.setColor(col[1], col[2], col[3], 1)
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
    -- 雪冠
    love.graphics.setColor(C.snow[1], C.snow[2], C.snow[3], 0.5)
    local pts2 = {}
    pts2[1] = 0; pts2[2] = H
    for i = 0, 20 do
        local p = i / 20
        local x = p * W
        local y = yBase - math.abs(math.sin(p*4 + j)) * h - (i%3)*h*0.1 - 20
        if i > 0 and i < 20 and y < yBase - h*0.2 then
            pts2[#pts2+1] = x; pts2[#pts2+1] = y
        else
            pts2[#pts2+1] = x; pts2[#pts2+1] = yBase - 30
        end
    end
    pts2[#pts2+1] = W; pts2[#pts2+1] = yBase - 30
    pts2[#pts2+1] = 0; pts2[#pts2+1] = yBase - 30
end

-- 极光 (单条)
local function drawAurora(t, A, hueR, hueG, hueB)
    local pts = {}
    for i = 0, 60 do
        local p = i / 60
        local x = p * W
        local y = A.y0 + math.sin(p*4 + A.ph + t*0.3) * A.amp
                 + math.sin(p*8 + t*0.5) * A.amp*0.3
        pts[#pts+1] = x; pts[#pts+1] = y
    end
    -- 厚带
    for k = 0, 3 do
        love.graphics.setColor(hueR, hueG, hueB, A.a*0.25)
        local p2 = {}
        for i = 1, #pts, 2 do
            p2[i]   = pts[i]
            p2[i+1] = pts[i+1] + k * 8
        end
        for i = #pts+1, #p2 do p2[i] = nil end
        p2[1] = 0; p2[2] = pts[2]
        p2[#p2+1] = 0; p2[#p2+1] = pts[2]
        p2[#p2+1] = W; p2[#p2+1] = pts[#pts] + k*8
        p2[#p2+1] = W; p2[#p2+1] = pts[2]
        love.graphics.polygon("fill", p2)
    end
    -- 中心细线
    love.graphics.setColor(1.0, 1.0, 1.0, A.a*0.8)
    love.graphics.line(pts)
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 夜空 (深青)
    for i = 0, 100 do
        local p = i / 100
        local r = lerp(C.skyTop[1], C.skyHor[1], p)
        local g = lerp(C.skyTop[2], C.skyHor[2], p)
        local b = lerp(C.skyTop[3], C.skyHor[3], p)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 星星
    for _, S in ipairs(STARS) do
        local tw = 0.6 + 0.4 * math.sin(t*2 + S.ph)
        love.graphics.setColor(1, 1, 1, S.a * tw)
        love.graphics.circle("fill", S.x, S.y, S.s)
        if S.s > 1.2 then
            love.graphics.setColor(0.85, 0.95, 1.0, S.a * tw * 0.4)
            love.graphics.line(S.x - S.s*3, S.y, S.x + S.s*3, S.y)
            love.graphics.line(S.x, S.y - S.s*3, S.x, S.y + S.s*3)
        end
    end

    -- 3) 极光 (3条, 异色)
    drawAurora(t, AURORAS[1], 0.30, 1.00, 0.55)  -- 绿
    drawAurora(t, AURORAS[2], 0.55, 0.85, 1.00)  -- 蓝白
    drawAurora(t, AURORAS[3], 0.85, 0.40, 1.00)  -- 紫

    -- 4) 远山
    drawMountain(H*0.50, C.mtn1, 80, 1)
    drawMountain(H*0.55, C.mtn2, 60, 2)
    drawMountain(H*0.60, C.mtn3, 50, 3)

    -- 5) 雪原地面
    for i = 0, 30 do
        local p = i / 30
        local y = H*0.78 + p * H*0.22
        love.graphics.setColor(0.95, 0.97, 1.0, lerp(0.9, 0.6, p))
        love.graphics.rectangle("fill", 0, y, W, H*0.0075 + 2)
    end

    -- 6) 远景雪松
    for i = 1, 8 do
        drawPine(80 + i*150, H*0.80, 110 + (i%3)*15, 0.7, C.pine, C.pineL)
    end

    -- 7) 中景雪松
    for i = 1, 5 do
        drawPine(180 + i*220, H*0.86, 160 + (i%3)*20, 1.0, C.pine, C.pineL)
    end

    -- 8) 前景雪松 (大)
    drawPine(W*0.05, H*0.95, 280, 1.6, C.pine, C.pineL)
    drawPine(W*0.12, H*0.96, 240, 1.4, C.pine, C.pineL)
    drawPine(W*0.88, H*0.96, 260, 1.5, C.pine, C.pineL)
    drawPine(W*0.95, H*0.95, 280, 1.6, C.pine, C.pineL)

    -- 9) 雪花
    for _, F in ipairs(FLAKES) do
        local fy = (F.y + t * F.v) % H
        local fx = F.x + math.sin(t*0.8 + F.ph) * 8
        love.graphics.setColor(1, 1, 1, 0.85)
        love.graphics.circle("fill", fx, fy, F.s)
    end

    -- 10) 顶部信息条
    love.graphics.setColor(0,0,0,0.55)
    love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.50,0.90,0.70,0.6)
    love.graphics.rectangle("fill", 0, 75, W, 1)

    love.graphics.setColor(0.90,1.0,0.95,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.09  ·  极光雪原  ·  Aurora Snow", 24, 12)
    love.graphics.setColor(0.75,0.95,0.85,0.95); love.graphics.setFont(subFont)
    love.graphics.print("极光 · 星空 · 雪松 · 雪原 · 雪花", 24, 48)
    love.graphics.setColor(0.65,0.85,0.75,0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 11) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.75,0.95,0.85,0.85); love.graphics.setFont(subFont)
    love.graphics.print("-40°C 的天空突然亮了起来 — 极光在点名", 24, H-23)
end
return M
