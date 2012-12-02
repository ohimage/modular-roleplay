local NRP = NRP
if( not GAMEMODE and GM )then GAMEMODE = GM end -- make sure we have the tables we need.

local clModules = {}
local clCurModules = {}
local function AddClientModule( path, tbl )
	AddCSLuaFile( path )
	clCurModules[ path ] = table.Copy( tbl )
end
local function NewCLModuleSet( )
	table.insert( clModules, clCurModules )
	clCurModules = {}
end

util.AddNetworkString("NeoRP_ModuleList")
local function SendModuleList( ply )
	timer.Simple( 1, function()
		NRP:LoadMessageBig("Sending module list to "..ply:Name())
		net.Start("NeoRP_ModuleList")
			net.WriteTable( clModules )
		net.Send( ply )
	end)
end
hook.Add("PlayerInitialSpawn","NeoRP_Modules", SendModuleList )

function NRP:LoadModule( path )
	-- read the module from the file...
	local text = file.Read(path, "LUA" )
	if( not text )then
		NRP:LoadErrorMessage('NO FILE AT '..path )
		return false
	end
	
	-- find the header.
	local XML = NRP:LocateXML( text )
	if( not XML )then
		NRP:LoadErrorMessage('XML File header zone not found.')
		return false
	end
	
	-- parse the file for module.
	local module = NRP:ParseXML( XML )[1]
	local settings = {}
	
	-- get a list of module flags and stick em in settings table.
	if( module.flags )then
		for k,v in pairs( module.flags )do
			settings[ k ] = v
		end
	end
	
	-- data sanity check.
	if( not module.value )then
		NRP:LoadErrorMessage('XML header missing <module> </module> element.')
		return
	end
	
	-- parse module's contents for additional settings.
	local elements = NRP:ParseXML( module.value )
	for k,v in pairs( elements )do
		settings[ v.key ] = v.value
	end
	
	-- PRINT SETTINGS.
	for k,v in pairs( settings )do
		NRP:LoadMessage(NRP.color.grey,"          "..k.." = '"..v.."'" )
	end
	
	if( settings['require'] ~= nil )then
		settings['require'] = string.Explode(',',settings['require'] )
	end
	
	if( not settings['instance'] )then
		NRP:LoadErrorMessage('MODULE INSTANCE NOT SPECIFIED.')
		return
	end
	
	if( settings['instance' ] == 'SHARED' )then
		AddClientModule( path, settings )
		NRP:QueModule( path, settings )
	elseif( settings['instance'] == 'CLIENT' )then
		AddClientModule( path, settings )
	elseif( settings['instance'] == 'SERVER' )then
		NRP:QueModule( path, settings )
	else
		NRP:LoadErrorMessage('ERROR. INVALID INSTANCE TYPE '.. settings['instance'] )
	end
end

function NRP:FindModules( dir )
	NRP:LoadMessageBig(NRP.color.white,"Scanning Directory "..dir )
	local files, _dirs = file.Find(dir .. "*.lua", "LUA")
	local n = 1
	for k,v in pairs(files) do
		NRP:LoadMessage(NRP.color.white,"     "..n..") Found module "..v )
		n = n + 1
		local path = dir..v
		NRP:LoadModule( path )
	end
	NewCLModuleSet()
	NRP:LoadQue()
end

NRP:LoadMessageBig(NRP.color.white,"LOADING MODULES.")
NRP:FindModules( GAMEMODE.FolderName.."/gamemode/vgui/" )
NRP:FindModules( GAMEMODE.FolderName.."/gamemode/core_modules/" )
NRP:FindModules( GAMEMODE.FolderName.."/gamemode/modules/" )

util.AddNetworkString("NeoRP_ReloadTrig")
concommand.Add('NRP_Reload',function( ply )
	if( not IsValid( ply ) or ply:IsListenServerHost() )then
		include(GAMEMODE.FolderName.."/gamemode/loader_sh.lua")
		include(GAMEMODE.FolderName.."/gamemode/loader_sv.lua")
		net.Start("NeoRP_ReloadTrig")
		net.Send( player.GetAll() )
		for k,v in pairs( player.GetAll() )do
			hook.Call('PlayerInitialSpawn', GAMEMODE, v )
		end
	end
end)