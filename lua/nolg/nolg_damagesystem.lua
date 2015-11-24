local NOLG = NOLG
local Utl = NOLG.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

print("Loading Damage Systems")

--My Data
NOLG.DamageSystem = {}
local Dams = NOLG.DamageSystem

--Settings
local MaxHealth = 1000000	-- Max Health Allowed
local MinHealth = 100 -- Minimum Health Allowed

----Health Related functions----

--Calculates an entitys health, and returns it.
function Dams.CalculateEntityHealth(entity) 
	local health = math.Round(Dams.GetVolume(ent)*0.01)
	
	Dams.SetMaxHealth(entity,health)
	Dams.SetHealth(entity,health)
	
	return health
end

--Sets a entitys health
function Dams.SetHealth(entity,health) 
	entity.NOLGHealth = math.Clamp(health,MinHealth,Dams.GetMaxHealth(entity))
end

--Returns a entitys health
function Dams.GetHealth(entity) 
	return entity.NOLGHealth or Dams.CalculateEntityHealth(entity)
end

--Sets a entitys max health
function Dams.SetMaxHealth(entity,health) 
	entity.NOLGMaxHealth = math.Clamp(health,MinHealth,MaxHealth)
end

--Returns a entitys max health
function Dams.GetMaxHealth(entity) 
	return entity.NOLGMaxHealth or Dams.CalculateEntityHealth(entity)
end

----Damage Dealing and Repair----

--Damage dealing function.
function Dams.DealDamage(entity,damage) end

--Repair function
function Dams.RepairEntity(entity,amount) end

--Utility function to mark entity as dead.
function Dams.MarkAsDead(entity) end

--Marks a entity as dead if part of a contraption, removes if not.
function Dams.KillEntity(entity) end

----Support Functions----

--Grabs the volume of an entity
function Dams.GetVolume(ent)
	local dif = ent:OBBMaxs() - ent:OBBMins()	
	return dif.x * dif.y * dif.z
end

--Checks to makesure the entity is a valid model for damage.
function Dams.CheckValid( entity )
	if not IsValid(entity) then return false end
	if entity:IsWorld() then return false end
	
	local Phys = entity:GetPhysicsObject()
	if not IsValid(Phys) then return false end
	if not Phys:GetVolume() or not Phys:GetMass() then return false end
	
	return true
end