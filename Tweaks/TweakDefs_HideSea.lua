--Hide Sea
local function rmvID(id)
	local def = UnitDefs[id]
	if def then
		def.health = 0
	end
end

--Disable sea and water landing.
for id, def in pairs(UnitDefs) do
	local minWD = def.minwaterdepth
	if minWD then
		if minWD > 0 then
			rmvID(id)
		end
	end
	if def.cruisealtitude then
		if def.cansubmerge then
			def.cansubmerge = false
		end
		if def.maxwaterdepth then
			def.maxwaterdepth = 0
		end
	end
end