--T3 Figs 1.0a (Zop)
local mods = Spring.GetModOptions()
local uDefs = UnitDefs or {}
local cps = 'customparams'
local wds = 'weapondefs'
local wpn = 'weapons'

local catAirATA = 'AIR_ATA'

local tweakT3Figs = true

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

local function indexOfWeapon(def, id, start)
	if def then
		local lowID = string.lower(id)
		for i = start, #def[wpn] do
			if def[wpn][i].def then
				local lowDef = string.lower(def[wpn][i].def)
				if lowDef == lowID then
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

local function recolorAA(w)
	if not w then return end
	w.canattackground = false
	w.rgbcolor = '1 0.4 0.95'
	w.rgbcolor2 = '1 0.8 1'
	if w.weapontype ~= 'LightningCannon' then
		w.explosiongenerator = 'custom:genericshellexplosion-tiny-aa'
	end
	if w.cegtag then
		w.cegtag = 'missiletrailaa'
	end
	if (w.damage.vtol or 0) < (w.damage.default or 0) then
		w.damage.vtol = w.damage.default
	end
end

local function retargetAA(slot)
	slot.onlytargetcategory = 'VTOL'
	slot.badtargetcategory = 'NOTAIR'
	slot.fastautoretargeting = true
	slot.maindir = '0 0 1'
	slot.maxangledif = slot.maxangledif or 25
end

local flyKeys = {
	'maxacc', 'maxdec', 'maxaileron', 'maxbank', 'maxelevator',
	'maxpitch', 'maxrudder', 'turnradius', 'usesmoothmesh',
	'wingangle', 'wingdrag', 'speedtofront', 'cruisealtitude', 'speed',
}

local function flyAsFig(def, figID)
	local fig = uDefs[figID]
	if not def or not fig then return end
	def.hoverattack = false
	def.airstrafe = false
	def.airStrafe = false
	def.activatewhenbuilt = true
	def.turninplaceanglelimit = nil
	def.upright = nil
	def.turnrate = nil
	def.collide = false
	def.blocking = false
	for i = 1, #flyKeys do
		local k = flyKeys[i]
		def[k] = fig[k]
	end
	def[cps].fighter = 1
	def[cps].attacksafetydistance = fig[cps].attacksafetydistance or 300
end

local function copyFig(srcID, newID, figID, name, tip)
	local src = uDefs[srcID]
	if not src then return end
	uDefs[newID] = table.copy(src)
	local def = uDefs[newID]
	def.icontype = figID
	def.nochasecategory = 'NOTAIR'
	def[cps].unitgroup = 'aa'
	def[cps].techlevel = 3
	def[cps].armordef = 'vtol'
	categorize(def, 'category', catAirATA)
	setDesc(def, name, tip)
	flyAsFig(def, figID)
	clear(def[wds])
	def[wpn] = {}
	return def
end

local function addAAWpn(def, srcID, srcWID)
	local src = uDefs[srcID]
	if not def or not src or not src[wds][srcWID] then return end
	local i = indexOfWeapon(src, srcWID, 1)
	if i < 1 then return end
	def[wds][srcWID] = table.copy(src[wds][srcWID])
	recolorAA(def[wds][srcWID])
	def[wds][srcWID].turret = nil
	local slot = #def[wpn] + 1
	def[wpn][slot] = table.copy(src[wpn][i])
	def[wpn][slot].def = srcWID
	retargetAA(def[wpn][slot])
	def.airsightdistance = math.max(def.airsightdistance or 0, def.sightdistance or 0, def[wds][srcWID].range or 0)
end

--T3 anti-air fighters from seaplane hulls.
if tweakT3Figs then
	local aID = 'armt3fig'
	local cID = 'cort3fig'
	local lID = 'legt3fig'
	local aDef = copyFig('armseap', aID, 'armhawk', 'Lightning Fighter', 'Anti-air lightning fighter')
	local cDef = copyFig('corseap', cID, 'corvamp', 'Sabot Fighter', 'Anti-air sabot fighter')
	local lDef = copyFig('legspsurfacegunship', lID, 'legafigdef', 'Talon Fighter', 'Anti-air gatling fighter')
	addAAWpn(aDef, 'armlwall', 'lightning')
	addAAWpn(cDef, 'corvipe', 'vipersabot')
	if cDef then
		local sDef = uDefs['corsfig']
		if sDef then
			cDef.script = sDef.script
		end
	end
	if cDef and cDef[wds]['vipersabot'] then
		local w = cDef[wds]['vipersabot']
		w.avoidfriendly = false
		w.collidefriendly = false
		w.castshadow = false
		w.burst = 2
		w.burstrate = 0.15
		w.flighttime = 4
		w.weapontimer = 9
		w.turnrate = 22000
		w.tolerance = 12000
		w.tracks = true
		w.targetmoveerror = nil
		w[cps].exclude_preaim = nil
		w[cps].overrange_distance = nil
		w[cps].projectile_destruction_method = nil
		cDef[wpn][1].maindir = nil
		cDef[wpn][1].maxangledif = nil
	end
	addAAWpn(lDef, 'legafigdef', 'leggun')
	if lDef and lDef[wds]['leggun'] then
		local w = lDef[wds]['leggun']
		w.projectiles = w.burst or 10
		w.sprayangle = 1200
		w.burst = 1
		w.burstrate = nil
		w.soundtrigger = true
	end
	local figs = { aDef, cDef, lDef }
	for f = 1, #figs do
		local def = figs[f]
		if def and def[wds] then
			for _, w in pairs(def[wds]) do
				if w.damage then
					for k, v in pairs(w.damage) do
						w.damage[k] = v * 2
					end
				end
			end
		end
	end
	if aDef and aDef[wpn][1] then addBO('armapt3', aID) end
	if cDef and cDef[wpn][1] then addBO('corapt3', cID) end
	if lDef and lDef[wpn][1] then addBO('legapt3', lID) end
	--Ghetto fix for Arm.
	local cPlant = uDefs['corapt3']
	local aPlant = uDefs['armapt3']
	if aPlant and cPlant then
		local keys = {
			'objectname',
			'script',
			'footprintx',
			'footprintz',
			'yardmap',
			'collisionvolumeoffsets',
			'collisionvolumescales',
			'collisionvolumetype',
		}
		for i = 1, #keys do
			aPlant[keys[i]] = cPlant[keys[i]]
		end
		keys = {
			'buildinggrounddecaltype',
			'buildinggrounddecalsizex',
			'buildinggrounddecalsizey',
			'normaltex',
		}
		for i = 1, #keys do
			aPlant[cps][keys[i]] = cPlant[cps][keys[i]]
		end
		mergeRec(aPlant.featuredefs, cPlant.featuredefs)
	end
end