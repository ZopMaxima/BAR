--Lava QoL Patch 1.3 (Zop)
--Quad Pharos pick by MGGW
local mods = Spring.GetModOptions()
local uDefs = UnitDefs or {}
local cps = 'customparams'
local fds = 'featuredefs'
local wds = 'weapondefs'
local wpn = 'weapons'
local aACons = { 'armaca', 'armack', 'armacv', 'armacsub', 'armoc' } --oc Orbital Constructor from Space Mod
local cACons = { 'coraca', 'corack', 'coracv', 'coracsub', 'coroc' }
local lACons = { 'legaca', 'legack', 'legacv', 'legoc' }
local allBOs = {}

local hasLegion = mods.experimentallegionfaction
local hasScavs = mods.scavunitsforplayers
local hasExtras = mods.experimentalextraunits
local hasHoverTide = mods.map_lavatiderhythm == 'enabled' and mods.map_lavalowlevel == 0

local noLRPC = mods.unit_restrictions_nolrpc
local noLOLCannon = mods.unit_restrictions_noendgamelrpc
local noPawnLauncher = noLOLCannon or true --TODO Pawn Bounce Thug Battery etc...
local noNukes = mods.unit_restrictions_nonukes
local noTacs = mods.unit_restrictions_notacnukes
local noSea = mods.map_waterislava
local noAir = mods.unit_restrictions_noair

local removeExcess = true --Delete unpopular units to reduce constructor pages.

local tweakPilum = true
local tweakBehemoth = true
local tweakReclaim = true
local tweakPulsar = true
local tweakWrecks = true
local tweakMini = true
local tweakQuadLT = true
local tweakLegEpic = true
local tweakBBT = true
local tweakTacs = true

--Assign
for id, def in pairs(uDefs) do
	if def and def.buildoptions then
		table.insert(allBOs, id)
	end
end

local function round10(n)
	return math.floor(n * 0.1) * 10
end

local function round100(n)
	return math.floor(n * 0.01) * 100
end

local function mulAll(map, mul)
	for k, v in pairs(map) do
		map[k] = math.floor(v * mul)
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

local function rmvID(id)
	rmvBOArr(allBOs, id)
end

local function delID(id)
	local def = UnitDefs[id]
	if def then
		def.health = 0
	end
end

local function mergeRec(def, ref)
	table.mergeInPlace(def, ref, true)
end

local function setDesc(def, name, tip)
	local latin = { 'en', 'fr', 'de', 'es' }
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
	delID('armbotrail')
end
if noNukes then
	rmvID('armsilo')
	rmvID('corsilo')
	rmvID('legsilo')
	delID('armseadragon')
	delID('cordesolator')
	rmvID('armamd')
	rmvID('corfmd')
	rmvID('legabm')
	rmvID('armscab')
	rmvID('cormabm')
	rmvID('legavantinuke')
	if hasLegion then
		local ramp = uDefs['legrampart']
		ramp[wpn][1] = ramp[wpn][2]
		ramp[wpn][2] = nil
		ramp[wds]['fmd_rocket'].interceptor = nil
	end
end
if noTacs then
	rmvID('armemp')
	rmvID('cortron')
	rmvID('legperdition')
end
if removeExcess then
	rmvBOArr(aACons, 'armdf')
	rmvBOArr(aACons, 'armckfus')
	if hasExtras and hasScavs then
		rmvID('armgmm')
	end
end

--Disable sea and water landing, keep mex and geo.
if noSea then
	local mwd = 'minwaterdepth'
	local uwRef = uDefs['coruwgeo']
	uDefs['armuwgeo'][mwd] = uwRef[mwd]
	for id, def in pairs(uDefs) do
		if def[cps].metal_extractor then
			def.maxwaterdepth = uwRef.maxwaterdepth
		end
		local min = def[mwd]
		if hasHoverTide and min then
			local isEco = def.energymake or def.metalmake or def[cps].unitgroup == 'energy' or def[cps].unitgroup == 'metal'
			if isEco or def.buildoptions or def.waterline == nil then
				rmvID(id)
			else
				def.waterline = 0
				def[mwd] = 1
				def[cps] = def[cps] or {}
				def[cps].enabled_on_no_sea_maps = true
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
	end
end

--Pilum Nerf
if tweakPilum then
	local wDef = uDefs['legbunk'][wds]['piledriver']
	wDef.areaofeffect = wDef.areaofeffect * 0.375
	wDef.weaponvelocity = wDef.weaponvelocity * 0.75
	mulAll(wDef.damage, 0.2)
end

--Behemoth Nerf
if tweakBehemoth then
	local mMul = 2
	local eMul = 2
	if noAir then
		mMul = mMul + 1
	end
	local def = uDefs['corjugg']
	--Compatibility Check
	local cost = def.metalcost
	if cost == 20000 then
		def.metalcost = round100(def.metalcost * mMul)
		def.energycost = round100(def.energycost * eMul)
		def.buildtime = math.floor(def.buildtime * ((mMul + eMul) * 0.5))
	end
	def[cps].paralyzemultiplier = 2.5
end

--Nano Nerf
if tweakReclaim then
	local ws = 'workertime'
	local rs = 'reclaimspeed'
	local sqrtThreshold = 22.5 -- Above 506.25
	for k, v in pairs(uDefs) do
		local bp = v[ws] or v[rs]
		if bp and v.canreclaim and not v.canmove then
			v[rs] = math.min(bp, round10(math.sqrt(bp * mods.multiplier_buildpower) * sqrtThreshold))
		end
	end
end

--Pulsar vs Pulsar
if tweakPulsar then
	local def = uDefs['armannit3']
	if def then
		def[cps].unitmidpos = '0 66 0'
		def[cps].unitaimpos = '0 58 0'
	end
end

--Smaller Wrecks
if tweakWrecks then
	local scale = 0.75
	if noAir then
		scale = 0.25
	end
	local cr = 'crushresistance'
	local mc = 'movementclass'
	local t3Crush = 1400
	local noCrush = 2500000
	local mcMul = 0.4
	local hpMul = 0.1
	for id, def in pairs(uDefs) do
		--Most epic bots are smaller than Titan.
		if def[mc] and def[mc] == 'EPICBOT' then
			def[mc] = 'HABOT5'
		end
		if def.canmove and def[fds] and def[fds].dead then
			local dead = def[fds].dead
			dead.footprintx = math.max(1, math.floor(dead.footprintx * scale))
			dead.footprintz = math.max(1, math.floor(dead.footprintz * scale))
			if def[cps].iscommander then
				dead[cr] = noCrush + 1
			end
			if not dead[cr] then
				local mass = 0
				if dead.mass then
					mass = dead.mass
				elseif def.mass then
					mass = def.mass * mcMul
					if dead.damage then
						mass = mass + (dead.damage * hpMul)
					end
				elseif def.metalcost then
					mass = def.metalcost * mcMul
					if dead.damage then
						mass = mass + (dead.damage * hpMul)
					end
				end
				if mass >= t3Crush and mass < noCrush then
					dead[cr] = t3Crush - 1
				end
			end
		end
	end
	uDefs['armbanth'][mc] = 'EPICBOT'
end

--Mini plasma as 'Cerberus' alternatives.
if hasScavs and tweakMini and hasLegion then
	local rangeMul = 1.25
	local aWDef = uDefs['armminivulc'][wds]['armminivulc_weapon']
	local cWDef = uDefs['corminibuzz'][wds]['corminibuzz_weapon']
	local lWDef = uDefs['legministarfall'][wds]['starfire']
	aWDef.range = round10(aWDef.range * rangeMul)
	cWDef.range = round10(cWDef.range * rangeMul)
	lWDef.range = round10(lWDef.range * rangeMul)
	mulAll(aWDef.damage, 2)
	mulAll(cWDef.damage, 2 * (aWDef.range / cWDef.range))
end

--Quad towers.
if hasScavs and tweakQuadLT and hasLegion then
	local aLT = 'armhllllt'
	local cLT = 'corhllllt'
	local lLT = 'leghllllt'
	local cDef = uDefs[cLT]
	uDefs[aLT] = table.copy(cDef)
	local aDef = uDefs[aLT]
	uDefs[lLT] = table.copy(cDef)
	local lDef = uDefs[lLT]
	for i = 1, 4 do
		local aWDef = aDef[wds]['hllt_' .. i]
		local cWDef = cDef[wds]['hllt_' .. i]
		local lWDef = lDef[wds]['hllt_' .. i]
		mulAll(cWDef.damage, 0.675)
		local dps = cWDef.damage.default / cWDef.reloadtime
		local wr = cWDef.range + 50
		--Arm
		mergeRec(aWDef, uDefs['armbeamer'][wds]['armbeamer_weapon'])
		aWDef.range = wr - 35
		aWDef.reloadtime = aWDef.reloadtime + 0.075
		aWDef.beamtime = aWDef.reloadtime
		aWDef.thickness = aWDef.thickness - ((i - 1) * 0.5)
		mulAll(aWDef.damage, dps / (aWDef.damage.default / aWDef.reloadtime))
		aDef[wpn][i].fastautoretargeting = true
		--Cor
		cWDef.range = wr
		--Leg
		mergeRec(lWDef, uDefs['leglht'][wds]['heat_ray'])
		lWDef.range = wr - 15
		mulAll(lWDef.damage, dps / (lWDef.damage.default / lWDef.reloadtime))
		--Scatter Targets
		local btc = 'badtargetcategory'
		if i == 1 or i == 2 then
			aDef[wpn][i][btc] = 'VTOL GROUNDSCOUT'
			cDef[wpn][i][btc] = aDef[wpn][i][btc]
			lDef[wpn][i][btc] = aDef[wpn][i][btc]
		end
		local pxp = 'proximitypriority'
		if i == 1 or i == 3 then
			aWDef[pxp] = 1
			cWDef[pxp] = 1
			lWDef[pxp] = 1
		end
	end
	setDesc(aDef, 'Quad Beamer', 'Heavy Beam Laser Turret')
	setDesc(lDef, 'Quad Pharos', 'Heavy Heat Ray Tower')
	aDef.icontype = cLT
	lDef.icontype = cLT
	addBOArr(aACons, aLT)
	addBOArr(lACons, lLT)
end

--Legion epic defense.
if hasScavs then
	local cT4 = 'cordoomt3'
	local lT4 = 'legdoomt3'
	local cEvos = { 'corcomlvl8', 'corcomlvl9', 'corcomlvl10' }
	local lEvos = { 'legcomlvl8', 'legcomlvl9', 'legcomlvl10' }
	if tweakLegEpic and hasLegion then
		uDefs[lT4] = table.copy(uDefs[cT4])
		local def = uDefs[lT4]
		local wDef1 = def[wds]['armagmheat']
		local wDef2 = def[wds]['armageddon_blue_laser']
		local wDef3 = def[wds]['armageddon_green_laser']
		mergeRec(wDef1, uDefs['legsrailt4'][wds]['railgunt2'])
		wDef1.reloadtime = wDef1.reloadtime * 2
		wDef1.duration = 0.05
		wDef1.cegtag = 'railgun'
		wDef1.rgbcolor2 = '1 1 1'
		wDef1.areaofeffect = 100
		wDef1.edgeeffectiveness = 0.7
		wDef1.impactonly = nil
		wDef1.collidefriendly = false
		wDef1.stockpile = false
		wDef1.stockpilelimit = 0
		wDef1.thickness = 5
		wDef1.weaponvelocity = wDef1.weaponvelocity * 2.5
		mergeRec(wDef2, uDefs['legerailtank'][wds]['t3_rail_accelerator'])
		wDef2.duration = 0.05
		wDef2.burst = 3
		wDef2.burstrate = 0.25
		wDef2.thickness = 2
		mergeRec(wDef3, uDefs['legdtr'][wds]['corlevlr_weapon'])
		wDef3.reloadtime = wDef3.reloadtime * 0.375
		wDef3.impulsefactor = wDef3.impulsefactor * 2
		wDef3.proximitypriority = 1
		wDef3.rgbcolor = '1 0.8 0'
		setDesc(def, 'Trident', 'Super Heavy Railgun Defense')
		def.icontype = cT4
		addBOArr(lACons, lT4)
		addBOArr(lEvos, lT4)
	else
		addBOArr(lACons, cT4)
		addBOArr(lEvos, cT4)
	end
	addBOArr(cEvos, cT4)
end

--Base Commander
if tweakBBT then
	local bbtIDs = { 'armrespawn', 'correspawn', 'legnanotcbase' }
	for i = 1, #bbtIDs do
		local def = uDefs[bbtIDs[i]]
		if def then
			def[cps] = def[cps] or {}
			def[cps].isscavcommander = true
			def[cps].armordef = 'commanders'
		end
	end
end

--Catch up to EMP.
if tweakTacs then
	local t = 'stockpiletime'
	local cWDef = uDefs['cortron'][wds]['cortron_weapon']
	cWDef.damage.shields = math.floor(cWDef.damage.default * 2.125)
	local lWDef = uDefs['legperdition'][wds]['napalmmissile']
	lWDef.damage.shields = math.floor(lWDef.damage.default * 9.125)
	lWDef[cps].shield_aoe_penetration = true
	local aWDef = uDefs['armemp'][wds]['armemp_weapon']
	local ratio = aWDef[t]
	aWDef[t] = math.max(cWDef[t], lWDef[t]) + math.abs(cWDef[t] - lWDef[t])
	ratio = aWDef[t] / ratio
	aWDef.energypershot = round10(aWDef.energypershot * ratio)
	aWDef.metalpershot = round10(aWDef.metalpershot * ratio)
end