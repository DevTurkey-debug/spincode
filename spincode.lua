-- Mobile + PC Infinite Yield style fling
-- LocalScript ONLY (StarterPlayerScripts)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local fling = false
local spinConnection, touchConnection
local av, att

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "TouchFlingGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local function button(text, y, color)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0, 180, 0, 32)
	b.Position = UDim2.new(0.5, -90, 0, y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b)
	return b
end

local onBtn = button("FLING ON", 30, Color3.fromRGB(60,170,60))
local offBtn = button("FLING OFF", 70, Color3.fromRGB(170,60,60))
local closeBtn = button("X", 110, Color3.fromRGB(170,50,50))

-- ===== FUNCTIONS =====
local function flingPlayer(targetHRP)
	if targetHRP and targetHRP.Parent and targetHRP.Parent:FindFirstChild("Humanoid") then
		local bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
		bodyVel.Velocity = (targetHRP.Position - player.Character.HumanoidRootPart.Position).Unit * 120
		bodyVel.P = 1e5
		bodyVel.Parent = targetHRP
		task.delay(0.1, function() bodyVel:Destroy() end)
	end
end

local function startFling()
	if fling then return end
	fling = true

	local char = player.Character
	if not char then return end
	local hrp = char:WaitForChild("HumanoidRootPart")

	-- Stable movement
	hrp.CanCollide = false
	hrp.Massless = true

	-- Spin setup
	att = Instance.new("Attachment", hrp)
	av = Instance.new("AngularVelocity")
	av.Attachment0 = att
	av.AngularVelocity = Vector3.new(0, 400, 0)
	av.MaxTorque = math.huge
	av.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	av.Parent = hrp

	-- Forward movement with mobile support
	spinConnection = RunService.Heartbeat:Connect(function()
		if hrp then
			local direction = hrp.CFrame.LookVector
			-- If mobile, include thumbstick input
			if UserInputService.TouchEnabled then
				local moveVec = Vector3.new(player.Character.Humanoid.MoveDirection.X, 0, player.Character.Humanoid.MoveDirection.Z)
				if moveVec.Magnitude > 0 then
					direction = moveVec.Unit
				end
			end
			hrp.Velocity = direction * 12
		end
	end)

	-- Touch fling players
	touchConnection = hrp.Touched:Connect(function(part)
		local targetChar = part.Parent
		if targetChar == char then return end
		local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
		if targetHRP then
			flingPlayer(targetHRP)
		end
	end)
end

local function stopFling()
	fling = false
	if spinConnection then spinConnection:Disconnect() spinConnection = nil end
	if touchConnection then touchConnection:Disconnect() touchConnection = nil end
	if av then av:Destroy() av = nil end
	if att then att:Destroy() att = nil end

	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CanCollide = true
		char.HumanoidRootPart.Massless = false
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
