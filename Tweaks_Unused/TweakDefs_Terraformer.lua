--Terraformer (Zop)
local uDefs = UnitDefs or {}
local cps = 'customparams'

local tweakTerraform = true

local function addBO(conID, id)
	local cDef = UnitDefs[conID]
	local uDef = UnitDefs[id]
	if cDef and uDef and not cDef.buildoptions[id] then
		table.insert(cDef.buildoptions, id)
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

--Terraformer
if tweakTerraform then
	local newID = 'terrat1'
	local y = 'yyyyyyyyyyyyyyyyyyyyyyyy'
	y = y .. y .. y .. y .. y .. y
	y = y .. y .. y .. y
	uDefs[newID] = {
		health = 10,
		autoheal = -10,
		buildtime = 100,
		metalcost = 10,
		energycost = 1000,
		footprintx = 24,
		footprintz = 24,
		maxslope = 45,
		buildpic = 'other/chip.dds',
		objectname = 'chip.s3o',
		script = 'chip.lua',
		yardmap = y,
		customparams = { unitgroup = 'util' },
	}
	setDesc(uDefs[newID], 'Terraformer', 'The factory must grow!')
	for k, v in pairs(uDefs) do
		if v.buildoptions and v[cps] and v[cps].iscommander then
			addBO(k, newID)
		end
	end
end
