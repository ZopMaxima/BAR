--OneBigNuke 1.3.1
local uDefs = UnitDefs or {}
local cps = 'customparams'
local wds = 'weapondefs'

local function addC(conName, newUnit)
	if
		uDefs[conName] and uDefs[conName].buildoptions and
		not table.contains(uDefs[conName].buildoptions, newUnit)
	then
		table.insert(uDefs[conName].buildoptions, newUnit)
	end
end

local function setDesc(def, name, tip)
	local latin = { 'en', 'fr', 'de', 'es' }
	if def then
		for i = 1, #latin do
			if name then
				def[cps]['i18n_' .. latin[i] .. '_humanname'] = name
			end
			if tip then
				def[cps]['i18n_' .. latin[i] .. '_tooltip'] = tip
			end
		end
	end
end

local function addUnitToBO(newUnit, ...)
	local rest = { ... }
	for i, v in ipairs(rest) do
		addC(v, newUnit)
	end
end

local function mergeToNew(u, newU, obj)
	if uDefs[u] and not uDefs[newU] then
		uDefs[newU] = table.merge(uDefs[u], obj)
	end
	return uDefs[newU]
end

local nukeSettings = {
	health = 5900,
	maxthisunit = 1,
	buildtime = 4785000,
	energycost = 260000000,
	metalcost = 16000000,
}

local title = "Nuclear ICBM Launcher"
local tip = "Very expensive but it will do it's job with vigor'. Anti's for this are non existent'"

if uDefs["armsilo"] then
	local uDef = mergeToNew("armsilo", "armsiloexp", nukeSettings)
	uDef.icontype = "armsilo"
	local wDef = uDef[wds].nuclear_missile
	wDef.targetable = nil
	wDef.stockpiletime = 30
	wDef.areaofeffect = 3200
	wDef.damage.default = 1000000
	addUnitToBO("armsiloexp", "armack", "armaca", "armacv")
	setDesc(uDef, title, tip)
end

if uDefs["corsilo"] then
	local uDef = mergeToNew("corsilo", "corsiloexp", nukeSettings)
	uDef.icontype = "corsilo"
	local wDef = uDef[wds].crblmssl
	wDef.targetable = nil
	wDef.stockpiletime = 30
	wDef.areaofeffect = 3200
	wDef.damage.default = 1000000
	addUnitToBO("corsiloexp", "corack", "coraca", "coracv")
	setDesc(uDef, title, tip)
end

if uDefs["legsilo"] then
	local uDef = mergeToNew("legsilo", "legsiloexp", nukeSettings)
	uDef.icontype = "legsilo"
	local wDef = uDef[wds].legicbm
	wDef.targetable = nil
	wDef.stockpiletime = 30
	wDef.areaofeffect = 3200
	wDef.damage.default = 1000000
	wDef[cps].shield_aoe_penetration = true
	addUnitToBO("legsiloexp", "legack", "legaca", "legacv")
	setDesc(uDef, title, tip)
end