local starterChar = game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts")
local anims = starterChar:WaitForChild("Animate")

local cnpr = game:GetService("ContentProvider")
for i, v in pairs (anims:GetChildren()) do
    cnpr:PreloadAsync({v})
end

print("Anims in Animate Script have been loaded ")

-- local rs = game:GetService("ReplicatedStorage") -- THIS CODE CAN BE USED FOR ANIMS IN THE REPLICATED STORAGE, the one above is js for the anims in the Animate local script.
-- local anims = rs:WaitForChild("MoveAnimHolder")

-- local Cnpr = game:GetService("ContentProvider")

-- for i, v in pairs(anims:GetChildren()) do
--     Cnpr:PreloadAsync({v})
-- end

-- print("Anims have been loaded")