-- 风景集 / No.01  雪山酒店  Hotel on the Snow Mountain
local M = { name = "snow_hotel" }
local W, H = 1200, 700
local function lerp(a,b,t) return a + (b-a)*t end
local function rnd(i) return (i * 9301 + 49297) % 233280 / 233280 end

local C = {
    skyTop={0.02,0.04,0.10}, skyMid={0.05,0.08,0.18}, skyHor={0.10,0.14,0.26},
    mtFar={0.13,0.17,0.26}, mtBody={0.20,0.24,0.32}, mtDark={0.12,0.15,0.22},
    snow={0.93,0.95,0.99}, snowS={0.78,0.83,0.92},
    forest={0.04,0.06,0.10},
}

local PEAK = {
    x=W*0.45, y=H*0.18,
    platL=W*0.36, platY=H*0.27, platR=W*0.55,
    footL=W*-0.10, footR=W*0.78, base=H*0.86,
}
local PEAK2 = {
    x=W*0.85, y=H*0.32,
    platL=W*0.78, platY=H*0.40, platR=W*0.93,
    footL=W*0.55, footR=W*1.10, base=H*0.86,
}

local SNOW = {}
for i=1,260 do SNOW[i]={ x=rnd(i), y=rnd(i*7.3), r=1.0+(i%3), s=0.05+(i%5)*0.010 } end

local function drawPeak(p, body, dark, snowCol)
    local x,y = p.x, p.y
    local platL,platY,platR = p.platL,p.platY,p.platR
    local footL,footR,base = p.footL,p.footR,p.base
    love.graphics.setColor(dark[1],dark[2],dark[3],1)
    love.graphics.polygon("fill",{ footL,base, platL-2,platY+4, x,y, platR+2,platY+4, footR,base })
    love.graphics.setColor(body[1],body[2],body[3],1)
    love.graphics.polygon("fill",{ footL,base, x,y, platR+2,platY+4, x+(footR-x)*0.40,platY+(base-platY)*0.55, x+(footR-x)*0.18,platY+(base-platY)*0.75 })
    love.graphics.setColor(0.34,0.38,0.46,1)
    love.graphics.polygon("fill",{ footL,base, x,y, x-(x-footL)*0.25,platY+(base-platY)*0.30, x-(x-footL)*0.55,platY+(base-platY)*0.65 })
    local sBL = x-(x-footL)*0.42
    local sBR = x+(footR-x)*0.38
    local sBY = platY+(base-platY)*0.40
    love.graphics.setColor(snowCol[1],snowCol[2],snowCol[3],1)
    love.graphics.polygon("fill",{ x,y, platL+2,platY+2, sBL,sBY, x,sBY+8, sBR,sBY, platR-2,platY+2 })
    love.graphics.setColor(0.70,0.78,0.88,0.40)
    love.graphics.polygon("fill",{ x,y, platR-2,platY+2, sBR,sBY, x,sBY+8 })
    love.graphics.setColor(0.55,0.62,0.78,0.55)
    love.graphics.line(sBL,sBY, x,sBY+8); love.graphics.line(x,sBY+8, sBR,sBY)
    love.graphics.setColor(0.30,0.34,0.42,0.7)
    love.graphics.line(x,y, footL,base)
end

local function drawHotelOnTop()
    local cx = (PEAK.platL+PEAK.platR)/2
    local platTop = PEAK.platY+4
    local mainW, mainH = 110, 70
    local mx = cx-mainW/2; local my = platTop-mainH
    love.graphics.setColor(0,0,0,0.25)
    love.graphics.polygon("fill",{ mx-2,platTop, mx+mainW+2,platTop, mx+mainW+12,platTop+5, mx-12,platTop+5 })
    love.graphics.setColor(0.14,0.11,0.09,1); love.graphics.rectangle("fill",mx,my,mainW,mainH)
    love.graphics.setColor(0.22,0.16,0.11,1); love.graphics.rectangle("fill",mx,my+mainH*0.5,mainW,4)
    love.graphics.setColor(0.12,0.10,0.08,1); love.graphics.polygon("fill",{ mx-8,my, cx,my-30, mx+mainW+8,my })
    love.graphics.setColor(0.97,0.98,1.0,1); love.graphics.polygon("fill",{ mx-7,my+1, cx,my-29, mx+mainW+7,my+1 })
    love.graphics.setColor(0.10,0.08,0.06,1); love.graphics.rectangle("fill",mx+mainW-15,my-22,8,22)
    love.graphics.setColor(0.95,0.97,1.0,1); love.graphics.rectangle("fill",mx+mainW-15,my-22,8,2)
    for k=0,3 do
        local t=love.timer.getTime()
        love.graphics.setColor(1,1,1,0.18-k*0.04)
        love.graphics.circle("fill",mx+mainW-11+math.sin(t*0.5+k*0.7)*1.5, my-26-k*7-4, 4+k)
    end
    local winW,winH,gap = 14,16,4
    local cols,rows = 4,3
    local gx = mx+(mainW-cols*(winW+gap)+gap)/2
    for i=0,cols-1 do for j=0,rows-1 do
        local wx=gx+i*(winW+gap); local wy=my+10+j*(winH+gap)
        love.graphics.setColor(1.0,0.80,0.48,0.9); love.graphics.rectangle("fill",wx,wy,winW,winH)
        love.graphics.setColor(0.05,0.04,0.03,1); love.graphics.rectangle("line",wx,wy,winW,winH)
        love.graphics.line(wx+winW/2,wy, wx+winW/2,wy+winH)
        love.graphics.line(wx,wy+winH/2, wx+winW,wy+winH/2)
    end end
    love.graphics.setColor(1.0,0.85,0.55,1); love.graphics.rectangle("fill",cx-22,my-12,44,10)
    love.graphics.setColor(0.05,0.04,0.03,1); love.graphics.rectangle("line",cx-22,my-12,44,10)
    love.graphics.setColor(1.0,0.92,0.65,1); love.graphics.print("HOTEL",cx-20,my-11)
    local lW,lH=50,40; local lx=mx-lW-8; local ly=platTop-lH
    love.graphics.setColor(0.10,0.08,0.06,1); love.graphics.rectangle("fill",lx,ly,lW,lH)
    love.graphics.setColor(0.12,0.10,0.08,1); love.graphics.polygon("fill",{ lx-4,ly, lx+lW/2,ly-18, lx+lW+4,ly })
    love.graphics.setColor(0.96,0.97,1.0,1); love.graphics.polygon("fill",{ lx-3,ly+1, lx+lW/2,ly-17, lx+lW+3,ly+1 })
    for i=0,2 do
        love.graphics.setColor(1.0,0.80,0.48,0.9); love.graphics.rectangle("fill",lx+6+i*13,ly+8,8,12)
        love.graphics.setColor(0.05,0.04,0.03,1); love.graphics.rectangle("line",lx+6+i*13,ly+8,8,12)
    end
    local rW,rH=36,60; local rx=mx+mainW+8; local ry=platTop-rH
    love.graphics.setColor(0.10,0.08,0.06,1); love.graphics.rectangle("fill",rx,ry,rW,rH)
    love.graphics.setColor(0.13,0.10,0.08,1); love.graphics.polygon("fill",{ rx-3,ry, rx+rW/2,ry-12, rx+rW+3,ry })
    love.graphics.setColor(0.96,0.97,1.0,1); love.graphics.polygon("fill",{ rx-2,ry+1, rx+rW/2,ry-11, rx+rW+2,ry+1 })
    love.graphics.setColor(0.12,0.10,0.08,1); love.graphics.rectangle("fill",rx+rW/2-4,ry-30,8,18)
    love.graphics.setColor(0.14,0.11,0.09,1); love.graphics.polygon("fill",{ rx+rW/2-5,ry-30, rx+rW/2,ry-42, rx+rW/2+5,ry-30 })
    love.graphics.setColor(0.96,0.97,1.0,1); love.graphics.polygon("fill",{ rx+rW/2-4,ry-29, rx+rW/2,ry-41, rx+rW/2+4,ry-29 })
    love.graphics.setColor(1.0,0.95,0.78,1); love.graphics.circle("fill",rx+rW/2,ry-22,4)
    love.graphics.setColor(0.05,0.04,0.03,1); love.graphics.circle("line",rx+rW/2,ry-22,4)
    local ang=(love.timer.getTime()*0.05)%(math.pi*2)
    love.graphics.line(rx+rW/2,ry-22, rx+rW/2+math.cos(ang)*3, ry-22+math.sin(ang)*3)
    for i=0,1 do
        love.graphics.setColor(1.0,0.80,0.48,0.9); love.graphics.rectangle("fill",rx+6,ry+10+i*18,9,12)
        love.graphics.setColor(0.05,0.04,0.03,1); love.graphics.rectangle("line",rx+6,ry+10+i*18,9,12)
        love.graphics.rectangle("fill",rx+rW-15,ry+10+i*18,9,12); love.graphics.rectangle("line",rx+rW-15,ry+10+i*18,9,12)
    end
    love.graphics.setColor(0.10,0.08,0.06,1); love.graphics.rectangle("fill",lx-2,ly-30,1.5,14)
    love.graphics.setColor(0.85,0.30,0.25,1); love.graphics.polygon("fill",{ lx-0.5,ly-30, lx+8,ly-27, lx-0.5,ly-24 })
    love.graphics.setColor(1.0,0.85,0.55,0.12); love.graphics.circle("fill",cx,platTop-20,90)
    love.graphics.setColor(1.0,0.85,0.55,0.07); love.graphics.circle("fill",cx,platTop-20,150)
end

function M.draw(titleFont, subFont)
    local tnow = love.timer.getTime()
    -- 夜空
    for i=0,60 do
        local p=i/60
        love.graphics.setColor(lerp(C.skyTop[1],C.skyHor[1],p), lerp(C.skyTop[2],C.skyHor[2],p), lerp(C.skyTop[3],C.skyHor[3],p), 1)
        love.graphics.rectangle("fill", 0, i*(H/60), W, H/60+1)
    end
    -- 月
    local mx,my = W*0.86, H*0.16
    for k=5,1,-1 do love.graphics.setColor(0.98,0.95,0.85,0.06*k); love.graphics.circle("fill",mx,my,18+k*8) end
    love.graphics.setColor(0.98,0.95,0.85,1); love.graphics.circle("fill",mx,my,22)
    love.graphics.setColor(0.78,0.74,0.65,1)
    love.graphics.circle("fill",mx-7,my-4,4); love.graphics.circle("fill",mx+9,my+4,5); love.graphics.circle("fill",mx+2,my+9,3)
    -- 星
    local t = love.timer.getTime()
    for i=1,130 do
        local x=rnd(i*3.1)*W; local y=rnd(i*7.7)*H*0.7
        local tw=0.5+0.5*math.sin(t*0.6+i)
        love.graphics.setColor(0.85,0.92,1.0,0.25+0.45*tw); love.graphics.circle("fill",x,y,1.2)
    end
    -- 远山
    for i=0,9 do
        local p=i/9
        local x=(W*-0.05)+p*(W*1.10)+(i%3-1)*30
        local top=H*0.55+(i%4-2)*12
        love.graphics.setColor(0.10,0.14,0.22,0.6); love.graphics.polygon("fill",{ x-60,H*0.86, x,top, x+60,H*0.86 })
    end
    -- 山
    drawPeak(PEAK2, C.mtFar, C.mtDark, C.snowS)
    drawPeak(PEAK, C.mtBody, C.mtDark, C.snow)
    -- 树
    local baseY=H*0.86
    for i=0,60 do
        local p=i/60; local x=lerp(-10,W+10,p)+(i%5-2)*4; local h=10+(i%5)*3
        love.graphics.setColor(C.forest[1],C.forest[2],C.forest[3],0.95)
        love.graphics.polygon("fill",{ x,baseY-h, x-4,baseY, x+4,baseY })
    end
    -- 雪原
    for i=0,8 do
        local p=i/8
        love.graphics.setColor(lerp(0.82,0.90,p), lerp(0.86,0.93,p), lerp(0.94,0.99,p), 1)
        love.graphics.rectangle("fill", 0, baseY+i*(H*0.04/8), W, H*0.04/8+1)
    end
    for i=0,8 do
        local p=i/8
        love.graphics.setColor(lerp(0.92,0.98,p), lerp(0.95,0.99,p), lerp(0.99,1.0,p), 1)
        love.graphics.rectangle("fill", 0, H*0.90+i*(H*0.04/8), W, H*0.04/8+1)
    end
    love.graphics.setColor(0.98,0.99,1.0,1); love.graphics.rectangle("fill", 0, H*0.94, W, H*0.06)
    -- 雪堆
    love.graphics.setColor(0.94,0.96,1.0,1)
    love.graphics.polygon("fill",{ W*0.00,H*0.95, W*0.08,H*0.92, W*0.18,H*0.95, 0,H })
    love.graphics.polygon("fill",{ W*0.82,H*0.95, W*0.90,H*0.93, W*1.00,H*0.95, W,H })
    -- 酒店
    drawHotelOnTop()
    -- 山顶光
    love.graphics.setColor(1.0,0.85,0.55,0.18); love.graphics.circle("fill",(PEAK.platL+PEAK.platR)/2, PEAK.platY+20, 110)
    -- 脚印
    for i=0,18 do
        love.graphics.setColor(0.78,0.83,0.92,0.55)
        love.graphics.circle("fill", W*0.18+i*8, H*0.95-i*1.0, 1)
    end
    -- 飘雪
    for _,s in ipairs(SNOW) do
        local x=s.x*W; local y=((s.y+tnow*s.s*0.05)%1.0)*H
        love.graphics.setColor(1,1,1,0.78); love.graphics.circle("fill",x,y,s.r)
    end
    -- 标题
    love.graphics.setColor(0,0,0,0.45); love.graphics.rectangle("fill", 0, H-72, W, 72)
    love.graphics.setColor(0.95,0.80,0.45,0.6); love.graphics.rectangle("fill", 0, H-72, W, 1)
    love.graphics.setColor(0.98,0.93,0.78,1); love.graphics.setFont(titleFont)
    love.graphics.print("No.01  ·  雪山酒店  ·  Hotel on the Snow Mountain", 24, H-58)
    love.graphics.setColor(0.78,0.85,0.95,0.85); love.graphics.setFont(subFont)
    love.graphics.print("灵感取自阿加莎·克里斯蒂《大雪中的山庄》", 24, H-22)
    love.graphics.setColor(0.78,0.85,0.95,0.80); love.graphics.setFont(subFont)
    love.graphics.print("← / → 切换场景    ·    Esc 退出", W-300, H-22)
end
return M
