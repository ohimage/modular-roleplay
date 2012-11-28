local NRP = NRP
if( not GAMEMODE and GM )then GAMEMODE = GM end -- make sure we have the tables we need.

print("Loaded CL Loader")

/*=================================
LOADING MODULES
=================================*/
net.Receive("NeoRP_ModuleList",function()
	NRP:LoadMessageBig("Recieving MODULE Table from server.")
	local modules = net.ReadTable()
	for k,v in pairs( modules )do
		NRP:QueModule( k, v )
	end
	NRP:LoadQue()
end)
