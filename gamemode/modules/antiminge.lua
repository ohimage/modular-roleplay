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

hook.Add("PlayerGiveSWEP","NO SWEPS",function( ply, class, wep )
	NRP.Notice( ply, 6, "ERROR: You do not have permission to spawn weapons.", NOTIFY_ERROR)
	if( NRP.cfg.CanGiveSWEP )then
		return NRP.cfg.CanGiveSWEP( ply )
	else
		return ply:IsSuperAdmin()
	end
end)

hook.Add("PlayerSpawnSENT","NO SENTS",function( ply, class, wep )
	NRP.Notice( ply, 6, "ERROR: You do not have permission to spawn weapons.", NOTIFY_ERROR)
	if( NRP.cfg.CanSpawnSENT )then
		return NRP.cfg.CanSpawnSENT( ply )
	else
		return ply:IsSuperAdmin()
	end
end)

hook.Add("PlayerSpawnNPC","NO NPCS",function( ply, class, wep )
	NRP.Notice( ply, 6, "ERROR: You do not have permission to spawn weapons.", NOTIFY_ERROR)
	if( NRP.cfg.CanSpawnNPC )then
		return NRP.cfg.CanSpawnNPC( ply )
	else
		return ply:IsSuperAdmin()
	end
end)

function GM:GravGunPunt( ply )
	return false
end

function GM:PlayerSpawnSWEP( ply, class, wep )
	print("Player tried to spawn a weapon.")
	ply:ChatPrint("This functionality is diabled.")
	return false;
end