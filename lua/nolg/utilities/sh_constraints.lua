function constraint.GetAllWeldedEntities( ent, ResultTable ) --Modded constraint.GetAllConstrainedEntities to find only welded ents
	local ResultTable = ResultTable or {}
	if not ent or not ent:IsValid() then return end
	if ( ResultTable[ ent ] ) then return end	
	ResultTable[ ent ] = ent	
	local ConTable = constraint.GetTable( ent )	
	for k, con in ipairs( ConTable ) do	
		for EntNum, Ent in pairs( con.Entity ) do
			if con.Type == "Weld" or con.Type == "Axis" or con.Type == "Ballsocket" or con.Type == "Hydraulic" then
				constraint.GetAllWeldedEntities( Ent.Entity, ResultTable )
			end
		end	
	end
	return ResultTable	
end

function constraint.GetAllConstrainedEntities_B( ent, ResultTable ) --Modded to filter out grabbers
	local ResultTable = ResultTable or {}
	if not ent or not ent:IsValid() then return end
	if ResultTable[ ent ] then return end
	ResultTable[ ent ] = ent
	local ConTable = constraint.GetTable( ent )
	for k, con in ipairs( ConTable ) do
		for EntNum, Ent in pairs( con.Entity ) do
			if con.Type ~= "" then
				constraint.GetAllWeldedEntities( Ent.Entity, ResultTable )
			end
		end
	end
	return ResultTable
end

--Rewrite this so it detects through parents properly.
function constraint.ShipCoreDetect( ent, ResultTable ) --Modded constraint.GetAllConstrainedEntities for use with shipcores.
	local ResultTable = ResultTable or {}
	if not ent or not IsValid(ent) then return end
	if ( ResultTable[ ent ] ) then return end	
	ResultTable[ ent ] = ent	
	local ConTable = constraint.GetTable( ent )	
	for k, con in ipairs( ConTable ) do	
		for EntNum, Ent in pairs( con.Entity ) do
			if con.Type == "Weld" or con.Type == "Axis" or con.Type == "Ballsocket" or con.Type == "Hydraulic" then
				constraint.ShipCoreDetect( Ent.Entity, ResultTable )
			end
		end	
	end
	
	local children = ent:GetChildren()
	for k, child in ipairs( children ) do
		if child and IsValid(child) then
			constraint.ShipCoreDetect( child, ResultTable )
		end
	end
	
	return ResultTable	
end

--Parent Hax.
local metaent = FindMetaTable("Entity")
if not metaent.SetParentOld then metaent.SetParentOld = metaent.SetParent end

metaent.SetParent = function(self,parent)
	local OldParent = self:GetParent()
	
	if OldParent and IsValid(OldParent) then
		OldParent.ParentedChildren=OldParent.ParentedChildren or {}
		OldParent.ParentedChildren[self:EntIndex()]=nil
	end
	
	--Add a check to prevent parent loops.
	
	if parent and IsValid(parent) then
		parent.ParentedChildren=parent.ParentedChildren or {}
		parent.ParentedChildren[self:EntIndex()]=self
	end
	
	self:SetParentOld(parent)
end

metaent.GetChildren = function(self)
	self.ParentedChildren = self.ParentedChildren or {}
	return self.ParentedChildren
end
