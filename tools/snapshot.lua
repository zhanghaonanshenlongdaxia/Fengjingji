-- 用法: love 项目目录 + 这个文件作为 conf
-- 跑一帧后写 preview.png 然后退出
-- 启动: tools\snap.bat

local OUT = "preview.png"
local W, H = 1200, 700
local FRAMES = 60   -- 飘雪要动起来一些

local SNOW = {}
for i = 1, 220 do
    SNOW[i] = {
        x = (i * 137.5) % 1.0,
        y = ((i * 91.7)  % 1.0),
        r = 1.0 + ((i * 7) % 3),
        s = 0.10 + ((i * 3) % 5) * 0.012
    }
end

local FONT_CANDIDATES = {
    "fonts/Deng.ttf",
    "C:/Windows/Fonts/Deng.ttf",
    "C:/Windows/Fonts/simhei.ttf",
    "C:/Windows/Fonts/msyh.ttc",
}

local function makeFont(size)
    for _, p in ipairs(FONT_CANDIDATES) do
        local ok, f = pcall(love.graphics.newFont, p, size)
        if ok then return f end
    end
    return love.graphics.getFont()
end

function love.conf(t)
    t.title = "snapshot"
    t.window.width  = W
    t.window.height = H
    t.console = true
    -- 关掉 OpenGL 音频设备 / 物理窗口
    t.window.vsync = false
    t.modules.audio    = false
    t.modules.sound    = false
    t.modules.timer    = true
end

local fontTitle, fontSub

function love.load()
    fontTitle = makeFont(28)
    fontSub   = makeFont(16)
    love.graphics.setBackgroundColor(0.04, 0.05, 0.10)
end

-- 把 main.lua 的 draw 复用：直接 require 一下
-- 但更简单：把绘制代码原样放这里（一份小拷贝），独立无依赖
local function lerp(a,b,t) return a + (b-a)*t end

local function drawMountain(pts, r, g, b, a)
    love.graphics.setColor(r, g, b, a)
    love.graphics.polygon("fill", pts)
end
local function drawSnowCap(pts, r, g, b, a)
    love.graphics.setColor(r, g, b, a)
    love.graphics.polygon("fill", pts)
end
local function drawWindowGrid(x, y, cols, rows, cw, ch, gap, r, g, b, alpha)
    for i = 0, cols-1 do
        for j = 0, rows-1 do
            local wx = x + i*(cw+gap)
            local wy = y + j*(ch+gap)
            love.graphics.setColor(r, g, b, alpha)
            love.graphics.rectangle("fill", wx, wy, cw, ch)
            love.graphics.setColor(0.10, 0.08, 0.06, 1)
            love.graphics.rectangle("line", wx, wy, cw, ch)
            love.graphics.line(wx + cw/2, wy, wx + cw/2, wy+ch)
            love.graphics.line(wx, wy + ch/2, wx+cw, wy+ch/2)
        end
    end
end
local function drawSnowDrift(pts)
    love.graphics.setColor(0.96, 0.97, 1.0, 1)
    love.graphics.polygon("fill", pts)
    love.graphics.setColor(0.78, 0.82, 0.92, 0.55)
    love.graphics.polygon("line", pts)
end

local frame = 0
function love.draw()
    frame = frame + 1
    local t = frame * 0.05
    local W, H = love.graphics.getDimensions()

    -- 夜空
    for i = 0, 30 do
        local p = i / 30
        love.graphics.setColor(lerp(0.04,0.08,p), lerp(0.05,0.10,p), lerp(0.10,0.22,p), 1)
        love.graphics.rectangle("fill", 0, i * (H/30), W, H/30 + 1)
    end
    local moonX, moonY = W*0.78, H*0.18
    for k = 5, 1, -1 do
        love.graphics.setColor(1, 0.95, 0.82, 0.04 * k)
        love.graphics.circle("fill", moonX, moonY, 18 + k*8)
    end
    love.graphics.setColor(0.98, 0.93, 0.78, 1)
    love.graphics.circle("fill", moonX, moonY, 18)
    for i = 1, 90 do
        local x = (i * 137.5) % W
        local y = (i * 73.1)  % (H * 0.55)
        local tw = 0.5 + 0.5 * math.sin(t * 0.8 + i)
        love.graphics.setColor(0.85, 0.9, 1.0, 0.3 + 0.4*tw)
        love.graphics.circle("fill", x, y, 1.2)
    end

    local baseY = H * 0.62
    drawMountain({ 0,baseY, W*0.15,baseY-90, W*0.32,baseY-30, W*0.50,baseY-130, W*0.70,baseY-60, W*0.86,baseY-110, W,baseY-40, W,baseY+200, 0,baseY+200 }, 0.16,0.22,0.31,0.85)

    local baseY2 = H * 0.70
    drawMountain({ 0,baseY2, W*0.12,baseY2-80, W*0.28,baseY2-40, W*0.45,baseY2-110, W*0.62,baseY2-55, W*0.82,baseY2-95, W,baseY2-30, W,baseY2+200, 0,baseY2+200 }, 0.12,0.15,0.26,0.95)
    drawSnowCap({ W*0.45-80,baseY2-110, W*0.45,baseY2-145, W*0.45+80,baseY2-110 }, 0.95,0.97,1.0,0.9)
    drawSnowCap({ W*0.82-60,baseY2-95,  W*0.82,baseY2-125, W*0.82+60,baseY2-95  }, 0.95,0.97,1.0,0.9)

    -- 滑雪道
    love.graphics.setColor(0.10, 0.13, 0.22, 1)
    love.graphics.polygon("fill", { W*0.55,baseY2-30, W*0.95,baseY2-200, W,baseY2-180, W,baseY2+200, W*0.55,baseY2+200 })
    love.graphics.setColor(0.92, 0.95, 1.0, 0.85)
    love.graphics.polygon("fill", { W*0.62,baseY2-60, W*0.78,baseY2-170, W*0.82,baseY2-170, W*0.66,baseY2-60 })
    love.graphics.setColor(0.70, 0.78, 0.92, 0.5)
    love.graphics.polygon("line", { W*0.62,baseY2-60, W*0.78,baseY2-170, W*0.82,baseY2-170, W*0.66,baseY2-60 })

    for i = 1, 28 do
        local x = ((i * 211) % (W*0.5)) + W*0.02
        local y = baseY2 - 5 + (i % 3) * 2
        local h = 18 + (i % 4) * 4
        love.graphics.setColor(0.08, 0.13, 0.20, 0.85)
        love.graphics.polygon("fill", { x, y-h, x-5, y-2, x+5, y-2 })
    end

    local HX1, HY1 = W*0.18, H*0.42
    local HX2, HY2 = W*0.52, H*0.82
    love.graphics.setColor(0.13, 0.10, 0.08, 1)
    love.graphics.rectangle("fill", HX1, HY1, HX2-HX1, HY2-HY1)
    local roofTopY = H*0.30
    love.graphics.setColor(0.16, 0.12, 0.09, 1)
    love.graphics.polygon("fill", { HX1-10,HY1+6, HX1+(HX2-HX1)/2,roofTopY, HX2+10,HY1+6 })
    love.graphics.setColor(0.97, 0.98, 1.0, 1)
    love.graphics.polygon("fill", { HX1-8,HY1+8, HX1+8,HY1+8, HX1+(HX2-HX1)/2,roofTopY+6 })
    love.graphics.polygon("fill", { HX2+8,HY1+8, HX2-8,HY1+8, HX1+(HX2-HX1)/2,roofTopY+6 })
    love.graphics.setColor(0.72, 0.78, 0.88, 0.6)
    love.graphics.line(HX1-8,HY1+8, HX1+(HX2-HX1)/2,roofTopY+6)
    love.graphics.line(HX2+8,HY1+8, HX1+(HX2-HX1)/2,roofTopY+6)

    love.graphics.setColor(0.10, 0.08, 0.06, 1)
    love.graphics.rectangle("fill", HX2-60, roofTopY-5, 18, 35)
    love.graphics.setColor(0.95, 0.97, 1.0, 1)
    love.graphics.rectangle("fill", HX2-60, roofTopY-7, 18, 4)
    for k = 0, 2 do
        local ox = math.sin(t*0.5 + k)*3
        local oy = -k*16 - 8
        love.graphics.setColor(1, 1, 1, 0.10 - k*0.02)
        love.graphics.circle("fill", HX2-51+ox, roofTopY-18+oy, 9+k*2)
    end

    love.graphics.setColor(1.0, 0.85, 0.55, 1)
    love.graphics.circle("fill", HX1+(HX2-HX1)/2, roofTopY+50, 9)
    love.graphics.setColor(0.10, 0.08, 0.06, 1)
    love.graphics.circle("line", HX1+(HX2-HX1)/2, roofTopY+50, 9)

    drawWindowGrid(HX1+20, HY1+60,  5, 1, 32, 44, 12, 1.0,0.82,0.50,1)
    drawWindowGrid(HX1+20, HY1+130, 5, 1, 32, 44, 12, 1.0,0.78,0.45,1)
    drawWindowGrid(HX1+30, HY1+200, 4, 1, 38, 50, 14, 1.0,0.88,0.55,1)

    local doorX = HX1+(HX2-HX1)/2 - 22
    local doorY = HY2 - 70
    love.graphics.setColor(0.07, 0.05, 0.04, 1)
    love.graphics.rectangle("fill", doorX, doorY, 44, 70)
    love.graphics.setColor(1.0, 0.78, 0.42, 0.4)
    love.graphics.rectangle("fill", doorX+6, doorY+6, 32, 58)
    love.graphics.setColor(0.10, 0.07, 0.05, 1)
    love.graphics.rectangle("fill", doorX-6, doorY-8, 56, 10)
    love.graphics.setColor(0.95, 0.97, 1.0, 0.6)
    love.graphics.rectangle("fill", doorX-6, doorY-9, 56, 2)
    love.graphics.setColor(0.95, 0.96, 1.0, 0.9)
    love.graphics.rectangle("fill", doorX-14, HY2-6, 72, 6)
    love.graphics.setColor(1.0, 0.92, 0.65, 0.18)
    love.graphics.circle("fill", doorX-6, doorY+8, 22)
    love.graphics.setColor(1.0, 0.95, 0.78, 1)
    love.graphics.circle("fill", doorX-6, doorY+8, 3)

    local LX1, LY1 = W*0.04, H*0.62
    local LX2, LY2 = HX1, H*0.82
    love.graphics.setColor(0.11, 0.09, 0.07, 1)
    love.graphics.rectangle("fill", LX1, LY1, LX2-LX1, LY2-LY1)
    love.graphics.setColor(0.14, 0.11, 0.08, 1)
    love.graphics.polygon("fill", { LX1-4,LY1+4, (LX1+LX2)/2,LY1-24, LX2+4,LY1+4 })
    love.graphics.setColor(0.96, 0.97, 1.0, 1)
    love.graphics.polygon("fill", { LX1-2,LY1+6, (LX1+LX2)/2,LY1-22, LX2+2,LY1+6 })
    drawWindowGrid(LX1+12, LY1+18, 3, 2, 24, 32, 10, 1.0,0.80,0.48,1)

    local RX1, RY1 = HX2, H*0.50
    local RX2, RY2 = W*0.66, H*0.82
    love.graphics.setColor(0.12, 0.10, 0.08, 1)
    love.graphics.rectangle("fill", RX1, RY1, RX2-RX1, RY2-RY1)
    love.graphics.setColor(0.15, 0.12, 0.09, 1)
    love.graphics.polygon("fill", { RX1-4,RY1+4, (RX1+RX2)/2,RY1-30, RX2+4,RY1+4 })
    love.graphics.setColor(0.96, 0.97, 1.0, 1)
    love.graphics.polygon("fill", { RX1-2,RY1+6, (RX1+RX2)/2,RY1-28, RX2+2,RY1+6 })
    drawWindowGrid(RX1+12, RY1+30, 4, 2, 26, 34, 10, 1.0,0.82,0.50,1)
    local TX = (RX1+RX2)/2
    love.graphics.setColor(0.13, 0.10, 0.08, 1)
    love.graphics.rectangle("fill", TX-18, RY1-90, 36, 80)
    love.graphics.setColor(0.14, 0.11, 0.09, 1)
    love.graphics.polygon("fill", { TX-22,RY1-90, TX,RY1-120, TX+22,RY1-90 })
    love.graphics.setColor(0.96, 0.97, 1.0, 1)
    love.graphics.polygon("fill", { TX-20,RY1-88, TX,RY1-118, TX+20,RY1-88 })
    love.graphics.setColor(1.0, 0.95, 0.78, 1)
    love.graphics.circle("fill", TX, RY1-70, 10)
    love.graphics.setColor(0.05, 0.04, 0.03, 1)
    love.graphics.circle("line", TX, RY1-70, 10)
    local ang = (t * 0.05) % (math.pi*2)
    love.graphics.line(TX, RY1-70, TX + math.cos(ang)*7, RY1-70 + math.sin(ang)*7)

    for i = 0, 12 do
        local p = i / 12
        love.graphics.setColor(lerp(0.92,0.98,p), lerp(0.95,0.99,p), 1, 1)
        love.graphics.rectangle("fill", 0, H*0.82 + i*(H*0.18/12), W, H*0.18/12 + 1)
    end
    drawSnowDrift({ W*0.00,H*0.92, W*0.18,H*0.86, W*0.40,H*0.93, W*0.30,H*0.98, 0,H })
    drawSnowDrift({ W*0.30,H*0.95, W*0.55,H*0.88, W*0.78,H*0.94, W*0.65,H*0.99, W*0.30,H })
    drawSnowDrift({ W*0.70,H*0.93, W*0.92,H*0.86, W,H*0.90,       W,H,        W*0.70,H })

    love.graphics.setColor(1.0, 0.85, 0.55, 0.12)
    love.graphics.polygon("fill", { HX1+30,H*0.82, HX2-30,H*0.82, HX2+10,H*0.96, HX1-10,H*0.96 })

    love.graphics.setColor(0.80, 0.85, 0.95, 0.6)
    for i = 0, 6 do
        love.graphics.circle("fill", (HX1+HX2)/2 + (i-3)*14, H*0.96 + i*0.6, 2)
    end

    love.graphics.setColor(0.10, 0.08, 0.06, 1)
    love.graphics.rectangle("fill", HX2-30, roofTopY-8, 2, 60)
    love.graphics.setColor(0.7, 0.1, 0.1, 1)
    love.graphics.polygon("fill", { HX2-28,roofTopY-4, HX2-6,roofTopY-2, HX2-8,roofTopY+4, HX2-28,roofTopY+6 })

    local pX, pY = W*0.86, H*0.86
    love.graphics.setColor(0.04, 0.04, 0.06, 1)
    love.graphics.polygon("fill", { pX-7,pY-4, pX-11,pY-50, pX+11,pY-50, pX+7,pY-4 })
    love.graphics.circle("fill", pX, pY-56, 5)
    love.graphics.rectangle("fill", pX-7, pY-65, 14, 3)
    love.graphics.rectangle("fill", pX-5, pY-70, 10, 5)
    love.graphics.setColor(0.15, 0.10, 0.05, 1)
    love.graphics.line(pX+9, pY-4, pX+14, pY-60)
    love.graphics.circle("line", pX+14, pY-60, 3)
    love.graphics.setColor(0.78, 0.82, 0.92, 0.6)
    for i = 1, 4 do
        love.graphics.circle("fill", pX-20-i*10, pY-i*0.3, 1.5)
    end

    for _, s in ipairs(SNOW) do
        local x = s.x * W
        local y = ((s.y + t * s.s * 0.05) % 1.0) * H
        love.graphics.setColor(1, 1, 1, 0.75)
        love.graphics.circle("fill", x, y, s.r)
    end

    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 0, H-70, W, 70)
    love.graphics.setColor(0.95, 0.80, 0.45, 0.6)
    love.graphics.rectangle("fill", 0, H-70, W, 1)
    love.graphics.setColor(0.98, 0.93, 0.78, 1)
    love.graphics.setFont(fontTitle)
    love.graphics.print("No.01  ·  雪山酒店  ·  Hotel on the Snow Mountain", 24, H-55)
    love.graphics.setColor(0.78, 0.85, 0.95, 0.85)
    love.graphics.setFont(fontSub)
    love.graphics.print("灵感取自阿加莎·克里斯蒂《大雪中的山庄》    ·    按 ESC 退出", 24, H-22)
end

function love.update(dt)
    if frame >= FRAMES then
        local canvas = love.graphics.newCanvas(love.graphics.getDimensions())
        love.graphics.setCanvas(canvas)
        love.graphics.clear()
        love.draw()  -- 实际不需要重画，因为已经渲染到默认 framebuffer
        love.graphics.setCanvas()
        local img = canvas:newImageData()
        img:encode("png", OUT)
        print("[snap] saved -> " .. OUT)
        love.event.quit()
    end
end
