--[[
<info>
<name>chat</name>
<author>TheLastPenguin</author>
<desc>Server side chat system.</desc>
<instance>SERVER</instance>
<require>notice</require>
</info>
]]

-- NOTE GM here is NOT the same table as it is in the other gamemode files, it is a LOCAL table.
-- the functions placed here will be called as gamemode hooks with high priority through some magic
-- in the module_loader.lua file.

local chatCommands = {}

function MORP:AddChatCommand( cmd, func )
	chatCommands[ cmd ] = func
end

-- adding a basic chat command.
local OCC = function( ply, text )
	if( text )then
		MORP:ChatMessage(player.GetAll(), team.GetColor( ply:Team() ), '(OCC) '..ply:Name(), MORP.color.white, ": "..text )
	end
end
MORP:AddChatCommand( '/', OCC )
MORP:AddChatCommand( 'ooc', OCC )
MORP:AddChatCommand( 'oc', OCC )

local function RunCommand(ply, text )
	local cmd = nil
	local arg = nil
	local space = string.find( text, ' ' )
	if( not space )then
		cmd = text
	else
		cmd = string.sub( text, 1, space - 1 )
		arg = string.sub( text, space + 1 )
	end
	cmd = string.lower( cmd )
	if( chatCommands[ cmd ] == nil )then
		MORP:ChatMessage( ply, MORP.color.red, "Command '"..cmd.."' not found.")
	else
		if( table.HasValue( MORP.cfg.BlockedCommands, cmd ))then
			MORP:ChatMessage( ply, MORP.color.orange, "COmmand '"..cmd.."' disabled. Contact server staff if you feel this is an error.")
		end
		return chatCommands[ cmd ]( ply, arg )
	end
end

function GM:PlayerSay( ply, text, teamChat )
	if( not (string.len( text ) > 3) )then
		MORP:ChatMessage( ply, MORP.color.red, "Message must be more than 3 letters long.")
	end
	if( text[1] == '/')then
		return RunCommand( ply, string.sub( text, 2 ) ) or ''
	else
		local players = player.GetAll()
		MORP:ChatMessage(players, team.GetColor( ply:Team() ),ply:Name(), MORP.color.white, ": "..text )
	end
	return ""
end