-- 风景集 / No.05  沙漠黄昏  Desert Dusk
-- 沙丘 · 驼队 · 残阳 · 远石柱 · 风沙
local M = { name = "desert_dusk" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop = {0.45, 0.20, 0.45},   -- 紫
    skyMid = {0.95, 0.45, 0.25},   -- 橙红
    skyHor = {1.00, 0.85, 0.45},   -- 暖金
    sun    = {1.00, 0.85, 0.55},
    dune1  = {0.85, 0.55, 0.30},   -- 近沙
    dune2  = {0.70, 0.40, 0.20},   -- 中沙
    dune3  = {0.50, 0.25, 0.15},   -- 远沙
    pillar = {0.30, 0.15, 0.10},   -- 石柱
    camel  = {0.45, 0.25, 0.10},
    camelDrk= {0.30, 0.15, 0.05},
}

-- 风沙
local SANDS = {}
for i = 1, 70 do
    SANDS[i] = {
        x = rnd(i) * W,
        y = H*0.55 + rnd(i*2.1) * H*0.35,
        s = 0.6 + rnd(i*3.3) * 1.0,
        v = 60 + rnd(i*4.1) * 80,
        a = rnd(i*5.7) * 0.4,
    }
end

-- 一个沙丘
local function drawDune(yBase, col, h, j, segments)
    love.graphics.setColor(col[1], col[2], col[3], 1)
    local pts = {}
    pts[1] = 0; pts[2] = H
    for i = 0, segments do
        local p = i / segments
        local x = p * W
        local y = yBase - math.sin(p*3 + j) * h*0.3 - (i%3)*h*0.1 - h*0.5
        pts[#pts+1] = x; pts[#pts+1] = y
    end
    pts[#pts+1] = W; pts[#pts+1] = H
    love.graphics.polygon("fill", pts)
end

-- 一只骆驼
local function drawCamel(x, y, s, phase)
    local px, py = x, y
    local swing = math.sin(phase) * 2 * s
    -- 腿
    love.graphics.setColor(C.camelDrk[1], C.camelDrk[2], C.camelDrk[3], 1)
    love.graphics.rectangle("fill", px - 8*s, py, 2*s, 12*s)
    love.graphics.rectangle("fill", px - 3*s, py + swing*0.3, 2*s, 12*s)
    love.graphics.rectangle("fill", px + 3*s, py - swing*0.3, 2*s, 12*s)
    love.graphics.rectangle("fill", px + 8*s, py, 2*s, 12*s)
    -- 身体
    love.graphics.setColor(C.camel[1], C.camel[2], C.camel[3], 1)
    love.graphics.ellipse("fill", px, py - 2*s, 14*s, 6*s)
    -- 驼峰
    love.graphics.ellipse("fill", px - 3*s, py - 8*s, 5*s, 5*s)
    love.graphics.ellipse("fill", px + 3*s, py - 8*s, 5*s, 5*s)
    -- 头颈 (向前)
    love.graphics.setColor(C.camel[1], C.camel[2], C.camel[3], 1)
    love.graphics.polygon("fill", {
        px + 10*s, py - 6*s, px + 18*s, py - 14*s,
        px + 20*s, py - 12*s, px + 14*s, py - 3*s
    })
    -- 头
    love.graphics.ellipse("fill", px + 20*s, py - 15*s, 3*s, 2.5*s)
    -- 尾巴
    love.graphics.setColor(C.camelDrk[1], C.camelDrk[2], C.camelDrk[3], 1)
    love.graphics.line(px - 14*s, py - 2*s, px - 18*s, py + 2*s)
end

-- 一根石柱 (风蚀)
local function drawPillar(x, baseY, h, s)
    love.graphics.setColor(C.pillar[1], C.pillar[2], C.pillar[3], 1)
    -- 柱身 (梯形+缺口)
    love.graphics.polygon("fill", {
        x - 6*s, baseY, x + 6*s, baseY,
        x + 4*s, baseY - h, x - 4*s, baseY - h
    })
    -- 顶部突起
    love.graphics.polygon("fill", {
        x - 4*s, baseY - h, x + 4*s, baseY - h,
        x + 3*s, baseY - h - 4*s, x - 3*s, baseY - h - 4*s
    })
    -- 亮面
    love.graphics.setColor(C.pillar[1]+0.15, C.pillar[2]+0.10, C.pillar[3]+0.05, 1)
    love.graphics.polygon("fill", {
        x - 4*s, baseY, x - 1*s, baseY,
        x - 1*s, baseY - h, x - 4*s, baseY - h
    })
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 天空 (紫→橙→金)
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.50 then
            local q = p / 0.50
            r = lerp(C.skyTop[1], C.skyMid[1], q)
            g = lerp(C.skyTop[2], C.skyMid[2], q)
            b = lerp(C.skyTop[3], C.skyMid[3], q)
        else
            local q = (p - 0.50) / 0.50
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 太阳
    local sunX, sunY = W*0.30, H*0.50
    for k = 5, 1, -1 do
        love.graphics.setColor(1.0, 0.80, 0.40, 0.08*k)
        love.graphics.circle("fill", sunX, sunY, 50 + k*20)
    end
    love.graphics.setColor(1.0, 0.90, 0.55, 0.95)
    love.graphics.circle("fill", sunX, sunY, 50)
    love.graphics.setColor(1.0, 1.0, 0.85, 0.6)
    love.graphics.circle("fill", sunX - 8, sunY - 8, 18)

    -- 3) 远石柱 (剪影)
    drawPillar(W*0.72, H*0.62, 70, 1.0)
    drawPillar(W*0.78, H*0.63, 50, 0.7)

    -- 4) 远沙丘
    drawDune(H*0.60, C.dune3, 50, 1, 14)
    -- 中沙丘
    drawDune(H*0.68, C.dune2, 70, 2, 12)
    -- 近沙丘
    drawDune(H*0.78, C.dune1, 90, 3, 10)

    -- 5) 沙丘高光
    love.graphics.setColor(1.0, 0.85, 0.50, 0.20)
    love.graphics.polygon("fill", {
        sunX - 250, H*0.65, sunX + 250, H*0.65,
        sunX + 350, H, sunX - 350, H
    })

    -- 6) 驼队 (3只, 走)
    drawCamel(W*0.55, H*0.86, 1.5, t*1.5)
    drawCamel(W*0.60, H*0.86, 1.4, t*1.5 + 0.6)
    drawCamel(W*0.65, H*0.86, 1.3, t*1.5 + 1.2)
    -- 牵驼人
    love.graphics.setColor(0.15, 0.10, 0.05, 1)
    love.graphics.rectangle("fill", W*0.68, H*0.85, 2, 12)
    love.graphics.circle("fill", W*0.68+1, H*0.85-1, 2)
    -- 牵绳
    love.graphics.setColor(0.10, 0.05, 0.02, 0.7)
    love.graphics.line(W*0.68, H*0.86, W*0.66, H*0.86)

    -- 7) 风沙
    for _, S in ipairs(SANDS) do
        local sx = (S.x + t * S.v) % (W + 40) - 20
        local sy = S.y + math.sin(t*0.5 + S.a*10) * 4
        love.graphics.setColor(0.95, 0.75, 0.45, 0.55)
        love.graphics.circle("fill", sx, sy, S.s)
        love.graphics.setColor(0.95, 0.75, 0.45, 0.3)
        love.graphics.circle("fill", sx - 4, sy, S.s*0.7)
    end

    -- 8) 顶部信息条
    love.graphics.setColor(0,0,0,0.50)
    love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.95,0.65,0.35,0.6)
    love.graphics.rectangle("fill", 0, 75, W, 1)

    love.graphics.setColor(1.0,0.85,0.60,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.05  ·  沙漠黄昏  ·  Desert Dusk", 24, 12)
    love.graphics.setColor(0.95,0.75,0.55,0.95); love.graphics.setFont(subFont)
    love.graphics.print("沙丘 · 驼队 · 残阳 · 远石柱 · 风沙", 24, 48)
    love.graphics.setColor(0.85,0.70,0.55,0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 9) 底部
    love.graphics.setColor(0,0,0,0.35); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.95,0.75,0.55,0.85); love.graphics.setFont(subFont)
    love.graphics.print("灵感取自撒哈拉边缘 — 沙与金与最后一个下午", 24, H-23)
end
return M
