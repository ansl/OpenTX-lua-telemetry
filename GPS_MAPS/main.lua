---- #########################################################################
---- #                                                                       #
---- # Telemetry Widget script for TX16S with TBS Crossfire                  #
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


-- Date: 2020
-- ver: 0.1
local version = "v0.1"
local tile_size=256
local SHADOW=1048576
local BLNK=3
local SML_FONT=256

local dlSRC=0


local _options = {
  { "Sats", SOURCE, 0 }, -- default to 'Cels'
  { "GPS", SOURCE, 0 }, -- default to 'Cels'
  { "zoom", SOURCE, 0 }, -- default to 'Cels'
  { "Alt", SOURCE, 0 }, -- default to 'Cels'
  --{ "dlSRC" , SOURCE , 0 },
  { "FMode" , SOURCE , 0 }
}

--##########################################################################
--LOCAL FUNCTIONS
--##########################################################################
local function rnd(v,d)
  if type(v)=="number" then
    if d then
     return math.floor((v*10^d)+0.5)/(10^d)
    else
     return math.floor(v+0.5)
    end
  else
    return v
  end
 end
local function NILV(val,ret)
    if val==nil then
      return ret
    else 
      return val
    end
 end
local function file_found(file_name)
  local f=io.open(file_name, "r")      
  if f==nil then
    return false
  else
    io.close(f)
    return true
  end
 end
local function circle(xCenter, yCenter, radius,flags)
    local y, x
    for y=-radius, radius do
      for x=-radius, radius do
        if(x*x+y*y <= radius*radius) then
        lcd.drawPoint(xCenter+x, yCenter+y,flags)
        end
      end
    end
 end

local function latlon_tile(DR,wgt,map_ref)
    if type(DR.GPS_COORDS.curr.lat)=="number" then
      local siny=math.sin(math.rad(DR.GPS_COORDS.curr.lat))
      local scale=math.pow(2,wgt.ZOOM)
      local x_pixCoor=tile_size*(0.5+DR.GPS_COORDS.curr.lon/360)*scale
      local y_pixCoor=tile_size*(0.5-math.log((1+siny)/(1-siny))/(4*math.pi))*scale
      local x_tilePixelCoor=math.fmod( x_pixCoor,tile_size )
      local y_tilePixelCoor=math.fmod( y_pixCoor,tile_size )
      local x_tileCoor=x_pixCoor/tile_size
      local y_tileCoor=y_pixCoor/tile_size
      
      if map_ref then
        local tile_path="/IMAGES/MAPS/"..tostring(17-wgt.ZOOM).."_"..tostring(math.floor(x_tileCoor/1024,1)).."_"..tostring(math.floor(x_tileCoor-math.floor(x_tileCoor/1024,1)*1024)).."_"..tostring(math.floor(y_tileCoor/1024,1)).."_"..tostring(math.floor(y_tileCoor-math.floor(y_tileCoor/1024,1)*1024))..".png"
        if not(file_found(tile_path)) then
          tile_path=wgt.TILE.no_tile_path
        end
        wgt.TILE.curr_tile_path=tile_path
      end
        DR.TCoor.curr.X=x_tileCoor
        DR.TCoor.curr.Y=y_tileCoor
        DR.PCoor.curr.X=x_pixCoor
        DR.PCoor.curr.Y=y_pixCoor
        DR.TPCoor.curr.X=x_tilePixelCoor
        DR.TPCoor.curr.Y=y_tilePixelCoor
      --return tile_path,math.floor(x_tileCoor,1),math.floor(y_tileCoor,1),math.floor(x_pixCoor,1),math.floor(y_pixCoor,1),x_tilePixelCoor,y_tilePixelCoor
    end
 end

local function get_DOWNLINK_STATUS(wgt)
  --local val=getValue(dlSRC)
   wgt.DOWNLINK_STATUS=NILV(getValue(dlSRC),0)
   if  wgt.DOWNLINK_STATUS==0 then wgt.GEN_PRINT_FLAG=SHADOW else wgt.GEN_PRINT_FLAG=0 end
 end

local function update_var(wgt)
  wgt.DRONE.GPS_COORDS.prev=wgt.DRONE.GPS_COORDS.curr
  wgt.DRONE.TCoor.prev=wgt.DRONE.TCoor.curr
  wgt.DRONE.PCoor.prev=wgt.DRONE.PCoor.curr
  wgt.DRONE.TPCoor.prev=wgt.DRONE.TPCoor.curr
  wgt.TILE.prev_tile_path=wgt.TILE.curr_tile_path
 end
local function get_telemetry(wgt)
  --ZOOM
  wgt.ZOOM=17-rnd(2*NILV(getValue(wgt.options.zoom),0)/1024)
  --FM
  local FM_raw=NILV(getValue(wgt.options.FMode),"NO DATA")
    wgt.DRONE.FM=string.match(FM_raw,"%w*")
  if NILV(string.find(FM_raw,0),0)>0 then 
      wgt.DRONE.ARM="ARMED"
      wgt.GEN_PRINT_FLAG=0
    else 
      wgt.DRONE.ARM="DISARMED"
      wgt.GEN_PRINT_FLAG=SHADOW
  end

  --SATS
  wgt.DRONE.SATS.COUNT=NILV(getValue(wgt.options.Sats),"NO DATA")
  if wgt.DRONE.SATS.COUNT<5 then wgt.DRONE.SATS.SATS_PRINT_FLAG=BLNK else wgt.DRONE.SATS.SATS_PRINT_FLAG=0 end

  --GPS
  if type(getValue(wgt.options.GPS))==("table") then
    wgt.DRONE.GPS_COORDS.curr = getValue(wgt.options.GPS)
    wgt.DRONE.GPS_COORDS.GPS_PRINT_FLAG=0
  else wgt.DRONE.GPS_COORDS.GPS_PRINT_FLAG=SHADOW
  end
  latlon_tile(wgt.DRONE,wgt,true)

  --HDG
  if wgt.DRONE.PCoor.curr~=wgt.DRONE.PCoor.prev then
    wgt.DRONE.HDG=rnd(math.atan2((wgt.DRONE.PCoor.curr.Y-wgt.DRONE.PCoor.prev.Y)/(wgt.DRONE.PCoor.curr.X-wgt.DRONE.PCoor.prev.X)),3)
  end

  --ALT
  wgt.DRONE.ALT=NILV(getValue(wgt.options.Alt),"NO DATA")

  --HOME

  return
 end

local function GPS_MAP_PLOT(wgt,x,y)
  --if (type(wgt.DRONE.GPS_COORDS.curr) == "table") then
    if (wgt.TILE.prev_tile_path~=wgt.TILE.curr_tile_path or wgt.init_flag==true) then
      wgt.TILE.tile=Bitmap.open(wgt.TILE.curr_tile_path)
      wgt.init_flag=false
    end
    --if(wgt.DRONE.PCoor.curr~=wgt.DRONE.PCoor.prev or wgt.init_flag==false) then
      lcd.drawBitmap(wgt.TILE.tile,x,y)
    --end
  --end
 end

local function GPS_DRONE_PLOT(wgt,x,y)
    --if (wgt.DRONE.PCoor.curr.X~=0) and ( wgt.DRONE.TPCoor.curr~=wgt.DRONE.TPCoor.prev) then
    local R={
            {    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,255,0,0,255,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,255,0,0,255,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,48,69,61,30,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,54,158,171,39,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,57,216,234,46,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,15,125,219,237,126,28,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,0,28,81,222,219,237,222,85,45,0,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,0,30,159,237,103,219,237,103,219,149,43,0,255,255,255,255,255,255},
            {    255,255,255,255,255,23,55,213,237,237,71,219,237,71,219,219,197,64,39,255,255,255,255,255},
            {    255,255,255,0,27,126,236,237,237,237,71,219,237,71,219,219,219,218,122,41,0,255,255,255},
            {    255,255,15,11,183,237,237,237,237,237,71,219,237,71,219,219,219,219,219,169,14,28,255,255},
            {    0,25,94,82,215,237,237,237,237,237,71,219,237,71,219,219,219,219,219,198,76,97,39,0},
            {    33,172,237,88,215,237,237,237,237,237,71,219,237,71,219,219,219,219,219,198,82,219,161,52},
            {    48,237,237,88,215,237,237,237,237,237,198,219,237,198,219,219,219,219,219,198,82,219,219,62},
            {    47,237,237,88,198,180,136,84,48,35,73,211,229,71,47,58,90,131,208,198,82,219,219,63},
            {    28,96,52,13,30,28,0,0,0,255,20,47,37,12,255,0,0,0,174,78,18,61,99,40},
            {    0,0,0,0,0,255,255,255,255,0,0,0,0,0,0,255,255,255,255,0,0,0,0,0},
            {    255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255}
      }
    local G={
            {    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,255,0,0,255,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,255,0,0,255,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,46,69,60,30,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,54,156,169,39,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,57,214,232,46,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,15,124,217,235,125,28,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,0,28,80,220,217,235,220,84,45,0,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,0,30,157,235,102,217,235,102,217,147,42,0,255,255,255,255,255,255},
            {    255,255,255,255,255,21,55,211,235,235,70,217,235,70,217,217,195,63,39,255,255,255,255,255},
            {    255,255,255,0,26,125,234,235,235,235,70,217,235,70,217,217,217,216,121,41,0,255,255,255},
            {    255,255,15,11,182,235,235,235,235,235,70,217,235,70,217,217,217,217,217,168,14,28,255,255},
            {    0,24,93,81,213,235,235,235,235,235,70,217,235,70,217,217,217,217,217,197,75,95,39,0},
            {    33,171,235,88,213,235,235,235,235,235,70,217,235,70,217,217,217,217,217,197,81,217,159,50},
            {    48,235,235,88,213,235,235,235,235,235,197,217,235,197,217,217,217,217,217,197,81,217,217,62},
            {    47,235,235,88,196,179,135,84,46,35,72,209,227,70,46,58,89,129,206,196,81,217,217,63},
            {    28,95,51,13,29,28,0,0,0,255,20,46,37,12,255,0,0,0,174,78,18,60,98,40},
            {    0,0,0,0,0,255,255,255,255,0,0,0,0,0,0,255,255,255,255,0,0,0,0,0},
            {    255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255}
      }
    local B={
            {255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,255,0,0,255,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,255,0,0,255,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,48,69,61,30,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,54,158,171,39,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,57,217,234,46,255,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,15,126,220,237,126,28,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,0,28,81,222,220,237,222,85,45,0,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,0,30,159,237,103,220,237,103,220,149,43,0,255,255,255,255,255,255},
            {    255,255,255,255,255,23,55,213,237,237,71,220,237,71,220,220,198,64,39,255,255,255,255,255},
            {    255,255,255,0,27,126,236,237,237,237,71,220,237,71,220,220,220,219,123,41,0,255,255,255},
            {    255,255,15,11,183,237,237,237,237,237,71,220,237,71,220,220,220,220,220,170,14,28,255,255},
            {    0,25,94,82,215,237,237,237,237,237,71,220,237,71,220,220,220,220,220,199,76,98,39,0},
            {    33,172,237,88,215,237,237,237,237,237,71,220,237,71,220,220,220,220,220,199,82,220,161,52},
            {    48,237,237,88,215,237,237,237,237,237,198,220,237,198,220,220,220,220,220,199,82,220,220,63},
            {    47,237,237,88,198,180,136,84,48,35,73,212,229,71,47,59,90,131,209,198,82,220,220,63},
            {    28,96,52,13,30,28,0,0,0,255,20,47,37,12,255,0,0,0,177,78,18,61,100,40},
            {    0,0,0,0,0,255,255,255,255,0,0,0,0,0,0,255,255,255,255,0,0,0,0,0},
            {    255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255},
            {    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255}
      }
    local A={ {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,32,146,182,182,146,32,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,65,181,45,1,1,45,181,65,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,7,4,95,177,177,95,4,12,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,9,75,8,8,80,9,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,0,125,131,0,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,0,18,18,0,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,106,246,227,95,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,227,255,255,207,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,236,255,255,218,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,86,247,255,255,245,92,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,5,153,235,255,255,255,255,251,169,5,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,41,214,248,255,255,255,255,255,255,255,231,41,0,0,0,0,0,0},
              {0,0,0,0,0,120,231,255,255,255,255,255,255,255,255,255,255,248,130,0,0,0,0,0},
              {0,0,0,25,198,242,255,255,255,255,255,255,255,255,255,255,255,255,254,214,25,0,0,0},
              {0,0,86,246,254,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,251,92,0,0},
              {12,173,236,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,251,188,12},
              {179,250,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,197},
              {229,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,245},
              {231,255,255,255,255,255,247,231,225,219,242,255,255,239,237,243,250,254,255,255,255,255,255,246},
              {231,234,227,241,196,137,77,32,1,0,89,244,228,86,0,1,32,76,69,190,247,245,251,243},
              {47,42,4,35,1,0,0,0,0,19,56,124,124,56,19,0,0,0,0,1,35,4,42,42},
              {0,0,0,0,0,0,0,0,0,58,127,145,145,127,58,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}
    if (wgt.DRONE.PCoor.curr.X~=0) then
      --lcd.drawBitmap(wgt.DRONE.ICON,wgt.DRONE.TPCoor.curr.X+x,wgt.DRONE.TPCoor.curr.Y+y)

      for i=1,24,1
      do
        for j=1,24,1
        do
          if A[i][j]>45 then
            lcd.setColor( CUSTOM_COLOR, lcd.RGB(R[i][j], G[i][j], B[i][j] ))
            lcd.drawPoint(i+x-12,j+y-12,CUSTOM_COLOR)
          end
        end
      end
      --lcd.setColor( CUSTOM_COLOR, lcd.RGB(255, 0, 0 ))

      --circle(wgt.DRONE.TPCoor.curr.X+x, wgt.DRONE.TPCoor.curr.Y+y, 4,CUSTOM_COLOR)
    end
 end

local function GPS_HOME_PLOT(wgt,x,y)
  --if (wgt.HOME.PCoor.curr.X~=0) and (wgt.HOME.TCoor.curr==wgt.DRONE.TCoor.curr) and ( wgt.HOME.TPCoor.curr~=wgt.HOME.TPCoor.prev) then
  if (wgt.HOME.PCoor.curr.X~=0) and (wgt.HOME.TCoor.curr==wgt.DRONE.TCoor.curr)  then
    lcd.drawBitmap(wgt.HOME.ICON,wgt.HOME.TPCoor.curr.X+x,wgt.HOM.TPCoor.curr.Y+y)
  end
 end

--##########################################################################
--MAIN SCRIPT
--##########################################################################


-- This function is run once at the creation of the widget

local function create(zone, options)
  local wgt = {
    zone = zone,
    options = options,
    init_flag=true,
    ZOOM=0,
    TILE={
        TILE_SIZE=tile_size,
        curr_tile_path="/IMAGES/MAPS/WW.png",
        prev_tile_path=0,
        tile=0,
        no_tile_path="/IMAGES/MAPS/NO_TILE.png"
    },
    DOWNLINK_STATUS=0,
    GEN_PRINT_FLAG=SHADOW,

    DRONE={
              FM="NO_DATA",
              ARM="DISARMED",
              SATS={
                COUNT=0,
                SATS_PRINT_FLAG="BLINK"
              },
              GPS_COORDS={
                curr={lat="NO DATA",lon="NO DATA"},
                prev={lat="NO DATA",lon="NO DATA"},
                GPS_PRINT_FLAG=BLNK+SHADOW
              },
              PCoor={
                curr={X=0,Y=0},
                prev={X=0,Y=0}
              },
              TCoor={
                curr={X=0,Y=0},
                prev={X=0,Y=0}
              },
              TPCoor={
                curr={X=0,Y=0},
                prev={X=0,Y=0}
              },
              HDG=0,
              ALT=0,
              ICON=Bitmap.open("/IMAGE/ICONS/DRN.png")
    },

    HOME={
      SATS={
        COUNT=0,
        SATS_PRINT_FLAG="BLINK"
      },
      GPS_COORDS={
        curr={lat="NO DATA",lon="NO DATA"},
        prev={lat="NO DATA",lon="NO DATA"},
        GPS_PRINT_FLAG=BLNK+SHADOW
      },
      PCoor={
        curr={X=0,Y=0},
        prev={X=0,Y=0}
      },
      TCoor={
        curr={X=0,Y=0},
        prev={X=0,Y=0}
      },
      TPCoor={
        curr={X=0,Y=0},
        prev={X=0,Y=0}
      },
      HDG=0,
      ALT=0,
      DIST=0,
      ICON=Bitmap.open("/IMAGE/ICONS/HOME.png")
    }
  }

  if wgt.options.GPS == 0 then
    --  wgt.options.GPS = getFieldInfo('GPS').id
    wgt.options.GPS = "GPS"
  end
  if wgt.options.Sats == 0 then
    -- wgt.options.Sats = getFieldInfo('Sats').id
    wgt.options.Sats = "Sats"
  end
  if wgt.options.zoom == 0 then
    -- wgt.options.zoom = getFieldInfo('S1').id
    wgt.options.zoom = "S1"
  end
  if wgt.options.Alt == 0 then
    --wgt.options.Alt = getFieldInfo('Alt').id
    wgt.options.Alt = "Alt"
  end
  -- if wgt.options.dlSRC == 0 then
  --   -- wgt.options.dlSRC = getFieldInfo("TQly").id
  --   wgt.options.dlSRC="TQly"
  -- end
  if wgt.options.FMode == 0 then
    --  wgt.options.FMode = getFieldInfo('FM').id
    wgt.options.FMode="FM"
  end
    dlSRC = getFieldInfo('TQly').id

   --wgt.TILE.tile=Bitmap.open(wgt.TILE.curr_tile_path)
   --lcd.drawBitmap(wgt.TILE.tile,wgt.zone.w-wgt.TILE.TILE_SIZE,wgt.zone.y)

  return wgt
end
-- This function allow updates when you change widgets settings
local function update(wgt, options)
  wgt.options=options
end

local function background(wgt)
  get_DOWNLINK_STATUS(wgt)
  update_var(wgt)
  get_telemetry(wgt)
end

local function refresh(wgt)


  --lcd.clear()
  --lcd.drawText(wgt.zone.x+100, wgt.zone.y+10, wgt.options.FMode,0)
  get_DOWNLINK_STATUS(wgt)
  update_var(wgt)
  get_telemetry(wgt)
  GPS_MAP_PLOT(wgt,1,1)
  GPS_DRONE_PLOT(wgt,1,1)
  GPS_HOME_PLOT(wgt,1,1)


   lcd.drawText(wgt.zone.x+300, wgt.zone.y, "SAT",0+SMLSIZE)
   lcd.drawText(wgt.zone.x+350, wgt.zone.y+10, wgt.DRONE.SATS.COUNT,wgt.DRONE.SATS.SATS_PRINT_FLAG)
   lcd.drawText(wgt.zone.x+300, wgt.zone.y+30, "LAT",0)
   lcd.drawText(wgt.zone.x+350, wgt.zone.y+30, rnd(wgt.DRONE.GPS_COORDS.curr.lat,5),wgt.DRONE.GPS_COORDS.GPS_PRINT_FLAG)
   lcd.drawText(wgt.zone.x+300, wgt.zone.y+50, "LON",0)
   lcd.drawText(wgt.zone.x+350, wgt.zone.y+50, rnd(wgt.DRONE.GPS_COORDS.curr.lon,5),wgt.DRONE.GPS_COORDS.GPS_PRINT_FLAG)
   lcd.drawText(wgt.zone.x+300, wgt.zone.y+70, "HDG",0)
   lcd.drawText(wgt.zone.x+350, wgt.zone.y+70, rnd(wgt.DRONE.HDG,2),0)
   lcd.drawText(wgt.zone.x+300, wgt.zone.y+90, "ALT",0)
   lcd.drawText(wgt.zone.x+350, wgt.zone.y+90, rnd(wgt.DRONE.ALT,2),wgt.GEN_PRINT_FLAG)
   lcd.drawText(wgt.zone.x+300, wgt.zone.y+110, "ZOM",0)
   lcd.drawNumber(wgt.zone.x+350, wgt.zone.y+110, rnd(wgt.ZOOM,2),wgt.GEN_PRINT_FLAG)

   lcd.drawText(wgt.zone.x+300, wgt.zone.y+140, "TPCOOR",256)
   lcd.drawNumber(wgt.zone.x+340, wgt.zone.y+140, rnd(wgt.DRONE.TPCoor.curr.X,4),wgt.GEN_PRINT_FLAG+256)
   lcd.drawNumber(wgt.zone.x+370, wgt.zone.y+140, rnd(wgt.DRONE.TPCoor.curr.Y,4),wgt.GEN_PRINT_FLAG+256)
   lcd.drawText(wgt.zone.x+300, wgt.zone.y+155, "TCOOR",256)
   lcd.drawNumber(wgt.zone.x+340, wgt.zone.y+155, rnd(wgt.DRONE.TCoor.curr.X,4),wgt.GEN_PRINT_FLAG+256)
   lcd.drawNumber(wgt.zone.x+370, wgt.zone.y+155, rnd(wgt.DRONE.TCoor.curr.Y,4),wgt.GEN_PRINT_FLAG+256)
   lcd.drawText(wgt.zone.x+300, wgt.zone.y+170, "PCOOR",256)
   lcd.drawNumber(wgt.zone.x+340, wgt.zone.y+170, rnd(wgt.DRONE.PCoor.curr.X,4),wgt.GEN_PRINT_FLAG+256)
   lcd.drawNumber(wgt.zone.x+370, wgt.zone.y+170, rnd(wgt.DRONE.PCoor.curr.Y,4),wgt.GEN_PRINT_FLAG+256)

  -- lcd.drawText(wgt.zone.x+300, wgt.zone.y+130, "TCX",0)
  -- lcd.drawNumber(wgt.zone.x+350, wgt.zone.y+130, rnd(wgt.DRONE.TCoor.curr.X,2),0)
  -- lcd.drawText(wgt.zone.x+300, wgt.zone.y+150, "TCY",0)
  -- lcd.drawNumber(wgt.zone.x+350, wgt.zone.y+150, rnd(wgt.DRONE.TCoor.curr.Y,2),0)
  -- lcd.drawText(wgt.zone.x+300, wgt.zone.y+170, "PCX",0)
  -- lcd.drawNumber(wgt.zone.x+350, wgt.zone.y+170, rnd(wgt.DRONE.PCoor.curr.X,2),0)
  -- lcd.drawText(wgt.zone.x+300, wgt.zone.y+190, "PCY",0)
  -- lcd.drawNumber(wgt.zone.x+350, wgt.zone.y+190, rnd(wgt.DRONE.PCoor.curr.Y,2),0)
  -- lcd.drawText(wgt.zone.x+300, wgt.zone.y+210, "TPCX",0)
  -- lcd.drawNumber(wgt.zone.x+350, wgt.zone.y+210, rnd(wgt.DRONE.TPCoor.curr.X,2),0)
  -- lcd.drawText(wgt.zone.x+300, wgt.zone.y+230, "TPCY",0)
  -- lcd.drawNumber(wgt.zone.x+350, wgt.zone.y+230, rnd(wgt.DRONE.TPCoor.curr.Y,2),0)

  --GPS_MAP_PLOT()

    -- local gpsLatLon = getValue(wgt.options.GPS)
  -- local gpsSats=getValue(wgt.options.Sats)
  -- local zoom=17-rnd(2*getValue(wgt.options.zoom)/1024)
  -- local gpsValue="Unknown"
  --   if wgt.prev_tile_path~=wgt.curr_tile_path then
  --     wgt.tile=Bitmap.open(wgt.curr_tile_path)
  --   else
  --   end
  --   --local tile=Bitmap.open(tile_path)
  --   --local sat_png=Bitmap.open("/IMAGES/MAPS/SAT.png")
  --   lcd.drawBitmap(wgt.tile,1,1)
  --   lcd.setColor( CUSTOM_COLOR, lcd.RGB(255, 0, 0 ))
  --   lcd.drawPoint(x_relCoor,y_relCoor,CUSTOM_COLOR)
  --   lcd.drawNumber(wgt.zone.x+10, wgt.zone.y+50, x_relCoor,0)
  --   lcd.drawNumber(wgt.zone.x+10, wgt.zone.y+70, y_relCoor,0)

  -- if (type(gpsLatLon) == "table") then
  --   local tile_path=latlon_tile(gpsLatLon["lat"],gpsLatLon["lon"],zoom,256)
  --   local x_relCoor,y_relCoor=latlon_tile_pos(gpsLatLon["lat"],gpsLatLon["lon"],zoom,256)

  --   local tile=Bitmap.open(tile_path)
  --   lcd.drawBitmap(tile,wgt.zone.w-257,wgt.zone.h-257)
  --   lcd.setColor( CUSTOM_COLOR, lcd.RGB(255, 0, 0 ))
  --   lcd.drawPoint(wgt.zone.w-256+x_relCoor,wgt.zone.h-256+y_relCoor,CUSTOM_COLOR)


  --   -- gpsValue = rnd(gpsLatLon["lat"],4) .. ", " .. rnd(gpsLatLon["lon"],4)
  --   -- lcd.drawText(wgt.zone.x+10, wgt.zone.y+30, gpsValue,0)
   

  -- else
  --   lcd.drawNumber(wgt.zone.x+10+16*3, wgt.zone.y+10,gpsSats,SHADOWED)
  --   lcd.drawText(wgt.zone.x+10, wgt.zone.y+30, gpsValue,SHADOWED)
  -- end

  --plot_cockpit_BG(wgt.zone.x+math.floor(wgt.zone.w*0.5),wgt.zone.y+math.floor(wgt.zone.h*0.5),math.floor(wgt.zone.w*0.5),math.floor(wgt.zone.h*0.8),v_Roll)
   -- if (v_Pitch~=nil) then

  --end
end

return { name = "GPS MAPS", options = _options, create = create, update = update, background = background, refresh = refresh }



