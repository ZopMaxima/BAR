--T4Eco
local uDefs = UnitDefs or {}
local latin = {'en','fr','de'}
local cps = 'customparams'

local tweakT4Eco = true

local function addBO(builderID, unitID)
	local bDef = UnitDefs[builderID]
	local uDef = UnitDefs[unitID]
	if bDef and uDef then
		bDef.buildoptions[#bDef.buildoptions + 1] = unitID
	end
end

local function mergeMap(l, r)
	for k, v in pairs(r) do
		l[k] = v
	end
end

local function setDesc(def, name, tip)
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

--T4 Eco (Engi/txpera)
if tweakT4Eco then
	local t4CostMul = 10
	local t4OutMul = 10
	local t4HPMul = 2.5
	local afusDef = uDefs['corafus']
	local aconDef = uDefs['cormmkr']
	local t4Fus = 'lootboxplatinum'
	local t4Con = 'armdf'
	local t4FusDef = uDefs[t4Fus]
	local t4ConDef = uDefs[t4Con]
	local advIDs = {
		'armaca','armack','armacv',
		'coraca','corack','coracv',
		'legaca','legack','legacv'
	}
	--Fusion
	local t4FusKVP = {
		buildpic = 'other/resourcecheat.dds',
		buildtime = afusDef.buildtime * t4CostMul,
		energycost = afusDef.energycost * t4CostMul,
		energymake = afusDef.energymake * t4OutMul,
		energystorage = afusDef.energystorage * t4OutMul,
		explodeas = 'korgExplosionSelfd',
		health = afusDef.health * t4HPMul,
		metalcost = afusDef.metalcost * t4CostMul,
		metalmake = 0,
		reclaimable = true
	}
	local t4FusCPar = {
		fall_damage_multiplier = 2
	}
	mergeMap(t4FusDef, t4FusKVP)
	mergeMap(t4FusDef[cps], t4FusCPar)
	t4FusDef['pushresistant'] = true
	t4FusDef['yardmap'] = 'yooy oooo oooo yooy'
	t4FusDef[cps]['removewait'] = true
	setDesc(t4FusDef, 'Super Fusion Reactor', 'Produces '..(afusDef.energymake * t4OutMul)..' Energy')
	--Converter
	local t4ConKVP = {
		activatewhenbuilt = true,
		buildpic = 'lootboxes/LOOTBOXGOLD.DDS',
		buildtime = aconDef.buildtime * t4CostMul,
		energycost = aconDef.energycost * t4CostMul,
		energymake = 0,
		explodeas = 'fusionExplosion',
		health = aconDef.health * t4HPMul,
		maxwaterdepth = 0,
		metalcost = aconDef.metalcost * t4CostMul,
		objectname = 'Units/CORUWFUS.s3o',
		script = 'Units/CORUWFUS.cob',
		selfdestructas = 'fusionExplosionSelfd'
	}
	local t4ConCPar = {
		buildinggrounddecalsizex = 8,
		buildinggrounddecalsizey = 8,
		buildinggrounddecaltype = 'decals/coruwfus_aoplane.dds',
		energyconv_capacity = aconDef[cps].energyconv_capacity * t4OutMul,
		energyconv_efficiency = aconDef[cps].energyconv_efficiency,
		subfolder = 'ArmBuildings/LandEconomy',
		unitgroup = 'metal'
	}
	local t4ConFDefDead = {
		collisionvolumeoffsets = '1.9 -0.1 1',
		collisionvolumescales = '90 27.3 72.6',
		damage = t4ConKVP.health * 0.545,
		footprintx = 5,
		footprintz = 5,
		height = 20,
		metal = t4ConKVP.metalcost * 0.575,
		object = 'Units/coruwfus_dead.s3o'
	}
	local t4ConFDefHeap = {
		blocking = false,
		category = 'heaps',
		damage = t4ConKVP.health * 0.275,
		footprintx = 5,
		footprintz = 5,
		height = 4,
		metal = t4ConKVP.metalcost * 0.225,
		object = 'Units/cor5X5A.s3o'
	}
	mergeMap(t4ConDef, t4ConKVP)
	mergeMap(t4ConDef[cps], t4ConCPar)
	mergeMap(t4ConDef.featuredefs.dead, t4ConFDefDead)
	mergeMap(t4ConDef.featuredefs.heap, t4ConFDefHeap)
	setDesc(t4ConDef, 'Super Energy Converter', 'Converts '..(aconDef[cps].energyconv_capacity * t4OutMul)..' energy into '..math.floor(aconDef[cps].energyconv_capacity * t4OutMul * aconDef[cps].energyconv_efficiency)..' metal per sec')
	for i = 1, #advIDs do
		addBO(advIDs[i], t4Con)
		addBO(advIDs[i], t4Fus)
	end
end