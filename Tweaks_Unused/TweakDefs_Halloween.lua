--Halloween 1.0 (Zop)
local mods = Spring.GetModOptions()
local uDefs = UnitDefs or {}
local wDefs = WeaponDefs or {}
local cps = 'customparams'
local fds = 'featuredefs'
local wds = 'weapondefs'

local hasLegion = mods.experimentallegionfaction

local tweakArmGhosts = true
local tweakCorFiends = true
local tweakLegZombies = true
local allPerks = true --Grant to all factions.

local function isArmada(id, def)
	if type(id) ~= 'string' or not id:find('^arm') then
		return false
	end
	return true
end

local function isCortex(id, def)
	return type(id) == 'string' and id:find('^cor') ~= nil
end

local function isLegion(def)
	local sub = def[cps] and def[cps].subfolder
	return sub and sub:find('Legion', 1, true) ~= nil
end

local function perkArm(id, def)
	return allPerks or isArmada(id, def)
end

local function perkCor(id, def)
	return allPerks or isCortex(id, def)
end

local function perkLeg(def)
	return allPerks or isLegion(def)
end

local function weaponDps(wDef)
	if not wDef or not wDef.damage or not wDef.reloadtime or wDef.reloadtime <= 0 then
		return 0
	end
	if wDef.paralyzer then
		return 0
	end
	local wCp = wDef[cps] or wDef.customparams
	if wCp and (wCp.bogus == 1 or wCp.bogus == true or wCp.bogus == '1') then
		return 0
	end
	local dmg = wDef.damage.default or 0
	local burst = wDef.burst or 1
	local projectiles = wDef.projectiles or 1
	return (dmg * burst * projectiles) / wDef.reloadtime
end

local function unitDps(def)
	local weapons = def[wds]
	if not weapons then
		return 0
	end
	local total = 0
	for _, wDef in pairs(weapons) do
		total = total + weaponDps(wDef)
	end
	return total
end

local function unitMaxWeaponRange(def)
	local weapons = def[wds]
	if not weapons then
		return 0
	end
	local maxRange = 0
	for _, wDef in pairs(weapons) do
		if weaponDps(wDef) > 0 and wDef.range and wDef.range > maxRange then
			maxRange = wDef.range
		end
	end
	return maxRange
end

-- Scout < T1 < T1.5 (boats/seaplanes/hovers) < T2 < T3 < T4 (scav epic / t4).
local perkScouts = {
	armflea = true,
	armfav = true,
	armpeep = true,
	armsh = true,
	armpt = true,
	corfav = true,
	corfink = true,
	corsh = true,
	corpt = true,
	corbw = true,
}

local function perkTier(id, def)
	local cp = def[cps] or {}
	local sub = cp.subfolder or ''
	local tech = tonumber(cp.techlevel)
	local mclass = def.movementclass or ''

	if tech == 4 or (type(id) == 'string' and id:find('t4')) or mclass:find('EPIC', 1, true) then
		return 4
	end
	if tech == 3 or sub:find('Gantry', 1, true) then
		return 3
	end
	if tech == 2 or sub:find('/T2', 1, true) or sub:find('T2 ', 1, true) then
		return 2
	end
	local metal = def.metalcost or 0
	if perkScouts[id] or (def.canmove and not def.builder and metal > 0 and metal <= 35) then
		return 0
	end
	if tech == 1.5
		or sub:find('Ships', 1, true)
		or sub:find('Seaplanes', 1, true)
		or sub:find('Hovercraft', 1, true)
	then
		return 1.5
	end
	return 1
end

local cloakByTier = {
	[0] = { cost = 5, moving = 20, dist = 50 },
	[1] = { cost = 10, moving = 40, dist = 60 },
	[1.5] = { cost = 25, moving = 100, dist = 75 },
	[2] = { cost = 50, moving = 200, dist = 95 },
	[3] = { cost = 250, moving = 1000, dist = 120 },
	[4] = { cost = 1250, moving = 5000, dist = 150 },
}
local cloakTierNext = {
	[0] = 1,
	[1] = 1.5,
	[1.5] = 2,
	[2] = 3,
	[3] = 4,
	[4] = 4,
}

-- Dedicated jammers (exclude claw / MLV token jam radii).
local function isJammer(def)
	return (def.radardistancejam or 0) >= 400
end

-- Cortex self-D by tier.
local corSelfDByTier = {
	[0] = 'smallExplosionGenericSelfd',
	[1] = 'flamethrowerSelfd',
	[1.5] = 'pyroselfd',
	[2] = 'mediumBuildingExplosionGenericSelfd',
	[3] = 'scavcomexplosion',
	[4] = 'fusionExplosionSelfd',
}

-- High yield explosions, not to be overwritten.
local corSelfDExclude = {
	cortorch = true,
	corantiship = true,
	corblackhy = true,
	corcarry = true,
	cordeadeye = true,
	cordesolator = true,
	corprince = true,
	corroach = true,
	coresuppt3 = true,
	corkorg = true,
	corakt4 = true,
	corcomboss = true,
	corsktl = true,
	armseadragon = true,
	armepoch = true,
	armantiship = true,
	armcarry = true,
	armmanni = true,
	armvader = true,
	armbanth = true,
	armcomboss = true,
	armvadert4 = true,
	armpwt4 = true,
	armrattet4 = true,
	leganavyartyship = true,
	leganavyflagship = true,
	leganavyantinukecarrier = true,
	leginc = true,
	legsnapper = true,
	legeheatraymech = true,
	legeheatraymech_old = true,
	leegmech = true,
	legfortt4 = true,
}

local function isSelfDExcluded(id)
	if type(id) ~= 'string' then
		return false
	end
	if corSelfDExclude[id] then
		return true
	end
	return corSelfDExclude[id:gsub('_scav$', '')] == true
end

-- Known EMP unit explosions (WeaponDefs may not be keyed yet at tweakdefs time).
local empExplosionNames = {
	empblast = true,
	spybombx = true,
	spybombxscav = true,
	mistexplo = true,
	mistexploxl = true,
	mistexploxxl = true,
}

local function explosionIsEmp(name)
	if type(name) ~= 'string' or name == '' then
		return false
	end
	local key = name:lower()
	if empExplosionNames[key] then
		return true
	end
	local wDef = wDefs and (wDefs[key] or wDefs[name])
	return wDef and (wDef.paralyzer == 1 or wDef.paralyzer == true)
end

local function hasEmpExplosion(def)
	return explosionIsEmp(def.selfdestructas) or explosionIsEmp(def.explodeas)
end

--Arm Ghosts
if tweakArmGhosts then
	for id, def in pairs(uDefs) do
		if def and perkArm(id, def) and not def.cloakcost then
			local tier = perkTier(id, def)
			if isJammer(def) then
				tier = cloakTierNext[tier] or math.min((tier or 1) + 1, 4)
			end
			local cloak = cloakByTier[tier] or cloakByTier[1]
			def.cancloak = true
			def.cloakcost = cloak.cost
			def.initcloaked = true
			if def.canmove then
				def.cloakcostmoving = cloak.moving
			end
			if not def.mincloakdistance or def.mincloakdistance <= 0 then
				def.mincloakdistance = cloak.dist
			end
		end
	end
end

--Cortex Fiends
if tweakCorFiends then
	for id, def in pairs(uDefs) do
		if def and perkCor(id, def) then
			local cp = def[cps] or {}
			if not cp.iscommander and def.canmove and not def.yardmap and not hasEmpExplosion(def) then
				if not isSelfDExcluded(id) then
					local tier = perkTier(id, def)
					def.selfdestructas = corSelfDByTier[tier] or corSelfDByTier[1]
				end
				local cd = def.selfdestructcountdown
				if cd == nil or cd > 1 then
					def.selfdestructcountdown = 1
				end
			end
		end
	end
end

--Legion Zombies
if tweakLegZombies and (allPerks or hasLegion) then
	local builders = {}
	for id, def in pairs(uDefs) do
		if def and perkLeg(def) then
			if def.builder then
				builders[id] = def
			end

			local hp = def.health
			local dead = def[fds] and def[fds].dead
			if dead and hp and hp > 0 then
				if not def[cps].iscommander then
					def[cps].iseffigy = true --Keep corpse HP through alldefs_post.
				end
				dead.damage = hp * 5
			end
		end
	end

	for _, def in pairs(builders) do
		local hasBp = def.workertime and def.workertime > 0
		if not hasBp then
			local dps = unitDps(def)
			if dps > 0 then
				def.workertime = math.floor(dps * 0.5)
				hasBp = def.workertime > 0
			end
		end

		if not def.builddistance or def.builddistance <= 0 then
			local maxRange = unitMaxWeaponRange(def)
			if maxRange > 0 then
				def.builddistance = maxRange * 0.5
			end
		end

		if hasBp and def.builddistance and def.builddistance > 0 then
			def.canresurrect = true
		end
	end
end