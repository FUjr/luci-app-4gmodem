local m
m = Map("4gmodem", translate("4G Modem"))



section = m:section(TypedSection, "modem", translate("Modem Settings"))
section.anonymous = true
section.addremove = false
    section:tab("base", translate("Base setting and information"))
    section:tab("dial", translate("Dial Setup"))
    section:tab("advanced", translate("Advanced Settings"))
	section:tab("redial", translate("Auto redial"))
    


	basetab_title = section:taboption('base',DummyValue, "titile", translate("Modem Information"))
	basetab_title.template = "4gmodem/basetab_title"

	modem_status = section:taboption("base", Value, translate("Modem Status"))
	modem_status.template = "4gmodem/modem_status"


    enable = section:taboption("dial", Flag, "enabled", translate("Enable"))
	enable.rmempty  = false

	advanced_dial_setting = section:taboption("dial", Flag,"advanced_dial_setting" ,translate("Advanced Dial Setting"))
	advanced_dial_setting.rmempty  = false
	advanced_dial_setting.default = 0

	device = section:taboption("dial",Value, "device", translate("Modem device"))
	device:depends("advanced_dial_setting", 1)
	device:value("auto", "auto")
	local device_suggestions = nixio.fs.glob("/dev/cdc-wdm*")
	if device_suggestions then
		local node
		for node in device_suggestions do
			device:value(node)
		end
	end
	local device_suggestions = nixio.fs.glob("/dev/ttyUSB*")
	if device_suggestions then
		local node
		for node in device_suggestions do
			device:value(node)
		end
	end
	
	log_enable = section:taboption("dial", Flag, "log_enabled", translate("Log Enable"))
	log_enable.rmempty  = false
	log_enable.default = 0
	log_enable:depends("advanced_dial_setting", 1)

	apn = section:taboption("dial", Value, "apn", translate("APN"))
	apn:depends("advanced_dial_setting", 1)

	username = section:taboption("dial", Value, "username", translate("PAP/CHAP Username"))
	username.optional  = true
	username:depends("advanced_dial_setting", 1)

	password = section:taboption("dial", Value, "password", translate("PAP/CHAP Password"))
	password.password = true
	password:depends("advanced_dial_setting", 1)


	pincode = section:taboption("dial", Value, "pincode", translate("PIN Code"))
	pincode:depends("advanced_dial_setting", 1)


	auth = section:taboption("dial", Value, "auth", translate("Authentication Type"))
	auth.rmempty = true
	auth:depends("advanced_dial_setting", 1)
	auth:value("", translate("-- Please choose --"))
	auth:value("both", "PAP/CHAP (both)")
	auth:value("pap", "PAP")
	auth:value("chap", "CHAP")
	auth:value("none", "NONE")

	tool = section:taboption("dial", Value, "tool", translate("Tools"))
	tool:value("quectel-CM", "quectel-CM")
	tool:value("ls_dial", "ls_dial")
	tool:value("auto", "auto")
	tool.rmempty = true
	tool:depends("advanced_dial_setting", 1)

	PdpType= section:taboption("dial", Value, "pdptype", translate("PdpType"))
	PdpType:value("IPv4", "IPv4")
	PdpType:value("IPv6", "IPv6")
	PdpType:value("IPv4v6", "IPv4v6")
	PdpType.rmempty = true

	ttl  = section:taboption('advanced',Value, "ttl", translate("TTL"))
	ttl.default = 64
	ttl.datatype = "range(1,255)"
	ttl.rmempty = false

	ttl_enable = section:taboption('advanced',Flag, "ttl_enabled", translate("TTL Enable"))
	ttl_enable.rmempty = false
	ttl_enable.default = 0

    set_imei = section:taboption('advanced',DummyValue, "set_imei_button", translate("Set IMEI"))
    set_imei.template = "4gmodem/set_imei"
    
    band_section = section:taboption('advanced',DummyValue, "set_band_button", translate("Set BAND"))
    band_section.template = "4gmodem/set_lock_band"


	redial_enable = section:taboption('redial',Flag, "redial_enabled", translate("Auto redial Enable"))
	redial_enable.rmempty = false
	redial_enable.default = 1
	
	redial_time_hour = section:taboption('redial',Value, "redial_time_hour", translate("Auto redial (Hour)"))
	redial_time_hour.default = 0
	redial_time_hour.datatype = "range(0,23)"
	redial_time_hour:depends("redial_enabled", 1)

	redial_time_min = section:taboption('redial',Value, "redial_time_min", translate("Auto redial (Minute)"))
	redial_time_min.default = 0
	redial_time_min.datatype = "range(0,59)"
	redial_time_min:depends("redial_enabled", 1)

	redial_time_week = section:taboption('redial',Value, "redial_time_week", translate("Auto redial (Week)"))
	redial_time_week.default = '*'
	redial_time_week:depends("redial_enabled", 1)
	redial_time_week:value('*', translate("Everyday"))
	redial_time_week:value(1, translate("Monday"))
	redial_time_week:value(2, translate("Tuesday"))
	redial_time_week:value(3, translate("Wednesday"))
	redial_time_week:value(4, translate("Thursday"))
	redial_time_week:value(5, translate("Friday"))
	redial_time_week:value(6, translate("Saturday"))
	redial_time_week:value(7, translate("Sunday"))


return m
