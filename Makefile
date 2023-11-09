#将openwrt顶层目录下的rules.mk文件中的内容导入进来
include $(TOPDIR)/rules.mk
#软件包名
PKG_NAME:=luci-app-4gmodem
#软件包版本
PKG_VERSION:=5.0.1
#真正编译当前软件包的目录
PKG_BUILD_DIR:= $(BUILD_DIR)/$(PKG_NAME)
 
 
 #将$(TOPDIR)/include目录下的package.mk文件中的内容导入进来
include $(TOPDIR)/rules.mk
 
LUCI_DEPENDS:= +luci +bc +luci-compat +kmod-usb-net  +kmod-usb-net-cdc-ether +kmod-usb-acm \
		+kmod-usb-net-qmi-wwan  +kmod-usb-net-rndis +gl-modem-at\
		+kmod-usb-ohci +kmod-usb-serial \
		+kmod-usb-serial-option +kmod-usb-wdm \
		+kmod-usb2 +kmod-usb-net-cdc-mbim +quectel-CM-5G
LUCI_TITLE:=LuCI Support for 4gmodem
PKG_LICENSE:=GPLv3
LUCI_PKGARCH:=all
PKG_LINCESE_FILES:=LICENSE
PKG_MAINTAINER:=Tom <github.com/Fujr>

include $(TOPDIR)/feeds/luci/luci.mk
# call BuildPackage - OpenWrt buildroot signature
