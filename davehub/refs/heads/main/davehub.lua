local URL = "https://raw.githubusercontent.com/PracticalD/Dave/refs/heads/main/WebhookServer.server.lua"

local ok, src = pcall(function()
	return game:HttpGet(URL)
end)
if not ok then
	error("HttpGet failed: " .. tostring(src))
end

local fn, compileErr = loadstring(src)
if not fn then
	error("Compile failed: " .. tostring(compileErr))
end

local runOk, runErr = pcall(fn)
if not runOk then
	error("Runtime failed: " .. tostring(runErr))
end
