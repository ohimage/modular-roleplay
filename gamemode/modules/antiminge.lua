--[[
<xml>
	<module>
		<name>sv_antiminge</name>
		<author>TheLastPenguin</author>
		<desc>Stop all those mean propkillers</desc>
		<instance>SERVER</instance>
	</module>
</xml>
]]

function GM:EntityTakeDamage( target, dmginfo )
	local dmgtype = dmginfo:GetDamageType()
	local attacker = dmginfo:GetAttacker()
	if ( target:IsPlayer() ) then
		if( dmgtype == DMG_CRUSH or ( IsValid( dmginfo:GetAttacker() ) and dmginfo:GetAttacker():GetClass() == 'prop_physics' ) )then
			if( attacker.owner and not attacker.Owner )then attacker.Owner = attacker.owner end -- someone might have it lowercase...
			if( IsValid( attacker ) and attacker.Owner ~= nil )then
				local killer = attacker.Owner
				killer:SendLua("chat.AddText(Color(255,0,0),'Dont prop kill please.')")
				killer:TakeDamage( dmginfo:GetDamage() )
			end
			dmginfo:SetDamage( 0 )
		end
	end
end
function GM:CanDrive( ply, ent ) -- disable prop driving.
    if ( not ply:IsSuperAdmin() ) then
		ply:ChatPrint("You must be a superadmin to do this!")
		return false end
end

function GM:CanProperty( ply, ent )
	if( not ply:IsSuperAdmin() )then
		ply:ChatPrint("You must be a superadmin to do this!")
		return false
	end
end

function GM:PlayerSpawnSWEP( ply, class, wep )
	print("Player tried to spawn a weapon.")
	ply:ChatPrint("This functionality is diabled.")
	return false;
end