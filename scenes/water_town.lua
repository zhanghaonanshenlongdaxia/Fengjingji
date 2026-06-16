-- 风景集 / No.02  水乡古镇  Twilight in a Canal Town
-- 黄昏雨后 · 乌篷船 · 石桥 · 红灯笼 · 水面 + 倒影
local M = { name = "water_town" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

-- 调色板
local C = {
    skyTop   = {0.16, 0.10, 0.20},   -- 黄昏紫
    skyMid   = {0.55, 0.30, 0.32},   -- 暗橙
    skyHor   = {0.85, 0.55, 0.32},   -- 落日
    waterTop = {0.18, 0.10, 0.18},   -- 远处水面
    waterMid = {0.32, 0.18, 0.22},
    waterBot = {0.05, 0.04, 0.10},   -- 近处暗
    house1   = {0.10, 0.07, 0.10},   -- 远景白墙
    house2   = {0.06, 0.04, 0.08},   -- 近景深色
    roof1    = {0.18, 0.12, 0.13},   -- 远景屋顶
    roof2    = {0.10, 0.06, 0.08},   -- 近景屋顶
    rock     = {0.40, 0.38, 0.42},   -- 石桥
    rockDk   = {0.20, 0.18, 0.22},
    wood     = {0.18, 0.10, 0.06},   -- 乌篷
    paper    = {0.85, 0.65, 0.30},   -- 灯笼
    ember    = {1.00, 0.55, 0.20},
    leaf     = {0.12, 0.18, 0.10},
    willow   = {0.22, 0.28, 0.18},
}

-- 雨丝
local RAIN = {}
for i = 1, 220 do
    RAIN[i] = { x = rnd(i), y = rnd(i*5.7), s = 6 + (i%4)*2, o = 0.35 + (i%3)*0.15 }
end

-- 灯笼（挂在画面各处的椭圆灯笼，每个独立摆动）
local LANTERNS = {
    { x=W*0.12, y=H*0.46, r=10, hue=1.0,  ph=0.0,  dist=1.0 },
    { x=W*0.30, y=H*0.50, r=8,  hue=0.95, ph=1.2,  dist=1.0 },
    { x=W*0.50, y=H*0.44, r=12, hue=1.05, ph=2.1,  dist=1.0 },
    { x=W*0.72, y=H*0.49, r=9,  hue=0.9,  ph=3.3,  dist=1.0 },
    { x=W*0.90, y=H*0.45, r=10, hue=1.0,  ph=4.5,  dist=1.0 },
    { x=W*0.20, y=H*0.62, r=6,  hue=0.9,  ph=2.7,  dist=2.0 },  -- 倒影
    { x=W*0.55, y=H*0.66, r=7,  hue=1.0,  ph=1.5,  dist=2.0 },
    { x=W*0.80, y=H*0.63, r=6,  hue=0.95, ph=4.1,  dist=2.0 },
}

-- ============= 画一座屋顶 =============
local function drawRoof(cx, baseY, w, h, col, side)
    -- 屋顶：左半亮 / 右半暗，做出方向感
    -- side: "near" 用 roof2
    if side == "near" then
        love.graphics.setColor(col[1]*0.9, col[2]*0.9, col[3]*0.9, 1)
    else
        love.graphics.setColor(col[1], col[2], col[3], 1)
    end
    love.graphics.polygon("fill", {
        cx - w*0.55, baseY,
        cx - w*0.45, baseY - h,
        cx,            baseY - h*1.10,
        cx + w*0.45,   baseY - h,
        cx + w*0.55,   baseY,
    })
    -- 屋脊
    love.graphics.setColor(0.02, 0.02, 0.04, 0.9)
    love.graphics.line(cx - w*0.45, baseY - h, cx, baseY - h*1.10)
    love.graphics.line(cx, baseY - h*1.10, cx + w*0.45, baseY - h)
    -- 屋脊小翘角
    love.graphics.polygon("fill", {
        cx - w*0.45 - 4, baseY - h, cx - w*0.45, baseY - h - 5, cx - w*0.45 + 2, baseY - h + 1
    })
    love.graphics.polygon("fill", {
        cx + w*0.45 - 2, baseY - h + 1, cx + w*0.45, baseY - h - 5, cx + w*0.45 + 4, baseY - h
    })
end

-- ============= 画一栋白墙黛瓦的房子 =============
local function drawHouse(x, baseY, w, h, side)
    local wall = (side == "near") and C.house2 or C.house1
    local roof = (side == "near") and C.roof2  or C.roof1
    -- 墙
    love.graphics.setColor(wall[1], wall[2], wall[3], 1)
    love.graphics.rectangle("fill", x - w/2, baseY - h, w, h)
    -- 墙面高光（侧面窗）
    love.graphics.setColor(0.85, 0.65, 0.30, 0.9)  -- 暖窗光
    for i = 0, 2 do
        love.graphics.rectangle("fill", x - w*0.35 + i*8, baseY - h + 6, 4, 6)
    end
    -- 屋檐
    love.graphics.setColor(0.04, 0.03, 0.05, 1)
    love.graphics.rectangle("fill", x - w/2 - 3, baseY - h - 2, w + 6, 3)
    -- 屋顶
    drawRoof(x, baseY - h, w + 6, 14, roof, side)
    -- 屋檐小灯笼
    love.graphics.setColor(0.10, 0.06, 0.04, 1)
    love.graphics.line(x, baseY - h, x, baseY - h + 8)
    love.graphics.setColor(1.0, 0.55, 0.20, 0.95)
    love.graphics.circle("fill", x, baseY - h + 12, 3)
    love.graphics.setColor(1.0, 0.95, 0.6, 0.4)
    love.graphics.circle("fill", x, baseY - h + 12, 6)
end

-- ============= 画一座拱桥 =============
local function drawBridge(cx, baseY, w, h)
    -- 桥体
    love.graphics.setColor(C.rock[1], C.rock[2], C.rock[3], 1)
    love.graphics.polygon("fill", {
        cx - w/2, baseY,
        cx - w/2 + 6, baseY - h,
        cx + w/2 - 6, baseY - h,
        cx + w/2, baseY,
    })
    -- 桥拱（半圆）
    love.graphics.setColor(C.waterMid[1], C.waterMid[2], C.waterMid[3], 1)
    love.graphics.arc("fill", cx, baseY, w/2 - 6, math.pi, math.pi*2, 32)
    -- 桥面
    love.graphics.setColor(C.rock[1]*1.1, C.rock[2]*1.1, C.rock[3]*1.1, 1)
    love.graphics.polygon("fill", {
        cx - w/2 + 6, baseY - h,
        cx + w/2 - 6, baseY - h,
        cx + w/2 - 10, baseY - h - 4,
        cx - w/2 + 10, baseY - h - 4,
    })
    -- 桥栏杆
    love.graphics.setColor(0.10, 0.07, 0.08, 1)
    love.graphics.rectangle("fill", cx - w/2 + 6, baseY - h - 4, w - 12, 2)
    -- 栏杆柱
    for i = 0, 5 do
        local rx = cx - w/2 + 12 + i * ((w - 24) / 5)
        love.graphics.rectangle("fill", rx, baseY - h - 8, 2, 6)
    end
    -- 桥洞倒影（深一点的水）
    love.graphics.setColor(0.05, 0.04, 0.08, 0.55)
    love.graphics.arc("fill", cx, baseY, w/2 - 8, 0, math.pi, 32)
    -- 桥身阴影
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.polygon("fill", {
        cx + w/2 - 8, baseY,
        cx + w/2, baseY,
        cx + w/2, baseY + 8,
    })
end

-- ============= 画一艘乌篷船 =============
local function drawBoat(cx, cy, w, side)
    -- side=1 正向（向右），side=-1 反向
    local dir = side
    -- 船身（半浸在水里）
    love.graphics.setColor(C.wood[1], C.wood[2], C.wood[3], 1)
    love.graphics.polygon("fill", {
        cx - w/2 * dir, cy,
        cx + w/2 * dir, cy,
        cx + (w/2 - 6) * dir, cy + 10,
        cx - (w/2 - 6) * dir, cy + 10,
    })
    -- 船舷阴影
    love.graphics.setColor(0.04, 0.02, 0.02, 1)
    love.graphics.line(cx - w/2 * dir, cy, cx + w/2 * dir, cy)
    -- 乌篷（半圆顶）
    local px = cx - 4*dir
    love.graphics.setColor(0.05, 0.04, 0.06, 1)
    love.graphics.arc("fill", px, cy, w*0.32, math.pi, math.pi*2, 24)
    -- 乌篷的竹骨
    for i = -3, 3 do
        love.graphics.setColor(0.25, 0.18, 0.10, 0.7)
        love.graphics.line(px, cy, px + i*4*dir, cy - math.abs(i)*1.5 - 2)
    end
    -- 乌篷上的小红绳/灯
    love.graphics.setColor(1.0, 0.55, 0.20, 1)
    love.graphics.circle("fill", px, cy - 2, 2)
    -- 桨
    love.graphics.setColor(0.15, 0.10, 0.05, 1)
    love.graphics.rectangle("fill", cx + (w/2 - 4) * dir, cy + 2, 18 * dir, 2)
    love.graphics.setColor(0.10, 0.06, 0.03, 1)
    love.graphics.polygon("fill", {
        cx + (w/2 + 12) * dir, cy + 1,
        cx + (w/2 + 20) * dir, cy + 3,
        cx + (w/2 + 20) * dir, cy + 5,
        cx + (w/2 + 12) * dir, cy + 5,
    })
    -- 船底倒影（深）
    love.graphics.setColor(0.02, 0.01, 0.04, 0.7)
    love.graphics.polygon("fill", {
        cx - w/2 * dir, cy + 10,
        cx + w/2 * dir, cy + 10,
        cx + (w/2 - 4) * dir, cy + 16,
        cx - (w/2 - 4) * dir, cy + 16,
    })
end

-- ============= 画一盏灯笼 =============
local function drawLantern(L, t)
    local sway = math.sin(t * 1.1 + L.ph) * 1.5
    local x = L.x + sway
    local y = L.y
    -- 远近感
    local a = (L.dist == 2.0) and 0.35 or 0.95
    -- 绳子
    love.graphics.setColor(0.05, 0.04, 0.05, a)
    love.graphics.line(x, y - 18, x, y - 6)
    -- 灯体（暖红椭圆）
    love.graphics.setColor(1.0, 0.55, 0.20, a)
    love.graphics.ellipse("fill", x, y, L.r, L.r*1.15)
    -- 灯体亮面
    love.graphics.setColor(1.0, 0.78, 0.30, a*0.7)
    love.graphics.ellipse("fill", x - L.r*0.25, y - L.r*0.3, L.r*0.55, L.r*0.55)
    -- 上下帽
    love.graphics.setColor(0.10, 0.05, 0.04, a)
    love.graphics.rectangle("fill", x - L.r*0.9, y - L.r*1.15, L.r*1.8, 1.5)
    love.graphics.rectangle("fill", x - L.r*0.9, y + L.r*1.15, L.r*1.8, 1.5)
    -- 暖光晕
    love.graphics.setColor(1.0, 0.65, 0.30, 0.10 * a)
    love.graphics.circle("fill", x, y, L.r*3)
    love.graphics.setColor(1.0, 0.65, 0.30, 0.05 * a)
    love.graphics.circle("fill", x, y, L.r*5)
    -- 字（"福"）
    if L.r >= 9 then
        love.graphics.setColor(1.0, 0.92, 0.65, a*0.95)
        love.graphics.print("福", x - L.r*0.3, y - L.r*0.55)
    end
end

-- ============= 柳枝 =============
local function drawWillow(x, baseY, len, t)
    love.graphics.setColor(C.willow[1], C.willow[2], C.willow[3], 0.9)
    for i = 0, 9 do
        local p = i / 9
        local x0 = x + math.sin(t*0.3 + i*0.4) * 4
        local y0 = baseY - p * len
        local x1 = x0 + 18 - i*1.2
        local y1 = y0 + 4
        love.graphics.line(x0, y0, x1, y1)
        -- 叶
        love.graphics.setColor(C.leaf[1]+0.05*p, C.leaf[2]+0.05*p, C.leaf[3], 0.85)
        love.graphics.ellipse("fill", x1, y1, 1.6, 0.8)
    end
end

-- ============= 主体绘制 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 天空渐变（顶紫 / 中橙 / 地平线落日）
    for i = 0, 80 do
        local p = i / 80
        local r, g, b
        if p < 0.55 then
            local q = p / 0.55
            r = lerp(C.skyTop[1], C.skyMid[1], q)
            g = lerp(C.skyTop[2], C.skyMid[2], q)
            b = lerp(C.skyTop[3], C.skyMid[3], q)
        else
            local q = (p - 0.55) / 0.45
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/80), W, H/80+1)
    end

    -- 落日（地平线上的小盘）
    local sunY = H * 0.50
    local sunX = W * 0.74
    for k = 4, 1, -1 do
        love.graphics.setColor(1.0, 0.78, 0.35, 0.07*k)
        love.graphics.circle("fill", sunX, sunY, 30 + k*14)
    end
    love.graphics.setColor(1.0, 0.78, 0.35, 0.9)
    love.graphics.circle("fill", sunX, sunY, 32)

    -- 2) 远景山影（地平线后）
    for i = 0, 12 do
        local p = i / 12
        local x = (W*-0.05) + p * (W*1.10) + (i%3 - 1) * 40
        local top = H*0.40 + (i%4 - 2) * 10
        love.graphics.setColor(0.10, 0.07, 0.18, 0.45)
        love.graphics.polygon("fill", { x-50, H*0.50, x, top, x+50, H*0.50 })
    end

    -- 3) 远景房子（横排）
    local farY = H * 0.50
    for i = 0, 11 do
        local x = i * (W/11) + (i%2)*8
        local w = 60 + (i%3)*10
        local h = 30 + (i%4)*5
        drawHouse(x, farY, w, h, "far")
    end

    -- 4) 中景房子
    local midY = H * 0.58
    for i = 0, 8 do
        local x = i * (W/8) + (i%2)*20
        local w = 90 + (i%3)*14
        local h = 50 + (i%3)*6
        drawHouse(x, midY, w, h, "mid")
    end

    -- 5) 水面（地平线到画面底）
    local waterTop = H * 0.50
    -- 渐变：远处偏紫 / 近处偏暗
    for i = 0, 40 do
        local p = i / 40
        local r = lerp(C.waterTop[1], C.waterBot[1], p)
        local g = lerp(C.waterTop[2], C.waterBot[2], p)
        local b = lerp(C.waterTop[3], C.waterBot[3], p)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, waterTop + i*((H - waterTop)/40), W, (H - waterTop)/40 + 1)
    end

    -- 6) 落日倒影
    for k = 0, 6 do
        local a = 0.45 - k*0.06
        if a > 0 then
            love.graphics.setColor(1.0, 0.70, 0.30, a)
            love.graphics.rectangle("fill", sunX - 18 + math.sin(t*1.2 + k)*2, waterTop + k*8, 36 - k*3, 4)
        end
    end

    -- 7) 远景房子倒影（倒置，半透明，模糊）
    love.graphics.setColor(1, 1, 1, 1)
    for i = 0, 11 do
        local x = i * (W/11) + (i%2)*8
        local w = 60 + (i%3)*10
        local h = 30 + (i%4)*5
        -- 倒置的墙
        love.graphics.setColor(0.08, 0.05, 0.08, 0.45)
        love.graphics.polygon("fill", {
            x - w/2, waterTop,
            x + w/2, waterTop,
            x + w/2, waterTop + h*0.5,
            x - w/2, waterTop + h*0.5,
        })
        -- 倒置的屋顶
        love.graphics.setColor(0.06, 0.04, 0.06, 0.40)
        love.graphics.polygon("fill", {
            x - w/2 - 3, waterTop + h*0.5,
            x + w/2 + 3, waterTop + h*0.5,
            x + w/2 + 8, waterTop + h*0.5 + 5,
            x,            waterTop + h*0.5 + 12,
            x - w/2 - 8,  waterTop + h*0.5 + 5,
        })
    end

    -- 8) 中景房子倒影
    for i = 0, 8 do
        local x = i * (W/8) + (i%2)*20
        local w = 90 + (i%3)*14
        local h = 50 + (i%3)*6
        love.graphics.setColor(0.05, 0.03, 0.06, 0.55)
        love.graphics.polygon("fill", {
            x - w/2, waterTop,
            x + w/2, waterTop,
            x + w/2, waterTop + h*0.7,
            x - w/2, waterTop + h*0.7,
        })
        love.graphics.setColor(0.04, 0.02, 0.05, 0.50)
        love.graphics.polygon("fill", {
            x - w/2 - 4, waterTop + h*0.7,
            x + w/2 + 4, waterTop + h*0.7,
            x + w/2 + 10, waterTop + h*0.7 + 7,
            x,             waterTop + h*0.7 + 16,
            x - w/2 - 10,  waterTop + h*0.7 + 7,
        })
    end

    -- 9) 拱桥（中景，跨在河上）
    drawBridge(W*0.50, waterTop + 30, 230, 70)
    -- 桥上一盏灯 + 一个人
    love.graphics.setColor(0.10, 0.06, 0.04, 1)
    love.graphics.line(W*0.50, waterTop + 30 - 70, W*0.50, waterTop + 30 - 60)
    love.graphics.setColor(1.0, 0.55, 0.20, 1); love.graphics.circle("fill", W*0.50, waterTop + 30 - 56, 4)
    love.graphics.setColor(1.0, 0.85, 0.50, 0.4); love.graphics.circle("fill", W*0.50, waterTop + 30 - 56, 10)
    -- 桥上小人（撑伞）
    love.graphics.setColor(0.05, 0.04, 0.06, 1)
    love.graphics.rectangle("fill", W*0.50 + 18, waterTop + 30 - 64, 3, 14)  -- 身
    love.graphics.circle("fill", W*0.50 + 19.5, waterTop + 30 - 67, 2.5)    -- 头
    love.graphics.setColor(0.55, 0.20, 0.18, 1)
    love.graphics.arc("fill", W*0.50 + 19.5, waterTop + 30 - 68, 7, math.pi, math.pi*2, 16)  -- 伞

    -- 10) 中景乌篷船
    drawBoat(W*0.22, waterTop + 95, 90, 1)
    drawBoat(W*0.78, waterTop + 80, 75, -1)

    -- 11) 水波纹（近处）
    for i = 0, 16 do
        local y = waterTop + 90 + i*4
        for j = 0, 14 do
            local x = j*90 + (i%2)*45 + math.sin(t*0.6 + i*0.5 + j*0.7) * 3
            love.graphics.setColor(0.78, 0.55, 0.40, 0.18 - i*0.008)
            if 0.18 - i*0.008 > 0 then
                love.graphics.line(x, y, x + 12 - i*0.3, y)
            end
        end
    end

    -- 12) 灯笼（横排挂在上方）
    for _, L in ipairs(LANTERNS) do
        if L.dist == 1.0 then
            drawLantern(L, t)
        end
    end

    -- 13) 柳枝（前景两侧）
    drawWillow(W*0.05, waterTop + 30, 60, t)
    drawWillow(W*0.95, waterTop + 40, 70, t + 1.5)

    -- 14) 雨丝
    for _, r_ in ipairs(RAIN) do
        local x = r_.x * W
        local y = ((r_.y + t * r_.s * 0.04) % 1.0) * H
        love.graphics.setColor(0.85, 0.90, 1.0, r_.o)
        love.graphics.line(x, y, x - 1.2, y + 6)
    end

    -- 15) 灯笼倒影
    for _, L in ipairs(LANTERNS) do
        if L.dist == 2.0 then
            local sway = math.sin(t * 1.1 + L.ph) * 1.5
            local x = L.x + sway
            local y = L.y
            -- 上下颠倒的灯笼，飘在水面下
            love.graphics.setColor(1.0, 0.55, 0.20, 0.32)
            love.graphics.ellipse("fill", x, y, L.r*0.9, L.r*1.0)
            love.graphics.setColor(1.0, 0.78, 0.30, 0.18)
            love.graphics.ellipse("fill", x, y, L.r*1.4, L.r*1.6)
        end
    end

    -- 16) 雨打在水面的小涟漪
    for i = 1, 25 do
        local x = rnd(i*3.7) * W
        local y = waterTop + 30 + rnd(i*5.1) * (H - waterTop - 40)
        local ph = (t * 1.4 + i) % 1.5
        local r = ph * 4
        love.graphics.setColor(0.95, 0.85, 0.70, 0.45 * (1 - ph/1.5))
        love.graphics.circle("line", x, y, r)
    end

    -- 17) 顶部信息条（高 76: 标题 30px + 副标题 20px + 留白 26px）
    love.graphics.setColor(0,0,0,0.45)
    love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.95,0.65,0.40,0.6)
    love.graphics.rectangle("fill", 0, 75, W, 1)

    love.graphics.setColor(0.98,0.85,0.65,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.02  ·  水乡古镇  ·  Twilight in a Canal Town", 24, 12)
    love.graphics.setColor(0.85,0.72,0.55,0.95); love.graphics.setFont(subFont)
    love.graphics.print("乌篷 · 石桥 · 灯笼 · 落日雨丝", 24, 48)
    love.graphics.setColor(0.78,0.65,0.55,0.80); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)
    -- 18) 底部
    love.graphics.setColor(0,0,0,0.30); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.95,0.75,0.50,0.85); love.graphics.setFont(subFont)
    love.graphics.print("灵感取自吴冠中笔下的江南水乡", 24, H-23)
end
return M
