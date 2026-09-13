-- Drop-in Orion entrypoint for Vape.
-- Boots NewMainScript automatically when the universal adapter is absent.
local VAPE_LOADER = 'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/NewMainScript.lua'

if not (shared.OrionLib and shared.OrionLib.__VapeOrionCompat) then
	local source = game:HttpGet(VAPE_LOADER, true)
	local chunk, err = loadstring(source, 'Vape NewMainScript')
	if not chunk then
		error('Vape bootstrap failed: '..tostring(err))
	end
	chunk()
end

local deadline = os.clock() + 30
repeat
	if shared.OrionLib and shared.OrionLib.__VapeOrionCompat then
		return shared.OrionLib
	end
	task.wait()
until os.clock() >= deadline

error('Vape Orion compatibility bootstrap timed out.')
