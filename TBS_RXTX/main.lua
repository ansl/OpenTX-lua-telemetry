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

  { "RXTX", BOOL, 0 }, -- default to 'Cels'
  { "RQly_al", VALUE, 0 }, -- default to 'Cels'
  { "TQly_al", VALUE, 0 }, -- default to 'Cels'
  { "RQly_crit", VALUE, 0 }, -- default to 'Cels'
  { "TQly_crit", VALUE, 0 } -- default to 'Cels'
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
    if  wgt.DOWNLINK_STATUS==0 then wgt.GEN_PRINT_FLAG=DARKRED + BLINK else wgt.GEN_PRINT_FLAG=COLOR_THEME_PRIMARY2 end
   end
   
--##########################################################################
--MAIN SCRIPT
--##########################################################################


-- This function is run once at the creation of the widget

local function create(zone, options)
  local wgt = {
    zone = zone,
    options = options,
    DOWNLINK_STATUS=0,
  }
  dlSRC = getFieldInfo('TQly').id
  return wgt
end
-- This function allow updates when you change widgets settings
local function update(wgt, options)
  wgt.options=options

end

--- Zone size: 70x39 1/8th top bar
local function refreshZoneTiny(wgt)
  get_DOWNLINK_STATUS(wgt)
    if wgt.options.RXTX==0 then
        local RFMD=getValue("RFMD")
        if RFMD==0 then RFMD=4 elseif RFMD==1 then RFMD=50 elseif RFMD==2 then RFMD=150 end
        local RQly=getValue("RQly")
        local RSSI=getValue("1RSS")
        if RQly <wgt.options.RQly_al then wgt.GEN_PRINT_FLAG=ORANGE + BLINK  elseif RQly <wgt.options.RQly_crit then wgt.GEN_PRINT_FLAG=DARKRED + BLINK end
        lcd.drawText(wgt.zone.x ,wgt.zone.y +0 ,"RFM:" .. RFMD .."Hz", LEFT + SMLSIZE + wgt.GEN_PRINT_FLAG)
        lcd.drawText(wgt.zone.x ,wgt.zone.y +12 ,"RQly:" .. RQly .."%", LEFT + SMLSIZE + wgt.GEN_PRINT_FLAG)
        lcd.drawText(wgt.zone.x ,wgt.zone.y +24 ,"RSS:" .. RSSI .."dB", LEFT + SMLSIZE + wgt.GEN_PRINT_FLAG)
    else
        local TPWR=getValue("TPWR")
        local TQly=getValue("TQly")
        local TSSI=getValue("TRSS")
        if TQly <wgt.options.TQly_al then wgt.GEN_PRINT_FLAG=ORANGE + BLINK  elseif TQly <wgt.options.TQly_crit then wgt.GEN_PRINT_FLAG=DARKRED + BLINK end
        lcd.drawText(wgt.zone.x ,wgt.zone.y +0 ,"TPW:" .. TPWR .."mW", LEFT + SMLSIZE + wgt.GEN_PRINT_FLAG)
        lcd.drawText(wgt.zone.x ,wgt.zone.y +12 ,"TQly:" .. TQly .."%", LEFT + SMLSIZE + wgt.GEN_PRINT_FLAG)
        lcd.drawText(wgt.zone.x ,wgt.zone.y +24 ,"TSS:" .. TSSI .."dB", LEFT + SMLSIZE + wgt.GEN_PRINT_FLAG)
    end

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

return { name = "TBS_RXTX", options = _options, create = create, update = update, background = background, refresh = refresh }

