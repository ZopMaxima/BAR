--Slow Nukes
local uDefs = UnitDefs or {}
local nukeIDs = {'armsilo','corsilo','legsilo','armseadragon','cordesolator'}
local velocityMul = 0.5
local timerMul = 1.5
for i = 1, #nukeIDs do
	local def = uDefs[nukeIDs[i]]
	if def and def.weapondefs then
		for k, v in pairs(def.weapondefs) do
			v.turnrate = v.turnrate * velocityMul
			v.weaponvelocity = v.weaponvelocity * velocityMul
			v.weapontimer = v.weapontimer * timerMul
		end
	end
end
local capacity = 10
local reload = 0.5
local turnMul = 2
for id, def in pairs(uDefs) do
	if def.weapondefs then
		for k, v in pairs(def.weapondefs) do
			if v.interceptor then
				v.reloadtime = reload
				v.turnrate = v.turnrate * turnMul
				if v.customparams and v.customparams.stockpilelimit then
					v.customparams.stockpilelimit = capacity
				end
			end
		end
	end
end