--Bot Cannons (Zop)
local uDefs = UnitDefs or {}
local latin = {'en','fr','de'}
local cps = 'customparams'
local wds = 'weapondefs'

local pawnHP = uDefs['armbotrail'].health
local pawnMax = uDefs['armbotrail'].maxthisunit
local enablePawn = (pawnHP > 0) and ((not pawnMax) or pawnMax > 0)

local function round10(n)
	return math.floor(n * 0.1) * 10
end

local function rmvID(unitID)
	local def = UnitDefs[unitID]
	if def then
		def.health = 0
	end
end

local function addBO(builderID, unitID)
	local bDef = UnitDefs[builderID]
	local uDef = UnitDefs[unitID]
	if bDef and uDef then
		bDef.buildoptions[#bDef.buildoptions + 1] = unitID
	end
end

local function rmvBO(builderID, unitID)
	local bDef = UnitDefs[builderID]
	if bDef and bDef.buildoptions then
		for k, v in pairs(bDef.buildoptions) do
			if v == unitID then
				bDef.buildoptions[k] = nil
				break
			end
		end
	end
end

local function addDefCPS(def)
	if not def.customparams then
		def[cps] = {}
	end
end

local function mergeMap(l, r)
	for k, v in pairs(r) do
		l[k] = v
	end
end

local function setDesc(def, name, tip)
	if def then
		for i = 1, #latin do
			if name then
				def[cps]['i18n_'..latin[i]..'_humanname'] = name
			end
			if tip then
				def[cps]['i18n_'..latin[i]..'_tooltip'] = tip
			end
		end
	end
end

--Recycling, do not disable with sea.
if enablePawn and tweakPawn then
	uDefs['armfhlt'].minwaterdepth = nil
	uDefs['corfhlt'].minwaterdepth = nil
end
if tweakPawn then
	rmvBO('armcsa', 'armfhlt')
	rmvBO('corcsa', 'corfhlt')
end

--Clean up build cards.
if not enablePawn then
	rmvID('armbotrail')
end

--Pawn launcher range nerf, Cor / Leg alternatives.
if enablePawn and tweakPawn then
	local pawnRangeMul = 0.65
	local thugRangeMul = 0.875
	local centRangeMul = 0.75
	local aRail = 'armbotrail'
	local cRail = 'corfhlt'
	local lRail = 'armfhlt'
	local aRailDef = uDefs[aRail]
	local cRailDef = uDefs[cRail]
	local lRailDef = uDefs[lRail]
	local aRailWDef = aRailDef[wds]['arm_botrail']
	local cRailWDef = cRailDef[wds][cRail..'_laser']
	local lRailWDef = lRailDef[wds][lRail..'_laser']
	local thugDef = uDefs['corthud']
	local centDef = uDefs['legcen']
	for k, v in pairs(uDefs[aRail]) do
		if not (k == 'customparams') and not (k == 'weapondefs') and not (k == 'weapons') then
			cRailDef[k] = v
			lRailDef[k] = v
		end
	end
	for k, v in pairs(aRailWDef) do
		if not (k == 'customparams') and not (k == 'damage') then
			cRailWDef[k] = v
			lRailWDef[k] = v
		end
	end
	for k, v in pairs(uDefs[aRail].weapons[1]) do
		if not (k == 'def') then
			cRailDef.weapons[1][k] = v
			lRailDef.weapons[1][k] = v
		end
	end
	addDefCPS(cRailDef)
	addDefCPS(cRailWDef)
	if not cRailWDef.damage then
		cRailWDef.damage = {}
	end
	addDefCPS(lRailDef)
	addDefCPS(lRailWDef)
	if not lRailWDef.damage then
		lRailWDef.damage = {}
	end
	mergeMap(cRailDef[cps], aRailDef[cps])
	mergeMap(lRailDef[cps], aRailDef[cps])
	mergeMap(cRailWDef[cps], aRailWDef[cps])
	mergeMap(lRailWDef[cps], aRailWDef[cps])
	mergeMap(cRailWDef.damage, aRailWDef.damage)
	mergeMap(lRailWDef.damage, aRailWDef.damage)
	--Arm Balanced Output
	aRailWDef.range = round10(aRailWDef.range * pawnRangeMul)
	aRailWDef.sprayangle = aRailWDef.sprayangle * 0.75
	aRailWDef.bounceslip = 0.675
	aRailWDef.bouncerebound = 0.475
	aRailWDef.numbounce = 3
	aRailWDef.damage.default = aRailWDef.damage.default * 5
	aRailWDef.damage.shields = aRailWDef.damage.shields * 5
	--Cor Shield Buster
	setDesc(cRailDef, 'Thug Battery', 'Shield-Busting Infantry Cannon')
	cRailWDef[cps].spawns_name = 'corthud'
	cRailWDef[cps].stockpilelimit = 20
	cRailWDef.range = round10(cRailWDef.range * thugRangeMul)
	cRailWDef.model = 'Units/CORTHUD.s3o'
	cRailWDef.metalpershot = thugDef.metalcost * 3
	cRailWDef.energypershot = thugDef.energycost * 3
	cRailWDef.hightrajectory = 1
	cRailWDef.reloadtime = 1
	cRailWDef.stockpiletime = 5
	cRailWDef.sprayangle = cRailWDef.sprayangle * 0.5
	cRailWDef.bounceslip = 0.25
	cRailWDef.bouncerebound = 0.125
	cRailWDef.numbounce = 1
	cRailWDef.areaofeffect = 30
	cRailWDef.damage.default = thugDef.mass
	cRailWDef.damage.shields = thugDef.mass * 15
	--Leg Unit Dispenser
	setDesc(lRailWDef, 'Centaur Cannon', 'Shotgun Infantry Cannon')
	lRailWDef[cps].spawns_name = 'legcen'
	lRailWDef[cps].stockpilelimit = 5
	lRailWDef.range = round10(lRailWDef.range * centRangeMul)
	lRailWDef.model = 'Units/LEGCEN.s3o'
	lRailWDef.metalpershot = centDef.metalcost * 30
	lRailWDef.energypershot = centDef.energycost * 30
	lRailWDef.projectiles = 10
	lRailWDef.reloadtime = 2
	lRailWDef.stockpiletime = 30
	lRailWDef.sprayangle = lRailWDef.sprayangle * 1.15
	lRailWDef.bounceslip = 0.5
	lRailWDef.bouncerebound = 0.625
	lRailWDef.numbounce = 1
	lRailWDef.weaponvelocity = lRailWDef.weaponvelocity * 1.25
	addBO('coraca', cRail)
	addBO('corack', cRail)
	addBO('coracv', cRail)
	addBO('legaca', lRail)
	addBO('legack', lRail)
	addBO('legacv', lRail)
end