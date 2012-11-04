local ModuleHooks = {}

-- we override the default hook call system to give us controle first.
-- this means module hooks will always be called FIRST before everything else.
if( not HOOKCALL_OVERRIDEN )then
	local oldCall = hook.Call
	hook.Call = function( name, gmode, ... )
		local arg = {...}
		local res = {MORP:CallModuleHook( name, ... )}
		if( #res == 0 )then
			return oldCall( name, gmode, ... )
		else
			return unpack( res )
		end
	end
end
HOOKCALL_OVERRIDEN = true


function MORP:CallModuleHook( name, ... )
	if( not ModuleHooks[ name ] )then return end
	local res
	for k,v in SortedPairs( ModuleHooks[ name ] )do
		res = {v(...)}
		if( #res ~= 0 )then	return unpack( res  ) end
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
	local code = string.format('%s\n%s\n%s\n',
		'local GM = {}',codestr, 'return GM' )
	local func = CompileString( code, id )
	if( not func )then
		MsgCTBL(MORP.color.red, "Failed to compile module "..id )
		return false
	end
	local res = func()
	for k,v in pairs( res )do
		if( type( v ) == 'function' )then
			if( not ModuleHooks[ k ] )then ModuleHooks[ k ] = {} end
			table.insert( ModuleHooks[ k ], v )
		end
	end
end

local que = {}
local function QueModule( req, path, name, code )
	MsgCTBL(MORP.color.grey,"Added module "..name.." to que.")
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
					if( table.HasValue( req, j ) )then
						RequiredNum = RequiredNum - 1
					end
				end
			else
				if( not req or RequiredNum == 0)then
					MsgCTBL(MORP.color.white,"Running module "..v[3] )
					RunModule( v[2], v[4] )
					table.insert(loaded, v[3] )
					que[k] = nil
				end
			end
		end
	end
	if( #que == 0 )then
		MsgCTBL(MORP.color.cyan,"Done loading modules!!!")
	else
		ErrorNoHalt("REQUIREMENT ERROR. FAILED TO LOAD SOME MODULES. FORCING LOAD WITHOUT REQUIREMENTS.")
		for k,v in pairs( que )do
			RunModule( v[2], v[4] )
		end
	end
end

local function LoadModule( path )
	-- read the module from the file...
	local text = file.Read(path, "LUA" )
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
	MsgCTBL( MORP.color.white, "Loading module "..name,
			"\n\t\tDescription: ", desc,
			"\n\t\tAuthor: ", author,
			"\n\t\tInstance: ", instance)
	else
		MsgCTBL( MORP.color.orange, "Skipping "..instance.. " module ".. name )
	end
	if(instance == 'CLIENT' or instance == 'SHARED' )then
		MsgCTBL( MORP.color.grey, "Adding "..name.." as a clientside file.")
	end
	
	-- load the requirement list.
	local ReqStr = (ParseForProperty( header, 'require' ))
	if( ReqStr )then
		ReqStr = string.gsub( ReqStr, ' ', '' )
		local req = string.Explode(',', ReqStr )
		MsgCTBL(MORP.color.grey,"Requires "..table.concat( req, ", ") )
	end
	-- run the module.
	if( instance == 'SERVER' and SERVER)then
		QueModule( req, path, name, code )
	elseif( instance == 'CLIENT' )then
		if(CLIENT)then
			QueModule( req, path, name, code )
		else
			AddCSLuaFile( path )
		end
	elseif( instance == 'SHARED' )then 
		QueModule(req, path, name, code )
		if(SERVER)then
			AddCSLuaFile( path )
		end
	else
		ErrorNoHalt("Invalid instance specified "..instance.." Path: "..path )
	end
end

local function ScanForModules( moduleFolder )
	MsgCTBL(MORP.color.white,[[
	========================
	= Scanning for Modules =
	========================]])
	local files, _ = file.Find(moduleFolder .. "*.lua", "LUA")
	for k,v in pairs(files) do
		print("Found module "..v)
		local curPath = moduleFolder..v
		LoadModule( curPath )
	end
end
ScanForModules( GM.FolderName.."/gamemode/modules/" )
if(SERVER)then
	ScanForModules( GM.FolderName.."/gamemode/modules/server/" )
end
ScanForModules( GM.FolderName.."/gamemode/modules/client/" )
ScanForModules( GM.FolderName.."/gamemode/modules/shared/" )

ProcessQue() -- now that we have our list, run them.