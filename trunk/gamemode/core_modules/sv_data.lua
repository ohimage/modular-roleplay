--[[
<info>
<name>sv_data</name>
<author>TheLastPenguin</author>
<desc>Server Side data system.</desc>
<instance>SERVER</instance>
</info>
]]
MORP:LoadMessageBig("Loading Data Manager.")
local TablePrefix = MORP.cfg.TablePrefix
MORP:LoadMessage("Table Prefix is "..TablePrefix )

MORP.DBI = {}
local DBI = MORP.DBI
function DBI:Query( str )
	query = string.gsub( str, 'prefix_', TablePrefix )
	local a, b, c = sql.Query( query )
	return a, b, c
end

local userProperties = {}
function DBI:AddUserProperty( name, type, default )
	MORP:LoadMessage( "Registerd user data property "..name)
	local newProp = {
		['column'] = name,
		['type'] = type,
		['default'] = default
	}
	table.insert( userProperties, newProp )
end

MORP.DBI:AddUserProperty( 'uid', 'INT UNSIGNED', function( ply ) return tostring( ply:UniqueID() ) end ) -- user id for tracking users.
MORP.DBI:AddUserProperty( 'ip', 'INT UNSIGNED', function( ply ) return tostring( ply:UniqueID() ) end ) -- user id for tracking users.
MORP.DBI:AddUserProperty( 'money', 'BIGINT UNSIGNED', MORP.cfg.StartingBalance ) -- money system.
MORP.DBI:AddUserProperty( 'custom_name', 'VARCHAR( 30 )', function( ply ) 
	if( string.len( ply:Name() ) > 0 )then
		return ply:Name()
	else
		return 'unknown'
	end
end ) -- used for custom name system.
MORP.DBI:AddUserProperty( 'lastjob', 'INT UNSIGNED', MORP. TEAM_CITIZEN or 0) -- used for restoring old jobs on disconnect.
MORP.DBI:AddUserProperty( 'karma', 'INT UNSIGNED', MORP. TEAM_CITIZEN or 0) -- used for RDM system.


function GM:PlayerInitialSpawn( ply )
	MORP:LoadMessage("Player "..ply:Name().." spawned.")
	local res = DBI:Query('SELECT * FROM prefix_users WHERE uid = '..sql.SQLStr( ply:UniqueID() ) )
	if( res )then
		
	else
		MORP:LoadMessageBig("Player "..ply:Name().." doesn't have DB entry. Creating new one.")
		local props, vals = {}, {}
		for k,v in pairs( userProperties )do
			table.insert( props, v['column'] )
			if( type( v[ 'default' ] ) == 'function' )then
				table.insert( vals, sql.SQLStr( v[ 'default' ]( ply ) ) )
			else
				table.insert( vals, sql.SQLStr( v['default'] ) )
			end
		end
		DBI:Query(string.format( "INSERT INTO prefix_users ( %s ) VALUES ( %s )", table.concat( props, ','), table.concat( vals, ',')))
		res = DBI:Query('SELECT * FROM prefix_users WHERE uid = '..sql.SQLStr( ply:UniqueID() ) )
	end
	local user = res[1]
	PrintTable( user )
end

function DBI:Init()
	local tables = {
		"prefix_users ( uid INT UNSIGNED NOT NULL )",
		"prefix_doors ( map VARCHAR( 200 ), id BIGINT NOT NULL, locked TINYINT, title VARCHAR(30), price SMALLINT )",
		"prefix_weapons ( uid INT NOT NULL, class VARCHAR( 30 ), ammo1 SMALLINT UNSIGNED, ammo2 SMALLINT UNSIGNED, expires INT)"
	}
	-- use table.insert( tables, your table shit ) to add a table. DO NOT USE A RETURN VALUE.
	hook.Call('MoRP_RegisterSQLTables', tables)
	hook.Call('MoRP_DB_AddUserProperties', userPropeties)
	sql.Begin()
		for k,v in pairs( tables )do
			DBI:Query( string.format('CREATE TABLE IF NOT EXISTS %s', v ) )
		end
	sql.Commit()
	
	for k,v in pairs( userProperties )do
		PrintTable( v )
		if( DBI:Query('SELECT '..v['column']..' FROM prefix_users') == false )then
			MORP:LoadMessage("Adding missing column "..v['column'] )
			DBI:Query( 'ALTER TABLE prefix_users ADD '.. v['column']..' '.. v['type'] )
		end
	end
end
MORP:LoadMessageBig("Initalising Database Tables.")
DBI:Init()

function GM:ModulesLoaded()
	MORP:LoadMessageBig("Checking Database Tables.")
	DBI:Init()
end