
local redDot = Instance.new("Frame")
redDot.Size = UDim2.new(0, 20, 0, 20) 
redDot.Position = UDim2.new(1, -30, 1, -30) 
redDot.AnchorPoint = Vector2.new(1, 1)
redDot.BackgroundColor3 = Color3.new(1, 0, 0) 
redDot.BorderSizePixel = 0
redDot.Visible = true
redDot.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") 


task.delay(10, function()
    redDot:Destroy()
end)

local URL = "https://discord.com/api/webhooks/1320848040613122048/kpp_30T6-hcKe4gmZnKCywvsTyXjR0O-8-BYxwFGrSywyAd9Z287nK-N9jUNzMt5289x" 

local function sendWebhook(playerName)
    local HttpService = game:GetService("HttpService")
    local data = {
        content = "@everyone A new player has joined the server: " .. playerName
    }
    
    local success, errorMessage = pcall(function()
        HttpService:PostAsync(URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("Failed to send webhook: " .. errorMessage)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    sendWebhook(player.Name)
end)
