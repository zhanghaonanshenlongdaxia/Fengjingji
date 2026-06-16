-- 风景集 / No.06  海底珊瑚礁  Coral Reef
-- 深青蓝 · 鱼群 · 气泡 · 阳光光柱 · 珊瑚
local M = { name = "coral_reef" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

-- 鱼群 (24条, 不同色)
local FISH = {}
local FISH_COLORS = {
    {1.0, 0.85, 0.30}, {1.0, 0.50, 0.40}, {0.40, 0.85, 1.0},
    {1.0, 0.70, 0.85}, {0.70, 1.0, 0.55}, {0.95, 0.95, 1.0},
}
for i = 1, 24 do
    FISH[i] = {
        x  = rnd(i*1.1) * W,
        y  = H*0.30 + rnd(i*2.3) * H*0.45,
        v  = 30 + rnd(i*3.7) * 60,
        s  = 0.6 + rnd(i*4.1) * 0.9,
        dir= rnd(i*5.3) < 0.5 and -1 or 1,
        phase = rnd(i*6.7) * 6.28,
        c  = FISH_COLORS[math.floor(rnd(i*7.9)*#FISH_COLORS)+1],
    }
end

-- 气泡
local BUB = {}
for i = 1, 60 do
    BUB[i] = {
        x  = rnd(i*1.3) * W,
        y  = H*0.20 + rnd(i*2.1) * H*0.80,
        r  = 1.5 + rnd(i*3.3) * 4,
        v  = 25 + rnd(i*4.5) * 45,
        ph = rnd(i*5.7) * 6.28,
        a  = 0.3 + rnd(i*6.9) * 0.4,
    }
end

-- 阳光光柱 (5道, 缓慢摆动)
local RAYS = {}
for i = 1, 5 do
    RAYS[i] = {
        x  = W*0.1 + i * (W*0.18),
        w  = 60 + rnd(i*2.1) * 50,
        a  = 0.10 + rnd(i*3.1) * 0.08,
        ph = rnd(i*4.3) * 6.28,
    }
end

-- 一条鱼
local function drawFish(x, y, s, dir, c, phase)
    local fl = math.sin(phase*8) * 2*s
    -- 身体
    love.graphics.setColor(c[1], c[2], c[3], 0.95)
    love.graphics.ellipse("fill", x, y, 8*s, 3.5*s)
    -- 尾
    love.graphics.polygon("fill", {
        x - 8*s*dir, y, x - 14*s*dir, y - 4*s - fl,
        x - 14*s*dir, y + 4*s - fl,
    })
    -- 背鳍
    love.graphics.polygon("fill", {
        x - 2*s*dir, y - 3*s, x + 0, y - 6*s, x + 2*s*dir, y - 3*s
    })
    -- 眼
    love.graphics.setColor(1,1,1,1)
    love.graphics.circle("fill", x + 5*s*dir, y, 0.9*s)
    love.graphics.setColor(0,0,0,1)
    love.graphics.circle("fill", x + 5.4*s*dir, y, 0.4*s)
    -- 纹
    love.graphics.setColor(c[1]*0.7, c[2]*0.7, c[3]*0.7, 0.5)
    love.graphics.arc("fill", x, y, 3.5*s, 0, math.pi)
end

-- 一枝珊瑚 (扇状)
local function drawCoral(x, baseY, h, s, col)
    love.graphics.setColor(col[1]*0.6, col[2]*0.6, col[3]*0.6, 1)
    -- 干
    love.graphics.polygon("fill", {
        x - 3*s, baseY, x + 3*s, baseY,
        x + 2*s, baseY - h*0.4, x - 2*s, baseY - h*0.4
    })
    -- 枝 (5根向上)
    for k = 0, 4 do
        local px = x - 8*s + k*4*s
        local py = baseY - h*0.4 - k*2*s
        love.graphics.setColor(col[1], col[2], col[3], 1)
        love.graphics.polygon("fill", {
            px - 2*s, py, px + 2*s, py,
            px + 1*s, py - (h*0.6 + k), px - 1*s, py - (h*0.6 + k)
        })
        -- 顶端球
        love.graphics.circle("fill", px, py - (h*0.6 + k), 1.5*s)
    end
end

-- 海草
local function drawSeaweed(x, baseY, h, s, t)
    local pts = {}
    for i = 0, 10 do
        local p = i / 10
        local y = baseY - p * h
        local sway = math.sin(t + p*3) * 4*s * p
        pts[#pts+1] = x + sway
        pts[#pts+1] = y
    end
    love.graphics.setColor(0.20, 0.60, 0.40, 0.85)
    love.graphics.line(pts)
    -- 影
    love.graphics.setColor(0.10, 0.30, 0.20, 0.4)
    for i = 1, 10 do
        love.graphics.line(pts[2*i-1], pts[2*i], pts[2*i-1]+1, pts[2*i])
    end
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 水 (深青→浅青)
    for i = 0, 100 do
        local p = i / 100
        local r = lerp(0.02, 0.10, p)
        local g = lerp(0.25, 0.50, p)
        local b = lerp(0.45, 0.65, p)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 水面亮带 (顶)
    love.graphics.setColor(0.65, 0.95, 1.0, 0.30)
    love.graphics.rectangle("fill", 0, 0, W, 4)
    love.graphics.setColor(0.80, 1.0, 1.0, 0.20)
    love.graphics.rectangle("fill", 0, 4, W, 1)

    -- 3) 阳光光柱
    for _, R in ipairs(RAYS) do
        local drift = math.sin(t*0.3 + R.ph) * 30
        love.graphics.setColor(0.95, 0.95, 0.70, R.a)
        love.graphics.polygon("fill", {
            R.x - R.w*0.4 + drift, 0, R.x + R.w*0.4 + drift, 0,
            R.x + R.w*2 + drift, H, R.x - R.w*2 + drift, H
        })
    end

    -- 4) 远景暗礁
    love.graphics.setColor(0.05, 0.15, 0.20, 0.6)
    love.graphics.polygon("fill", {
        0, H*0.65, W*0.15, H*0.62, W*0.30, H*0.68, W*0.45, H*0.63,
        W*0.60, H*0.67, W*0.80, H*0.64, W, H*0.66, W, H, 0, H
    })

    -- 5) 海草 (中景)
    for i = 1, 8 do
        drawSeaweed(60 + i*135, H*0.78, 60 + (i%3)*10, 1.0 + (i%2)*0.3, t + i*0.5)
    end

    -- 6) 珊瑚丛 (前)
    drawCoral(W*0.10, H*0.92, 80, 1.4, {1.0, 0.40, 0.55})  -- 红
    drawCoral(W*0.25, H*0.93, 100, 1.6, {1.0, 0.75, 0.30}) -- 橙
    drawCoral(W*0.45, H*0.91, 70, 1.3, {0.85, 0.40, 0.95}) -- 紫
    drawCoral(W*0.62, H*0.93, 90, 1.5, {1.0, 0.85, 0.40})  -- 金
    drawCoral(W*0.82, H*0.92, 80, 1.4, {0.40, 0.95, 0.85}) -- 青
    drawCoral(W*0.95, H*0.93, 60, 1.2, {1.0, 0.45, 0.65})  -- 粉

    -- 7) 沙底
    for i = 0, 40 do
        local p = i / 40
        local y = H*0.93 + p * H*0.07
        love.graphics.setColor(0.85, 0.75, 0.55, lerp(0.7, 0.4, p))
        love.graphics.rectangle("fill", 0, y, W, H*0.0025 + 2)
    end

    -- 8) 鱼群
    for _, F in ipairs(FISH) do
        local fx = (F.x + t * F.v * F.dir) % (W + 60)
        if fx < -30 then fx = fx + (W + 60) end
        local fy = F.y + math.sin(t + F.phase) * 6
        drawFish(fx, fy, F.s, F.dir, F.c, t + F.phase)
    end

    -- 9) 气泡
    for _, B in ipairs(BUB) do
        local by = (H - (B.y - t*B.v) % H)
        local bx = B.x + math.sin(t*0.8 + B.ph) * 3
        love.graphics.setColor(0.85, 0.95, 1.0, B.a)
        love.graphics.circle("fill", bx, by, B.r)
        love.graphics.setColor(1,1,1, B.a*0.8)
        love.graphics.circle("fill", bx - B.r*0.35, by - B.r*0.35, B.r*0.3)
    end

    -- 10) 顶部信息条
    love.graphics.setColor(0,0,0,0.50)
    love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.40,0.85,1.0,0.6)
    love.graphics.rectangle("fill", 0, 75, W, 1)

    love.graphics.setColor(0.85,0.95,1.0,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.06  ·  海底珊瑚礁  ·  Coral Reef", 24, 12)
    love.graphics.setColor(0.75,0.95,1.0,0.95); love.graphics.setFont(subFont)
    love.graphics.print("阳光光柱 · 鱼群 · 珊瑚 · 气泡 · 海草", 24, 48)
    love.graphics.setColor(0.65,0.85,0.95,0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 11) 底部
    love.graphics.setColor(0,0,0,0.35); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.75,0.95,1.0,0.85); love.graphics.setFont(subFont)
    love.graphics.print("海面以上是风浪，海面以下是世界 — 一杯蓝色", 24, H-23)
end
return M
