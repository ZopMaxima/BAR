--T3 Nano Turrets (Zop)
--Concept by Djarshi / Txpera
local mods = Spring.GetModOptions()
local uDefs = UnitDefs or {}
local cps = 'customparams'
local aACons = {'armaca','armack','armacv','armacsub'}
local cACons = {'coraca','corack','coracv','coracsub'}
local lACons = {'legaca','legack','legacv'}

local noSea = mods.map_waterislava

local tweakT3Nano = true

local function round10(n)
	return math.floor(n * 0.1) * 10
end

local function extrapolate(t1, t2)
	return round10(t2 * (t2 / t1))
end

local function unwater(id)
	local def = UnitDefs[id]
	if def then
		def.minwaterdepth = -1000000
		def.maxwaterdepth = 0
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

--Extrapolate nano turret stats.
if tweakT3Nano and not uDefs['armnanotct3'] then
	local footMul = 1.25
	local at1Def = uDefs['armnanotc']
	local at2Def = uDefs['armnanotct2']
	if at1Def and at2Def then
		local ex = 'hugeBuildingExplosionGeneric'
		local override = {
			icontype = 'armrespawn',
			metalcost = extrapolate(at1Def.metalcost, at2Def.metalcost) * footMul,
			energycost = extrapolate(at1Def.energycost, at2Def.energycost) * footMul,
			buildtime = extrapolate(at1Def.buildtime, at2Def.buildtime) * footMul,
			workertime = extrapolate(at1Def.workertime, at2Def.workertime) * footMul,
			builddistance = extrapolate(at1Def.builddistance, at2Def.builddistance),
			sightdistance = extrapolate(at1Def.sightdistance, at2Def.sightdistance),
			health = extrapolate(at1Def.health, at2Def.health),
			maxwaterdepth = 1000000,
			minwaterdepth = -1000000,
			explodeas = ex,
			selfdestructas = ex..'Selfd',
			customparams = {
				techlevel = 3
			}
		}
		local at3 = 'armnanotct3'
		local ct3 = 'cornanotct3'
		local lt3 = 'legnanotct3'
		uDefs[at3] = table.merge(uDefs['armrespawn'], override)
		uDefs[ct3] = table.merge(uDefs['correspawn'], override)
		uDefs[lt3] = table.merge(uDefs['legnanotcbase'], override)
		local at3Def = uDefs[at3]
		local ct3Def = uDefs[ct3]
		local lt3Def = uDefs[lt3]
		if noSea then
			unwater(at3)
			unwater(ct3)
			unwater(lt3)
		end
		local t3Name = 'Epic Construction Turret'
		local t3Desc = 'Assist & Repair in massive radius. (OP by djarshi)'
		setDesc(at3Def, t3Name, t3Desc)
		setDesc(ct3Def, t3Name, t3Desc)
		setDesc(lt3Def, t3Name, t3Desc)
		addBOArr(aACons, at3)
		addBOArr(cACons, ct3)
		addBOArr(lACons, lt3)
	end
end