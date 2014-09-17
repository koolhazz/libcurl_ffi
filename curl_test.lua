local libcurl 	= require("libcurl")
local ffi 		= require("ffi")

local str = {}

local table = table

local function print_html(ptr, sz, nu, userdata)
	local _str = ffi.string(ptr, nu * sz)

	table.insert(str, _str)

	return nu
end

local function to_json()
	return "{\"id\":\"99\", \"sitemid\":\"100\"}"
end

local function error_handle(_c, errno)
	print("EMSG: "..errno..ffi.string(_curl:strerror()))
end


local function get_test()
	local _curl = libcurl.CURL:new()

	if _curl:init() then
		_curl:set_writefunction(print_html)
		_curl:set_url("www.ifeng.com")

		local res = _curl:perform()

		if  res == 0 then
			print(table.concat(str, nil))
		else
			print("failed"..res)
		end

		_curl:cleanup()
	end
end

local function post_test()
	local _curl = libcurl.CURL:new()

	if _curl:init() then
		_curl:set_url("http://www.ifeng.com/")
		_curl:set_post(1)
		_curl:set_postfields("json="..to_json())
		_curl:set_writefunction(print_html)

		print(to_json())

		local _res = _curl:perform()

		if _res == 0 then
			print(table.concat(str, nil))
		else
			error_handle(_curl, _res)
		end

		_curl:cleanup()
	end
end

post_test()

--get_test()
