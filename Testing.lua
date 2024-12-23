
local function createNotification()
    -- Get the player's GUI
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create a ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationGui"
    screenGui.Parent = playerGui
    
    -- Create the notification frame
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0, 300, 0, 100) -- 300x100 pixels
    notificationFrame.Position = UDim2.new(1, -320, 1, -120) -- Bottom-right corner with padding
    notificationFrame.AnchorPoint = Vector2.new(1, 1) -- Anchor to bottom-right
    notificationFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Dark gray color
    notificationFrame.BackgroundTransparency = 0.2
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = screenGui
    
    -- Create a corner to round the notification
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0.1, 0) -- Slightly rounded corners
    uiCorner.Parent = notificationFrame

    -- Add text to the notification
    local notificationText = Instance.new("TextLabel")
    notificationText.Name = "NotificationText"
    notificationText.Size = UDim2.new(1, -20, 1, -20) -- Leave some padding
    notificationText.Position = UDim2.new(0, 10, 0, 10) -- Center with padding
    notificationText.BackgroundTransparency = 1 -- Transparent background
    notificationText.Text = "Kick script activated"
    notificationText.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
    notificationText.Font = Enum.Font.SourceSansBold
    notificationText.TextScaled = true
    notificationText.Parent = notificationFrame

    -- Add a button overlay to make it clickable
    local button = Instance.new("TextButton")
    button.Name = "CloseButton"
    button.Size = UDim2.new(1, 0, 1, 0) -- Cover the entire frame
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundTransparency = 1 -- Transparent background
    button.Text = "" -- No text on the button
    button.Parent = notificationFrame
    
    -- Function to remove the GUI
    local function removeNotification()
        if screenGui then
            screenGui:Destroy()
        end
    end

    -- Remove the GUI when the button is clicked
    button.MouseButton1Click:Connect(removeNotification)

    -- Automatically remove the GUI after 10 seconds
    task.delay(10, removeNotification)
end

-- Activate the notification when the script runs
createNotification()

print("You will be kicked if a player joins the game!")

local function kickLocalPlayer()
    local player = game.Players.LocalPlayer
    player:Kick("A new player joined the server.")
end

game.Players.PlayerAdded:Connect(function(newPlayer)
    kickLocalPlayer()
end)

