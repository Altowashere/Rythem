local rs = game:GetService("ReplicatedStorage")
local anims = rs:WaitForChild("MoveAnimHolder")

local Cnpr = game:GetService("ContentProvider")

for i, v in pairs(anims:GetChildren()) do
    Cnpr:PreloadAsync({v})
end

print("Anims have been loaded")