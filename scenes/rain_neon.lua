-- 风景集 / No.10  雨夜霓虹  Rain Neon
-- 紫黑 · 雨滴 · 霓虹反射 · 街灯 · 雨伞 · 行人 · 湿街 · 雾
local M = { name = "rain_neon" }
local W, H = 1200, 700
local GROUND_Y = H * 0.86  -- 路面线, 楼底都对齐到这
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop = {0.04, 0.04, 0.09},
    skyMid = {0.10, 0.07, 0.18},
    skyHor = {0.18, 0.10, 0.28},
    bldg1  = {0.07, 0.07, 0.14},  -- 远楼
    bldg2  = {0.04, 0.04, 0.09},  -- 中楼
    bldg3  = {0.02, 0.02, 0.05},  -- 近楼
    neon1  = {1.0, 0.20, 0.55},   -- 粉红
    neon2  = {0.30, 0.95, 1.0},   -- 青
    neon3  = {1.0, 0.80, 0.20},   -- 黄
    neon4  = {0.70, 0.30, 1.0},   -- 紫
    neon5  = {0.20, 1.0, 0.55},   -- 绿
    road   = {0.07, 0.06, 0.11},
    pud    = {0.22, 0.16, 0.26},
}

-- 雨滴 (加密 + 倾斜, 分远近层)
local RAIN_FAR = {}
for i = 1, 220 do
    RAIN_FAR[i] = {
        x  = rnd(i*1.1) * W,
        y  = rnd(i*2.3) * H,
        l  = 4 + rnd(i*3.3) * 4,
        v  = 300 + rnd(i*4.5) * 150,
        ph = rnd(i*5.7) * 6.28,
    }
end
local RAIN_NEAR = {}
for i = 1, 140 do
    RAIN_NEAR[i] = {
        x  = rnd(i*1.7+9) * W,
        y  = rnd(i*2.9+3) * H,
        l  = 14 + rnd(i*3.1) * 12,
        v  = 700 + rnd(i*4.2) * 300,
        ph = rnd(i*5.1) * 6.28,
    }
end

-- 远楼窗户灯 (窗户亮但带不规则性, 一些关灯)
local function drawBldgLights(bx, by, bw, bh, rows, cols, c, sx, sy, seed)
    local cellW = bw / (cols + 1)
    local cellH = bh / (rows + 1)
    for r = 0, rows-1 do
        for c_ = 0, cols-1 do
            -- 用 seed 稳定地决定开/关
            if rnd((r+1)*100 + (c_+1)*7 + bx*0.01 + seed*13) > 0.35 then
                local wx = bx + 3 + c_ * cellW
                local wy = by + 4 + r * cellH
                love.graphics.setColor(c[1], c[2], c[3], 0.92)
                love.graphics.rectangle("fill", wx, wy, cellW*0.55, cellH*0.45)
                -- 灯光晕
                love.graphics.setColor(c[1], c[2], c[3], 0.10)
                love.graphics.rectangle("fill", wx-2, wy-2, cellW*0.55+4, cellH*0.45+4)
            end
        end
    end
end

-- 一块霓虹招牌 (矩形+字+光晕)
local function drawNeonSign(x, y, w, h, s, c, txt, big)
    big = big or false
    -- 外光晕
    love.graphics.setColor(c[1], c[2], c[3], 0.18)
    love.graphics.rectangle("fill", x-6*s, y-4*s, w+12*s, h+8*s)
    love.graphics.setColor(c[1], c[2], c[3], 0.10)
    love.graphics.rectangle("fill", x-12*s, y-8*s, w+24*s, h+16*s)
    -- 框底
    love.graphics.setColor(c[1]*0.25, c[2]*0.25, c[3]*0.25, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    -- 霓虹边
    love.graphics.setColor(c[1], c[2], c[3], 0.95)
    love.graphics.rectangle("fill", x, y, w, 2*s)
    love.graphics.rectangle("fill", x, y + h - 2*s, w, 2*s)
    love.graphics.rectangle("fill", x, y, 2*s, h)
    love.graphics.rectangle("fill", x + w - 2*s, y, 2*s, h)
    -- 内部淡淡光
    love.graphics.setColor(c[1], c[2], c[3], 0.18)
    love.graphics.rectangle("fill", x + 2*s, y + 2*s, w - 4*s, h - 4*s)
    -- 字
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.print(txt, x + 5*s, y + 3*s)
    if big then
        -- 闪烁的额外亮条
        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.rectangle("fill", x + 3*s, y + h*0.4, w-6*s, 1*s)
    end
end

-- 雨伞 + 行人 (带身体+腿, 走路)
--   y 参数 = 脚底 (路面 y), 伞面在 y 之上, 柄穿过身体中部
local function drawPedestrian(x, y, s, c, t, walkSpeed)
    walkSpeed = walkSpeed or 1.0
    local walk = math.sin(t * 3 * walkSpeed) * 2*s
    -- 腿 (从 y 向上 12s)
    love.graphics.setColor(0.05, 0.04, 0.10, 1)
    love.graphics.rectangle("fill", x-4*s, y-12*s+walk, 3*s, 12*s)
    love.graphics.rectangle("fill", x+1*s, y-12*s-walk, 3*s, 12*s)
    -- 鞋
    love.graphics.setColor(0.0, 0.0, 0.0, 1)
    love.graphics.rectangle("fill", x-5*s, y-1*s+walk, 4*s, 2*s)
    love.graphics.rectangle("fill", x+0*s, y-1*s-walk, 4*s, 2*s)
    -- 身体 (大衣) - 肩在 y-12s, 领在 y-30s
    love.graphics.setColor(c[1]*0.45, c[2]*0.45, c[3]*0.45, 1)
    love.graphics.polygon("fill", {
        x-7*s, y-12*s, x+7*s, y-12*s,
        x+6*s, y-30*s, x-6*s, y-30*s
    })
    -- 大衣亮面
    love.graphics.setColor(c[1]*0.65, c[2]*0.65, c[3]*0.65, 1)
    love.graphics.polygon("fill", {
        x-7*s, y-12*s, x-2*s, y-12*s,
        x-1*s, y-30*s, x-6*s, y-30*s
    })
    -- 头 (大衣之上, 圆头)
    love.graphics.setColor(0.85, 0.75, 0.68, 1)
    love.graphics.circle("fill", x, y-34*s, 4*s)
    -- === 伞 ===
    -- 伞面 (上凸半圆): 顶在 y-58s (高), 沿在 y-48s (宽 64s)
    love.graphics.setColor(c[1]*0.55, c[2]*0.55, c[3]*0.55, 1)
    love.graphics.arc("fill", x, y-48*s, 32*s, math.pi, 2*math.pi)
    -- 伞面亮面 (上半)
    love.graphics.setColor(c[1], c[2], c[3], 0.96)
    love.graphics.polygon("fill", {
        x - 32*s, y - 48*s, x + 32*s, y - 48*s,
        x + 24*s, y - 54*s, x + 14*s, y - 58*s,
        x,         y - 60*s,
        x - 14*s, y - 58*s, x - 24*s, y - 54*s
    })
    -- 伞沿深色边
    love.graphics.setColor(c[1]*0.4, c[2]*0.4, c[3]*0.4, 1)
    love.graphics.rectangle("fill", x-32*s, y-48*s-1, 64*s, 1.5*s)
    -- 伞骨 (细线)
    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.line(x, y-60*s, x-30*s, y-48*s)
    love.graphics.line(x, y-60*s, x-15*s, y-48*s)
    love.graphics.line(x, y-60*s, x,      y-48*s)
    love.graphics.line(x, y-60*s, x+15*s, y-48*s)
    love.graphics.line(x, y-60*s, x+30*s, y-48*s)
    -- 伞高光
    love.graphics.setColor(1, 1, 1, 0.35)
    love.graphics.polygon("fill", {
        x - 26*s, y - 56*s, x - 6*s, y - 56*s,
        x, y - 47*s, x - 12*s, y - 50*s
    })
    -- 柄 (从伞中央 y-60s 一直延伸到人手里 y-22s)
    love.graphics.setColor(0.10, 0.06, 0.04, 1)
    love.graphics.line(x+1, y-60*s, x+1, y-22*s)
    -- 柄上端的小弯钩 (伞头)
    love.graphics.circle("line", x+1, y-60*s, 1.5*s)
    -- 倒影 (路面上, 模糊的伞颜色块)
    local rx, ry = x, y + 2
    love.graphics.setColor(c[1], c[2], c[3], 0.22)
    love.graphics.ellipse("fill", rx, ry, 22*s, 4)
    love.graphics.setColor(0,0,0,0.3)
    love.graphics.ellipse("fill", rx, ry+2, 14*s, 2)
end

-- 一个街灯 (杆+灯+光晕+地面光斑)
local function drawStreetlight(x, baseY, h, s, c, t)
    -- 杆
    love.graphics.setColor(0.08, 0.08, 0.12, 1)
    love.graphics.rectangle("fill", x - 1.2*s, baseY, 2.4*s, -h)
    -- 臂
    love.graphics.rectangle("fill", x - 1.2*s, baseY - h, 12*s, 1.8*s)
    -- 灯
    love.graphics.setColor(c[1]*0.3, c[2]*0.3, c[3]*0.3, 1)
    love.graphics.polygon("fill", {
        x + 11*s, baseY - h - 3*s, x + 13*s, baseY - h - 3*s,
        x + 13*s, baseY - h + 6*s, x + 11*s, baseY - h + 6*s
    })
    -- 灯亮
    love.graphics.setColor(1, 1, 0.85, 0.95)
    love.graphics.rectangle("fill", x + 11.5*s, baseY - h - 2*s, 1.2*s, 5*s)
    -- 三层光晕
    love.graphics.setColor(c[1], c[2], c[3], 0.10)
    love.graphics.circle("fill", x + 12*s, baseY - h + 4*s, 50*s)
    love.graphics.setColor(c[1], c[2], c[3], 0.22)
    love.graphics.circle("fill", x + 12*s, baseY - h + 4*s, 28*s)
    love.graphics.setColor(c[1], c[2], c[3], 0.45)
    love.graphics.circle("fill", x + 12*s, baseY - h + 4*s, 12*s)
    -- 地面光斑 (椭圆形)
    love.graphics.setColor(c[1], c[2], c[3], 0.12)
    love.graphics.ellipse("fill", x + 12*s, baseY + 8, 60*s, 14)
    love.graphics.setColor(c[1], c[2], c[3], 0.20)
    love.graphics.ellipse("fill", x + 12*s, baseY + 4, 30*s, 6)
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 夜空 (紫黑)
    for i = 0, 100 do
        local p = i / 100
        local r = lerp(C.skyTop[1], C.skyHor[1], p)
        local g = lerp(C.skyTop[2], C.skyHor[2], p)
        local b = lerp(C.skyTop[3], C.skyHor[3], p)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 1.5) 远处城市光雾 (水平)
    love.graphics.setColor(C.neon1[1], C.neon1[2], C.neon1[3], 0.10)
    love.graphics.rectangle("fill", 0, H*0.50, W, H*0.06)
    love.graphics.setColor(C.neon2[1], C.neon2[2], C.neon2[3], 0.08)
    love.graphics.rectangle("fill", 0, H*0.55, W, H*0.05)

    -- 2) 远楼 (顶到 H*0.55, 底在 H*0.75)
    for i = 1, 10 do
        local x = 20 + i * 120
        local h = 100 + (i%3) * 60
        local w = 60 + (i%2) * 30
        local groundY = H * 0.75
        love.graphics.setColor(C.bldg1[1], C.bldg1[2], C.bldg1[3], 1)
        love.graphics.rectangle("fill", x, groundY - h, w, h)
        if i % 3 == 0 then
            love.graphics.setColor(0.05, 0.05, 0.10, 1)
            love.graphics.rectangle("fill", x + w*0.5 - 1, groundY - h - 15, 2, 15)
            love.graphics.setColor(0.15, 0.05, 0.05, 1)
            love.graphics.circle("fill", x + w*0.5, groundY - h - 16, 3)
        end
        drawBldgLights(x, groundY - h, w, h, 6, 3, C.neon3, 1, 1, i)
    end

    -- 3) 中楼 (顶到 H*0.55, 底在 GROUND_Y=H*0.86)
    for i = 1, 8 do
        local x = 40 + i * 145
        local h = 180 + (i%3) * 80
        local w = 80 + (i%2) * 30
        local groundY = GROUND_Y
        love.graphics.setColor(C.bldg2[1], C.bldg2[2], C.bldg2[3], 1)
        love.graphics.rectangle("fill", x, groundY - h, w, h)
        love.graphics.setColor(0.04, 0.04, 0.08, 1)
        love.graphics.rectangle("fill", x, groundY - h - 4, w, 4)
        drawBldgLights(x, groundY - h, w, h, 8, 4, C.neon2, 1, 1, i+10)
    end

    -- 4) 近楼 (顶高, 底在 GROUND_Y)
    for i = 1, 5 do
        local x = -20 + i * 280
        local h = 320 + (i%3) * 80
        local w = 160 + (i%2) * 40
        local groundY = GROUND_Y
        love.graphics.setColor(C.bldg3[1], C.bldg3[2], C.bldg3[3], 1)
        love.graphics.rectangle("fill", x, groundY - h, w, h)
        -- 楼底加深 (地基)
        love.graphics.setColor(0.01, 0.01, 0.03, 1)
        love.graphics.rectangle("fill", x, groundY - 6, w, 6)
        -- 楼顶天线
        if i % 2 == 0 then
            love.graphics.setColor(0.03, 0.03, 0.06, 1)
            love.graphics.rectangle("fill", x + w*0.3, groundY - h - 25, 2, 25)
            love.graphics.setColor(0.30, 0.05, 0.05, 1)
            love.graphics.circle("fill", x + w*0.3, groundY - h - 26, 3)
        end
        -- 楼顶屋檐 (亮一点的横条)
        love.graphics.setColor(0.06, 0.06, 0.10, 1)
        love.graphics.rectangle("fill", x, groundY - h, w, 3)
        drawBldgLights(x, groundY - h, w, h, 10, 6, {1.0, 0.85, 0.55}, 1, 1, i+20)
        -- 顶霓虹招牌 (贴着楼顶上方)
        if i == 2 then
            drawNeonSign(x + 10, groundY - h - 30, 100, 22, 1.0, C.neon1, "BAR")
        elseif i == 3 then
            drawNeonSign(x + 10, groundY - h - 30, 130, 22, 1.0, C.neon4, "CLUB 88", true)
        elseif i == 4 then
            drawNeonSign(x + 10, groundY - h - 30, 120, 22, 1.0, C.neon2, "OPEN 24H", true)
        end
        -- 侧墙霓虹竖条
        if i == 1 then
            love.graphics.setColor(C.neon3[1], C.neon3[2], C.neon3[3], 0.85)
            love.graphics.rectangle("fill", x + w - 6, groundY - h + 20, 4, h - 60)
        end
        if i == 5 then
            love.graphics.setColor(C.neon5[1], C.neon5[2], C.neon5[3], 0.80)
            love.graphics.rectangle("fill", x + 4, groundY - h + 30, 3, h - 80)
        end
    end

    -- 5) 街灯 (底在 GROUND_Y, 向上 160 像素)
    drawStreetlight(W*0.15, GROUND_Y, 160, 1.0, C.neon3, t)
    drawStreetlight(W*0.50, GROUND_Y, 160, 1.0, C.neon2, t + 1.0)
    drawStreetlight(W*0.85, GROUND_Y, 160, 1.0, C.neon1, t + 2.0)

    -- 6) 街道 (近暗远亮透视, 上沿就是 GROUND_Y)
    love.graphics.setColor(C.road[1], C.road[2], C.road[3], 1)
    love.graphics.polygon("fill", {
        0, GROUND_Y, W, GROUND_Y, W*1.3, H, -W*0.3, H
    })
    -- 路面亮带 (水平湿痕)
    for k = 1, 6 do
        local yk = GROUND_Y + k * (H*0.14/6) - 4
        love.graphics.setColor(0.18, 0.15, 0.22, 0.18)
        love.graphics.rectangle("fill", 0, yk, W, 2)
    end

    -- 7) 远处路沿霓虹亮线
    love.graphics.setColor(C.neon2[1], C.neon2[2], C.neon2[3], 0.55)
    love.graphics.rectangle("fill", 0, GROUND_Y - 2, W, 1)
    love.graphics.setColor(C.neon1[1], C.neon1[2], C.neon1[3], 0.55)
    love.graphics.rectangle("fill", 0, GROUND_Y - 1, W, 1)

    -- 8) 水洼反射 (大块, 多种霓虹色)
    local puddles = {
        {x=120, y=GROUND_Y+30, rx=70, ry=10, c=C.neon1},
        {x=280, y=GROUND_Y+45, rx=55, ry=7,  c=C.neon2},
        {x=430, y=GROUND_Y+38, rx=80, ry=11, c=C.neon3},
        {x=620, y=GROUND_Y+50, rx=60, ry=8,  c=C.neon4},
        {x=780, y=GROUND_Y+40, rx=90, ry=12, c=C.neon5},
        {x=950, y=GROUND_Y+55, rx=70, ry=10, c=C.neon1},
        {x=1080,y=GROUND_Y+45, rx=55, ry=7,  c=C.neon2},
    }
    for _, p in ipairs(puddles) do
        love.graphics.setColor(p.c[1], p.c[2], p.c[3], 0.32)
        love.graphics.ellipse("fill", p.x, p.y, p.rx, p.ry)
        love.graphics.setColor(p.c[1], p.c[2], p.c[3], 0.20)
        love.graphics.ellipse("fill", p.x+10, p.y+2, p.rx*0.5, p.ry*0.5)
    end

    -- 9) 远处行人剪影 (无伞, 走的姿势, 站在路沿上)
    for i = 1, 4 do
        local px = (i * 280 + t * 25) % (W + 200) - 100
        local py = GROUND_Y + 4
        local sc = 0.8
        local walk = math.sin(t*3 + i) * 1.5*sc
        love.graphics.setColor(0.03, 0.03, 0.08, 0.85)
        love.graphics.rectangle("fill", px-3*sc, py-8*sc+walk, 2*sc, 8*sc)
        love.graphics.rectangle("fill", px+1*sc, py-8*sc-walk, 2*sc, 8*sc)
        love.graphics.setColor(0.04, 0.04, 0.10, 0.9)
        love.graphics.polygon("fill", {
            px-4*sc, py-8*sc, px+4*sc, py-8*sc,
            px+3*sc, py-18*sc, px-3*sc, py-18*sc
        })
        love.graphics.circle("fill", px, py-21*sc, 2.5*sc)
    end

    -- 10) 前景行人 (雨伞+身体+腿), 脚踩路面
    drawPedestrian(W*0.30, GROUND_Y+10, 1.6, C.neon1, t, 0.9)
    drawPedestrian(W*0.45, GROUND_Y+8,  1.4, C.neon2, t + 0.7, 1.1)
    drawPedestrian(W*0.65, GROUND_Y+12, 1.7, C.neon3, t + 1.3, 1.0)
    drawPedestrian(W*0.75, GROUND_Y+9,  1.3, C.neon4, t + 1.9, 0.8)
    drawPedestrian(W*0.13, GROUND_Y+8,  1.2, C.neon5, t + 0.4, 1.2)
    drawPedestrian(W*0.88, GROUND_Y+10, 1.5, C.neon1, t + 2.4, 0.95)

    -- 10.5) 远雾 (水平条带, 营造雨雾)
    for k = 1, 4 do
        local yk = H*0.50 + k * 30
        love.graphics.setColor(0.10, 0.08, 0.16, 0.10)
        love.graphics.rectangle("fill", 0, yk, W, 18)
    end

    -- 11) 雨 (远层, 细密)
    for _, R in ipairs(RAIN_FAR) do
        local rx = (R.x + t * R.v * 0.2) % (W + 100)
        local ry = (R.y + t * R.v) % H
        love.graphics.setColor(0.70, 0.80, 0.95, 0.35)
        love.graphics.line(rx, ry, rx - 1, ry + R.l)
    end
    -- 雨 (近层, 粗大倾斜)
    for _, R in ipairs(RAIN_NEAR) do
        local rx = (R.x + t * R.v * 0.25) % (W + 200) - 50
        local ry = (R.y + t * R.v) % H
        love.graphics.setColor(0.85, 0.92, 1.0, 0.65)
        love.graphics.line(rx, ry, rx - 3, ry + R.l)
    end

    -- 11.5) 雨刷光斑 (街灯正下方, 周期闪烁模拟水花)
    for i, sx in ipairs({W*0.15, W*0.50, W*0.85}) do
        local flash = (math.sin(t*4 + i*1.5) + 1) * 0.5
        love.graphics.setColor(1, 0.95, 0.85, 0.10 + flash*0.18)
        love.graphics.ellipse("fill", sx + 12, GROUND_Y + 4, 18, 3)
    end

    -- 12) 顶部信息条
    love.graphics.setColor(0,0,0,0.55)
    love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.90,0.40,0.85,0.6)
    love.graphics.rectangle("fill", 0, 75, W, 1)

    love.graphics.setColor(0.95,0.90,1.0,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.10  ·  雨夜霓虹  ·  Rain Neon", 24, 12)
    love.graphics.setColor(0.85,0.85,0.95,0.95); love.graphics.setFont(subFont)
    love.graphics.print("霓虹 · 雨滴 · 街灯 · 行人 · 雨伞", 24, 48)
    love.graphics.setColor(0.75,0.75,0.85,0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 13) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.85,0.85,0.95,0.85); love.graphics.setFont(subFont)
    love.graphics.print("雨打湿了霓虹 — 雨没打湿的只有路", 24, H-23)
end
return M
