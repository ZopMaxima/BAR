--T3 Nano Turrets (Zop)
--Concept by Djarshi / Txpera
local uDefs = UnitDefs or {}
local cps = 'customparams'
local aACons = {'armaca','armack','armacv'}
local cACons = {'coraca','corack','coracv'}
local lACons = {'legaca','legack','legacv'}

local tweakT3Nano = true

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

local function extrapolate(t1, t2)
	return round10(t2 * (t2 / t1))
end

--Multiply and overwrite stats.
if tweakT3Nano then
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