--[[----------------------------------------------------
Jupiter Menu Core -Provides a modular menu system.
----------------------------------------------------]]--

local NOLG = NOLG --Localise the global table for speed.
NOLG.MenuCore = NOLG.MenuCore or {}

local MC = NOLG.MenuCore

if(CLIENT)then
	
	function MC.CheckOpenFrame(Remove)
		if MC.OpenFrame then
			if IsValid(MC.OpenFrame) then
				if Remove then
					MC.OpenFrame:Remove()
				else
					return true
				end
			end
		end
		return false
	end
	
	function MC.SetOpenFrame(Frame)
		MC.OpenFrame = Frame
	end

	---------------------------------------------------------------
	---------------Vgui Derma Related Functions--------------------
	---------------------------------------------------------------
	
	function MC.CreateFrame(Size,Visible,XButton,Draggable,CloseDelete)
		local Derma = vgui.Create( "DFrame" )
			if Derma then
				Derma:SetSize( Size.x, Size.y )
				Derma:SetVisible( Visible )
				Derma:ShowCloseButton( XButton )
				Derma:SetDraggable( Draggable )
				Derma:SetDeleteOnClose( CloseDelete )
				
				Derma:SetTitle("")
			
				function Derma:SetTitle(txt) self.Title = txt end Derma:SetTitle("")
				function Derma:SetColor(Col) self.RenderColor = Col end Derma:SetColor(NOLG.GuiThemeColor.BG) --Dont Forget to set a color so we dont get nil Errors.
				function Derma:SetGradientColor(Col) self.RenderGradientColor = Col end Derma:SetGradientColor(NOLG.GuiThemeColor.GC) --Dont Forget to set a color so we dont get nil Errors.
				
				Derma.Paint = function( self, w, h )
					draw.RoundedBox( 16, 0, 0, w, h, self.RenderColor )
					
					--Draw an texture gradient
					local GC = self.RenderGradientColor
					if GC.a>0 then
						surface.SetTexture( NOLG.GradientTex )
						surface.SetDrawColor( GC.r, GC.g, GC.b, GC.a )
						surface.DrawTexturedRect( 0, 0, w, h )
					end
					
					--Draw the title text
					local tw,th = surface.GetTextSize( self.Title )
					draw.DrawText(self.Title, "DermaDefault",tw+20,th, NOLG.GuiThemeColor.Text, 2)
				end		
			end
		return Derma
	end
	
	function MC.CreatePanel(Parent,Size,Spot,Draw)
		local Derma = vgui.Create( "DPanel", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			
			function Derma:SetColor(Col) self.RenderColor = Col end Derma:SetColor(NOLG.GuiThemeColor.BG) --Dont Forget to set a color so we dont get nil Errors.
			function Derma:SetGradientColor(Col) self.RenderGradientColor = Col end Derma:SetGradientColor(NOLG.GuiThemeColor.GC) --Dont Forget to set a color so we dont get nil Errors.

			Derma.Paint = Draw or Derma.Paint
		return Derma
	end

	function MC.CreateTextBar(Parent,Size,Spot,Text,Func)
		local Derma = vgui.Create( "DTextEntry", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetText( Text )
			Derma.OnEnter = function( self )
				Func( self:GetValue() )	
			end
		return Derma
	end

	function MC.AdvTextInput(Parent,Size,Spot,Text,Value,Func)
		local Input = MC.CreatePanel(Parent,{x=Size.x,y=Size.y},{x=Spot.x,y=Spot.y})
		Input.TextLabel = MC.CreateText(Input,{x=5,y=3},Text,Color(0,0,0,255))
		Input.InputBox = MC.CreateTextBar(Input,{x=(Size.x)/4,y=Size.y},{x=Size.x*0.75,y=0},Value,Func)
		
		Input.SetText= function(self,Text) self.TextLabel:SetText(Text) end
		Input.SetValue= function(self,Value) self.InputBox:SetText(Value) end
		
		return Input
	end
	
	function MC.CreatePSheet(Parent,Size,Spot)
		local Derma = vgui.Create( "DPropertySheet", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
				
			Derma.OldAddSheet = Derma.AddSheet
			function Derma:AddSheet(label, panel, material, NoStretchX, NoStretchY, Tooltip)
				local Dat = Derma:OldAddSheet(label, panel, material, NoStretchX, NoStretchY, Tooltip)
				
				local Tab = Dat.Tab
				
				function Tab:SetColor(Col) self.RenderColor = Col end Tab:SetColor(NOLG.GuiThemeColor.FG)
				Tab.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
					draw.RoundedBox( 5, 4, 4, w-4, h-4, self.RenderColor ) -- Draw a red box instead of the frame
				end	
				
				return Dat
			end
			
			function Derma:SetColor(Col) self.RenderColor = Col end Derma:SetColor(NOLG.GuiThemeColor.FG)

			Derma.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
				draw.RoundedBox( 16, 0, 0, w, h, self.RenderColor ) -- Draw a red box instead of the frame
			end	
			
		return Derma
	end
	
	function MC.DisplayModel(Parent,Size,Spot,Model,View,Look)
		local Derma = vgui.Create( "DModelPanel", Parent )
			Derma:SetModel(Model)
			Derma:SetSize( Size, Size )
			Derma:SetCamPos(Vector(View,View,View))
			if(Look)then
				Derma:SetLookAt(Vector(0,0,Look))
			end
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end	
	
	function MC.CreatePBar(Parent,Size,Spot,Progress)
		local Derma = vgui.Create( "DPanel", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			
			function Derma:SetFraction(frac) self.Fraction = math.Clamp(frac,0,1) end Derma:SetFraction(0)
			function Derma:SetBGColor(Col) self.RenderBGColor = Col end Derma:SetBGColor(NOLG.GuiThemeColor.BG) --Dont Forget to set a color so we dont get nil Errors.
			function Derma:SetFGColor(Col) self.RenderFGColor = Col end Derma:SetFGColor(Color(0,0,100)) --Dont Forget to set a color so we dont get nil Errors.
			function Derma:SetGradientColor(Col) self.RenderGradientColor = Col end Derma:SetGradientColor(NOLG.GuiThemeColor.GC) --Dont Forget to set a color so we dont get nil Errors.
			
			Derma.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
				draw.RoundedBox( 5, 0, 0, w, h, self.RenderBGColor )
				draw.RoundedBox( 5, 0, 0, w*self.Fraction, h, self.RenderFGColor )
				
				--Draw an texture gradient
				local GC = self.RenderGradientColor
				if GC.a>0 then
					surface.SetTexture( NOLG.GradientTex )
					surface.SetDrawColor( GC.r, GC.g, GC.b, GC.a )
					surface.DrawTexturedRect( 0, 0, w, h )
				end
			end	

			if Progress then
				Derma:SetFraction( Progress() )
				Derma.OThink=Derma.Think
			
				Derma.Think=function(self)
					self:SetFraction( Progress())
					--self:OThink()
				end
			end
		return Derma
	end
	
	function MC.CreateText(Parent,Spot,Text,Color, Font)
		local Derma = vgui.Create( "DLabel", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetText( Text or "" )
			if Font then Derma:SetFont(Font) end
			Derma:SetTextColor( Color or NOLG.GuiThemeColor.Text )
			Derma.OldText = Derma.SetText
			Derma.SetText = function(self,Text)
				self:OldText(Text)
				self:SizeToContents()
			end
			Derma:SizeToContents()
		return Derma
	end
	
	function MC.CreateAdvText(Parent,Size,Spot,Text,Color)	
		local Derma = vgui.Create( "DPanel", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )			
			function Derma:SetText(Text) self.Text = Text end Derma:SetText( Text or "" )
			function Derma:SetTextColor(Col) self.TextColor = Col end Derma:SetTextColor( Color or NOLG.GuiThemeColor.Text )
			
			function Derma:Paint(w,h)
				local TC = self.TextColor
				surface.SetTextColor( TC.r, TC.g, TC.b, TC.a )
				
				local explode = string.Explode(" ",self.Text or "")
				local NewLines = {}
				
				local line = ""
				for _, textLine in pairs(explode) do
					local text = line..textLine.." "
					tw,th = surface.GetTextSize(text)
					if tw < w-20 then
						line = text
					else
						table.insert(NewLines,line)
						line = textLine.." " 
					end
				end
				table.insert(NewLines,line)
				
				posy=0
				for _, textLine in pairs (NewLines) do
					surface.SetTextPos( 5, posy )
					surface.DrawText(textLine)
					posy = posy + 10
				end
			end
			
			Derma:SizeToContents()
		return Derma
	end
	
	function MC.PropertyGrid(Parent,Size,Spot)
		local Derma = vgui.Create( "DProperties",Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			Derma.GetPParent = function() return Parent end
			Derma.GetPSize = function() return Size end
			Derma.GetPPos = function() return Spot end
		return Derma
	end
	
	function MC.CreateList(Parent,Size,Spot,Multi,Func)
		local Derma = vgui.Create( "DListView", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetMultiSelect(Multi)
			if Func then 
				Derma.OldThink = Derma.Think or function() end
				Derma.Think = function(self) 	
					if self:GetSelected() and self:GetSelected()[1] then 
						local selectedValue = self:GetSelected()[1]:GetValue(1) 
						if selectedValue ~= self.Selected then 
							self.Selected = selectedValue
							Func(selectedValue)
						end
					end 
					self:OldThink() 
				end 
			end
		return Derma
	end	
			
	function MC.LoadWebpage(Parent,Size,Link)
		local Derma = vgui.Create("HTML",Parent)
		Derma:SetSize(Size.x, Size.y)
		Derma:OpenURL(Link)
		return Derma		
	end
	
	function MC.CreateButton(Parent,Size,Spot,Text,OnClick)
		local Derma = vgui.Create( "DButton", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetText( Text or "" )
			Derma.DoClick = OnClick or function() end
			Derma:SetColor(NOLG.GuiThemeColor.Text)
			
			function Derma:SetBGColor(Col) self.RenderColor = Col end Derma:SetBGColor(NOLG.GuiThemeColor.FG)
			function Derma:SetGradientColor(Col) self.RenderGradientColor = Col end Derma:SetGradientColor(NOLG.GuiThemeColor.GC)
			function Derma:SetGradientColorOver(Col) self.RenderGradientColorOver = Col end Derma:SetGradientColorOver(NOLG.GuiThemeColor.GHO)

			Derma.Paint = function( self, w, h )
				draw.RoundedBox( 6, 0, 0, w, h, self.RenderColor )

				--Draw an texture gradient
				local GC = self.RenderGradientColor
				if self.Hovered then GC = self.RenderGradientColorOver end
				if GC.a>0 then
					surface.SetTexture( NOLG.GradientTex )
					surface.SetDrawColor( GC.r, GC.g, GC.b, GC.a )
					surface.DrawTexturedRect( 0, 0, w, h )
				end		
			end
		return Derma
	end
	
	function MC.CreateCheckbox(Parent,Spot,Text,Func)
		local Derma = vgui.Create( "DCheckBoxLabel", Parent )
		Derma:SetPos( Spot.x, Spot.y )
		Derma:SetText( Text )
		Derma:SetChecked( 0 )
		Derma:SizeToContents() -- Make its size to the contents. Duh?
		
		Derma.ChFunc = Func
		
		function Derma:OnChange(value)
			if not self.ChFunc then return end
			if value then
				self.ChFunc(1)
			else
				self.ChFunc(0)
			end
		end
		return Derma
	end

	function MC.CreateSlider(Parent,Size,Spot,Values,Text,Func)
		local Derma = vgui.Create( "DNumSlider", Parent )
			Derma:SetMinMax( Values.Min, Values.Max )
			Derma:SetDecimals( Values.Dec )
			Derma:SetValue(Values.Val or 0)
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetText( Text )
			Derma:SetWide(Size.x)
			
			function Derma:OnValueChanged(Value)
				if Func then
					Func(Value)
				end
			end				
		return Derma
	end
	
	---------------------------------------------------------------
	--------------Draw Library Related Functions-------------------
	---------------------------------------------------------------
	
	function MC.DrawRoundedBox(Size,Spot,Color,Sides)
		draw.RoundedBoxEx( Sides.R, Spot.x, Spot.y, Size.x, Size.y, Color, Sides.TL, Sides.TR, Sides.BL, Sides.BR )
	end
	
	---------------------------------------------------------------
	----------WorldTip Replacement Related Functions---------------
	---------------------------------------------------------------	
	surface.CreateFont("GModWorldtip", {font = "coolvetica", size = 24, weight = 500})
	
	function MC.RenderWorldTip(Ent,Func)
		if not Ent or not IsValid(Ent) then return end
		local ScreenSize = Vector(ScrW(),ScrH(),0)
		local Pos = Ent:LocalToWorld(Ent:OBBCenter()):ToScreen()
		if MC.WorldTip and IsValid(MC.WorldTip) then
			local Panel = MC.WorldTip
			Panel:MakeInfo()
			local x,y = Panel:GetSize()
			local paneloffset = 0.05		--For quick changing of zee offset amount
			
			Panel:SetPos(math.Clamp(Pos.x-(x/2),0,ScreenSize.x-x),math.Clamp(Pos.y-(--[[y/2]] y)-(ScreenSize.y*paneloffset),0,ScreenSize.y-y))
		else
			local Panel = MC.CreatePanel(nil,{x=10,y=10},{x=Pos.x,y=Pos.y},function( self, w, h )
				draw.RoundedBox( 16, 0, 0, w, h, self.RenderColor )
				
				--Draw an texture gradient
				local GC = self.RenderGradientColor
				if GC.a>0 then
					surface.SetTexture( NOLG.GradientTex )
					surface.SetDrawColor( GC.r, GC.g, GC.b, GC.a )
					surface.DrawTexturedRect( 0, 0, w, h )
				end
			end)
			
			Panel.Ent = Ent

			Panel.Think = function(self)
				local TR = LocalPlayer():GetEyeTrace()
				local TRE = TR.Entity
				if not TRE or not IsValid(TRE) or EyePos():Distance( TR.HitPos ) > 512 then
					self:Remove()
					return false
				else
					if TRE ~= self.Ent then
						self:Remove()
						return false
					end
				end
			end
			
			Panel.Texts = {}
			
			function Panel:MakeInfo()
				local Height = 10
				local Width = self:GetWide()
				
				local Data = Func(Ent)
				
				local DataMisMatch = false
				
				--Check if the data matchs properly.
				if table.Count(self.Texts)==table.Count(Data) then
					for i, n in pairs( Data ) do
						local ST = self.Texts[i]
						if ST.Type~=n.Type then
							DataMisMatch = true
						else
							if ST.Text and not IsValid(ST.Text) then
								DataMisMatch = true
							end
							if ST.Progress and not IsValid(ST.Progress) then
								DataMisMatch = true
							end							
						end
					end
				else
					DataMisMatch = true
				end
				
				if DataMisMatch then
					--print("Data MissMatch!")
					for i, n in pairs( self.Texts ) do
						if n.Text and IsValid(n.Text) then
							n.Text:Remove()
						end
						
						if n.Progress and IsValid(n.Progress) then
							n.Progress:Remove()
						end
					end
			
					for i, n in pairs( Data ) do
						local w,h = 0,0
						if n.Type == "Label" then
							local T = MC.CreateText(self,{x=10,y=Height},n.Value)
							T:SetFont("GModWorldtip")
							T:SizeToContents()
							
							self.Texts[i]={Type=n.Type,Text=T}
							
							surface.SetFont( "GModWorldtip" ) -- Hack!
							w,h = surface.GetTextSize(n.Value)
						elseif n.Type == "Percentage" then
							surface.SetFont( "GModWorldtip" ) -- Hack!
							tw,th = surface.GetTextSize(n.Text)
							
							local P = MC.CreatePBar(self,{x=tw+20,y=30},{x=10,y=Height})
							P:SetFraction(n.Value)
							
							local T = MC.CreateText(self,{x=20,y=Height+5},n.Text)
							T:SetFont("GModWorldtip")
							T:SizeToContents()
							
							self.Texts[i]={Type=n.Type,Text=T,Progress=P}
							
							w,h = tw+20,30
						end
						
						Height=Height+h
						
						if w+20 > Width then
							Width = w+20
						end
					end
				else				
					for i, n in pairs( Data ) do
						local w,h = 0,0
						local Gui = self.Texts[i]
						if n.Type == "Label" then
							Gui.Text:SetText(n.Value)
						
							surface.SetFont( "GModWorldtip" ) -- Hack!
							w,h = surface.GetTextSize(n.Value)
						elseif n.Type == "Percentage" then
							Gui.Text:SetText(n.Text)
							
							surface.SetFont( "GModWorldtip" ) -- Hack!
							tw,th = surface.GetTextSize(n.Text)
							
							local x,y = MC.WorldTip:GetSize()
							
							--Gui.Progress:SetSize(tw+20,30)
							Gui.Progress:SetSize(x-20,30)
							Gui.Progress:SetFraction(n.Value)
							
							local V = math.Clamp(n.Value,0.001,1)
							
							local Red = math.Clamp(255 - ((255*2) * V), 0, 255)
							local Green = math.Clamp(-255 + ((255*2) * V), 0, 255)
							local Blue = math.Clamp(255 - Red*2 - Green*2, 0, 255)
							
							local Col = Color(Red,Green,Blue,255)
							
							Gui.Progress:SetFGColor(Col)
							
							w,h = tw+20,30
						end
						
						Height=Height+h
					
						if w+20 > Width then
							Width = w+20
						end
					end
				end
				self:SetSize(Width,Height+10)
			end
			Panel:MakeInfo()
			
			MC.WorldTip = Panel
		end
	end
else
	----Server side-----

end