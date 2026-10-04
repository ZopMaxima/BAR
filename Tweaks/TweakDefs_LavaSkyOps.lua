--Lava Sky Ops 1.4 (Zop)
local mods = Spring.GetModOptions()
local uDefs = UnitDefs or {}
local cps = 'customparams'
local wds = 'weapondefs'
local wpn = 'weapons'
local allAir = {}

local catAirATA = 'AIR_ATA'
local catAirATS = 'AIR_ATS'
local catAirUtil = 'AIR_UTIL'
local cruiseOrbit = 1000

local noSea = mods.map_waterislava
local slowComm = mods.comm_trans_slow

local tweakSeaPlane = true
local tweakAirPrice = true
local tweakAirTrans = true
local tweakFlags = true
local tweakScreamers = true

--Assign
for id, def in pairs(uDefs) do
	local ca = def.cruisealtitude
	if ca and ca < cruiseOrbit then
		allAir[id] = def
	end
end

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

local function tryLower(v)
	return type(v) == 'string' and string.lower(v) or v
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

local function clear(t)
	for k, v in pairs(t) do
		t[k] = nil
	end
end

local function forEachWhere(t, where, func)
	for k, v in pairs(t) do
		if where(k, v) then
			func(k, v)
		end
    end
end

local function forEachKey(t, key, func)
	forEachWhere(t, function (k, v) return k == key end, func)
end

local function forEachValue(t, val, match, func)
	match = tryLower(match)
	forEachWhere(t, function(k, v) return tryLower(v[val]) == match end, func)
end

local function indexOfWeapon(def, id, start)
	if def then
		local lowID = tryLower(id)
		for i = start, #def[wpn] do
			if def[wpn][i].def then
				if tryLower(def[wpn][i].def) == lowID then
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
		def[cps] = def[cps] or {}
		def[cps].enabled_on_no_sea_maps = true
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

--Air price, energy tax.
if tweakAirPrice then
	local airMCMul = 2
	local airMCCutoff = 12500
	local airECMul = 1
	local airDrainMMul = 0.001
	local airDrainEMul = 0.01
	for id, def in pairs(allAir) do
		if (def.transportcapacity and def[cps] and (def[cps].techlevel or 0) > 1) or next(def[wds] or {}) or next(def[wpn] or {}) then
			local mcMul = math.max(1, math.min(airMCCutoff / def.metalcost, airMCMul))
			def.buildtime = math.floor(def.buildtime * ((mcMul + airECMul) * 0.5))
			def.metalcost = math.floor(def.metalcost * mcMul)
			def.energycost = math.floor(def.energycost * airECMul)
		end
		if not def.energymake then
			def.onoffable = false
			def.energyupkeep = math.min(def.metalcost * airDrainMMul, 1) * def.energycost * airDrainEMul
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

--Paratroopers
if tweakAirTrans then
	local mvc = 'movementclass'
	local amph = { 'ATANK', 'ABOT', 'VBOT', 'COMM', 'EPIC' }
	for id, def in pairs(uDefs) do
		if def.cruisealtitude then
			if allAir[id] and def.transportcapacity then
				def.isfireplatform = true
			end
		elseif def.canmove and not def.cantbetransported and not (def[cps] and def[cps].iscommander and not slowComm) then
			def[cps] = def[cps] or {}
			def[cps].paratrooper = true
			local fdm = 'fall_damage_multiplier'
			if not def[cps][fdm] then
				if def[mvc] and string.find(def[mvc], 'HOVER') then
					def[cps][fdm] = 0.125
					def[cps]['water_'..fdm] = 0
					def.cantbetransported = nil
				else
					--See alldefs_post.lua
					local mass = def.mass or math.max(def.metalcost or 1, ((def.health or 6) / 6))
					if (def.metalcost or 1) < 751 and mass > 750 then
						mass = 750
					end
					def[cps][fdm] = 0.125 + 0.125 * math.min(3, math.max(1, mass / 750)) --0.25 to 0.5
					if def[mvc] then
						for k, v in pairs(amph) do
							if string.find(def[mvc], v) then
								def[cps]['water_' .. fdm] = def[cps][fdm] * 0.25
								break
							end
						end
					end
				end
			end
			if def[wds] then
				for _, wd in pairs(def[wds]) do
					wd[cps] = wd[cps] or {}
					wd[cps].collidefirebase = false
				end
			end
		end
	end
end

local function t4AA(def, wID, mul)
	forEachValue(def[wpn], 'def', wID, function(k, v) categorize(v, 'onlytargetcategory', 'T4AIR') end)
	local d = def[wds][wID].damage
	d.vtol = math.max((d.default or 1) * mul, d.vtol or 1)
end

local function splitAA(def, id, idNew)
	local i1 = indexOfWeapon(def, id, 1)
	local i2 = indexOfWeapon(def, id, i1 + 1)
	local w1 = def[wpn][i1]
	local w2 = def[wpn][i2]
	for _, w in ipairs { w1, w2 } do
		w.fastautoretargeting = true
		w.maxangledif = nil
		w.maindir = nil
	end
	w2.def = idNew
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
	lDef.radardistancejam = 600
	lDef.category = "T4AIR"
	t4AA(lDef, 'plasma', 0.4)
	t4AA(lDef, 'semiauto', 0.25)
	--Arm
	local aWID2 = aWID .. '2'
	clear(aWDef)
	mergeRec(aWDef, aAAWDef)
	mergeWeapons(aDef, aWID, aAADef, aAAWID)
	aWDef.reloadtime = aWDef.reloadtime * 0.5
	aWDef.damage.vtol = aWDef.damage.vtol * 0.25
	aDef[wds][aWID2] = table.copy(aWDef)
	aDef[wds][aWID2].proximitypriority = -1
	aDef[wds][aWID].proximitypriority = 1
	splitAA(aDef, aWID, aWID2)
	--Cor
	local cWID2 = cWID..'2'
	clear(cWDef)
	mergeRec(cWDef, cAAWDef)
	mergeWeapons(cDef, cWID, cAADef, cAAWID)
	cWDef.noExplode = true
	cWDef.projectiles = 2
	cWDef.sprayangle = 1080
	cWDef.ownerExpAccWeight = 0
	cWDef.burstrate = 0.05
	cWDef.burst = 2
	cWDef.reloadtime = cWDef.burstrate * cWDef.burst
	cWDef.range = round10(cWDef.range * 1.1)
	cWDef.proximitypriority = 1
	cWDef[cps] = cWDef[cps] or {}
	cWDef[cps].overpenetrate = true
	cWDef[cps].noattackrangearc = nil
	cWDef.damage.vtol = math.floor(cWDef.damage.vtol * 0.125)
	cDef[wds][cWID2] = table.copy(cWDef)
	cDef[wds][cWID2].proximitypriority = -1
	splitAA(cDef, cWID, cWID2)
	--Leg
	clear(lWDef)
	mergeRec(lWDef, lAAWDef)
	mergeWeapons(lDef, lWID, lAADef, lAAWID)
	lWDef.turnrate = lWDef.turnrate * 1.5
	lWDef.startvelocity = lWDef.startvelocity * 0.25
	lWDef.weaponvelocity = lWDef.weaponvelocity * 1.25
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
	lWDef.damage.vtol = math.floor(lWDef.damage.vtol * 1.5)
end

--Redistribute AoE, prefer ATS targets.
local function tweakLRAA(uID, wID)
	local wDef = nil
	local def = uDefs[uID]
	if def then
		def.airsightdistance = def.sightdistance * 1.5
		wDef = def[wds][wID]
		if wDef then
			wDef.damage.vtol = wDef.damage.vtol * 1.5
			wDef.edgeeffectiveness = 0
			wDef.areaofeffect = wDef.areaofeffect * 0.5
			forEachValue(def[wpn], 'def', wID,
				function(k, v)
					categorize(v, 'badtargetcategory', catAirATA)
					categorize(v, 'badtargetcategory', catAirUtil)
				end)
		end
	end
	return wDef
end

--Reliable LRAA.
if tweakScreamers then
	for id, def in pairs(allAir) do
		local isATA = false
		local isATS = (def.transportcapacity or 0) > 0
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
	end
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
		wd[cps] = wd[cps] or {}
		wd[cps].overpenetrate = true
		wd[cps].overpenetrate_falloff = true
	end
end