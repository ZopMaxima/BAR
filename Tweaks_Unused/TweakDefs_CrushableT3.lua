--Crushable T3
local uDefs = UnitDefs or {}
local t3Crush = 1400
local noCrush = 100000
local mcMul = 0.4
local hpMul = 0.1
for id, def in pairs(uDefs) do
	if def.movementclass and def.movementclass == 'EPICBOT' then
		def.movementclass = 'HABOT5'
	end
	if def.speed and def.featuredefs and def.featuredefs.dead then
		local dead = def.featuredefs.dead
		if not dead.crushresistance then
			local mass = 0
			if dead.mass then
				mass = dead.mass
			elseif def.mass then
				mass = def.mass * mcMul
				if dead.damage then
					mass = mass + (dead.damage * hpMul)
				end
			elseif def.metalcost then
				mass = def.metalcost * mcMul
				if dead.damage then
					mass = mass + (dead.damage * hpMul)
				end
			end
			if mass >= t3Crush and mass < noCrush then
				dead.crushresistance = t3Crush - 1
			end
		end
	end
end
uDefs['armbanth'].movementclass = 'EPICBOT'