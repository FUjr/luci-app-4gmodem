module("luci.controller.admin.4gmodem", package.seeall) 
I18N = require "luci.i18n"
translate = I18N.translate
function index()
	entry({"admin", "4gmodem"}, firstchild(), translate("Cellular"), 25).dependent=false
	entry({"admin", "4gmodem", "4gmodem"}, cbi('4gmodem/4gmodem'), translate("Modem Settings"))
	entry({"admin", "4gmodem", "get_modem_status"}, call("get_modem_status"))
	entry({"admin", "4gmodem", "set_imei"}, call("set_imei"))
	entry({"admin", "4gmodem", "get_imei"}, call("get_imei"))
	entry({"admin", "4gmodem", "set_lock_band"}, call("set_lock_band"))
	entry({"admin", "4gmodem", "set_lock_rat"}, call("set_lock_rat"))
	entry({"admin","4gmodem","run_func"}, call("run_func"))
end

function set_imei()
	local cfg = luci.http.formvalue("cfg")
	local imei = luci.http.formvalue("imei")
	local set_imei = luci.sys.exec('/usr/libexec/modem_ctrl set_imei ' .. cfg .. ' ' .. imei)
	if set_imei  then
		luci.http.prepare_content("application/json")
		luci.http.write_json({set_status = set_imei})
	else
		luci.http.prepare_content("application/json")
		luci.http.write_json({set_status = "fail"})
	end
end

function set_lock_band()
	local cfg = luci.http.formvalue("cfg")
	local band = luci.http.formvalue("band_list")
	lock_band = luci.sys.exec('/usr/libexec/modem_ctrl lock_band ' .. cfg .. ' ' .. band)

	luci.http.prepare_content("application/json")
	luci.http.write_json({set_status = lock_band})

end

function set_lock_rat()
	local cfg = luci.http.formvalue("cfg")
	local band = luci.http.formvalue("RAT")
	lock_band = luci.sys.exec('/usr/libexec/modem_ctrl lock_rat ' .. cfg .. ' ' .. band)

	luci.http.prepare_content("application/json")
	luci.http.write_json({set_status = lock_band})

end

function get_modem_status()
	local cfg = luci.http.formvalue("cfg")
	local need_translate = luci.http.formvalue("need_translate")
	local category = luci.http.formvalue("category")
	--可以传入一个或多个，用逗号分隔,如果不传入则默认为Signal,Module,SIM,CellInfo,LockBand
	if (category == nil) then
		category = 'Signal,Module,SIM,CellInfo,LockBand,GetFunc'
	end
	local allow_category = {Signal = 30 , Module = 600, SIM = 60, CellInfo = 60, LockBand = 60, GetFunc = 5}
	local force_refresh = luci.http.formvalue("force_refresh")
	local res = {}

	cate_list = {}
	for cate in string.gmatch(category, '([^,]+)') do
		local timeout = allow_category[cate]
		if (timeout == nil) then
			rv = { status = 'not allow category'}
		else
			rv = fetch_data(cfg,cate,timeout,force_refresh)
			if (need_translate) then
				for k,v in pairs(rv) do
					translate_k = translate(k)
					if (translate_k ~= k) then
						rv[translate_k] = v
						rv[k] = nil
					end
				end
			end
		end
		res[cate] = rv
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(res)
end



function fetch_data(cfg,category,timeout,force_refresh)
	local category = category
	local file_name = '/tmp/cpe_' .. category .. '_' .. cfg .. '.json'
	if (force_refresh) then
		luci.sys.exec('/usr/libexec/modem_ctrl ' .. category .. ' ' .. cfg)
	end
	if ( not nixio.fs.stat(file_name) ) then
		luci.sys.exec('/usr/libexec/modem_ctrl ' .. category .. ' ' .. cfg)
	end
	if (nixio.fs.stat(file_name)) then
		-- 检查是否超时
		if (os.time() - nixio.fs.stat(file_name).mtime) > timeout then
			luci.sys.exec('/usr/libexec/modem_ctrl ' .. category .. ' ' .. cfg)
		end
		file = io.open(file_name, "r")
		rv = luci.jsonc.parse(file:read("*all"))
		file:close()
		if (rv == nil) then
			rv = { data_status = 'timeout'}
		else
			-- status 返回文件更新时间 以HH:MM:SS格式
			rv['data_status'] = os.date("%H:%M:%S", nixio.fs.stat(file_name).mtime)
		end
	else
		rv = { data_status = 'timeout'}
	end
	return rv
end

function run_func()
	cfg = luci.http.formvalue("cfg")
	func = luci.http.formvalue("func")
	res = luci.sys.exec('/usr/libexec/modem_ctrl run_func '  .. cfg .. ' ' .. func)
	luci.http.prepare_content("application/json")
	luci.http.write_json({msg = res})
end
