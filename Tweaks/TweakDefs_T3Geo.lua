--T3 Bubble Geo (Zop)
--Concept by Djarshi / Txpera
local uDefs = UnitDefs or {}
local cps = 'customparams'
local wds = 'weapondefs'
local wpn = 'weapons'
local aACons = {'armaca','armack','armacv'}
local cACons = {'coraca','corack','coracv'}
local lACons = {'legaca','legack','legacv'}

local tweakT3Geo = true

local function round10(n)
	return math.floor(n * 0.1) * 10
end

local function addBO(builderID, id)
	local bDef = UnitDefs[builderID]
	local uDef = UnitDefs[id]
	if bDef and uDef then
		bDef.buildoptions[#bDef.buildoptions + 1] = id
	end
end

local function addBOArr(builderIDs, id)
	for i = 1, #builderIDs do
		addBO(builderIDs[i], id)
	end
end

local function remodel(def, name, hasDead, hasDecal)
	if def then
		def.buildpic = name..'.DDS'
		def.objectname = 'Units/'..name..'.s3o'
		def.script = 'Units/'..name..'.cob'
		if hasDead then
			def[fds].dead.object = 'Units/'..string.lower(name)..'_dead.s3o'
		end
		if hasDecal then
			def[cps].buildinggrounddecaltype = 'decals/'..string.lower(name)..'_aoplane.dds'
		end
	end
end

local function setDesc(def, name, tip)
	local latin = {'en','fr','de'}
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

local function extrapolate(t1, t2)
	return round10(t2 * (t2 / t1))
end

local function mulTier(t1Def, t2Def, t3Def, stat)
	if t1Def and t2Def and t3Def then
		t3Def[stat] = extrapolate(t1Def[stat], t2Def[stat])
	end
end

local function mulGeoTier(t1Def, t2Def, t3Def)
	mulTier(t1Def, t2Def, t3Def, 'metalcost')
	mulTier(t1Def, t2Def, t3Def, 'energycost')
	mulTier(t1Def, t2Def, t3Def, 'buildtime')
	mulTier(t1Def, t2Def, t3Def, 'energymake')
	mulTier(t1Def, t2Def, t3Def, 'energystorage')
	mulTier(t1Def, t2Def, t3Def, 'health')
end

local function mergeDeflector(geoDef, defDef)
	if geoDef and defDef then
		geoDef[wds] = table.merge(geoDef[wds], defDef[wds])
		geoDef[wpn] = table.merge(geoDef[wpn], defDef[wpn])
		geoDef[cps]['shield_color_mult'] = defDef[cps].shield_color_mult
		geoDef[cps]['shield_power'] = defDef[cps].shield_power
		geoDef[cps]['shield_radius'] = defDef[cps].shield_radius
	end
end

--Multiply and overwrite stats.
if tweakT3Geo then
	local at1Def = uDefs['armgeo']
	local ct1Def = uDefs['corgeo']
	local lt1Def = uDefs['leggeo']
	local at2Def = uDefs['armageo']
	local ct2Def = uDefs['corageo']
	local lt2Def = uDefs['legageo']
	--T3
	local statOverride = {
		icontype = 'armageo',
		canattack = false,
		canrepeat = false,
		explodeas = 'advancedFusionExplosionSelfd',
		selfdestructas = 'ScavComBossExplo',
		customparams = {
			techlevel = 3
		},
		weapondefs = {},
		weapons = {}
	}
	local at3 = 'armageot3'
	local ct3 = 'corageot3'
	local lt3 = 'legageot3'
	uDefs[at3] = table.merge(at2Def, statOverride)
	uDefs[ct3] = table.merge(ct2Def, statOverride)
	uDefs[lt3] = table.merge(lt2Def, statOverride)
	local at3Def = uDefs[at3]
	local ct3Def = uDefs[ct3]
	local lt3Def = uDefs[lt3]
	local t3Name = 'Epic Geothermal Powerplant'
	local t3DescPfx = 'Produces '
	local t3DescSfx = ' Energy (Extremely Hazardous)'
	--Arm
	mulGeoTier(at1Def, at2Def, at3Def)
	mergeDeflector(at3Def, uDefs['armgatet3'])
	setDesc(at3Def, t3Name, t3DescPfx..at3Def.energymake..t3DescSfx)
	remodel(at3Def, 'ARMUWAGEO', false, false)
	addBOArr(aACons, at3)
	--Cor
	mulGeoTier(ct1Def, ct2Def, ct3Def)
	mergeDeflector(ct3Def, uDefs['corgatet3'])
	setDesc(ct3Def, t3Name, t3DescPfx..ct3Def.energymake..t3DescSfx)
	remodel(ct3Def, 'CORUWAGEO', false, false)
	addBOArr(cACons, ct3)
	--Leg
	mulGeoTier(lt1Def, lt2Def, lt3Def)
	mergeDeflector(lt3Def, uDefs['leggatet3'])
	setDesc(lt3Def, t3Name, t3DescPfx..lt3Def.energymake..t3DescSfx)
	remodel(lt3Def, 'legrampart', false, false)
	addBOArr(lACons, lt3)
	--T2
	local yardmap = 'h cbbybjyybc bjbjjbbjjb yjbjbjjbbb ybjjjbjjjy jbjbjjjbjb bjbjjjbjbj yjjjbjjjby bbbjjbjbjy bjjbbjjbjb cbyyjbybbc'
	at2Def.yardmap = yardmap
	ct2Def.yardmap = yardmap
	lt2Def.yardmap = yardmap
end