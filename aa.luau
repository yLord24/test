--//Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Variables
local fireworkBuyingAmmount = 100
local selectedItemBuyingAmmount = 100
local visualizeFireworks = true
local isBuyingFireworks = false
local isFiringFireworks = false
local isBuyingSelectedItem = false
local isDroppingSelectedItem = false
local fireworkbuyingDelay = 0
local fireworkfiringDelay = 0.01
local selectedItemBuyingDelay = 0
local selectedItemDroppingDelay = 0.01
local selectedItemToDrop = ""
local savedPositions = {
    [Vector3.new(-420.5417175292969, -198.8121337890625, 245.8579559326172)] = "WeaponStore",
    [Vector3.new(-51.35408020019531, -191.0496826171875, 256.0548400878906)] = "BrassWeaponStore",
    [Vector3.new(-426.57440185546875, -204.94363403320312, 225.22071838378906)] = "Firework",
    [Vector3.new(-409.2104187011719, -205.19276428222656, 211.6106719970703)] = "GolfClub",
    [Vector3.new(-409.4185485839844, -204.94363403320312, 274.70526123046875)] = "Joint",
    [Vector3.new(-51.08735656738281, -187.46702575683594, 258.3082580566406)] = "Brass"
}
local convertedItemNames = {
    ["GolfClub"] = "Taco de Golfe",
    ["Joint"] = "Balão",
    ["Brass"] = "Ingles"
}

--//Library references
local Toggles = {
    ["Crasher_firefireworks"] = nil,
    ["Crasher_buyFireworks"] = nil,
}

--//Source
local function choqueTeam()
    ReplicatedStorage.ChangeTeamEvent:FireServer(BrickColor.new("Dark taupe"))
end

local function getBuyingProximityPrompt(itemName)

    --> ProximityPrompt Search variables
    local mainModel = workspace.Map.Model
    local mainStoreString = itemName == "Brass" and "BrassWeaponStore" or "WeaponStore"
    local weaponStoreModel
    local proximityPrompt

    --> Gets the weapon store first
    for _, Model in mainModel:GetChildren() do
        local modelPosition = Model:GetPivot().Position

        if savedPositions[modelPosition] == mainStoreString then
            weaponStoreModel = Model
            break
        end
    end

    for _, Part in weaponStoreModel:GetChildren() do
        if not Part:IsA("BasePart") or not Part:FindFirstChild("ProximityPrompt") then
            continue
        end

        if savedPositions[Part.Position] == itemName then
            proximityPrompt = Part.ProximityPrompt
            break
        end
    end

    return proximityPrompt
end

local function buyFireworks()

    --> Buying variables
    local Counter = 0
    local Heartbeat = RunService.Heartbeat
    local buyingProximityPrompt = getBuyingProximityPrompt("Firework")

    if not buyingProximityPrompt then
        warn("Y: Not found prompt for buying.")
        return
    end

    while Counter < fireworkBuyingAmmount and isBuyingFireworks do
        Counter += 1

        fireproximityprompt(buyingProximityPrompt)

        local _ = fireworkbuyingDelay ~= 0 and task.wait(fireworkbuyingDelay) or Heartbeat:Wait()
    end

    Toggles["Crasher_buyFireworks"]:Set(false)
end

local function fireFireworks()

    --> Fireworks firing variables
    local playerBackpack = Players.LocalPlayer.Backpack
    local playerCharacter = Players.LocalPlayer.Character
    local Heartbeat = RunService.Heartbeat

    --> Equip fireworks and fire it
    while isFiringFireworks do
        for _, Tool in playerBackpack:GetChildren() do

            if Tool.Name ~= "Rojao" then continue end

            playerCharacter.Humanoid:EquipTool(Tool)
            task.wait(fireworkfireworkfiringDelay)
            Tool:Activate()
            Tool:Destroy()
        end

        Heartbeat:Wait()
    end
end

local function buySelectedItem()

    --> Buying variables
    local Counter = 0
    local Heartbeat = RunService.Heartbeat
    local buyingProximityPrompt = getBuyingProximityPrompt(selectedItemToDrop)

    if not buyingProximityPrompt then
        warn("Y: Not found prompt for buying. (SELECTED_ITEM)")
        return
    end

    while Counter < selectedItemBuyingAmmount and isBuyingSelectedItem do
        Counter += 1

        fireproximityprompt(buyingProximityPrompt)

        local _ = fireworkbuyingDelay ~= 0 and task.wait(selectedItemBuyingDelay) or Heartbeat:Wait()
    end

    Toggles["Dropper_buyitem"]:Set(false)
end

local function dropSelectedItem()

    --> Fireworks firing variables
    local playerBackpack = Players.LocalPlayer.Backpack
    local playerCharacter = Players.LocalPlayer.Character
    local Heartbeat = RunService.Heartbeat
    local convertedName = convertedItemNames[selectedItemToDrop]

    if not convertedName then
        warn("Y: Not found item for dropping. (ITEM_NAME)")
        return
    end

    --> Equip fireworks and fire it
    while isDroppingSelectedItem do
        for _, Tool in playerBackpack:GetChildren() do

            if Tool.Name ~= convertedName then continue end

            playerCharacter.Humanoid:EquipTool(Tool)
            task.wait(selectedItemDroppingDelay)
            Tool.Parent = workspace
        end

        Heartbeat:Wait()
    end
end

local function getAnimationTrack(animationId)

    --> Function variables
    local playerCharacter = Players.LocalPlayer.Character
    local playerHumanoid = playerCharacter.Humanoid
    local resultTrack;

for _, Track in ipairs(playerHumanoid:GetPlayingAnimationTracks()) do

    if Track.Animation.AnimationId == animationId then
        resultTrack = Track
        break
    end
end

return resultTrack
end
local function killAll()

local surrenderTrack = getAnimationTrack("rbxassetid://17625947275")

    if surrenderTrack then
        surrenderTrack:Stop()
    end

end

workspace.ChildAdded:Connect(function(Instance)

    --> Deletes firework vfx (because laggin)
    if Instance.Name == "Artificio" and not visualizeFireworks then
        Instance:Destroy()
    end
end)

--//Library
local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Wait = library.subs.Wait -- Only returns if the GUI has not been terminated. For "while Wait() do" loops
local Yhub = library:CreateWindow({
    Name = "Y###",
    Themeable = {
        Info = "...",
    },
})

local generalTab = Yhub:CreateTab({
    Name = "General",
})
local serverCrasherSection = generalTab:CreateSection({
    Name = "Server Crasher",
})

Toggles["Crasher_firefireworks"] = serverCrasherSection:AddToggle({
    Name = "Fire fireworks",
    Flag = "Crasher_firefireworks",
    Callback = function()
        isFiringFireworks = not isFiringFireworks

        if isFiringFireworks then
            fireFireworks()
        end
    end,
})

Toggles["Crasher_buyFireworks"] = serverCrasherSection:AddToggle({
    Name = "Buy Fireworks",
    Flag = "Crasher_buyFireworks",
    Callback = function()
        isBuyingFireworks = not isBuyingFireworks

        if isBuyingFireworks then
            buyFireworks()
        end
    end,
})

Toggles["Crasher_visualizeFireworks"] = serverCrasherSection:AddToggle({
    Name = "Visualize Fireworks",
    Flag = "Crasher_visualizeFireworks",
    Value = true,
    Callback = function()
        visualizeFireworks = not visualizeFireworks
    end,
})

serverCrasherSection:AddSlider({
    Name = "Buying ammount",
    Flag = "Crasher_buyerammount",
    Value = fireworkBuyingAmmount,
    Precise = 50,
    Min = 0,
    Max = 10000,
    Callback = function(Value)
        fireworkBuyingAmmount = Value
    end
})

serverCrasherSection:AddTextbox({
    Name = "Firing Delay",
    Flag = "Crasher_fireworkfiringDelay",
    type = "number",
    Value = fireworkfiringDelay,
    Callback = function(Value)
        fireworkfiringDelay = Value
    end,
})

serverCrasherSection:AddTextbox({
    Name = "Buying Delay",
    Flag = "Crasher_fireworkbuyingDelay",
    type = "number",
    Value = fireworkbuyingDelay,
    Callback = function(Value)
        fireworkbuyingDelay = Value
    end,
})

local itemDropperSection = generalTab:CreateSection({
    Name = "Item Dropper",
})

itemDropperSection:AddTextbox({
    Name = "Item Name",
    Flag = "Dropper_itemname",
    Value = selectedItemToDrop,
    Callback = function(Value)
        selectedItemToDrop = Value
    end,
})

Toggles["Dropper_buyitem"] = itemDropperSection:AddToggle({
    Name = "Buy Item",
    Flag = "Dropper_buyitem",
    Callback = function()
        isBuyingSelectedItem = not isBuyingSelectedItem

        if isBuyingSelectedItem then
            buySelectedItem()
        end
    end,
})

Toggles["Dropper_dropitem"] = itemDropperSection:AddToggle({
    Name = "Drop Item",
    Flag = "Dropper_dropitem",
    Callback = function()
        isDroppingSelectedItem = not isDroppingSelectedItem

        if isDroppingSelectedItem then
            dropSelectedItem()
        end
    end,
})

itemDropperSection:AddSlider({
    Name = "Buying ammount",
    Flag = "Dropper_buyerammount",
    Value = selectedItemBuyingAmmount,
    Precise = 50,
    Min = 0,
    Max = 10000,
    Callback = function(Value)
        selectedItemBuyingAmmount = Value
    end
})

itemDropperSection:AddTextbox({
    Name = "Buying Delay",
    Flag = "Dropper_selectedItemBuyingDelay",
    type = "number",
    Value = selectedItemBuyingDelay,
    Callback = function(Value)
        selectedItemBuyingDelay = Value
    end,
})

itemDropperSection:AddTextbox({
    Name = "Dropping Delay",
    Flag = "Dropper_selectedItemDroppingDelay",
    type = "number",
    Value = selectedItemDroppingDelay,
    Callback = function(Value)
        selectedItemDroppingDelay = Value
    end,
})

local MiscSection = generalTab:CreateSection({
    Name = "Misc",
    Side = "Right",
})

MiscSection:AddButton({
    Name = "Join CHOQUE",
    Callback = choqueTeam,
})

MiscSection:AddKeybind({
    Name = "Test Key",
    Callback = print,
})
