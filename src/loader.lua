local isfile = isfile
	or function(file)
		local suc, res = pcall(function()
			return readfile(file)
		end)
		return suc and res ~= nil and res ~= ""
	end
local delfile = delfile or function(file)
	writefile(file, "")
end

local httpService = game:GetService("HttpService")
local compiledRepository = "7GrandDadPGN/VapeCompiled"
local compiledRaw = "https://raw.githubusercontent.com/" .. compiledRepository .. "/"
local cacheWatermark =
	"--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates."
local downloadAttempts = 3

local function validCommit(value)
	return type(value) == "string" and #value == 40 and value:match("^[%da-fA-F]+$") ~= nil
end

local function readCachedCommit()
	if not isfile("newvape/profiles/commit.txt") then
		return nil
	end
	local commit = readfile("newvape/profiles/commit.txt"):match("^%s*(.-)%s*$")
	return validCommit(commit) and commit or nil
end

local function fetchLatestCommit()
	local success, body = pcall(function()
		return game:HttpGet("https://api.github.com/repos/" .. compiledRepository .. "/commits/main", true)
	end)
	if not success then
		return nil
	end

	local decodedSuccess, data = pcall(httpService.JSONDecode, httpService, body)
	return decodedSuccess and type(data) == "table" and validCommit(data.sha) and data.sha or nil
end

local function requestFile(path, commit)
	local relativePath = select(1, path:gsub("newvape/", ""))
	local lastError
	for attempt = 1, downloadAttempts do
		local success, body = pcall(game.HttpGet, game, compiledRaw .. commit .. "/" .. relativePath, true)
		if success and type(body) == "string" and body ~= "" and body ~= "404: Not Found" then
			return body
		end
		lastError = body
		if attempt < downloadAttempts then
			task.wait(0.2 * (2 ^ (attempt - 1)))
		end
	end
	error("Failed to download " .. path .. ": " .. tostring(lastError))
end

local function downloadFile(path, func)
	if not isfile(path) then
		local res = requestFile(path, readfile("newvape/profiles/commit.txt"))
		if path:find(".lua") then
			res = cacheWatermark .. "\n" .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then
		return
	end
	for _, file in listfiles(path) do
		if file:find("loader") then
			continue
		end
		if isfile(file) and select(1, readfile(file):find(cacheWatermark, 1, true)) == 1 then
			delfile(file)
		end
	end
end

for _, folder in
	{ "newvape", "newvape/games", "newvape/profiles", "newvape/assets", "newvape/libraries", "newvape/guis" }
do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local assetVer = "1"
	local cachedCommit = readCachedCommit()
	local latestCommit = fetchLatestCommit()
	local commit = latestCommit or cachedCommit or "main"

	-- Only invalidate a working cache after GitHub confirms a different commit.
	-- Network/API failure keeps the last known-good version instead of wiping it.
	if latestCommit and cachedCommit and latestCommit ~= cachedCommit then
		wipeFolder("newvape")
		wipeFolder("newvape/games")
		wipeFolder("newvape/guis")
		wipeFolder("newvape/libraries")
	end

	if (isfile("newvape/profiles/asset.txt") and readfile("newvape/profiles/asset.txt") or "") ~= assetVer then
		wipeFolder("newvape/assets")
	end

	writefile("newvape/profiles/asset.txt", assetVer)
	writefile("newvape/profiles/commit.txt", commit)
end

shared.VapeFileCache = {
	Download = downloadFile,
	Watermark = cacheWatermark,
}

return loadstring(downloadFile("newvape/main.lua"), "main")()
