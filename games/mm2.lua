-- LocalScript: StarterPlayerScripts
print("V2.106.232")
if _G.__MurderHUD_Running then return end
_G.__MurderHUD_Running = true

local BULLET_DELAY    = 0.3
local SPAM_JUMP_VEL   = 35
local VEL_SMOOTH_SIZE  = 4
local lpLastActiveTime  = 0
local IDLE_KILLALL_DELAY = 30
local WALK_LEAD_THROW = 1.5
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local GRAVITY         = workspace.Gravity

local lp = Players.LocalPlayer

-- ── State ─────────────────────────────────────────────────────────────────────
local roles             = {}
local stickyRoles       = {}
local visuals           = {}
local lpVisuals         = {}
local playersInRound    = {}
local outlines          = {}
local murderer          = nil
local isLpMurd          = false
local isLpSheriff = false
local gunDropHighlights = {}
local gunDropped      = false
local roundActive       = false
local murderGui = nil
local innocentGui = nil
local helpGui = nil
local autofarmActive = false
local timerLabel     = nil
local roundId = 0
local function isInLobby(char)
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local lobbyParts = Workspace:FindFirstChild("RegularLobby")
        and Workspace.RegularLobby:FindFirstChild("MainLobby")
        and Workspace.RegularLobby.MainLobby:FindFirstChild("Parts")
    if not lobbyParts then return false end
    local ok, cf, size = pcall(function() return lobbyParts:GetBoundingBox() end)
    if not ok then return false end
    local localPos = cf:PointToObjectSpace(hrp.Position)
    local half = size / 2
    return math.abs(localPos.X) <= half.X
       and math.abs(localPos.Y) <= half.Y
       and math.abs(localPos.Z) <= half.Z
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

local rayParams      = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local HIDE_POS2 = Vector3.new(0, -9999, 0)
local REAL_HRP_SIZE = Vector3.new(14, 4, 14)
local FAKE_HRP_SIZE = Vector3.new(2, 2, 1)

local fakeHRPs  = {}
local charParts = {}
local velSmooth = {}

-- ── Gun drop ESP ──────────────────────────────────────────────────────────────
local function attachGunDropHighlight(part)
    if gunDropHighlights[part] then return end
    local ok, err = pcall(function()
        local color = Color3.fromRGB(0, 255, 80)
        local bb = Instance.new("BillboardGui")
        bb.Name        = "GunDropTracker"
        bb.Adornee     = part
        bb.AlwaysOnTop = true
        bb.Size        = UDim2.new(0, 5, 0, 5)
        bb.StudsOffset = Vector3.new(0, 1, 0)
        bb.Parent      = game:GetService("CoreGui")
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
    if not ok then warn("[MurderHUD] GunDrop highlight: " .. tostring(err)) end
end

-- ── Walk / Jump ───────────────────────────────────────────────────────────────
local function setWalkSpeed(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 19
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if hum.WalkSpeed ~= 19 then hum.WalkSpeed = 19 end
        end)
    else
        char.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                child.WalkSpeed = 19
                child:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if child.WalkSpeed ~= 19 then child.WalkSpeed = 19 end
                end)
            end
        end)
    end
end

local function setJumpPower(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = 55
        hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if hum.JumpPower ~= 55 then hum.JumpPower = 55 end
        end)
    else
        char.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                child.UseJumpPower = true
                child.JumpPower = 55
                child:GetPropertyChangedSignal("JumpPower"):Connect(function()
                    if child.JumpPower ~= 55 then child.JumpPower = 55 end
                end)
            end
        end)
    end
end

-- ── LP murderer ESP ───────────────────────────────────────────────────────────
local function removeLpVisual(p)
    local lv = lpVisuals[p]
    lpVisuals[p] = nil
    if lv and lv.bb and lv.bb.Parent then lv.bb:Destroy() end
end

local function clearAllLpVisuals()
    for p in pairs(lpVisuals) do removeLpVisual(p) end
end

local function attachLpVisual(p, char, color)
    removeLpVisual(p)
    local head = char:FindFirstChild("Head")
    if not head then return end
    local ok, err = pcall(function()
        local bb = Instance.new("BillboardGui")
        bb.Name          = "LpEspTracker"
        bb.Adornee       = head
        bb.AlwaysOnTop   = true
        bb.ExtentsOffset = Vector3.new(0, 1, 0)
        bb.Size          = UDim2.new(0, 5, 0, 5)
        bb.StudsOffset   = Vector3.new(0, 1, 0)
        bb.Parent        = game:GetService("CoreGui")
        local frame = Instance.new("Frame", bb)
        frame.ZIndex               = 10
        frame.BackgroundTransparency = 0.3
        frame.BackgroundColor3     = color
        frame.Size                 = UDim2.new(1, 0, 1, 0)
        local txt = Instance.new("TextLabel", bb)
        txt.ZIndex                 = 10
        txt.Text                   = p.Name
        txt.BackgroundTransparency = 1
        txt.Position               = UDim2.new(0, 0, 0, -35)
        txt.Size                   = UDim2.new(1, 0, 10, 0)
        txt.Font                   = Enum.Font.ArialBold
        txt.TextSize               = 12
        txt.TextStrokeTransparency = 0.5
        txt.TextColor3             = color
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
    if not ok then warn("[MurderHUD] LpVisual: " .. tostring(err)) end
end

-- ── Role visuals ──────────────────────────────────────────────────────────────
local function removeVisuals(p)
    local v = visuals[p]
    if not v then return end
    visuals[p] = nil
    if v.bb and v.bb.Parent then v.bb:Destroy() end
end

local function attachVisuals(p, char, role)
    removeVisuals(p)
    local head = char:FindFirstChild("Head")
    if not head then return end
    local ok, err = pcall(function()
        local color = ROLE_COLOR[role]
        local bb = Instance.new("BillboardGui")
        bb.Name          = "tracker"
        bb.Adornee       = head
        bb.AlwaysOnTop   = true
        bb.ExtentsOffset = Vector3.new(0, 1, 0)
        bb.Size          = UDim2.new(0, 5, 0, 5)
        bb.StudsOffset   = Vector3.new(0, 1, 0)
        bb.Parent        = game:GetService("CoreGui")
        local frame = Instance.new("Frame", bb)
        frame.ZIndex               = 10
        frame.BackgroundTransparency = 0.3
        frame.BackgroundColor3     = color
        frame.Size                 = UDim2.new(1, 0, 1, 0)
        local txt = Instance.new("TextLabel", bb)
        txt.ZIndex                 = 10
        txt.Text                   = p.Name
        txt.BackgroundTransparency = 1
        txt.Position               = UDim2.new(0, 0, 0, -35)
        txt.Size                   = UDim2.new(1, 0, 10, 0)
        txt.Font                   = Enum.Font.ArialBold
        txt.TextSize               = 12
        txt.TextStrokeTransparency = 0.5
        txt.TextColor3             = color
        visuals[p] = { bb = bb }
        bb.AncestryChanged:Connect(function(_, parent)
            if parent ~= nil then return end
            if visuals[p] and visuals[p].bb == bb then
                visuals[p] = nil
                task.defer(function()
                    local pChar = p.Character
                    local role = roles[p]
                    if pChar and role then attachVisuals(p, pChar, role) end
                end)
            end
        end)
    end)
    if not ok then warn("[MurderHUD] RoleVisual: " .. tostring(err)) end
end

local OUTLINE_COLOR = {
    murder  = Color3.fromRGB(255, 0, 0),
    sheriff = Color3.fromRGB(0, 100, 255),
    hero    = Color3.fromRGB(255, 255, 0),
    norole  = Color3.fromRGB(0, 255, 80),
}

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
        hl.Parent              = game:GetService("CoreGui")
        outlines[p] = hl
        hl.AncestryChanged:Connect(function(_, parent)
            if parent ~= nil then return end
            if outlines[p] == hl then
                outlines[p] = nil
                task.defer(function()
                    local pChar = p.Character
                    if pChar and playersInRound[p] then
                        local r = roles[p]
                        if r or isLpMurd then
                            attachOutline(p, pChar, r)
                        end
                    end
                end)
            end
        end)
    end)
    if not ok then warn("[MurderHUD] Outline: " .. tostring(err)) end
end

-- ── Role detection ────────────────────────────────────────────────────────────
local function getRole(p)
    local char      = p.Character
    local bp        = p:FindFirstChild("Backpack")
    local wsModel   = Workspace:FindFirstChild(p.Name)
    if not char then return stickyRoles[p] end
    local hasKnife = char:FindFirstChild("Knife")
        or (bp       and bp:FindFirstChild("Knife"))
        or (wsModel  and wsModel:FindFirstChild("Knife"))
    if hasKnife then
        stickyRoles[p] = "murder"
        return "murder"
    end
    local hasGun = char:FindFirstChild("Gun")
        or (bp       and bp:FindFirstChild("Gun"))
        or (wsModel  and wsModel:FindFirstChild("Gun"))
    if hasGun then
        local role = gunDropped and "hero" or "sheriff"
        stickyRoles[p] = role
        return role
    end
    return stickyRoles[p]
end

-- ── LP visual for one player ──────────────────────────────────────────────────
local function updateLpVisualFor(p)
    if not isLpMurd then removeLpVisual(p) return end
    local pChar = p.Character
    if not pChar then removeLpVisual(p) return end
    local role = roles[p]
    if role == "murder" then removeLpVisual(p) return end
    local lpColor = role == "sheriff" and LP_COLOR.sheriff or LP_COLOR.norole
    local lv = lpVisuals[p]
    if not lv or lv.color ~= lpColor then
        attachLpVisual(p, pChar, lpColor)
    end
end

local applyRole
local function endRound()
    if not roundActive then return end
    roundActive = false
    playersInRound = {}
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Anchored then hrp.Anchored = false end
    if murderGui then murderGui.Enabled = false end
    if innocentGui then innocentGui.Enabled = false end
    gunDropped = false
    murderer = nil
    local thisId = roundId
    task.delay(15, function()
        if roundId ~= thisId then return end
        for p in pairs(visuals) do removeVisuals(p) end
        for p in pairs(lpVisuals) do removeLpVisual(p) end
        for p in pairs(outlines) do removeOutline(p) end
        roles = {}
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
    roundId = roundId + 1
    roundActive = true
    gunDropped  = false
    playersInRound = {}
    if murderGui then murderGui.Enabled = false end
    if innocentGui then innocentGui.Enabled = false end
    for _, p in ipairs(Players:GetPlayers()) do
        playersInRound[p] = true
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then applyRole(p) end
    end
    task.delay(1, function()
        if not roundActive then return end
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

-- ── Apply role state for a player ─────────────────────────────────────────────
applyRole = function(p)
    local role  = getRole(p)
    local pChar = p.Character
    local old   = roles[p]
    roles[p] = role
    if role == "murder" then
        if murderer ~= p then
            murderer = p
            startRound()
        end
    elseif old == "murder" and murderer == p then
        murderer = nil
    end
    if role and pChar then
        if isInLobby(pChar) and not playersInRound[p] then
            removeVisuals(p)
            removeLpVisual(p)
        else
            local v = visuals[p]
            if not v or not v.bb or not v.bb.Parent or old ~= role then
                attachVisuals(p, pChar, role)
            end
        end
    else
        removeVisuals(p)
    end
    if pChar and playersInRound[p] then
        if isInLobby(pChar) or (not isLpMurd and not role) then
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
    if old ~= role then
        updateLpVisualFor(p)
    end
end

-- ── LP murderer state ─────────────────────────────────────────────────────────
local function refreshLpMurd()
    local char = lp.Character
    local bp   = lp:FindFirstChild("Backpack")
    local prev = isLpMurd
    local wsModel = Workspace:FindFirstChild(lp.Name)
    isLpMurd = (char    and char:FindFirstChild("Knife")    ~= nil)
            or (bp      and bp:FindFirstChild("Knife")      ~= nil)
            or (wsModel and wsModel:FindFirstChild("Knife") ~= nil)
    if prev == isLpMurd then return end
    if not roundActive then startRound() end
    if isLpMurd then
        for _, p in ipairs(Players:GetPlayers()) do
            lpLastActiveTime = tick()
            if p ~= lp then
                applyRole(p)
                updateLpVisualFor(p)
            end
        end
        if innocentGui then innocentGui.Enabled = false end
    else
        clearAllLpVisuals()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and playersInRound[p] then
                attachOutline(p, p.Character, roles[p])
            end
        end
    end
    local lpInLobby = isInLobby(lp.Character)
    if murderGui then murderGui.Enabled = isLpMurd and not lpInLobby end
end

-- ── Watch container for tool events ──────────────────────────────────────────
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
            if child.Name == "Knife" or child.Name == "Gun" then
                task.defer(function() applyRole(p) end)
            end
        end)
        container.ChildRemoved:Connect(function(child)
            if child.Name == "Knife" or child.Name == "Gun" then
                task.defer(function() applyRole(p) end)
            end
        end)
    end
end

-- ── Watch character for removal ───────────────────────────────────────────────
local function watchChar(p, char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function()
            playersInRound[p] = nil
            removeLpVisual(p)
            removeVisuals(p)
            if murderer == p then
                murderer = nil
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
        if parent ~= nil then
            if isInLobby(char) and not playersInRound[p] then
                removeLpVisual(p)
                removeVisuals(p)
            end
            return
        end
        playersInRound[p] = nil
        roles[p]          = nil
        stickyRoles[p]    = nil
        removeOutline(p)
        if murderer == p then
            murderer = nil
            endRound()
        else
            checkInnocentsDead()
        end
    end)
end

-- ── FakeHRP helpers ────────────────────────────────────────────────────────
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
    if not ok then warn("[MurderHUD] FakeHRP create: " .. tostring(err)) end
end

-- ── Per-player setup ──────────────────────────────────────────────────────────
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

-- ── LP setup ──────────────────────────────────────────────────────────────────
local function setupLp()
    local char = lp.Character
    if char then
        setWalkSpeed(char)
        setJumpPower(char)
        watchContainer(lp, char, true)
    end
    local bp = lp:FindFirstChild("Backpack")
    if bp then
        watchContainer(lp, bp, true)
    end
    refreshLpMurd()
end

local function refreshLpSheriff()
    local char = lp.Character
    local bp   = lp:FindFirstChild("Backpack")
    local prev = isLpSheriff
    isLpSheriff = (char and char:FindFirstChild("Gun") ~= nil)
               or (bp   and bp:FindFirstChild("Gun")   ~= nil)
    if prev == isLpSheriff then return end
    if isLpSheriff and not roundActive then startRound() end
    local lpInLobby = isInLobby(lp.Character)
    if innocentGui then innocentGui.Enabled = not lpInLobby and not isLpMurd and not isLpSheriff and gunDropped end
    if murderGui and lpInLobby then murderGui.Enabled = false end
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
    refreshLpMurd()
end)

setupLp()

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then setupPlayer(p) end
end

Players.PlayerAdded:Connect(function(p)
    if p == lp then return end
    setupPlayer(p)
end)

Players.PlayerRemoving:Connect(function(p)
    playersInRound[p] = nil
    roles[p]       = nil
    stickyRoles[p] = nil
    velSmooth[p] = nil
    removeLpVisual(p)
    removeVisuals(p)
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
    removeOutline(p)
end)

-- ── FakeHRP sync: Heartbeat (positional, must remain per-frame) ───────────────
RunService.Heartbeat:Connect(function()
    for p, fakePart in pairs(fakeHRPs) do
        local char = p.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        -- Velocity smoothing sample
        if hrp then
            if not velSmooth[p] then velSmooth[p] = {} end
            local buf = velSmooth[p]
            table.insert(buf, hrp.AssemblyLinearVelocity)
            if #buf > VEL_SMOOTH_SIZE then table.remove(buf, 1) end
        end
        if hrp then
            fakePart.CFrame = hrp.CFrame
            if hrp.Size ~= REAL_HRP_SIZE then
                hrp.Size       = REAL_HRP_SIZE
                hrp.CanCollide = false
            end
            local list = charParts[p]
            if list then
                for i = 1, #list do
                    local v = list[i]
                    if v and v.Parent and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        else
            fakePart.CFrame = CFrame.new(HIDE_POS2)
        end
    end
end)

-- ── Aim: gun (targets murderer) ───────────────────────────────────────────────
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

local function getAimPosition()
    if not murderer then return nil end
    local char = murderer.Character
    if not char then return nil end

    local hrp = char:FindFirstChild("HumanoidRootPart")
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

    local pos   = hrp.Position
    local hVel  = Vector3.new(vel.X, 0, vel.Z)
    local speed = hVel.Magnitude

    local isAir      = hum and hum.FloorMaterial == Enum.Material.Air
    local isClimbing = hum and hum:GetState() == Enum.HumanoidStateType.Climbing
    local inAir      = isAir and not isClimbing

    local torsoOff = torso and (torso.Position - pos) or Vector3.new(0, 0.9, 0)
    local headOff  = head  and (head.Position  - pos) or Vector3.new(0, 2.5, 0)

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

    local LEAD_VFAST  = 4.9
    local LEAD_FAST  = 4.7
    local LEAD_SLOW  = 2.6
    local LEAD_SSLOW  = 1.7
    local LEAD_VSLOW = 1

    local hUnit = hVel.Magnitude > 0 and hVel.Unit or Vector3.zero
    local lead
    if speed >= 17.5 then
        lead = LEAD_VFAST
    elseif speed >= 15.8 then
        lead = LEAD_FAST
    elseif speed >= 11 then
        lead = LEAD_SLOW
    elseif speed > 8 then
        lead = LEAD_SSLOW
    elseif speed > 4 then
        lead = LEAD_VSLOW
    else
        lead = 0
    end

    local hOffset = hUnit * lead
    local predX   = pos.X + hOffset.X
    local predZ   = pos.Z + hOffset.Z

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

    local predHRP = Vector3.new(predX, predY, predZ)

    local candidates = {
        predHRP + torsoOff,
        predHRP + headOff,
        predHRP,
    }

    rayParams.FilterDescendantsInstances = { myChar, char }
    for _, cPos in ipairs(candidates) do
        local dir = cPos - myHRP.Position
        local hit = Workspace:Raycast(myHRP.Position, dir, rayParams)
        if not hit or hit.Instance:IsDescendantOf(char) then
            return cPos
        end
    end

    print("Speed:" .. speed)
    return candidates[1]
end

-- ── Remote getters ────────────────────────────────────────────────────────────
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

-- ── Input ─────────────────────────────────────────────────────────────────────
local doThrowKnife
local doGrabGun
local touchStartPos = nil

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if not innocentGui or not innocentGui.Enabled then return end
        local ok, err = pcall(doGrabGun)
        if not ok then warn("[MurderHUD] GrabGun key: " .. tostring(err)) end
    end
end)

UIS.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        touchStartPos = input.Position
        if isLpMurd then lpLastActiveTime = tick() end
    end
end)

UIS.InputEnded:Connect(function(input, processed)
    local isRightMouse = input.UserInputType == Enum.UserInputType.MouseButton2
    if isRightMouse then
        if not murderGui or not murderGui.Enabled then return end
        local ok, err = pcall(doThrowKnife)
        if not ok then warn("[MurderHUD] ThrowKnife RMB: " .. tostring(err)) end
        return
    end
    local isFire = input.UserInputType == Enum.UserInputType.MouseButton1
               or (input.UserInputType == Enum.UserInputType.Touch
                   and not UIS:GetFocusedTextBox()
                   and input.Position.X > (workspace.CurrentCamera.ViewportSize.X * 0.35))
    if not isFire then return end
    if touchStartPos then
        local delta = (Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(touchStartPos.X, touchStartPos.Y)).Magnitude
        if delta > 12 then touchStartPos = nil return end
    end
    touchStartPos = nil
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
    if not ok then warn("[MurderHUD] Shoot FireServer: " .. tostring(err)) end
end)

doThrowKnife = function()
    local char = lp.Character
    if not char then return end
    local myHRP = char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local knife = char:FindFirstChild("Knife")
    if not knife then
        local bp = lp:FindFirstChild("Backpack")
        if bp then
            local bpKnife = bp:FindFirstChild("Knife")
            if bpKnife then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then warn("[MurderHUD] ThrowKnife: no Humanoid") return end
                local ok2, err2 = pcall(function() hum:EquipTool(bpKnife) end)
                if not ok2 then warn("[MurderHUD] ThrowKnife equip: " .. tostring(err2)) return end
                task.wait(0.1)
                knife = char:FindFirstChild("Knife")
            end
        end
    end
    if not knife then warn("[MurderHUD] ThrowKnife: no Knife found") return end
    local knifeEvents = knife:FindFirstChild("Events")
    local throwRemote = knifeEvents and knifeEvents:FindFirstChild("KnifeThrown")
    if not (throwRemote and throwRemote:IsA("RemoteEvent")) then
        warn("[MurderHUD] ThrowKnife: KnifeThrown remote not found") return
    end
    local candidates = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local hrp2 = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                local dist = (hrp2.Position - myHRP.Position).Magnitude
                table.insert(candidates, { player = p, hrp = hrp2, dist = dist })
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
                local dir = part.Position - myHRP.Position
                local result = Workspace:Raycast(myHRP.Position, dir, rayParams)
                if not result or result.Instance:IsDescendantOf(pChar) then
                    visible = visible + 1
                end
            end
        end
        if visible > 0 then
            nearest    = c.player
            nearestHRP = c.hrp
            break
        end
    end
    if not nearest and #candidates > 0 then
        nearest    = candidates[1].player
        nearestHRP = candidates[1].hrp
    end
    if not nearest then warn("[MurderHUD] ThrowKnife: no target found") return end
    local vel  = nearestHRP.AssemblyLinearVelocity
    local hVel = Vector3.new(vel.X, 0, vel.Z)
    local aimPos = nearestHRP.Position
    if hVel.Magnitude > 0 then
        aimPos = aimPos + hVel.Unit * WALK_LEAD_THROW
    end
    local ok, err = pcall(function()
        throwRemote:FireServer(CFrame.new(myHRP.Position, aimPos), CFrame.new(aimPos))
    end)
    if not ok then warn("[MurderHUD] ThrowKnife FireServer: " .. tostring(err)) end
end

-- ── killall ────────────────────────────────────────────────────
local function doKillAll()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local knife = char:FindFirstChild("Knife")
    if not knife then
        local bp = lp:FindFirstChild("Backpack")
        if bp then
            local bpKnife = bp:FindFirstChild("Knife")
            if bpKnife then
                local ok2, err2 = pcall(function() hum:EquipTool(bpKnife) end)
                if not ok2 then warn("[MurderHUD] KillAll equip: " .. tostring(err2)) return end
                task.wait(0.1)
                knife = char:FindFirstChild("Knife")
            end
        end
    end
    if not knife then warn("[MurderHUD] KillAll: no Knife found") return end
    local knifeEvents = knife:FindFirstChild("Events")
    local stab = knifeEvents and knifeEvents:FindFirstChild("KnifeStabbed")
    if not (stab and stab:IsA("RemoteEvent")) then
        pcall(function() lp.Character:FindFirstChild("Knife").Events.KnifeStabbed:FireServer() end)
        return
    end
    local myHRP = char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local ok3, err3 = pcall(function()
                    hrp.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 1
                end)
                if not ok3 then warn("[MurderHUD] KillAll move: " .. tostring(err3)) end
            end
        end
    end
    local ok4, err4 = pcall(function() stab:FireServer() end)
    if not ok4 then warn("[MurderHUD] KillAll FireServer: " .. tostring(err4)) end
end

local function doKillSingle(name)
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local knife = char:FindFirstChild("Knife")
    if not knife then
        local bp = lp:FindFirstChild("Backpack")
        if bp then
            local bpKnife = bp:FindFirstChild("Knife")
            if bpKnife then
                local ok2, err2 = pcall(function() hum:EquipTool(bpKnife) end)
                if not ok2 then warn("[MurderHUD] KillSingle equip: " .. tostring(err2)) return end
                task.wait(0.1)
                knife = char:FindFirstChild("Knife")
            end
        end
    end
    if not knife then warn("[MurderHUD] KillSingle: no Knife") return end
    local knifeEvents = knife:FindFirstChild("Events")
    local stab = knifeEvents and knifeEvents:FindFirstChild("KnifeStabbed")
    if not (stab and stab:IsA("RemoteEvent")) then
        warn("[MurderHUD] KillSingle: KnifeStabbed remote not found") return
    end
    local myHRP = char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local low = name:lower()
    local target = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Name:lower():find(low, 1, true) then
            target = p
            break
        end
    end
    if not target then warn("[MurderHUD] KillSingle: not found: " .. name) return end
    local tChar = target.Character
    local tHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not tHRP then warn("[MurderHUD] KillSingle: target has no HRP") return end
    local ok3, err3 = pcall(function()
        tHRP.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 1
    end)
    if not ok3 then warn("[MurderHUD] KillSingle move: " .. tostring(err3)) end
    local ok4, err4 = pcall(function() stab:FireServer() end)
    if not ok4 then warn("[MurderHUD] KillSingle FireServer: " .. tostring(err4)) end
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

local function freezeAbove(hrp)
    hrp.CFrame   = CFrame.new(hrp.Position + Vector3.new(0, 200, 0))
end

local function waitUntilTimer(secs, guard)
    while autofarmActive do
        if guard and not guard() then return false end
        local t = timerLabel and parseTimer(timerLabel.Text)
        if t and t <= secs then return true end
        task.wait(0.5)
    end
    return false
end

local function doAutofarmShoot()
    local lastShot = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not autofarmActive or not roundActive or not murderer then
            conn:Disconnect()
            local c = lp.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if h and not h.Anchored then freezeAbove(h) end
            return
        end
        local now = tick()
        if now - lastShot < 0.1 then return end
        lastShot = now
        local mChar = murderer.Character
        local mHRP  = mChar and mChar:FindFirstChild("HumanoidRootPart")
        if not mHRP then return end
        local myChar = lp.Character
        local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local bp = lp:FindFirstChild("Backpack")
        local hasGun = myChar:FindFirstChild("Gun") ~= nil
            or (bp and bp:FindFirstChild("Gun") ~= nil)
        if isLpSheriff or hasGun then
            myHRP.CFrame = CFrame.new(mHRP.Position + mHRP.CFrame.LookVector * 15, mHRP.Position)
        end
        local aimPos = getAimPosition() or mHRP.Position
        local remote = getShootRemote()
        if remote then
            pcall(function()
                remote:FireServer(CFrame.new(myHRP.Position, aimPos), CFrame.new(aimPos))
            end)
        end
    end)
end

local function stopAutofarm()
    autofarmActive = false
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Anchored then hrp.Anchored = false end
end

local function runAutofarm()
    task.spawn(function()
        while autofarmActive do
            if not roundActive then task.wait(1) continue end
            local char = lp.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5) continue end

            if isLpMurd then
                local knife = char:FindFirstChild("Knife")
                if not knife then
                    local bp = lp:FindFirstChild("Backpack")
                    knife = bp and bp:FindFirstChild("Knife")
                end
                if not knife then task.wait(0.3) continue end
                while autofarmActive and roundActive and isLpMurd do
                    pcall(doKillAll)
                    task.wait(3)
                end

            elseif isLpSheriff then
                if not hrp.Anchored then freezeAbove(hrp) end
                local ok = waitUntilTimer(30, function()
                    return autofarmActive and roundActive and isLpSheriff
                end)
                if ok and autofarmActive then
                    doAutofarmShoot()
                end
                task.wait(0.5)

            else
                if not hrp.Anchored then freezeAbove(hrp) end
                while autofarmActive and not gunDropped and roundActive do
                    task.wait(0.5)
                end
                if autofarmActive and gunDropped and roundActive then
                    while autofarmActive and roundActive do
                        local gd = Workspace:FindFirstChild("GunDrop", true)
                        if not gd then break end
                        local c2 = lp.Character
                        local h2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                        if h2 then h2.Anchored = false end
                        pcall(doGrabGun)
                        task.wait(0.1)
                        local c3 = lp.Character
                        local h3 = c3 and c3:FindFirstChild("HumanoidRootPart")
                        if h3 then freezeAbove(h3) end
                        task.wait(0.3)
                    end
                    local ok = waitUntilTimer(60, function()
                        return autofarmActive and roundActive and not isLpMurd
                    end)
                    if ok and autofarmActive then
                        doAutofarmShoot()
                    end
                end
                task.wait(0.5)
            end
        end
        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Anchored then hrp.Anchored = false end
    end)
end

doGrabGun = function()
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local savedCFrame = hrp.CFrame
    local gunDrop = nil
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "GunDrop" and desc:IsA("BasePart") then
            gunDrop = desc
            break
        end
    end
    if not gunDrop then warn("[MurderHUD] GrabGun: no GunDrop found") return end
    local ok, err = pcall(function()
        hrp.CFrame = CFrame.new(gunDrop.Position)
        firetouchinterest(gunDrop, hrp, 0)
        hrp.CFrame = savedCFrame
    end)
    if not ok then warn("[MurderHUD] GrabGun: " .. tostring(err)) end
end

-- ── Murder GUI ────────────────────────────────────────────────────────────────
do
    local gui = Instance.new("ScreenGui")
    gui.Name        = "MurderHUD_Gui"
    gui.ResetOnSpawn = false
    gui.Enabled     = false
    gui.Parent      = game:GetService("CoreGui")
    murderGui       = gui

    local frame = Instance.new("Frame")
    frame.Size                  = UDim2.new(0, 170, 0, 60)
    frame.Position              = UDim2.new(1, -180, 0, 10)
    frame.BackgroundTransparency = 1
    frame.Parent                = gui

    local throwBtn = Instance.new("TextButton")
    throwBtn.Size             = UDim2.new(1, 0, 0, 50)
    throwBtn.Position         = UDim2.new(0, 0, 0, 0)
    throwBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    throwBtn.Text             = "Throw Knife"
    throwBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    throwBtn.TextSize         = 18
    throwBtn.Font             = Enum.Font.GothamSemibold
    throwBtn.Parent           = frame
    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0, 10)
    c1.Parent       = throwBtn

    throwBtn.MouseButton1Click:Connect(function()
        local ok, err = pcall(doThrowKnife)
        if not ok then warn("[MurderHUD] ThrowKnife: " .. tostring(err)) end
    end)

    local dragging = false
    local dragInput, dragStart, startPos

    local function onInputBegan(input)
        local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        if not (isMouse or isTouch) then return end
        dragging  = true
        dragStart = input.Position
        startPos  = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end

    local function onInputChanged(input)
        local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        if isMouse or isTouch then dragInput = input end
    end

    for _, obj in ipairs({ frame, throwBtn }) do
        obj.InputBegan:Connect(onInputBegan)
        obj.InputChanged:Connect(onInputChanged)
    end

    UIS.InputChanged:Connect(function(input)
        if input ~= dragInput or not dragging then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)
end

-- ── Innocent GUI ──────────────────────────────────────────────────────────────
do
    local gui = Instance.new("ScreenGui")
    gui.Name         = "MurderHUD_InnocentGui"
    gui.ResetOnSpawn = false
    gui.Enabled      = false
    gui.Parent       = game:GetService("CoreGui")
    innocentGui      = gui

    local frame = Instance.new("Frame")
    frame.Size                   = UDim2.new(0, 170, 0, 60)
    frame.Position               = UDim2.new(1, -180, 0, 10)
    frame.BackgroundTransparency = 1
    frame.Parent                 = gui

    local grabBtn = Instance.new("TextButton")
    grabBtn.Size             = UDim2.new(1, 0, 0, 50)
    grabBtn.Position         = UDim2.new(0, 0, 0, 0)
    grabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    grabBtn.Text             = "Grab Gun"
    grabBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    grabBtn.TextSize         = 18
    grabBtn.Font             = Enum.Font.GothamSemibold
    grabBtn.Parent           = frame
    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0, 10)
    c1.Parent       = grabBtn

    grabBtn.MouseButton1Click:Connect(function()
        local ok, err = pcall(doGrabGun)
        if not ok then warn("[MurderHUD] GrabGun: " .. tostring(err)) end
    end)

    local dragging = false
    local dragInput, dragStart, startPos

    local function onInputBegan(input)
        local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        if not (isMouse or isTouch) then return end
        dragging  = true
        dragStart = input.Position
        startPos  = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end

    local function onInputChanged(input)
        local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        if isMouse or isTouch then dragInput = input end
    end

    for _, obj in ipairs({ frame, grabBtn }) do
        obj.InputBegan:Connect(onInputBegan)
        obj.InputChanged:Connect(onInputChanged)
    end

    UIS.InputChanged:Connect(function(input)
        if input ~= dragInput or not dragging then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)
end

-- ── Help GUI ──────────────────────────────────────────────────────────────────
do
    local gui = Instance.new("ScreenGui")
    gui.Name         = "ShadowX_HelpGui"
    gui.ResetOnSpawn = false
    gui.Enabled      = true
    gui.Parent       = game:GetService("CoreGui")
    helpGui          = gui

    local frame = Instance.new("Frame")
    frame.Size                   = UDim2.new(0, 310, 0, 390)
    frame.Position               = UDim2.new(0.5, -155, 0.5, -195)
    frame.BackgroundColor3       = Color3.fromRGB(18, 18, 18)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel        = 0
    frame.Parent                 = gui
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 12)
    fCorner.Parent       = frame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size                 = UDim2.new(1, -46, 0, 36)
    titleLbl.Position             = UDim2.new(0, 12, 0, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text                 = "ShadowX  —  Help"
    titleLbl.TextColor3           = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize             = 15
    titleLbl.Font                 = Enum.Font.GothamBold
    titleLbl.TextXAlignment       = Enum.TextXAlignment.Left
    titleLbl.Parent               = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size             = UDim2.new(0, 28, 0, 28)
    closeBtn.Position         = UDim2.new(1, -34, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    closeBtn.Text             = "X"
    closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize         = 13
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.BorderSizePixel  = 0
    closeBtn.Parent           = frame
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent       = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    local divider = Instance.new("Frame")
    divider.Size             = UDim2.new(1, -20, 0, 1)
    divider.Position         = UDim2.new(0, 10, 0, 38)
    divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    divider.BorderSizePixel  = 0
    divider.Parent           = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size                  = UDim2.new(1, -10, 1, -48)
    scroll.Position              = UDim2.new(0, 5, 0, 44)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness    = 4
    scroll.ScrollBarImageColor3  = Color3.fromRGB(90, 90, 90)
    scroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    scroll.BorderSizePixel       = 0
    scroll.Parent                = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding   = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent    = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, 8)
    pad.PaddingRight  = UDim.new(0, 8)
    pad.PaddingTop    = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent        = scroll

    local lo = 0

    local function addSection(text)
        lo = lo + 1
        local lbl = Instance.new("TextLabel")
        lbl.LayoutOrder            = lo
        lbl.Size                   = UDim2.new(1, 0, 0, 0)
        lbl.AutomaticSize          = Enum.AutomaticSize.Y
        lbl.BackgroundTransparency = 1
        lbl.Text                   = text
        lbl.TextColor3             = Color3.fromRGB(255, 195, 50)
        lbl.TextSize               = 13
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.TextWrapped            = true
        lbl.Parent                 = scroll
    end

    local function addLine(text)
        lo = lo + 1
        local lbl = Instance.new("TextLabel")
        lbl.LayoutOrder            = lo
        lbl.Size                   = UDim2.new(1, 0, 0, 0)
        lbl.AutomaticSize          = Enum.AutomaticSize.Y
        lbl.BackgroundTransparency = 1
        lbl.Text                   = text
        lbl.TextColor3             = Color3.fromRGB(205, 205, 205)
        lbl.TextSize               = 12
        lbl.Font                   = Enum.Font.Gotham
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.TextWrapped            = true
        lbl.Parent                 = scroll
    end

    addSection("VISUALS")
    addLine("Red label + outline = Murderer (has Knife)")
    addLine("Blue label + outline = Sheriff (has Gun before it's dropped)")
    addLine("Yellow label + outline = Hero (picked up the dropped Gun)")
    addLine("Green label = Innocent — only visible when you are the Murderer")
    addLine("Green dot 'Gun' = Dropped gun location in the map")

    addSection("WHEN VISUALS APPEAR")
    addLine("Labels and outlines appear once a round starts and roles are detected from held items.")
    addLine("Gun drop marker appears the moment the murderer drops the gun.")
    addLine("All visuals clear 15 seconds after the round ends. (For cleanup)")

    addSection("BUTTONS")
    addLine("Throw Knife — Shown when you are the Murderer. Right-click or tap to auto-throw at the nearest visible player.")
    addLine("Grab Gun — Shown when the gun is dropped and you are innocent (not Sheriff). Tap or press G to teleport to the gun and pick it up.")

    addSection("CHAT COMMANDS")
    addLine(";help — Open or close this window")
    addLine(";killall — Kills all player (Murderer only)")
    addLine(";kill username — Kills the specific player (Murderer only)")
    -- ADD
addLine(";autofarm — Toggle autofarm. Murderer: kills all immediately. Sheriff: freezes 50 studs up, shoots at 30s left. Innocent: freezes up, grabs gun, shoots at 60s left, (doesn't include auto farm coins)")
    addLine(";help — shows this gui")
    
    addSection("AUTO FEATURES")
    addLine("Walk speed is locked to 19. (org. 17)")
    addLine("Jump power is locked to 55. (org. 50)")
    addLine("Auto-aim fires at the Murderer on left-click or tap with movement prediction.")
    addLine("Auto killall triggers after 30 seconds idle as Murderer. (So exp will not get wasted when afk and got murd)")

    local dragging = false
    local dragInput, dragStart, startPos

    local function onInputBegan(input)
        local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        if not (isMouse or isTouch) then return end
        dragging  = true
        dragStart = input.Position
        startPos  = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end

    local function onInputChanged(input)
        local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        if isMouse or isTouch then dragInput = input end
    end

    frame.InputBegan:Connect(onInputBegan)
    frame.InputChanged:Connect(onInputChanged)
    titleLbl.InputBegan:Connect(onInputBegan)
    titleLbl.InputChanged:Connect(onInputChanged)

    UIS.InputChanged:Connect(function(input)
        if input ~= dragInput or not dragging then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)
end

lp.Chatted:Connect(function(msg)
    local lower = msg:lower()
    if lower == ";killall" or lower == ";kill" then
        local ok, err = pcall(doKillAll)
        if not ok then warn("[MurderHUD] KillAll: " .. tostring(err)) end
    elseif lower:sub(1, 6) == ";kill " then
        local name = msg:sub(7)
        local ok, err = pcall(doKillSingle, name)
        if not ok then warn("[MurderHUD] KillSingle: " .. tostring(err)) end
    elseif lower == ";autofarm" then
        if autofarmActive then
            stopAutofarm()
        else
            autofarmActive = true
            runAutofarm()
        end
    elseif lower == ";help" then
        helpGui.Enabled = not helpGui.Enabled
    end
end)

-- ── GunDrop: event-driven ─────────────────────────────────────────────────────
Workspace.DescendantAdded:Connect(function(desc)
    if desc.Name ~= "GunDrop" then return end
    gunDropped = true
    task.defer(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then applyRole(p) end
        end
    end)
    local lpInLobby = isInLobby(lp.Character)
    if innocentGui then innocentGui.Enabled = not isLpMurd and not lpInLobby end
    if not isLpMurd and not isLpSheriff and not lpInLobby then
        task.defer(function()
            local ok2, err2 = pcall(doGrabGun)
            if not ok2 then warn("[MurderHUD] GunDrop auto-grab: " .. tostring(err2)) end
        end)
    end
    local ok, err = pcall(attachGunDropHighlight, desc)
    if not ok then warn("[MurderHUD] GunDrop DescendantAdded: " .. tostring(err)) end
end)
-- Catch any drops already in workspace at startup
for _, desc in ipairs(Workspace:GetDescendants()) do
    if desc.Name == "GunDrop" then
        gunDropped = true
        local ok, err = pcall(attachGunDropHighlight, desc)
        if not ok then warn("[MurderHUD] GunDrop startup: " .. tostring(err)) end
        if not isLpMurd and not isLpSheriff and not isInLobby(lp.Character) then
            local ok2, err2 = pcall(doGrabGun)
            if not ok2 then warn("[MurderHUD] GunDrop startup grab: " .. tostring(err2)) end
        end
    end
end
if gunDropped and innocentGui then
    innocentGui.Enabled = not isLpMurd
end

Workspace.DescendantRemoving:Connect(function(desc)
    if desc.Name ~= "GunDrop" then return end
    if innocentGui then innocentGui.Enabled = false end
end)

task.spawn(function()
    local ok, result = pcall(function()
        return Workspace:WaitForChild("RoundTimerPart", 10)
            :WaitForChild("SurfaceGui", 5)
            :WaitForChild("Timer", 5)
    end)
    if not ok or not result then warn("[MurderHUD] RoundTimer: not found") return end
    timerLabel = result
    timerLabel:GetPropertyChangedSignal("Active"):Connect(function()
        if timerLabel.Active then
            if not roundActive then startRound() end
        else
            endRound()
        end
    end)
    lp.CharacterAdded:Connect(function(char)
        char.AncestryChanged:Connect(function(_, parent)
            local inLobby = isInLobby(char)
            if murderGui then murderGui.Enabled = not inLobby and isLpMurd end
            if innocentGui then innocentGui.Enabled = not inLobby and (gunDropped and not isLpMurd and not isLpSheriff) end
        end)
    end)
    local lpChar = lp.Character
    if lpChar then
        lpChar.AncestryChanged:Connect(function(_, parent)
            local inLobby = isInLobby(lpChar)
            if murderGui then murderGui.Enabled = not inLobby and isLpMurd end
            if innocentGui then innocentGui.Enabled = not inLobby and (gunDropped and not isLpMurd and not isLpSheriff) end
        end)
    end
    if timerLabel.Active and not roundActive then startRound()
    elseif not timerLabel.Active and roundActive then endRound() end
end)

local MAX_VELOCITY = 80

RunService.Heartbeat:Connect(function()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    if vel.Magnitude > MAX_VELOCITY then
        hrp.AssemblyLinearVelocity = vel.Unit * MAX_VELOCITY
    end
    if isLpMurd then
        local hSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
        if hSpeed > 2 then
            lpLastActiveTime = tick()
        elseif tick() - lpLastActiveTime >= IDLE_KILLALL_DELAY then
            lpLastActiveTime = tick()
            local ok, err = pcall(doKillAll)
            if not ok then warn("[MurderHUD] AutoKillAll: " .. tostring(err)) end
        end
    end
end)
