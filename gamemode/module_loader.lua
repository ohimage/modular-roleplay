/*
NOTE TO SELF:
Will have to recode this system to stream a list of modules to users.
Also need to figure out the issue with player teams not setting properly on spawn.
*/

local NRP = NRP

if( not GAMEMODE and GM )then GAMEMODE = GM end

local moduleHooks = {}
function NRP.ModuleHooksTbl()
	return moduleHooks
end

-- we override the default hook call system to give us controle first.
-- this means module hooks will always be called FIRST before everything else.

function NRP:CallModuleHook( name, ... )
	if( not moduleHooks[ name ] )then return end
	
	for k,v in SortedPairs( moduleHooks[ name ] )do
		local a, b, c, d = v( GAMEMODE, ...)
		if( a ~= nil )then return a, b, c, d end
	end
	return nil
end

local function ParseForProperty( text, property )
	local len = string.len( property )
	lowText = string.lower( text )
	propety = string.lower( property )
	local propBegin = string.find( lowText, '<'..property..'>')
	local propEnd = string.find( lowText, '</'..property..'>')
	if( not propBegin or not propEnd )then
		return nil
	end
	propBegin, propEnd = propBegin + len + 2, propEnd - 1
	local value = string.sub( text, propBegin, propEnd )
	return value
end
local function RunModule( id, codestr )
	local OldGM = GM
	GM = {}
	include( id )
	local res = GM
	GM = OldGM
	
	for k,v in pairs( res )do
		if( type( v ) == 'function' )then
			GAMEMODE[ k ] = function( GAMEMODE, ... )
				local a, b, c, d = NRP:CallModuleHook( k, ... )
				if( a )then
					return a, b, c, d
				elseif( moduleHooks[ k ] == nil)then
					if( GAMEMODE.BaseClass[ k ] )then
						return GAMEMODE.BaseClass[ k ]( GAMEMODE,  ... )
					end
				end
			end
			if( not moduleHooks[ k ] )then moduleHooks[ k ] = {} end
			table.insert( moduleHooks[ k ], v )
		end
	end
end

local que = {}
local function QueModule( req, path, name, code )
	MsgCTBL(NRP.color.grey,"Added module "..name.." to que.")
	table.insert( que, { req, path, name, code })
end
local function ProcessQue()
	local loaded = {}
	local lastQC = -1
	local CYCLES = 0
	
	while(CYCLES < 20 and #que ~= 0 and lastQC ~= #que)do
		CYCLES = CYCLES + 1 -- this shouldnt ever happen really, but if it does, we should have a backup rather than just getting stuck in a loop.
		lastQC = #que
		for k,v in pairs( que )do
			local req = v[1]
			local RequiredNum = 0
			if( req )then
				RequiredNum = #req
				for _,j in pairs( req )do
					if( table.HasValue( loaded, j ) )then
						RequiredNum = RequiredNum - 1
					end
				end
			end
			if( not req or RequiredNum == 0)then
				MsgCTBL(NRP.color.white,#loaded + 1,") Running module "..v[3] )
				RunModule( v[2], v[4] )
				table.insert(loaded, v[3] )
				que[k] = nil
			end
		end
	end
	if( table.Count( que ) == 0 )then
		NRP:LoadMessage('Done processing module que.')
	else
		MsgCTBL(NRP.color.red,"REQUIREMENT ERROR. FAILED TO LOAD SOME MODULES. FORCING LOAD WITHOUT REQUIREMENTS.\n")
		for k,v in pairs( que )do
			MsgCTBL(NRP.color.orange,"FORCING MODULE LOAD "..v[3])
			RunModule( v[2], v[4] )
		end
	end
	NRP:LoadMessage('Loaded ', tostring( #loaded + #que ), ' modules.' )
	que = {}
end

local function LoadModule( path, relativePath )
	-- read the module from the file...
	local text = file.Read(path, "LUA" )
	if(not text )then
		ErrorNoHalt( "NO CODE IN "..path )
		return
	end
	-- find the header inside the info tags.
	local headerBegin = string.find( text, '<info>')
	local headerClose = string.find( text, '</info>')
	if( not headerBegin )then
		ErrorNoHalt("Did not find module header in file "..path)
		return false
	end
	if( not headerClose )then
		ErrorNoHalt("Reached EOF before end of module definition found." .. path)
		return false
	end
	headerBegin, headerClose = headerBegin + 6, headerClose - 1
	
	-- parse out the header and code parts of the module.
	local header = string.sub( text, headerBegin, headerClose ) -- seperate off the header from the rest of the code.
	local code = text
	
	-- find the instance ( SERVER, CLIENT, or SHARED )
	local instance = ParseForProperty( header, 'instance' )
	if( not instance )then
		ErrorNoHalt("Module failed to specify server instance. "..path )
		return false
	end
	instance = string.upper( instance )
	
	-- show load messages
	local name = (ParseForProperty(header, 'name' ))
	if( not name )then ErrorNoHalt("ERROR "..path.." NO NAME.")
		return end
	local desc = (ParseForProperty(header, 'desc' ) or "[desc not found]")
	local author = (ParseForProperty( header, 'author' ) or '[author not found]')
	
	if( instance == 'SHARED' or ( instance == 'CLIENT' and CLIENT ) or ( instance == 'SERVER' and SERVER ) )then
	MsgCTBL( NRP.color.white, "Loading module "..name,
			"\n\t\tDescription: ", desc,
			"\n\t\tAuthor: ", author,
			"\n\t\tInstance: ", instance)
	else
		MsgCTBL( NRP.color.orange, "Skipping "..instance.. " module ".. name )
	end
	if(instance == 'CLIENT' or instance == 'SHARED' )then
		MsgCTBL( NRP.color.grey, "Adding "..name.." as a clientside file.")
	end
	
	-- load the requirement list.
	local ReqStr = (ParseForProperty( header, 'require' ))
	local req = nil
	if( ReqStr )then
		ReqStr = string.gsub( ReqStr, ' ', '' )
		local rawReq = string.Explode(',', ReqStr )
		req = {}
		for k,v in pairs( rawReq )do
			if( CLIENT and string.find( v, 'sv_' ) )then
				MsgCTBL(NRP.color.grey,"Skipping sv requirement on client")
			elseif( SERVER and string.find( v, 'cl_' ) )then
				MsgCTBL(NRP.color.grey,"Skipping cl requirement on server")
			else
				table.insert( req, v )
			end
		end
		MsgCTBL(NRP.color.grey,"Requires "..table.concat( req, ", ") )
	end
	-- run the module.
	if( instance == 'SERVER' and SERVER)then
		QueModule( req, path, name, code )
	elseif( instance == 'CLIENT' )then
		if(CLIENT)then
			QueModule( req, path, name, code )
		else
			MsgCTBL(NRP.color.grey,'Added CS Lua File '..relativePath )
			AddCSLuaFile( relativePath )
		end
	elseif( instance == 'SHARED' )then 
		QueModule(req, path, name, code )
		if(SERVER)then
				MsgCTBL(NRP.color.grey,'Added CS Lua File '..relativePath )
				AddCSLuaFile( relativePath )
		end
	else
		ErrorNoHalt("Invalid instance specified "..instance.." Path: "..path )
	end
end

local function ScanForModules( moduleFolder, relativeFolder )
	local files, _ = file.Find(moduleFolder .. "*.lua", "LUA")
	for k,v in pairs(files) do
		print("Found module "..v)
		local curPath = moduleFolder..v
		local relativePath = relativeFolder..v
		LoadModule( curPath, relativePath )
	end
end

local function LoadProcess()
	NRP:LoadMessageBig('NRP Scanning for CORE Modules.')

	ScanForModules( GAMEMODE.FolderName.."/gamemode/core_modules/", "core_modules/")
	NRP:LoadMessage('Processing CORE Module Que')
	ProcessQue() -- now that we have our list, run them.
	NRP:LoadMessageBig('NRP Scanning for REGULAR Modules')
	ScanForModules( GAMEMODE.FolderName.."/gamemode/modules/" , "modules/")
	NRP:LoadMessage('Processing REGULAR Module Que')
	ProcessQue()
	hook.Run('ModulesLoaded')
end

if(SERVER)then
	util.AddNetworkString('NRP_ReloadModules')
	concommand.Add("NRP_ReloadModules_SV",function()
		NRP:LoadMessageBig(NRP.color.cyan,'NRP Reloading Modules.')
		include(GAMEMODE.FolderName..'/gamemode/module_loader.lua')
		for k,v in pairs(player.GetAll())do
			NRP:LoadMessage("Calling load hooks on player "..v:Name() )
			v:SendLua([[
print("Reloading NRP.")
NRP:LoadMessageBig(NRP.color.cyan,'NRP Reloading Modules.')
include(GAMEMODE.FolderName..'/gamemode/module_loader.lua')
			]])
			hook.Call('PlayerInitialSpawn',GAMEMODE,v)
			v:StripWeapons()
			hook.Call('PlayerLoadout',GAMEMODE,v)
		end
	end)
end

LoadProcess()
PrintTable( moduleHooks )