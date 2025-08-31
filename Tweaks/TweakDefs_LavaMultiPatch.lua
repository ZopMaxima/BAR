--Lava Multi Patch (Zop)
--T3 Nano/Geo concept by djarshi/Txpera
local mods = Spring.GetModOptions()
local uDefs = UnitDefs or {}
local cps = 'customparams'
local fds = 'featuredefs'
local wds = 'weapondefs'
local wpn = 'weapons'
local aACons = {'armaca','armack','armacv'}
local cACons = {'coraca','corack','coracv'}
local lACons = {'legaca','legack','legacv'}

local hasScavs = mods.scavunitsforplayers
local hasExtras = mods.experimentalextraunits

local noLRPC = mods.unit_restrictions_nolrpc
local noLOLCannon = noLRPC or mods.unit_restrictions_noendgamelrpc
local noPawnLauncher = noLOLCannon or true --TODO
local noNukes = mods.unit_restrictions_nonukes
local noTacs = mods.unit_restrictions_notacnukes
local noSea = mods.map_waterislava
local noAir = mods.unit_restrictions_noair

local removeExcess = true

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

local function rmvBO(builderID, id)
	local bDef = UnitDefs[builderID]
	local uDef = UnitDefs[id]
	if bDef and uDef then
		for k, v in pairs(bDef.buildoptions) do
			if v == id then
				table.remove(bDef.buildoptions, k)
				break
			end
		end
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

local function setDesc(def, name, tip)
	local latin = { 'en', 'fr', 'de' }
	if def then
		for i = 1, #latin do
			if name then
				def[cps]['i18n_' .. latin[i] .. '_humanname'] = name
			end
			if tip then
				def[cps]['i18n_' .. latin[i] .. '_tooltip'] = tip
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

--Hide LRPC
if noLRPC then
	rmvID('armbrtha')
	rmvID('corint')
	rmvID('corslrpc')
	rmvID('leglrpc')
	rmvID('legelrpcmech')
end

--Hide LOL Cannon
if noLOLCannon then
	rmvID('armvulc')
	rmvID('corbuzz')
	rmvID('legstarfall')
end

--Hide Pawn Launcher
if noPawnLauncher then
	rmvID('armbotrail')
end

--Hide Nukes
if noNukes then
	--TODO Enable Rampart
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
end

--Hide Tac Nukes
if noTacs then
	rmvID('armemp')
	rmvID('cortron')
	rmvID('legperdition')
end

--Remove clutter from build menus.
if removeExcess then
	--Arm
	rmvBO('armaca', 'armckfus')
	rmvBO('armack', 'armckfus')
	rmvBO('armacv', 'armckfus')
	--Leg
	rmvBO('legaca', 'cormexp')
	rmvBO('legack', 'cormexp')
	rmvBO('legacv', 'cormexp')
end

--Disable sea and water landing.
if noSea then
	for id, def in pairs(uDefs) do
		local minWD = def.minwaterdepth
		if minWD then
			if minWD > 0 then
				rmvID(id)
			end
		end
		if def.cruisealtitude then
			if def.cansubmerge then
				def.cansubmerge = false
			end
			if def.maxwaterdepth then
				def.maxwaterdepth = 0
			end
		end
	end
end

--Behemoth Nerf
if tweakBehemoth then
	local beheDef = uDefs['corjugg']
	local beheMul = 2.5
	if noAir then
		beheMul = beheMul + 1
	end
	beheDef.metalcost = beheDef.metalcost * beheMul
	beheDef.customparams.paralyzemultiplier = 2.5
end

--Smaller Wrecks
if tweakWrecks then
	local scale = 0.75
	if noAir then
		scale = 0.5
	end
	for id, def in pairs(uDefs) do
		if def.canmove and def.featuredefs and def.featuredefs.dead then
			local dead = def.featuredefs.dead
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
	local cLT = 'corhllllt'
	local aLT = 'corscavdtl'
	local lLT = 'corscavdtf'
	local cLTDef = uDefs[cLT]
	local aLTDef = uDefs[aLT]
	local lLTDef = uDefs[lLT]
	mergeMapRec(aLTDef, cLTDef)
	mergeMapRec(lLTDef, cLTDef)
	for i = 1, 4 do
		local cLTWDef = cLTDef[wds]['hllt_' .. i]
		local aLTWDef = aLTDef[wds]['hllt_' .. i]
		local lLTWDef = lLTDef[wds]['hllt_' .. i]
		cLTWDef.range = round10(cLTWDef.range * 1.25)
		mergeMapRec(aLTWDef, uDefs['armbeamer'][wds]['armbeamer_weapon'])
		aLTWDef.range = round10(aLTWDef.range * 1.2)
		aLTWDef.reloadtime = aLTWDef.reloadtime + (i * 0.025)
		aLTWDef.beamtime = aLTWDef.reloadtime * 2
		aLTWDef.damage.default = aLTWDef.damage.default * 1.5
		aLTDef.weapons[i]['fastautoretargeting'] = true
		mergeMapRec(lLTWDef, uDefs['legmg'][wds]['armmg_weapon'])
	end
	setDesc(aLTDef, 'Quad Beamer', 'Heavy Beam Laser Turret')
	setDesc(lLTDef, 'Quad Cacophony', 'Heavy Machine Gun Turret')
	aLTDef.icontype = cLT
	lLTDef.icontype = cLT
	addBOArr(aACons, aLT)
	addBOArr(lACons, lLT)
end

--Legion epic defense.
if hasScavs then
	local cDoom = 'cordoomt3'
	local lDoom = 'corscavdtm'
	if tweakLegEpic then
		local cDoomDef = uDefs[cDoom]
		local lDoomDef = uDefs[lDoom]
		mergeMapRec(lDoomDef, cDoomDef)
		local lDoomWDef1 = lDoomDef[wds]['armagmheat']
		local lDoomWDef2 = lDoomDef[wds]['armageddon_blue_laser']
		local lDoomWDef3 = lDoomDef[wds]['armageddon_green_laser']
		mergeMapRec(lDoomWDef1, uDefs['legsrailt4'][wds]['railgunt2'])
		lDoomWDef1.cegtag = 'railgun'
		lDoomWDef1.collidefriendly = false
		lDoomWDef1.rgbcolor2 = '1 1 1'
		lDoomWDef1.weaponvelocity = lDoomWDef1.weaponvelocity * 1.5
		mergeMapRec(lDoomWDef2, uDefs['legerailtank'][wds]['t3_rail_accelerator'])
		lDoomWDef2.range = round10(lDoomWDef2.range * 1.5)
		mergeMapRec(lDoomWDef3, uDefs['legdtr'][wds]['corlevlr_weapon'])
		lDoomWDef3.reloadtime = lDoomWDef3.reloadtime * 0.375
		lDoomWDef3.rgbcolor = '1 0.8 0'
		setDesc(lDoomDef, 'Trident', 'Super Heavy Railgun Defense')
		lDoomDef.icontype = cDoom
		addBOArr(lACons, lDoom)
		addBO('legcomlvl8', lDoom)
		addBO('legcomlvl9', lDoom)
		addBO('legcomlvl10', lDoom)
	else
		addBOArr(lACons, cDoom)
		addBO('legcomlvl8', cDoom)
		addBO('legcomlvl9', cDoom)
		addBO('legcomlvl10', cDoom)
	end
	addBO('corcomlvl8', cDoom)
	addBO('corcomlvl9', cDoom)
	addBO('corcomlvl10', cDoom)
end

--Multiply and overwrite stats.
if hasExtras and tweakT3Nano then
	local footprintMul = 1.25
	local at1Def = uDefs['armnanotc']
	local at2Def = uDefs['armnanotct2']
	local aBaseDef = uDefs['armrespawn']
	local cBaseDef = uDefs['correspawn']
	local lBaseDef = uDefs['legnanotcbase']
	if at1Def and at2Def and aBaseDef then
		local statOverride = {
			icontype = 'armrespawn',
			metalcost = extrapolate(at1Def.metalcost, at2Def.metalcost) * footprintMul,
			energycost = extrapolate(at1Def.energycost, at1Def.energycost) * footprintMul,
			buildtime = extrapolate(at1Def.buildtime, at2Def.buildtime) * footprintMul,
			workertime = extrapolate(at1Def.workertime, at2Def.workertime) * footprintMul,
			builddistance = extrapolate(at1Def.builddistance, at2Def.builddistance),
			sightdistance = extrapolate(at1Def.sightdistance, at2Def.sightdistance),
			health = extrapolate(at1Def.health, at2Def.health),
			explodeas = 'hugeBuildingExplosionGeneric',
			selfdestructas = 'hugeBuildingExplosionGenericSelfd',
			customparams = {
				techlevel = 3
			}
		}
		local at3 = 'armnanotct3'
		local ct3 = 'cornanotct3'
		local lt3 = 'legnanotct3'
		uDefs[at3] = table.merge(aBaseDef, statOverride)
		uDefs[ct3] = table.merge(cBaseDef, statOverride)
		uDefs[lt3] = table.merge(lBaseDef, statOverride)
		local at3Def = uDefs[at3]
		local ct3Def = uDefs[ct3]
		local lt3Def = uDefs[lt3]
		local t3Name = 'Epic Construction Turret'
		local t3Desc = 'Assist & Repair in massive radius. (Concept by djarshi)'
		--Arm
		unwater(at3)
		setDesc(at3Def, t3Name, t3Desc)
		addBOArr(aACons, at3)
		--Cor
		unwater(ct3)
		setDesc(ct3Def, t3Name, t3Desc)
		addBOArr(cACons, ct3)
		--Leg
		unwater(lt3)
		setDesc(lt3Def, t3Name, t3Desc)
		addBOArr(lACons, lt3)
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
if hasExtras and tweakT3Geo then
	--TODO Move prude to combat, too many Arm eco buildings.
	rmvID('armshockwave')
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
	local t3DescSfx = ' Energy (Extremely Hazardous) (Concept by djarshi)'
	--Arm
	mulGeoTier(at1Def, at2Def, at3Def)
	mergeDeflector(at3Def, uDefs['armgatet3'])
	setDesc(at3Def, t3Name, t3DescPfx .. at3Def.energymake .. t3DescSfx)
	remodel(at3Def, 'ARMUWAGEO', false, false)
	addBOArr(aACons, at3)
	--Cor
	mulGeoTier(ct1Def, ct2Def, ct3Def)
	mergeDeflector(ct3Def, uDefs['corgatet3'])
	setDesc(ct3Def, t3Name, t3DescPfx .. ct3Def.energymake .. t3DescSfx)
	remodel(ct3Def, 'CORUWAGEO', false, false)
	addBOArr(cACons, ct3)
	--Leg
	mulGeoTier(lt1Def, lt2Def, lt3Def)
	mergeDeflector(lt3Def, uDefs['leggatet3'])
	setDesc(lt3Def, t3Name, t3DescPfx .. lt3Def.energymake .. t3DescSfx)
	remodel(lt3Def, 'legrampart', false, false)
	addBOArr(lACons, lt3)
	--T2
	local yardmap =
	'h cbbybjyybc bjbjjbbjjb yjbjbjjbbb ybjjjbjjjy jbjbjjjbjb bjbjjjbjbj yjjjbjjjby bbbjjbjbjy bjjbbjjbjb cbyyjbybbc'
	at2Def.yardmap = yardmap
	ct2Def.yardmap = yardmap
	lt2Def.yardmap = yardmap
end