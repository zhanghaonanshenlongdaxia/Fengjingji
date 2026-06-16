-- 风景集 / No.14  雪山极顶  Snow Summit
-- 雪山 · 登山者 · 冰裂缝 · 旗 · 远云海 · 太阳 · 蓝冰
local M = { name = "snow_summit" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop   = {0.10, 0.25, 0.55},
    skyMid   = {0.55, 0.70, 0.85},
    skyHor   = {0.85, 0.92, 0.98},
    sun      = {1.00, 0.95, 0.80},
    sunGlow  = {1.00, 0.85, 0.65},
    snowL    = {0.98, 0.99, 1.00},
    snowM    = {0.82, 0.88, 0.95},
    snowD    = {0.62, 0.72, 0.85},
    iceBlue  = {0.40, 0.65, 0.85},
    iceDk    = {0.25, 0.45, 0.65},
    rock     = {0.40, 0.40, 0.45},
    rockDk   = {0.20, 0.20, 0.25},
    flagR    = {0.95, 0.20, 0.20},
    jacket   = {0.85, 0.30, 0.30},
    jacketDk = {0.55, 0.18, 0.18},
    pants    = {0.18, 0.20, 0.30},
    cloud    = {1.00, 1.00, 1.00},
}

-- 远山雪峰 (层叠, 透视)
local function drawPeak(cx, baseY, w, h, c, snowPct)
    -- 山体
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.polygon("fill", {
        cx - w*0.5, baseY,
        cx + w*0.5, baseY,
        cx + w*0.20, baseY - h*0.7,
        cx,           baseY - h,
        cx - w*0.20, baseY - h*0.7,
    })
    -- 雪盖
    love.graphics.setColor(C.snowL[1], C.snowL[2], C.snowL[3], snowPct)
    love.graphics.polygon("fill", {
        cx - w*0.20, baseY - h*0.7,
        cx,           baseY - h,
        cx + w*0.20, baseY - h*0.7,
        cx + w*0.10, baseY - h*0.65,
        cx,           baseY - h*0.55,
        cx - w*0.10, baseY - h*0.65,
    })
end

-- 冰裂缝 (深色 V 形)
local function drawCrevice(x, y, w, h)
    love.graphics.setColor(C.iceDk[1], C.iceDk[2], C.iceDk[3], 1)
    love.graphics.polygon("fill", {
        x, y, x - w, y + h, x - w*0.3, y + h, x - w*0.1, y + h*0.2,
        x, y,
    })
    love.graphics.setColor(C.iceBlue[1], C.iceBlue[2], C.iceBlue[3], 0.7)
    love.graphics.line(x, y, x - w*0.3, y + h*0.7)
    love.graphics.setColor(C.snowL[1], C.snowL[2], C.snowL[3], 0.9)
    love.graphics.line(x + 0.5, y + 0.5, x - w + 0.5, y + h - 0.5)
end

-- 登山者
local function drawClimber(x, baseY, s, t)
    local bob = math.sin(t*2.5) * 1.5 * s
    -- 投影
    love.graphics.setColor(0.10, 0.15, 0.25, 0.30)
    love.graphics.ellipse("fill", x + 3*s, baseY + 1, 12*s, 3)
    -- 裤腿
    love.graphics.setColor(C.pants[1], C.pants[2], C.pants[3], 1)
    love.graphics.rectangle("fill", x - 4*s, baseY - 14*s + bob, 3.5*s, 14*s)
    love.graphics.rectangle("fill", x + 0.5*s, baseY - 14*s - bob*0.7, 3.5*s, 14*s)
    -- 靴
    love.graphics.setColor(0.10, 0.05, 0.05, 1)
    love.graphics.rectangle("fill", x - 5*s, baseY - 2*s + bob, 4.5*s, 2.5*s)
    love.graphics.rectangle("fill", x + 0.5*s, baseY - 2*s - bob*0.7, 4.5*s, 2.5*s)
    -- 上身 (羽绒服)
    love.graphics.setColor(C.jacket[1], C.jacket[2], C.jacket[3], 1)
    love.graphics.polygon("fill", {
        x - 8*s, baseY - 16*s, x + 8*s, baseY - 16*s,
        x + 6*s, baseY - 32*s, x - 6*s, baseY - 32*s
    })
    love.graphics.setColor(C.jacketDk[1], C.jacketDk[2], C.jacketDk[3], 1)
    love.graphics.polygon("fill", {
        x, baseY - 16*s, x + 8*s, baseY - 16*s,
        x + 6*s, baseY - 32*s, x, baseY - 32*s,
    })
    -- 手臂 (一支举着冰镐)
    love.graphics.setColor(C.jacket[1], C.jacket[2], C.jacket[3], 1)
    love.graphics.rectangle("fill", x + 6*s, baseY - 30*s, 4*s, 14*s)
    -- 冰镐
    love.graphics.setColor(0.30, 0.30, 0.35, 1)
    love.graphics.rectangle("fill", x + 7*s, baseY - 50*s, 1.5*s, 22*s)
    love.graphics.setColor(0.50, 0.50, 0.55, 1)
    love.graphics.polygon("fill", {
        x + 6*s, baseY - 50*s, x + 10*s, baseY - 50*s,
        x + 8*s, baseY - 54*s,
    })
    -- 头 (帽子)
    love.graphics.setColor(C.jacket[1], C.jacket[2], C.jacket[3], 1)
    love.graphics.circle("fill", x, baseY - 36*s, 5*s)
    -- 帽檐
    love.graphics.setColor(0.55, 0.18, 0.18, 1)
    love.graphics.rectangle("fill", x - 5*s, baseY - 36*s, 10*s, 1.5*s)
    -- 脸
    love.graphics.setColor(0.95, 0.80, 0.70, 1)
    love.graphics.circle("fill", x, baseY - 35*s, 3.5*s)
    -- 护目镜
    love.graphics.setColor(0.10, 0.10, 0.10, 1)
    love.graphics.rectangle("fill", x - 3*s, baseY - 36*s, 6*s, 2*s)
end

-- 旗 (飘)
local function drawFlag(x, baseY, h, t)
    -- 杆
    love.graphics.setColor(0.20, 0.20, 0.25, 1)
    love.graphics.rectangle("fill", x - 0.8, baseY - h, 1.6, h)
    love.graphics.circle("fill", x, baseY - h, 1.5)
    -- 旗面
    for k = 0, 4 do
        local px1 = x + 0.8 + k * 8
        local px2 = x + 0.8 + (k+1) * 8
        local py  = baseY - h + math.sin(t*4 + k*0.5) * 2
        love.graphics.setColor(C.flagR[1], C.flagR[2], C.flagR[3], 1)
        love.graphics.polygon("fill", {
            px1, baseY - h, px2, py,
            px1, baseY - h + 14,
        })
    end
end

-- 蓝冰 (透明层叠)
local function drawBlueIce(x, y, w, h, c)
    love.graphics.setColor(c[1], c[2], c[3], 0.7)
    love.graphics.polygon("fill", {
        x, y, x + w, y, x + w*0.8, y + h, x + w*0.2, y + h,
    })
    love.graphics.setColor(0.95, 1.0, 1.0, 0.8)
    love.graphics.line(x, y, x + w*0.2, y + h)
    love.graphics.line(x, y, x + w*0.5, y)
end

-- 云海 (柔软条带)
local function drawCloudStrip(y, w, c, a)
    love.graphics.setColor(c[1], c[2], c[3], a)
    love.graphics.ellipse("fill", W*0.5, y, w, 18)
end

-- ============= 主体 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 天空 (高海拔蓝)
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.6 then
            r = lerp(C.skyTop[1], C.skyMid[1], p/0.6)
            g = lerp(C.skyTop[2], C.skyMid[2], p/0.6)
            b = lerp(C.skyTop[3], C.skyMid[3], p/0.6)
        else
            local q = (p - 0.6) / 0.4
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 太阳
    love.graphics.setColor(C.sunGlow[1], C.sunGlow[2], C.sunGlow[3], 0.18)
    love.graphics.circle("fill", W*0.78, H*0.20, 110)
    love.graphics.setColor(C.sunGlow[1], C.sunGlow[2], C.sunGlow[3], 0.35)
    love.graphics.circle("fill", W*0.78, H*0.20, 60)
    love.graphics.setColor(C.sun[1], C.sun[2], C.sun[3], 1)
    love.graphics.circle("fill", W*0.78, H*0.20, 30)

    -- 3) 远山 (层叠)
    drawPeak(180,  H*0.65, 380, 220, C.rock,    0.95)
    drawPeak(480,  H*0.60, 420, 270, C.rockDk,  0.92)
    drawPeak(820,  H*0.68, 360, 200, C.rock,    0.95)
    drawPeak(1080, H*0.65, 320, 180, C.rockDk,  0.90)

    -- 4) 中景雪原
    love.graphics.setColor(C.snowM[1], C.snowM[2], C.snowM[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.72, 200, H*0.65, 480, H*0.70, 800, H*0.62,
        1200, H*0.68, 1200, H, 0, H,
    })
    love.graphics.setColor(C.snowL[1], C.snowL[2], C.snowL[3], 1)
    love.graphics.polygon("fill", {
        0, H*0.85, 300, H*0.80, 700, H*0.83, 1200, H*0.82, 1200, H, 0, H,
    })

    -- 5) 云海 (远处的云, 在山脚之下)
    for k = 1, 5 do
        local yk = H*0.55 + k*12
        love.graphics.setColor(1, 1, 1, 0.35 - k*0.04)
        love.graphics.ellipse("fill", W*0.5, yk, 700, 18)
    end

    -- 6) 蓝冰 (近景)
    drawBlueIce(W*0.05, H*0.86, 180, 40, C.iceBlue)
    drawBlueIce(W*0.25, H*0.88, 220, 50, C.iceDk)

    -- 7) 冰裂缝
    drawCrevice(W*0.50, H*0.82, 14, 30)
    drawCrevice(W*0.72, H*0.85, 12, 25)
    drawCrevice(W*0.85, H*0.83, 16, 35)

    -- 8) 登山者 (近景)
    drawClimber(W*0.42, H*0.82, 1.5, t)
    drawClimber(W*0.55, H*0.83, 1.2, t + 0.5)

    -- 9) 旗 (插在最高点)
    drawFlag(W*0.48, H*0.80, 80, t)

    -- 10) 远登山者 (剪影)
    for i = 1, 3 do
        local x = W*0.70 + i*30
        local y = H*0.66
        local s = 0.6
        love.graphics.setColor(0.15, 0.18, 0.28, 0.85)
        love.graphics.rectangle("fill", x-2*s, y-8*s, 2*s, 8*s)
        love.graphics.rectangle("fill", x+0*s, y-8*s, 2*s, 8*s)
        love.graphics.polygon("fill", {
            x-3*s, y-8*s, x+3*s, y-8*s, x+2*s, y-16*s, x-2*s, y-16*s
        })
        love.graphics.circle("fill", x, y-18*s, 2.5*s)
    end

    -- 11) 雪粒飘 (被风卷起)
    for i = 1, 60 do
        local ph = i * 2.7
        local x = (i*47) % W + math.sin(t*1.5 + ph) * 15
        local y = H*0.75 + (i*23) % (H*0.20) + math.cos(t*0.8 + ph) * 6
        love.graphics.setColor(1, 1, 1, 0.85)
        love.graphics.circle("fill", x, y, 0.8 + rnd(i*11+ph)*0.7)
    end

    -- 12) 顶部信息条
    love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.45,0.70,0.95,0.6); love.graphics.rectangle("fill", 0, 75, W, 1)
    love.graphics.setColor(0.95, 0.98, 1.0, 1); love.graphics.setFont(titleFont)
    love.graphics.print("No.14  ·  雪山极顶  ·  Snow Summit", 24, 12)
    love.graphics.setColor(0.85, 0.92, 1.0, 0.95); love.graphics.setFont(subFont)
    love.graphics.print("雪山 · 登山者 · 冰裂缝 · 旗 · 远云海 · 太阳 · 蓝冰", 24, 48)
    love.graphics.setColor(0.80, 0.88, 0.95, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 13) 底部
    love.graphics.setColor(0,0,0,0.40); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.88, 0.95, 1.0, 0.85); love.graphics.setFont(subFont)
    love.graphics.print("登顶那一刻 — 风比山会先开口", 24, H-23)
end
return M
