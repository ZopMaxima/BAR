--Titan Refit
local uDefs = UnitDefs or {}
local cps = 'customparams'
local wds = 'weapondefs'

local function addBO(builderID, unitID)
	local bDef = UnitDefs[builderID]
	local uDef = UnitDefs[unitID]
	if bDef and uDef then
		bDef.buildoptions[#bDef.buildoptions + 1] = unitID
	end
end

local function mergeMap(l, r)
	for k, v in pairs(r) do
		l[k] = v
	end
end

local function mergeMapRec(l, r)
	for k, v in pairs(r) do
		if type(v) == 'table' then
			local lk = l[k] or {}
			mergeMapRec(lk, v);
			l[k] = lk
		else
			l[k] = v
		end
	end
end

local function addUnit(id, copyID)
	local def = UnitDefs[id] or {}
	mergeMapRec(def, UnitDefs[copyID])
	UnitDefs[id] = def
	return def
end

local atxDef = addUnit('armbanthx', 'armbanth')
atxDef.health = atxDef.health * 0.5
local txWDef1 = atxDef[wds]['armbantha_fire']
local w1Rel = txWDef1.reloadtime
local w1AoE = txWDef1.areaofeffect
mergeMapRec(txWDef1, uDefs['armsnipe'][wds]['armsnipe_weapon'])
txWDef1.reloadtime = w1Rel
txWDef1.areaofeffect = w1AoE
local txWDef2 = atxDef[wds]['bantha_rocket']
txWDef2.burst = 4
txWDef2.burstrate = 0.375
local txWDef3 = atxDef[wds]['tehlazerofdewm']
local w3Range = txWDef3.range
mergeMapRec(txWDef3, uDefs['armanni'][wds]['ata'])
txWDef3.range = w3Range

addBO('armcom', 'armbanthx')