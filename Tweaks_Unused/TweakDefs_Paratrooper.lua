--Paratroopers (Zop)
local uDefs = UnitDefs or {}
local cps = 'customparams'

for id, def in pairs(uDefs) do
	if def.canmove and not def.cruisealtitude then
		if not def.customparams then
			def[cps] = {}
		end
		def[cps]['paratrooper'] = true
		local fdm = 'fall_damage_multiplier'
		if not def.customparams[fdm] then
			if def.movementclass and string.find(def.movementclass, 'HOVER') then
				def[cps][fdm] = 0
				def[cps]['water_'..fdm] = 0
				if def.cantbetransported then
					def.cantbetransported = false
				end
			else
				def[cps][fdm] = 0.25
			end
		end
	end
end