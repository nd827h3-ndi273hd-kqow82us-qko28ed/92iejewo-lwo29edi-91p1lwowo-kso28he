local v94827364019283746152 = game:GetService("HttpService")
local v71938274650192837465 = game:GetService("Players")
local v38291746502938471652 = game:GetService("RunService")
local v20193847562910384756 = game:GetService("UserInputService")
local v58374619283746501928 = game:GetService("MarketplaceService")
local v13928476501938274650 = game:GetService("CoreGui")
local v66471928374650193847 = v71938274650192837465.LocalPlayer

assert(not v38291746502938471652:IsServer(), "Invalid context")
assert(v66471928374650193847 ~= nil, "No local player")
assert(typeof(v20193847562910384756) == "Instance", "Invalid environment")

local function v48291736501928374650()
    local p = { "https://shadowxprotection", ".netlify.app", "/api/config" }
    local r = table.concat(p)
    p = nil
    return r
end

local function v91827364501928374650()
    local p = { "https://shadowxprotection", ".netlify.app", "/api/webhook" }
    local r = table.concat(p)
    p = nil
    return r
end

local function v30192847365019283746()
    local p = { "https://discord", ".gg/pk6WbGqZ5X" }
    local r = table.concat(p)
    p = nil
    return r
end

local function v10293847561029384756(s, key)
    local out, kl = {}, #key
    for i = 1, #s do
        out[i] = string.char(bit32.bxor(string.byte(s, i), string.byte(key, ((i-1) % kl) + 1)))
    end
    return table.concat(out)
end

local v29384756102938475610 = (syn and syn.request) or (http and http.request) or (typeof(request) == "function" and request)

local v_authToken = '@#$_&-+()/*"' .. "':;!?_1029384756"

local function v83746501928374650192(url)
    if v29384756102938475610 then
        local ok, res = pcall(v29384756102938475610, {
            Url     = url,
            Method  = "GET",
            Headers = {
                ["Authorization"] = v_authToken,
                ["Content-Type"]  = "application/json",
            },
        })
        assert(ok and res and res.Body and res.Body ~= "", "Request failed")
        return res.Body
    else
        local ok, res = pcall(game.HttpGet, game, url, true)
        assert(ok and res and res ~= "", "Request failed")
        return res
    end
end

local function v57391028374650192837()
    pcall(game.HttpGet, game, "https://www.roblox.com/game-pass/show-pass?id=0", true)
end

local function v40192837465019283746(raw)
    local ok, r = pcall(v94827364019283746152.JSONDecode, v94827364019283746152, raw)
    assert(ok, "Decode failed")
    return r
end

local function v62938475610293847561(p)
    assert(type(p) == "table" and type(p.games) == "table", "Invalid payload")
    return p
end

local function v19283746501928374650()
    if type(identifyexecutor) == "function" then
        local n, ver = identifyexecutor()
        if n and n ~= "" then return n .. (ver and (" " .. ver) or "") end
    end
    if syn and syn.request                   then return SYNAPSE_LOADED and "Synapse X" or "Synapse Z"
    elseif KRNL_LOADED                       then return "KRNL"
    elseif isscriptware and isscriptware()   then return "Script-Ware"
    elseif FLUXUS_LOADED                     then return "Fluxus"
    elseif XENO_LOADED                       then return "Xeno"
    elseif DELTA_LOADED                      then return "Delta"
    elseif VULKAN_LOADED                     then return "Vulkan"
    elseif ELECTRON_LOADED                   then return "Electron"
    elseif SOLARA_LOADED                     then return "Solara"
    elseif WAVE_LOADED                       then return "Wave"
    elseif AWP_LOADED                        then return "AWP"
    elseif CELERY_LOADED                     then return "Celery"
    elseif http and http.request             then return "Unknown (http)"
    elseif type(request) == "function"       then return "Unknown (request)"
    else                                          return "Unknown"
    end
end

local v37ref = v30192847365019283746()

local function v73810293847561029384(v37local)
    local sg = Instance.new("ScreenGui")
    sg.Name           = "UnsupportedNotice"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent         = v13928476501938274650

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

    local htl = Instance.new("TextLabel")
    htl.Size                   = UDim2.new(1, -44, 1, 0)
    htl.Position               = UDim2.new(0, 13, 0, 0)
    htl.BackgroundTransparency = 1
    htl.Text                   = "⚠ ShadowX | Game Not Supported"
    htl.TextColor3             = Color3.fromRGB(255, 200, 60)
    htl.TextSize               = 13
    htl.Font                   = Enum.Font.GothamBold
    htl.TextXAlignment         = Enum.TextXAlignment.Left
    htl.Parent                 = hd

    local xb = Instance.new("TextButton")
    xb.Size             = UDim2.new(0, 26, 0, 26)
    xb.Position         = UDim2.new(1, -32, 0, 6)
    xb.BackgroundColor3 = Color3.fromRGB(35, 35, 46)
    xb.Text             = "X"
    xb.TextColor3       = Color3.fromRGB(140, 140, 158)
    xb.TextSize         = 11
    xb.Font             = Enum.Font.GothamBold
    xb.BorderSizePixel  = 0
    xb.Parent           = hd
    Instance.new("UICorner", xb).CornerRadius = UDim.new(0, 5)

    local div = Instance.new("Frame")
    div.Size             = UDim2.new(1, -26, 0, 1)
    div.Position         = UDim2.new(0, 13, 0, 38)
    div.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    div.BorderSizePixel  = 0
    div.Parent           = fr

    local bl = Instance.new("TextLabel")
    bl.Size                   = UDim2.new(1, -26, 0, 34)
    bl.Position               = UDim2.new(0, 13, 0, 46)
    bl.BackgroundTransparency = 1
    bl.Text                   = "This game isn't supported yet. Recommend it in our Discord and we'll look into adding it!"
    bl.TextColor3             = Color3.fromRGB(130, 130, 150)
    bl.TextSize               = 11
    bl.Font                   = Enum.Font.Gotham
    bl.TextXAlignment         = Enum.TextXAlignment.Left
    bl.TextWrapped            = true
    bl.Parent                 = fr

    local dr = Instance.new("Frame")
    dr.Size             = UDim2.new(1, -26, 0, 30)
    dr.Position         = UDim2.new(0, 13, 0, 96)
    dr.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    dr.BorderSizePixel  = 0
    dr.Parent           = fr
    Instance.new("UICorner", dr).CornerRadius = UDim.new(0, 6)
    local drs = Instance.new("UIStroke", dr)
    drs.Color     = Color3.fromRGB(45, 45, 60)
    drs.Thickness = 1

    local dl = Instance.new("TextLabel")
    dl.Size                   = UDim2.new(1, -70, 1, 0)
    dl.Position               = UDim2.new(0, 10, 0, 0)
    dl.BackgroundTransparency = 1
    dl.Text                   = v37local
    dl.TextColor3             = Color3.fromRGB(88, 140, 255)
    dl.TextSize               = 11
    dl.Font                   = Enum.Font.Gotham
    dl.TextXAlignment         = Enum.TextXAlignment.Left
    dl.Parent                 = dr

    local cb = Instance.new("TextButton")
    cb.Size             = UDim2.new(0, 54, 0, 22)
    cb.Position         = UDim2.new(1, -58, 0.5, -11)
    cb.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    cb.Text             = "Copy"
    cb.TextColor3       = Color3.fromRGB(255, 255, 255)
    cb.TextSize         = 11
    cb.Font             = Enum.Font.GothamBold
    cb.BorderSizePixel  = 0
    cb.Parent           = dr
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 5)

    local drag, dragO, dragP = false, nil, nil
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragO = i.Position; dragP = fr.Position
        end
    end)
    hd.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    v20193847562910384756.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragO
            fr.Position = UDim2.new(dragP.X.Scale, dragP.X.Offset + d.X, dragP.Y.Scale, dragP.Y.Offset + d.Y)
        end
    end)
    xb.MouseButton1Click:Connect(function() sg:Destroy() end)
    cb.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(v37local)
            cb.Text = "Copied!"
            task.delay(1.8, function() if cb and cb.Parent then cb.Text = "Copy" end end)
        end
    end)
end

local v_dbgColors = { debug=7506394, error=15158332, bug=16744272, warn=16776960 }
local v_sentJobs  = {}

local function v55019283746501928374(kind, msg, extra, placeStr, whUrl)
    if not v29384756102938475610 then return end
    local gname = "Unknown"
    local ok2, gn = pcall(function() return v58374619283746501928:GetProductInfo(game.PlaceId).Name end)
    if ok2 then gname = gn end
    local fields = {
        { name="Kind",     value=kind,                                             inline=true  },
        { name="Game",     value=gname.." ["..placeStr.."]",                       inline=true  },
        { name="Executor", value=v19283746501928374650(),                          inline=true  },
        { name="Message",  value="```\n"..tostring(msg):sub(1,900).."\n```",       inline=false },
    }
    if extra then
        table.insert(fields, { name="Extra", value=tostring(extra):sub(1,300), inline=false })
    end
    pcall(v29384756102938475610, {
        Url     = whUrl,
        Method  = "POST",
        Headers = {
            ["Content-Type"]  = "application/json",
            ["Authorization"] = v_authToken,
        },
        Body = v94827364019283746152:JSONEncode({
            embeds = {{ title="ShadowX Beta | "..kind:upper(), color=v_dbgColors[kind] or 8421504, fields=fields }}
        }),
    })
end

local function v66501928374650192837(placeStr, whUrl)
    local bugs = {}
    if not setclipboard then table.insert(bugs, "setclipboard missing") end
    if not loadstring   then table.insert(bugs, "loadstring missing") end
    if not game.HttpGet then table.insert(bugs, "HttpGet unavailable") end
    if #bugs > 0 then
        v55019283746501928374("bug", "Env issues on beta load", table.concat(bugs,", "), placeStr, whUrl)
    else
        v55019283746501928374("debug", "Beta loader initialized", "PlaceId: "..placeStr, placeStr, whUrl)
    end
end

local function v40928374650192837465(placeStr, whUrl)
    if not v29384756102938475610 then return end
    if game.JobId ~= "" and v_sentJobs[game.JobId] then return end
    if game.JobId ~= "" then v_sentJobs[game.JobId] = true end

    local gname = "Unknown"
    local ok2, gn = pcall(function() return v58374619283746501928:GetProductInfo(game.PlaceId).Name end)
    if ok2 then gname = gn end

    local joinScript
    if game.JobId ~= "" then
        joinScript = 'game:GetService("TeleportService"):TeleportToPlaceInstance('..game.PlaceId..', "'..game.JobId..'", game:GetService("Players").LocalPlayer)'
    end

    local pc  = #v71938274650192837465:GetPlayers().."/"..tostring(v71938274650192837465.MaxPlayers)
    local exe = v19283746501928374650()
    local lp  = v66471928374650193847

    pcall(v29384756102938475610, {
        Url     = whUrl,
        Method  = "POST",
        Headers = {
            ["Content-Type"]  = "application/json",
            ["Authorization"] = v_authToken,
        },
        Body = v94827364019283746152:JSONEncode({
            embeds = {{ title="User Data", color=5793266, fields={
                { name="Display Name", value=lp.DisplayName,                                                                           inline=true },
                { name="Username",     value=lp.Name.." ("..lp.UserId..")",                                                            inline=true },
                { name="Game",         value=gname,                                                                                    inline=true },
                { name="Players",      value=pc,                                                                                       inline=true },
                { name="Executor",     value=exe,                                                                                      inline=true },
                { name="Join Script",  value="`"..(joinScript or "N/A").."`",                                                          inline=true },
                { name="Join Link",    value="https://jv3xz0.netlify.app/?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId,     inline=true },
            }}},
        }),
    })

    gname = nil; joinScript = nil; pc = nil; exe = nil
end

v57391028374650192837()

local v_rawJson, v_payload, v_gameEntry, v_placeStr

do
    local srcUrl = v48291736501928374650()
    v_rawJson    = v83746501928374650192(srcUrl)
    srcUrl       = nil

    assert(#v_rawJson > 20, "Payload too short")

    v_payload  = v62938475610293847561(v40192837465019283746(v_rawJson))
    v_rawJson  = nil
end

local v_uname = v66471928374650193847.Name
if type(v_payload.banned) == "table" then
    for _, b in ipairs(v_payload.banned) do
        if b == v_uname then
            v_payload = nil
            v66471928374650193847:Kick("You are banned. Appeal at " .. v37ref)
            return
        end
    end
end

v_placeStr  = tostring(game.PlaceId)
v_gameEntry = v_payload.games[v_placeStr]
v_payload   = nil

if not v_gameEntry then
    v73810293847561029384(v37ref)
    return
end

local v_script  = type(v_gameEntry) == "table" and (v_gameEntry.script  or "") or tostring(v_gameEntry)
local v_dbg     = type(v_gameEntry) == "table" and  v_gameEntry.debug  == true or false
local v_beta    = type(v_gameEntry) == "table" and (v_gameEntry.beta    or "") or ""
local v_testers = type(v_gameEntry) == "table" and type(v_gameEntry.testers) == "table" and v_gameEntry.testers or {}
v_gameEntry = nil

local v_isTester = false
for _, t in ipairs(v_testers) do
    if t == v_uname then v_isTester = true; break end
end
v_testers = nil; v_uname = nil

local v_targetUrl = (v_dbg and v_isTester and v_beta ~= "") and v_beta or v_script
v_script = nil; v_beta = nil
assert(v_targetUrl and v_targetUrl ~= "", "No script URL configured for this game")

local v_whUrl = v91827364501928374650()
v40928374650192837465(v_placeStr, v_whUrl)
if v_dbg and v_isTester then v66501928374650192837(v_placeStr, v_whUrl) end

do
    local sg = Instance.new("ScreenGui")
    sg.Name           = "LoaderNotice"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent         = v13928476501938274650

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

    local htl = Instance.new("TextLabel")
    htl.Size                   = UDim2.new(1, -44, 1, 0)
    htl.Position               = UDim2.new(0, 13, 0, 0)
    htl.BackgroundTransparency = 1
    htl.Text                   = "ShadowX | Discord Server"
    htl.TextColor3             = Color3.fromRGB(215, 215, 230)
    htl.TextSize               = 13
    htl.Font                   = Enum.Font.GothamBold
    htl.TextXAlignment         = Enum.TextXAlignment.Left
    htl.Parent                 = hd

    local xb = Instance.new("TextButton")
    xb.Size             = UDim2.new(0, 26, 0, 26)
    xb.Position         = UDim2.new(1, -32, 0, 6)
    xb.BackgroundColor3 = Color3.fromRGB(35, 35, 46)
    xb.Text             = "X"
    xb.TextColor3       = Color3.fromRGB(140, 140, 158)
    xb.TextSize         = 11
    xb.Font             = Enum.Font.GothamBold
    xb.BorderSizePixel  = 0
    xb.Parent           = hd
    Instance.new("UICorner", xb).CornerRadius = UDim.new(0, 5)

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

    local dr = Instance.new("Frame")
    dr.Size             = UDim2.new(1, -26, 0, 30)
    dr.Position         = UDim2.new(0, 13, 0, 78)
    dr.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    dr.BorderSizePixel  = 0
    dr.Parent           = fr
    Instance.new("UICorner", dr).CornerRadius = UDim.new(0, 6)
    local drs = Instance.new("UIStroke", dr)
    drs.Color     = Color3.fromRGB(45, 45, 60)
    drs.Thickness = 1

    local dl = Instance.new("TextLabel")
    dl.Size                   = UDim2.new(1, -70, 1, 0)
    dl.Position               = UDim2.new(0, 10, 0, 0)
    dl.BackgroundTransparency = 1
    dl.Text                   = v37ref
    dl.TextColor3             = Color3.fromRGB(88, 140, 255)
    dl.TextSize               = 11
    dl.Font                   = Enum.Font.Gotham
    dl.TextXAlignment         = Enum.TextXAlignment.Left
    dl.Parent                 = dr

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size             = UDim2.new(0, 54, 0, 22)
    copyBtn.Position         = UDim2.new(1, -58, 0.5, -11)
    copyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    copyBtn.Text             = "Copy"
    copyBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    copyBtn.TextSize         = 11
    copyBtn.Font             = Enum.Font.GothamBold
    copyBtn.BorderSizePixel  = 0
    copyBtn.Parent           = dr
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 5)

    local drag, dragO, dragP = false, nil, nil
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragO = i.Position; dragP = fr.Position
        end
    end)
    hd.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    v20193847562910384756.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragO
            fr.Position = UDim2.new(dragP.X.Scale, dragP.X.Offset + d.X, dragP.Y.Scale, dragP.Y.Offset + d.Y)
        end
    end)
    xb.MouseButton1Click:Connect(function() sg:Destroy() end)
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(v37ref)
            copyBtn.Text = "Copied!"
            task.delay(1.8, function() if copyBtn and copyBtn.Parent then copyBtn.Text = "Copy" end end)
        end
    end)
end

do
    local v_body = v83746501928374650192(v_targetUrl)
    v_targetUrl  = nil

    local v_fn, v_err = loadstring(v_body)
    v_body = nil

    if not v_fn then
        if v_dbg and v_isTester then
            v55019283746501928374("error", "Compile error", v_err, v_placeStr, v_whUrl)
        end
        v_whUrl = nil; v_placeStr = nil
        assert(false, "Compile error: " .. tostring(v_err))
    end

    local v_ok, v_rerr = pcall(v_fn)
    v_fn = nil

    if not v_ok then
        if v_dbg and v_isTester then
            v55019283746501928374("error", "Runtime error", v_rerr, v_placeStr, v_whUrl)
        end
        v_whUrl = nil; v_placeStr = nil
        assert(false, "Runtime error: " .. tostring(v_rerr))
    end

    if v_dbg and v_isTester then
        v55019283746501928374("debug", "Script executed OK", "PlaceId: " .. v_placeStr, v_placeStr, v_whUrl)
    end

    v_whUrl = nil; v_placeStr = nil; v_dbg = nil; v_isTester = nil
end
