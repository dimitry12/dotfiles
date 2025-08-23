lock:
	termux-wake-lock

unlock:
	termix-wake-unlock

ubuntu:
	proot-distro login ubuntu --user dzmitry --shared-tmp

ubuntu_su:
	proot-distro login ubuntu --shared-tmp

kill_termux_x11:
	pkill -f com.termux.x11

x11_term:
	termux-x11 :1 -xstartup "dbus-launch --exit-with-session kitty"

x11_xfce:
	termux-x11 :1 -xstartup "xfce4-session"

wip:
	termux-x11 :1 &
	env DISPLAY=:1 dbus-launch kitty &
	env DISPLAY=:1 xdotool search kitty
	env DISPLAY=:1 xdotool windowsize 2097160 1920 1280
	pkill -f com.termux.x11

x11:
	export LD_PRELOAD=/system/lib64/libskcodec.so && pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
	termux-x11 :1 -xstartup "xfce4-session"
