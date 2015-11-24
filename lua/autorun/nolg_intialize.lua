------------------------------------------
//     NOLG Mod Intialize System        //
------------------------------------------
print("==============================================")
print("==            NOLG    Loading...            ==")
print("==============================================")

AddCSLuaFile()--Make Sure the client gets it.

local start = SysTime()

NOLG = {}
local NOLG = NOLG --MAH SPEED

NOLG.Version = "Ultra Early V:0.01"
NOLG.Gamemode = "SandBox"
NOLG.EnableMenu = true --Debug Menu
NOLG.DebugMode = "Verbose" 
/*Print to console Debugging variable. 
Types: 
"Verbose" -Prints All Debugging messages.
"Basic"-Prints Basic Debugging messages.
"None"-Doesnt print to console at all.
*/ 

-- 0 Client 1 Shared 2 Server
function NOLG.LoadFile(Path,Mode) --Easy way of loading files.
	if SERVER then
		if Mode >= 1 then
			include(Path)
			if Mode == 1 then
				AddCSLuaFile(Path)
			end
		else
			AddCSLuaFile(Path)
		end
	else
		if Mode <= 1 then
			include(Path)
		end
	end
end
local LoadFile = NOLG.LoadFile --Lel Speed.

LoadFile("nolg/variables.lua",1)

LoadFile("nolg/utilities/sh_debug.lua",1)
LoadFile("nolg/utilities/sh_utility.lua",1)
LoadFile("nolg/utilities/sh_networking.lua",1)
LoadFile("nolg/utilities/sh_datamanagement.lua",1)
LoadFile("nolg/utilities/sh_vguiease.lua",1)

LoadFile("nolg/nolg_damagesystem.lua",2)

if(SERVER)then
	--Resources this mod uses.
	resource.AddFile("resource/fonts/digital-7 (italic).ttf")
	
	--resource.AddWorkshop( "174935590" ) --Spore Models
	resource.AddWorkshop( "160250458" ) --Wire Models
else
	
end			

print("==============================================")
print("==     NOLG Combat Systems Installed        ==")
print("==============================================")
print("NOLG Combat Systems Load Time: "..(SysTime() - start))