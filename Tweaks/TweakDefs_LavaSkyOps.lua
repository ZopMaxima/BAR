--Lava Sky Ops (Zop)
local mods = Spring.GetModOptions()
local uDefs = UnitDefs or {}
local cps = 'customparams'
local wds = 'weapondefs'
local wpn = 'weapons'

local catAirATA = 'AIR_ATA'
local catAirATS = 'AIR_ATS'
local catAirUtil = 'AIR_UTIL'
local cruiseOrbit = 1000

local noSea = mods.map_waterislava

local tweakSeaPlane = true
local tweakTorpedo = true
local tweakAirPrice = true
local tweakAirTrans = true
local tweakFlags = true
local tweakScreamers = true

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

local function categorize(def, key, cat)
	if def then
		if def[key] then
			def[key] = def[key]..' '..cat
		else
			def[key] = cat
		end
	end
end

local function tweakSeaPlatform(id, hpReset, height)
	local def = UnitDefs[id]
	if def then
		local hp = def.health
		if hp == 0 then
			def.health = hpReset
		end
		def.metalcost = round10(def.metalcost * 0.8)
		def.energycost = round10(def.energycost * 1.25)
		if noSea then
			unwater(id)
			def.waterline = def.waterline + height
			def.maxslope = 15
			def.yardmap = 'oooooo oeeeeo oeeeeo oeeeeo oeeeeo oooooo'
		end
		if def[cps] then
			def[cps].enabled_on_no_sea_maps = true
		end
	end
end

--Seaplanes on land.
if tweakSeaPlane then
	local asp = 'armplat'
	local csp = 'corplat'
	local lsp = 'legsplab'
	tweakSeaPlatform(asp, 2000, 20)
	tweakSeaPlatform(csp, 2200, 50)
	tweakSeaPlatform(lsp, 2200, 50)
	addBO('armcom', asp)
	addBO('corcom', csp)
	addBO('legcom', lsp)
	addBO('armca', asp)
	addBO('corca', csp)
	addBO('legca', lsp)
	addBO(asp, 'armca')
	addBO(asp, 'armlance')
	addBO(csp, 'corca')
	addBO(csp, 'cortitan')
	addBO(lsp, 'legca')
	addBO(lsp, 'legatorpbomber')
	addBO('armap', 'armcsa')
	addBO('armap', 'armseap')
	addBO('corap', 'corcsa')
	addBO('corap', 'corseap')
	addBO('legap', 'legspcon')
	addBO('legap', 'legsptorpgunship')
	addBO('armcsa', 'armaap')
	addBO('corcsa', 'coraap')
	addBO('legspcon', 'legaap')
end

--Torpedo buffs to fight T3.
if tweakTorpedo then
	local torpHPMul = 2
	local torpDmgMul = 2
	for id, def in pairs(uDefs) do
		local ca = def.cruisealtitude
		if def.weapondefs and ((ca and ca < cruiseOrbit) or (not def.canmove)) then
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
		local ca = def.cruisealtitude
		if ca and ca < cruiseOrbit then
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
		eDragon.health = eDragon.health * 1.5
		eDragon.speed = math.floor(eDragon.speed * 0.675)
		eDragon.buildtime = math.floor(eDragon.buildtime * ((airMCMul + airECMul) * 0.5))
		eDragon.metalcost = eDragon.metalcost * airMCMul
		eDragon.energycost = eDragon.energycost * airECMul
	end
end

--Transport paratrooper.
if tweakAirTrans then
	for id, def in pairs(uDefs) do
		local ca = def.cruisealtitude
		if ca and ca < cruiseOrbit then
			local isATA = false
			local isATS = false
			if def.transportcapacity then
				def['isfireplatform'] = true
				isATS = true
			end
			if def[wpn] then
				for i = 1, #def[wpn] do
					local otc = def[wpn][i].onlytargetcategory
					local ata = otc and otc == 'VTOL'
					isATA = isATA or ata
					isATS = isATS or ata == false
				end
			end
			if isATS then
				categorize(def, 'category', catAirATS)
			elseif isATA then
				categorize(def, 'category', catAirATA)
			else
				categorize(def, 'category', catAirUtil)
			end
		elseif def.canmove then
			if not def[cps] then
				def[cps] = {}
			end
			def[cps]['paratrooper'] = true
			local fdm = 'fall_damage_multiplier'
			if not def[cps][fdm] then
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
			if def[wds] then
				for i = 1, #def[wds] do
					if not def[wds][i][cps] then
						def[wds][i][cps] = {}
					end
					def[wds][i][cps].collidefirebase = false
				end
			end
		end
	end
end

--Flagship AA boost.
if tweakFlags then
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
	aDef[wpn][i1].maxangledif = nil
	aDef[wpn][i2].maxangledif = nil
	aDef[wpn][i1].maindir = nil
	aDef[wpn][i2].maindir = nil
	--Cor
	local cwID2 = cWID..'2'
	clear(cWDef)
	mergeRec(cWDef, cAAWDef)
	mergeWeapons(cDef, cWID, cAADef, cAAWID)
	cWDef.burstrate = 0.05
	cWDef.burst = 4
	cWDef.reloadtime = cWDef.burstrate * cWDef.burst
	cWDef.range = round10(cWDef.range * 1.25)
	cWDef.proximitypriority = 1
	cWDef[cps].noattackrangearc = nil
	cWDef.damage.vtol = cWDef.damage.vtol * 0.5
	cDef[wds][cwID2] = table.copy(cWDef)
	cDef[wds][cwID2].proximitypriority = -1
	i1 = indexOfWeapon(cDef, cWID, 1)
	i2 = indexOfWeapon(cDef, cWID, i1 + 1)
	cDef[wpn][i1].fastautoretargeting = true
	cDef[wpn][i2].fastautoretargeting = true
	cDef[wpn][i1].maxangledif = nil
	cDef[wpn][i2].maxangledif = nil
	cDef[wpn][i1].maindir = nil
	cDef[wpn][i2].maindir = nil
	cDef[wpn][i2].def = cwID2
	--Leg
	clear(lWDef)
	mergeRec(lWDef, lAAWDef)
	mergeWeapons(lDef, lWID, lAADef, lAAWID)
	lWDef.turnrate = lWDef.turnrate * 1.5
	lWDef.weaponvelocity = lWDef.weaponvelocity * 0.375
	lWDef.burst = 6
	lWDef.burstrate = 0.025
	lWDef.reloadtime = lWDef.reloadtime * 2
	lWDef.dance = 250
	lWDef.sprayangle = 1000
	lWDef.trajectoryheight = 0.25
	lWDef.proximitypriority = nil
	lWDef.stockpile = false
	lWDef.model = 'cormissile.s3o'
	lWDef.cegtag = 'missiletrailaa'
	lWDef.texture2 = 'smoketrailaa3'
	lWDef.smoketime = lWDef.smoketime * 0.25
	lWDef.smokesize = lWDef.smokesize * 0.25
	lWDef.startsound = 'packolau'
	lWDef.explosiongenerator = 'custom:genericshellexplosion-medium-aa'
	lWDef.areaofeffect = lWDef.areaofeffect * 0.2
end

--Redistribute AoE, prefer ATS targets.
local function tweakLRAA(uID, wID)
	local wDef = nil
	local def = uDefs[uID]
	if def then
		def.airsightdistance = def.sightdistance * 1.5
		wDef = def[wds][wID]
		if wDef then
			wDef.damage.vtol = wDef.damage.vtol * 2
			wDef.edgeeffectiveness = 0
			wDef.areaofeffect = wDef.areaofeffect * 0.5
			local i = indexOfWeapon(def, wID, 1)
			if i > 0 then
				categorize(def[wpn][i], 'badtargetcategory', catAirATA)
				categorize(def[wpn][i], 'badtargetcategory', catAirUtil)
			end
		end
	end
	return wDef
end

--More reliable LRAA.
if tweakScreamers then
	local wd = nil
	wd = tweakLRAA('armmercury', 'arm_advsam')
	if wd then
		wd.stockpiletime = wd.stockpiletime * 0.5
	end
	wd = tweakLRAA('corscreamer', 'cor_advsam')
	if wd then
		wd.stockpiletime = wd.stockpiletime * 0.5
	end
	wd = tweakLRAA('leglraa', 'railgunt2')
	if wd then
		wd.cegtag = nil
		wd.noExplode = true
		wd.overpenetrate = true
	end
end