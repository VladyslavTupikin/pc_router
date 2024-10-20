# General

Current repo contains configuration file for dnsmaqs with configs of DHCP server on specific interface. Additionally repo contains script which allows to prepare network on you Linux PC or laptop to act like a router, giving local IP address to LAN client with access to the internet.
Tested on Linux Debian 12 and Accer laptop. WAN interface is WiFi interface, LAN interface is bridge br_rpi with ethernet interface. LAN client - Raspberry PI with RDKB image. Rapsberry PI successfully gets IP address on erouter0 interface and send traffic to the internetl. 
