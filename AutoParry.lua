-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

-- Constants
-- local TOGGLE_KEY = Enum.KeyCode.V
local ANIMATION_NAMES = {'Slash', 'Swing', 'slash', 'swing', 'SLash'}
local BLOCK_RANGE = 16.2
local BLOCK_DELAY = 0.006

-- Variables
local localPlayer = Players.LocalPlayer
local cooldownFrame = localPlayer.PlayerGui.RoactUI.BottomStatusIndicators.FrameContainer.SecondRowFrame.ActionCooldownsFrame.ParryActionCooldown
local isEnabled = true
local animationInfo = {}

-- Helper Functions
local function getProductInfo(id)
    local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id)
    return success and info or nil
end

local function block()
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.15)
    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

local function toggleScript()
    isEnabled = not isEnabled
    print("Script is now:", isEnabled and "Enabled" or "Disabled")
end

local function isAnimationBlockable(animName)
    for _, name in ipairs(ANIMATION_NAMES) do
        if animName:match(name) then
            return true
        end
    end
    return false
end

-- Main Logic
local function onAnimationPlayed(player, track)
    if not isEnabled then return end
    
    local info = animationInfo[track.Animation.AnimationId]
    if not info then
        info = getProductInfo(tonumber(track.Animation.AnimationId:match("%d+")))
        animationInfo[track.Animation.AnimationId] = info
    end
    
    local localCharacter = localPlayer.Character
    local playerCharacter = player.Character
    if not (localCharacter and playerCharacter) then return end
    
    local distance = (playerCharacter.HumanoidRootPart.Position - localCharacter.HumanoidRootPart.Position).Magnitude
    if distance >= BLOCK_RANGE then return end
    
    if info and isAnimationBlockable(info.Name) then
        task.wait(BLOCK_DELAY)
        if cooldownFrame.ImageTransparency ~= 0.5 and track.IsPlaying then
            print(info.Name .. " BLOCKED")
            block()
        end
    end
end

local function setupPlayer(player)
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.AnimationPlayed:Connect(function(track)
                onAnimationPlayed(player, track)
            end)
        end
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Event Handlers
--UserInputService.InputBegan:Connect(function(input)
--    if input.KeyCode == TOGGLE_KEY and input.UserInputType == Enum.UserInputType.Keyboard then
--        toggleScript()
--    end
--end)

Players.PlayerAdded:Connect(setupPlayer)

-- Initial Setup
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        setupPlayer(player)
    end
end

-- Script Initialization
print("Hey, is the script working?")
task.wait(0.1)
print("Script enabled")
-- print("Toggle Keybind - V")
