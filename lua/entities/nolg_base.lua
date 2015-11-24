AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "NOLG Base Entity"
ENT.Author			= "Ludsoe"
ENT.Category		= "Other"
ENT.Spawnable		= false

if(SERVER)then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid(SOLID_VPHYSICS)
	
		local phy = self:GetPhysicsObject()
		if phy:IsValid() then phy:Wake() end
		
	end
end		
