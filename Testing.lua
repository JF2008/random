
print("You will now be kicked from the game if a new player joins the server!")

local function kickLocalPlayer()
    local player = game.Players.LocalPlayer
    player:Kick("A new player joined the server.")
end

game.Players.PlayerAdded:Connect(function(newPlayer)
    kickLocalPlayer()
end)

