--Lava Sky Ops (Zop)
local uDefs = UnitDefs or {}
local cps = 'customparams'
local wds = 'weapondefs'
local wpn = 'weapons'

local tweakSeaPlane = true
local tweakTorpedo = true
local tweakAirPrice = true
local tweakAirTrans = true
local tweakFlags = true

local function round10(n)
	return math.floor(n * 0.1) * 10
end

local function unwater(id)
	local def = UnitDefs[id]
	if def then
		def.minwaterdepth = -1000000
		def.maxwaterdepth = 0
	end
end

local function addBO(conID, id)
	local cDef = UnitDefs[conID]
	local uDef = UnitDefs[id]
	if cDef and uDef and not cDef.buildoptions[id] then
		table.insert(cDef.buildoptions, id)
	end
end

local function mergeRec(def, ref)
	table.mergeInPlace(def, ref, true)
end

local function clear(m)
	for k, v in pairs(m) do
		m[k] = nil
	end
end

local function indexOfWeapon(def, id, start)
	if def then
		local lowID = string.lower(id)
		for i = start, #def[wpn] do
			if def[wpn][i].def then
				local lowDef = string.lower(def[wpn][i].def)
				if lowDef == lowID then
					return i
				end
			end
		end
	end
	return 0
end

local function mergeWeapons(def, defWID, ref, refWID)
	local i = indexOfWeapon(def, defWID, 1)
	while i > 0 do
		local w = def[wpn][i]
		clear(w)
		mergeRec(w, ref[wpn][indexOfWeapon(ref, refWID, 1)])
		w.def = defWID
		i = indexOfWeapon(def, defWID, i + 1)
	end
end

--Seaplanes on land.
if tweakSeaPlane then
	local asp = 'armplat'
	local csp = 'corplat'
	local yard = 'oooooo oeeeeo oeeeeo oeeeeo oeeeeo oooooo'
	local aspDef = uDefs[asp]
	local cspDef = uDefs[csp]
	unwater(asp)
	local aspHP = aspDef.health
	if aspHP == 0 then
		aspDef.health = 2000
	end
	unwater(csp)
	local cspHP = cspDef.health
	if cspHP == 0 then
		cspDef.health = 2200
	end
	aspDef.waterline = aspDef.waterline + 20
	aspDef.maxslope = 15
	aspDef.yardmap = yard
	cspDef.waterline = cspDef.waterline + 50
	cspDef.maxslope = 15
	cspDef.yardmap = yard
	addBO('armcom', asp)
	addBO('corcom', csp)
	addBO('legcom', csp)
	addBO('armca', asp)
	addBO('corca', csp)
	addBO('legca', csp)
	addBO(asp, 'armca')
	addBO(asp, 'armlance')
	addBO(csp, 'corca')
	addBO(csp, 'legca')
	addBO(csp, 'cortitan')
	addBO(csp, 'legatorpbomber')
	addBO('armap', 'armcsa')
	addBO('armap', 'armseap')
	addBO('corap', 'corcsa')
	addBO('corap', 'corseap')
	addBO('legap', 'corcsa')
	addBO('legap', 'corseap')
	addBO('armcsa', 'armaap')
	addBO('corcsa', 'coraap')
	addBO('corcsa', 'legaap')
end

--Torpedo buffs to fight T3.
if tweakTorpedo then
	local torpHPMul = 2
	local torpDmgMul = 2
	for id, def in pairs(uDefs) do
		if def.weapondefs and (def.cruisealtitude or (not def.canmove)) then
			local hasWW = false
			for k, v in pairs(def.weapondefs) do
				if v.waterweapon then
					v.damage.default = v.damage.default * torpDmgMul
					hasWW = true
				end
			end
			if hasWW then
				def.health = def.health * torpHPMul
			end
		end
	end
end

--Air combat tweaks, energy tax.
if tweakAirPrice then
	local airMCMul = 2
	local airMCCutoff = 12500
	local airECMul = 1
	local airDrainMMul = 0.001
	local airDrainEMul = 0.01
	for id, def in pairs(uDefs) do
		if def.cruisealtitude then
			if def.weapondefs then
				local mcMul = math.max(1, math.min(airMCCutoff / def.metalcost, airMCMul))
				def.buildtime = math.floor(def.buildtime * ((mcMul + airECMul) * 0.5))
				def.metalcost = math.floor(def.metalcost * mcMul)
				def.energycost = math.floor(def.energycost * airECMul)
			end
			if not def.energymake then
				def['activatewhenbuilt'] = true
				def['onoffable'] = false
				def['energyupkeep'] = math.min(def.metalcost * airDrainMMul, 1) * def.energycost * airDrainEMul
			end
		end
	end
	--Snowflake price includes Epic Dragon.
	local eDragon = uDefs['corcrwt4']
	if eDragon then
		eDragon.buildtime = math.floor(eDragon.buildtime * ((airMCMul + airECMul) * 0.5))
		eDragon.metalcost = eDragon.metalcost * airMCMul
		eDragon.energycost = eDragon.energycost * airECMul
	end
end

--Transport paratrooper.
if tweakAirTrans then
	for id, def in pairs(uDefs) do
		if def.cruisealtitude then
			if def.transportcapacity then
				def['isfireplatform'] = true
				def['unloadspread'] = 0.25
			end
		elseif def.canmove then
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
end

--Flagship AA boost.
if tweakFlags then
	local i = 0
	local aDef = uDefs['armfepocht4']
	local cDef = uDefs['corfblackhyt4']
	local lDef = uDefs['legfortt4']
	local aWID = 'ferret_missile'
	local cWID = 'ferret_missile'
	local lWID = 'aa_missiles'
	local aWDef = aDef[wds][aWID]
	local cWDef = cDef[wds][cWID]
	local lWDef = lDef[wds][lWID]
	local aAADef = uDefs['armflak']
	local cAADef = uDefs['legafigdef']
	local lAADef = uDefs['corscreamer']
	local aAAWID = 'armflak_gun'
	local cAAWID = 'leggun'
	local lAAWID = 'cor_advsam'
	local aAAWDef = aAADef[wds][aAAWID]
	local cAAWDef = cAADef[wds][cAAWID]
	local lAAWDef = lAADef[wds][lAAWID]
	aDef.speed = aDef.speed * 1.25
	cDef.speed = cDef.speed * 1.25
	lDef.speed = lDef.speed * 1.125
	aDef.turnrate = aDef.turnrate * 1.25
	cDef.turnrate = cDef.turnrate * 1.25
	lDef.turnrate = lDef.turnrate * 1.125
	lDef['radardistancejam'] = 600
	--Arm
	clear(aWDef)
	mergeRec(aWDef, aAAWDef)
	mergeWeapons(aDef, aWID, aAADef, aAAWID)
	aWDef.reloadtime = aWDef.reloadtime * 1.5
	local i1 = indexOfWeapon(aDef, aWID, 1)
	local i2 = indexOfWeapon(aDef, aWID, i1 + 1)
	aDef[wpn][i1].maindir = "0 -1 -2"
	aDef[wpn][i1].proximitypriority = 1
	aDef[wpn][i2].proximitypriority = -1
	--Cor
	clear(cWDef)
	mergeRec(cWDef, cAAWDef)
	mergeWeapons(cDef, cWID, cAADef, cAAWID)
	cWDef.reloadtime = cWDef.reloadtime * 0.375
	cWDef.burst = cWDef.burst * 0.5
	cWDef.burstrate = cWDef.burstrate * 1.5
	cWDef.range = round10(cWDef.range * 1.25)
	cWDef[cps].noattackrangearc = nil
	i1 = indexOfWeapon(cDef, cWID, 1)
	i2 = indexOfWeapon(cDef, cWID, i1 + 1)
	cDef[wpn][i1].maxangledif = nil
	cDef[wpn][i1].maindir = '-1.5 0 2'
	cDef[wpn][i2].maxangledif = nil
	cDef[wpn][i2].maindir = '1.5 0 2'
	--Leg
	clear(lWDef)
	mergeRec(lWDef, lAAWDef)
	mergeWeapons(lDef, lWID, lAADef, lAAWID)
	lWDef.stockpile = false
	lWDef.maindir = "1 0 0"
	lWDef.cegtag = 'missiletrailaa-medium'
	lWDef.explosiongenerator = 'custom:genericshellexplosion-medium-aa'
	lWDef.areaofeffect = lWDef.areaofeffect * 0.25
end