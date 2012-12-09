local NRP = NRP
if( not GAMEMODE and GM )then GAMEMODE = GM end -- make sure we have the tables we need.

/*===================================
MODULE HEADER PARSER
===================================*/
NRP.LoadMessageBig("Loading Module Parsing Systems.")

local function ParseNextElement( str, index)
	if( not index )then index = 1 end
	if( not str )then return end
	local str = string.sub( str, index )
	-- parse out the key part.
	local bracket = string.find( str, '<' )
	local closeBracket = string.find( str, '>' )
	-- if we didnt find the opening or the close bracket we return nil.
	if( not ( bracket and closeBracket ) )then return nil end
	local elementDec = string.sub( str, bracket + 1, closeBracket - 1 ) -- now we actually have the key.
	
	-- lets do some work with the element declaration.
	local key = nil
	local flags = {}
	local decSpace = string.find( elementDec, ' ' )
	if( decSpace )then
		key = string.sub( elementDec, 1, decSpace - 1 )
		local props = string.sub( elementDec, 1, decSpace + 1 )
		-- parse out those properties.
		local propStrs = string.Explode( ' ', elementDec )
		for k,v in pairs( propStrs )do
			if( not (string.len( v ) == 0))then
				local equalsSign = string.find( v, '=' )
				if( equalsSign )then
					flags[ string.sub( v, 1, equalsSign - 1 ) ] = string.sub( v, equalsSign + 1 )
					--print("Flag '"..string.sub( v, 1, equalsSign - 1 ).."' = '"..string.sub( v, equalsSign + 1 ).."'")
				end
			end
		end
	else
		key = elementDec
	end
	local elementEndStr = '</'..key..'>'
	local elementEnd = string.find( str, elementEndStr )
	if( not elementEnd )then
		NRP.LoadMessage(NRP.color.red,"UNCLOSED ELEMENT.")
		return false
	end
	local value = string.sub( str, closeBracket + 1, elementEnd - 1 )
	return { ['key'] = key, ['value'] = value, ['flags'] = flags }, index + elementEnd + string.len( elementEndStr )
end

NRP.LocateXML = function( str )
	local s = string.find( str, "<xml>")
	local e = string.find( str, "</xml>")
	if( s and e )then
		return string.sub( str, s + 5, e - 1 )
	else
		return nil
	end
end

NRP.ParseXML = function( str )
	local elements = {}
	local ind = 1
	local limit = 100
	while( true and limit > 0 )do
		limit = limit - 1
		local r, newInd = ParseNextElement( str, ind )
		ind = newInd
		if( r )then
			table.insert(elements, r )
		elseif( r == false )then
			return
		else
			break
		end
	end
	return elements
end

/*==================================
 MODULE HOOK SYSTEM.
==================================*/
mhook = {}
local hooks = {}
local overrideHooks = {}
function mhook.Call( name, ... )
	if( overrideHooks[ name ] )then
		for k,v in SortedPairs( overrideHooks[ name ] )do
			local a, b, c, d =  v( GAMEMODE, ...)
			if( a ~= nil )then return a, b, c, d end
		end
	end
	
	if( not hooks[ name ] )then return end
	for k,v in SortedPairs( hooks[ name ] )do
		local a, b, c, d = v( GAMEMODE, ...)
		if( a ~= nil )then return a, b, c, d end
	end
	return nil
end

function mhook.Add( type, func ) -- not like normal hook.Add. Hooks are called first come, first serve. They can not be removed once added.
	if( not hooks[ type ] )then hooks[ type ] = {} end
	table.insert( hooks[ type ], func )
end

function mhook.AddOverride( type, func ) -- not like normal hook.Add. Hooks are called first come, first serve. They can not be removed once added.
	if( not overrideHooks[ type ] )then overrideHooks[ type ] = {} end
	table.insert( overrideHooks[ type ], func )
end

-- insert function override into the gamemode table.
function mhook.Compile( type )
	GAMEMODE[ type ] = function( GAMEMODE, ... )
		local a, b, c, d = mhook.Call( type, ... )
		if( a )then
			return a, b, c, d
		elseif( hooks[ type ] == nil and overrideHooks[ type ] == nil)then
			if( GAMEMODE.BaseClass[ type ] )then
				return GAMEMODE.BaseClass[ type ]( GAMEMODE,  ... )
			end
		end
	end
end

/*=================================
LOADING MODULES
=================================*/
local que = {}

NRP.QueModule = function( path, settings )
	que[ settings.name ] = { p = path, s = settings }
end

local function QueHasModule( name )
	return que[ name ] or false
end

local loaded = {}
NRP.LoadQue = function( )
	NRP.LoadMessageBig("PROCESSING MODULE QUE.")
	--PrintTable( que )
	
	-- remove requirements for nonexistant modules.
	NRP.LoadMessageBig("Checking requirements.")
	for k,v in pairs( que )do
		if( v.s.require )then
			for _, r in pairs( v.s.require )do
				if( SERVER and string.find( r, 'cl_' ) )then
					NRP.LoadMessage(NRP.color.white,'     MODULE '..k..' Removed cl require on server '..r..'.' )
					v.s.require[ _ ] = nil
				elseif( CLIENT and string.find( r, 'sv_' ) )then
					NRP.LoadMessage(NRP.color.white,'     MODULE '..k..' Removed sv require on client '..r..'.' )
					v.s.require[ _ ] = nil
				elseif( not QueHasModule( r ) and not table.HasValue( loaded, r ) )then
					NRP.LoadMessage(NRP.color.red,'     MODULE '.. k..' Removed requirement '..r..' INVALID.' )
					v.s.require[ _ ] = nil
				else
					NRP.LoadMessage(NRP.color.grey,'     module '..k..' requires '..r..'.' )
				end
			end
		end
	end
	
	NRP.LoadMessageBig("Running modules.")
	local cycles = 0
	while( table.Count( que ) > 0 )do
		cycles = cycles + 1
		NRP.LoadMessage(NRP.color.yellow,"Load cycle "..cycles )
		local queLen = table.Count( que )
		for k,v in pairs( que )do
			local req = v.s.require
			if( not req )then
				table.insert( loaded, k )
				NRP.LoadMessage(NRP.color.white, '     '..( #loaded + 1 ).. ') loaded module '..k )
				NRP.RunModule( v.p, v.s )
				que[ k ] = nil
			else
				local run = true
				for l,j in pairs( req )do
					-- we check if the module is loaded and that it exists.
					-- if it hasnt loaded, and is pending load we break out.
					if( not table.HasValue( loaded, j ) )then
						run = false
						break
					end
				end
				if( run )then
					table.insert( loaded, k )
					NRP.LoadMessage(NRP.color.white, '     '..( #loaded + 1 ).. ') loaded module '..k )
					NRP.RunModule( v.p, v.s )
					que[ k ] = nil
				end
			end
		end
		if( queLen == table.Count( que ) )then
			break -- if no new modules have been loaded, the loop will not progress so we need to break out.
		end
	end
	if( table.Count( que ) > 0 )then
		for k,v in pairs( que )do
			NRP.LoadMessage(NRP.color.red, '     '..( #loaded + 1 ).. ') FORCING LOAD WITHOUT REQUIREMENTS ON '..k )
			NRP:RunModule( v.p, v.s )
		end
	end
	
	NRP.LoadMessageBig(NRP.color.white,"COMPILEING MODULE HOOKS TO GAMEMODE TABLE.")
	local all = {}
	for k,v in pairs( hooks )do
		all[ k ] = true
	end
	for k,v in pairs( overrideHooks )do
		all[ k ] = true
	end
	for k,v in pairs( all )do
		NRP.LoadMessage(NRP.color.white,"     Compiled hook: "..k)
		mhook.Compile( k )
	end
	
	que = {}
end

NRP.RunModule = function( path, moduleTBL)
	NRP.LoadMessage(NRP.color.white,'          Loading '..path )
	local oldGM = GM
	GM = {}
	local status, error = pcall( include, path )
	if( status == false )then
		NRP:MsgC(NRP.color.red, "Failed to load module "..path )
		NRP:MsgC(NRP.color.yellow, "ERROR: "..error )
		return false
	end
	local result = GM
	GM = oldGM
	
	for k,v in pairs( result )do
		if( type( v ) == 'function' )then
			NRP.LoadMessage(NRP.color.gray,'Added module hook '..k )
			mhook.Add( k, v )
		end
	end
end

