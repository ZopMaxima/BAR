--Lava Sky Ops (Zop)
local uDefs = UnitDefs or {}
local cps = 'customparams'
local fds = 'featuredefs'
local wds = 'weapondefs'
local aACons = {'armaca','armack','armacv'}
local cACons = {'coraca','corack','coracv'}
local lACons = {'legaca','legack','legacv'}

local tweakSeaPlane = true
local tweakTorpedo = true
local tweakAirPrice = true
local tweakAirTrans = true
local tweakFlags = true
local tweakT3Eco = true

local function round10(n)
	return math.floor(n * 0.1) * 10
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

--Seaplanes on land.
if tweakSeaPlane then
	local asp = 'armplat'
	local csp = 'corplat'
	local yard = 'oooooo oeeeeo oeeeeo oeeeeo oeeeeo oooooo'
	local aspDef = uDefs[asp]
	local cspDef = uDefs[csp]
	unwater(asp)
	local aspHP = aspDef.health
	if aspHP == 0 then
		aspDef.health = 2000
	end
	unwater(csp)
	local cspHP = cspDef.health
	if cspHP == 0 then
		cspDef.health = 2200
	end
	aspDef.waterline = aspDef.waterline + 20
	aspDef.maxslope = 15
	aspDef.yardmap = yard
	cspDef.waterline = cspDef.waterline + 50
	cspDef.maxslope = 15
	cspDef.yardmap = yard
	addBO('armcom', asp)
	addBO('corcom', csp)
	addBO('legcom', csp)
	addBO('armca', asp)
	addBO('corca', csp)
	addBO('legca', csp)
	addBO(asp, 'armca')
	addBO(asp, 'armlance')
	addBO(csp, 'corca')
	addBO(csp, 'legca')
	addBO(csp, 'cortitan')
	addBO(csp, 'legatorpbomber')
	addBO('armap', 'armcsa')
	addBO('armap', 'armseap')
	addBO('corap', 'corcsa')
	addBO('corap', 'corseap')
	addBO('legap', 'corcsa')
	addBO('legap', 'corseap')
	addBO('armcsa', 'armaap')
	addBO('corcsa', 'coraap')
	addBO('corcsa', 'legaap')
end

--Torpedo buffs to fight T3.
if tweakTorpedo then
	local torpHPMul = 2
	local torpDmgMul = 2
	for id, def in pairs(uDefs) do
		if def.weapondefs and (def.cruisealtitude or (not def.canmove)) then
			local hasWW = false
			for k, v in pairs(def.weapondefs) do
				if v.waterweapon then
					v.damage.default = v.damage.default * torpDmgMul
					hasWW = true
				end
			end
			if hasWW then
				def.health = def.health * torpHPMul
			end
		end
	end
end

--Air combat tweaks, energy tax.
if tweakAirPrice then
	local airMCMul = 2
	local airMCCutoff = 12500
	local airECMul = 1
	local airDrainMMul = 0.001
	local airDrainEMul = 0.01
	for id, def in pairs(uDefs) do
		if def.cruisealtitude then
			if def.weapondefs then
				local mcMul = math.max(1, math.min(airMCCutoff / def.metalcost, airMCMul))
				def.buildtime = math.floor(def.buildtime * ((mcMul + airECMul) * 0.5))
				def.metalcost = math.floor(def.metalcost * mcMul)
				def.energycost = math.floor(def.energycost * airECMul)
			end
			if not def.energymake then
				def['activatewhenbuilt'] = true
				def['onoffable'] = false
				def['energyupkeep'] = math.min(def.metalcost * airDrainMMul, 1) * def.energycost * airDrainEMul
			end
		end
	end
	--Snowflake price includes Epic Dragon.
	local eDragon = uDefs['corcrwt4']
	if eDragon then
		eDragon.buildtime = math.floor(eDragon.buildtime * ((airMCMul + airECMul) * 0.5))
		eDragon.metalcost = eDragon.metalcost * airMCMul
		eDragon.energycost = eDragon.energycost * airECMul
	end
end

--Transport paratrooper.
if tweakAirTrans then
	for id, def in pairs(uDefs) do
		if def.cruisealtitude then
			if def.transportcapacity then
				def['isfireplatform'] = true
				def['unloadspread'] = 0.25
			end
		elseif def.canmove then
			if not def.customparams then
				def[cps] = {}
			end
			def[cps]['paratrooper'] = true
			local fdm = 'fall_damage_multiplier'
			if not def.customparams[fdm] then
				if def.movementclass and string.find(def.movementclass, 'HOVER') then
					def[cps][fdm] = 0
					def[cps]['water_'..fdm] = 0
					if def.cantbetransported then
						def.cantbetransported = false
					end
				else
					def[cps][fdm] = 0.25
				end
			end
		end
	end
end

--Flagship AA boost.
if tweakFlags then
	local afsDef = uDefs['armfepocht4']
	local cfsDef = uDefs['corfblackhyt4']
	local lfsDef = uDefs['legfortt4']
	afsDef.health = afsDef.health * 1.5
	cfsDef.health = cfsDef.health * 1.5
	lfsDef.health = lfsDef.health * 1.5
	afsDef.speed = afsDef.speed * 1.25
	cfsDef.speed = cfsDef.speed * 1.25
	lfsDef.speed = lfsDef.speed * 1.25
	afsDef.turnrate = afsDef.turnrate * 1.25
	cfsDef.turnrate = cfsDef.turnrate * 1.25
	lfsDef.turnrate = lfsDef.turnrate * 1.25
	lfsDef['radardistancejam'] = 600
	local afsWDef = afsDef[wds]['ferret_missile']
	mergeMapRec(afsWDef, uDefs['armflak'][wds]['armflak_gun'])
	afsWDef.reloadtime = afsWDef.reloadtime * 1.5
	local cfsWDef = cfsDef[wds]['ferret_missile']
	mergeMapRec(cfsWDef, uDefs['legflak'][wds]['legflak_gun'])
	cfsWDef.cegtag = nil
	cfsWDef.range = round10(cfsWDef.range * 0.75)
	local lfsWDef = lfsDef[wds]['aa_missiles']
	mergeMapRec(lfsWDef, uDefs['corscreamer'][wds]['cor_advsam'])
	lfsWDef.burstrate = nil
	lfsWDef.burst = nil
	lfsWDef.stockpile = false
end