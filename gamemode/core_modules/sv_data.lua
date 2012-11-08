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

function DBI:Init()
	local tables = {
		"prefix_users ( uid INT NOT NULL )"
	}
	-- use table.insert( tables, your table shit ) to add a table. DO NOT USE A RETURN VALUE.
	hook.Call('MoRP_RegisterDatabases', tables)
	sql.Begin()
		for k,v in pairs( tables )do
			DBI:Query( string.format('CREATE TABLE IF NOT EXISTS %s', v ) )
		end
	sql.Commit()
	print("UID FIELD")
	PrintTable({DBI:Query('SELECT uid FROM prefix_users')})
	print("SOME OTHER RANDOM FIELD.")
	PrintTable({DBI:Query('SELECT shit FROM prefix_users')})
end
function GM:ModulesLoaded()
	MORP:LoadMessageBig("Initalising Database Tables.")
	DBI:Init()
end