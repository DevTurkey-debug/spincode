-- Spin Fling GUI (PC + Mobile) | LocalScript

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local spinning = false
local spinSpeed = 900 -- HIGH = fling
local attachment
local angularVelocity

-- ================= GUI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "SpinFlingGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 210, 0, 150)
frame.Position = UDim2.new(0.02, 0, 0.45, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

-- Close button
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 26, 0, 26)
close.Position = UDim2.new(1, -30, 0, 4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,50,50)
close.TextColor3 = Color3.new(1,1,1)
close.BorderSizePixel = 0
Instance.new("UICorner", close)

-- Button creator
local function makeButton(text, y, color)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0, 170, 0, 34)
	b.Position = UDim2.new(0.5, -85, 0, y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)
	return b
end

local onBtn = makeButton("SPIN FLING ON", 40, Color3.fromRGB(60,170,60))
local offBtn = makeButton("SPIN FLING OFF", 85, Color3.fromRGB(170,60,60))

-- ================= FLING LOGIC =================
local function startSpin()
	if spinning then return end
	spinning = true

	-- Ensure collisions are enabled
	hrp.CanCollide = true
	hrp.Massless = false

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

-- ================= BUTTONS =================
onBtn.MouseButton1Click:Connect(startSpin)
offBtn.MouseButton1Click:Connect(stopSpin)

close.MouseButton1Click:Connect(function()
	stopSpin()
	gui:Destroy()
end)

-- ================= RESPAWN SAFE =================
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	hrp = character:WaitForChild("HumanoidRootPart")
	stopSpin()
end)
