local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 120)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.BorderColor3 = Color3.fromRGB(25, 25, 25)
titleLabel.BorderSizePixel = 2
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "Teleport Controls"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

local setSpawnButton = Instance.new("TextButton")
setSpawnButton.Size = UDim2.new(1, -20, 0, 30)
setSpawnButton.AnchorPoint = Vector2.new(0.5, 0)
setSpawnButton.Position = UDim2.new(0.5, 0, 0, 40)
setSpawnButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
setSpawnButton.BorderColor3 = Color3.fromRGB(25, 25, 25)
setSpawnButton.BorderSizePixel = 2
setSpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
setSpawnButton.Text = "Set Spawn"
setSpawnButton.Font = Enum.Font.SourceSans
setSpawnButton.TextSize = 16
setSpawnButton.Parent = mainFrame

local startTeleportButton = Instance.new("TextButton")
startTeleportButton.Size = UDim2.new(0.5, -15, 0, 30)
startTeleportButton.Position = UDim2.new(0, 10, 1, -40)
startTeleportButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
startTeleportButton.BorderColor3 = Color3.fromRGB(25, 25, 25)
startTeleportButton.BorderSizePixel = 2
startTeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startTeleportButton.Text = "Start Teleport"
startTeleportButton.Font = Enum.Font.SourceSans
startTeleportButton.TextSize = 16
startTeleportButton.Parent = mainFrame

local stopTeleportButton = Instance.new("TextButton")
stopTeleportButton.Size = UDim2.new(0.5, -15, 0, 30)
stopTeleportButton.Position = UDim2.new(0.5, 5, 1, -40)
stopTeleportButton.BackgroundColor3 = Color3.fromRGB(255, 99, 71)
stopTeleportButton.BorderColor3 = Color3.fromRGB(25, 25, 25)
stopTeleportButton.BorderSizePixel = 2
stopTeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopTeleportButton.Text = "Stop Teleport"
stopTeleportButton.Font = Enum.Font.SourceSans
stopTeleportButton.TextSize = 16
stopTeleportButton.Parent = mainFrame

local player = game.Players.LocalPlayer
local character
local humanoidRootPart

local spawnPoint = nil
local isTeleporting = false
local teleportConnection = nil

local function stopTeleport()
    if not isTeleporting then
        return
    end

    isTeleporting = false
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
   
end

local function onCharacterAdded(newCharacter)
    stopTeleport() -- Stop any previous loops
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end

local function setSpawn()
    if not humanoidRootPart then return end
    spawnPoint = humanoidRootPart.CFrame
    
end

local function startTeleport()
    if not spawnPoint then
      
        return
    end

    if isTeleporting then
       
        return
    end
    
    if not humanoidRootPart or not humanoidRootPart.Parent then
        
        return
    end

    isTeleporting = true
    teleportConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if isTeleporting and humanoidRootPart and humanoidRootPart.Parent then
            humanoidRootPart.CFrame = spawnPoint
        else
            stopTeleport()
        end
    end)
 
end

setSpawnButton.MouseButton1Click:Connect(setSpawn)
startTeleportButton.MouseButton1Click:Connect(startTeleport)
stopTeleportButton.MouseButton1Click:Connect(stopTeleport)

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end
