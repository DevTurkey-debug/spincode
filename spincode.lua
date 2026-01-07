-- Spin GUI (PC + Mobile) | LocalScript

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Spin variables
local spinning = false
local spinSpeed = 200 -- increase for faster spin
local angularVelocity
local attachment

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "SpinGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 140)
frame.Position = UDim2.new(0.02, 0, 0.45, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

-- Close button
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 26, 0, 26)
close.Position = UDim2.new(1, -30, 0, 4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
close.TextColor3 = Color3.new(1,1,1)
close.BorderSizePixel = 0
Instance.new("UICorner", close)

-- Button creator
local function makeButton(text, y, color)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0, 160, 0, 32)
	b.Position = UDim2.new(0.5, -80, 0, y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)
	return b
end

local spinOn = makeButton("Spin ON", 40, Color3.fromRGB(60, 170, 60))
local spinOff = makeButton("Spin OFF", 80, Color3.fromRGB(170, 60, 60))

-- ================= Spin Logic =================
local function startSpin()
	if spinning then return end
	spinning = true

	attachment = Instance.new("Attachment")
	attachment.Parent = hrp

	angularVelocity = Instance.new("AngularVelocity")
	angularVelocity.Attachment0 = attachment
	angularVelocity.AngularVelocity = Vector3.new(0, spinSpeed, 0)
	angularVelocity.MaxTorque = math.huge
	angularVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	angularVelocity.Parent = hrp
end

local function stopSpin()
	spinning = false
	if angularVelocity then angularVelocity:Destroy() end
	if attachment then attachment:Destroy() end
end

-- ================= Connections =================
spinOn.MouseButton1Click:Connect(startSpin)
spinOff.MouseButton1Click:Connect(stopSpin)

close.MouseButton1Click:Connect(function()
	stopSpin()
	gui:Destroy()
end)

-- Cleanup on respawn
player.CharacterAdded:Connect(function(newChar)
	char = newChar
	hrp = char:WaitForChild("HumanoidRootPart")
	stopSpin()
end)
