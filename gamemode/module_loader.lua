local function ScanForModules( moduleFolder )
	local files, folders = file.Find(moduleFolder .. "*", "LUA")
	for k,v in pairs(files) do
		print("Found module "..v)
		local curPath = moduleFolder..v
		file.Read(moduleFolder, "LUA" )
	end
end

ScanForModules( GM.FolderName.."/gamemode/modules/" )