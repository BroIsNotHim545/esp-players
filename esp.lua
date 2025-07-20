local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Create unique identifier for this script instance
local SCRIPT_ID = "UnstableEye_" .. tostring(math.random(1, 1000000))

-- Pre-download the custom sound
local customSoundId = nil
local hasCustomSound = false

-- Only attempt if the environment supports file functions
if writefile and readfile and isfile and getcustomasset then
    pcall(function()
        local url = "https://raw.githubusercontent.com/XQZ-official/Musics/main/Unstable_eyeSFX.mp3"
        local fileName = "hnngh! I see youuu~.mp3"
        if not isfile(fileName) then
            writefile(fileName, game:HttpGet(url))
        end
        customSoundId = getcustomasset(fileName)
        hasCustomSound = true
    end)
end

-- Remove any existing tool to prevent duplicates
for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
    if item.Name == "Unstable Eye" then
        item:Destroy()
    end
end

-- Create the tool
local tool = Instance.new("Tool")
tool.Name = "Unstable Eye"
tool.RequiresHandle = false
tool.CanBeDropped = false
tool.Parent = LocalPlayer.Backpack

-- Add tool icon for better visibility
local toolIcon = Instance.new("ImageLabel")
toolIcon.Name = "ToolIcon"
toolIcon.BackgroundTransparency = 1
toolIcon.Size = UDim2.new(0, 64, 0, 64)
toolIcon.Position = UDim2.new(0.5, -32, 0.5, -32)
toolIcon.Image = "rbxassetid://17064419705" -- Eye icon
toolIcon.Parent = tool

local COOLDOWN = 15
local cooldownEnd = 0
local originalWalkSpeed = 16 -- Default walk speed

-- Get the player's current walk speed
if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        originalWalkSpeed = humanoid.WalkSpeed
    end
end

local function getHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

local function getRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

-- Cooldown indicator management
local function manageCooldownUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Clean up any old UIs from previous instances
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui.Name == "UnstableEyeCooldown" and gui:GetAttribute("ScriptID") ~= SCRIPT_ID then
            gui:Destroy()
        end
    end
    
    -- Create new UI only if it doesn't exist
    local cooldownGui = playerGui:FindFirstChild("UnstableEyeCooldown")
    if not cooldownGui then
        cooldownGui = Instance.new("ScreenGui")
        cooldownGui.Name = "UnstableEyeCooldown"
        cooldownGui.ResetOnSpawn = false
        cooldownGui:SetAttribute("ScriptID", SCRIPT_ID)
        cooldownGui.Parent = playerGui
        
        local cooldownFrame = Instance.new("Frame")
        cooldownFrame.Name = "CooldownFrame"
        cooldownFrame.Size = UDim2.new(0, 200, 0, 40)
        cooldownFrame.Position = UDim2.new(0.5, -100, 0.9, -20)
        cooldownFrame.BackgroundTransparency = 0.7
        cooldownFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        cooldownFrame.BorderSizePixel = 0
        cooldownFrame.Parent = cooldownGui
        
        local cooldownText = Instance.new("TextLabel")
        cooldownText.Name = "CooldownText"
        cooldownText.Size = UDim2.new(1, 0, 1, 0)
        cooldownText.BackgroundTransparency = 1
        cooldownText.Text = "Unstable Eye: READY"
        cooldownText.TextColor3 = Color3.new(0.5, 1, 0.5)
        cooldownText.Font = Enum.Font.GothamBold
        cooldownText.TextSize = 18
        cooldownText.Parent = cooldownFrame
        
        local cooldownBar = Instance.new("Frame")
        cooldownBar.Name = "CooldownBar"
        cooldownBar.Size = UDim2.new(0, 0, 0, 6)
        cooldownBar.Position = UDim2.new(0, 0, 1, 0)
        cooldownBar.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
        cooldownBar.BorderSizePixel = 0
        cooldownBar.Parent = cooldownFrame
    end
end

-- Get UI elements dynamically
local function getCooldownElements()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local cooldownGui = playerGui:FindFirstChild("UnstableEyeCooldown")
    if not cooldownGui then return end
    
    local cooldownFrame = cooldownGui:FindFirstChild("CooldownFrame")
    if not cooldownFrame then return end
    
    return {
        Text = cooldownFrame:FindFirstChild("CooldownText"),
        Bar = cooldownFrame:FindFirstChild("CooldownBar")
    }
end

-- Update cooldown display
local function updateCooldown()
    local elements = getCooldownElements()
    if not elements or not elements.Text or not elements.Bar then 
        return 
    end
    
    local remaining = cooldownEnd - os.clock()
    
    if remaining > 0 then
        local progress = remaining / COOLDOWN
        elements.Bar.Size = UDim2.new(progress, 0, 0, 6)
        elements.Text.Text = string.format("Unstable Eye: %d SEC", math.ceil(remaining))
        elements.Text.TextColor3 = Color3.new(1, 0.5, 0.5)
        return true -- Still on cooldown
    else
        elements.Bar.Size = UDim2.new(0, 0, 0, 6)
        elements.Text.Text = "Unstable Eye: READY"
        elements.Text.TextColor3 = Color3.new(0.5, 1, 0.5)
        return false -- Not on cooldown
    end
end

-- Effect activation function
local function activateEffect()
    if updateCooldown() or not LocalPlayer.Character then 
        return 
    end
    
    cooldownEnd = os.clock() + COOLDOWN
    
    local character = LocalPlayer.Character
    local humanoid = getHumanoid(character)
    
    if not humanoid or humanoid.Health <= 0 then 
        return 
    end
    
    -- Store original walk speed
    originalWalkSpeed = humanoid.WalkSpeed
    
    -- Play sound effect using custom downloaded file
    local sound = Instance.new("Sound")
    sound.Volume = 1.5
    sound.Looped = false
    
    if hasCustomSound then
        sound.SoundId = customSoundId
    else
        -- Fallback to original sound
        sound.SoundId = "rbxassetid://17897783106"
    end
    
    sound.Parent = LocalPlayer:WaitForChild("PlayerGui")
    sound:Play()
    
    -- Clean up sound when finished
    sound.Ended:Connect(function()
        sound:Destroy()
    end)

    -- Movement effects - FREEZE player
    humanoid.WalkSpeed = 0
    
    -- Create visual effects
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    
    local originalFOV = Camera.FieldOfView
    local fovTween = TweenService:Create(Camera, TweenInfo.new(0.8), {FieldOfView = originalFOV - 15})
    fovTween:Play()
    
    local blurTween = TweenService:Create(blur, TweenInfo.new(0.2), {Size = 60})
    blurTween:Play()
    
    -- Player highlighting (ESP)
    local highlights = {}
    local root = getRootPart(character)
    
    if root then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetChar = player.Character
                local targetRoot = getRootPart(targetChar)
                local targetHumanoid = getHumanoid(targetChar)
                
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local dist = (targetRoot.Position - root.Position).Magnitude
                    if dist <= 250 then
                        -- Remove existing highlight if any
                        local existing = targetChar:FindFirstChild("ESPHighlight")
                        if existing then existing:Destroy() end
                        
                        -- Create highlight with new colors
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESPHighlight"
                        highlight.FillColor = Color3.new(1, 1, 0)       -- Bright yellow
                        highlight.OutlineColor = Color3.new(0.7, 0.7, 0) -- Darker yellow outline
                        highlight.FillTransparency = 1
                        highlight.OutlineTransparency = 1
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Adornee = targetChar
                        highlight.Parent = targetChar
                        
                        -- Tween highlight in
                        local tweenIn = TweenService:Create(highlight, TweenInfo.new(0.5), {
                            FillTransparency = 0.4,
                            OutlineTransparency = 0.2
                        })
                        tweenIn:Play()
                        
                        table.insert(highlights, highlight)
                    end
                end
            end
        end
    end

    -- After freeze period, boost speed
    task.wait(0.8)
    if humanoid and humanoid.Parent and humanoid.Health > 0 then
        humanoid.WalkSpeed = 27
    end
    
    -- Wait for effect duration
    task.wait(4)
    
    -- Clean up highlights
    for _, highlight in ipairs(highlights) do
        if highlight and highlight.Parent then
            local tweenOut = TweenService:Create(highlight, TweenInfo.new(0.5), {
                FillTransparency = 1,
                OutlineTransparency = 1
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                if highlight then
                    highlight:Destroy()
                end
            end)
        end
    end
    
    -- Reset visual effects
    task.wait(3)
    local blurOut = TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0})
    blurOut:Play()
    
    local fovOut = TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = originalFOV})
    fovOut:Play()
    
    blurOut.Completed:Connect(function()
        if blur then
            blur:Destroy()
        end
    end)
    
    -- Reset walkspeed after boost period (0.8s freeze + 7.5s boost = 8.3s total)
    task.wait(3.5) -- Total movement effect time: 0.8s + 7.5s = 8.3s
    if humanoid and humanoid.Parent and humanoid.Health > 0 then
        humanoid.WalkSpeed = originalWalkSpeed
    end
    
    -- Unequip the tool after activation
    if tool.Parent == LocalPlayer.Character then
        tool.Parent = LocalPlayer.Backpack
    end
end

-- Create initial UI
manageCooldownUI()

-- Activate when tool is equipped (taken in hand)
tool.Equipped:Connect(function()
    activateEffect()
end)

-- Handle character changes
LocalPlayer.CharacterAdded:Connect(function(char)
    -- Remove existing tool if any
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item.Name == "Unstable Eye" then
            item:Destroy()
        end
    end
    
    -- Recreate the tool
    local newTool = tool:Clone()
    newTool.Parent = LocalPlayer.Backpack
    
    -- Update reference
    tool = newTool
    
    -- Reconnect equipped event
    tool.Equipped:Connect(activateEffect)
    
    -- Update cooldown UI
    manageCooldownUI()
    
    -- Get new character's walk speed
    task.wait(1) -- Wait for character to fully load
    local humanoid = getHumanoid(char)
    if humanoid then
        originalWalkSpeed = humanoid.WalkSpeed
    end
end)

-- Clean up when script is destroyed
tool.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        -- Clean up cooldown UI when tool is destroyed
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local cooldownGui = playerGui:FindFirstChild("UnstableEyeCooldown")
            if cooldownGui and cooldownGui:GetAttribute("ScriptID") == SCRIPT_ID then
                cooldownGui:Destroy()
            end
        end
    end
end)

-- Update cooldown display continuously
while true do
    updateCooldown()
    task.wait(0.1)
end
