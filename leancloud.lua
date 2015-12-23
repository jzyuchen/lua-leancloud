#!/usr/bin/lua

module("leancloud", package.seeall)

local socketHttp = require("socket.http")
local socketHttps = require("ssl.https")
local json = require("luci.json")

local BASE_URL = "https://api.leancloud.cn/1.1/"
local app_id, app_key


function httpRequest(url, method, header, data)
	local result = {
		code = "",
		headers = "",
		status = "",
		res = ""
    }
	
	local t = {}
	local res, code, headers, status
	
	if method == "POST" or method == "PUT" then
		if header == nil then
			header = {}
		end
		header["Content-Length"] = #data
		res, code, headers, status = socketHttps.request{
			url = url,
			method = method,
			source = ltn12.source.string(data),
			sink = ltn12.sink.table(t),
			headers = header
		}
	else
		res, code, headers, status = socketHttps.request{
			url = url,
			method = method,
			sink = ltn12.sink.table(t),
			headers = header
		}
	end
	res = table.concat(t)
    result.code = code or ""
    result.headers = headers or ""
    result.status = status or ""
    result.res = res or ""
	return result
end

function init(appId, appKey)
	app_id = appId;
	app_key = appKey
end

AVObject = {}
AVObject.__index = AVObject
 
function AVObject:new(className)
    local o = {}
    setmetatable(o, AVObject)
    o["_className"] = className
	o["data"] = {}
    return o
end

function AVObject:put(key, value)
    self["data"][key] = value
end

function AVObject:get(key)
	return self["data"][key]
end

function AVObject:create()
	local data = json.encode(self["data"])
	local url = table.concat({BASE_URL, "classes", "/", self["_className"]})
	local header = {
		["X-LC-Id"] = app_id,
		["X-LC-Key"] = app_key,
		["Content-Type"] = "application/json"
	}
	local result = httpRequest(url, "POST", header, data)
	return result.res
end

function AVObject:update()
end

function AVObject:delete()
end

function AVObject:save()
    print(self["_className"])
end

function AVObject.find(className, skip, limit)
	local url = table.concat({BASE_URL, "classes", "/", className})
	local header = {
		["X-LC-Id"] = app_id,
		["X-LC-Key"] = app_key,
		["Content-Type"] = "application/json"
	}
	local result = httpRequest(url, "GET", header)
	return result.res
end

LeanEnginee = {}
LeanEnginee.__index = LeanEnginee

function LeanEnginee:new()
	local o = {}
    setmetatable(o, LeanEnginee)
	return o
end

function LeanEnginee:requestFunction(functionName, data)
	local postData = json.encode(data)
	local url = table.concat({BASE_URL, "functions", "/", functionName})
	local header = {
		["X-LC-Id"] = app_id,
		["X-LC-Key"] = app_key,
		["Content-Type"] = "application/json"
	}
	local result = httpRequest(url, "POST", header, postData)
	return result.res
end
