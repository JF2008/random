
print("The script has started")

local function kickLocalPlayer()
    local player = game.Players.LocalPlayer
    player:Kick("A new player joined the server.")
end

game.Players.PlayerAdded:Connect(function(newPlayer)
    kickLocalPlayer()
end)

