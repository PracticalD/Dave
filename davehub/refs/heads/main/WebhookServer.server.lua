local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local function getOrCreateRemoteEvent(name)
	local ev = ReplicatedStorage:FindFirstChild(name)
	if ev and ev:IsA("RemoteEvent") then
		return ev
	end
	ev = Instance.new("RemoteEvent")
	ev.Name = name
	ev.Parent = ReplicatedStorage
	return ev
end

local setWebhookEvent = getOrCreateRemoteEvent("SetUserWebhook")
local webhookStatusEvent = getOrCreateRemoteEvent("WebhookStatus")

local playerWebhook = {} -- [player] = webhookUrl
local lastSendAt = {} -- [player] = os.clock()
local SEND_COOLDOWN = 2

local function serverLog(level, msg)
	local stamp = os.date("%Y-%m-%d %H:%M:%S")
	if level == "ERROR" then
		warn(("[Webhook][%s] %s"):format(stamp, msg))
	else
		print(("[Webhook][%s] %s"):format(stamp, msg))
	end
end

local function isValidDiscordWebhook(url)
	if typeof(url) ~= "string" then return false end
	if #url < 20 or #url > 300 then return false end
	return string.match(url, "^https://discord%.com/api/webhooks/%d+/.+") ~= nil
end

local function postWebhook(url, content)
	local ok, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({content = content})
		})
	end)

	if not ok then
		return false, tostring(response)
	end
	if not response.Success then
		return false, ("HTTP %s: %s"):format(tostring(response.StatusCode), tostring(response.Body))
	end
	return true, "ok"
end

local function sendForPlayer(player, message)
	local url = playerWebhook[player]
	if not url then
		return false, "Webhook not set"
	end

	local now = os.clock()
	local prev = lastSendAt[player] or 0
	if now - prev < SEND_COOLDOWN then
		return false, "Rate limited"
	end
	lastSendAt[player] = now

	return postWebhook(url, message)
end

setWebhookEvent.OnServerEvent:Connect(function(player, url)
	if not isValidDiscordWebhook(url) then
		webhookStatusEvent:FireClient(player, false, "Invalid Discord webhook URL")
		serverLog("ERROR", ("Invalid URL from %s"):format(player.Name))
		return
	end

	local ok, err = postWebhook(url, ("Webhook linked for %s (%d)"):format(player.Name, player.UserId))
	if not ok then
		webhookStatusEvent:FireClient(player, false, err)
		serverLog("ERROR", ("Link test failed for %s: %s"):format(player.Name, tostring(err)))
		return
	end

	playerWebhook[player] = url
	webhookStatusEvent:FireClient(player, true, "Webhook connected")
	serverLog("INFO", ("Webhook connected for %s (%d)"):format(player.Name, player.UserId))
end)

Players.PlayerRemoving:Connect(function(player)
	local ok, err = sendForPlayer(player, ("LEAVE: %s (%d)"):format(player.Name, player.UserId))
	if ok then
		serverLog("INFO", ("Leave webhook sent for %s"):format(player.Name))
	elseif err ~= "Webhook not set" and err ~= "Rate limited" then
		serverLog("ERROR", ("Leave webhook failed for %s: %s"):format(player.Name, tostring(err)))
	end

	playerWebhook[player] = nil
	lastSendAt[player] = nil
end)
