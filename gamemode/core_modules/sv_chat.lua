--[[
<info>
<name>sv_chat</name>
<author>TheLastPenguin</author>
<desc>Server side chat system.</desc>
<instance>SERVER</instance>
<require>sh_notice</require>
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


-- we make a global table for this, so reloads wont remove all hooks forever and ever and ever... echo...
local otherhooks = MORP_CHATCMDSREPLACED or {}
MORP_CHATCMDSREPLACED = otherhooks

function GM:OnPlayerChat(ply, text, teamonly, dead)
	text = string.Trim( text )
	/*-- call the other hooks like a baws.
	for k,v in SortedPairs( otherhooks, false )do
		if type(v) == "function" then
			local newText = v(ply, text, teamonly, dead)
			if( newText )then
				text = newText
				break
			end
		end
	end
	*/
	
	if( string.len( text ) == 0 )then
		--MORP:ChatMessage( ply, MORP.color.red, "Message must be more than 3 letters long.")
	elseif( text[1] == '/')then
		return RunCommand( ply, string.sub( text, 2 ) ) or ''
	else
		local players = player.GetAll()
		MORP:ChatMessage(players, team.GetColor( ply:Team() ),ply:Name(), MORP.color.white, ": "..text )
	end
	return ""
end

/*
local function ReplaceChatHooks()
	if not hook.GetTable()['PlayerSay'] then return end
	for k,v in pairs(hook.GetTable()['PlayerSay']) do
		print("Removin hook "..k)
		otherhooks[k] = v
		hook.Remove("PlayerSay", k)
	end
	PrintTable(hook.GetTable().PlayerSay)
	for a,b in pairs(otherhooks) do
		if type(b) ~= "function" then
			otherhooks[a] = nil
		end
	end
end

timer.Simple(1, ReplaceChatHooks)
*/