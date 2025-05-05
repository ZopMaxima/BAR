--Smaller Wrecks
local scale = 0.75
for id, def in pairs(UnitDefs) do
	if def.canmove and def.featuredefs and def.featuredefs.dead then
		local dead = def.featuredefs.dead
		dead.footprintx = math.max(1, math.floor(dead.footprintx * scale))
		dead.footprintz = math.max(1, math.floor(dead.footprintz * scale))
	end
end