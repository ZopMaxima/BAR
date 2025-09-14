--Lava Multi Patch (Zop)
--T3 Nano/Geo concept by djarshi/Txpera
local mods = Spring.GetModOptions()
local uDefs = UnitDefs or {}
local cps = 'customparams'
local fds = 'featuredefs'
local wds = 'weapondefs'
local wpn = 'weapons'
local aACons = {'armaca','armack','armacv','armacsub'}
local cACons = {'coraca','corack','coracv','coracsub'}
local lACons = {'legaca','legack','legacv'}

local hasScavs = mods.scavunitsforplayers
local hasExtras = mods.experimentalextraunits
local hasHoverTide = mods.map_lavatiderhythm == 'enabled' and mods.map_lavahighlevel <= 1 and mods.map_lavahighdwell <= 1

local noLRPC = mods.unit_restrictions_nolrpc
local noLOLCannon = noLRPC or mods.unit_restrictions_noendgamelrpc
local noPawnLauncher = noLOLCannon or true --TODO
local noNukes = mods.unit_restrictions_nonukes
local noTacs = mods.unit_restrictions_notacnukes
local noSea = mods.map_waterislava
local noAir = mods.unit_restrictions_noair

local removeExcess = true --Delete unpopular units.

local tweakBehemoth = true
local tweakWrecks = true
local tweakMini = true
local tweakQuadLT = true
local tweakLegEpic = true
local tweakT3Nano = true
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

local function rmvID(id)
	local def = UnitDefs[id]
	if def then
		def.health = 0
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

local function rmvBO(conID, id)
	local cDef = UnitDefs[conID]
	local uDef = UnitDefs[id]
	if cDef and uDef then
		for k, v in pairs(cDef.buildoptions) do
			if v == id then
				table.remove(cDef.buildoptions, k)
				break
			end
		end
	end
end

local function rmvBOArr(conIDs, id)
	for i = 1, #conIDs do
		rmvBO(conIDs[i], id)
	end
end

local function mergeRec(def, ref)
	table.mergeInPlace(def, ref, true)
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

--Deleted Units
if noLRPC then
	rmvID('armbrtha')
	rmvID('corint')
	rmvID('corslrpc')
	rmvID('leglrpc')
	rmvID('legelrpcmech')
end
if noLOLCannon then
	rmvID('armvulc')
	rmvID('corbuzz')
	rmvID('legstarfall')
end
if noPawnLauncher then
	rmvID('armbotrail')
end
if noNukes then
	rmvID('armsilo')
	rmvID('corsilo')
	rmvID('legsilo')
	rmvID('armseadragon')
	rmvID('cordesolator')
	rmvID('armamd')
	rmvID('corfmd')
	rmvID('legabm')
	rmvID('armscab')
	rmvID('cormabm')
	local ramp = uDefs['legrampart']
	ramp[wpn][1] = ramp[wpn][2]
	ramp[wpn][2] = nil
	ramp[wds]['fmd_rocket'].interceptor = nil
end
if noTacs then
	rmvID('armemp')
	rmvID('cortron')
	rmvID('legperdition')
end
if removeExcess then
	rmvBOArr(aACons, 'armckfus')
	rmvBOArr(lACons, 'cormexp')
end

--Disable sea and water landing.
if noSea then
	local mwd = 'minwaterdepth'
	for id, def in pairs(uDefs) do
		local min = def[mwd]
		if hasHoverTide and min then
			local isEco = def.energymake or def.metalmake or def[cps].unitgroup == 'energy' or def[cps].unitgroup == 'metal'
			if isEco or def.buildoptions or def.waterline == nil then
				rmvID(id)
			else
				def.waterline = 0
				def[mwd] = 1
			end
		elseif min and min > 0 then
			rmvID(id)
		end
		if def.cruisealtitude then
			if def.cansubmerge then
				def.cansubmerge = false
			end
			if def.maxwaterdepth then
				def.maxwaterdepth = 0
			end
		end
		--Metal
		if def[cps].metal_extractor then
			def.maxwaterdepth = 0
		end
	end
	--Geo
	uDefs['armuwgeo'][mwd] = uDefs['coruwgeo'][mwd]
end

--Behemoth Nerf
if tweakBehemoth then
	local def = uDefs['corjugg']
	local mcMul = 2
	if noAir then
		mcMul = mcMul + 1
	end
	def.metalcost = def.metalcost * mcMul
	def.buildtime = def.buildtime * mcMul
	def[cps].paralyzemultiplier = 2.5
end

--Smaller Wrecks
if tweakWrecks then
	local scale = 0.75
	if noAir then
		scale = 0.5
	end
	for id, def in pairs(uDefs) do
		if def.canmove and def[fds] and def[fds].dead then
			local dead = def[fds].dead
			dead.footprintx = math.max(1, math.floor(dead.footprintx * scale))
			dead.footprintz = math.max(1, math.floor(dead.footprintz * scale))
		end
	end
end

--Mini plasma as 'Cerberus' alternatives.
if hasScavs and tweakMini then
	local rangeMul = 1.25
	local epsMul = 0.5
	local aWDef = uDefs['armminivulc'][wds]['armminivulc_weapon']
	local cWDef = uDefs['corminibuzz'][wds]['corminibuzz_weapon']
	local lWDef = uDefs['legministarfall'][wds]['ministarfire']
	aWDef.range = round10(aWDef.range * rangeMul)
	cWDef.range = round10(cWDef.range * rangeMul)
	lWDef.range = round10(lWDef.range * rangeMul)
	local eps = 'energypershot'
	aWDef[eps] = aWDef[eps] * epsMul
	cWDef[eps] = cWDef[eps] * epsMul
	lWDef[eps] = lWDef[eps] * epsMul
end

--Quad towers.
if hasScavs and tweakQuadLT then
	local aLT = 'armhllllt'
	local cLT = 'corhllllt'
	local lLT = 'leghllllt'
	local cDef = uDefs[cLT]
	uDefs[aLT] = table.copy(cDef)
	local aDef = uDefs[aLT]
	uDefs[lLT] = table.copy(cDef)
	local lDef = uDefs[lLT]
	for i = 1, 4 do
		local cWDef = cDef[wds]['hllt_'..i]
		local aWDef = aDef[wds]['hllt_'..i]
		local lWDef = lDef[wds]['hllt_'..i]
		--Cor
		cWDef.range = round10(cWDef.range * 1.25)
		--Arm
		mergeRec(aWDef, uDefs['armbeamer'][wds]['armbeamer_weapon'])
		aWDef.range = round10(aWDef.range * 1.2)
		aWDef.reloadtime = aWDef.reloadtime + (i * 0.025)
		aWDef.beamtime = aWDef.reloadtime * 2
		aWDef.damage.default = aWDef.damage.default * 1.5
		--Leg
		aDef[wpn][i]['fastautoretargeting'] = true
		mergeRec(lWDef, uDefs['legmg'][wds]['armmg_weapon'])
	end
	setDesc(aDef, 'Quad Beamer', 'Heavy Beam Laser Turret')
	setDesc(lDef, 'Quad Cacophony', 'Heavy Machine Gun Turret')
	aDef.icontype = cLT
	lDef.icontype = cLT
	addBOArr(aACons, aLT)
	addBOArr(lACons, lLT)
	--Space Mod
	addBO('armoc', aLT)
	addBO('legoc', lLT)
end

--Legion epic defense.
if hasScavs then
	local cT4 = 'cordoomt3'
	local lT4 = 'legdoomt3'
	local cEvos = {'corcomlvl8', 'corcomlvl9', 'corcomlvl10'}
	local lEvos = {'legcomlvl8', 'legcomlvl9', 'legcomlvl10'}
	if tweakLegEpic then
		uDefs[lT4] = table.copy(uDefs[cT4])
		local def = uDefs[lT4]
		local wDef1 = def[wds]['armagmheat']
		local wDef2 = def[wds]['armageddon_blue_laser']
		local wDef3 = def[wds]['armageddon_green_laser']
		mergeRec(wDef1, uDefs['legsrailt4'][wds]['railgunt2'])
		wDef1.cegtag = 'railgun'
		wDef1.collidefriendly = false
		wDef1.rgbcolor2 = '1 1 1'
		wDef1.weaponvelocity = wDef1.weaponvelocity * 1.5
		mergeRec(wDef2, uDefs['legerailtank'][wds]['t3_rail_accelerator'])
		wDef2.range = round10(wDef2.range * 1.5)
		mergeRec(wDef3, uDefs['legdtr'][wds]['corlevlr_weapon'])
		wDef3.reloadtime = wDef3.reloadtime * 0.375
		wDef3.rgbcolor = '1 0.8 0'
		setDesc(def, 'Trident', 'Super Heavy Railgun Defense')
		def.icontype = cT4
		addBOArr(lACons, lT4)
		addBOArr(lEvos, lT4)
		--Space Mod
		addBO('legoc', lT4)
	else
		addBOArr(lACons, cT4)
		addBOArr(lEvos, cT4)
		--Space Mod
		addBO('legoc', cT4)
	end
	addBOArr(cEvos, cT4)
end

--T3 Nano
if hasExtras and tweakT3Nano and not uDefs['armnanotct3'] then
	local footMul = 1.25
	local at1Def = uDefs['armnanotc']
	local at2Def = uDefs['armnanotct2']
	if at1Def and at2Def then
		local ex = 'hugeBuildingExplosionGeneric'
		local override = {
			icontype = 'armrespawn',
			metalcost = extrapolate(at1Def.metalcost, at2Def.metalcost) * footMul,
			energycost = extrapolate(at1Def.energycost, at2Def.energycost) * footMul,
			buildtime = extrapolate(at1Def.buildtime, at2Def.buildtime) * footMul,
			workertime = extrapolate(at1Def.workertime, at2Def.workertime) * footMul,
			builddistance = extrapolate(at1Def.builddistance, at2Def.builddistance),
			sightdistance = extrapolate(at1Def.sightdistance, at2Def.sightdistance),
			health = extrapolate(at1Def.health, at2Def.health),
			maxwaterdepth = 1000000,
			minwaterdepth = -1000000,
			explodeas = ex,
			selfdestructas = ex..'Selfd',
			customparams = {
				techlevel = 3
			}
		}
		local at3 = 'armnanotct3'
		local ct3 = 'cornanotct3'
		local lt3 = 'legnanotct3'
		uDefs[at3] = table.merge(uDefs['armrespawn'], override)
		uDefs[ct3] = table.merge(uDefs['correspawn'], override)
		uDefs[lt3] = table.merge(uDefs['legnanotcbase'], override)
		local at3Def = uDefs[at3]
		local ct3Def = uDefs[ct3]
		local lt3Def = uDefs[lt3]
		if noSea then
			unwater(at3)
			unwater(ct3)
			unwater(lt3)
		end
		local t3Name = 'Epic Construction Turret'
		local t3Desc = 'Assist & Repair in massive radius. (OP by djarshi)'
		setDesc(at3Def, t3Name, t3Desc)
		setDesc(ct3Def, t3Name, t3Desc)
		setDesc(lt3Def, t3Name, t3Desc)
		addBOArr(aACons, at3)
		addBOArr(cACons, ct3)
		addBOArr(lACons, lt3)
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

--T3 Geo
if hasExtras and tweakT3Geo and not uDefs['armageot3'] then
	--TODO Move prude to combat, keep shockwave.
	rmvID('armshockwave')
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