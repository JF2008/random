
local function createRedCircle()

    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
   
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RedCircleGui"
    screenGui.Parent = playerGui
    
    
    local circle = Instance.new("Frame")
    circle.Name = "RedCircle"
    circle.Size = UDim2.new(0, 50, 0, 50) -- 50x50 pixels
    circle.Position = UDim2.new(1, -60, 1, -60) -- Bottom-right corner with padding
    circle.AnchorPoint = Vector2.new(1, 1) -- Anchor to bottom-right
    circle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red color
    circle.BorderSizePixel = 0
    circle.Parent = screenGui
    
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(1, 0) -- Fully round
    uiCorner.Parent = circle

    -- Wait 10 seconds and remove the GUI
    task.wait(10)
    screenGui:Destroy()
end


createRedCircle()
print("You will be kicked if a player joins the game!")

local function kickLocalPlayer()
    local player = game.Players.LocalPlayer
    player:Kick("A new player joined the server.")
end

game.Players.PlayerAdded:Connect(function(newPlayer)
    kickLocalPlayer()
end)

