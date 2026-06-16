-- 风景集 / No.08  樱花神社  Sakura Shrine
-- 粉白 · 鸟居 · 落樱 · 灯笼 · 石阶 · 本殿 · 池塘 · 绘马 · 石灯笼 · 草丛
local M = { name = "sakura_shrine" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop = {0.65, 0.78, 0.95},   -- 浅蓝
    skyMid = {0.95, 0.88, 0.92},   -- 粉白
    skyHor = {1.00, 0.85, 0.85},   -- 暖粉
    hill1  = {0.85, 0.78, 0.85},   -- 远山
    hill2  = {0.75, 0.65, 0.78},
    torii  = {0.95, 0.20, 0.25},   -- 朱红
    toriiD = {0.65, 0.10, 0.15},   -- 暗红
    stone  = {0.55, 0.52, 0.50},
    stoneD = {0.40, 0.38, 0.36},
    ground = {0.90, 0.78, 0.72},
    groundD= {0.80, 0.65, 0.60},
    grass  = {0.65, 0.75, 0.55},
    lantern= {0.95, 0.85, 0.55},   -- 灯笼
    lanternD = {0.55, 0.30, 0.20},
    water  = {0.60, 0.75, 0.85},
    waterD = {0.40, 0.55, 0.70},
    wood   = {0.55, 0.20, 0.18},   -- 神社木色
    woodD  = {0.35, 0.10, 0.10},
    roof   = {0.40, 0.30, 0.32},   -- 神社屋顶(暗绿)
    roofD  = {0.25, 0.18, 0.20},
    gold   = {0.95, 0.80, 0.40},
    cherryL= {0.45, 0.85, 0.75},   -- 樱花叶
}

-- 樱花瓣
local PETALS = {}
for i = 1, 180 do
    PETALS[i] = {
        x  = rnd(i*1.1) * W,
        y  = rnd(i*2.3) * H,
        s  = 1.6 + rnd(i*3.7) * 2.4,
        v  = 20 + rnd(i*4.1) * 30,
        ph = rnd(i*5.7) * 6.28,
        sp = 0.2 + rnd(i*6.3) * 0.5,
    }
end

-- 一座鸟居 (有 2 柱+2 梁+2 立)
local function drawTorii(x, baseY, h, s, col, colD)
    -- 柱
    love.graphics.setColor(colD[1], colD[2], colD[3], 1)
    love.graphics.rectangle("fill", x - 14*s, baseY, 4*s, -h*0.85)
    love.graphics.rectangle("fill", x + 10*s, baseY, 4*s, -h*0.85)
    -- 柱亮面
    love.graphics.setColor(col[1], col[2], col[3], 1)
    love.graphics.rectangle("fill", x - 14*s, baseY, 1.5*s, -h*0.85)
    love.graphics.rectangle("fill", x + 10*s, baseY, 1.5*s, -h*0.85)
    -- 顶横梁 (笠木)
    love.graphics.setColor(colD[1], colD[2], colD[3], 1)
    love.graphics.polygon("fill", {
        x - 22*s, baseY - h, x + 22*s, baseY - h,
        x + 20*s, baseY - h - 5*s, x - 20*s, baseY - h - 5*s
    })
    -- 顶亮
    love.graphics.setColor(col[1], col[2], col[3], 1)
    love.graphics.rectangle("fill", x - 20*s, baseY - h, 40*s, 1.5*s)
    -- 第二横梁 (额束)
    love.graphics.setColor(colD[1], colD[2], colD[3], 1)
    love.graphics.rectangle("fill", x - 18*s, baseY - h*0.85, 36*s, 4*s)
    love.graphics.setColor(col[1], col[2], col[3], 1)
    love.graphics.rectangle("fill", x - 18*s, baseY - h*0.85, 36*s, 1*s)
    -- 中间立 (贯)
    love.graphics.setColor(colD[1], colD[2], colD[3], 1)
    love.graphics.rectangle("fill", x - 16*s, baseY - h*0.82, 32*s, 3*s)
    -- 中心牌
    love.graphics.setColor(0.10, 0.06, 0.04, 1)
    love.graphics.rectangle("fill", x - 6*s, baseY - h*0.70, 12*s, 14*s)
    -- 牌字
    love.graphics.setColor(0.95, 0.92, 0.85, 1)
    love.graphics.print("神", x - 4*s, baseY - h*0.68)
    -- 基座
    love.graphics.setColor(C.stone[1], C.stone[2], C.stone[3], 1)
    love.graphics.polygon("fill", {
        x - 18*s, baseY, x + 18*s, baseY,
        x + 16*s, baseY + 3*s, x - 16*s, baseY + 3*s
    })
    love.graphics.setColor(C.stoneD[1], C.stoneD[2], C.stoneD[3], 1)
    love.graphics.rectangle("fill", x - 18*s, baseY, 36*s, 1.5*s)
end

-- 一棵樱花 (树冠云团)
local function drawCherry(x, baseY, h, s, t)
    -- 干
    love.graphics.setColor(0.30, 0.18, 0.15, 1)
    love.graphics.polygon("fill", {
        x - 3*s, baseY, x + 3*s, baseY,
        x + 4*s, baseY - h*0.5, x - 4*s, baseY - h*0.5
    })
    -- 枝 (3主)
    love.graphics.setColor(0.30, 0.18, 0.15, 0.9)
    for k = -1, 1 do
        local px = x + k*8*s
        local py = baseY - h*0.5 - k*3*s
        love.graphics.polygon("fill", {
            px - 2*s, py, px + 2*s, py,
            px + k*15*s, py - 15*s, px + k*13*s, py - 15*s
        })
    end
    -- 树冠 (粉云)
    local sway = math.sin(t*0.3) * 3
    love.graphics.setColor(1.0, 0.85, 0.92, 0.95)
    love.graphics.circle("fill", x - 16*s + sway, baseY - h*0.65, 18*s)
    love.graphics.circle("fill", x + 0 + sway, baseY - h*0.75, 22*s)
    love.graphics.circle("fill", x + 16*s + sway, baseY - h*0.65, 18*s)
    love.graphics.circle("fill", x - 8*s + sway, baseY - h*0.55, 14*s)
    love.graphics.circle("fill", x + 8*s + sway, baseY - h*0.55, 14*s)
    -- 亮面
    love.graphics.setColor(1.0, 0.95, 0.98, 0.6)
    love.graphics.circle("fill", x - 4*s + sway, baseY - h*0.78, 10*s)
    -- 阴影面
    love.graphics.setColor(0.95, 0.65, 0.75, 0.4)
    love.graphics.circle("fill", x + 14*s + sway, baseY - h*0.50, 8*s)
end

-- 一盏吊灯笼
local function drawLantern(x, y, s, t)
    local swing = math.sin(t*0.5 + x*0.01) * 1.5*s
    -- 绳
    love.graphics.setColor(0.20, 0.15, 0.10, 0.8)
    love.graphics.line(x, 0, x, y + swing)
    -- 框
    love.graphics.setColor(0.40, 0.30, 0.20, 1)
    love.graphics.rectangle("fill", x - 4*s, y - 1*s + swing, 8*s, 1.5*s)
    love.graphics.rectangle("fill", x - 4*s, y + 16*s + swing, 8*s, 1.5*s)
    -- 灯
    love.graphics.setColor(1.0, 0.85, 0.55, 0.95)
    love.graphics.ellipse("fill", x, y + 8*s + swing, 6*s, 8*s)
    -- 灯亮
    love.graphics.setColor(1.0, 0.95, 0.75, 0.7)
    love.graphics.ellipse("fill", x - 1*s, y + 6*s + swing, 2.5*s, 3*s)
    -- 流苏
    love.graphics.setColor(0.95, 0.20, 0.25, 1)
    love.graphics.line(x, y + 16*s + swing, x, y + 20*s + swing)
end

-- 一座石灯笼 (地面)
local function drawStoneLantern(x, baseY, s)
    -- 基础
    love.graphics.setColor(C.stoneD[1], C.stoneD[2], C.stoneD[3], 1)
    love.graphics.polygon("fill", {
        x - 8*s, baseY, x + 8*s, baseY,
        x + 7*s, baseY - 4*s, x - 7*s, baseY - 4*s
    })
    -- 柱
    love.graphics.setColor(C.stone[1], C.stone[2], C.stone[3], 1)
    love.graphics.rectangle("fill", x - 2.5*s, baseY - 4*s, 5*s, -18*s)
    love.graphics.setColor(C.stoneD[1], C.stoneD[2], C.stoneD[3], 1)
    love.graphics.rectangle("fill", x + 1*s, baseY - 4*s, 1.5*s, -18*s)
    -- 中盘
    love.graphics.setColor(C.stone[1], C.stone[2], C.stone[3], 1)
    love.graphics.polygon("fill", {
        x - 7*s, baseY - 22*s, x + 7*s, baseY - 22*s,
        x + 6*s, baseY - 25*s, x - 6*s, baseY - 25*s
    })
    -- 火袋 (灯)
    love.graphics.setColor(0.20, 0.15, 0.10, 1)
    love.graphics.rectangle("fill", x - 5*s, baseY - 32*s, 10*s, 8*s)
    love.graphics.setColor(1.0, 0.85, 0.55, 0.9)
    love.graphics.rectangle("fill", x - 3.5*s, baseY - 31*s, 7*s, 6*s)
    love.graphics.setColor(1.0, 0.95, 0.80, 0.95)
    love.graphics.rectangle("fill", x - 2*s, baseY - 30*s, 4*s, 4*s)
    -- 顶盖
    love.graphics.setColor(C.stoneD[1], C.stoneD[2], C.stoneD[3], 1)
    love.graphics.polygon("fill", {
        x - 9*s, baseY - 32*s, x + 9*s, baseY - 32*s,
        x + 11*s, baseY - 36*s, x - 11*s, baseY - 36*s
    })
    -- 顶尖
    love.graphics.setColor(C.stone[1], C.stone[2], C.stone[3], 1)
    love.graphics.circle("fill", x, baseY - 38*s, 2.5*s)
end

-- 一片草丛
local function drawGrass(x, baseY, s, t)
    local sway = math.sin(t*0.7 + x*0.05) * 2
    love.graphics.setColor(C.grass[1], C.grass[2], C.grass[3], 0.9)
    for k = -2, 2 do
        local h = (8 + math.abs(k)*2) * s
        love.graphics.polygon("fill", {
            x + k*3*s - 1, baseY, x + k*3*s + 1, baseY,
            x + k*3*s + sway, baseY - h
        })
    end
    -- 亮尖
    love.graphics.setColor(0.85, 0.95, 0.70, 0.7)
    love.graphics.polygon("fill", {
        x + sway, baseY - 10*s, x + 1 + sway, baseY - 10*s,
        x + sway, baseY - 14*s
    })
end

-- 神社本殿
local function drawShrine(x, baseY, s)
    local w = 70 * s
    local h = 75 * s
    -- 台阶 (三层)
    for k = 0, 2 do
        local off = k * 4 * s
        love.graphics.setColor(C.stone[1] - k*0.04, C.stone[2] - k*0.04, C.stone[3] - k*0.04, 1)
        love.graphics.rectangle("fill", x - w*0.5 - off, baseY - off, w + off*2, 3*s)
    end
    -- 主体木墙
    love.graphics.setColor(C.wood[1], C.wood[2], C.wood[3], 1)
    love.graphics.rectangle("fill", x - w*0.5, baseY - h*0.55, w, h*0.55)
    -- 暗面
    love.graphics.setColor(C.woodD[1], C.woodD[2], C.woodD[3], 1)
    love.graphics.rectangle("fill", x + w*0.5 - 4*s, baseY - h*0.55, 4*s, h*0.55)
    -- 亮面
    love.graphics.setColor(0.70, 0.30, 0.25, 1)
    love.graphics.rectangle("fill", x - w*0.5, baseY - h*0.55, 3*s, h*0.55)
    -- 竖柱
    for k = -2, 2 do
        love.graphics.setColor(C.woodD[1], C.woodD[2], C.woodD[3], 1)
        love.graphics.rectangle("fill", x + k*w*0.22 - 1.5*s, baseY - h*0.55, 3*s, h*0.55)
    end
    -- 门 (中央, 略深)
    love.graphics.setColor(0.10, 0.04, 0.03, 1)
    love.graphics.rectangle("fill", x - 10*s, baseY - h*0.45, 20*s, h*0.45)
    -- 门亮边
    love.graphics.setColor(0.65, 0.30, 0.25, 1)
    love.graphics.rectangle("fill", x - 10*s, baseY - h*0.45, 20*s, 1.5*s)
    -- 门上金轮
    love.graphics.setColor(C.gold[1], C.gold[2], C.gold[3], 1)
    love.graphics.circle("fill", x, baseY - h*0.30, 2.5*s)
    -- 横梁 (楣)
    love.graphics.setColor(C.gold[1]*0.6, C.gold[2]*0.6, C.gold[3]*0.6, 1)
    love.graphics.rectangle("fill", x - w*0.5 - 4*s, baseY - h*0.55 - 3*s, w + 8*s, 3*s)
    -- 屋顶 (歇山顶, 上下两层曲线)
    -- 顶层
    love.graphics.setColor(C.roofD[1], C.roofD[2], C.roofD[3], 1)
    love.graphics.polygon("fill", {
        x - w*0.6, baseY - h*0.55 - 3*s,
        x + w*0.6, baseY - h*0.55 - 3*s,
        x + w*0.4, baseY - h*0.78,
        x - w*0.4, baseY - h*0.78
    })
    -- 顶层亮面
    love.graphics.setColor(C.roof[1], C.roof[2], C.roof[3], 1)
    love.graphics.polygon("fill", {
        x - w*0.6, baseY - h*0.55 - 3*s,
        x - w*0.1, baseY - h*0.55 - 3*s,
        x - w*0.1, baseY - h*0.78,
        x - w*0.4, baseY - h*0.78
    })
    -- 顶层瓦纹
    for k = 1, 6 do
        love.graphics.setColor(C.roofD[1]*0.7, C.roofD[2]*0.7, C.roofD[3]*0.7, 0.6)
        love.graphics.rectangle("fill", x - w*0.5 + k*10*s, baseY - h*0.55 - 3*s, 1*s, h*0.23)
    end
    -- 顶层屋脊
    love.graphics.setColor(C.gold[1]*0.5, C.gold[2]*0.5, C.gold[3]*0.5, 1)
    love.graphics.rectangle("fill", x - w*0.4, baseY - h*0.78, w*0.8, 1.5*s)
    -- 顶层顶尖 (千木)
    love.graphics.setColor(C.gold[1], C.gold[2], C.gold[3], 1)
    love.graphics.rectangle("fill", x - 1*s, baseY - h*0.78, 2*s, 8*s)
    love.graphics.rectangle("fill", x - 6*s, baseY - h*0.78 - 4*s, 12*s, 1.5*s)
    -- 底层 (前檐, 略大)
    love.graphics.setColor(C.roofD[1], C.roofD[2], C.roofD[3], 1)
    love.graphics.polygon("fill", {
        x - w*0.7, baseY - h*0.62,
        x + w*0.7, baseY - h*0.62,
        x + w*0.5, baseY - h*0.85,
        x - w*0.5, baseY - h*0.85
    })
    -- 底层亮面
    love.graphics.setColor(C.roof[1], C.roof[2], C.roof[3], 1)
    love.graphics.polygon("fill", {
        x - w*0.7, baseY - h*0.62,
        x - w*0.15, baseY - h*0.62,
        x - w*0.15, baseY - h*0.85,
        x - w*0.5, baseY - h*0.85
    })
    -- 屋檐翘角 (左右)
    love.graphics.setColor(C.roofD[1], C.roofD[2], C.roofD[3], 1)
    love.graphics.polygon("fill", {
        x - w*0.7, baseY - h*0.62, x - w*0.55, baseY - h*0.62,
        x - w*0.72, baseY - h*0.68, x - w*0.65, baseY - h*0.66
    })
    love.graphics.polygon("fill", {
        x + w*0.7, baseY - h*0.62, x + w*0.55, baseY - h*0.62,
        x + w*0.72, baseY - h*0.68, x + w*0.65, baseY - h*0.66
    })
end

-- 一块绘马 (挂在横木上)
local function drawEma(x, y, s, t, colorIdx)
    local colors = {
        {0.95, 0.55, 0.55},
        {0.95, 0.75, 0.55},
        {0.65, 0.85, 0.75},
        {0.85, 0.70, 0.95},
    }
    local c = colors[(colorIdx-1) % #colors + 1]
    local swing = math.sin(t*0.6 + x*0.02) * 0.8*s
    -- 绳
    love.graphics.setColor(0.30, 0.20, 0.10, 0.7)
    love.graphics.line(x, y - 30*s, x, y + swing)
    -- 木牌
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.rectangle("fill", x - 8*s, y + swing, 16*s, 12*s)
    -- 边框
    love.graphics.setColor(0.95, 0.92, 0.85, 1)
    love.graphics.rectangle("fill", x - 7*s, y + swing, 14*s, 1*s)
    love.graphics.rectangle("fill", x - 7*s, y + 11*s + swing, 14*s, 1*s)
    -- 马形
    love.graphics.setColor(0.30, 0.10, 0.10, 0.8)
    love.graphics.polygon("fill", {
        x - 4*s, y + 3*s + swing, x + 4*s, y + 3*s + swing,
        x + 5*s, y + 5*s + swing, x + 3*s, y + 7*s + swing,
        x - 3*s, y + 7*s + swing, x - 5*s, y + 5*s + swing
    })
end

-- 远山
local function drawMountain(yBase, col, h, j)
    love.graphics.setColor(col[1], col[2], col[3], 0.85)
    local pts = {}
    pts[1] = 0; pts[2] = H
    for i = 0, 20 do
        local p = i / 20
        local x = p * W
        local y = yBase - math.abs(math.sin(p*3 + j)) * h - (i%3)*h*0.1 - 10
        pts[#pts+1] = x; pts[#pts+1] = y
    end
    pts[#pts+1] = W; pts[#pts+1] = H
    love.graphics.polygon("fill", pts)
end

-- 池塘 (圆形)
local function drawPond(x, y, rx, ry, t)
    -- 水边暗圈
    love.graphics.setColor(C.stoneD[1], C.stoneD[2], C.stoneD[3], 1)
    love.graphics.ellipse("fill", x, y, rx + 4, ry + 3)
    -- 水
    love.graphics.setColor(C.water[1], C.water[2], C.water[3], 0.95)
    love.graphics.ellipse("fill", x, y, rx, ry)
    -- 水深暗
    love.graphics.setColor(C.waterD[1], C.waterD[2], C.waterD[3], 0.6)
    love.graphics.ellipse("fill", x, y + 1, rx * 0.7, ry * 0.6)
    -- 浮动光斑
    for k = 0, 3 do
        local a = t * 0.5 + k * 1.6
        local sx = x + math.cos(a) * rx * 0.5
        local sy = y + math.sin(a * 1.3) * ry * 0.4
        love.graphics.setColor(1, 0.95, 0.95, 0.55)
        love.graphics.ellipse("fill", sx, sy, 8, 1.5)
    end
    -- 漂着的花瓣
    for k = 1, 5 do
        local a = k * 1.3 + t * 0.3
        local sx = x + math.cos(a) * rx * 0.4
        local sy = y + math.sin(a) * ry * 0.3
        love.graphics.setColor(1.0, 0.78, 0.85, 0.9)
        love.graphics.circle("fill", sx, sy, 1.8)
    end
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 天空 (浅蓝→粉白→暖粉)
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.45 then
            local q = p / 0.45
            r = lerp(C.skyTop[1], C.skyMid[1], q)
            g = lerp(C.skyTop[2], C.skyMid[2], q)
            b = lerp(C.skyTop[3], C.skyMid[3], q)
        else
            local q = (p - 0.45) / 0.55
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 1.5) 太阳柔光 (月也行, 偏粉)
    love.graphics.setColor(1.0, 0.85, 0.85, 0.18)
    love.graphics.circle("fill", W*0.78, H*0.22, 80)
    love.graphics.setColor(1.0, 0.95, 0.90, 0.55)
    love.graphics.circle("fill", W*0.78, H*0.22, 30)
    -- 薄云遮月
    love.graphics.setColor(1.0, 0.88, 0.92, 0.4)
    love.graphics.ellipse("fill", W*0.74, H*0.21, 50, 6)
    love.graphics.ellipse("fill", W*0.82, H*0.23, 45, 5)
    love.graphics.setColor(1.0, 0.95, 0.96, 0.5)
    love.graphics.ellipse("fill", W*0.78, H*0.20, 60, 4)

    -- 1.6) 远飞鸟 (V 字群)
    for k = 1, 5 do
        local bx = W*0.5 + math.sin(t*0.4 + k*1.7) * 120
        local by = H*0.28 + k * 14 + math.cos(t*0.3 + k) * 5
        love.graphics.setColor(0.45, 0.30, 0.35, 0.7)
        love.graphics.line(bx - 4, by, bx, by - 2)
        love.graphics.line(bx, by - 2, bx + 4, by)
    end

    -- 2) 远山
    drawMountain(H*0.50, C.hill1, 70, 1)
    drawMountain(H*0.55, C.hill2, 60, 2)

    -- 2.5) 中景: 远樱花树冠
    for k = 0, 5 do
        local bx = 100 + k * 200
        local by = H*0.60 + math.sin(k*1.3) * 10
        local sway = math.sin(t*0.3 + k) * 3
        love.graphics.setColor(1.0, 0.85, 0.92, 0.55)
        love.graphics.circle("fill", bx + sway, by, 25)
        love.graphics.circle("fill", bx + 18 + sway, by + 5, 22)
        love.graphics.circle("fill", bx - 18 + sway, by + 5, 22)
    end

    -- 3) 石阶 (中央, 通往本殿)
    for k = 0, 7 do
        local p = k / 7
        local y = H*0.78 - k*8
        local w = 360 - k*30
        local x = W*0.5 - w*0.5
        love.graphics.setColor(C.stone[1] - p*0.05, C.stone[2] - p*0.05, C.stone[3] - p*0.05, 1)
        love.graphics.rectangle("fill", x, y, w, 8)
        love.graphics.setColor(0.30, 0.27, 0.25, 1)
        love.graphics.rectangle("fill", x, y, w, 1)
    end

    -- 4) 地面 (分远近两色, 营造层次)
    -- 远地面
    love.graphics.setColor(C.groundD[1], C.groundD[2], C.groundD[3], 1)
    love.graphics.rectangle("fill", 0, H*0.78, W, H*0.10)
    -- 近地面
    love.graphics.setColor(C.ground[1], C.ground[2], C.ground[3], 1)
    love.graphics.rectangle("fill", 0, H*0.88, W, H*0.12)
    -- 地缝 (深)
    for k = 1, 8 do
        local gx = (k * 150) % W
        love.graphics.setColor(0.65, 0.50, 0.45, 0.4)
        love.graphics.rectangle("fill", gx, H*0.90, 1, 6)
    end

    -- 4.5) 地面散布的落樱堆
    for k = 0, 14 do
        local px = (k * 89 + 30) % W
        local py = H*0.90 + (k % 3) * 8
        love.graphics.setColor(1.0, 0.78, 0.85, 0.55)
        love.graphics.circle("fill", px, py, 1.5)
        love.graphics.circle("fill", px + 3, py + 1, 1.2)
    end

    -- 5) 神社本殿 (中央, 在石阶尽头, 远处)
    drawShrine(W*0.5, H*0.66, 1.4)

    -- 6) 鸟居 (中, 在本殿前)
    drawTorii(W*0.5, H*0.78, 200, 1.2, C.torii, C.toriiD)

    -- 7) 鸟居 (前, 左右)
    drawTorii(W*0.18, H*0.92, 200, 1.1, C.torii, C.toriiD)
    drawTorii(W*0.82, H*0.92, 200, 1.1, C.torii, C.toriiD)

    -- 8) 樱花 (大, 后)
    drawCherry(W*0.10, H*0.85, 260, 1.2, t + 1.0)
    drawCherry(W*0.90, H*0.85, 260, 1.2, t + 2.0)

    -- 9) 樱花 (前, 大)
    drawCherry(W*0.05, H*0.92, 340, 1.6, t)
    drawCherry(W*0.95, H*0.92, 340, 1.6, t + 0.5)

    -- 10) 石灯笼 (两侧, 鸟居旁)
    drawStoneLantern(W*0.12, H*0.92, 1.2)
    drawStoneLantern(W*0.88, H*0.92, 1.2)
    drawStoneLantern(W*0.40, H*0.78, 1.0)
    drawStoneLantern(W*0.60, H*0.78, 1.0)

    -- 11) 吊灯笼
    drawLantern(W*0.20, 60, 1.2, t)
    drawLantern(W*0.50, 50, 1.4, t)
    drawLantern(W*0.80, 60, 1.2, t)

    -- 12) 池塘 (左下, 倒影樱花)
    drawPond(W*0.08, H*0.95, 50, 12, t)
    drawPond(W*0.92, H*0.95, 45, 11, t + 1.0)

    -- 13) 草丛 (地面装饰)
    drawGrass(180, H*0.92, 1.0, t)
    drawGrass(360, H*0.91, 1.2, t + 0.5)
    drawGrass(580, H*0.92, 0.9, t + 1.0)
    drawGrass(720, H*0.91, 1.1, t + 1.5)
    drawGrass(880, H*0.92, 1.0, t + 2.0)
    drawGrass(1040,H*0.91, 0.8, t + 2.5)

    -- 14) 绘马 (挂在横绳上, 中部)
    love.graphics.setColor(0.30, 0.20, 0.10, 0.7)
    love.graphics.line(W*0.30, H*0.66, W*0.70, H*0.66)
    local emaX = {0.34, 0.40, 0.46, 0.52, 0.58, 0.64}
    for k, fx in ipairs(emaX) do
        drawEma(W*fx, H*0.66, 1.0, t, k)
    end

    -- 15) 落樱
    for _, P in ipairs(PETALS) do
        local px = (P.x + t * P.v) % (W + 40)
        local py = (P.y + t * P.v * P.sp) % H
        local rot = t * 2 + P.ph
        -- 5瓣花
        love.graphics.push()
        love.graphics.translate(px, py)
        love.graphics.rotate(rot)
        love.graphics.setColor(1.0, 0.78, 0.85, 0.9)
        for k = 0, 4 do
            local a = k * 1.256 + rot
            love.graphics.circle("fill", math.cos(a)*P.s, math.sin(a)*P.s, P.s*0.7)
        end
        love.graphics.setColor(1.0, 0.95, 0.95, 0.95)
        love.graphics.circle("fill", 0, 0, P.s*0.4)
        love.graphics.pop()
    end

    -- 16) 顶部信息条
    love.graphics.setColor(0,0,0,0.45)
    love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.95,0.60,0.70,0.6)
    love.graphics.rectangle("fill", 0, 75, W, 1)

    love.graphics.setColor(1.0,0.95,0.95,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.08  ·  樱花神社  ·  Sakura Shrine", 24, 12)
    love.graphics.setColor(0.95,0.85,0.88,0.95); love.graphics.setFont(subFont)
    love.graphics.print("朱红鸟居 · 樱花 · 落瓣 · 灯笼 · 石阶", 24, 48)
    love.graphics.setColor(0.85,0.75,0.78,0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 17) 底部
    love.graphics.setColor(0,0,0,0.35); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.95,0.85,0.88,0.85); love.graphics.setFont(subFont)
    love.graphics.print("一千棵樱花落下来 — 神明说今天是好天气", 24, H-23)
end
return M
