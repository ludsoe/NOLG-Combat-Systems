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

--Player Damage
function Dams.DealPlyDamage(ent,amount,attacker,inflictor)
	ent:TakeDamage(amount,inflictor,attacker)
	return true
end

--Damage dealing function.
function Dams.DealDamage(ent,amount,attacker,inflictor,ignoresafe)	
	if not IsValid(ent) or not Dams.CheckValid( ent ) then return end
	if not amount then return end
	
	ent.attacker = attacker
	ent.LastAttacked = CurTime()

	amount=math.floor(math.abs(amount))

	if amount<=0 then return end
	
	if ent:IsPlayer() or ent:IsNPC() then Dams.DealPlyDamage(ent,amount,attacker,inflictor) return end
	
	--LDE:DamageShields(ent,amount,false,attacker)
end

--Does damage directly to the health of a entity
function Dams.DamageHealth(ent,amount,override,attacker)
	--Makesure its a valid run.
	if not IsValid(ent) or not Dams.CheckValid( ent ) then return end

	local Health = Dams.GetHealth( ent )
	if Health > amount then
		Dams.SetHealth(ent,Health-amount) 
	else
		LDE:BreakOff(ent)
	end
end

--Repair function
function Dams.RepairEntity(entity,amount) end

function Dams.BreakOff(ent,dir)
	if IsValid(ent) then return end
	
	ent:SetParent(nil) --Break the dead part off from the ship.
	constraint.RemoveAll( ent )
	ent:SetSolid( SOLID_VPHYSICS )
	ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE) 
	ent:DrawShadow( false )
	ent:Fire("enablemotion","",0)

	local delay = (math.random(300, 800) / 100)
	timer.Create("Kill "..ent:EntIndex(),delay+10,1,function() Dams.KillEnt(ent) end) --Kill the ent after some time has passed.
	local physobj = ent:GetPhysicsObject()
	if IsValid(physobj) and dir~=nil then
		physobj:Wake()
		physobj:EnableMotion(true)
		local mass = physobj:GetMass()
		physobj:ApplyForceCenter(dir)				
	end
end

function Dams.KillEnt(ent)
	if not IsValid(ent) or ent:IsPlayer() then if ent:IsPlayer() then ent:Kill() end return end

	ent:Remove()
end

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