--Extra Towers (Zop)
local uDefs = UnitDefs or {}
local cps = 'customparams'
local fds = 'featuredefs'
local wds = 'weapondefs'
local aACons = {'armaca','armack','armacv'}
local cACons = {'coraca','corack','coracv'}
local lACons = {'legaca','legack','legacv'}

local tweakMini = true
local tweakQuadLT = true
local tweakLegEpic = true

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

--Mini plasma as 'Cerberus' alternatives.
if tweakMini then
	local rangeMul = 1.25
	local epsMul = 0.5
	local aWDef = uDefs['armminivulc'][wds]['armminivulc_weapon']
	local cWDef = uDefs['corminibuzz'][wds]['corminibuzz_weapon']
	local lWDef = uDefs['legministarfall'][wds]['ministarfire']
	aWDef.range = round10(aWDef.range * rangeMul)
	cWDef.range = round10(cWDef.range * rangeMul)
	lWDef.range = round10(lWDef.range * rangeMul)
	local eps = 'energypershot'
	aWDef[eps] = aWDef[eps] * epsMul
	cWDef[eps] = cWDef[eps] * epsMul
	lWDef[eps] = lWDef[eps] * epsMul
end

--Quad towers.
if tweakQuadLT then
	local cLT = 'corhllllt'
	local aLT = 'corscavdtl'
	local lLT = 'corscavdtf'
	local cLTDef = uDefs[cLT]
	local aLTDef = uDefs[aLT]
	local lLTDef = uDefs[lLT]
	mergeMapRec(aLTDef, cLTDef)
	mergeMapRec(lLTDef, cLTDef)
	for i = 1, 4 do
		local cLTWDef = cLTDef[wds]['hllt_'..i]
		local aLTWDef = aLTDef[wds]['hllt_'..i]
		local lLTWDef = lLTDef[wds]['hllt_'..i]
		cLTWDef.range = round10(cLTWDef.range * 1.25)
		mergeMapRec(aLTWDef, uDefs['armbeamer'][wds]['armbeamer_weapon'])
		aLTWDef.range = round10(aLTWDef.range * 1.2)
		aLTWDef.reloadtime = aLTWDef.reloadtime + (i * 0.025)
		aLTWDef.beamtime = aLTWDef.reloadtime * 2
		aLTWDef.damage.default = aLTWDef.damage.default * 1.5
		aLTDef.weapons[i]['fastautoretargeting'] = true
		mergeMapRec(lLTWDef, uDefs['legmg'][wds]['armmg_weapon'])
	end
	setDesc(aLTDef, 'Quad Beamer', 'Heavy Beam Laser Turret')
	setDesc(lLTDef, 'Quad Cacophony', 'Heavy Machine Gun Turret')
	addBOArr(aACons, aLT)
	addBOArr(lACons, lLT)
end

--Legion epic defense.
local cDoom = 'cordoomt3'
local lDoom = 'corscavdtm'
if tweakLegEpic then
	local cDoomDef = uDefs[cDoom]
	local lDoomDef = uDefs[lDoom]
	mergeMapRec(lDoomDef, cDoomDef)
	local lDoomWDef1 = lDoomDef[wds]['armagmheat']
	local lDoomWDef2 = lDoomDef[wds]['armageddon_blue_laser']
	local lDoomWDef3 = lDoomDef[wds]['armageddon_green_laser']
	mergeMapRec(lDoomWDef1, uDefs['legsrailt4'][wds]['railgunt2'])
	lDoomWDef1.cegtag = 'railgun'
	lDoomWDef1.collidefriendly = false
	lDoomWDef1.rgbcolor2 = '1 1 1'
	lDoomWDef1.weaponvelocity = lDoomWDef1.weaponvelocity * 1.5
	mergeMapRec(lDoomWDef2, uDefs['legerailtank'][wds]['t3_rail_accelerator'])
	lDoomWDef2.range = round10(lDoomWDef2.range * 1.5)
	mergeMapRec(lDoomWDef3, uDefs['legdtr'][wds]['corlevlr_weapon'])
	lDoomWDef3.reloadtime = lDoomWDef3.reloadtime * 0.375
	lDoomWDef3.rgbcolor = '1 0.8 0'
	setDesc(lDoomDef, 'Trident', 'Super Heavy Railgun Defense')
	addBOArr(lACons, lDoom)
	addBO('legcomlvl8', lDoom)
	addBO('legcomlvl9', lDoom)
	addBO('legcomlvl10', lDoom)
else
	addBOArr(lACons, cDoom)
	addBO('legcomlvl8', cDoom)
	addBO('legcomlvl9', cDoom)
	addBO('legcomlvl10', cDoom)
end
addBO('corcomlvl8', cDoom)
addBO('corcomlvl9', cDoom)
addBO('corcomlvl10', cDoom)