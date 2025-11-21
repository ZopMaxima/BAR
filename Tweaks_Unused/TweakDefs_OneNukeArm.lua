--One Nuke (Arm)
local uDefs = UnitDefs or {}
local cps = 'customparams'
local wds = 'weapondefs'
local bos = 'buildoptions'

local function uMax(id, n)
	local def = uDefs[id]
	if def then
		def['maxthisunit'] = n
	end
end

--No stockpile exploits.
local nukeIDs = {'armsilo','corsilo','legsilo','armseadragon','cordesolator'}
for i = 1, #nukeIDs do
	local def = uDefs[nukeIDs[i]]
	if def and def[wds] then
		for k, v in pairs(def[wds]) do
			if v.stockpile and v[cps] and v[cps].stockpilelimit then
				v[cps].stockpilelimit = 1
			end
		end
	end
end

--Enable
local onIDs = {'armsilo','armamd'}
for i = 1, #onIDs do
	uMax(onIDs[i], 1)
end

--Disable
local offIDs = {'corsilo','legsilo','armseadragon','cordesolator','corfmd','legabm','armscab','cormabm'}
for i = 1, #offIDs do
	uMax(offIDs[i], 0)
end

--TODO Enable armscab if multi lab exploit is fixed.
--Scarab to bot labs.
--table.insert(uDefs['coralab'][bos], 'armscab')
--table.insert(uDefs['legalab'][bos], 'armscab')

--Swap to Arm.
for id, def in pairs(uDefs) do
	--Swap to Arm.
	if def[bos] then
		for i = 1, #def[bos] do
			if def[bos][i] == 'corsilo' or def[bos][i] == 'legsilo' then
				def[bos][i] = 'armsilo'
			end
			if def[bos][i] == 'corfmd' or def[bos][i] == 'legabm' then
				def[bos][i] = 'armamd'
			end
		end
	end
	--Reliable AN fire rate.
	if def[wds] then
		for k, v in pairs(def[wds]) do
			if v.interceptor then
				v.reloadtime = v.reloadtime * 0.5
				v.stockpiletime = v.stockpiletime * 0.125
				if v.stockpile and v[cps] and v[cps].stockpilelimit then
					v[cps].stockpilelimit = 10
				end
			end
		end
	end
end