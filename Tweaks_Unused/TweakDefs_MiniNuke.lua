--Mini Nukes (Zop)
local uDefs = UnitDefs or {}

local function rmvUA(unitID)
	local def = UnitDefs[unitID]
	if def and def.maxthisunit then --Wrong stat?
		def.health = 0
	end
end

--Small and focused nukes, small and sturdy anti-nukes.
local nukeDamageMul = 2
local nukeAOEMul = 0.225
local antiReloadMul = 0.05
local antiPorcRestockMul = 0.1
local antiMoblRestockMul = 0.25
local antiPorcAOE = 425
local antiMoblAOE = 625
local antiPorcCapacity = 99
local nukeIDs = {
	'armsilo','corsilo','legsilo'
}
for i = 1, #nukeIDs do
	rmvUA(nukeIDs[i])
	local nukeDef = uDefs[nukeIDs[i]]
	if nukeDef and nukeDef.weapondefs then
		for k, v in pairs(nukeDef.weapondefs) do
			v.areaofeffect = v.areaofeffect * nukeAOEMul
			v.craterareaofeffect = v.craterareaofeffect * nukeAOEMul
			v.craterboost = v.craterboost * nukeAOEMul
			v.cratermult = v.cratermult * nukeAOEMul
			v.edgeeffectiveness = 0.125
			v.impulsefactor = v.impulsefactor * nukeDamageMul
			if v.damage and v.damage.default then
				v.damage.default = v.damage.default * nukeDamageMul
			end
		end
	end
end
local antiIDs = {
	'armamd','corfmd','legabm',
	'armscab','cormabm',
	'armantiship','corantiship',
	'armcarry','corcarry'
}
for i = 1, #antiIDs do
	rmvUA(antiIDs[i])
	local antiDef = uDefs[antiIDs[i]]
	if antiDef and antiDef.weapondefs then
		for k, v in pairs(antiDef.weapondefs) do
			v.reloadtime = v.reloadtime * antiReloadMul
			if v.damage and v.damage.default then
				v.damage.default = v.damage.default * 0.25
			end
		end
		if antiDef.canmove and antiDef.speed then
			for k, v in pairs(antiDef.weapondefs) do
				v.coverage = antiMoblAOE
				v.stockpiletime = v.stockpiletime * antiMoblRestockMul
			end
		else
			for k, v in pairs(antiDef.weapondefs) do
				v.coverage = antiPorcAOE
				v.stockpiletime = v.stockpiletime * antiPorcRestockMul
				if v.customparams and v.customparams.stockpilelimit then
					v.customparams.stockpilelimit = antiPorcCapacity
				end
			end
		end
	end
end
