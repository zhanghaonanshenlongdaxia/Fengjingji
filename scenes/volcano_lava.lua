-- 风景集 / No.12  火山熔岩  Volcano Lava
-- 火山 · 熔岩河 · 烟柱 · 火星 · 天空暗红 · 闪电 · 岩石
local M = { name = "volcano_lava" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop   = {0.10, 0.04, 0.06},
    skyMid   = {0.30, 0.10, 0.08},
    skyHor   = {0.65, 0.20, 0.10},
    mtnFar   = {0.20, 0.08, 0.08},
    mtn      = {0.10, 0.04, 0.04},
    rock     = {0.12, 0.06, 0.05},
    rockDk   = {0.06, 0.03, 0.02},
    lavaHot  = {1.00, 0.95, 0.55},
    lavaMid  = {1.00, 0.50, 0.10},
    lavaDk   = {0.70, 0.15, 0.05},
    smoke    = {0.30, 0.18, 0.18},
    smokeLt  = {0.55, 0.30, 0.28},
    ash      = {0.85, 0.55, 0.40},
    spark    = {1.00, 0.85, 0.40},
}

-- 火山锥
local function drawVolcano(cx, baseY, w, h, c)
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.polygon("fill", {
        cx - w*0.5, baseY, cx + w*0.5, baseY,
        cx + w*0.10, baseY - h*0.85,
        cx,           baseY - h,
        cx - w*0.10, baseY - h*0.85,
    })
    -- 暗面 (右)
    love.graphics.setColor(c[1]*0.5, c[2]*0.5, c[3]*0.5, 1)
    love.graphics.polygon("fill", {
        cx, baseY, cx + w*0.5, baseY,
        cx + w*0.10, baseY - h*0.85,
        cx,           baseY - h,
    })
    -- 火山口 (椭圆开口, 暗红)
    love.graphics.setColor(0.02, 0.01, 0.01, 1)
    love.graphics.ellipse("fill", cx, baseY - h, w*0.13, 8)
    -- 熔岩顶
    love.graphics.setColor(C.lavaMid[1], C.lavaMid[2], C.lavaMid[3], 1)
    love.graphics.ellipse("fill", cx, baseY - h, w*0.11, 5)
    love.graphics.setColor(C.lavaHot[1], C.lavaHot[2], C.lavaHot[3], 0.9)
    love.graphics.ellipse("fill", cx, baseY - h - 1, w*0.07, 3)
end

-- 熔岩流 (多边形 + 内部亮带)
local function drawLavaStream(poly, c1, c2, t)
    love.graphics.setColor(c2[1], c2[2], c2[3], 1)
    love.graphics.polygon("fill", poly)
    -- 内部亮带
    local n = #poly / 2
    if n >= 4 then
        for k = 1, 3 do
            local s = 0.55 + 0.15 * math.sin(t*2 + k)
            love.graphics.setColor(c1[1], c1[2], c1[3], 0.55 * s)
            local inner = {}
            for i = 1, #poly, 2 do
                local px = poly[i]
                local py = poly[i+1]
                -- 缩进中心
                if i == 1 or i == 3 then
                    inner[#inner+1] = px
                    inner[#inner+1] = py
                else
                    inner[#inner+1] = lerp(px, (poly[1]+poly[3]+poly[5]+poly[7])/4, 0.45)
                    inner[#inner+1] = lerp(py, (poly[2]+poly[4]+poly[6]+poly[8])/4, 0.45)
                end
            end
            -- 用更简单的亮带 (顶部两层 line)
        end
        -- 顶部亮边
        love.graphics.setColor(c1[1], c1[2], c1[3], 0.85)
        love.graphics.line(poly[1], poly[2], poly[3], poly[4])
        love.graphics.setColor(c1[1], c1[2], c1[3], 0.55)
        love.graphics.line(poly[1]+1, poly[2]-1, poly[3]-1, poly[4]-1)
    end
    -- 火星
    for i = 1, 12 do
        local ph = i * 1.7
        local x = poly[1] + (poly[3]-poly[1]) * (0.2 + 0.6*rnd(i*3+ph))
        x = x + math.sin(t*3 + ph) * 4
        local y = poly[2] + (poly[4]-poly[2]) * (0.2 + 0.6*rnd(i*5+ph))
        y = y - 8 - rnd(i*7+ph)*18
        love.graphics.setColor(C.spark[1], C.spark[2], C.spark[3], 0.9)
        love.graphics.circle("fill", x, y, 1.2 + rnd(i*11+ph)*1.2)
    end
end

-- 烟柱 (多段椭圆, 渐大渐淡)
local function drawSmoke(cx, baseY, h, c1, c2, t)
    for k = 1, 8 do
        local p = k / 8
        local y = baseY - h * p
        local w = 26 + p * 90
        local x = cx + math.sin(t*0.6 + k*0.5) * (k * 3)
        local a = (1 - p) * 0.32
        love.graphics.setColor(c1[1], c1[2], c1[3], a)
        love.graphics.circle("fill", x, y, w)
    end
    -- 火山灰 (颗粒)
    for i = 1, 50 do
        local ph = i * 2.3
        local x = cx + math.sin(t*0.4 + ph) * 80
        local y = baseY - rnd(i*5 + ph) * 300
        love.graphics.setColor(C.ash[1], C.ash[2], C.ash[3], 0.35)
        love.graphics.circle("fill", x, y, 0.8 + rnd(i*7+ph)*1.0)
    end
end

-- 闪电
local function drawLightning(x, t)
    local flash = (math.sin(t*1.7) + math.sin(t*2.3)*0.7)
    if flash > 0.6 then
        love.graphics.setColor(1.0, 0.95, 0.75, 0.5)
        love.graphics.line(x, 0, x + 30, 80)
        love.graphics.line(x + 30, 80, x - 10, 160)
        love.graphics.line(x - 10, 160, x + 25, 230)
    end
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 暗红天空
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.55 then
            r = lerp(C.skyTop[1], C.skyMid[1], p/0.55)
            g = lerp(C.skyTop[2], C.skyMid[2], p/0.55)
            b = lerp(C.skyTop[3], C.skyMid[3], p/0.55)
        else
            local q = (p - 0.55) / 0.45
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 闪电
    drawLightning(W*0.20, t)
    drawLightning(W*0.55, t + 1.7)
    drawLightning(W*0.80, t + 3.1)

    -- 3) 远山剪影
    love.graphics.setColor(C.mtnFar[1], C.mtnFar[2], C.mtnFar[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.85, 100, H*0.65, 220, H*0.78, 340, H*0.62,
        480, H*0.80, 620, H*0.60, 760, H*0.78, 900, H*0.65,
        1040, H*0.80, 1200, H*0.70, 1200, H, 0, H,
    })

    -- 4) 火山 (主 + 副)
    drawVolcano(W*0.30, H*0.82, 380, 280, C.mtn)
    drawVolcano(W*0.72, H*0.85, 260, 180, C.mtn)

    -- 5) 烟柱
    drawSmoke(W*0.30, H*0.82 - 280, 380, C.smoke, C.smokeLt, t)
    drawSmoke(W*0.72, H*0.85 - 180, 240, C.smoke, C.smokeLt, t + 2.0)

    -- 6) 熔岩河 (主)
    drawLavaStream({
        380, H*0.83, 480, H*0.78,
        560, H*0.85, 700, H*0.92,
    }, C.lavaHot, C.lavaDk, t)

    -- 7) 熔岩河 (支)
    drawLavaStream({
        720, H*0.85, 820, H*0.82,
        920, H*0.88, 1080, H*0.95,
    }, C.lavaHot, C.lavaDk, t + 1.0)

    -- 8) 熔岩池 (前景)
    love.graphics.setColor(C.lavaDk[1], C.lavaDk[2], C.lavaDk[3], 1)
    love.graphics.ellipse("fill", W*0.15, H*0.90, 180, 30)
    love.graphics.setColor(C.lavaMid[1], C.lavaMid[2], C.lavaMid[3], 1)
    love.graphics.ellipse("fill", W*0.15, H*0.90, 150, 22)
    love.graphics.setColor(C.lavaHot[1], C.lavaHot[2], C.lavaHot[3], 0.85)
    love.graphics.ellipse("fill", W*0.15, H*0.89, 90, 12)
    -- 池面波纹
    for i = 1, 6 do
        local yo = H*0.90 + math.sin(t*2 + i)*1.5
        love.graphics.setColor(1.0, 0.95, 0.7, 0.35)
        love.graphics.ellipse("fill", W*0.15 + (i-3)*20, yo, 30, 2)
    end
    -- 池面红光晕
    love.graphics.setColor(1.0, 0.40, 0.10, 0.18)
    love.graphics.ellipse("fill", W*0.15, H*0.88, 240, 36)

    -- 9) 飞溅火星 (大颗粒)
    for i = 1, 30 do
        local ph = i * 3.1
        local x = W*0.15 + math.sin(t*1.7 + ph) * 90
        local y = H*0.90 - rnd(i*7 + ph) * 110
        local s = 1.2 + rnd(i*11+ph)*1.6
        love.graphics.setColor(C.spark[1], C.spark[2], C.spark[3], 0.85)
        love.graphics.circle("fill", x, y, s)
    end

    -- 10) 前景岩石
    love.graphics.setColor(C.rockDk[1], C.rockDk[2], C.rockDk[3], 1)
    love.graphics.polygon("fill", {
        0, H, 0, H*0.92, 80, H*0.88, 200, H*0.95, 320, H*0.90, 400, H, 0, H
    })
    love.graphics.setColor(C.rock[1], C.rock[2], C.rock[3], 1)
    love.graphics.polygon("fill", {
        900, H, 850, H*0.92, 980, H*0.90, 1080, H*0.93, 1200, H*0.91, 1200, H
    })

    -- 11) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(1.0,0.45,0.10,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(1, 0.85, 0.5, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.12  ·  火山熔岩  ·  Volcano Lava", 24, 12)
    love.graphics.setColor(1, 0.80, 0.55, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("火山 · 熔岩 · 烟柱 · 火星 · 闪电 · 岩石", 24, 48)
    love.graphics.setColor(0.95, 0.80, 0.70, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 12) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(1, 0.80, 0.55, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("山在烧 — 烧的不是山, 是山的耐心", 24, H-23)
end
return M
