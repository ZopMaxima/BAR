--Commando Pack (Zop)
--Unit names must contain 'cormando' for unit_commando_watch.lua.
local uDefs = UnitDefs or {}
local cps = 'customparams'
local fds = 'featuredefs'
local wds = 'weapondefs'
local wpn = 'weapons'

local tweakArm = true
local tweakCor = true
local tweakLeg = true
local tweakT4 = true

local function round10(n)
	return math.floor(n * 0.1) * 10
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
	local latin = {'en','fr','de','es'}
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

local function declutter(def, sight)
	if def then
		def.builddistance = 200
		def.sightdistance = sight
		def.airsightdistance = sight
		def.energymake = nil
		def.energystorage = nil
		def.sonardistancejam = nil
	end
end

local function cloak(def, rank)
	local range = { 60, 75, 90, 100 }
	local drain = { 50, 100, 200, 300 }
	rank = math.max(1, math.min(rank, #range))
	if def then
		def.cancloak = true
		def.mincloakdistance = range[rank]
		def.radardistancejam = range[rank]
		def.sonardistancejam = range[rank]
		def.cloakcost = drain[rank]
		def.cloakcostmoving = round10(drain[rank] * 5)
	end
end

local function mulPrice(def, m, e)
	if def then
		def.metalcost = round10(def.metalcost * m)
		def.energycost = round10(def.energycost * e)
		def.buildtime = round10(def.buildtime * (m + e) * 0.5)
	end
end

local function corpse(def, ref)
	if def then
		def.corpse = 'DEAD'
		def[fds] = def[fds] or {}
		def[fds].dead = table.copy(uDefs[ref][fds].dead)
		def[fds].heap = table.copy(uDefs[ref][fds].heap)
		def[fds].dead.metal = def.metalcost * 0.625
		def[fds].heap.metal = def.metalcost * 0.375
	end
end

local function mulDamage(def, m)
	if def and def.damage then
		local d = def.damage
		for k, v in pairs(d) do
			d[k] = math.floor(v * m) or 1
		end
	end
end

--Cor
local corID = 'cormando'
if tweakCor and uDefs[corID] then
	local def = uDefs[corID]
	declutter(def, def.sightdistance)
	cloak(def, 2)
	def.corpse = 'HEAP'
	def[fds] = def[fds] or {}
	def[fds].heap = table.copy(uDefs['corfast'][fds].heap)
	def[fds].heap.metal = def.metalcost * 0.5
end

--Cor T4
local corT4ID = 'cormandot4'
if tweakCor and tweakT4 and uDefs[corT4ID] then
	local def = uDefs[corT4ID]
	declutter(def, def.sightdistance)
	cloak(def, 3)
	def.corpse = 'HEAP'
	def[fds] = def[fds] or {}
	def[fds].heap = table.copy(uDefs['corshiva'][fds].heap)
	def[fds].heap.metal = def.metalcost * 0.5
	def.explodeas = 'largeExplosionGeneric'
	def.selfdestructas = 'largeExplosionGenericSelfd'
end

--Arm (legcomt2off)
if tweakArm and uDefs[corID] then
	local newID = 'acormando'
	uDefs[newID] = table.copy(uDefs[corID])
	local def = uDefs[newID]
	remodel(def, 'LEGCOMOFF', false, false)
	setDesc(def, 'Vandal', 'Combat Commando Bot')
	def.buildpic = 'LEGCOMT2OFF.DDS'
	def.icontype = corID
	def.buildoptions = {
		'armeyes',
		'armferret',
		'armpb',
		'armdrag',
		'armclaw',
		'armatlas',
		'armhvytrans',
		'armamex',
	}
	def.health = def.health * 1.5
	def.speed = 50
	declutter(def, def.sightdistance * 1.5)
	cloak(def, 3)
	mulPrice(def, 2.5, 1.5)
	corpse(def, 'legcomt2off')
	def.explodeas = 'largeExplosionGeneric'
	def.selfdestructas = 'largeExplosionGenericSelfd'
	def.radardistance = nil
	def.canmanualfire = true
	def.canresurrect = true
	def.canrestore = true
	--Left
	local wDefL = def[wds]['commando_blaster']
	clear(wDefL)
	mergeRec(wDefL, uDefs['legmg'][wds]['armmg_weapon'])
	wDefL.name = 'Rapid-Fire Machine Gun'
	wDefL.range = 380
	wDefL.burst = 3
	wDefL.burstrate = 0.066
	wDefL.reloadtime = wDefL.burst * wDefL.burstrate
	wDefL.weaponvelocity = wDefL.weaponvelocity * 1.5
	wDefL.overpenetrate = true
	wDefL.impactonly = nil
	wDefL[cps] = wDefL[cps] or {}
	wDefL[cps].weapons_group = 1
	--Right
	def[wds].janus_rocket = table.copy(uDefs['armjanus'][wds]['janus_rocket'])
	local wDefR = def[wds]['janus_rocket']
	wDefR.name = 'High-Explosive Missile Launcher'
	wDefR.range = wDefL.range
	wDefR.areaofeffect = wDefR.areaofeffect * 1.5
	wDefR.commandfire = true
	mulDamage(wDefR, 2)
	wDefR[cps] = wDefR[cps] or {}
	wDefR[cps].weapons_group = 1
	def[wpn][3] = table.copy(uDefs['armjanus'][wpn][1])
	--Lab
	addBO('armalab', newID)
end

--Arm T4 (legcomt2com)
if tweakArm and tweakT4 and uDefs[corT4ID] then
	local newID = 'acormandot4'
	uDefs[newID] = table.copy(uDefs[corT4ID])
	local def = uDefs[newID]
	remodel(def, 'LEGCOMT2COM', false, false)
	setDesc(def, 'Epic Vandal', 'Heavy Combat Commando Bot')
	def.buildpic = 'LEGCOMT2COM.DDS'
	def.icontype = corID
	def.buildoptions = {
		'armeyes',
		'armferret',
		'armpb',
		'armamb',
		'armemp',
		'armdrag',
		'armfort',
		'armclaw',
		'armlwall',
		'armatlas',
		'armhvytrans',
		'armshockwave',
	}
	def.health = def.health * 2
	def.speed = 30
	declutter(def, def.sightdistance * 2)
	cloak(def, 4)
	mulPrice(def, 2.5, 1.5)
	corpse(def, 'legcomt2com')
	def.explodeas = 'hugeExplosionGeneric'
	def.selfdestructas = 'hugeExplosionGenericSelfd'
	def.radardistance = nil
	def.canresurrect = true
	def.canrestore = true
	--Left
	local wDefL = def[wds]['commando_stunner']
	clear(wDefL)
	mergeRec(wDefL, uDefs['acormando'][wds]['commando_blaster'])
	wDefL.name = 'Dual Rapid-Fire Machine Gun'
	wDefL.range = 420
	wDefL.burstrate = wDefL.burstrate * 0.5
	wDefL.reloadtime = wDefL.reloadtime * 0.25
	wDefL.thickness = wDefL.thickness * 1.25
	wDefL.overpenetrate = true
	wDefL.impactonly = nil
	mulDamage(wDefL, 1.5)
	--Shoulder
	def[wds].armpb_weapon = table.copy(uDefs['armpb'][wds]['armpb_weapon'])
	local wDefS = def[wds]['armpb_weapon']
	wDefS.name = 'Burst-Fire Gauss Cannon'
	wDefS.range = wDefL.range
	wDefS.commandfire = true
	wDefS.stockpile = true
	wDefS.metalpershot = 24
	wDefS.stockpiletime = 5
	wDefS.reloadtime = 0.125
	wDefS[cps] = wDefS[cps] or {}
	wDefS[cps].stockpilelimit = 6
	wDefS[cps].weapons_group = 1
	def[wpn][1].onlytargetcategory = 'NOTAIR'
	def[wpn][2] = nil
	def[wpn][5] = table.copy(uDefs['armpb'][wpn][1])
	--Lab
	addBO('armshltx', newID)
	addBO('armshltxuw', newID)
end

--Leg (legcomlvl2)
if tweakLeg and uDefs[corID] then
	local newID = 'lcormando'
	uDefs[newID] = table.copy(uDefs[corID])
	local def = uDefs[newID]
	remodel(def, 'legevocom1', false, false)
	setDesc(def, 'Saboteur', 'Utility Commando Bot')
	def.buildpic = 'LEGCOM.DDS'
	def.icontype = corID
	def.buildoptions = {
		'legeyes',
		'legrad',
		'legjam',
		'legrl',
		'legcib',
		'leglts',
		'legscout',
	}
	def.health = def.health * 0.5
	def.speed = 50
	def.istargetingupgrade = true
	declutter(def, 250)
	cloak(def, 1)
	mulPrice(def, 0.5, 3)
	corpse(def, 'legcomlvl2')
	def.radardistance = 1250
	def.canmanualfire = true
	def.cancapture = true
	--Left
	local wDefL = def[wds]['commando_blaster']
	clear(wDefL)
	mergeRec(wDefL, uDefs['legmg'][wds]['armmg_weapon'])
	wDefL.name = 'Incendiary Machine Gun'
	wDefL.range = 300
	wDefL.explosiongenerator = 'custom:genericshellexplosion-tiny-aa'
	clear(wDefL.damage)
	wDefL.damage.default = 4
	wDefL.damage.vtol = 2
	wDefL.customparams = {
		area_onhit_ceg = 'fire-area-37-repeat',
		area_onhit_damageCeg = 'burnflame-xs',
		area_onhit_resistance = 'fire',
		area_onhit_damage = 15,
		area_onhit_range = 37.5,
		area_onhit_time = 3,
		water_splash = 0,
	}
	--Right
	def[wds]['corlevlr_weapon'] = table.copy(uDefs['legdtr'][wds]['corlevlr_weapon'])
	local wDefR = def[wds]['corlevlr_weapon']
	wDefR.name = 'Shieldbreaker Grenade'
	wDefR.range = wDefL.range
	wDefR.commandfire = true
	wDefR.stockpile = true
	wDefR.energypershot = 5000
	wDefR.stockpiletime = 10
	wDefR.reloadtime = 1
	wDefR.waterweapon = true
	wDefR.impulsefactor = 100
	wDefR.areaofeffect = 100
	wDefR.craterareaofeffect = 100
	wDefR.craterboost = 1
	wDefR.cratermult = 1
	wDefR.rgbcolor = '1 1 1'
	wDefR.explosiongenerator = 'custom:starfire-explosion'
	wDefR.avoidfeature = false
	wDefR.avoidfriendly = false
	wDefR.collideenemy = true
	wDefR.collidefriendly = true
	wDefR.collidefeature = true
	wDefR.noselfdamage = false
	wDefR[cps] = wDefR[cps] or {}
	wDefR[cps].stockpilelimit = 1
	wDefR[cps].weapons_group = 1
	wDefR[cps].place_target_on_ground = 'true'
	clear(wDefR.damage)
	wDefR.damage.default = 50
	wDefR.damage.shields = 10000
	def[wpn][3] = table.copy(uDefs['legdtr'][wpn][1])
	--Lab
	addBO('legalab', newID)
end

--Leg T4 (legcomlvl10)
if tweakLeg and tweakT4 and uDefs[corT4ID] then
	local newID = 'lcormandot4'
	uDefs[newID] = table.copy(uDefs[corT4ID])
	local def = uDefs[newID]
	remodel(def, 'legevocom3', false, false)
	setDesc(def, 'Epic Saboteur', 'Refined Utility Commando Bot')
	def.buildpic = 'LEGCOM.DDS'
	def.icontype = corID
	def.buildoptions = {
		'legeyes',
		'legaradk',
		'legajamk',
		'legperdition',
		'legcib',
		'legwhisper',
		'legrhapsis',
		'leglupara',
		'leglts',
		'legatrans',
		'legaspy',
		'legdecom',
	}
	def.health = def.health * 0.5
	def.speed = 55
	declutter(def, 300)
	cloak(def, 2)
	mulPrice(def, 0.5, 3)
	corpse(def, 'legcomlvl10')
	def.radardistance = 1800
	def.canmanualfire = true
	def.cancapture = true
	--Left
	local wDefL = def[wds]['commando_stunner']
	clear(wDefL)
	mergeRec(wDefL, uDefs['lcormando'][wds]['commando_blaster'])
	wDefL.name = 'Heavy Incendiary Autocannon'
	wDefL.range = 300
	wDefL.burst = 3
	wDefL.burstrate = wDefL.burstrate * 3
	wDefL.reloadtime = wDefL.burst * wDefL.burstrate
	wDefL.thickness = wDefL.thickness * 2
	wDefL.explosiongenerator = 'custom:genericshellexplosion-small-air'
	wDefL[cps].area_onhit_damage = 75
	--Right
	local wDefR = def[wds]['commando_back_cannon']
	clear(wDefR)
	mergeRec(wDefR, uDefs[corT4ID][wds]['commando_stunner'])
	wDefR.name = 'Shieldbreaker Burst'
	wDefR.range = wDefL.range
	wDefR.commandfire = true
	wDefR.stockpile = true
	wDefR.energypershot = 25000
	wDefR.stockpiletime = 10
	wDefR.reloadtime = 1
	wDefR.projectiles = nil
	wDefR.waterweapon = true
	wDefR.impulsefactor = 50
	wDefR.paralyzer = nil
	wDefR.paralyzetime = nil
	wDefR.sprayangle = nil
	wDefR.beamttl = 0.4
	wDefR.areaofeffect = 100
	wDefR.craterareaofeffect = 100
	wDefR.craterboost = 1
	wDefR.cratermult = 1
	wDefR.explosiongenerator = 'custom:starfire-explosion'
	wDefR.avoidfeature = false
	wDefR.avoidfriendly = false
	wDefR.collideenemy = true
	wDefR.collidefriendly = true
	wDefR.collidefeature = true
	wDefR.noselfdamage = false
	wDefR[cps] = wDefR[cps] or {}
	wDefR[cps].stockpilelimit = 1
	wDefR[cps].weapons_group = 1
	wDefR[cps].place_target_on_ground = 'true'
	clear(wDefR.damage)
	wDefR.damage.default = 250
	wDefR.damage.shields = 50000
	--Shoulder
	def[wds]['emp'] = table.copy(uDefs['armthor'][wds]['emp'])
	local wDefS = def[wds]['emp']
	wDefS.range = wDefL.range
	wDefS.thickness = wDefL.thickness * 0.25
	wDefS[cps].weapons_group = 1
	wDefS[cps].soundstart_volume_multiplier = 0.5
	mulDamage(wDefS, 2)
	wDefS.proximitypriority = 1
	wDefS.soundstart = 'beamershot2'
	def[wpn][1].onlytargetcategory = 'NOTAIR'
	def[wpn][2].onlytargetcategory = 'NOTAIR'
	def[wpn][4] = {
		def = 'EMP',
		fastautoretargeting = true,
		onlytargetcategory = 'EMPABLE',
		badtargetgategory = 'VTOL NOTWEAPON',
	}
	--Lab
	addBO('leggant', newID)
	addBO('leggantuw', newID)
end