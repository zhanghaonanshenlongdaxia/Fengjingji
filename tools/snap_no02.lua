-- 用法: 跑 N 帧后存 out_no02.png
local OUT = "out_no02.png"
local W, H = 1200, 700
local FRAMES = 50

local FONT_CANDIDATES = {
    "fonts/Deng.ttf","C:/Windows/Fonts/Deng.ttf",
    "C:/Windows/Fonts/simhei.ttf","C:/Windows/Fonts/msyh.ttc",
}
local function makeFont(size)
    for _, p in ipairs(FONT_CANDIDATES) do
        local ok, f = pcall(love.graphics.newFont, p, size); if ok then return f end
    end
    return love.graphics.getFont()
end

function love.conf(t)
    t.title = "snap"
    t.window.width  = W
    t.window.height = H
    t.console = true
    t.window.vsync = false
    t.modules.audio = false
    t.modules.sound = false
    t.modules.timer = true
end

local MGR = require("scenes.manager")
local fontTitle, fontSub

function love.load()
    fontTitle = makeFont(30)
    fontSub   = makeFont(18)
    MGR.register(require("scenes.snow_hotel"))
    MGR.register(require("scenes.water_town"))
    MGR.next()  -- 切到 No.02
end

local frame = 0
function love.draw()
    frame = frame + 1
    MGR.current().draw(fontTitle, fontSub)
    if frame == FRAMES then
        local img = love.graphics.newImage(love.graphics.newScreenshot())
        img:encode("png", OUT)
        print("[snap] saved -> " .. OUT)
        love.event.quit()
    end
end
