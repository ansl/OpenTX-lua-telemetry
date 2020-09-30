---- #########################################################################
---- #                                                                       #
---- # Telemetry Widget script for FrSky Horus                               #
---- # Copyright (C) OpenTX                                                  #
-----#                                                                       #
---- # License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html               #
---- #                                                                       #
---- # This program is free software; you can redistribute it and/or modify  #
---- # it under the terms of the GNU General Public License version 2 as     #
---- # published by the Free Software Foundation.                            #
---- #                                                                       #
---- # This program is distributed in the hope that it will be useful        #
---- # but WITHOUT ANY WARRANTY; without even the implied warranty of        #
---- # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
---- # GNU General Public License for more details.                          #
---- #                                                                       #
---- #########################################################################

-- Horus Widget to display the levels of lipo battery with per cell indication
-- 3djc & Offer Shmuely
-- Date: 2020
-- ver: 0.5
local version = "v0.5"

local _options = {
  { "GPS", SOURCE, 0 }, -- default to 'Cels'
  { "Sats", SOURCE, 0 }, -- default to 'Cels'
  { "pitch", SOURCE, 0 }, -- default to 'Cels'
  { "roll", SOURCE, 0 }, -- default to 'Cels'
  { "yaw", SOURCE, 0 }, -- default to 'Cels'
  { "Color", COLOR, WHITE },
  { "Shadow", BOOL, 0 }
}



local function rnd(v,d)
  if d then
   return math.floor((v*10^d)+0.5)/(10^d)
  else
   return math.floor(v+0.5)
  end
end

local function sign(v)
  if v<0 then
   return -1
  else
   return 0
  end
end

-- local function plot_cockpit_BG(x_c,y_c,x_w,y_w,roll)
  --   --lcd.setColor( CUSTOM_COLOR, lcd.RGB(92, 206, 255) )--blue
  --   lcd.setColor( CUSTOM_COLOR, lcd.RGB(236, 143, 38 ))--brown
  --   lcd.drawFilledRectangle(x_c-math.floor(x_w/2),y_c-math.floor(y_w/2),x_w,y_w,CUSTOM_COLOR)
  --   lcd.setColor( CUSTOM_COLOR, lcd.RGB(0, 0, 0))--black
  --   lcd.drawRectangle(x_c-math.floor(x_w/2),y_c-math.floor(y_w/2),x_w,y_w,SOLID,1)
-- end

-- local function Horizon_BG(P,Y0,x_c,y_c,x_w,y_w,ref_col)
--   if ref_col>0 then
--     lcd.setColor( CUSTOM_COLOR, lcd.RGB(92, 206, 255) )--blue
--     lcd.drawFilledRectangle(x_c-rnd(x_w/2),y_c-rnd(y_w/2),x_w,y_w,CUSTOM_COLOR)
--     lcd.setColor( CUSTOM_COLOR, lcd.RGB(236, 143, 38 ))--brown
--   else
--     lcd.setColor( CUSTOM_COLOR, lcd.RGB(236, 143, 38 ))--brown
--     lcd.drawFilledRectangle(x_c-rnd(x_w/2),y_c-rnd(y_w/2),x_w,y_w,CUSTOM_COLOR)
--     lcd.setColor( CUSTOM_COLOR, lcd.RGB(92, 206, 255) )--blue
--   end

--   local xpos=0


--   for i=0,y_w,1 do
--     if (y_w/2-i-Y0)/P>=rnd(x_w/2) then
--       xpos=rnd(x_w/2)
--     elseif (y_w/2-i-Y0)/P<=rnd(-x_w/2) then
--       xpos=rnd(-1*x_w/2)
--     else
--       xpos=rnd((y_w/2-i-Y0)/P)
--     lcd.drawLine(rnd(-x_w/2)+x_c,rnd(y_w/2-i)+y_c,xpos+x_c,rnd(y_w/2-i)+y_c,SOLID,CUSTOM_COLOR)

--   end
-- end


local function plot_horizon(x_c,y_c,x_w,y_w,roll,pitch,yaw,R)
--pitch_correction

 -- if roll==0 or roll==math.pi then
 --   roll=roll+0.00000001
 -- end
--H0RIZON VARS
 --local R=150
 --local P=math.tan(roll)*math.cos(yaw)/math.cos(pitch)-math.tan(pitch)*math.sin(yaw)
 local P=math.tan(roll)*(math.tan(pitch)*math.cos(yaw)-math.sin(yaw))
 --local Y0=-1*R*(math.tan(roll)*math.sin(yaw)/math.cos(pitch)+math.tan(pitch)*math.cos(yaw))
 local Y0=-1*R*(math.tan(roll)*math.tan(pitch)*math.sin(yaw)*math.sin(roll)+math.tan(roll)*math.cos(yaw)+math.tan(pitch)*math.sin(yaw)*math.cos(roll))
 local ref_horZ=R*(math.cos(roll)*math.sin(pitch)*math.cos(yaw)+math.sin(roll)*math.sin(yaw))-(x_w/2)*(math.cos(roll)*math.sin(pitch)*math.sin(yaw)-math.sin(roll)*math.cos(yaw))+(y_w/2)*math.cos(roll)*math.cos(pitch)


--INTERSECTION POINTS
  local I={}
  local H={}

  H["x"]={}
  H["y"]={}

  I["x"]={}
  I["y"]={}
  I["chk"]={}

  I.x[1]=x_w/2
  I.y[1]=I.x[1]*P+Y0
  if math.abs(I.y[1])<=y_w/2 then  I.chk[1]=1  else I.chk[1]=0   end

  I.x[2]=-1*x_w/2
  I.y[2]=I.x[2]*P+Y0
  if math.abs(I.y[2])<=y_w/2 then  I.chk[2]=1  else I.chk[2]=0   end

  I.y[3]=y_w/2
  I.x[3]=(I.y[3]-Y0)/P
  if math.abs(I.x[3])<=x_w/2 then  I.chk[3]=1  else I.chk[3]=0   end

  I.y[4]=-1*y_w/2
  I.x[4]=(I.y[4]-Y0)/P
  if math.abs(I.x[4])<=x_w/2 then  I.chk[4]=1  else I.chk[4]=0   end

  --Final HOrizon

  local j=1
  local h_check=0
  for i=1,4,1 do
    if I.chk[i]==1 then
      H.x[j]=I.x[i]
      H.y[j]=I.y[i]
      j=j+1
    end
    h_check=h_check+I.chk[i]
  end
  if h_check==2 then
    --Horizon_BG(P,Y0,x_c,y_c,x_w,y_w,ref_horZ)
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(0, 0, 0))
    lcd.drawLine(math.floor(H.x[1]+x_c),math.floor(H.y[1]+y_c),math.floor(H.x[2]+x_c),math.floor(H.y[2]+y_c),SOLID,CUSTOM_COLOR)

    lcd.drawText(50,210,rnd(H.x[1],4),SMLSIZE)
    lcd.drawText(50,220,rnd(H.y[1],4),SMLSIZE)
    lcd.drawText(150,210,rnd(H.x[2],4),SMLSIZE)
    lcd.drawText(150,220,rnd(H.y[2],4),SMLSIZE)
    lcd.drawText(200,210,rnd(P,4),SMLSIZE)
    lcd.drawText(200,220,rnd(Y0,4),SMLSIZE)

  end

end

local function plot_cockpit_level(x_c,y_c,x_w)
  --lcd.setColor( CUSTOM_COLOR, lcd.RGB(92, 206, 255) )--blue
  --lcd.setColor( CUSTOM_COLOR, lcd.RGB(236, 143, 38 ))--brown
  lcd.setColor( CUSTOM_COLOR, lcd.RGB(0, 0, 0))--black
  --lcd.drawLine(x_c-math.floor(x_w/2),y_c,x_c-math.floor(x_w/5),y_c,SOLID,CUSTOM_COLOR)

  lcd.drawLine(x_c-math.floor(x_w/2),y_c,x_c-math.floor(x_w/10),y_c,SOLID,CUSTOM_COLOR)
  lcd.drawLine(x_c+math.floor(x_w/2),y_c,x_c+math.floor(x_w/10),y_c,SOLID,CUSTOM_COLOR)

  lcd.drawLine(x_c-math.floor(x_w/10),y_c,x_c,y_c+math.floor(x_w/10),SOLID,CUSTOM_COLOR)
  lcd.drawLine(x_c+math.floor(x_w/10),y_c,x_c,y_c+math.floor(x_w/10),SOLID,CUSTOM_COLOR)

  lcd.setColor( CUSTOM_COLOR, lcd.RGB(255, 0, 0 ))
  lcd.drawLine(x_c-1,y_c,x_c+1,y_c,SOLID,CUSTOM_COLOR)
  lcd.drawPoint(x_c,y_c+1,CUSTOM_COLOR)
  lcd.drawPoint(x_c,y_c-1,CUSTOM_COLOR)
 
end

-- This function is run once at the creation of the widget
local function create(zone, options)
  local wgt = {
    zone = zone,
    options = options,
    shadowed = 0
  }

  if wgt.options.GPS == 0 then
    wgt.options.GPS = "GPS"
  end
  if wgt.options.Sats == 0 then
    wgt.options.Sats = "Sats"
  end
  if wgt.options.yaw == 0 then
    wgt.options.yaw = "Ptch"
  end
  if wgt.options.yaw == 0 then
    wgt.options.yaw = "Roll"
  end
  if wgt.options.yaw == 0 then
    wgt.options.yaw = "Yaw"
  end

  return wgt
end


-- This function allow updates when you change widgets settings
local function update(wgt, options)
  wgt.options=options
end

local function background(wgt)

end

local function refresh(wgt)

  gpsLatLon = getValue(wgt.options.GPS)
  gpsSats=getValue(wgt.options.Sats)
  v_Pitch=getValue(wgt.options.pitch)
  v_Roll=getValue(wgt.options.roll)
  v_Yaw=getValue(wgt.options.yaw)
  local gpsValue="Unknown"

  --lcd.clear()
  lcd.drawText(wgt.zone.x+10, wgt.zone.y+10, "GPS",0)
  if (type(gpsLatLon) == "table") then
    gpsValue = rnd(gpsLatLon["lat"],4) .. ", " .. rnd(gpsLatLon["lon"],4)
    lcd.drawNumber(wgt.zone.x+10+16*3, wgt.zone.y+10,gpsSats,0)
    lcd.drawText(wgt.zone.x+10, wgt.zone.y+30, gpsValue,0)
  else
    lcd.drawNumber(wgt.zone.x+10+16*3, wgt.zone.y+10,gpsSats,SHADOWED)
    lcd.drawText(wgt.zone.x+10, wgt.zone.y+30, gpsValue,SHADOWED)
  end

  --plot_cockpit_BG(wgt.zone.x+math.floor(wgt.zone.w*0.5),wgt.zone.y+math.floor(wgt.zone.h*0.5),math.floor(wgt.zone.w*0.5),math.floor(wgt.zone.h*0.8),v_Roll)
  plot_cockpit_level(wgt.zone.x+math.floor(wgt.zone.w/2),wgt.zone.y+math.floor(wgt.zone.h/2),math.floor(wgt.zone.w*0.5))
  plot_horizon(wgt.zone.x+math.floor(wgt.zone.w*0.5),wgt.zone.y+math.floor(wgt.zone.h*0.5),math.floor(wgt.zone.w*0.5),math.floor(wgt.zone.h*0.8),v_Roll,v_Pitch,v_Yaw,150)
  --lcd.drawNumber(wgt.zone.x+10, wgt.zone.y+50, v_Yaw,PREC2)
  if (v_Pitch~=nil) then
    lcd.drawText(wgt.zone.x+10, wgt.zone.y+50,rnd(v_Pitch,4),0)
    lcd.drawText(wgt.zone.x+10, wgt.zone.y+70,rnd(v_Roll,4),0)
    lcd.drawText(wgt.zone.x+10, wgt.zone.y+90,rnd(v_Yaw,4),0)
  end
end

return { name = "ANSL_Tel", options = _options, create = create, update = update, background = background, refresh = refresh }



