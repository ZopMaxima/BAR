--Riot Titan (Zop)
local uDefs = UnitDefs or {}
local cps = 'customparams'
local wds = 'weapondefs'
local wpn = 'weapons'

local tweakShieldTitan = true

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

local function clearMap(m)
	for k, v in pairs(m) do
		m[k] = nil
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

local function addUnit(id, copyID)
	local def = UnitDefs[id] or {}
	mergeMapRec(def, UnitDefs[copyID])
	UnitDefs[id] = def
	return def
end

--A titan that relies on energy to tank.
if tweakShieldTitan then
	local newID = 'armbanthx'
	local def = addUnit(newID, 'legcomt2def')
	mergeMapRec(def, uDefs['armbanth'])
	setDesc(def, 'Riot Titan', 'Heavy-Shielded Riot Mech')
	def.icontype = 'armbanth'
	def[cps].iscommander = nil
	def.showplayername = nil
	def.hidedamage = nil
	def.builder = false
	def.workertime = 0
	def.terraformspeed = 0
	def.buildoptions = {}
	def.cancapture = false
	def.capturable = true
	def.reclaimable = true
	def.metalmake = 0
	def.energymake = 0
	def.energystorage = 0
	def.metalcost = def.metalcost * 1.5
	def.energycost = def.energycost * 2.5
	def.buildtime = def.buildtime * 2
	def.radardistance = 0
	def.sonardistance = 0
	def[cps].paralyzemultiplier = 0.25
	--Shield
	local shieldRad = def[cps]['shield_radius']
	local wDefShield = def[wds]['repulsor']
	wDefShield.shield.force = 5
	wDefShield.shield.power = 10000
	wDefShield.shield.powerregen = 250
	wDefShield.shield.powerregenenergy = wDefShield.shield.powerregen * 10
	wDefShield.shield.intercepttype = 65535
	--Arms
	local wDefArms = def[wds]['armbantha_fire']
	local wDefRiot = uDefs['armmav'][wds]['armmav_weapon']
	clearMap(wDefArms)
	mergeMapRec(wDefArms, wDefRiot)
	wDefArms.projectiles = 4
	wDefArms.sprayangle = 1800
	wDefArms.weaponvelocity = wDefArms.weaponvelocity * 1.5
	wDefArms.reloadtime = wDefArms.reloadtime * 0.75
	wDefArms.range = 500
	def[wpn][1].badtargetcategory = "VTOL GROUNDSCOUT"
	def[wpn][1].onlytargetcategory = 'SURFACE'
	--Shoulder
	local wDefLazer = def[wds]['tehlazerofdewm']
	local wDefLight = uDefs['armthor'][wds]['thunder']
	mergeMapRec(wDefLazer, wDefLight)
	wDefLazer.collidefriendly = false
	wDefLazer.beamtime = nil
	wDefLazer.burst = 15
	wDefLazer.burstburstrate = 0.03333
	wDefLazer.reloadtime = 0.5
	wDefLazer.energypershot = wDefLazer.energypershot * 2
	wDefLazer.range = round10(shieldRad * 1.4)
	wDefLazer.damage.default = wDefLazer.damage.default * 0.375
	--Backpack
	def[wpn][3].def = uDefs['legcomt2def'][wpn][3].def
	local wDefEMP = def[wds]['empgrenade']
	wDefEMP.projectiles = 3
	wDefEMP.sprayangle = 3600
	wDefEMP.commandfire = false
	wDefEMP.reloadtime = wDefEMP.reloadtime * 1.5
	wDefEMP.range = wDefArms.range
	wDefEMP.weaponvelocity = wDefArms.weaponvelocity * 0.5
	wDefEMP.damage.default = 10000
	def[wpn][3].badtargetcategory = "VTOL GROUNDSCOUT"
	def[wpn][3].onlytargetcategory = 'SURFACE EMPABLE'
	--Labs
	addBO('armshltx', newID)
	addBO('armshltxuw', newID)
end