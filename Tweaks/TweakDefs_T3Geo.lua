--T3 Bubble Geo (Zop)
--Concept by Djarshi / Txpera
local mods = Spring.GetModOptions()
local uDefs = UnitDefs or {}
local cps = 'customparams'
local fds = 'featuredefs'
local wds = 'weapondefs'
local wpn = 'weapons'
local aACons = {'armaca','armack','armacv','armacsub'}
local cACons = {'coraca','corack','coracv','coracsub'}
local lACons = {'legaca','legack','legacv'}

local hasExtras = mods.experimentalextraunits
local noSea = mods.map_waterislava

local tweakT3Geo = true

local function round10(n)
	return math.floor(n * 0.1) * 10
end

local function extrapolate(t1, t2)
	return round10(t2 * (t2 / t1))
end

local function mulTier(t1Def, t2Def, t3Def, stat)
	if t1Def and t2Def and t3Def then
		t3Def[stat] = extrapolate(t1Def[stat], t2Def[stat])
	end
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

local function addBOArr(conIDs, id)
	for i = 1, #conIDs do
		addBO(conIDs[i], id)
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

local function mulGeoTier(t1, t2, t3)
	mulTier(t1, t2, t3, 'metalcost')
	mulTier(t1, t2, t3, 'energycost')
	mulTier(t1, t2, t3, 'buildtime')
	mulTier(t1, t2, t3, 'energymake')
	mulTier(t1, t2, t3, 'energystorage')
	mulTier(t1, t2, t3, 'health')
end

local function mergeShield(def, ref)
	if def and ref then
		def[wds] = table.merge(def[wds], ref[wds])
		def[wpn] = table.merge(def[wpn], ref[wpn])
		def[cps]['shield_color_mult'] = ref[cps].shield_color_mult
		def[cps]['shield_power'] = ref[cps].shield_power
		def[cps]['shield_radius'] = ref[cps].shield_radius
	end
end

--Extrapolate geo stats.
if hasExtras and tweakT3Geo and not uDefs['armageot3'] then
	local at2Def = uDefs['armageo']
	local ct2Def = uDefs['corageo']
	local lt2Def = uDefs['legageo']
	--T3
	local override = {
		icontype = 'armageo',
		canattack = false,
		canrepeat = false,
		maxwaterdepth = 1000000,
		minwaterdepth = -1000000,
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
	uDefs[at3] = table.merge(at2Def, override)
	uDefs[ct3] = table.merge(ct2Def, override)
	uDefs[lt3] = table.merge(lt2Def, override)
	local at3Def = uDefs[at3]
	local ct3Def = uDefs[ct3]
	local lt3Def = uDefs[lt3]
	if noSea then
		unwater(at3)
		unwater(ct3)
		unwater(lt3)
	end
	local t3Name = 'Epic Geothermal Powerplant'
	local t3DescP = 'Produces '
	local t3DescS = ' Energy (Extremely Hazardous) (OP by djarshi)'
	--Arm
	mulGeoTier(uDefs['armgeo'], at2Def, at3Def)
	mergeShield(at3Def, uDefs['armgatet3'])
	setDesc(at3Def, t3Name, t3DescP..at3Def.energymake..t3DescS)
	remodel(at3Def, 'ARMUWAGEO', false, false)
	addBOArr(aACons, at3)
	--Cor
	mulGeoTier(uDefs['corgeo'], ct2Def, ct3Def)
	mergeShield(ct3Def, uDefs['corgatet3'])
	setDesc(ct3Def, t3Name, t3DescP..ct3Def.energymake..t3DescS)
	remodel(ct3Def, 'CORUWAGEO', false, false)
	addBOArr(cACons, ct3)
	--Leg
	mulGeoTier(uDefs['leggeo'], lt2Def, lt3Def)
	mergeShield(lt3Def, uDefs['leggatet3'])
	setDesc(lt3Def, t3Name, t3DescP..lt3Def.energymake..t3DescS)
	remodel(lt3Def, 'legrampart', false, false)
	addBOArr(lACons, lt3)
	--T2
	local ym = 'h cbbybjyybc bjbjjbbjjb yjbjbjjbbb ybjjjbjjjy jbjbjjjbjb bjbjjjbjbj yjjjbjjjby bbbjjbjbjy bjjbbjjbjb cbyyjbybbc'
	at2Def.yardmap = ym
	ct2Def.yardmap = ym
	lt2Def.yardmap = ym
	uDefs['armuwageo'].yardmap = ym
	uDefs['coruwageo'].yardmap = ym
	--Space Mod
	addBO('armoc', at3)
	addBO('coroc', ct3)
	addBO('legoc', lt3)
end