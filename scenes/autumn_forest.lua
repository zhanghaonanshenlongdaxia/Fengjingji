-- 风景集 / No.03  秋日森林  Autumn Forest
-- 暖金 · 枫叶 · 林间小径 · 远山 · 飘落叶 · 小鹿
local M = { name = "autumn_forest" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

-- 调色板
local C = {
    skyTop   = {0.32, 0.18, 0.30},   -- 紫
    skyMid   = {0.95, 0.55, 0.25},   -- 橙
    skyHor   = {1.00, 0.85, 0.45},   -- 暖金
    farMt    = {0.55, 0.40, 0.55},   -- 远山紫灰
    midMt    = {0.45, 0.30, 0.35},   -- 中山
    ground   = {0.55, 0.28, 0.12},   -- 土地暖棕
    path     = {0.75, 0.50, 0.25},   -- 小径
    leafGold = {0.95, 0.70, 0.20},   -- 金叶
    leafRed  = {0.85, 0.25, 0.15},   -- 红叶
    leafOrg  = {0.95, 0.45, 0.10},   -- 橙叶
    leafDrk  = {0.25, 0.10, 0.05},   -- 暗影
    bark     = {0.22, 0.10, 0.05},   -- 树干
    barkLt   = {0.40, 0.22, 0.10},   -- 树身亮
    sun      = {1.00, 0.90, 0.55},
    deer     = {0.45, 0.28, 0.18},   -- 鹿
    deerLt   = {0.75, 0.55, 0.35},
    bird     = {0.10, 0.05, 0.05},
}

-- 飘落的叶子
local LEAVES = {}
for i = 1, 80 do
    LEAVES[i] = {
        x = rnd(i) * W,
        y = rnd(i*2.3) * H,
        s = 1.0 + rnd(i*3.1) * 1.5,    -- 大小
        v = 8 + rnd(i*4.7) * 10,       -- 下落速度
        a = rnd(i*5.3) * math.pi * 2, -- 摆动相位
        w = 0.4 + rnd(i*6.1) * 0.6,   -- 摆动幅度
        c = (i % 3),                  -- 颜色档 0/1/2
        rot = rnd(i*7.7) * math.pi,
        vrot = (rnd(i*8.3) - 0.5) * 1.5,  -- 旋转速度
    }
end

-- 鸟群 (远景剪影)
local BIRDS = {}
for i = 1, 6 do
    BIRDS[i] = {
        x = rnd(i*10.1) * W,
        y = H*0.28 + rnd(i*11.1) * H*0.10,
        s = 0.5 + rnd(i*12.1) * 0.4,
        sp = 12 + rnd(i*13.1) * 8,
        ph = rnd(i*14.1) * 100,
    }
end

-- ============= 一棵远景树（剪影） =============
local function drawTreeSil(x, baseY, h, side)
    -- 树干
    local bw = h * 0.10
    love.graphics.setColor(C.bark[1]*0.5, C.bark[2]*0.5, C.bark[3]*0.5, 1)
    love.graphics.rectangle("fill", x - bw/2, baseY - h, bw, h)
    -- 树冠 (一坨)
    local r = h * 0.45
    love.graphics.setColor(0.45, 0.20, 0.10, 0.85)
    love.graphics.circle("fill", x, baseY - h, r)
    love.graphics.setColor(0.55, 0.30, 0.15, 0.75)
    love.graphics.circle("fill", x - r*0.4, baseY - h + r*0.2, r*0.7)
end

-- ============= 一棵近景树 =============
local function drawTree(x, baseY, h, side)
    -- side: "near" 暖光面, "mid" 中等
    local trunkW = h * 0.13
    -- 树干 (有明暗)
    love.graphics.setColor(C.bark[1], C.bark[2], C.bark[3], 1)
    love.graphics.rectangle("fill", x - trunkW/2, baseY - h, trunkW, h)
    -- 亮面
    love.graphics.setColor(C.barkLt[1], C.barkLt[2], C.barkLt[3], 1)
    love.graphics.rectangle("fill", x + trunkW*0.10, baseY - h, trunkW*0.30, h)
    -- 树皮纹
    love.graphics.setColor(0.10, 0.05, 0.02, 0.6)
    for i = 1, 4 do
        local yy = baseY - h * (i / 5)
        love.graphics.line(x - trunkW/2, yy, x + trunkW/2, yy)
    end
    -- 树冠 (5 团)
    local r = h * 0.55
    -- 主体
    love.graphics.setColor(0.55, 0.18, 0.10, 1)
    love.graphics.circle("fill", x, baseY - h, r)
    -- 高光团 (金色)
    love.graphics.setColor(C.leafGold[1], C.leafGold[2], C.leafGold[3], 0.95)
    love.graphics.circle("fill", x - r*0.40, baseY - h - r*0.10, r*0.55)
    love.graphics.circle("fill", x + r*0.30, baseY - h - r*0.30, r*0.40)
    -- 红叶团
    love.graphics.setColor(C.leafRed[1], C.leafRed[2], C.leafRed[3], 0.95)
    love.graphics.circle("fill", x + r*0.35, baseY - h + r*0.10, r*0.50)
    -- 暗影团
    love.graphics.setColor(0.20, 0.08, 0.04, 0.85)
    love.graphics.circle("fill", x + r*0.10, baseY - h + r*0.25, r*0.55)
    -- 底部高光 (受光面)
    love.graphics.setColor(C.leafOrg[1], C.leafOrg[2], C.leafOrg[3], 0.7)
    love.graphics.circle("fill", x - r*0.30, baseY - h + r*0.35, r*0.45)
    -- 树枝 (从树干伸出)
    love.graphics.setColor(C.bark[1], C.bark[2], C.bark[3], 1)
    love.graphics.line(x + trunkW*0.30, baseY - h*0.70, x + r*0.70, baseY - h*0.85)
    love.graphics.line(x - trunkW*0.30, baseY - h*0.55, x - r*0.65, baseY - h*0.65)
end

-- ============= 远山 =============
local function drawMt(yBase, col, j)
    love.graphics.setColor(col[1], col[2], col[3], 1)
    local pts = {}
    pts[1] = 0; pts[2] = yBase
    for i = 0, 12 do
        local p = i / 12
        local x = p * W
        local top = yBase - 60 - (math.sin(p*4 + j) * 25) - (i%3)*15
        pts[#pts+1] = x; pts[#pts+1] = top
    end
    pts[#pts+1] = W; pts[#pts+1] = yBase
    love.graphics.polygon("fill", pts)
end

-- ============= 一片云 =============
local function drawCloud(x, y, s, t)
    love.graphics.setColor(1.0, 0.92, 0.80, 0.65)
    love.graphics.circle("fill", x, y, 18*s)
    love.graphics.circle("fill", x + 22*s, y - 4*s, 22*s)
    love.graphics.circle("fill", x + 48*s, y, 16*s)
    love.graphics.circle("fill", x + 20*s, y + 6*s, 18*s)
    -- 受光面
    love.graphics.setColor(1.0, 0.95, 0.85, 0.4)
    love.graphics.circle("fill", x + 22*s, y - 6*s, 12*s)
end

-- ============= 一只鸟 (V 形剪影) =============
local function drawBird(x, y, s, flap)
    love.graphics.setColor(C.bird[1], C.bird[2], C.bird[3], 0.85)
    local f = math.sin(flap) * 4 * s
    love.graphics.line(x - 6*s, y, x - 2*s, y - f)
    love.graphics.line(x - 2*s, y - f, x, y)
    love.graphics.line(x, y, x + 2*s, y - f)
    love.graphics.line(x + 2*s, y - f, x + 6*s, y)
end

-- ============= 一只鹿 (剪影风格) =============
local function drawDeer(x, y, s, side)
    local dir = side
    -- 身体
    love.graphics.setColor(C.deer[1], C.deer[2], C.deer[3], 1)
    love.graphics.ellipse("fill", x, y, 16*s, 8*s)
    -- 亮面
    love.graphics.setColor(C.deerLt[1], C.deerLt[2], C.deerLt[3], 1)
    love.graphics.ellipse("fill", x - 3*s*dir, y - 3*s, 10*s, 4*s)
    -- 头
    love.graphics.setColor(C.deer[1], C.deer[2], C.deer[3], 1)
    love.graphics.ellipse("fill", x + 14*s*dir, y - 8*s, 5*s, 4*s)
    -- 脖子
    love.graphics.setColor(C.deer[1], C.deer[2], C.deer[3], 1)
    love.graphics.polygon("fill", {
        x + 6*s*dir, y - 5*s,
        x + 14*s*dir, y - 8*s,
        x + 16*s*dir, y - 4*s,
        x + 8*s*dir,  y - 2*s,
    })
    -- 耳朵
    love.graphics.setColor(C.deer[1], C.deer[2], C.deer[3], 1)
    love.graphics.polygon("fill", {
        x + 12*s*dir, y - 12*s, x + 15*s*dir, y - 16*s, x + 16*s*dir, y - 11*s
    })
    -- 鹿角
    love.graphics.setColor(0.15, 0.08, 0.04, 1)
    love.graphics.line(x + 15*s*dir, y - 14*s, x + 18*s*dir, y - 22*s)
    love.graphics.line(x + 18*s*dir, y - 22*s, x + 16*s*dir, y - 26*s)
    love.graphics.line(x + 18*s*dir, y - 22*s, x + 21*s*dir, y - 22*s)
    love.graphics.line(x + 15*s*dir, y - 14*s, x + 12*s*dir, y - 22*s)
    love.graphics.line(x + 12*s*dir, y - 22*s, x + 9*s*dir, y - 19*s)
    -- 腿
    love.graphics.setColor(C.deer[1], C.deer[2], C.deer[3], 1)
    love.graphics.rectangle("fill", x - 10*s, y + 5*s, 2*s, 12*s)
    love.graphics.rectangle("fill", x - 3*s,  y + 5*s, 2*s, 12*s)
    love.graphics.rectangle("fill", x + 4*s,  y + 5*s, 2*s, 12*s)
    love.graphics.rectangle("fill", x + 10*s, y + 5*s, 2*s, 12*s)
    -- 尾
    love.graphics.setColor(C.deerLt[1], C.deerLt[2], C.deerLt[3], 1)
    love.graphics.circle("fill", x - 15*s*dir, y - 3*s, 2.5*s)
end

-- ============= 主体绘制 =============
function M.draw(titleFont, subFont)
    local t = love.timer.getTime()

    -- 1) 天空渐变 (顶紫→中橙→地平线金)
    for i = 0, 100 do
        local p = i / 100
        local r, g, b
        if p < 0.50 then
            local q = p / 0.50
            r = lerp(C.skyTop[1], C.skyMid[1], q)
            g = lerp(C.skyTop[2], C.skyMid[2], q)
            b = lerp(C.skyTop[3], C.skyMid[3], q)
        else
            local q = (p - 0.50) / 0.50
            r = lerp(C.skyMid[1], C.skyHor[1], q)
            g = lerp(C.skyMid[2], C.skyHor[2], q)
            b = lerp(C.skyMid[3], C.skyHor[3], q)
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, i*(H/100), W, H/100+1)
    end

    -- 2) 太阳
    local sunX, sunY = W*0.70, H*0.34
    for k = 5, 1, -1 do
        love.graphics.setColor(1.0, 0.85, 0.45, 0.06*k)
        love.graphics.circle("fill", sunX, sunY, 40 + k*16)
    end
    love.graphics.setColor(1.0, 0.92, 0.65, 0.95)
    love.graphics.circle("fill", sunX, sunY, 42)
    love.graphics.setColor(1.0, 1.0, 0.95, 0.85)
    love.graphics.circle("fill", sunX - 8, sunY - 8, 18)

    -- 3) 远云
    drawCloud(W*0.15 + math.sin(t*0.05)*20, H*0.22, 1.0, t)
    drawCloud(W*0.85 + math.sin(t*0.04 + 1)*20, H*0.18, 0.8, t)
    drawCloud(W*0.40, H*0.10, 0.6, t)

    -- 4) 远山 (层叠)
    drawMt(H*0.42, {0.65, 0.45, 0.60}, 1)
    drawMt(H*0.46, {0.50, 0.32, 0.42}, 2)
    drawMt(H*0.50, C.midMt, 3)

    -- 5) 远景树剪影
    for i = 0, 14 do
        local x = i * (W/14) + (i%2) * 12
        local h = 25 + (i%3) * 10
        drawTreeSil(x, H*0.52, h, "far")
    end

    -- 6) 地面 (起伏的暖色土地)
    love.graphics.setColor(0.50, 0.28, 0.12, 1)
    love.graphics.polygon("fill", {
        0, H*0.52, W, H*0.52,
        W, H*0.55,
        W*0.8, H*0.60, W*0.6, H*0.58, W*0.4, H*0.62, W*0.2, H*0.59, 0, H*0.55
    })
    -- 远地 (深一点)
    love.graphics.setColor(0.38, 0.18, 0.08, 1)
    love.graphics.polygon("fill", {
        0, H*0.60, W, H*0.60,
        W, H, 0, H
    })
    -- 地面高光 (金色阳光)
    love.graphics.setColor(0.85, 0.55, 0.20, 0.20)
    love.graphics.polygon("fill", {
        sunX - 200, H*0.55, sunX + 200, H*0.55,
        sunX + 280, H*0.95, sunX - 280, H*0.95
    })

    -- 7) 小径 (从画面中下方到远处)
    love.graphics.setColor(0.75, 0.50, 0.25, 1)
    love.graphics.polygon("fill", {
        W*0.45, H*0.58, W*0.55, H*0.58,
        W*0.85, H,     W*0.15, H,
    })
    -- 路面高光
    love.graphics.setColor(0.92, 0.65, 0.30, 0.55)
    love.graphics.polygon("fill", {
        W*0.475, H*0.58, W*0.525, H*0.58,
        W*0.75, H*0.95,  W*0.25, H*0.95
    })

    -- 8) 中景树 (5棵)
    local midTrees = {
        {x=W*0.10, y=H*0.62, h=180},
        {x=W*0.28, y=H*0.66, h=140},
        {x=W*0.72, y=H*0.65, h=160},
        {x=W*0.90, y=H*0.63, h=190},
        {x=W*0.55, y=H*0.70, h=110},
    }
    for _, T in ipairs(midTrees) do
        drawTree(T.x, T.y, T.h, "mid")
    end

    -- 9) 一只鹿在中景
    local deerX = W*0.45 + math.sin(t*0.3) * 8
    local deerY = H*0.78
    drawDeer(deerX, deerY, 1.4, 1)

    -- 10) 前景树 (大)
    drawTree(W*0.18, H*1.02, 280, "near")
    drawTree(W*0.85, H*1.02, 260, "near")
    -- 前景草丛
    love.graphics.setColor(0.55, 0.32, 0.12, 1)
    for i = 0, 12 do
        local x = i * (W/12) + (i%2) * 30
        local y = H*0.92 + (i%3) * 4
        love.graphics.polygon("fill", {
            x, y, x - 4, y + 16, x + 4, y + 16
        })
    end
    -- 高草丛 (金色)
    love.graphics.setColor(0.85, 0.65, 0.25, 0.85)
    for i = 0, 14 do
        local x = i * (W/14) + (i%3) * 18
        local y = H*0.94 + (i%2) * 4
        love.graphics.line(x, y, x + math.sin(t*0.5 + i)*2, y - 10)
        love.graphics.line(x + 3, y, x + 3 + math.sin(t*0.5 + i + 1)*2, y - 12)
    end

    -- 11) 鸟群
    for _, B in ipairs(BIRDS) do
        local bx = (B.x + t * B.sp) % (W + 60) - 30
        drawBird(bx, B.y, B.s, t*4 + B.ph)
    end

    -- 12) 飘落的叶子
    for _, L in ipairs(LEAVES) do
        local ly = ((L.y + t * L.v) % (H + 40)) - 20
        local lx = L.x + math.sin(t * 0.7 + L.a) * 30 * L.w
        local colors = {C.leafGold, C.leafRed, C.leafOrg}
        local col = colors[(L.c % 3) + 1]
        love.graphics.setColor(col[1], col[2], col[3], 0.95)
        -- 叶子形状 (椭圆)
        local rot = L.rot + t * L.vrot
        love.graphics.push()
        love.graphics.translate(lx, ly)
        love.graphics.rotate(rot)
        love.graphics.ellipse("fill", 0, 0, 5*L.s, 2.5*L.s)
        -- 叶柄
        love.graphics.setColor(col[1]*0.6, col[2]*0.6, col[3]*0.6, 0.9)
        love.graphics.line(0, 0, 0, 3*L.s)
        love.graphics.pop()
    end

    -- 13) 顶部信息条 (76px)
    love.graphics.setColor(0,0,0,0.45)
    love.graphics.rectangle("fill", 0, 0, W, 76)
    love.graphics.setColor(0.95,0.65,0.40,0.6)
    love.graphics.rectangle("fill", 0, 75, W, 1)

    love.graphics.setColor(0.98,0.85,0.65,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.03  ·  秋日森林  ·  Autumn Forest", 24, 12)
    love.graphics.setColor(0.95,0.70,0.50,0.95); love.graphics.setFont(subFont)
    love.graphics.print("枫林 · 小径 · 落叶 · 小鹿 · 远山", 24, 48)
    love.graphics.setColor(0.85,0.70,0.55,0.85); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, 48)

    -- 14) 底部
    love.graphics.setColor(0,0,0,0.30); love.graphics.rectangle("fill", 0, H-32, W, 32)
    love.graphics.setColor(0.95,0.75,0.50,0.85); love.graphics.setFont(subFont)
    love.graphics.print("灵感取自秋日欧亚混交林深处的午后", 24, H-23)
end
return M
