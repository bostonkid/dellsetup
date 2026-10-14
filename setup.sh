#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=================================================="
echo " Starting Debian i3WM & URXVT Installation        "
echo "=================================================="

# 1. Update and Install Debian Packages
echo "Updating package repositories..."
sudo apt update && sudo apt upgrade -y

echo "Installing core i3 components and rxvt-unicode..."
PACKAGES=(
    i3 i3status i3lock dmenu xorg xinit 
    nitrogen picom rxvt-unicode rofi 
    lightdm lightdm-gtk-greeter 
    fonts-dejavu lxappearance pcmanfm network-manager
    mpv vlc axel chromium vim ranger xwinrap
)

sudo apt install -y "${PACKAGES[@]}"

# 2. Create Configuration Directories
echo "Creating user configuration folders..."
mkdir -p "$HOME/.config/i3"
mkdir -p "$HOME/.config/picom"
mkdir -p "$HOME/Pictures/Wallpapers"

# 3. Create Custom .Xresources Configuration for URXVT
# This gives urxvt a dark theme, proper padding, and scalable fonts
echo "Configuring rxvt-unicode (URXVT) visual styling..."
cat << 'EOF' > "$HOME/.Xresources"
! URXVT Configuration


! special
*.foreground:   #e0dcdb
*.background:   #040403
*.cursorColor:  #e0dcdb

! black
*.color0:       #090707
*.color8:       #fcd4c9

! red
*.color1:       #171413
*.color9:       #feb6e4

! green
*.color2:       #2b2524
*.color10:      #6adff1

! yellow
*.color3:       #453e3c
*.color11:      #b9b5f2

! blue
*.color4:       #665c5a
*.color12:      #f896d6

! magenta
*.color5:       #8f817d
*.color13:      #f7a88d

! cyan
*.color6:       #baadaa
*.color14:      #bbbe61

! white
*.color7:       #e5e2e1
*.color15:      #00d1e6



! Black color that will not be affected by bold highlighting.
*.color66: #131811
*color66:  #131811

! rofi setup
rofi.color-enabled:         true
rofi.separator-style:       solid
rofi.font:                  curieMedium 20
rofi.bw:                    2
rofi.columns:               1
rofi.yoffset:               0
rofi.fake-transparency:     false
rofi.hide-scrollbar:        true
!rofi.opacity:               90

rofi.location:              0
rofi.width:                 50
rofi.lines:                 10
rofi.fixed-num-lines:       true

!-------------------------------------------------------------------------------
! URxvt settings
!-------------------------------------------------------------------------------

!! URxvt Appearance
!Xterm*font:xft:Roboto Mono:regular:size=22
#!URxvt*font:xft:Hack:pixelsize=14:antialias=true,xft:Hack\Nerd\Font
URxvt.font: xft:Hack:pixelsize=14:antialias=true,xft:Hack\ Nerd\ Font:pixelsize=14:style=Regular:antialias=true
URxvt.font:xft:Monospace:pixelsize=16
URxvt.boldfont:xft:Monospace-Bold:pixelsize=16
URxvt.letterSpace: -1
URxvt.lineSpace: 0
URxvt.geometry: 90x28
URxvt.internalBorder: 15
URxvt.externalBorder: 0
URxvt.cursorBlink: true
URxvt.cursorUnderline: false
URxvt.saveline: 2048
URxvt.scrollBar: false
URxvt.scrollBar_right: false
URxvt.urgentOnBell: true
URxvt.depth: 32
URxvt.iso14755: false
URxvt.cursorColor: #FF69B4
#Urxvt.perl-ext-common: default,tabbed_new

URxvt.keysym.Control-Shift-V: eval:paste_clipboard
URxvt.perl-ext-common: default,ctrl_v_paste
URxvt.iso14755: false
URxvt.iso14755_52: false

URxvt.perl-ext-common: default,tabbed
URxvt.tabbed.new-button: true
URXvt.tabbed.reopen-on-close: yes
URxvt.keysym.Control-Shift-t: perl:tabbedex:new_tab
URxvt.keysym.Shift-Right: perl:tabbedex:next_tab
URxvt.keysym.Shift-Left: perl:tabbedex:prev_tab
URxvt.tabbed.no-tabbedex-keys: true


###### XTERM SETTINGS######
! xterm ----------------------------------------------------------------
xterm*saveLines:      4096
xterm*AllowIconInput: on
xterm*background:     #2E3440
xterm*foreground:     #D8DEE9
xterm*border:         #D8DEE9
xterm*faceName:       Hack
xterm*Font:           Hack
xterm*allowBoldFonts: false
xterm*renderFont:     true
xterm*faceSize:       9
xterm*InternalBorder: 0
xterm*MarginBell:     off
xterm*MenuFont:       fixed8
xterm*Mouse:          yellow
xterm*TitleFont:      vtbold
xterm*charClass:      33:48,37:48,45-47:48,64:48
xterm*colorAttrMode:  true
xterm*colorULMode:    true
!xterm*colorUL:       green
xterm*curses:         on
xterm*cutNewline:     off
xterm*jumpScroll:     on
xterm*multiClickTime: 500
xterm*multiScroll:    on
xterm*reverseWrap:    off
xterm*scrollBar:      off
xterm*reverseVideo:   off
xterm*VT100.Translations: #override \
    Ctrl Shift <Key>V:    insert-selection(CLIPBOARD) \n\
    Ctrl Shift <Key>C:    copy-selection(CLIPBOARD) \n\
    Ctrl <Btn1Up>: exec-formatted("xdg-open '%t'", PRIMARY)

EOF

# Merge the new Xresources configuration right away
xrdb -merge "$HOME/.Xresources" || true

# 4. Generate Custom Base i3 Configuration
echo "Writing custom i3 configuration..."
cat << 'EOF' > "$HOME/.config/i3/config"
# i3wm Debian Custom Configuration
set $mod Mod1

# Font for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
font pango:monospace 13

# This font is widely installed, provides lots of unicode glyphs, right-to-left
# text rendering and scalability on retina/hidpi displays (thanks to pango).
font pango:monospace 13

### Borders ###
new_window pixel 2
new_float pixel 2

### Gaps ###
set $default_gaps_inner 11
set $default_gaps_outer 5
gaps inner $default_gaps_inner
gaps outer $default_gaps_outer
smart_gaps on
smart_borders on

# Define color variables
set $focus_border    #BF00FF
set $focus_bg        #565656
set $focus_text      #ffffff
set $focus_indicator #2e9ef4
set $focus_child     #285577

set $unfocus_border    #B7121F
set $unfocus_bg        #76DFFF
set $unfocus_text      #888888
set $unfocus_indicator #292d2e
set $unfocus_child     #222222

# Apply colors to clients
# class           border         background text         indicator        child_border
client.focused    $focus_border  $focus_bg  $focus_text  $focus_indicator $focus_child
client.unfocused  $unfocus_border $unfocus_bg $unfocus_text $unfocus_indicator $unfocus_child

# Default layout
workspace_layout default 

# class                 border  backgr. text    indicator
client.focused          #BF00FF #BF00FF #000000 #BF00FF
client.focused_inactive #21FC0D #000000 #FFFFFF #21FC0D
client.unfocused        #7DF9FF #000000 #FFFFFF #000000
client.urgent           #7DF9FF #000000 #ffffff #000000
client.placeholder      #7DF9FF #000000 #ffffff #000000

for_window [class="mpv"] border pixel 0

# start a terminal
bindsym $mod+Return exec urxvt

# live wallpaper

#exec --no-startup-id xwinwrap -b -nf -ov -fs -- mpv -wid WID --loop --no-audio --panscan="1.0" /home/hp/Pictures/bground.mp4


# autostart programs
exec --no-startup-id autotiling
exec --no-startup-id picom -bf
exec --no-startup-id urxvt 

# start programs

# kill focused window
bindsym $mod+Shift+q kill

# start rofi 
bindsym $mod+d exec bash -c "rofi -show run" -font "FreeMono 12" -columns 5 -lines 1 -color-window "#FFFFFF" -hide-scrollbar -terminal urxvt

# change focus windows
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused windows alternatively, you can use the cursor keys:
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# split in horizontal orientation
bindsym $mod+h split h

# split in vertical orientation
bindsym $mod+v split v

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen toggle

# change container layout (stacked, tabbed, toggle split)
bindsym $mod+s layout stacking
bindsym $mod+z layout tabbed
bindsym $mod+x layout toggle split

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# focus the parent container
bindsym $mod+q focus parent

# switch to workspace
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5
bindsym $mod+6 workspace 6
bindsym $mod+7 workspace 7
bindsym $mod+8 workspace 8
bindsym $mod+9 workspace 9
bindsym $mod+10 workspace 10

# move focused container to workspace
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5
bindsym $mod+Shift+6 move container to workspace 6
bindsym $mod+Shift+7 move container to workspace 7
bindsym $mod+Shift+8 move container to workspace 8
bindsym $mod+Shift+9 move container to workspace 9
bindsym $mod+Shift+10 move container to workspace 10

# reload the configuration file
bindsym $mod+Shift+c reload

# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $mod+Shift+r restart

# exit i3 (logs you out of your X session)
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'exit i3' 'i3-msg exit'"

# resize window (you can also use the mouse for that)
bindsym $mod+r mode "resize"

mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

        # Pressing left will shrink the window’s width.
        # Pressing right will grow the window’s width.
        # Pressing up will shrink the window’s height.
        # Pressing down will grow the window’s height.
        bindsym j resize shrink width 10 px or 10 ppt
        bindsym k resize grow height 10 px or 10 ppt
        bindsym l resize shrink height 10 px or 10 ppt
        bindsym m resize grow width 10 px or 10 ppt

        # same bindings, but for the arrow keys
        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
        bindsym Right resize grow width 10 px or 10 ppt

        # back to normal: Enter or Escape
        bindsym Return mode "default"
        bindsym Escape mode "default"
}


EOF

# 5. Generate Minimal Picom Configuration
echo "Writing basic compositor settings..."
cat << 'EOF' > "$HOME/.config/picom/picom.conf"
backend = "xrender";
vsync = true;
active-opacity = 1.0;
inactive-opacity = 0.95;
frame-opacity = 1.0;
inactive-opacity-override = false;
EOF

echo "=================================================="
echo " Installation finished successfully!             "
echo "=================================================="
echo "Next Steps:"
echo "1. Reboot and select 'i3' at your login screen."
echo "2. Press Super+Return to launch URXVT."
