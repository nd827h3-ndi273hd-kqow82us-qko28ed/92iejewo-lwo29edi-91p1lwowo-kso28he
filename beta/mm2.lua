if _G.__ShadowX_Running then return end
_G.__ShadowX_Running = true

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local UIS        = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

local BULLET_DELAY       = 0.3
local SPAM_JUMP_VEL      = 35
local VEL_SMOOTH_SIZE    = 4
local GRAVITY            = workspace.Gravity
local origFPDH           = workspace.FallenPartsDestroyHeight
local KNIFE_SPEED_CAP    = 10
local KNIFE_SPEED_DEF    = 120
local FAKE_BOMB_Y_OFFSET = 3.2
local MAX_VELOCITY       = 80
local OWNER              = "jvpogi233j"

local INVIS_DURATION = 5
local INVIS_HEIGHT   = 400

local silentAimEnabled    = false
local manualAimEnabled    = false
local throwKnifeEnabled   = false
local grabGunEnabled      = false
local autoGrabGunEnabled  = false
local fakeBombEnabled     = false
local infiniteJumpEnabled = false
local invisibleEnabled    = false
local espMurder           = true
local espSheriff          = true
local espInnocent         = true
local espGun              = true
local currentSpeed        = 17
local currentJump         = 50
local originalJumpPower   = nil
local lockedStats         = {}

-- Invisible state
local isInvisible   = false
local invisReturnCF = nil

local roles             = {}
local stickyRoles       = {}
local visuals           = {}
local lpVisuals         = {}
local playersInRound    = {}
local outlines          = {}
local murderer          = nil
local isLpMurd          = false
local isLpSheriff       = false
local gunDropHighlights = {}
local gunDropped        = false
local roundActive       = false
local gunAvailable      = false
local timerLabel        = nil
local roundId           = 0
local knifeSpeedBuf     = {}
local fbConn            = nil
local pendingApplyRole  = {}

local fakeHRPs     = {}
local charParts    = {}
local velSmooth    = {}
local collideFrame = 0

local _guiParent
local function getGuiParent()
    if _guiParent then return _guiParent end
    local cg = game:GetService("CoreGui")
    local t  = Instance.new("Folder")
    local ok = pcall(function() t.Parent = cg end)
    if ok then t:Destroy() _guiParent = cg
    else       t:Destroy() _guiParent = lp:WaitForChild("PlayerGui") end
    return _guiParent
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:AddTheme({ Name = "Dark",            Accent = Color3.fromHex("#FF0F7B"), Dialog = Color3.fromHex("#161616"), Outline = Color3.fromHex("#FF0F7B"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#101010"), Button = Color3.fromHex("#52525b"), Icon = Color3.fromHex("#FF0F7B") })
WindUI:AddTheme({ Name = "Light",           Accent = Color3.fromHex("#0066FF"), Dialog = Color3.fromHex("#F0F0F0"), Outline = Color3.fromHex("#0066FF"), Text = Color3.fromHex("#000000"), Placeholder = Color3.fromHex("#888888"), Background = Color3.fromHex("#FFFFFF"), Button = Color3.fromHex("#DDDDDD"), Icon = Color3.fromHex("#0066FF") })
WindUI:AddTheme({ Name = "Purple Dream",    Accent = Color3.fromHex("#9B59B6"), Dialog = Color3.fromHex("#1A0A2E"), Outline = Color3.fromHex("#9B59B6"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#0D0018"), Button = Color3.fromHex("#3D1A6E"), Icon = Color3.fromHex("#9B59B6") })
WindUI:AddTheme({ Name = "Ocean Blue",      Accent = Color3.fromHex("#00BFFF"), Dialog = Color3.fromHex("#0A1628"), Outline = Color3.fromHex("#00BFFF"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#050D1A"), Button = Color3.fromHex("#0A2040"), Icon = Color3.fromHex("#00BFFF") })
WindUI:AddTheme({ Name = "Forest Green",    Accent = Color3.fromHex("#27AE60"), Dialog = Color3.fromHex("#0A1A0A"), Outline = Color3.fromHex("#27AE60"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#050D05"), Button = Color3.fromHex("#0A2A0A"), Icon = Color3.fromHex("#27AE60") })
WindUI:AddTheme({ Name = "Crimson Red",     Accent = Color3.fromHex("#E74C3C"), Dialog = Color3.fromHex("#1A0505"), Outline = Color3.fromHex("#E74C3C"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#0D0000"), Button = Color3.fromHex("#3D0A0A"), Icon = Color3.fromHex("#E74C3C") })
WindUI:AddTheme({ Name = "Sunset Orange",   Accent = Color3.fromHex("#E67E22"), Dialog = Color3.fromHex("#1A0E05"), Outline = Color3.fromHex("#E67E22"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#0D0700"), Button = Color3.fromHex("#3D1E05"), Icon = Color3.fromHex("#E67E22") })
WindUI:AddTheme({ Name = "Midnight Purple", Accent = Color3.fromHex("#6C3483"), Dialog = Color3.fromHex("#12001A"), Outline = Color3.fromHex("#6C3483"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#08000D"), Button = Color3.fromHex("#2A0040"), Icon = Color3.fromHex("#6C3483") })
WindUI:AddTheme({ Name = "Cyan Glow",       Accent = Color3.fromHex("#00FFFF"), Dialog = Color3.fromHex("#001A1A"), Outline = Color3.fromHex("#00FFFF"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#000D0D"), Button = Color3.fromHex("#003333"), Icon = Color3.fromHex("#00FFFF") })
WindUI:AddTheme({ Name = "Rose Pink",       Accent = Color3.fromHex("#FF69B4"), Dialog = Color3.fromHex("#1A0A0F"), Outline = Color3.fromHex("#FF69B4"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#0D0007"), Button = Color3.fromHex("#3D1020"), Icon = Color3.fromHex("#FF69B4") })
WindUI:AddTheme({ Name = "Golden Hour",     Accent = Color3.fromHex("#F1C40F"), Dialog = Color3.fromHex("#1A1500"), Outline = Color3.fromHex("#F1C40F"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#0D0A00"), Button = Color3.fromHex("#3D3000"), Icon = Color3.fromHex("#F1C40F") })
WindUI:AddTheme({ Name = "Neon Green",      Accent = Color3.fromHex("#39FF14"), Dialog = Color3.fromHex("#001A00"), Outline = Color3.fromHex("#39FF14"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#000D00"), Button = Color3.fromHex("#003300"), Icon = Color3.fromHex("#39FF14") })
WindUI:AddTheme({ Name = "Electric Blue",   Accent = Color3.fromHex("#0080FF"), Dialog = Color3.fromHex("#000D1A"), Outline = Color3.fromHex("#0080FF"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#00050D"), Button = Color3.fromHex("#001A40"), Icon = Color3.fromHex("#0080FF") })
WindUI:AddTheme({ Name = "Custom",          Accent = Color3.fromHex("#FF0F7B"), Dialog = Color3.fromHex("#161616"), Outline = Color3.fromHex("#FF0F7B"), Text = Color3.fromHex("#FFFFFF"), Placeholder = Color3.fromHex("#7a7a7a"), Background = Color3.fromHex("#101010"), Button = Color3.fromHex("#52525b"), Icon = Color3.fromHex("#FF0F7B") })
WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title       = "MM2 ShadowX | Official",
    Icon        = "sword",
    Author      = "by Jv3xz0",
    Folder      = "ShadowX",
    Transparent = true,
    Theme       = "Dark",
})
Window:ToggleTransparency(true)

local ConfigManager = Window.ConfigManager
local myConfig      = ConfigManager:CreateConfig("MM2")

Window:EditOpenButton({
    Title           = "ShadowX | Official",
    Icon            = "monitor",
    CornerRadius    = UDim.new(0, 16),
    StrokeThickness = 2,
    Color           = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    OnlyMobile      = false,
    Enabled         = true,
    Draggable       = true,
})

local MainTab     = Window:Tab({ Title = "Main",     Icon = "sword"    })
local PlayersTab  = Window:Tab({ Title = "Players",  Icon = "users"    })
local VisualsTab  = Window:Tab({ Title = "Visuals",  Icon = "eye"      })
local MiscTab     = Window:Tab({ Title = "Misc",     Icon = "info"     })
local CreditsTab  = Window:Tab({ Title = "Credits",  Icon = "heart"    })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

local function lockHumanoidStat(hum, prop, val)
    if lockedStats[prop] and lockedStats[prop].conn then
        lockedStats[prop].conn:Disconnect()
    end
    lockedStats[prop] = { val = val }
    hum[prop] = val
    lockedStats[prop].conn = hum:GetPropertyChangedSignal(prop):Connect(function()
        if hum[prop] ~= lockedStats[prop].val then
            hum[prop] = lockedStats[prop].val
        end
    end)
end

local function updateLockedStat(prop, newVal)
    if lockedStats[prop] then lockedStats[prop].val = newVal end
    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum[prop] = newVal end
end

local function setWalkSpeed(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        lockHumanoidStat(hum, "WalkSpeed", currentSpeed)
    else
        char.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then lockHumanoidStat(child, "WalkSpeed", currentSpeed) end
        end)
    end
end

local function setJumpPower(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        lockHumanoidStat(hum, "JumpPower", currentJump)
        originalJumpPower = hum.JumpPower
    else
        char.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                child.UseJumpPower = true
                lockHumanoidStat(child, "JumpPower", currentJump)
                originalJumpPower = child.JumpPower
            end
        end)
    end
end

local ROLE_COLOR = {
    murder  = Color3.fromRGB(255, 0, 0),
    sheriff = Color3.fromRGB(0, 100, 255),
    hero    = Color3.fromRGB(255, 255, 0),
}
local LP_COLOR = {
    norole  = Color3.fromRGB(0, 255, 80),
    sheriff = Color3.fromRGB(0, 100, 255),
}
local OUTLINE_COLOR = {
    murder  = Color3.fromRGB(255, 0, 0),
    sheriff = Color3.fromRGB(0, 100, 255),
    hero    = Color3.fromRGB(255, 255, 0),
    norole  = Color3.fromRGB(0, 255, 80),
}

local rayParams      = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local HIDE_POS2     = Vector3.new(0, -9999, 0)
local REAL_HRP_SIZE = Vector3.new(12, 3, 12)
local FAKE_HRP_SIZE = Vector3.new(2, 2, 1)

local function attachGunDropHighlight(part)
    if not espGun then return end
    if gunDropHighlights[part] then return end
    local ok, err = pcall(function()
        local color = Color3.fromRGB(0, 255, 80)
        local bb = Instance.new("BillboardGui")
        bb.Name        = "GunDropTracker"
        bb.Adornee     = part
        bb.AlwaysOnTop = true
        bb.Size        = UDim2.new(0, 5, 0, 5)
        bb.StudsOffset = Vector3.new(0, 1, 0)
        bb.Parent      = getGuiParent()
        local frame = Instance.new("Frame", bb)
        frame.ZIndex               = 10
        frame.BackgroundTransparency = 0.3
        frame.BackgroundColor3     = color
        frame.Size                 = UDim2.new(1, 0, 1, 0)
        local txt = Instance.new("TextLabel", bb)
        txt.ZIndex                 = 10
        txt.Text                   = "Gun"
        txt.BackgroundTransparency = 1
        txt.Position               = UDim2.new(0, 0, 0, -35)
        txt.Size                   = UDim2.new(1, 0, 10, 0)
        txt.Font                   = Enum.Font.ArialBold
        txt.TextSize               = 12
        txt.TextStrokeTransparency = 0.5
        txt.TextColor3             = color
        gunDropHighlights[part]    = bb
        part.AncestryChanged:Connect(function(_, parent)
            if parent then return end
            if bb and bb.Parent then bb:Destroy() end
            gunDropHighlights[part] = nil
        end)
    end)
    if not ok then warn("[ShadowX] GunDrop highlight: " .. tostring(err)) end
end

local function makeBillboard(adornee, color, name, labelText)
    local bb = Instance.new("BillboardGui")
    bb.Name          = name
    bb.Adornee       = adornee
    bb.AlwaysOnTop   = true
    bb.ExtentsOffset = Vector3.new(0, 1, 0)
    bb.Size          = UDim2.new(0, 5, 0, 5)
    bb.StudsOffset   = Vector3.new(0, 1, 0)
    bb.Parent        = getGuiParent()
    local frame = Instance.new("Frame", bb)
    frame.ZIndex               = 10
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3     = color
    frame.Size                 = UDim2.new(1, 0, 1, 0)
    local txt = Instance.new("TextLabel", bb)
    txt.ZIndex                 = 10
    txt.Text                   = labelText
    txt.BackgroundTransparency = 1
    txt.Position               = UDim2.new(0, 0, 0, -35)
    txt.Size                   = UDim2.new(1, 0, 10, 0)
    txt.Font                   = Enum.Font.ArialBold
    txt.TextSize               = 12
    txt.TextStrokeTransparency = 0.5
    txt.TextColor3             = color
    return bb
end

local function removeLpVisual(p)
    local lv = lpVisuals[p]
    lpVisuals[p] = nil
    if lv and lv.bb and lv.bb.Parent then lv.bb:Destroy() end
end

local function clearAllLpVisuals()
    for p in pairs(lpVisuals) do removeLpVisual(p) end
end

local function attachLpVisual(p, char, color)
    if not espInnocent then return end
    removeLpVisual(p)
    local head = char:FindFirstChild("Head")
    if not head then return end
    local ok, err = pcall(function()
        local bb = makeBillboard(head, color, "LpEspTracker", p.Name)
        lpVisuals[p] = { bb = bb, color = color }
        bb.AncestryChanged:Connect(function(_, parent)
            if parent ~= nil then return end
            if lpVisuals[p] and lpVisuals[p].bb == bb then
                lpVisuals[p] = nil
                task.defer(function()
                    local pChar = p.Character
                    if not pChar or not isLpMurd then return end
                    local role = roles[p]
                    if role == "murder" then return end
                    local lpColor = role == "sheriff" and LP_COLOR.sheriff or LP_COLOR.norole
                    attachLpVisual(p, pChar, lpColor)
                end)
            end
        end)
    end)
    if not ok then warn("[ShadowX] LpVisual: " .. tostring(err)) end
end

local function removeVisuals(p)
    local v = visuals[p]
    if not v then return end
    visuals[p] = nil
    if v.bb and v.bb.Parent then v.bb:Destroy() end
end

local function attachVisuals(p, char, role)
    if role == "murder" and not espMurder then return end
    if (role == "sheriff" or role == "hero") and not espSheriff then return end
    removeVisuals(p)
    local head = char:FindFirstChild("Head")
    if not head then return end
    local ok, err = pcall(function()
        local color = ROLE_COLOR[role]
        local bb = makeBillboard(head, color, "tracker", p.Name)
        visuals[p] = { bb = bb }
        bb.AncestryChanged:Connect(function(_, parent)
            if parent ~= nil then return end
            if visuals[p] and visuals[p].bb == bb then
                visuals[p] = nil
                task.defer(function()
                    local pChar = p.Character
                    local r = roles[p]
                    if pChar and r then attachVisuals(p, pChar, r) end
                end)
            end
        end)
    end)
    if not ok then warn("[ShadowX] RoleVisual: " .. tostring(err)) end
end

local function removeOutline(p)
    local hl = outlines[p]
    outlines[p] = nil
    if hl and hl.Parent then hl:Destroy() end
end

local function attachOutline(p, char, role)
    removeOutline(p)
    local ok, err = pcall(function()
        local color = OUTLINE_COLOR[role or "norole"]
        local hl = Instance.new("Highlight")
        hl.Name                = "MurderHUD_Outline"
        hl.Adornee             = char
        hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        hl.OutlineColor        = color
        hl.OutlineTransparency = 0.6
        hl.FillTransparency    = 1
        hl.Enabled             = true
        hl.Parent              = getGuiParent()
        outlines[p] = hl
        hl.AncestryChanged:Connect(function(_, parent)
            if parent ~= nil then return end
            if outlines[p] == hl then
                outlines[p] = nil
                task.defer(function()
                    local pChar = p.Character
                    if pChar and (playersInRound[p] or roles[p]) then
                        local r = roles[p]
                        if r or isLpMurd then attachOutline(p, pChar, r) end
                    end
                end)
            end
        end)
    end)
    if not ok then warn("[ShadowX] Outline: " .. tostring(err)) end
end

local function getRole(p)
    local char    = p.Character
    local bp      = p:FindFirstChild("Backpack")
    local wsModel = Workspace:FindFirstChild(p.Name)
    if not char then return stickyRoles[p] end
    local hasKnife = char:FindFirstChild("Knife")
        or (bp      and bp:FindFirstChild("Knife"))
        or (wsModel and wsModel:FindFirstChild("Knife"))
    if hasKnife then
        stickyRoles[p] = "murder"
        return "murder"
    end
    local hasGun = char:FindFirstChild("Gun")
        or (bp      and bp:FindFirstChild("Gun"))
        or (wsModel and wsModel:FindFirstChild("Gun"))
    if hasGun then
        if not roundActive and stickyRoles[p] == "hero" then return "hero" end
        local role = gunDropped and "hero" or "sheriff"
        stickyRoles[p] = role
        return role
    end
    return stickyRoles[p]
end

local function updateLpVisualFor(p)
    if not isLpMurd then removeLpVisual(p) return end
    local pChar = p.Character
    if not pChar then removeLpVisual(p) return end
    local role = roles[p]
    if role == "murder" or role == "hero" then removeLpVisual(p) return end
    local lpColor = role == "sheriff" and LP_COLOR.sheriff or LP_COLOR.norole
    local lv = lpVisuals[p]
    if not lv or lv.color ~= lpColor then attachLpVisual(p, pChar, lpColor) end
end

local applyRole

local function scheduleApplyRole(p)
    if pendingApplyRole[p] then return end
    pendingApplyRole[p] = true
    task.defer(function()
        pendingApplyRole[p] = nil
        applyRole(p)
    end)
end

local function endRound()
    if not roundActive then return end
    roundActive  = false
    gunDropped   = false
    gunAvailable = false
    murderer     = nil
    playersInRound = {}
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Anchored then hrp.Anchored = false end
    for p in pairs(outlines) do removeOutline(p) end
    local thisId = roundId
    task.delay(15, function()
        if roundId ~= thisId then return end
        for p in pairs(visuals)   do removeVisuals(p)  end
        for p in pairs(lpVisuals) do removeLpVisual(p) end
        roles       = {}
        stickyRoles = {}
    end)
end

local function checkInnocentsDead()
    if not roundActive then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == murderer then continue end
        local char = p.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then return end
    end
    endRound()
end

local function startRound()
    roundId     = roundId + 1
    roundActive = true
    gunDropped  = false
    playersInRound = {}
    playersInRound[lp] = true
    task.delay(1, function()
        if not roundActive then return end
        for _, p in ipairs(Players:GetPlayers()) do playersInRound[p] = true end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then applyRole(p) end
        end
    end)
    task.delay(3, function()
        if not roundActive then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then applyRole(p) end
        end
    end)
end

applyRole = function(p)
    local role  = getRole(p)
    local pChar = p.Character
    local old   = roles[p]
    roles[p] = role
    if role == "murder" then
        if murderer ~= p then murderer = p startRound() end
    elseif old == "murder" and murderer == p then
        murderer = nil
    end
    if role and pChar then
        local v = visuals[p]
        if not v or not v.bb or not v.bb.Parent or old ~= role then
            attachVisuals(p, pChar, role)
        end
    else
        removeVisuals(p)
    end
    if pChar and (playersInRound[p] or role ~= nil) then
        if not isLpMurd and not role then
            removeOutline(p)
        else
            local o = outlines[p]
            if not o or not o.Parent or old ~= role then
                attachOutline(p, pChar, role)
            end
        end
    else
        removeOutline(p)
    end
    if old ~= role then updateLpVisualFor(p) end
end

local function refreshLpMurd()
    local char    = lp.Character
    local bp      = lp:FindFirstChild("Backpack")
    local wsModel = Workspace:FindFirstChild(lp.Name)
    local prev    = isLpMurd
    isLpMurd = (char    and char:FindFirstChild("Knife")    ~= nil)
            or (bp      and bp:FindFirstChild("Knife")      ~= nil)
            or (wsModel and wsModel:FindFirstChild("Knife") ~= nil)
    if prev == isLpMurd then return end
    if not roundActive then startRound() end
    if isLpMurd then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then applyRole(p) updateLpVisualFor(p) end
        end
    else
        clearAllLpVisuals()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and playersInRound[p] then
                attachOutline(p, p.Character, roles[p])
            end
        end
    end
end

local function refreshLpSheriff()
    local char = lp.Character
    local bp   = lp:FindFirstChild("Backpack")
    local prev = isLpSheriff
    isLpSheriff = (char and char:FindFirstChild("Gun") ~= nil)
               or (bp   and bp:FindFirstChild("Gun")   ~= nil)
    if prev == isLpSheriff then return end
    if isLpSheriff and not roundActive then startRound() end
end

local function watchContainer(p, container, forLp)
    if forLp then
        container.ChildAdded:Connect(function(child)
            if child.Name == "Knife" then refreshLpMurd() end
        end)
        container.ChildRemoved:Connect(function(child)
            if child.Name == "Knife" then refreshLpMurd() end
        end)
    else
        container.ChildAdded:Connect(function(child)
            if child.Name == "Knife" or child.Name == "Gun" then scheduleApplyRole(p) end
        end)
        container.ChildRemoved:Connect(function(child)
            if child.Name == "Knife" or child.Name == "Gun" then scheduleApplyRole(p) end
        end)
    end
end

local function onEliminated(p)
    if not playersInRound[p] then return end
    playersInRound[p] = nil
    removeVisuals(p)
    removeLpVisual(p)
    removeOutline(p)
end

local function watchChar(p, char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function()
            onEliminated(p)
            if murderer == p then
                murderer   = nil
                gunDropped = false
                endRound()
                task.delay(15, function()
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl ~= lp then
                            stickyRoles[pl] = nil
                            applyRole(pl)
                            updateLpVisualFor(pl)
                        end
                    end
                end)
            end
        end)
    end
    char.AncestryChanged:Connect(function(_, parent)
        if parent ~= nil then return end
        onEliminated(p)
        roles[p]       = nil
        stickyRoles[p] = nil
        if murderer == p then
            murderer = nil
            endRound()
        else
            checkInnocentsDead()
        end
    end)
end

local function rebuildCharParts(p)
    local char = p.Character
    if not char then charParts[p] = nil return end
    local list = {}
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then list[#list + 1] = v end
    end
    charParts[p] = list
    char.DescendantAdded:Connect(function(v)
        if v:IsA("BasePart") then
            if v.CanCollide then v.CanCollide = false end
            local l = charParts[p]
            if l then l[#l + 1] = v end
        end
    end)
end

local function expandRealHRP(p)
    local char = p.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size       = REAL_HRP_SIZE
        hrp.CanCollide = false
    end
end

local function ensureFakeHRP(p)
    if fakeHRPs[p] and fakeHRPs[p].Parent then return end
    local ok, err = pcall(function()
        local part = Instance.new("Part")
        part.Name         = "FakeHRP_" .. p.Name
        part.Anchored     = true
        part.CanCollide   = true
        part.CanQuery     = false
        part.CanTouch     = false
        part.Transparency = 1
        part.CastShadow   = false
        part.Size         = FAKE_HRP_SIZE
        part.CFrame       = CFrame.new(HIDE_POS2)
        part.Parent       = Workspace
        fakeHRPs[p]       = part
    end)
    if not ok then warn("[ShadowX] FakeHRP create: " .. tostring(err)) end
end

local function setupPlayer(p)
    ensureFakeHRP(p)
    local bp = p:FindFirstChild("Backpack")
    if bp then
        watchContainer(p, bp, false)
    else
        p.ChildAdded:Connect(function(child)
            if child.Name == "Backpack" then watchContainer(p, child, false) end
        end)
    end
    if p.Character then
        watchChar(p, p.Character)
        watchContainer(p, p.Character, false)
        expandRealHRP(p)
        rebuildCharParts(p)
        applyRole(p)
        updateLpVisualFor(p)
    end
    p.CharacterAdded:Connect(function(char)
        stickyRoles[p] = nil
        watchChar(p, char)
        watchContainer(p, char, false)
        local bp2 = p:FindFirstChild("Backpack")
        if bp2 then watchContainer(p, bp2, false) end
        expandRealHRP(p)
        rebuildCharParts(p)
        applyRole(p)
        updateLpVisualFor(p)
        task.delay(1, function() if p.Character == char then applyRole(p) end end)
        task.delay(3, function() if p.Character == char then applyRole(p) end end)
    end)
end

local function setupLp()
    local char = lp.Character
    if char then
        setWalkSpeed(char)
        setJumpPower(char)
        watchContainer(lp, char, true)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function()
                if playersInRound[lp] then playersInRound[lp] = nil end
            end)
        end
    end
    local bp = lp:FindFirstChild("Backpack")
    if bp then watchContainer(lp, bp, true) end
    refreshLpMurd()
end

local function watchLpGun(container)
    container.ChildAdded:Connect(function(child)
        if child.Name == "Gun" then refreshLpSheriff() end
    end)
    container.ChildRemoved:Connect(function(child)
        if child.Name == "Gun" then refreshLpSheriff() end
    end)
end

do
    local char = lp.Character
    if char then watchLpGun(char) end
    local bp = lp:FindFirstChild("Backpack")
    if bp then watchLpGun(bp) end
    refreshLpSheriff()
end

local function getSmoothedVel(p)
    local buf = velSmooth[p]
    if not buf or #buf == 0 then
        local char = p.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        return hrp and hrp.AssemblyLinearVelocity or Vector3.zero
    end
    local sum = Vector3.zero
    for _, v in ipairs(buf) do sum = sum + v end
    return sum / #buf
end

local function getKnifeSpeed()
    if #knifeSpeedBuf == 0 then return KNIFE_SPEED_DEF end
    local sum = 0
    for _, v in ipairs(knifeSpeedBuf) do sum = sum + v end
    return sum / #knifeSpeedBuf
end

local function getAimPosition()
    if not murderer then return nil end
    local char = murderer.Character
    if not char then return nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local head  = char:FindFirstChild("Head")
    local hum   = char:FindFirstChildOfClass("Humanoid")
    local myChar = lp.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local rawVel  = hrp.AssemblyLinearVelocity
    local smoothV = getSmoothedVel(murderer)
    local vel     = smoothV * 0.6 + rawVel * 0.4
    local pos     = hrp.Position
    local hVel    = Vector3.new(vel.X, 0, vel.Z)
    local speed   = hVel.Magnitude
    local inAir   = hum and hum.FloorMaterial == Enum.Material.Air
                  and hum:GetState() ~= Enum.HumanoidStateType.Climbing
    local torsoOff = torso and (torso.Position - pos) or Vector3.new(0, 0.9, 0)
    local dist = (pos - myHRP.Position).Magnitude
    local dt   = BULLET_DELAY + math.clamp(dist / 400, 0, 0.1)

    if speed < 1.5 and not inAir then
        local target = torso and torso.Position or (pos + torsoOff)
        rayParams.FilterDescendantsInstances = { myChar, char }
        local dir = target - myHRP.Position
        local hit = Workspace:Raycast(myHRP.Position, dir, rayParams)
        if not hit or hit.Instance:IsDescendantOf(char) then return target end
        if head then
            local hDir = head.Position - myHRP.Position
            local hHit = Workspace:Raycast(myHRP.Position, hDir, rayParams)
            if not hHit or hHit.Instance:IsDescendantOf(char) then return head.Position end
        end
        return target
    end

    local lead = speed >= 17.8 and 4.7
              or speed >= 15.8 and 4.5
              or speed >= 11   and 2.5
              or speed > 8     and 1.5
              or speed > 4     and 1
              or speed > 2     and 0.4
              or 0

    if lead > 0 then
        local lv  = hrp.CFrame.LookVector
        local lvH = Vector3.new(lv.X, 0, lv.Z)
        if lvH.Magnitude > 0 then
            lvH = lvH.Unit
            rayParams.FilterDescendantsInstances = { myChar, char }
            local wallHit = Workspace:Raycast(pos, lvH * (lead + 1), rayParams)
            if wallHit and wallHit.Distance <= lead then
                lead = wallHit.Distance < 1 and 0 or wallHit.Distance - 1
            end
        end
    end

    local hUnit = hVel.Magnitude > 0 and hVel.Unit or Vector3.zero
    local predX = pos.X + hUnit.X * lead
    local predZ = pos.Z + hUnit.Z * lead
    local predY

    if inAir then
        local velY = vel.Y
        local yOff
        rayParams.FilterDescendantsInstances = { myChar, char }
        local floorHit = Workspace:Raycast(pos, Vector3.new(0, -5, 0), rayParams)
        if floorHit and floorHit.Distance <= 5 then
            yOff = -0.3
        elseif velY < -50 then yOff = -7
        elseif velY < -40 then yOff = -5
        elseif velY < -30 then yOff = -4
        elseif velY < -20 then yOff = -2
        elseif velY <  10 then yOff = -0.2
        elseif velY >= 25 then yOff =  0.2
        elseif velY >   5 then yOff =  1
        else                   yOff =  0
        end
        predY = pos.Y + yOff
        if lp.Name == OWNER then
            print(string.format("[ShadowX] AimGun | hSpeed=%.1f lead=%.2f velY=%.1f yOff=%.1f predY=%.1f floorDist=%s",
                speed, lead, velY, yOff, predY,
                floorHit and string.format("%.1f", floorHit.Distance) or "nil"))
        end
    else
        predY = pos.Y
        if lp.Name == OWNER then
            print(string.format("[ShadowX] AimGun | hSpeed=%.1f lead=%.2f velY=0 yOff=0 (ground)", speed, lead))
        end
    end

    local predHRP = Vector3.new(predX, predY, predZ)
    local bpNames = { "UpperTorso", "Torso", "Head", "LeftUpperArm", "Left Arm", "RightUpperArm", "Right Arm" }
    local candidates = {}
    for _, pn in ipairs(bpNames) do
        local bp = char:FindFirstChild(pn)
        if bp then candidates[#candidates + 1] = predHRP + (bp.Position - pos) end
    end
    if #candidates == 0 then candidates[1] = predHRP + torsoOff end
    rayParams.FilterDescendantsInstances = { myChar, char }
    for _, cPos in ipairs(candidates) do
        local dir = cPos - myHRP.Position
        local hit = Workspace:Raycast(myHRP.Position, dir, rayParams)
        if not hit or hit.Instance:IsDescendantOf(char) then return cPos end
    end
    return candidates[1]
end

local function getShootRemote()
    local char    = lp.Character
    local bp      = lp:FindFirstChild("Backpack")
    local wsModel = Workspace:FindFirstChild(lp.Name)
    local gun = (char    and char:FindFirstChild("Gun"))
             or (bp      and bp:FindFirstChild("Gun"))
             or (wsModel and wsModel:FindFirstChild("Gun"))
    if not gun then return nil end
    local r = gun:FindFirstChild("Shoot")
    return (r and r:IsA("RemoteEvent")) and r or nil
end

local function doFakeBomb()
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bomb = char:FindFirstChild("FakeBomb")
    if not bomb then return end
    local remote = bomb:FindFirstChild("Remote")
    if not remote or not remote:IsA("RemoteEvent") then return end
    local cf = CFrame.new(hrp.Position - Vector3.new(0, FAKE_BOMB_Y_OFFSET, 0))
    pcall(function() remote:FireServer(cf, 50) end)
end

local function getPredPos(p, hrp, myHRP, dtOverride)
    local char  = p.Character
    local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
    local head  = char and char:FindFirstChild("Head")
    local hum   = char and char:FindFirstChildOfClass("Humanoid")
    local rawVel  = hrp.AssemblyLinearVelocity
    local smoothV = getSmoothedVel(p)
    local vel     = smoothV * 0.6 + rawVel * 0.4
    local pos     = hrp.Position
    local hVel    = Vector3.new(vel.X, 0, vel.Z)
    local speed   = hVel.Magnitude
    local inAir   = (hum and hum.FloorMaterial == Enum.Material.Air)
                  and hum:GetState() ~= Enum.HumanoidStateType.Climbing
    local bodyOff = torso and (torso.Position - pos)
             or head  and (head.Position  - pos)
             or Vector3.new(0, 1.5, 0)
    local dist = (pos - myHRP.Position).Magnitude
    local dt   = dtOverride or (BULLET_DELAY + math.clamp(dist / 400, 0, 0.1))

    if speed < 1.5 and not inAir then
        return torso and torso.Position or head and head.Position or (pos + bodyOff)
    end

    local hUnit = speed > 0 and hVel.Unit or Vector3.zero
    local lead  = speed >= 17.5 and 5
               or speed >= 15.8 and 4.8
               or speed >= 11   and 2.7
               or speed > 8     and 1.7
               or speed > 4     and 1.1
               or 0

    local predX = pos.X + hUnit.X * lead
    local predZ = pos.Z + hUnit.Z * lead
    local predY

    if inAir then
        local velY = vel.Y
        if velY >= SPAM_JUMP_VEL then
            local tApex = velY / GRAVITY
            if tApex <= dt then
                local apexY  = pos.Y + velY * tApex - 0.5 * GRAVITY * tApex * tApex
                local fallDt = dt - tApex
                predY = apexY - 0.5 * GRAVITY * fallDt * fallDt
            else
                predY = pos.Y + velY * dt - 0.5 * GRAVITY * dt * dt
            end
        elseif velY < 0 then
            predY = pos.Y + velY * dt - 0.5 * GRAVITY * dt * dt
            if predY < pos.Y - 8 then predY = pos.Y - 4 end
        else
            predY = pos.Y + velY * dt - 0.5 * GRAVITY * dt * dt
        end
    else
        predY = pos.Y
    end

    return Vector3.new(predX, predY, predZ) + bodyOff
end

local function equipKnife(char, hum)
    local knife = char:FindFirstChild("Knife")
    if knife then return knife end
    local bp = lp:FindFirstChild("Backpack")
    if not bp then return nil end
    local bpKnife = bp:FindFirstChild("Knife")
    if not bpKnife then return nil end
    local ok, err = pcall(function() hum:EquipTool(bpKnife) end)
    if not ok then warn("[ShadowX] equipKnife: " .. tostring(err)) return nil end
    task.wait(0.1)
    return char:FindFirstChild("Knife")
end

local doThrowKnife
doThrowKnife = function()
    local char = lp.Character
    if not char then return end
    local myHRP = char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then warn("[ShadowX] ThrowKnife: no Humanoid") return end
    local knife = equipKnife(char, hum)
    if not knife then warn("[ShadowX] ThrowKnife: no Knife found") return end
    local knifeEvents = knife:FindFirstChild("Events")
    local throwRemote = knifeEvents and knifeEvents:FindFirstChild("KnifeThrown")
    if not (throwRemote and throwRemote:IsA("RemoteEvent")) then
        warn("[ShadowX] ThrowKnife: KnifeThrown remote not found") return
    end
    local candidates = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local hrp2 = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                local dist = (hrp2.Position - myHRP.Position).Magnitude
                candidates[#candidates + 1] = { player = p, hrp = hrp2, dist = dist }
            end
        end
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    local nearest, nearestHRP = nil, nil
    local CHECK_PARTS = { "Head", "Torso", "UpperTorso", "HumanoidRootPart", "Left Arm", "LeftUpperArm", "Right Arm", "RightUpperArm" }
    rayParams.FilterDescendantsInstances = { char }
    for _, c in ipairs(candidates) do
        local pChar = c.player.Character
        if not pChar then continue end
        local visible = 0
        for _, partName in ipairs(CHECK_PARTS) do
            local part = pChar:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                local dir    = part.Position - myHRP.Position
                local result = Workspace:Raycast(myHRP.Position, dir, rayParams)
                if not result or result.Instance:IsDescendantOf(pChar) then
                    visible = visible + 1
                end
            end
        end
        if visible > 0 then nearest = c.player nearestHRP = c.hrp break end
    end
    if not nearest and #candidates > 0 then
        nearest    = candidates[1].player
        nearestHRP = candidates[1].hrp
    end
    if not nearest then warn("[ShadowX] ThrowKnife: no target found") return end
    local kDt    = (nearestHRP.Position - myHRP.Position).Magnitude / getKnifeSpeed()
    local aimPos = getPredPos(nearest, nearestHRP, myHRP, kDt)
    local ok, err = pcall(function()
        throwRemote:FireServer(CFrame.new(myHRP.Position, aimPos), CFrame.new(aimPos))
    end)
    if not ok then warn("[ShadowX] ThrowKnife FireServer: " .. tostring(err)) end
end

local doGrabGun
doGrabGun = function()
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local savedCFrame = hrp.CFrame
    local gunDrop = nil
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "GunDrop" and desc:IsA("BasePart") then gunDrop = desc break end
    end
    if not gunDrop then warn("[ShadowX] GrabGun: no GunDrop found") return end
    local ok, err = pcall(function()
        hrp.CFrame = CFrame.new(gunDrop.Position)
        firetouchinterest(gunDrop, hrp, 0)
        hrp.CFrame = savedCFrame
    end)
    if not ok then warn("[ShadowX] GrabGun: " .. tostring(err)) end
end

local function equipGunIfNeeded()
    local myChar = lp.Character
    if not myChar then return end
    if myChar:FindFirstChild("Gun") then return end
    local bp = lp:FindFirstChild("Backpack")
    local bpGun = bp and bp:FindFirstChild("Gun")
    if not bpGun then return end
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:EquipTool(bpGun) end) end
    task.wait(0.1)
end

local function doSingleShot()
    if not murderer then
        WindUI:Notify({ Title = "Shoot Murd", Content = "No murderer detected.", Duration = 3, Icon = "x" })
        return
    end
    local myChar = lp.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    equipGunIfNeeded()
    local remote = getShootRemote()
    if not remote then
        WindUI:Notify({ Title = "Shoot Murd", Content = "No gun found.", Duration = 3, Icon = "x" })
        return
    end
    local aimPos = getAimPosition()
    if not aimPos then return end
    local ok, err = pcall(function()
        remote:FireServer(CFrame.new(myHRP.Position, aimPos), CFrame.new(aimPos))
    end)
    if not ok then warn("[ShadowX] doSingleShot: " .. tostring(err)) end
end

local function SkidFling(target)
    local char  = lp.Character
    local hum   = char and char:FindFirstChildOfClass("Humanoid")
    local hrp   = hum and hum.RootPart
    if not (char and hum and hrp) then return end
    local tChar  = target.Character
    if not tChar then return end
    local tHum   = tChar:FindFirstChildOfClass("Humanoid")
    local tHRP   = tHum and tHum.RootPart
    local tHead  = tChar:FindFirstChild("Head")
    local acc    = tChar:FindFirstChildOfClass("Accessory")
    local handle = acc and acc:FindFirstChild("Handle")
    if tHum and tHum.Sit then return end
    if not tChar:FindFirstChildWhichIsA("BasePart") then return end

    local oldCF = hrp.CFrame

    if tHead then workspace.CurrentCamera.CameraSubject = tHead
    elseif handle then workspace.CurrentCamera.CameraSubject = handle
    elseif tHum then workspace.CurrentCamera.CameraSubject = tHum
    end

    local function fPos(bp, pos, ang)
        hrp.CFrame                  = CFrame.new(bp.Position) * pos * ang
        hrp.AssemblyLinearVelocity  = Vector3.new(9e7, 9e7 * 10, 9e7)
        hrp.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function sfPart(bp)
        local t0  = tick()
        local ang = 0
        repeat
            if not (hrp and tHum) then break end
            local bpVel = bp.AssemblyLinearVelocity.Magnitude
            if bpVel < 50 then
                ang = ang + 100
                local md = tHum.MoveDirection * bpVel / 1.25
                fPos(bp, CFrame.new(0,  1.5, 0) + md, CFrame.Angles(math.rad(ang), 0, 0)) task.wait()
                fPos(bp, CFrame.new(0, -1.5, 0) + md, CFrame.Angles(math.rad(ang), 0, 0)) task.wait()
                fPos(bp, CFrame.new( 2.25,  1.5, -2.25) + md, CFrame.Angles(math.rad(ang), 0, 0)) task.wait()
                fPos(bp, CFrame.new(-2.25, -1.5,  2.25) + md, CFrame.Angles(math.rad(ang), 0, 0)) task.wait()
                fPos(bp, CFrame.new(0,  1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(ang), 0, 0)) task.wait()
                fPos(bp, CFrame.new(0, -1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(ang), 0, 0)) task.wait()
            else
                local tVel = tHRP and tHRP.AssemblyLinearVelocity.Magnitude or bpVel
                fPos(bp, CFrame.new(0,  1.5,  tHum.WalkSpeed),  CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                fPos(bp, CFrame.new(0, -1.5, -tHum.WalkSpeed),  CFrame.Angles(0, 0, 0))            task.wait()
                fPos(bp, CFrame.new(0,  1.5,  tHum.WalkSpeed),  CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                fPos(bp, CFrame.new(0,  1.5,  tVel / 1.25), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                fPos(bp, CFrame.new(0, -1.5, -tVel / 1.25), CFrame.Angles(0, 0, 0))            task.wait()
                fPos(bp, CFrame.new(0,  1.5,  tVel / 1.25), CFrame.Angles(math.rad(90), 0, 0)) task.wait()
                fPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90),  0, 0)) task.wait()
                fPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))             task.wait()
                fPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0)) task.wait()
                fPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))             task.wait()
            end
        until bp.AssemblyLinearVelocity.Magnitude > 500
            or bp.Parent ~= tChar
            or target.Parent ~= Players
            or tHum.Sit
            or hum.Health <= 0
            or tick() > t0 + 2
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local bv = Instance.new("BodyVelocity")
    bv.Name     = "FlingVel"
    bv.Parent   = hrp
    bv.Velocity = Vector3.new(9e8, 9e8, 9e8)
    bv.MaxForce = Vector3.new(1/0, 1/0, 1/0)
    bv.P        = math.huge
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if tHRP and tHead then
        if (tHRP.CFrame.p - tHead.CFrame.p).Magnitude > 5 then sfPart(tHead)
        else sfPart(tHRP) end
    elseif tHRP  then sfPart(tHRP)
    elseif tHead then sfPart(tHead)
    elseif handle then sfPart(handle)
    end

    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = hum

    repeat
        hrp.CFrame = oldCF * CFrame.new(0, 0.5, 0)
        char:PivotTo(oldCF * CFrame.new(0, 0.5, 0))
        hum:ChangeState("GettingUp")
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                v.AssemblyLinearVelocity  = Vector3.new()
                v.AssemblyAngularVelocity = Vector3.new()
            end
        end
        task.wait()
    until (hrp.Position - oldCF.p).Magnitude < 25

    workspace.FallenPartsDestroyHeight = origFPDH
end

local function doFling(name)
    local low    = name:lower()
    local target = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Name:lower():find(low, 1, true) then target = p break end
    end
    if not target then
        WindUI:Notify({ Title = "Fling", Content = "Player not found.", Duration = 3, Icon = "x" })
        return
    end
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        WindUI:Notify({ Title = "Fling", Content = "Target not loaded.", Duration = 3, Icon = "x" })
        return
    end
    SkidFling(target)
end

local function doTp(name)
    local low    = name:lower()
    local target = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Name:lower():find(low, 1, true) then target = p break end
    end
    if not target then
        WindUI:Notify({ Title = "Teleport", Content = "Player not found.", Duration = 3, Icon = "x" })
        return
    end
    local tChar = target.Character
    local tHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not tHRP then
        WindUI:Notify({ Title = "Teleport", Content = "Target has no character.", Duration = 3, Icon = "x" })
        return
    end
    local myChar = lp.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    myHRP.CFrame = tHRP.CFrame
end

local function parseTimer(text)
    if not text then return nil end
    local m, s = text:match("(%d+)m%s*(%d+)s")
    if m and s then return tonumber(m) * 60 + tonumber(s) end
    local mo = text:match("(%d+)m")
    if mo then return tonumber(mo) * 60 end
    local so = text:match("(%d+)s")
    if so then return tonumber(so) end
    local mc, sc = text:match("^(%d+):(%d+)$")
    if mc and sc then return tonumber(mc) * 60 + tonumber(sc) end
    local sec = text:match("^(%d+)$")
    if sec then return tonumber(sec) end
    return nil
end

local function watchOwnerChat(p)
    if p.Name ~= OWNER then return end
    p.Chatted:Connect(function(msg)
        if msg:lower():sub(1, 6) ~= ".kick " then return end
        local body = msg:sub(7)
        local user, reason = body:match("^(%S+)%s*(.-)%s*$")
        if not user then return end
        if not lp.Name:lower():find(user:lower(), 1, true) then return end
        lp:Kick(reason ~= "" and reason or "Kicked.")
    end)
end

local tpTarget    = ""
local flingTarget = ""

local function getPlayerOptions()
    local opts = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            opts[#opts + 1] = { Title = p.Name, Icon = "user" }
        end
    end
    return opts
end

-- ── Toggles ───────────────────────────────────────────────────────────────────

local SilentAimToggle = MainTab:Toggle({
    Title    = "Silent Aim",
    Desc     = "Auto-aims and fires at the murderer on left click",
    Icon     = "target",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        silentAimEnabled = state
        myConfig:Save()
    end
})

local ManualAimToggle = MainTab:Toggle({
    Title    = "Manual Aim",
    Desc     = "Enable the Shoot Murd button",
    Icon     = "target",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        manualAimEnabled = state
        myConfig:Save()
    end
})

local ThrowKnifeToggle = MainTab:Toggle({
    Title    = "Throw Knife",
    Desc     = "Enable the Throw Knife button",
    Icon     = "sword",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        throwKnifeEnabled = state
        myConfig:Save()
    end
})

local GrabGunToggle = MainTab:Toggle({
    Title    = "Grab Gun",
    Desc     = "Enable the Grab Gun button",
    Icon     = "zap",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        grabGunEnabled = state
        myConfig:Save()
    end
})

local AutoGrabGunToggle = MainTab:Toggle({
    Title    = "Auto Grab Gun",
    Desc     = "Automatically grabs the gun when it drops",
    Icon     = "magnet",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        autoGrabGunEnabled = state
        myConfig:Save()
    end
})

local FakeBombToggle = MainTab:Toggle({
    Title    = "Fake Bomb",
    Desc     = "Auto triggers fake bomb at jump apex",
    Icon     = "zap-off",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        fakeBombEnabled = state
        myConfig:Save()
    end
})

local InvisibleToggle = MainTab:Toggle({
    Title    = "Invisible",
    Desc     = "Enable the Invisible button",
    Icon     = "eye-off",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        invisibleEnabled = state
        myConfig:Save()
    end
})

-- ── Native Action Buttons (top-right, red, mobile-friendly) ───────────────────

local function makeInvisBar(rem, tot)
    return string.rep("█", rem) .. string.rep("░", tot - rem)
end

local invisNativeLbl = nil

local function setInvisBtn(title)
    if invisNativeLbl then invisNativeLbl.Text = title end
end

local function resetInvisBtn()
    setInvisBtn(string.format("👁  Invisible  %s", makeInvisBar(INVIS_DURATION, INVIS_DURATION)))
end

-- GUI setup
local nGui = Instance.new("ScreenGui")
nGui.Name            = "ShadowX_Btns"
nGui.ResetOnSpawn    = false
nGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
nGui.IgnoreGuiInset  = true
nGui.Parent          = getGuiParent()

local nFrame = Instance.new("Frame")
nFrame.Name                   = "BtnContainer"
nFrame.BackgroundTransparency = 1
nFrame.AnchorPoint            = Vector2.new(1, 0)
nFrame.Position               = UDim2.new(1, -6, 0, 52)
nFrame.Size                   = UDim2.new(0, 124, 1, 0)
nFrame.Parent                 = nGui

local nLayout = Instance.new("UIListLayout")
nLayout.SortOrder           = Enum.SortOrder.LayoutOrder
nLayout.Padding             = UDim.new(0, 4)
nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
nLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
nLayout.Parent              = nFrame

local BTN_W = 118
local BTN_H = 28

local C_IDLE  = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 0, 22)),
})
local C_PRESS = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 115)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 25, 55)),
})

local function makeNativeBtn(text, cb)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, BTN_W, 0, BTN_H)
    btn.BackgroundColor3 = Color3.fromRGB(170, 0, 25)
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.BorderSizePixel  = 0
    btn.Parent           = nFrame

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    local grad = Instance.new("UIGradient", btn)
    grad.Color    = C_IDLE
    grad.Rotation = 100

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color        = Color3.fromRGB(255, 80, 100)
    stroke.Thickness    = 1
    stroke.Transparency = 0.4

    local shadow = Instance.new("ImageLabel", btn)
    shadow.Size                  = UDim2.new(1, 12, 1, 12)
    shadow.Position              = UDim2.new(0, -6, 0, 5)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex                = 0
    shadow.Image                 = "rbxassetid://6015897843"
    shadow.ImageColor3           = Color3.fromRGB(200, 0, 30)
    shadow.ImageTransparency     = 0.6
    shadow.ScaleType             = Enum.ScaleType.Slice
    shadow.SliceCenter           = Rect.new(49, 49, 450, 450)

    local sc = Instance.new("UIScale", btn)
    sc.Scale = 1

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size                   = UDim2.new(1, -8, 1, 0)
    lbl.Position               = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = text
    lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
    lbl.TextSize               = 11
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextTruncate           = Enum.TextTruncate.AtEnd
    lbl.TextXAlignment         = Enum.TextXAlignment.Center
    lbl.ZIndex                 = 2

    local tweenDown = TweenService:Create(sc,
        TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Scale = 0.89 })
    local tweenUp = TweenService:Create(sc,
        TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Scale = 1.0 })

    btn.MouseButton1Down:Connect(function()
        tweenDown:Play()
        grad.Color = C_PRESS
    end)

    local function onRelease()
        tweenUp:Play()
        grad.Color = C_IDLE
        task.spawn(cb)
    end

    btn.MouseButton1Up:Connect(onRelease)
    btn.TouchTap:Connect(onRelease)

    return btn, lbl
end

-- Shoot Murd
makeNativeBtn("🎯  Shoot Murd", function()
    if not manualAimEnabled then
        WindUI:Notify({ Title = "Shoot Murd", Content = "Enable Manual Aim first.", Duration = 3, Icon = "x" })
        return
    end
    WindUI:Notify({ Title = "Shoot Murd", Content = "Firing...", Duration = 1, Icon = "zap" })
    local ok, err = pcall(doSingleShot)
    if not ok then warn("[ShadowX] ShootMurd: " .. tostring(err)) end
end)

-- Throw Knife
makeNativeBtn("🗡  Throw Knife", function()
    if not throwKnifeEnabled then
        WindUI:Notify({ Title = "Throw Knife", Content = "Enable Throw Knife first.", Duration = 3, Icon = "x" })
        return
    end
    if not isLpMurd then
        WindUI:Notify({ Title = "Throw Knife", Content = "You are not the Murderer.", Duration = 3, Icon = "x" })
        return
    end
    WindUI:Notify({ Title = "Throw Knife", Content = "Throwing...", Duration = 1, Icon = "zap" })
    local ok, err = pcall(doThrowKnife)
    if not ok then warn("[ShadowX] ThrowKnife: " .. tostring(err)) end
end)

-- Grab Gun
makeNativeBtn("⚡  Grab Gun", function()
    if not grabGunEnabled then
        WindUI:Notify({ Title = "Grab Gun", Content = "Enable Grab Gun first.", Duration = 3, Icon = "x" })
        return
    end
    WindUI:Notify({ Title = "Grab Gun", Content = "Grabbing...", Duration = 1, Icon = "zap" })
    local ok, err = pcall(doGrabGun)
    if not ok then warn("[ShadowX] GrabGun: " .. tostring(err)) end
end)

-- Invisible (countdown animation on label)
local _, _iLbl = makeNativeBtn(
    string.format("👁  Invisible  %s", makeInvisBar(INVIS_DURATION, INVIS_DURATION)),
    function()
        if not invisibleEnabled then
            WindUI:Notify({ Title = "Invisible", Content = "Enable Invisible toggle first.", Duration = 3, Icon = "x" })
            return
        end
        if isInvisible then
            WindUI:Notify({ Title = "Invisible", Content = "Already active.", Duration = 2, Icon = "clock" })
            return
        end
        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            WindUI:Notify({ Title = "Invisible", Content = "No character found.", Duration = 3, Icon = "x" })
            return
        end
        invisReturnCF               = hrp.CFrame
        hrp.CFrame                  = CFrame.new(hrp.Position + Vector3.new(0, INVIS_HEIGHT, 0))
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        isInvisible = true
        WindUI:Notify({ Title = "Invisible", Content = string.format("Vanished! Back in %ds...", INVIS_DURATION), Duration = INVIS_DURATION, Icon = "eye-off" })
        task.spawn(function()
            for i = INVIS_DURATION, 1, -1 do
                setInvisBtn(string.format("👁  [%ds]  %s", i, makeInvisBar(i, INVIS_DURATION)))
                task.wait(1)
            end
            local retChar = lp.Character
            local retHRP  = retChar and retChar:FindFirstChild("HumanoidRootPart")
            if retHRP and invisReturnCF then
                retHRP.CFrame                  = invisReturnCF
                retHRP.AssemblyLinearVelocity  = Vector3.zero
                retHRP.AssemblyAngularVelocity = Vector3.zero
            end
            isInvisible   = false
            invisReturnCF = nil
            resetInvisBtn()
            WindUI:Notify({ Title = "Invisible", Content = "Back to normal.", Duration = 2, Icon = "eye" })
        end)
    end
)
invisNativeLbl = _iLbl

-- ── Players Tab ───────────────────────────────────────────────────────────────

local WalkSpeedSlider = PlayersTab:Slider({
    Title = "Walk Speed",
    Desc  = "Adjust your walk speed",
    Step  = 1,
    Value = { Min = 0, Max = 100, Default = 17 },
    Callback = function(value)
        currentSpeed = value
        updateLockedStat("WalkSpeed", value)
    end
})

local JumpPowerSlider = PlayersTab:Slider({
    Title = "Jump Power",
    Desc  = "Adjust your jump power",
    Step  = 1,
    Value = { Min = 0, Max = 200, Default = 50 },
    Callback = function(value)
        currentJump       = value
        originalJumpPower = value
        updateLockedStat("JumpPower", value)
    end
})

local TpDropdown = PlayersTab:Dropdown({
    Title    = "Teleport Target",
    Desc     = "Select a player to teleport to",
    Values   = getPlayerOptions(),
    Value    = "",
    Callback = function(option)
        tpTarget = option.Title
    end
})

PlayersTab:Button({
    Title    = "Teleport",
    Desc     = "Teleport to the selected player",
    Callback = function()
        if tpTarget == "" then
            WindUI:Notify({ Title = "Teleport", Content = "Select a player first.", Duration = 3, Icon = "x" })
            return
        end
        local ok, err = pcall(doTp, tpTarget)
        if not ok then warn("[ShadowX] Tp: " .. tostring(err)) end
    end
})

local FlingDropdown = PlayersTab:Dropdown({
    Title    = "Fling Target",
    Desc     = "Select a player to fling",
    Values   = getPlayerOptions(),
    Value    = "",
    Callback = function(option)
        flingTarget = option.Title
    end
})

PlayersTab:Button({
    Title    = "Fling",
    Desc     = "Fling the selected player",
    Callback = function()
        if flingTarget == "" then
            WindUI:Notify({ Title = "Fling", Content = "Select a player first.", Duration = 3, Icon = "x" })
            return
        end
        local ok, err = pcall(doFling, flingTarget)
        if not ok then warn("[ShadowX] Fling: " .. tostring(err)) end
    end
})

local InfiniteJumpToggle = PlayersTab:Toggle({
    Title    = "Infinite Jump",
    Desc     = "Jump infinitely in mid-air",
    Icon     = "arrow-up",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        myConfig:Save()
    end
})

-- ── Visuals Tab ───────────────────────────────────────────────────────────────

local MurderEspToggle = VisualsTab:Toggle({
    Title    = "Murder ESP",
    Desc     = "Show ESP for the Murderer",
    Icon     = "eye",
    Type     = "Checkbox",
    Value    = true,
    Callback = function(state)
        espMurder = state
        if not state then
            local toRemove = {}
            for p in pairs(visuals) do
                if roles[p] == "murder" then toRemove[#toRemove + 1] = p end
            end
            for _, p in ipairs(toRemove) do removeVisuals(p) end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and roles[p] == "murder" and p.Character then
                    attachVisuals(p, p.Character, "murder")
                end
            end
        end
        myConfig:Save()
    end
})

local SheriffEspToggle = VisualsTab:Toggle({
    Title    = "Sheriff ESP",
    Desc     = "Show ESP for Sheriff and Hero",
    Icon     = "eye",
    Type     = "Checkbox",
    Value    = true,
    Callback = function(state)
        espSheriff = state
        if not state then
            local toRemove = {}
            for p in pairs(visuals) do
                local r = roles[p]
                if r == "sheriff" or r == "hero" then toRemove[#toRemove + 1] = p end
            end
            for _, p in ipairs(toRemove) do removeVisuals(p) end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp then
                    local r = roles[p]
                    if (r == "sheriff" or r == "hero") and p.Character then
                        attachVisuals(p, p.Character, r)
                    end
                end
            end
        end
        myConfig:Save()
    end
})

local InnocentEspToggle = VisualsTab:Toggle({
    Title    = "Innocent ESP",
    Desc     = "Show green ESP on innocents (Murderer view)",
    Icon     = "eye",
    Type     = "Checkbox",
    Value    = true,
    Callback = function(state)
        espInnocent = state
        if not state then
            clearAllLpVisuals()
        else
            if isLpMurd then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp then updateLpVisualFor(p) end
                end
            end
        end
        myConfig:Save()
    end
})

local GunEspToggle = VisualsTab:Toggle({
    Title    = "Gun ESP",
    Desc     = "Show ESP on the dropped gun",
    Icon     = "eye",
    Type     = "Checkbox",
    Value    = true,
    Callback = function(state)
        espGun = state
        if not state then
            for _, bb in pairs(gunDropHighlights) do
                if bb and bb.Parent then bb:Destroy() end
            end
            gunDropHighlights = {}
        else
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name == "GunDrop" and desc:IsA("BasePart") then
                    attachGunDropHighlight(desc)
                end
            end
        end
        myConfig:Save()
    end
})

-- ── Misc Tab ──────────────────────────────────────────────────────────────────

local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")

local function getServers(cursor)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
        game.PlaceId
    )
    if cursor then url = url .. "&cursor=" .. cursor end
    local ok, res = pcall(function() return game:HttpGet(url) end)
    return ok and HttpService:JSONDecode(res) or nil
end

local function getAllServers()
    local servers, cursor, attempts = {}, nil, 0
    repeat
        local data = getServers(cursor)
        if data and data.data then
            for _, s in pairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(servers, s)
                end
            end
            cursor   = data.nextPageCursor
            attempts = attempts + 1
            task.wait(0.3)
        else break end
    until not cursor or attempts >= 10
    return servers
end

local function hopToSmallest()
    WindUI:Notify({ Title = "Server Hop", Content = "Finding smallest server...", Duration = 3, Icon = "search" })
    task.spawn(function()
        local servers = getAllServers()
        if #servers == 0 then
            WindUI:Notify({ Title = "Server Hop", Content = "No servers found.", Duration = 3, Icon = "x" })
            return
        end
        table.sort(servers, function(a, b) return a.playing < b.playing end)
        local t = servers[1]
        WindUI:Notify({ Title = "Server Hop", Content = string.format("Hopping to %d/%d players...", t.playing, t.maxPlayers), Duration = 3, Icon = "zap" })
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, t.id, lp)
    end)
end

local function hopToRandom()
    WindUI:Notify({ Title = "Server Hop", Content = "Finding random server...", Duration = 3, Icon = "search" })
    task.spawn(function()
        local servers = getAllServers()
        if #servers == 0 then
            WindUI:Notify({ Title = "Server Hop", Content = "No servers found.", Duration = 3, Icon = "x" })
            return
        end
        local t = servers[math.random(1, #servers)]
        WindUI:Notify({ Title = "Server Hop", Content = string.format("Hopping to %d/%d players...", t.playing, t.maxPlayers), Duration = 3, Icon = "zap" })
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, t.id, lp)
    end)
end

local function getGameName()
    local ok, res = pcall(function()
        local url  = string.format("https://games.roblox.com/v1/games?universeIds=%d", game.PlaceId)
        local data = HttpService:JSONDecode(game:HttpGet(url))
        return data and data.data and data.data[1] and data.data[1].name or "Unknown"
    end)
    return ok and res or "Unknown"
end

local gameName   = getGameName()
local ServerInfo = MiscTab:Paragraph({
    Title         = "Server Information",
    Desc          = string.format("Game: %s\nPlace ID: %d\nJob ID: %s\nPlayers: %d/%d",
        gameName, game.PlaceId, game.JobId, #Players:GetPlayers(), Players.MaxPlayers),
    Color         = "Blue",
    Thumbnail     = "rbxassetid://74135635728836",
    ThumbnailSize = 100,
})

task.spawn(function()
    while true do
        task.wait(5)
        if ServerInfo then
            ServerInfo:Set({
                Desc = string.format("Game: %s\nPlace ID: %d\nJob ID: %s\nPlayers: %d/%d",
                    gameName, game.PlaceId, game.JobId, #Players:GetPlayers(), Players.MaxPlayers)
            })
        end
    end
end)

MiscTab:Button({
    Title    = "Hop Small Server",
    Desc     = "Teleport to the server with the least players",
    Callback = hopToSmallest,
})

MiscTab:Button({
    Title    = "Server Hop",
    Desc     = "Teleport to a random available server",
    Callback = hopToRandom,
})

-- ── Credits Tab ───────────────────────────────────────────────────────────────

CreditsTab:Paragraph({
    Title         = "ShadowX | Official",
    Desc          = "Made by Jv3xz0. Join our Discord to stay updated with the latest features.",
    Color         = "Red",
    Thumbnail     = "rbxassetid://74135635728836",
    ThumbnailSize = 140,
    Buttons = {
        {
            Icon     = "users",
            Title    = "Discord",
            Callback = function()
                setclipboard("https://discord.gg/pk6WbGqZ5X")
                WindUI:Notify({ Title = "Copied!", Content = "Discord invite copied to clipboard.", Duration = 3, Icon = "check" })
            end,
        }
    }
})

-- ── Settings Tab ──────────────────────────────────────────────────────────────

local ThemeDropdown = SettingsTab:Dropdown({
    Title  = "Theme Selector",
    Values = {
        { Title = "Dark",            Icon = "moon"           },
        { Title = "Light",           Icon = "sun"            },
        { Title = "Purple Dream",    Icon = "sparkles"       },
        { Title = "Ocean Blue",      Icon = "waves"          },
        { Title = "Forest Green",    Icon = "tree-deciduous" },
        { Title = "Crimson Red",     Icon = "flame"          },
        { Title = "Sunset Orange",   Icon = "sunset"         },
        { Title = "Midnight Purple", Icon = "moon-star"      },
        { Title = "Cyan Glow",       Icon = "zap"            },
        { Title = "Rose Pink",       Icon = "heart"          },
        { Title = "Golden Hour",     Icon = "sun"            },
        { Title = "Neon Green",      Icon = "zap-off"        },
        { Title = "Electric Blue",   Icon = "sparkle"        },
        { Title = "Custom",          Icon = "palette"        },
    },
    Value    = "Dark",
    Callback = function(option) WindUI:SetTheme(option.Title) end
})

local ThemeColor = SettingsTab:Colorpicker({
    Title    = "Custom Theme Color",
    Desc     = "Set a custom accent color",
    Default  = Color3.fromRGB(255, 15, 123),
    Callback = function(color)
        WindUI:AddTheme({
            Name        = "Custom",
            Accent      = color,
            Dialog      = Color3.fromHex("#161616"),
            Outline     = color,
            Text        = Color3.fromHex("#FFFFFF"),
            Placeholder = Color3.fromHex("#7a7a7a"),
            Background  = Color3.fromHex("#101010"),
            Button      = Color3.fromHex("#52525b"),
            Icon        = color,
        })
        WindUI:SetTheme("Custom")
    end
})

-- ── Config Registration ────────────────────────────────────────────────────────

myConfig:Register("SilentAim",    SilentAimToggle)
myConfig:Register("ManualAim",    ManualAimToggle)
myConfig:Register("ThrowKnife",   ThrowKnifeToggle)
myConfig:Register("GrabGun",      GrabGunToggle)
myConfig:Register("AutoGrabGun",  AutoGrabGunToggle)
myConfig:Register("FakeBomb",     FakeBombToggle)
myConfig:Register("Invisible",    InvisibleToggle)
myConfig:Register("InfiniteJump", InfiniteJumpToggle)
myConfig:Register("MurderEsp",    MurderEspToggle)
myConfig:Register("SheriffEsp",   SheriffEspToggle)
myConfig:Register("InnocentEsp",  InnocentEspToggle)
myConfig:Register("GunEsp",       GunEspToggle)
myConfig:Register("WalkSpeed",    WalkSpeedSlider)
myConfig:Register("JumpPower",    JumpPowerSlider)
myConfig:Register("TpTarget",     TpDropdown)
myConfig:Register("FlingTarget",  FlingDropdown)
myConfig:Register("Theme",        ThemeDropdown)
myConfig:Register("ThemeColor",   ThemeColor)

-- ── Input / UIS ────────────────────────────────────────────────────────────────

local touchStartPos = nil

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        touchStartPos = input.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if not silentAimEnabled then return end
    local isFire = input.UserInputType == Enum.UserInputType.MouseButton1
               or (input.UserInputType == Enum.UserInputType.Touch
                   and not UIS:GetFocusedTextBox()
                   and input.Position.X > (workspace.CurrentCamera.ViewportSize.X * 0.35))
    if not isFire then return end
    if not touchStartPos then return end
    local delta = (Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(touchStartPos.X, touchStartPos.Y)).Magnitude
    touchStartPos = nil
    if delta > 12 then return end
    local myChar = lp.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    if not murderer then return end
    local wsModel = Workspace:FindFirstChild(lp.Name)
    if not wsModel or not wsModel:FindFirstChild("Gun") then return end
    local aimPos = getAimPosition()
    if not aimPos then return end
    local remote = getShootRemote()
    if not remote then return end
    local ok, err = pcall(function()
        remote:FireServer(CFrame.new(myHRP.Position, aimPos), CFrame.new(aimPos))
    end)
    if not ok then warn("[ShadowX] SilentAim shoot: " .. tostring(err)) end
end)

UIS.JumpRequest:Connect(function()
    local char = lp.Character
    if not char then return end

    if infiniteJumpEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and originalJumpPower then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hum.JumpPower = originalJumpPower
        end
    end

    if fakeBombEnabled and char:FindFirstChild("FakeBomb") then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if fbConn then fbConn:Disconnect() fbConn = nil end
        local t0 = tick()
        task.defer(function()
            if lp.Character ~= char then return end
            fbConn = RunService.Heartbeat:Connect(function()
                if lp.Character ~= char or tick() - t0 > 3 then
                    fbConn:Disconnect() fbConn = nil return
                end
                local velY = hrp.AssemblyLinearVelocity.Y
                if velY > 5 then
                    fbConn:Disconnect() fbConn = nil
                    task.delay(velY / GRAVITY, function()
                        if lp.Character == char then doFakeBomb() end
                    end)
                end
            end)
        end)
    end
end)

lp.ChildAdded:Connect(function(child)
    if child.Name == "Backpack" then
        watchContainer(lp, child, true)
        watchLpGun(child)
    end
end)

lp.CharacterAdded:Connect(function(char)
    setWalkSpeed(char)
    setJumpPower(char)
    watchContainer(lp, char, true)
    watchLpGun(char)
    refreshLpMurd()
    if isInvisible then
        isInvisible   = false
        invisReturnCF = nil
        resetInvisBtn()
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function()
            if playersInRound[lp] then playersInRound[lp] = nil end
            if isInvisible then
                isInvisible   = false
                invisReturnCF = nil
                resetInvisBtn()
            end
        end)
    end
end)

Players.PlayerAdded:Connect(function(p)
    if p == lp then return end
    setupPlayer(p)
    watchOwnerChat(p)
    local opts = getPlayerOptions()
    TpDropdown:Refresh(opts)
    FlingDropdown:Refresh(opts)
end)

Players.PlayerRemoving:Connect(function(p)
    playersInRound[p]   = nil
    roles[p]            = nil
    stickyRoles[p]      = nil
    velSmooth[p]        = nil
    pendingApplyRole[p] = nil
    removeLpVisual(p)
    removeVisuals(p)
    removeOutline(p)
    if murderer == p then
        murderer = nil
        endRound()
    else
        checkInnocentsDead()
    end
    local fake = fakeHRPs[p]
    if fake and fake.Parent then fake:Destroy() end
    fakeHRPs[p]  = nil
    charParts[p] = nil
    if tpTarget    == p.Name then tpTarget    = "" end
    if flingTarget == p.Name then flingTarget = "" end
    local opts = getPlayerOptions()
    TpDropdown:Refresh(opts)
    FlingDropdown:Refresh(opts)
end)

Workspace.DescendantAdded:Connect(function(desc)
    if desc.Name == "GunDrop" and desc:IsA("BasePart") then
        gunDropped   = true
        gunAvailable = true
        task.defer(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp then applyRole(p) end
            end
        end)
        if autoGrabGunEnabled and not isLpMurd and not isLpSheriff and (playersInRound[lp] ~= nil) then
            task.defer(function()
                local ok2, err2 = pcall(doGrabGun)
                if not ok2 then warn("[ShadowX] GunDrop auto-grab: " .. tostring(err2)) end
            end)
        end
        local ok, err = pcall(attachGunDropHighlight, desc)
        if not ok then warn("[ShadowX] GunDrop DescendantAdded: " .. tostring(err)) end
        return
    end
    if desc:IsA("BasePart") and desc.Name == "Knife" then
        local par = desc.Parent
        if par and par:IsA("Model") and Players:GetPlayerFromCharacter(par) then return end
        task.defer(function()
            task.wait(0.05)
            if not desc.Parent then return end
            local spd = desc.AssemblyLinearVelocity.Magnitude
            if spd < 5 then return end
            knifeSpeedBuf[#knifeSpeedBuf + 1] = spd
            if #knifeSpeedBuf > KNIFE_SPEED_CAP then table.remove(knifeSpeedBuf, 1) end
        end)
    end
end)

for _, desc in ipairs(Workspace:GetDescendants()) do
    if desc.Name == "GunDrop" then
        gunDropped   = true
        gunAvailable = true
        local ok, err = pcall(attachGunDropHighlight, desc)
        if not ok then warn("[ShadowX] GunDrop startup: " .. tostring(err)) end
    end
end

Workspace.DescendantRemoving:Connect(function(desc)
    if desc.Name ~= "GunDrop" then return end
    gunAvailable = false
end)

for _, p in ipairs(Players:GetPlayers()) do
    watchOwnerChat(p)
    if p ~= lp then setupPlayer(p) end
end

setupLp()

task.defer(function()
    local anyRole = false
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and getRole(p) then anyRole = true end
    end
    if not anyRole then return end
    if not roundActive then
        roundId     = roundId + 1
        roundActive = true
    end
    refreshLpMurd()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then applyRole(p) end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        playersInRound[p] = true
    end
    refreshLpSheriff()
end)

RunService.Heartbeat:Connect(function()
    collideFrame = collideFrame + 1
    local doCollide = collideFrame % 3 == 0
    for p, fakePart in pairs(fakeHRPs) do
        local char = p.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not velSmooth[p] then velSmooth[p] = {} end
            local buf = velSmooth[p]
            buf[#buf + 1] = hrp.AssemblyLinearVelocity
            if #buf > VEL_SMOOTH_SIZE then table.remove(buf, 1) end
            fakePart.CFrame = hrp.CFrame
            if hrp.Size ~= REAL_HRP_SIZE then
                hrp.Size       = REAL_HRP_SIZE
                hrp.CanCollide = false
            end
            if doCollide then
                local list = charParts[p]
                if list then
                    for i = 1, #list do
                        local v = list[i]
                        if v and v.Parent and v.CanCollide then v.CanCollide = false end
                    end
                end
            end
        else
            fakePart.CFrame = CFrame.new(HIDE_POS2)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    if vel.Magnitude > MAX_VELOCITY then
        hrp.AssemblyLinearVelocity = vel.Unit * MAX_VELOCITY
    end
end)

task.spawn(function()
    local ok, result = pcall(function()
        return Workspace:WaitForChild("RoundTimerPart", 10)
            :WaitForChild("SurfaceGui", 5)
            :WaitForChild("Timer", 5)
    end)
    if not ok or not result then warn("[ShadowX] RoundTimer: not found") return end
    timerLabel = result
    timerLabel:GetPropertyChangedSignal("Active"):Connect(function()
        if timerLabel.Active then
            if not roundActive then startRound() end
        else
            endRound()
        end
    end)
    local t      = parseTimer(timerLabel.Text)
    local atEdge = t ~= nil and t <= 2
    if timerLabel.Active then
        if not atEdge and not roundActive then startRound()
        elseif not roundActive then
            roundActive = true
            roundId     = roundId + 1
        end
        task.defer(function()
            for _, p in ipairs(Players:GetPlayers()) do playersInRound[p] = true end
            refreshLpMurd()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp then applyRole(p) end
            end
        end)
    elseif roundActive then
        endRound()
    end
end)

Window:Tag({
    Title  = "V2.120.12",
    Icon   = "github",
    Color  = Color3.fromHex("#30ff6a"),
    Radius = 0,
})

WindUI:Popup({
    Title   = "MM2 ShadowX V2.120.12",
    Icon    = "sword",
    Content = "V2.120.12 — Native action buttons (top-right), Kill All removed.",
    Buttons = {
        {
            Title    = "Close",
            Callback = function() end,
            Variant  = "Tertiary",
        },
        {
            Title    = "Join Discord",
            Icon     = "users",
            Callback = function()
                setclipboard("https://discord.gg/pk6WbGqZ5X")
                WindUI:Notify({ Title = "Copied!", Content = "Discord invite copied to clipboard.", Duration = 3, Icon = "check" })
            end,
            Variant = "Primary",
        }
    }
})

myConfig:Load()
