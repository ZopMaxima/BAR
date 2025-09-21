--T3 Eco Express (Zop)
local uDefs = UnitDefs or {}
local cps = 'customparams'
local fds = 'featuredefs'

local tweakT3Afus = true
local tweakT3Conv = true

local function round10(n)
	return math.floor(n * 0.1) * 10
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

--Declutter Armada.
rmvBO('armaca', 'armckfus')
rmvBO('armack', 'armckfus')
rmvBO('armacv', 'armckfus')

--Afus faction attributes and icon.
if tweakT3Afus then
	local t3HPMul = 1.5
	local timeMul = 5
	local costMul = 10
	local aAFusDef = uDefs['armafus']
	local cAFusDef = uDefs['corafus']
	local lAFusDef = uDefs['legafus']
	local aT3FusDef = uDefs['armafust3']
	local cT3FusDef = uDefs['corafust3']
	local lT3FusDef = uDefs['legafust3']
	local hp = 'health'
	aT3FusDef[hp] = aAFusDef[hp] * t3HPMul
	cT3FusDef[hp] = cAFusDef[hp] * t3HPMul
	lT3FusDef[hp] = lAFusDef[hp] * t3HPMul
	local bt = 'buildtime'
	aT3FusDef[bt] = aAFusDef[bt] * timeMul
	cT3FusDef[bt] = cAFusDef[bt] * timeMul
	lT3FusDef[bt] = lAFusDef[bt] * timeMul
	local mc = 'metalcost'
	aT3FusDef[mc] = aAFusDef[mc] * costMul
	cT3FusDef[mc] = cAFusDef[mc] * costMul
	lT3FusDef[mc] = lAFusDef[mc] * costMul
	local ec = 'energycost'
	aT3FusDef[ec] = aAFusDef[ec] * costMul
	cT3FusDef[ec] = cAFusDef[ec] * costMul
	lT3FusDef[ec] = lAFusDef[ec] * costMul
	local em = 'energymake'
	aT3FusDef[em] = aAFusDef[em] * costMul
	cT3FusDef[em] = cAFusDef[em] * costMul
	lT3FusDef[em] = lAFusDef[em] * costMul
	--Arm unique pass.
	aT3FusDef.energystorage = aAFusDef.energystorage * costMul * 1.5
	aT3FusDef.cloakcost = 250
	aT3FusDef.mincloakdistance = 175
	setDesc(lT3FusDef, nil, 'Produces '..lT3FusDef[em]..' Energy (Hazardous)')
	local bp = 'other/resourcecheat.dds'
	aT3FusDef.buildpic = bp
	cT3FusDef.buildpic = bp
	lT3FusDef.buildpic = bp
	local ex = 'advancedFusionExplosionSelfd'
	aT3FusDef.explodeas = ex
	cT3FusDef.explodeas = ex
	lT3FusDef.explodeas = ex
end

--Converter size and price reduction.
if tweakT3Conv then
	local timeMul = 5
	local costMul = 10
	local conDef = uDefs['cormmkr']
	local aT3CDef = uDefs['armmmkrt3']
	local cT3CDef = uDefs['cormmkrt3']
	local lT3CDef = uDefs['legadveconvt3']
	local t3ConKVP = {
		buildtime = conDef.buildtime * timeMul,
		metalcost = round10(conDef.metalcost * costMul * (cT3CDef[cps].energyconv_efficiency / conDef[cps].energyconv_efficiency)),
		energycost = conDef.energycost * costMul,
		footprintx = 5,
		footprintz = 5,
		explodeas = 'fusionExplosion',
		selfdestructas = 'fusionExplosionSelfd',
		yardmap = 'yoooy ooooo ooooo ooooo yoooy'
	}
	local t3ConCPar = {
		buildinggrounddecalsizex = 5,
		buildinggrounddecalsizey = 5
	}
	local t3ConFDSDead = {
		damage = aT3CDef.health * 0.545,
		metal = aT3CDef.metalcost * 0.575,
		footprintx = 5,
		footprintz = 5,
		height = 20
	}
	local t3ConFDSHeap = {
		damage = aT3CDef.health * 0.275,
		metal = aT3CDef.metalcost * 0.225,
		footprintx = 5,
		footprintz = 5,
		height = 4,
		object = 'Units/cor5X5A.s3o'
	}
	--Arm shared pass.
	mergeMap(aT3CDef, t3ConKVP)
	mergeMap(aT3CDef[cps], t3ConCPar)
	mergeMap(aT3CDef[fds].dead, t3ConFDSDead)
	mergeMap(aT3CDef[fds].heap, t3ConFDSHeap)
	--Cor
	mergeMapRec(cT3CDef, aT3CDef)
	remodel(cT3CDef, 'CORUWMMM', true, true)
	--Leg
	mergeMapRec(lT3CDef, aT3CDef)
	remodel(lT3CDef, 'CORUWFUS', true, true)
	lT3CDef.collisionvolumeoffsets = cT3CDef.collisionvolumeoffsets
	lT3CDef.collisionvolumescales = cT3CDef.collisionvolumescales
	lT3CDef.collisionvolumetype = cT3CDef.collisionvolumetype
	--Arm unique pass.
	local foot = { footprintx = 6, footprintz = 4 }
	mergeMap(aT3CDef, foot)
	mergeMap(aT3CDef[fds].dead, foot)
	mergeMap(aT3CDef[fds].heap, foot)
	remodel(aT3CDef, 'ARMUWFUS', true, true)
	aT3CDef.yardmap = 'oooooo oooooo oooooo oooooo'
end