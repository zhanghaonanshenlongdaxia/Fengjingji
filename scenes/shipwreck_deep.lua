-- 风景集 / No.13  海底沉船  Shipwreck Deep
-- 沉船 · 光柱 · 鱼群 · 气泡 · 海草 · 沙底 · 珊瑚
local M = { name = "shipwreck_deep" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    seaTop   = {0.02, 0.18, 0.30},
    seaMid   = {0.04, 0.10, 0.20},
    seaDeep  = {0.02, 0.04, 0.10},
    lightBeam= {0.50, 0.85, 1.00},
    sand     = {0.85, 0.78, 0.55},
    sandDk   = {0.55, 0.45, 0.30},
    wood     = {0.32, 0.22, 0.14},
    woodDk   = {0.18, 0.12, 0.08},
    rope     = {0.40, 0.30, 0.20},
    fish1    = {1.00, 0.55, 0.20},
    fish2    = {0.95, 0.85, 0.20},
    fish3    = {0.30, 0.65, 1.00},
    fish4    = {0.85, 0.40, 0.60},
    seaweed  = {0.10, 0.45, 0.25},
    coral1   = {1.00, 0.40, 0.55},
    coral2   = {1.00, 0.70, 0.30},
    bubble   = {0.70, 0.90, 1.00},
}

-- 沉船 (侧躺的帆船)
local function drawShipwreck(x, baseY, t)
    local tilt = -8  -- 倾斜角度 (度)
    -- 船身
    love.graphics.setColor(C.wood[1], C.wood[2], C.wood[3], 1)
    love.graphics.polygon("fill", {
        x - 180, baseY - 30, x + 180, baseY - 30,
        x + 150, baseY + 30,  x - 150, baseY + 30,
    })
    -- 船身暗面
    love.graphics.setColor(C.woodDk[1], C.woodDk[2], C.woodDk[3], 1)
    love.graphics.polygon("fill", {
        x, baseY - 30, x + 180, baseY - 30,
        x + 150, baseY + 30, x, baseY + 30,
    })
    -- 船舷上沿
    love.graphics.setColor(0.20, 0.14, 0.08, 1)
    love.graphics.rectangle("fill", x - 180, baseY - 32, 360, 4)
    -- 桅杆 (斜倒)
    love.graphics.setColor(0.22, 0.15, 0.10, 1)
    love.graphics.rectangle("fill", x - 30, baseY - 200, 8, 170)
    -- 桅杆顶部
    love.graphics.circle("fill", x - 26, baseY - 200, 5)
    -- 横桁
    love.graphics.rectangle("fill", x - 90, baseY - 200, 130, 4)
    -- 残帆
    love.graphics.setColor(0.75, 0.65, 0.50, 0.95)
    love.graphics.polygon("fill", {
        x - 80, baseY - 198, x + 35, baseY - 198,
        x + 30, baseY - 100, x - 60, baseY - 130,
    })
    -- 帆布破洞
    love.graphics.setColor(C.seaMid[1], C.seaMid[2], C.seaMid[3], 1)
    love.graphics.polygon("fill", {
        x - 40, baseY - 180, x - 20, baseY - 175,
        x - 10, baseY - 160, x - 35, baseY - 150,
    })
    -- 船头破洞
    love.graphics.setColor(0.02, 0.04, 0.10, 1)
    love.graphics.ellipse("fill", x - 130, baseY - 5, 25, 18)
    -- 舷窗
    for i = 0, 2 do
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.circle("fill", x - 50 + i*60, baseY - 8, 6)
        love.graphics.setColor(C.lightBeam[1], C.lightBeam[2], C.lightBeam[3], 0.4)
        love.graphics.circle("fill", x - 50 + i*60, baseY - 8, 4)
    end
    -- 锚链
    love.graphics.setColor(C.rope[1], C.rope[2], C.rope[3], 1)
    for k = 0, 5 do
        local cy = baseY + 30 + k*8
        love.graphics.rectangle("fill", x - 100, cy, 8, 5)
    end
    -- 投影
    love.graphics.setColor(0, 0, 0, 0.30)
    love.graphics.ellipse("fill", x + 20, baseY + 50, 220, 18)
end

-- 一条鱼
local function drawFish(x, y, s, c, t, dir)
    dir = dir or 1
    local wag = math.sin(t*5 + x*0.01) * 4 * s
    love.graphics.setColor(c[1], c[2], c[3], 0.95)
    -- 身体
    love.graphics.ellipse("fill", x, y, 10*s, 4*s)
    -- 尾
    love.graphics.polygon("fill", {
        x - 9*s*dir, y, x - 14*s*dir, y - 4*s + wag*0.5,
        x - 14*s*dir, y + 4*s + wag*0.5,
    })
    -- 背鳍
    love.graphics.polygon("fill", {
        x - 2*s, y - 4*s, x + 2*s, y - 4*s,
        x + 1*s, y - 7*s,
    })
    -- 眼
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle("fill", x + 6*s*dir, y - 1*s, 1.0*s)
end

-- 海草 (摇曳)
local function drawSeaweed(x, baseY, h, c, t, ph)
    local segs = 6
    for k = 0, segs-1 do
        local p1 = k / segs
        local p2 = (k+1) / segs
        local y1 = baseY - h * p1
        local y2 = baseY - h * p2
        local sway1 = math.sin(t*1.2 + ph + p1*2) * 6 * p1
        local sway2 = math.sin(t*1.2 + ph + p2*2) * 6 * p2
        local w1 = 4 * (1 - p1) + 1
        local w2 = 4 * (1 - p2) + 1
        love.graphics.setColor(c[1], c[2], c[3], 0.95)
        -- 用 polygon 画梯形海草段 (两端不同宽度)
        love.graphics.polygon("fill", {
            x + sway1 - w1, y1,
            x + sway1 + w1, y1,
            x + sway2 + w2, y2,
            x + sway2 - w2, y2,
        })
    end
end

-- 珊瑚
local function drawCoral(x, baseY, c, kind)
    if kind == 1 then
        -- 树状
        love.graphics.setColor(c[1], c[2], c[3], 1)
        love.graphics.polygon("fill", {
            x-8, baseY, x+8, baseY, x+4, baseY-30,
            x-4, baseY-30,
        })
        love.graphics.polygon("fill", {
            x-4, baseY-25, x+4, baseY-25, x+1, baseY-50,
            x-1, baseY-50,
        })
        love.graphics.circle("fill", x, baseY-50, 4)
    else
        -- 球状簇
        love.graphics.setColor(c[1], c[2], c[3], 1)
        love.graphics.circle("fill", x-6, baseY-5, 7)
        love.graphics.circle("fill", x+6, baseY-7, 8)
        love.graphics.circle("fill", x, baseY-12, 7)
        love.graphics.circle("fill", x-3, baseY-18, 5)
    end
end

-- 气泡
local BUBBLES = {}
for i = 1, 60 do
    BUBBLES[i] = {
        x = rnd(i*3) * W,
        y = rnd(i*5) * H,
        r = 0.8 + rnd(i*7) * 2.5,
        v = 18 + rnd(i*11) * 20,
        ph = rnd(i*13) * 6.28,
    }
end

-- 光柱 (斜射)
local function drawLightBeam(x, topW, botW, t)
    local flicker = 0.20 + 0.05 * math.sin(t*1.5)
    love.graphics.setColor(C.lightBeam[1], C.lightBeam[2], C.lightBeam[3], flicker)
    love.graphics.polygon("fill", {
        x - topW, 0, x + topW, 0,
        x + botW, H, x - botW, H,
    })
    love.graphics.setColor(C.lightBeam[1], C.lightBeam[2], C.lightBeam[3], flicker * 0.5)
    love.graphics.polygon("fill", {
        x - topW*1.4, 0, x + topW*1.4, 0,
        x + botW*1.3, H, x - botW*1.3, H,
    })
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 海水渐变 (上亮下深)
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.5 then
            r = lerp(C.seaTop[1], C.seaMid[1], p/0.5)
            g = lerp(C.seaTop[2], C.seaMid[2], p/0.5)
            b = lerp(C.seaTop[3], C.seaMid[3], p/0.5)
        else
            local q = (p - 0.5) / 0.5
            r = lerp(C.seaMid[1], C.seaDeep[1], q)
            g = lerp(C.seaMid[2], C.seaDeep[2], q)
            b = lerp(C.seaMid[3], C.seaDeep[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 光柱 (2 束)
    drawLightBeam(W*0.30, 30, 100, t)
    drawLightBeam(W*0.70, 25, 80, t + 1.5)

    -- 3) 沙底
    love.graphics.setColor(C.sand[1], C.sand[2], C.sand[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.85, 200, H*0.83, 400, H*0.86, 600, H*0.84,
        800, H*0.87, 1000, H*0.85, 1200, H*0.86, 1200, H, 0, H
    })
    love.graphics.setColor(C.sandDk[1], C.sandDk[2], C.sandDk[3], 0.55)
    love.graphics.polygon("fill", {
        0, H*0.92, 300, H*0.91, 600, H*0.93,
        900, H*0.92, 1200, H*0.93, 1200, H, 0, H
    })

    -- 4) 沉船
    drawShipwreck(W*0.50, H*0.78, t)

    -- 5) 珊瑚
    drawCoral(W*0.10, H*0.86, C.coral1, 1)
    drawCoral(W*0.18, H*0.85, C.coral2, 2)
    drawCoral(W*0.85, H*0.87, C.coral1, 2)
    drawCoral(W*0.93, H*0.86, C.coral2, 1)
    drawCoral(W*0.30, H*0.88, C.coral1, 2)

    -- 6) 海草 (摇曳)
    drawSeaweed(60,  H*0.85, 130, C.seaweed, t, 0.0)
    drawSeaweed(120, H*0.86, 100, C.seaweed, t, 1.0)
    drawSeaweed(180, H*0.85, 150, C.seaweed, t, 2.0)
    drawSeaweed(1100,H*0.85, 130, C.seaweed, t, 0.5)
    drawSeaweed(1050,H*0.86, 100, C.seaweed, t, 1.5)
    drawSeaweed(1000,H*0.85, 150, C.seaweed, t, 2.5)

    -- 7) 鱼群 (一群, 朝一个方向游)
    for i = 1, 8 do
        local ph = i * 0.5
        local fx = ((i*120 + t*30) % (W + 200)) - 100
        local fy = H*0.30 + (i%3) * 25 + math.sin(t*1.5 + ph)*6
        local fc = ({C.fish1, C.fish2, C.fish3, C.fish4})[((i-1)%4)+1]
        drawFish(fx, fy, 0.9, fc, t, 1)
    end
    -- 散鱼 (各色)
    drawFish(150 + math.sin(t*0.4)*30, 200, 1.2, C.fish3, t, -1)
    drawFish(900 + math.sin(t*0.5 + 1)*40, 250, 1.1, C.fish4, t, 1)
    drawFish(700 + math.sin(t*0.6 + 2)*30, 180, 0.8, C.fish2, t, 1)

    -- 8) 气泡
    for _, B in ipairs(BUBBLES) do
        local bx = (B.x + math.sin(t*0.5 + B.ph) * 5) % W
        local by = (B.y - t * B.v) % H
        if by < 0 then by = by + H end
        love.graphics.setColor(C.bubble[1], C.bubble[2], C.bubble[3], 0.55)
        love.graphics.circle("line", bx, by, B.r)
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.circle("fill", bx - B.r*0.3, by - B.r*0.3, B.r*0.3)
    end

    -- 9) 漂浮尘埃 (悬浮颗粒)
    for i = 1, 80 do
        local ph = i * 4.1
        local x = (i*53) % W + math.sin(t*0.2 + ph) * 10
        local y = (i*37) % H + math.cos(t*0.3 + ph) * 8
        love.graphics.setColor(0.70, 0.85, 0.95, 0.25)
        love.graphics.circle("fill", x, y, 0.6)
    end

    -- 10) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.40,0.85,1.00,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(0.85, 0.95, 1.0, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.13  ·  海底沉船  ·  Shipwreck Deep", 24, 12)
    love.graphics.setColor(0.80, 0.90, 1.0, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("沉船 · 光柱 · 鱼群 · 气泡 · 海草 · 沙底 · 珊瑚", 24, 48)
    love.graphics.setColor(0.70, 0.85, 0.95, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 11) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.80, 0.92, 1.0, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("沉得越深, 越听得见自己的船", 24, H-23)
end
return M
