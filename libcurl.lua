module(..., package.seeall)

local ffi = require 'ffi'
ffi.cdef[[
    void *curl_easy_init();
	int curl_easy_setopt(void *curl, int option, ...);
	int curl_easy_perform(void *curl);
	void curl_easy_cleanup(void *curl);
	char *curl_easy_strerror(int code);

	struct curl_slist {
  		char *data;
  		struct curl_slist *next;
	};

	struct curl_slist *curl_slist_append(struct curl_slist *list, const char * string);

	const char *curl_easy_strerror(int errornum);
]]
local libcurl = ffi.load('libcurl')

CURL = {
	__handle 	= nil,
	__res 		= 0,
	__headers 	= nil,
	__read_cb	= nil,
	__write_cb 	= nil,
}

OPT = {
	CURLOPT_URL 			= 10002,
	CURLOPT_POST 			= 47,
	CURLOPT_HTTPPOST 		= 10024,
	CURLOPT_HTTPHEADER		= 10023,
	CURLOPT_WRITEFUNCTION	= 20011,
	CURLOPT_READFUNCTION	= 20012,
	CURLOPT_POSTFIELDS		= 10015,
}

local function curl_easy_setopt(_handle, _option, arg)
	return libcurl.curl_easy_setopt(_handle, _option, arg)
end

function CURL:new(o)
	o = o or {}

	setmetatable(o, self)

	self.__index = self

	return o	
end

function CURL:init()
	self.__handle = libcurl.curl_easy_init()

	return self.__handle and true or false
end

function CURL:perform()
	self.__res = libcurl.curl_easy_perform(self.__handle)

	return self.__res
end

function CURL:cleanup()
	libcurl.curl_easy_cleanup(self.__handle)
end

function CURL:add_header(_h)
	self.__headers = libcurl.easy_slist_append(self.__headers, _h)

	return self.__headers and 0 or 1
end

function CURL:set_headers()
	return curl_easy_setopt(self.__handle, OPT.CURLOPT_HTTPHEADER, self.__headers)
end

function CURL:set_url(_u)
	return curl_easy_setopt(self.__handle, OPT.CURLOPT_URL, _u)
end
	
function CURL:set_post(_b)
	return curl_easy_setopt(self.__handle, OPT.CURLOPT_POST, _b)
end

function CURL:set_httppost(_b)
	return curl_easy_setopt(self.__handle, OPT.CURLOPT_HTTPPOST, _b)
end

function CURL:set_writefunction(cb)
	self.__write_cb = ffi.cast("size_t (*)(char*, size_t, size_t, void*)", cb)

	return curl_easy_setopt(self.__handle, OPT.CURLOPT_WRITEFUNCTION, self.__write_cb)
end

function CURL:set_readfunction(cb)
	self.__read_cb = ffi.cast("size_t (*)(char*, size_t, size_t, void*)", cb)

	return curl_easy_setopt(self.__handle, OPT.CURLOPT_READFUNCTION, self.__read_cb)
end

function CURL:strerror()
	return libcurl.curl_easy_strerror(self.__res)
end

function CURL:set_postfields(_f)
	return curl_easy_setopt(self.__handle, OPT.CURLOPT_POSTFIELDS, _f)
end


