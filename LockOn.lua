-- Lock-On independiente (botón táctil para móvil)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local MAX_DIST = 80   -- distancia máxima para fijar objetivo
local SMOOTH = 0.25   -- 1 = instantáneo, menor = más suave
local target = nil

-- Evita duplicados si lo ejecutas dos veces
pcall(function() RunService:UnbindFromRenderStep("LockOn") end)
local old = lp:WaitForChild("PlayerGui"):FindFirstChild("LockOnGui")
if old then old:Destroy() end

local function getTarget()
	local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local best, bestDist = nil, MAX_DIST
	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		if p ~= lp and hrp and hum and hum.Health > 0 then
			local d = (hrp.Position - root.Position).Magnitude
			if d < bestDist then best, bestDist = hrp, d end
		end
	end
	return best
end

-- Botón táctil
local gui = Instance.new("ScreenGui")
gui.Name = "LockOnGui"
gui.ResetOnSpawn = false
gui.Parent = lp.PlayerGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.fromOffset(90, 50)
btn.Position = UDim2.new(1, -110, 0.5, 0)
btn.Text = "LOCK: OFF"
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = gui

btn.Activated:Connect(function()
	if target then
		target = nil
	else
		target = getTarget()
	end
	btn.Text = target and "LOCK: ON" or "LOCK: OFF"
end)

RunService:BindToRenderStep("LockOn", Enum.RenderPriority.Camera.Value + 1, function()
	if not target then return end
	local hum = target.Parent and target.Parent:FindFirstChildOfClass("Humanoid")
	local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if not (hum and hum.Health > 0 and root and target:IsDescendantOf(workspace)) then
		target = nil
		btn.Text = "LOCK: OFF"
		return
	end
	cam = workspace.CurrentCamera
	local goal = CFrame.lookAt(cam.CFrame.Position, target.Position)
	cam.CFrame = cam.CFrame:Lerp(goal, SMOOTH)
end)
