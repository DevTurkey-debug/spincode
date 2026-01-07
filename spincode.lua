-- Spin Fling ALL-IN-ONE (FIXED)
-- Place in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================= CREATE REMOTE =================
local remote = ReplicatedStorage:FindFirstChild("SpinRemote")
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = "SpinRemote"
	remote.Parent = ReplicatedStorage
end

-- ================= SERVER LOGIC =================
local spinning = {}
local SPIN_SPEED = 900

remote.OnServerEvent:Connect(function(player, action)
	if typeof(action) ~= "string" then return end

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- START
	if action == "START" and not spinning[player] then
		local att = Instance.new("Attachment")
		att.Parent = hrp

		local av = Instance.new("AngularVelocity")
		av.Attachment0 = att
		av.AngularVelocity = Vector3.new(0, SPIN_SPEED, 0)
		av.MaxTorque = math.huge
		av.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
		av.Parent = hrp

		spinning[player] = {att, av}
	end

	-- STOP
	if action == "STOP" and spinning[player] then
		for _, obj in pairs(spinning[player]) do
			obj:Destroy()
		end
		spinning[player] = nil
	end
end)

Players.PlayerRemoving:Connect(function(player)
	spinning[player] = nil
end)

-- ================= CLIENT SOURCE =================
local clientSource = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("SpinRemote")

local spinning = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SpinFlingGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 210, 0, 150)
frame.Position = UDim2.new(0.02, 0, 0.45, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 26, 0, 26)
close.Position = UDim2.new(1, -30, 0, 4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,50,50)
close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", close)

local function button(text, y, color)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0, 170, 0, 34)
	b.Position = UDim2.new(0.5, -85, 0, y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b)
	return b
end

local onBtn = button("SPIN FLING ON", 40, Color3.fromRGB(60,170,60))
local offBtn = button("SPIN FLING OFF", 85, Color3.fromRGB(170,60,60))

onBtn.MouseButton1Click:Connect(function()
	if not spinning then
		spinning = true
		remote:FireServer("START")
	end
end)

offBtn.MouseButton1Click:Connect(function()
	if spinning then
		spinning = false
		remote:FireServer("STOP")
	end
end)

close.MouseButton1Click:Connect(function()
	if spinning then
		remote:FireServer("STOP")
	end
	gui:Destroy()
end)
]]

-- ================= INJECT GUI =================
local function giveClient(player)
	local ls = Instance.new("LocalScript")
	ls.Name = "SpinFlingClient"
	ls.Source = clientSource
	ls.Parent = player:WaitForChild("PlayerGui")
end

Players.PlayerAdded:Connect(giveClient)

-- Studio test support
for _, p in ipairs(Players:GetPlayers()) do
	giveClient(p)
end
