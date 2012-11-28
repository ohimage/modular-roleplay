local NRP = NRP
if( not GAMEMODE and GM )then GAMEMODE = GM end -- make sure we have the tables we need.

print("Loaded CL Loader")

/*=================================
LOADING MODULES
=================================*/
net.Receive("NeoRP_ModuleList",function()
	NRP:LoadMessageBig("Recieving MODULE Table from server.")
	local modules = net.ReadTable()
	for _, m in SortedPairs( modules )do
		for k,v in pairs( m )do
			NRP:QueModule( k, v )
		end
	end
	NRP:LoadQue()
end)

net.Receive("NeoRP_ReloadTrig",function()
	include(GAMEMODE.FolderName.."/gamemode/loader_sh.lua")
	include(GAMEMODE.FolderName.."/gamemode/loader_cl.lua")
end)