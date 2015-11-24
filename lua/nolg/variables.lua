--[[---------------------------------------------------
		        NOLG Variable Cache
---------------------------------------------------]]--
/*    Stores all the Global Variables for NOLG    */

local NOLG = NOLG --Gonna Need all the speed we can get.

if CLIENT then
	NOLG.GradientTex = surface.GetTextureID( "gui/center_gradient" )

	NOLG.GuiThemeColor = {
		BG = Color(50,50,50,150), --BackGround Color
		FG = Color(0,0,0,150), --ForeGround Color
		GC = Color(255, 255, 255, 15), --Gradient Color
		GHO = Color(0,40,150,10),--Gradient Hover Over Color
		Text = Color(0,140,220,200) --Text Color
	}
end










