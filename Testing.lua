
local function sendChatMessage(message, color)
    print("attempted to send chat message")
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = message,
        Color = color
    })
end

sendChatMessage("⚠️You will now be kicked from the game if a player joins your server!", Color3.fromRGB(255, 255, 0))

local function kickLocalPlayer()
    local player = game.Players.LocalPlayer
    player:Kick("A new player joined the server.")
end

game.Players.PlayerAdded:Connect(function(newPlayer)
    kickLocalPlayer()
end)

