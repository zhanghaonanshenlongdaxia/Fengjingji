-- 风景集 main.lua  场景画廊 (LÖVE 11.5)
-- 操作: ← / → / 空格 切换场景；Esc 退出；F2 截图

local FONT_CANDS = {
    "fonts/Deng.ttf", "C:/Windows/Fonts/Deng.ttf",
    "C:/Windows/Fonts/simhei.ttf", "C:/Windows/Fonts/msyh.ttc",
}
local function makeFont(sz)
    for _, p in ipairs(FONT_CANDS) do
        local ok, f = pcall(love.graphics.newFont, p, sz); if ok then return f end
    end
    return love.graphics.getFont()
end

local MGR = require("scenes.manager")
local fontTitle, fontSub

function love.load()
    fontTitle = makeFont(30)
    fontSub   = makeFont(18)
    MGR.register(require("scenes.snow_hotel"))
    MGR.register(require("scenes.water_town"))
    MGR.register(require("scenes.autumn_forest"))
    MGR.register(require("scenes.lavender_night"))
    MGR.register(require("scenes.desert_dusk"))
    MGR.register(require("scenes.coral_reef"))
    MGR.register(require("scenes.bamboo_mist"))
    MGR.register(require("scenes.sakura_shrine"))
    MGR.register(require("scenes.aurora_snow"))
    MGR.register(require("scenes.rain_neon"))
    -- No.11 ~ No.20 新场景
    MGR.register(require("scenes.grassland_dawn"))
    MGR.register(require("scenes.volcano_lava"))
    MGR.register(require("scenes.shipwreck_deep"))
    MGR.register(require("scenes.snow_summit"))
    MGR.register(require("scenes.oasis_night"))
    MGR.register(require("scenes.sakura_tunnel"))
    MGR.register(require("scenes.rime_pine_forest"))
    MGR.register(require("scenes.rooftop_dusk"))
    MGR.register(require("scenes.firefly_wood"))
    MGR.register(require("scenes.ice_cave"))
    print("[风景集] 已注册 "..MGR.count().." 个场景，当前 No."..MGR.index().." - "..(MGR.current().name or "?"))
end

function love.keypressed(k, sc, isrepeat)
    if k == "escape" then
        love.event.quit()
        return
    elseif k == "f2" then
        saveSnapshot()
        return
    end
    MGR.handleKey(k)
end

function love.draw()
    -- 背景渐变 (深蓝→深紫) — 给窗口留 8px 顶/底 margin 让场景标题不贴边
    local W, H = love.graphics.getDimensions()
    for y = 0, H do
        local t = y / H
        local r = 0.06 + 0.10*t
        local g = 0.05 + 0.05*t
        local b = 0.18 + 0.22*t
        love.graphics.setColor(r, g, b)
        love.graphics.line(0, y, W, y)
    end
    love.graphics.setColor(1,1,1)
    -- 只画当前场景（场景自己负责所有文字 — 顶部副标题/底部灵感/切换提示）
    MGR.current().draw(fontTitle, fontSub)
end

-- F2 截图：写到 save 目录
function saveSnapshot()
    local W, H = love.graphics.getDimensions()
    local canvas = love.graphics.newCanvas(W, H)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    MGR.current().draw(fontTitle, fontSub)
    love.graphics.setCanvas()
    local data = canvas:newImageData()
    local outName = "snap_"..(MGR.current().name or "scene")..".png"
    data:encode("png", outName)
    print("[风景集] 截图已写到 save 目录: "..outName)
end
