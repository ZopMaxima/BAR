--Commando Pack 1.1 (Zop)
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

local catJunoTarget = 'JUNOTARGET'

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

local function categorize(def, key, cat)
	if def then
		if def[key] then
			def[key] = def[key]..' '..cat
		else
			def[key] = cat
		end
	end
end

local function hasCategory(def, cat)
	local s = def and def.category
	return s and string.find(' '..s..' ', ' '..cat..' ', 1, true) ~= nil
end

local function declutter(def, sight)
	if def then
		def.builddistance = 200
		def.sightdistance = sight
		def.airsightdistance = sight * 1.5
		def.energymake = nil
		def.energystorage = nil
	end
end

local function cloak(def, rank)
	local range = { 65, 75, 90, 100 }
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

local function overpen(w)
	w.impactonly = true
	w.noExplode = true
	w[cps] = w[cps] or {}
	w[cps].overpenetrate = true
	w[cps].overpenetrate_falloff = false
end

local function dgun(w, range)
	w.range = range
	w.commandfire = true
	w[cps] = w[cps] or {}
	w[cps].weapons_group = 1
end

local function legDgun(w, range, energy)
	dgun(w, range)
	w.stockpile = true
	w.energypershot = energy
	w.stockpiletime = 10
	w.reloadtime = 1
	w.waterweapon = true
	w.impulseboost = energy
	w.areaofeffect = 100
	w.craterareaofeffect = 100
	w.craterboost = 1
	w.cratermult = 1
	w.explosiongenerator = 'custom:starfire-explosion'
	w.avoidfeature = false
	w.avoidfriendly = false
	w.collideenemy = true
	w.collidefriendly = true
	w.collidefeature = true
	w.noselfdamage = false
	w[cps].stockpilelimit = 1
	w[cps].place_target_on_ground = true
	clear(w.damage)
	w.damage.default = math.floor(energy / 100)
	w.damage.shields = energy * 2
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
	overpen(wDefL)
	wDefL[cps].weapons_group = 1
	--Right
	def[wds].janus_rocket = table.copy(uDefs['armjanus'][wds]['janus_rocket'])
	local wDefR = def[wds]['janus_rocket']
	wDefR.name = 'High-Explosive Missile Launcher'
	dgun(wDefR, wDefL.range)
	wDefR.areaofeffect = wDefR.areaofeffect * 1.5
	mulDamage(wDefR, 2)
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
	wDefL.reloadtime = wDefL.reloadtime * 0.5
	wDefL.thickness = wDefL.thickness * 1.25
	overpen(wDefL)
	mulDamage(wDefL, 3)
	--Shoulder
	def[wds].armpb_weapon = table.copy(uDefs['armpb'][wds]['armpb_weapon'])
	local wDefS = def[wds]['armpb_weapon']
	wDefS.name = 'Burst-Fire Gauss Cannon'
	dgun(wDefS, wDefL.range)
	wDefS.stockpile = true
	wDefS.metalpershot = 24
	wDefS.stockpiletime = 5
	wDefS.reloadtime = 0.125
	wDefS[cps].stockpilelimit = 6
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
	def.health = def.health * 0.75
	def.speed = 50
	def.istargetingupgrade = true
	declutter(def, 200)
	cloak(def, 1)
	mulPrice(def, 0.75, 3)
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
	wDefL.accuracy = wDefL.accuracy * 1.5
	wDefL.explosiongenerator = 'custom:genericshellexplosion-tiny-aa'
	clear(wDefL.damage)
	wDefL.damage.default = 4
	wDefL.damage.vtol = 2
	wDefL.customparams = {
		area_onhit_ceg = 'treeburn-tiny',
		area_onhit_damageCeg = 'burnflame-xs',
		area_onhit_resistance = 'fire',
		area_onhit_damage = 15,
		area_onhit_range = 25,
		area_onhit_time = 2,
		water_splash = 0,
	}
	--Right
	def[wds]['corlevlr_weapon'] = table.copy(uDefs['legdtr'][wds]['corlevlr_weapon'])
	local wDefR = def[wds]['corlevlr_weapon']
	wDefR.name = 'Shieldbreaker Grenade'
	wDefR.rgbcolor = '1 1 1'
	legDgun(wDefR, wDefL.range, 5000)
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
	def.health = def.health * 0.75
	def.speed = 55
	declutter(def, 200)
	cloak(def, 2)
	mulPrice(def, 0.75, 3)
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
	wDefL.burst = 6
	wDefL.burstrate = wDefL.burstrate * 1.5
	wDefL.reloadtime = wDefL.burst * wDefL.burstrate * 2
	wDefL.thickness = wDefL.thickness * 2
	mulDamage(wDefL, 4)
	wDefL[cps].area_onhit_damage = 125
	wDefL.canattackground = true
	wDefL.weapontype = 'BeamLaser'
	wDefL.beamburst = true
	wDefL.beamtime = 0.05
	wDefL.beamttl = 1
	wDefL.rgbcolor = '0.75 0 0'
	wDefL.rgbcolor2 = '0.9 0.9 0.6'
	wDefL.soundstart = 'lasfirerc'
	wDefL.soundhitdry = ''
	wDefL.soundhitwet = 'sizzle'
	wDefL.soundtrigger = 1
	wDefL.explosiongenerator = 'custom:genericshellexplosion-small-air'
	--Right
	local wDefR = def[wds]['commando_back_cannon']
	clear(wDefR)
	mergeRec(wDefR, uDefs[corT4ID][wds]['commando_stunner'])
	wDefR.name = 'Shieldbreaker Burst'
	legDgun(wDefR, wDefL.range, 25000)
	wDefR.projectiles = nil
	wDefR.paralyzer = nil
	wDefR.paralyzetime = nil
	wDefR.sprayangle = nil
	wDefR.beamttl = 0.4
	--Shoulder
	def[wds]['emp'] = table.copy(uDefs['armthor'][wds]['emp'])
	local wDefS = def[wds]['emp']
	wDefS.name = 'Juno Beam'
	wDefS.range = wDefL.range
	wDefS.thickness = wDefS.thickness * 0.5
	wDefS.reloadtime = wDefS.reloadtime * 0.5
	wDefS.beamtime = wDefS.beamtime * 0.5
	wDefS.canattackground = false
	wDefS[cps].weapons_group = 1
	wDefS[cps].soundstart_volume_multiplier = 0.5
	mulDamage(wDefS, 0.25)
	wDefS.paralyzer = nil
	wDefS.paralyzetime = nil
	wDefS.proximitypriority = 1
	wDefS.soundstart = 'beamershot2'
	wDefS.rgbcolor = '0.75 1.0 0.4'
	def[wpn][1].onlytargetcategory = 'NOTAIR'
	def[wpn][1].badtargetcategory = catJunoTarget
	def[wpn][2].onlytargetcategory = 'NOTAIR'
	def[wpn][4] = {
		def = 'EMP',
		fastautoretargeting = true,
		onlytargetcategory = catJunoTarget,
		badtargetcategory = 'VTOL WEAPON',
	}
	--Lab
	addBO('leggant', newID)
	addBO('leggantuw', newID)
end

--Juno targets.
for _, def in pairs(uDefs) do
	local isRadJam = (not def[wds] or not next(def[wds])) and not def.builder and ((def.radardistance or 0) > 0 or (def.radardistancejam or 0) > 0)
	if hasCategory(def, 'GROUNDSCOUT') or hasCategory(def, 'LIGHTAIRSCOUT') or isRadJam then
		categorize(def, 'category', catJunoTarget)
	end
end