-- Infinite Yield style fling
-- LocalScript ONLY

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local fling = false
local spinConnection
local av, att

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "FlingGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 140)
frame.Position = UDim2.new(0.05, 0, 0.45, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local function button(text, y, color)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0, 160, 0, 32)
	b.Position = UDim2.new(0.5, -80, 0, y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b)
	return b
end

local onBtn = button("FLING ON", 30, Color3.fromRGB(60,170,60))
local offBtn = button("FLING OFF", 70, Color3.fromRGB(170,60,60))
local closeBtn = button("X", 110, Color3.fromRGB(120,40,40))

-- ===== FUNCTIONS =====
local function startFling()
	if fling then return end
	fling = true

	local char = player.Character
	if not char then return end

	local hrp = char:WaitForChild("HumanoidRootPart")

	-- Make HRP behave like Infinite Yield
	hrp.CanCollide = false

	att = Instance.new("Attachment", hrp)
	av = Instance.new("AngularVelocity")
	av.Attachment0 = att
	av.AngularVelocity = Vector3.new(0, 99999, 0)
	av.MaxTorque = math.huge
	av.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	av.Parent = hrp

	-- Constant movement force (keeps you stable)
	spinConnection = RunService.Heartbeat:Connect(function()
		if hrp then
			hrp.Velocity = hrp.CFrame.LookVector * 60
		end
	end)
end

local function stopFling()
	fling = false
	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
	end
	if av then av:Destroy() av = nil end
	if att then att:Destroy() att = nil end

	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CanCollide = true
	end
end

-- ===== BUTTONS =====
onBtn.MouseButton1Click:Connect(startFling)
offBtn.MouseButton1Click:Connect(stopFling)

closeBtn.MouseButton1Click:Connect(function()
	stopFling()
	gui:Destroy()
end)

-- Reset on respawn
player.CharacterAdded:Connect(function()
	stopFling()
end)
