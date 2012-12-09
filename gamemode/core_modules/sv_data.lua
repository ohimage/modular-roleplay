--[[
<xml>
	<module>
		<name>sv_data</name>
		<author>TheLastPenguin</author>
		<desc>Server Side data system.</desc>
		<instance>SERVER</instance>
		<require>util</require>
	</module>
</xml>

This thing took me quite a while... so i hope to never have to look at it again.
Please dont find errors... ( if you do report them to thelastpenguin212@gmail.com. I'll hate you for it, but i will fix it.)
]]
local NRP = NRP

NRP.LoadMessageBig("Loading Data Manager.")
local TablePrefix = NRP.cfg.TablePrefix
NRP.LoadMessage("Table Prefix is "..TablePrefix )

NRP.DBI = {}
local DBI = NRP.DBI

-- Perform a query with the prefix_ replaced with the user config setting.
DBI.Query = function( str )
	query = string.gsub( str, 'prefix_', TablePrefix )
	local a, b, c = sql.Query( query )
	return a, b, c
end

local userProperties = {}

/*=======================================================================
-- add a persisting variable to to the user database.
-- thease properties will be loaded into access objects for each player.
=======================================================================*/
DBI.AddUserProperty = function( name, type, default )
	NRP.LoadMessage( "Registerd user data property "..name)
	local newProp = {
		['column'] = name,
		['type'] = type,
		['default'] = default
	}
	table.insert( userProperties, newProp )
end
/*===================================
Add properties to the user database.
===================================*/
NRP.DBI.AddUserProperty( 'uid', 'INT UNSIGNED', function( ply ) return tostring( ply:UniqueID() ) end ) -- user id for tracking users.
NRP.DBI.AddUserProperty( 'money', 'BIGINT UNSIGNED', NRP.cfg.StartingBalance ) -- money system.
NRP.DBI.AddUserProperty( 'custom_name', 'VARCHAR( 30 )', function( ply ) 
	if( string.len( ply:Name() ) > 0 )then
		return ply:Name()
	else
		return 'unknown'
	end
end ) -- used for custom name system.
/*==================================================
Stuff to do when a player spawns for the first time.
==================================================*/
local SQLDATA_INDEX = function( self, index)
		local data = rawget( self, 'data' )
		return data[ index ]
	end
local SQLDATA_NEWINDEX = function( self, key, value )
		local data = rawget( self, 'data' )
		if( not data[ key ] )then
			ErrorNoHalt("ATTEMPT TO SET NON EXISTANT SQLDB PROPERTY "..key.." to value "..value )
			return
		end
		data[ key ] = value
		print("DATAMANAGER SET "..key.." -> "..value.." for player "..self.Entity:Name() )
		DBI.Query(string.format( 'UPDATE prefix_users SET %s = %s WHERE uid = %s', key, sql.SQLStr( value ), sql.SQLStr( self.Entity:UniqueID() )))
	end
  
function GM:PlayerInitialSpawn( ply )
	NRP.LoadMessage("Player "..ply:Name().." spawned.")
	local res = DBI.Query('SELECT * FROM prefix_users WHERE uid = '..sql.SQLStr( ply:UniqueID() ) )
	if( res )then -- dont do anything if they already have a value in the database.
		
	else-- they dont have a value, so lets make one.
		res = {}
		NRP.LoadMessageBig("Player "..ply:Name().." doesn't have DB entry. Creating new one.")
		local props, vals = {}, {} -- calculate the default values for the various SQL Properties.
		for k,v in pairs( userProperties )do
			table.insert( props, v['column'] )
			if( type( v[ 'default' ] ) == 'function' )then
				local defaultVal = v[ 'default' ]( ply ) 
				res[ v['column'] ] = defaultVal
				table.insert( vals, sql.SQLStr( defaultVal ) )
			else
				local defaultVal = v[ 'default' ]
				res[ v['column'] ] = defaultVal
				table.insert( vals, sql.SQLStr( defaultVal ) )
			end
		end
		DBI.Query(string.format( "INSERT INTO prefix_users ( %s ) VALUES ( %s )", table.concat( props, ','), table.concat( vals, ',')))
	end
	
	-- SQL DATA SYSTEM.
	local data = res[1]
	
	if( not data )then 
		print("FAILED TO LOAD USER "..ply:Name() )
		return end
	-- if the data looks like a number... it probably is one... so make it one.
	for k,v in pairs( data )do
		if( string.match( v, '[0-9]*') == v )then
			data[ k ] = tonumber( v )
		end
	end
	
	-- stick some values we need in.
	data.Entity = ply
	
	ply.SQLDATA = {}
	ply.SQLDATA.data = data
	
	ply.SQLDATA.__index = SQLDATA_INDEX
	ply.SQLDATA.__newindex = SQLDATA_NEWINDEX
	setmetatable( ply.SQLDATA, ply.SQLDATA )
	
	PrintTable( ply.SQLDATA.data )
end

/*===========================================
Initialise Database Tables and other stuff...
===========================================*/
function DBI.Init()
	-- list of default tables to check for / create if they dont exist.
	local tables = {
		"prefix_users ( uid INT UNSIGNED NOT NULL, UNIQUE (uid) )",
		"prefix_doors ( map VARCHAR( 200 ), id BIGINT NOT NULL, locked TINYINT, title VARCHAR(30), price SMALLINT )",
		"prefix_weapons ( uid INT NOT NULL, class VARCHAR( 30 ), ammo1 SMALLINT UNSIGNED, ammo2 SMALLINT UNSIGNED, expires INT)"
	}
	-- use table.insert( tables, your table shit ) to add a table. DO NOT USE A RETURN VALUE.
	hook.Call('NRP_RegisterSQLTables', tables)
	hook.Call('NRP_DB_AddUserProperties', userPropeties)
	
	-- go through the tables and make them if they dont exist.
	sql.Begin()
		for k,v in pairs( tables )do
			DBI.Query( string.format('CREATE TABLE IF NOT EXISTS %s', v ) )
		end
	sql.Commit()
	
	-- check that desired colums exist in the user properties table, and make them if they arnt found.
	for k,v in pairs( userProperties )do
		PrintTable( v )
		if( DBI.Query('SELECT '..v['column']..' FROM prefix_users') == false )then
			NRP.LoadMessage("Adding missing column "..v['column'] )
			DBI.Query( 'ALTER TABLE prefix_users ADD '.. v['column']..' '.. v['type'] )
		end
	end
end

-- we call DBI:Init twice for extra certainty mostly since some modules may be slow to catch on.
NRP.LoadMessageBig("Initalising Database Tables.")
DBI.Init()
function GM:ModulesLoaded()
	NRP:LoadMessageBig("Checking Database Tables.")
	DBI.Init()
end