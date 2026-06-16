-- scenes/manager.lua  -- 场景调度器：← / → / Space 切换，Esc 退出
local M = {}
local scenes = {}
local cur = 1

function M.register(scene) scenes[#scenes+1] = scene end
function M.current() return scenes[cur] end
function M.index() return cur end
function M.count() return #scenes end

function M.next()
    cur = cur + 1
    if cur > #scenes then cur = 1 end
end
function M.prev()
    cur = cur - 1
    if cur < 1 then cur = #scenes end
end

function M.handleKey(k)
    if k == nil then return false end
    if k == "right" or k == "space" then
        M.next(); return true
    elseif k == "left" then
        M.prev(); return true
    elseif k == "escape" then
        love.event.quit(); return true
    end
    return false
end
return M
