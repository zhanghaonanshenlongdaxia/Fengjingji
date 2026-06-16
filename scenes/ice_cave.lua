-- 风景集 / No.20  极地冰洞  Ice Cave
-- 洞口 · 冰柱 · 倒挂冰锥 · 冰面反光 · 幽蓝光 · 飘雪 · 雪堆 · 脚印
local M = { name = "ice_cave" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop   = {0.20, 0.30, 0.50},
    skyMid   = {0.40, 0.55, 0.75},
    skyHor   = {0.70, 0.82, 0.95},
    iceDark  = {0.15, 0.25, 0.45},
    iceMid   = {0.35, 0.55, 0.85},
    iceLt    = {0.65, 0.85, 1.00},
    iceGlow  = {0.55, 0.85, 1.00},
    iceDk    = {0.10, 0.18, 0.35},
    snowL    = {0.95, 0.98, 1.00},
    snowM    = {0.80, 0.88, 0.95},
    snowD    = {0.60, 0.72, 0.85},
    rockDk   = {0.18, 0.22, 0.30},
    rockMid  = {0.30, 0.35, 0.45},
    rockLt   = {0.50, 0.55, 0.65},
    glow     = {0.65, 0.90, 1.00},
}

-- 远山
local function drawMtn(cx, baseY, w, h, c)
    love.graphics.setColor(c[1], c[2], c[3], 0.85)
    love.graphics.polygon("fill", {
        cx - w*0.5, baseY, cx + w*0.5, baseY,
        cx,           baseY - h,
    })
    -- 雪顶
    love.graphics.setColor(0.95, 0.98, 1.0, 0.95)
    love.graphics.polygon("fill", {
        cx - w*0.10, baseY - h*0.78,
        cx, baseY - h,
        cx + w*0.10, baseY - h*0.78,
    })
end

-- 冰柱
local function drawStalactite(x, top, len, w, t)
    -- 暗面
    love.graphics.setColor(C.iceDk[1], C.iceDk[2], C.iceDk[3], 0.95)
    love.graphics.polygon("fill", {
        x - w, top, x + w, top, x, top + len,
    })
    -- 主面
    love.graphics.setColor(C.iceMid[1], C.iceMid[2], C.iceMid[3], 1)
    love.graphics.polygon("fill", {
        x - w*0.6, top, x, top,
        x, top + len*0.95,
        x - w*0.3, top + len*0.4,
    })
    -- 亮面
    love.graphics.setColor(C.iceLt[1], C.iceLt[2], C.iceLt[3], 0.85)
    love.graphics.polygon("fill", {
        x - w*0.6, top, x - w*0.2, top, x - w*0.1, top + len*0.3,
    })
    -- 顶端高光
    love.graphics.setColor(0.95, 1.0, 1.0, 0.9)
    love.graphics.circle("fill", x, top, 1.2)
end

-- 冰笋 (从下往上)
local function drawStalagmite(x, baseY, h, w, t)
    -- 暗
    love.graphics.setColor(C.iceDk[1], C.iceDk[2], C.iceDk[3], 0.95)
    love.graphics.polygon("fill", {
        x - w, baseY, x + w, baseY, x, baseY - h,
    })
    -- 主
    love.graphics.setColor(C.iceMid[1], C.iceMid[2], C.iceMid[3], 1)
    love.graphics.polygon("fill", {
        x - w*0.4, baseY, x, baseY,
        x, baseY - h*0.95,
        x - w*0.2, baseY - h*0.4,
    })
    -- 亮
    love.graphics.setColor(C.iceLt[1], C.iceLt[2], C.iceLt[3], 0.85)
    love.graphics.polygon("fill", {
        x, baseY - h*0.3, x + w*0.1, baseY - h*0.1, x, baseY,
    })
end

-- 冰洞岩壁
local function drawCaveWall()
    -- 顶部拱形
    love.graphics.setColor(C.rockDk[1], C.rockDk[2], C.rockDk[3], 1)
    love.graphics.polygon("fill", {
        0, 0, W, 0, W, 200, 900, 260, 600, 240, 300, 250, 0, 200,
    })
    -- 浅岩
    love.graphics.setColor(C.rockMid[1], C.rockMid[2], C.rockMid[3], 1)
    love.graphics.polygon("fill", {
        0, 0, W, 0, W, 130, 950, 170, 600, 160, 250, 165, 0, 130,
    })
    -- 高亮
    love.graphics.setColor(C.rockLt[1], C.rockLt[2], C.rockLt[3], 0.7)
    love.graphics.polygon("fill", {
        0, 0, W, 0, W, 60, 850, 90, 600, 80, 300, 85, 0, 60,
    })
    -- 洞口右侧石 (遮挡)
    love.graphics.setColor(C.rockDk[1], C.rockDk[2], C.rockDk[3], 1)
    love.graphics.polygon("fill", {
        1000, 200, 1200, 250, 1200, 400, 950, 380, 980, 280,
    })
    -- 洞口左侧石
    love.graphics.polygon("fill", {
        0, 230, 180, 220, 220, 350, 50, 380, 0, 400,
    })
    -- 洞口弧线 (暗影)
    love.graphics.setColor(0.05, 0.10, 0.20, 0.8)
    love.graphics.ellipse("fill", W*0.50, H*0.35, 600, 110)
end

-- 脚印
local function drawFootprint(x, y, t)
    love.graphics.setColor(C.iceDk[1], C.iceDk[2], C.iceDk[3], 0.7)
    love.graphics.ellipse("fill", x, y, 4, 2)
    love.graphics.ellipse("fill", x - 2, y - 3, 2, 1)
end

-- 飘雪 (洞外)
local SNOWS = {}
for i = 1, 40 do
    SNOWS[i] = {
        x = rnd(i*3) * W,
        y = rnd(i*5) * H*0.5,
        v = 10 + rnd(i*7) * 20,
        ph = rnd(i*11) * 6.28,
    }
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 远天 (洞外)
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
        love.graphics.rectangle("fill", 0, i*(H*0.50/100), W, H*0.50/100+1)
    end

    -- 2) 远山
    drawMtn(W*0.30, H*0.40, 380, 110, {0.55, 0.60, 0.70})
    drawMtn(W*0.65, H*0.40, 420, 130, {0.50, 0.55, 0.65})
    drawMtn(W*0.90, H*0.40, 350, 100, {0.55, 0.60, 0.70})

    -- 3) 冰洞岩壁
    drawCaveWall()

    -- 4) 冰面 (洞内)
    love.graphics.setColor(C.iceMid[1], C.iceMid[2], C.iceMid[3], 0.9)
    love.graphics.polygon("fill", {
        0, 350, 200, 360, 1000, 360, 1200, 350,
        1200, H, 0, H,
    })
    -- 冰面反光
    love.graphics.setColor(C.iceLt[1], C.iceLt[2], C.iceLt[3], 0.45)
    love.graphics.polygon("fill", {
        0, 380, 1200, 380, 1200, 410, 0, 410,
    })
    love.graphics.setColor(0.85, 0.95, 1.0, 0.25)
    love.graphics.polygon("fill", {
        0, 400, 1200, 400, 1200, 415, 0, 415,
    })

    -- 5) 洞内幽蓝光晕 (中央)
    love.graphics.setColor(C.glow[1], C.glow[2], C.glow[3], 0.12)
    love.graphics.circle("fill", W*0.50, H*0.55, 280)
    love.graphics.setColor(C.glow[1], C.glow[2], C.glow[3], 0.18)
    love.graphics.circle("fill", W*0.50, H*0.55, 180)
    love.graphics.setColor(0.85, 0.95, 1.0, 0.25)
    love.graphics.circle("fill", W*0.50, H*0.55, 90)

    -- 6) 倒挂冰锥 (洞顶)
    for k = 0, 16 do
        local x = 30 + k * 75
        local len = 40 + rnd(k*3) * 50
        local w = 4 + rnd(k*5) * 3
        drawStalactite(x, 10, len, w, t)
    end
    -- 远排
    for k = 0, 10 do
        local x = 200 + k * 90
        local len = 25 + rnd(k*7) * 30
        drawStalactite(x, 5, len, 2 + rnd(k*11), t)
    end

    -- 7) 冰笋 (地面)
    for k = 0, 6 do
        local x = 80 + k * 180
        local h = 30 + rnd(k*3) * 30
        drawStalagmite(x, H*0.95, h, 6, t)
    end

    -- 8) 雪堆 (洞外近景)
    love.graphics.setColor(C.snowD[1], C.snowD[2], C.snowD[3], 1)
    love.graphics.ellipse("fill", W*0.10, H*0.55, 80, 18)
    love.graphics.ellipse("fill", W*0.20, H*0.56, 60, 14)
    love.graphics.ellipse("fill", W*0.90, H*0.55, 70, 16)
    love.graphics.ellipse("fill", W*0.80, H*0.56, 50, 12)
    -- 雪堆亮面
    love.graphics.setColor(C.snowL[1], C.snowL[2], C.snowL[3], 0.8)
    love.graphics.ellipse("fill", W*0.10, H*0.54, 60, 8)
    love.graphics.ellipse("fill", W*0.90, H*0.54, 50, 6)

    -- 9) 冰裂纹 (冰面)
    for k = 0, 7 do
        local x = 100 + k * 150
        local y = H*0.65 + (k*37) % 60
        love.graphics.setColor(C.iceLt[1], C.iceLt[2], C.iceLt[3], 0.6)
        love.graphics.line(x, y, x + 30, y - 8)
        love.graphics.line(x + 30, y - 8, x + 50, y + 5)
        love.graphics.line(x + 30, y - 8, x + 25, y + 12)
    end

    -- 10) 脚印
    for i = 0, 5 do
        local px = W*0.30 + i * 35
        local py = H*0.75 + math.sin(i) * 3
        drawFootprint(px, py, t)
    end
    for i = 0, 5 do
        local px = W*0.65 - i * 35
        local py = H*0.78 + math.sin(i+1) * 3
        drawFootprint(px, py, t)
    end

    -- 11) 冰面反光 (光斑)
    for k = 0, 12 do
        local x = (k * 97 + 20) % W
        local y = H*0.85 + (k*23) % 40
        love.graphics.setColor(C.iceLt[1], C.iceLt[2], C.iceLt[3], 0.35)
        love.graphics.ellipse("fill", x, y, 12, 3)
    end

    -- 12) 飘雪 (洞口)
    for _, S in ipairs(SNOWS) do
        local sx = S.x + math.sin(t*0.3 + S.ph) * 8
        local sy = (S.y + t * S.v) % H
        if sy < 0 then sy = sy + H end
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.circle("fill", sx, sy, 1.2 + rnd(S.ph*10)*0.8)
    end

    -- 13) 冰晶 (空气, 闪烁)
    for i = 1, 25 do
        local x = (i*53) % W
        local y = (i*37) % (H*0.6) + H*0.2
        local flick = 0.5 + 0.5 * math.sin(t*2 + i)
        love.graphics.setColor(C.iceLt[1], C.iceLt[2], C.iceLt[3], flick * 0.8)
        love.graphics.circle("fill", x, y, 0.8)
    end

    -- 14) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.55,0.85,1.00,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(0.85, 0.95, 1.0, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.20  ·  极地冰洞  ·  Ice Cave", 24, 12)
    love.graphics.setColor(0.80, 0.90, 1.0, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("洞口 · 冰柱 · 倒挂冰锥 · 冰面反光 · 幽蓝光 · 飘雪 · 雪堆 · 脚印", 24, 48)
    love.graphics.setColor(0.70, 0.85, 0.95, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 15) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.80, 0.90, 1.0, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("往洞里看 — 蓝得像把冬天咽了下去", 24, H-23)
end
return M
