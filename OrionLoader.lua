-- Drop-in Orion entrypoint for Vape.
-- Load NewMainScript.lua first, then this file returns the native Vape adapter.
local deadline = os.clock() + 15
repeat
	if shared.OrionLib then
		return shared.OrionLib
	end
	task.wait()
until os.clock() >= deadline

error('Vape Orion compatibility is not ready. Load NewMainScript.lua first.')
