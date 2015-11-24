AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "NOLG Prop Core"
ENT.Author			= "Ludsoe"
ENT.Category		= "Other"
ENT.Spawnable		= true

if(SERVER)then
	function ENT:Initialize()  
		self:SetModel("models/props_lab/reciever01b.mdl")
		
		self:PhysicsInit( SOLID_VPHYSICS )  	
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )      
		
		local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
		self.Outputs = WireLib.CreateSpecialOutputs( self,
			 { "Health", "Total Health" ,"Shields" ,"Max Shields", "Mount Points", "Mount Capacity" , "Temperature","Freezing Point",  "Melting Point", "OverHeating", "Attacker" },
			{N,N,N,N,N,N,N,N,N,N,E}
			)
		self.Inputs = Wire_CreateInputs(self, { "SelfDestruct","Vent Shields","UnLink All" })
		
		--Setup all of our variables.
		self.Thinkz= 0
		self.PropCore = self
		self.NOLG = {CorePoints=0,MaxCorePoints=1,CoreHealth=1,CoreMaxHealth=1,CoreShield=0,CoreMaxShield=0,TotalHealth=1,CanRecharge=1,Flashing=1,DeathSeq=false}
		self.Props ={} self.Weapons ={} self.CoreLinked ={} self.PropHealth ={} self.Shielded ={} 
		self.ShipClass = "Calculating"
		
		self:CoreLink(self)
		
		self:CoreHealth()
		
		self.NOLG.CoreHealth = self.NOLG.CoreMaxHealth
		self.NOLG.CorePoints = self.NOLG.MaxCorePoints
		
		WireLib.TriggerOutput( self, "Health", self.NOLG.CoreHealth or 0 )
		WireLib.TriggerOutput( self, "Total Health", self.NOLG.CoreMaxHealth or 0 )
		WireLib.TriggerOutput( self, "Shields", self.NOLG.CoreShield or 0 )
		WireLib.TriggerOutput( self, "Max Shields", self.NOLG.CoreMaxShield or 0 )
		WireLib.TriggerOutput( self, "Mount Points", self.NOLG.CorePoints or 0 )
		WireLib.TriggerOutput( self, "Mount Capacity", self.NOLG.MaxCorePoints or 0 )
		
		self:SetNWInt("PropCoreType", "Basic")
		self:SetNWInt("PropCoreClass", "Registering")
		
		self:NextThink( CurTime() + 1 )
		return true
	end
	
	function ENT:SetOptions( ply )
		self.Owner = ply
	end

	function ENT:ClearProp( Entity )
		for key, ent in pairs( self.Props ) do
			if Entity == ent then
				table.remove( self.Props, key )
				self.Prophealth[ent:EntIndex()] = nil
				return --Stop the loop there.
			end
		end
	end

	function ENT:CoreLink(Entity)
		if(Entity.PropCore and not Entity.PropCore == self)then
			Entity.PropCore:CoreUnLink(Entity)
		end
		self.CoreLinked[Entity:EntIndex()]=Entity
		Entity.PropCore = self
		if Entity.IsLDEWeapon or Entity.PointCost then
			self.Weapons[Entity:EntIndex()] = Entity
			if Entity.HasPoints == false and Entity.PointCost <= self.NOLG.CorePoints then
				self.NOLG.CorePoints=self.NOLG.CorePoints-Entity.PointCost
				Entity.HasPoints=true
			end
		end
	end

	function ENT:CoreUnLink( Entity )
		for key, ent in pairs( self.CoreLinked ) do
			if Entity == ent then
				table.remove( self.CoreLinked, key )
				Entity.PropCore = nil
				if Entity.IsLDEWeapon or Entity.PointCost then
					if Entity.HasPoints == true then
						self.Weapons[Entity:EntIndex()] = nil
						self.NOLG.CorePoints=self.NOLG.CorePoints+Entity.PointCost
						Entity.HasPoints=false
					end
				end
				return --Stop the loop there.
			end
		end
	end
	
	function ENT:UnLinkAll()
		if not self.CoreLinked then return end
		for _, ent in pairs( self.CoreLinked ) do
			if ent and IsValid(ent) then
				ent.PropCore = nil
				ent.Shield = nil
			end
		end
		self.CoreLinked={}
	end
	
	function ENT:Think() 
		if not self.Thinkz then return end--WOT
		if self.NOLG.DeathSeq then
			--NOLG:ExplodeCore(self)
		end
		
		self.Thinkz=self.Thinkz+1
		if(self.Thinkz>=5)then
			self.Thinkz=0
			self:CoreHealth()
			
			self.NOLG.CorePoints = self.NOLG.MaxCorePoints --Set the points to max.
			
			for key, ent in pairs( self.Weapons ) do
				if ent and IsValid(ent) then
					if ent.PointCost <= self.NOLG.CorePoints then
						self.NOLG.CorePoints=self.NOLG.CorePoints-ent.PointCost
						ent.HasPoints=true
					else
						ent.HasPoints=false
					end
				else
					table.remove( self.Weapons, key )
				end
			end
							
			self:CoreClass()
		end

		local Networked = {
			CoreMaxHealth = "MaxHealth",CoreHealth = "Health",CoreMaxShield	= "MaxShield",
			CoreShield = "Shield",MaxCorePoints = "MaxCorePoints",CorePoints = "CorePoints"
		}
			
		-- Set NW ints
		for DV, NW in pairs(Networked) do
			local hp = self:GetNWInt(NW)
			if not hp or hp ~= self.NOLG[DV] then
				--   print("Synced "..NW.." as "..DV.." for "..self.NOLG[DV])
				self:SetNWInt(NW, self.NOLG[DV])
			end				
		end

		self:NextThink( CurTime() + 1 )
		return true
	end
	
	function ENT:OnRemove()
		self:UnLinkAll()
	end

	function ENT:BuildDupeInfo()
		local info = self.BaseClass.BuildDupeInfo(self) or {}
		return info
	end

	function ENT:ApplyDupeInfo( ply, ent, info, GetEntByID )
		self.BaseClass.ApplyDupeInfo( self, ply, ent, info, GetEntByID )
	end
	
	--Redo these so they fit better.
	local ShipClasses = {"Heavy - Fighter / Bomber / Interceptor","Corvette","Frigate","Heavy Frigate","Destroyer","Cruiser"}

	--Determines the cores class
	function ENT:CoreClass()
		local T = self.NOLG.CoreMaxShield+self.NOLG.CoreMaxHealth
		self.NOLG.TotalHealth = T
		local Classification = "Fighter / Bomber / Interceptor"
		
		for i, cls in pairs( ShipClasses ) do
			local Scale = 50000*(i*((i/5)+(i/10)))
			if T > Scale then
				Classification = cls
			else
				break
			end
		end

		self.ShipClass = Classification
		self:SetNWInt("PropCoreClass", Classification)
	end

	--Calculates the health of a core.
	function ENT:CoreHealth()
		-- Get all constrained props
		self.Props = constraint.ShipCoreDetect(self)
					
		-- Loop through all props
		local hp = self.NOLG.CoreHealth
		local maxhp,maxsd,CPS = 1,1,0
		
		for _, ent in pairs( self.Props ) do
			if ent and NOLG.DamageSystem.CheckValid( ent ) then
				if not self.PropHealth then self.PropHealth={} end --Make sure we have the prop health table.	
				
				local entcore = ent.PropCore
				local health = self.PropHealth[ent:EntIndex()] or 0
				local enthealth = NOLG.DamageSystem.GetHealth(ent)
				local Calcedhealth = NOLG.DamageSystem.CalculateEntityHealth(ent)
				local maxhealth = Calcedhealth
				local entshield = Calcedhealth*1.2
				local entpoints = Calcedhealth*0.4
				
				if not entcore or not IsValid(entcore) then -- if the entity has no core
					ent.PropCore = self
					ent.Shield = self --Environments Damage Override Compatability
					self.PropHealth[ent:EntIndex()] = enthealth
					self:CoreLink(ent) --Link it to our core :)
					hp = hp + enthealth
				elseif (entcore and entcore == self and enthealth != health) then -- if the entity's health has changed
					hp = hp - health -- subtract the old health
					hp = hp + enthealth -- add the new health
					self.PropHealth[ent:EntIndex()] = enthealth
				elseif (entcore and entcore != self) then -- if the entity already has a core
					continue --Guess we dont get that prop :(
				end
				
				maxhp=(maxhp+maxhealth)
				maxsd=maxsd+entshield
				CPS=CPS+entpoints
			end
		end
		
		-- Set health
		self.NOLG.CoreHealth = hp
		self.NOLG.CoreMaxHealth = maxhp
		self.NOLG.CoreMaxShield = maxsd
		self.NOLG.MaxCorePoints=CPS
		
		if (self.NOLG.CoreHealth > self.NOLG.CoreMaxHealth) then 
			self.NOLG.CoreHealth = self.NOLG.CoreMaxHealth
		end
		
		-- Wire Output
		WireLib.TriggerOutput( self, "Health", self.NOLG.CoreHealth or 0 )
		WireLib.TriggerOutput( self, "Total Health", self.NOLG.CoreMaxHealth or 0 )
		WireLib.TriggerOutput( self, "Shields", self.NOLG.CoreShield or 0 )
		WireLib.TriggerOutput( self, "Max Shields", self.NOLG.CoreMaxShield or 0 )
		WireLib.TriggerOutput( self, "Mount Points", self.NOLG.CorePoints or 0)	
		WireLib.TriggerOutput( self, "Mount Capacity", self.NOLG.MaxCorePoints or 0 )	
	end
else

	function ENT:Draw()      
		self:DrawDisplayTip()
		self:DrawModel()
	end
		
	function ENT:DrawDisplayTip()		
		
		if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512) then
			NOLG.MenuCore.RenderWorldTip(self,function(self)
				return {
					{Type="Label",Value="Type: "..self:GetNWString("PropCoreType")},
					{Type="Label",Value="Class: "..self:GetNWString("PropCoreClass")},
					{Type="Percentage",
						Value=math.Round(self:GetNWInt("Health"))/math.Round(self:GetNWInt("MaxHealth")),
						Text="Health: "..math.Round(self:GetNWInt("Health")).." / "..math.Round(self:GetNWInt("MaxHealth"))
					},
					{Type="Percentage",
						Value=math.Round(self:GetNWInt("Shield"))/math.Round(self:GetNWInt("MaxShield")),
						Text="Shields: "..math.Round(self:GetNWInt("Shield")).." / "..math.Round(self:GetNWInt("MaxShield"))
					},
					{Type="Percentage",
						Value=math.Round(self:GetNWInt("CorePoints"))/math.Round(self:GetNWInt("MaxCorePoints")),
						Text="Processor: "..math.Round(self:GetNWInt("CorePoints")).." / "..math.Round(self:GetNWInt("MaxCorePoints"))
					}
				}
			end)
		end
	end
	
end		
