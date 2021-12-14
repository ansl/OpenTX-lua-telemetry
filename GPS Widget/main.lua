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

local dlSRC=0
local pic=Bitmap.open("/IMAGES/sats_s.png")

local _options = {
  { "Sats", SOURCE, 0 }, -- default to 'Cels'
  { "GPS", SOURCE, 0 }, -- default to 'Cels'
  { "FMode", SOURCE, 0 }, -- default to 'Cels'
}
--##########################################################################
--LOCAL FUNCTIONS
--##########################################################################

  local function NILV(val,ret)
      if val==nil then
        return ret
      else 
        return val
      end
   end
   local function get_DOWNLINK_STATUS(wgt)
    --local val=getValue(dlSRC)
     wgt.DOWNLINK_STATUS=NILV(getValue(dlSRC),0)
     --if  wgt.DOWNLINK_STATUS==0 then wgt.GEN_PRINT_FLAG=INVERS + BLINK else wgt.GEN_PRINT_FLAG=0 end
   end
   local function get_telemetry(wgt)
    get_DOWNLINK_STATUS(wgt)
    if wgt.DOWNLINK_STATUS==0 then
    
     wgt.SATS.COUNT="-"
     wgt.FMode="NO TLMTR"
     wgt.SATS.PRINT_FLAG=DARKRED + BLINK

      --if(getValue(wgt.options.Sats)<4
    else

        wgt.SATS.COUNT=NILV(getValue(wgt.options.Sats),"-")
        wgt.FMode=NILV(getValue(wgt.options.FMode),"NO TLMTR")
        if(getValue(wgt.options.Sats)<4) then
          wgt.SATS.PRINT_FLAG=ORANGE + BLINK
        else
          wgt.SATS.PRINT_FLAG=COLOR_THEME_PRIMARY2
        end

    end

    --GPS
    if type(getValue(wgt.options.GPS))==("table") then
        wgt.GPS= getValue(wgt.options.GPS)
        wgt.GPS.PRINT_FLAG=COLOR_THEME_PRIMARY2
    else wgt.GPS.PRINT_FLAG=DARKRED + BLINK
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
    SATS={
        COUNT="-",
        PRINT_FLAG=DARKRED + BLINK
    },
    GPS={
        lat="NO DATA",
        lon="NO DATA",
        PRINT_FLAG=DARKRED + BLINK
    },
    FMode="NO TLMTR",
    DOWNLINK_STATUS=0
  }

  if wgt.options.GPS == 0 then
    --  wgt.options.GPS = getFieldInfo('GPS').id
    wgt.options.GPS = "GPS"
  end
  if wgt.options.Sats == 0 then
    --  wgt.options.GPS = getFieldInfo('GPS').id
    wgt.options.Sats = "Sats"
  end
  if wgt.options.FMode == 0 then
    --  wgt.options.FMode = getFieldInfo('FM').id
    wgt.options.FMode="FM"
  end
  dlSRC = getFieldInfo('TQly').id
  return wgt
end
-- This function allow updates when you change widgets settings
local function update(wgt, options)
  wgt.options=options
  if wgt.options.GPS == 0 then
    --  wgt.options.GPS = getFieldInfo('GPS').id
    wgt.options.GPS = "GPS"
  end
  if wgt.options.Sats == 0 then
    --  wgt.options.GPS = getFieldInfo('GPS').id
    wgt.options.Sats = "Sats"
  end
  if wgt.options.FMode == 0 then
    --  wgt.options.GPS = getFieldInfo('GPS').id
    wgt.options.FMode = "FM"
  end
end

--- Zone size: 70x39 1/8th top bar
local function refreshZoneTiny(wgt)
    get_telemetry(wgt)
    lcd.drawBitmap(pic,wgt.zone.x+5,wgt.zone.y+2)
    lcd.drawText(wgt.zone.x + 27, wgt.zone.y +0 , wgt.SATS.COUNT, LEFT + MIDSIZE + wgt.SATS.PRINT_FLAG)
    lcd.drawText(wgt.zone.x + 5, wgt.zone.y +24, wgt.FMode, LEFT + SMLSIZE + wgt.SATS.PRINT_FLAG)
  end
  
  --- Zone size: 160x32 1/8th
  local function refreshZoneSmall(wgt)
   
  end
  
  --- Zone size: 180x70 1/4th  (with sliders/trim)
  --- Zone size: 225x98 1/4th  (no sliders/trim)
  local function refreshZoneMedium(wgt)
  
  end
  
  --- Zone size: 192x152 1/2
  local function refreshZoneLarge(wgt)
   
  end
  
  local function refreshFullScreenImpl(wgt, x, w, y, h)
  
  end
  
  --- Zone size: 390x172 1/1
  --- Zone size: 460x252 1/1 (no sliders/trim/topbar)
  local function refreshZoneXLarge(wgt)
   
  end
    
  --- Zone size: 460x252 (full screen app mode)
  local function refreshFullScreen(wgt, event, touchState)
    
  end

local function background(wgt)

end

local function refresh(wgt)
  
    if (event ~= nil) then
        refreshFullScreen(wgt, event, touchState)
      elseif wgt.zone.w > 380 and wgt.zone.h > 165 then   refreshZoneXLarge(wgt)
      elseif wgt.zone.w > 180 and wgt.zone.h > 145 then   refreshZoneLarge(wgt)
      elseif wgt.zone.w > 170 and wgt.zone.h > 65 then    refreshZoneMedium(wgt)
      elseif wgt.zone.w > 150 and wgt.zone.h > 28 then    refreshZoneSmall(wgt)
      elseif wgt.zone.w > 65 and wgt.zone.h > 35 then
        refreshZoneTiny(wgt)
      end
end

return { name = "GPS WIDGET", options = _options, create = create, update = update, background = background, refresh = refresh }

