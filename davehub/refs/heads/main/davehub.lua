local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local setWebhookEvent = ReplicatedStorage:WaitForChild("SetUserWebhook")
local webhookStatusEvent = ReplicatedStorage:WaitForChild("WebhookStatus")

player.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

local function notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Button1 = "Close",
			Duration = 5
		})
	end)
end

notify("Success", "Anti-idle enabled")

local gui = Instance.new("ScreenGui")
gui.Name = "DavehubWebhookGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(430, 210)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.fromOffset(10, 10)
title.BackgroundTransparency = 1
title.Text = "Enter your Discord webhook URL"
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -20, 0, 36)
box.Position = UDim2.fromOffset(10, 55)
box.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
box.TextColor3 = Color3.fromRGB(245, 245, 245)
box.PlaceholderText = "https://discord.com/api/webhooks/..."
box.ClearTextOnFocus = false
box.TextXAlignment = Enum.TextXAlignment.Left
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 24)
status.Position = UDim2.fromOffset(10, 98)
status.BackgroundTransparency = 1
status.Text = "Status: waiting"
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.Parent = frame

local save = Instance.new("TextButton")
save.Size = UDim2.fromOffset(120, 34)
save.Position = UDim2.new(1, -130, 1, -44)
save.BackgroundColor3 = Color3.fromRGB(73, 127, 255)
save.TextColor3 = Color3.new(1, 1, 1)
save.Font = Enum.Font.GothamBold
save.TextSize = 14
save.Text = "Save"
save.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(120, 34)
closeBtn.Position = UDim2.fromOffset(10, 156)
closeBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 64)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Text = "Close"
closeBtn.Parent = frame

save.MouseButton1Click:Connect(function()
	status.Text = "Status: sending..."
	status.TextColor3 = Color3.fromRGB(180, 180, 180)
	setWebhookEvent:FireServer(box.Text)
end)

closeBtn.MouseButton1Click:Connect(function()
	gui.Enabled = false
end)

webhookStatusEvent.OnClientEvent:Connect(function(ok, message)
	if ok then
		status.Text = "Status: connected"
		status.TextColor3 = Color3.fromRGB(110, 220, 130)
		notify("Webhook", message or "Connected")
	else
		status.Text = "Status: failed"
		status.TextColor3 = Color3.fromRGB(255, 120, 120)
		notify("Webhook Error", message or "Failed")
	end
end)
