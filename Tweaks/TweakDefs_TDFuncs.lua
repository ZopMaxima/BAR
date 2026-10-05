--TDFuncs 1.0 (Zop)
local uDefs = UnitDefs or {}
local shared = Shared or {}
local cps = 'customparams'
local fds = 'featuredefs'
local wpn = 'weapons'

local languages = {}
local armComms = {}
local corComms = {}
local legComms = {}
local armCons = {}
local corCons = {}
local legCons = {}
local armAdvCons = {}
local corAdvCons = {}
local legAdvCons = {}
local allBuilders = {}

local function openJSON(relative)
	if relative and VFS.FileExists(relative) then
		local decode = (Json and Json.decode) or VFS.Include('common/luaUtilities/json.lua').decode
		if decode then
			return decode(VFS.LoadFile(relative))
		end
	end
end

local function round10(n)
	return math.floor(n * 0.1) * 10
end

local function round100(n)
	return math.floor(n * 0.01) * 100
end

local function round1000(n)
	return math.floor(n * 0.001) * 1000
end

local function truncateInt(n)
	local s = n < 0 and -1 or 1
	n = math.abs(n)
	if n > 100000 then return s * round1000(n) end
	if n > 10000 then return s * round100(n) end
	if n > 1000 then return s * round10(n) end
	return s * math.floor(n)
end

local function mulAll(tbl, mul)
	for k, v in pairs(tbl) do
		tbl[k] = v * mul
	end
end

local function mulAllInt(tbl, mul)
	for k, v in pairs(tbl) do
		tbl[k] = math.floor(v * mul)
	end
end

--Linear
local function extrapolate(t1, t2)
	return truncateInt(t2 + (t2 - t1))
end

--Exponential
local function scale(t1, t2)
	return truncateInt(t2 * (t2 / t1))
end

local function tryLower(value)
	return type(value) == 'string' and string.lower(value) or value
end

local function tryUpper(value)
	return type(value) == 'string' and string.upper(value) or value
end

local function mergeOneLevel(tbl, ref)
	for k, v in pairs(ref) do
		tbl[k] = v
	end
end

local function mergeRecursive(tbl, ref)
	table.mergeInPlace(tbl, ref, true)
end

local function clear(tbl)
	for k, v in pairs(tbl) do
		tbl[k] = nil
	end
end

local function forEachWhere(tbl, where, func)
	for k, v in pairs(tbl) do
		if where(k, v) then
			func(k, v)
		end
	end
end

local function forEachWhereNumber(tbl, func)
	forEachWhere(tbl, function(k, v) return type(v) == 'number' end, func)
end

local function forEachWhereContainsValue(tbl, subKey, match, func)
	match = tryLower(match)
	forEachWhere(tbl, function(k, v) return type(v) == 'table' and tryLower(v[subKey]) == match end, func)
end

local function mulDamage(def, mul)
	if def and def.damage then
		local d = def.damage
		mulAllInt(d, mul)
		for k, v in pairs(d) do
			if v == 0 then
				d[k] = (k == 'default' and 1) or nil
			end
		end
	end
end

local function mulTier(t1Def, t2Def, t3Def, stat)
	if t1Def and t2Def and t3Def then
		t3Def[stat] = scale(t1Def[stat], t2Def[stat])
	end
end

local function mulPrice(def, mMul, eMul)
	if def then
		def.metalcost = truncateInt(def.metalcost * mMul)
		def.energycost = truncateInt(def.energycost * eMul)
		def.buildtime = truncateInt(def.buildtime * (mMul + eMul) * 0.5)
	end
end

local function indexOfWeapon(def, id, start)
	local weapons = def and def[wpn]
	if weapons then
		local lowID = tryLower(id)
		for i = start, #weapons do
			local w = weapons[i]
			if w and w.def and tryLower(w.def) == lowID then
				return i
			end
		end
	end
	return 0
end

local function overwriteWeapon(def, defWID, ref, refWID)
	local iRef = indexOfWeapon(ref, refWID, 1)
	if iRef == 0 then
		return
	end
	local i = indexOfWeapon(def, defWID, 1)
	while i > 0 do
		local w = def[wpn][i]
		clear(w)
		mergeRecursive(w, ref[wpn][iRef])
		w.def = defWID
		i = indexOfWeapon(def, defWID, i + 1)
	end
end

local function hasCategory(tbl, key, category)
	local s = tbl and tbl[key]
	return s and string.find(' ' .. s .. ' ', ' ' .. category .. ' ', 1, true) ~= nil
end

local function addCategory(tbl, key, category)
	if tbl then
		if tbl[key] then
			tbl[key] = tbl[key] .. ' ' .. category
		else
			tbl[key] = category
		end
	end
end

--Collect Languages
do
	local codes = { 'en', 'fr', 'de', 'ru', 'zh', 'es' }
	for i = 1, #codes do
		local lang = codes[i]
		languages[lang] = openJSON('language/' .. lang .. '/units.json')
	end
end

--Collect Constructors
do
	local a = 'arm'
	local c = 'cor'
	local l = 'leg'
	local factories = {}

	local function getTeir(def)
		return tonumber(def[cps] and def[cps].techlevel) or 1
	end

	local function hasFactory(def, tier)
		for _, bo in pairs(def.buildoptions) do
			if factories[bo] == tier then
				return true
			end
		end
	end

	local function addToFaction(aList, cList, lList, faction, id)
		if faction == a then
			table.insert(aList, id)
		elseif faction == c then
			table.insert(cList, id)
		elseif faction == l then
			table.insert(lList, id)
		end
	end

	for id, def in pairs(uDefs) do
		if def and def.yardmap and def.buildoptions and next(def.buildoptions) then
			factories[id] = getTeir(def)
		end
	end

	for id, def in pairs(uDefs) do
		if def and def.buildoptions then
			table.insert(allBuilders, id)
			local faction = string.sub(id, 1, 3)
			if faction == a or faction == c or faction == l then
				if def[cps] and def[cps].iscommander then
					addToFaction(armComms, corComms, legComms, faction, id)
				elseif not def.yardmap then
					local tier = getTeir(def)
					if hasFactory(def, 3) then
						addToFaction(armAdvCons, corAdvCons, legAdvCons, faction, id)
					elseif tier <= 1 and hasFactory(def, tier + 1) then
						addToFaction(armCons, corCons, legCons, faction, id)
					end
				end
			end
		end
	end
end

local function addBuildOption(conID, id)
	local cDef = uDefs[conID]
	local uDef = uDefs[id]
	if cDef and uDef and cDef.buildoptions then
		for _, v in pairs(cDef.buildoptions) do
			if v == id then
				return
			end
		end
		table.insert(cDef.buildoptions, id)
	end
end

local function addBuildOptionArray(conIDs, id)
	for i = 1, #conIDs do
		addBuildOption(conIDs[i], id)
	end
end

local function removeBuildOption(conID, id)
	local cDef = uDefs[conID]
	local uDef = uDefs[id]
	if cDef and uDef and cDef.buildoptions then
		for k, v in pairs(cDef.buildoptions) do
			if v == id then
				table.remove(cDef.buildoptions, k)
				break
			end
		end
	end
end

local function removeBuildOptionArray(conIDs, id)
	for i = 1, #conIDs do
		removeBuildOption(conIDs[i], id)
	end
end

--Safe removal of a unit from builders.
local function removeByID(id)
	removeBuildOptionArray(allBuilders, id)
end

--Required to disable 'extra' after-tweak units.
local function deleteByID(id)
	local def = uDefs[id]
	if def then
		def.health = 0
	end
end

local function setDescription(def, name, tip, language)
	language = language or 'en'
	if def then
		def[cps] = def[cps] or {}
		if name then
			def[cps]['i18n_' .. language .. '_humanname'] = name
		end
		if tip then
			def[cps]['i18n_' .. language .. '_tooltip'] = tip
		end
	end
end

local function setDescriptionArray(def, name, tip, langs)
	langs = langs or languages
	for lang in pairs(langs) do
		setDescription(def, name, tip, lang)
	end
end

local function replaceInDescription(id, oldStr, newStr)
	local def = uDefs[id]
	if not def or oldStr == nil or newStr == nil then
		return
	end
	oldStr = tostring(oldStr)
	newStr = tostring(newStr)
	def[cps] = def[cps] or {}
	local i18nID = def[cps].i18nfromunit or id
	local wrote = false
	for lang, data in pairs(languages) do
		local units = data and data.units
		local nameKey = 'i18n_' .. lang .. '_humanname'
		local tipKey = 'i18n_' .. lang .. '_tooltip'
		local name = def[cps][nameKey] or (units and units.names and units.names[i18nID])
		local tip = def[cps][tipKey] or (units and units.descriptions and units.descriptions[i18nID])
		if tip then
			setDescription(def, name, tip:gsub(oldStr, newStr), lang)
			wrote = true
		end
	end
	if wrote then
		def[cps].i18nfromunit = nil
	end
end

local function duplicateUnit(id, newID)
	local ref = uDefs[id]
	if ref and newID then
		uDefs[newID] = table.copy(ref)
		local def = uDefs[newID]
		def.icontype = ref.icontype or id
		def[cps] = def[cps] or {}
		def[cps].i18nfromunit = nil
		local i18nID = (ref[cps] and ref[cps].i18nfromunit) or id
		for lang, data in pairs(languages) do
			local units = data and data.units
			local name = units and units.names and units.names[i18nID]
			local tip = units and units.descriptions and units.descriptions[i18nID]
			setDescription(def, name, tip, lang)
		end
		return def
	end
end

local function remodel(def, icon, object, hasDead, hasDecal)
	if def then
		def.buildpic = (icon and (icon .. '.DDS')) or def.buildpic
		if object then
			def.objectname = 'Units/' .. object .. '.s3o'
			def.script = 'Units/' .. object .. '.cob'
			if hasDead then
				def[fds] = def[fds] or {}
				def[fds].dead = def[fds].dead or {}
				def[fds].dead.object = 'Units/' .. string.lower(object) .. '_dead.s3o'
			end
			if hasDecal then
				def[cps] = def[cps] or {}
				def[cps].buildinggrounddecaltype = 'decals/' .. string.lower(object) .. '_aoplane.dds'
			end
		end
	end
end

shared.tdvars_languages = languages
shared.tdvars_armComms = armComms
shared.tdvars_corComms = corComms
shared.tdvars_legComms = legComms
shared.tdvars_armCons = armCons
shared.tdvars_corCons = corCons
shared.tdvars_legCons = legCons
shared.tdvars_armAdvCons = armAdvCons
shared.tdvars_corAdvCons = corAdvCons
shared.tdvars_legAdvCons = legAdvCons
shared.tdvars_allBuilders = allBuilders

shared.tdfuncs_round10 = round10
shared.tdfuncs_round100 = round100
shared.tdfuncs_round1000 = round1000
shared.tdfuncs_truncateInt = truncateInt
shared.tdfuncs_mulAll = mulAll
shared.tdfuncs_mulAllInt = mulAllInt
shared.tdfuncs_extrapolate = extrapolate
shared.tdfuncs_scale = scale
shared.tdfuncs_tryLower = tryLower
shared.tdfuncs_tryUpper = tryUpper
shared.tdfuncs_mergeOneLevel = mergeOneLevel
shared.tdfuncs_mergeRecursive = mergeRecursive
shared.tdfuncs_clear = clear
shared.tdfuncs_forEachWhere = forEachWhere
shared.tdfuncs_forEachWhereNumber = forEachWhereNumber
shared.tdfuncs_forEachWhereContainsValue = forEachWhereContainsValue
shared.tdfuncs_mulDamage = mulDamage
shared.tdfuncs_mulTier = mulTier
shared.tdfuncs_mulPrice = mulPrice
shared.tdfuncs_indexOfWeapon = indexOfWeapon
shared.tdfuncs_overwriteWeapon = overwriteWeapon
shared.tdfuncs_hasCategory = hasCategory
shared.tdfuncs_addCategory = addCategory
shared.tdfuncs_addBuildOption = addBuildOption
shared.tdfuncs_addBuildOptionArray = addBuildOptionArray
shared.tdfuncs_removeBuildOption = removeBuildOption
shared.tdfuncs_removeBuildOptionArray = removeBuildOptionArray
shared.tdfuncs_removeByID = removeByID
shared.tdfuncs_deleteByID = deleteByID
shared.tdfuncs_setDescription = setDescription
shared.tdfuncs_setDescriptionArray = setDescriptionArray
shared.tdfuncs_replaceInDescription = replaceInDescription
shared.tdfuncs_duplicateUnit = duplicateUnit
shared.tdfuncs_remodel = remodel