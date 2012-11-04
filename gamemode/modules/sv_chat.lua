--[[
<info>
<name>chat</name>
<author>TheLastPenguin</author>
<desc>Server side chat system.</desc>
<instance>SHARED</instance>
<require>notice</require>
</info>
]]

-- NOTE GM here is NOT the same table as it is in the other gamemode files, it is a LOCAL table.
-- the functions placed here will be called as gamemode hooks with high priority through some magic
-- in the module_loader.lua file.
print("HI!")


function GM:PlayerSay( ply, text, public)
	print("SOMEONE CHATED!")
end