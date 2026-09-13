repeat
	task.wait()
until game:IsLoaded()
if shared.vape then
	shared.vape:Uninject()
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification("Vape", "Failed to load : " .. err, 30, "alert")
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile
	or function(file)
		local suc, res = pcall(function()
			return readfile(file)
		end)
		return suc and res ~= nil and res ~= ""
	end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService("Players"))

local function downloadFile(path, func)
	if shared.VapeFileCache and type(shared.VapeFileCache.Download) == "function" then
		return shared.VapeFileCache.Download(path, func)
	end

	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet(
				"https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/"
					.. readfile("newvape/profiles/commit.txt")
					.. "/"
					.. select(1, path:gsub("newvape/", "")),
				true
			)
		end)
		if not suc or res == "404: Not Found" then
			error(res)
		end
		if path:find(".lua") then
			res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n"
				.. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function startDownload(path)
	local future = {
		Done = false,
		Event = Instance.new("BindableEvent"),
	}
	task.spawn(function()
		future.Success, future.Result = pcall(downloadFile, path)
		future.Done = true
		future.Event:Fire()
	end)
	return future
end

local function awaitDownload(future)
	while not future.Done do
		future.Event.Event:Wait()
	end
	future.Event:Destroy()
	return future.Success, future.Result
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and not shared.VapeIndependent then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				if shared.VapeDeveloper then
					loadstring(readfile('newvape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.VapeDeveloper then
				teleportScript = "shared.VapeDeveloper = true\n" .. teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\n' .. teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then
			return
		end
		if vape.Settings.GUI.Options["GUI bind indicator"].Enabled then
			vape:CreateNotification(
				"Finished Loading",
				vape.VapeButton and "Press the button in the top right to open GUI"
					or "Press " .. table.concat(vape.GUIBind.Keys, " + "):upper() .. " to open GUI",
				5
			)
		end
	end
end

if not isfile("newvape/profiles/gui.txt") then
	writefile("newvape/profiles/gui.txt", "new")
end
local gui = "new" --readfile('newvape/profiles/gui.txt')

if not isfolder("newvape/assets/" .. gui) then
	makefolder("newvape/assets/" .. gui)
end
local guiPath = "newvape/guis/" .. gui .. ".lua"
local universalPath = "newvape/games/universal.lua"
local gamePath = "newvape/games/" .. game.PlaceId .. ".lua"
local downloads = {
	[guiPath] = startDownload(guiPath),
}
if not shared.VapeIndependent then
	downloads[universalPath] = startDownload(universalPath)
	if not shared.VapeDeveloper or isfile(gamePath) then
		downloads[gamePath] = startDownload(gamePath)
	end
end

-- Network-bound files are independent. Fetch together, execute in dependency order.
local guiSuccess, guiSource = awaitDownload(downloads[guiPath])
if not guiSuccess then
	error(guiSource)
end
vape = loadstring(guiSource, "gui")()
shared.vape = vape

if not shared.VapeIndependent then
	local universalSuccess, universalSource = awaitDownload(downloads[universalPath])
	if not universalSuccess then
		error(universalSource)
	end
	loadstring(universalSource, "universal")()
	if downloads[gamePath] then
		local gameSuccess, gameSource = awaitDownload(downloads[gamePath])
		if gameSuccess then
			loadstring(gameSource, tostring(game.PlaceId))(...)
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
