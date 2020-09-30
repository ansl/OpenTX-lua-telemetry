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
  { "Color", COLOR, WHITE },
  { "Shadow", BOOL, 0 }
}

local function create(zone, options)
  local wgt = {
    zone = zone,
    options = options,
    t0=0,
    t1=0,
    i=0
    }
  return wgt

end

local function update(wgt, options)
  wgt.options=options
end

local function background(wgt)

end

local function refresh(wgt)

    
    wgt.t1=getTime()
        lcd.drawText(10,10,wgt.t1)
        lcd.drawText(10,30,wgt.t0)
        --lcd.drawText(10,50,math.pow(2,wgt.i))
        --lcd.drawText(250,125,"flag"..math.pow(2,wgt.i),math.pow(2,wgt.i))
        lcd.drawText(10,50,wgt.i,1048576)
        lcd.drawText(250,125,"flag"..wgt.i,wgt.i)
        if wgt.t1>=wgt.t0+600 then
            wgt.t0=wgt.t1
            wgt.i=wgt.i+1
        end


end

return { name = "FLAG tester", options = _options, create = create, update = update, background = background, refresh = refresh }



--2 INVERS
-- 256 small
-- 512medium
-- 1024normal
-- 2048 bold
-- 16384 vertical
-- 1048576 shadowed