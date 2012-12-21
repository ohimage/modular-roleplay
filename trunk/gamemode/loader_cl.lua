local NRP = NRP
if( not GAMEMODE and GM )then GAMEMODE = GM end -- make sure we have the tables we need.

print("Loaded CL Loader")

/*=================================
LOADING MODULES
=================================*/
net.Receive("NeoRP_ModuleList",function()
	NRP.LoadMessageBig("Recieving MODULE Table from server.")
	local modules = net.ReadTable()
	for _, m in SortedPairs( modules )do
		for k,v in pairs( m )do
			NRP.QueModule( k, v )
		end
		NRP.LoadQue()
	end
	
	hook.Remove("HUDPaint","NRP_Pending")
	timer.Remove("UpdateLoadStr")
end)

surface.CreateFont( "NRP_Loading",{
	font      = "coolvetica",
	size      = 120,
	weight    = 1000
})
local loadstr = ''
timer.Create("UpdateLoadStr",0.5,0,function()
	loadstr = loadstr .. '.'
	if( string.len( loadstr ) > 3 )then
		loadstr = ''
	end
end)
hook.Add("HUDPaint","NRP_Pending",function()
	surface.SetDrawColor( Color( 155, 155, 155 ) )
	surface.DrawRect( 0, 0, ScrW(), ScrH() )
	draw.SimpleText("NeoRP Loading"..loadstr , "NRP_Loading", ScrW() / 2, ScrH() / 2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	return true
end)

net.Receive("NeoRP_ReloadTrig",function()
	RunString([[
	include(GAMEMODE.FolderName.."/gamemode/loader_sh.lua")
	include(GAMEMODE.FolderName.."/gamemode/loader_cl.lua")
	]])
end)