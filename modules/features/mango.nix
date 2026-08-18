# Mango 会话：官方 NixOS/HM 模块、结构化合成器配置与会话限定的独立桌面栈。
_: {
  den.aspects.mango = {
    nixos = {
      # 上游模块同时提供登录会话、XWayland、Polkit 与 Mango 专用 portal；共享层不重复接管。
      programs.mango = {
        addLoginEntry = true;
        enable = true;
      };
    };

    provides.to-users.homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        dotfiles = "${config.home.homeDirectory}/Documents/nix-dotfiles/dotfiles";
        link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
        mangoPackage = config.wayland.windowManager.mango.package;

        footCommand = ''foot --config="$HOME/.config/mango/foot/foot.ini"'';
        screenshotCommand =
          mode:
          ''${lib.getExe pkgs.bash} "$HOME/.config/mango/scripts/screenshot.sh" ${lib.getExe pkgs.grim} ${lib.getExe pkgs.slurp} ${lib.getExe pkgs.satty} ${mode}'';
        clipboardCommand = ''${lib.getExe pkgs.bash} "$HOME/.config/mango/scripts/cliphist-rofi.sh" ${lib.getExe pkgs.cliphist} ${lib.getExe pkgs.rofi} ${pkgs.wl-clipboard}/bin/wl-copy'';

        mkMangoService =
          {
            description,
            execStart,
            after ? [ ],
            serviceConfig ? { },
          }:
          {
            Unit = {
              Description = description;
              After = [ "mango-session.target" ] ++ after;
              PartOf = [ "mango-session.target" ];
            };
            Service = {
              ExecStart = execStart;
              Restart = "on-failure";
              RestartSec = 2;
            }
            // serviceConfig;
            Install.WantedBy = [ "mango-session.target" ];
          };
      in
      {
        home.packages = builtins.attrValues {
          inherit (pkgs)
            blueman
            networkmanagerapplet
            pamixer
            polkit_gnome
            rofi
            sway-audio-idle-inhibit
            swaybg
            swayidle
            swaylock-effects
            swaynotificationcenter
            swayosd
            waybar
            wlogout
            wlsunset
            xrdb
            ;
        };

        # 根配置由上游 HM 模块生成并用 `mango -p` 校验；非空 autostart 触发其环境导入与 target 启动。
        wayland.windowManager.mango = {
          autostart_sh = ":";
          enable = true;
          systemd = {
            enable = true;
            # guard 依赖实例 socket；导入后才能在 compositor 退出时自动收拢整个 target。
            variables = [
              "DISPLAY"
              "WAYLAND_DISPLAY"
              "XDG_CURRENT_DESKTOP"
              "XDG_SESSION_TYPE"
              "NIXOS_OZONE_WL"
              "XCURSOR_THEME"
              "XCURSOR_SIZE"
              "MANGO_INSTANCE_SIGNATURE"
            ];
          };
          topPrefixes = [ "env" ];
          bottomPrefixes = [
            "monitorrule"
            "tagrule"
            "windowrule"
            "layerrule"
            "bind"
            "mousebind"
            "axisbind"
            "gesturebind"
          ];
          settings = {
            env = [
              "GTK_IM_MODULE,fcitx"
              "QT_IM_MODULE,fcitx"
              "SDL_IM_MODULE,fcitx"
              "XMODIFIERS,@im=fcitx"
              "QT_QPA_PLATFORM,wayland;xcb"
              "XCURSOR_THEME,Bibata-Modern-Classic"
              "XCURSOR_SIZE,24"
            ];

            # 参考配置的深棕/Gruvbox 视觉，收敛动画时长以免切换 tag 显得拖沓。
            animations = 1;
            layer_animations = 1;
            animation_type_open = "slide";
            animation_type_close = "slide";
            layer_animation_type_open = "fade";
            layer_animation_type_close = "fade";
            animation_fade_in = 1;
            animation_fade_out = 1;
            animation_duration_move = 260;
            animation_duration_open = 220;
            animation_duration_tag = 240;
            animation_duration_close = 180;
            animation_duration_focus = 160;
            animation_curve_open = "0.46,1.0,0.29,1.0";
            animation_curve_move = "0.46,1.0,0.29,1.0";
            animation_curve_tag = "0.46,1.0,0.29,1.0";
            animation_curve_close = "0.08,0.92,0.0,1.0";
            animation_curve_focus = "0.46,1.0,0.29,1.0";

            shadows = 1;
            layer_shadows = 1;
            shadow_only_floating = 1;
            shadows_size = 12;
            shadows_blur = 15;
            shadowscolor = "0x000000aa";
            border_radius = 8;
            no_radius_when_single = 0;
            focused_opacity = 1.0;
            unfocused_opacity = 0.9;
            gappih = 6;
            gappiv = 6;
            gappoh = 14;
            gappov = 14;
            borderpx = 3;
            rootcolor = "0x201b14ff";
            bordercolor = "0x504945ff";
            focuscolor = "0xd79921ff";
            urgentcolor = "0xcc241dff";
            overlaycolor = "0x8ec07cff";

            # tile 是 1–9 的稳定默认；快捷键仍可在 tile/scroller/dwindle 间循环。
            circle_layout = "tile,scroller,dwindle";
            scroller_structs = 20;
            scroller_default_proportion = 0.8;
            scroller_focus_center = 0;
            scroller_prefer_center = 1;
            scroller_default_proportion_single = 1.0;
            scroller_proportion_preset = "0.5,0.8,1.0";
            new_is_master = 1;
            smartgaps = 0;
            default_mfact = 0.55;
            default_nmaster = 1;
            dwindle_smart_split = 0;
            dwindle_drop_simple_split = 1;
            dwindle_preserve_split = 1;

            enable_hotarea = 1;
            hotarea_size = 10;
            ov_tab_mode = 0;
            overviewgappi = 6;
            overviewgappo = 24;

            xwayland_persistence = 1;
            # 当前 NVIDIA 驱动先关闭显式同步；若 Mango 不稳定可在 greeter 直接回退 Niri。
            syncobj_enable = 0;
            focus_on_activate = 1;
            sloppyfocus = 0;
            warpcursor = 1;
            focus_cross_monitor = 0;
            focus_cross_tag = 0;
            enable_floating_snap = 1;
            snap_distance = 24;
            cursor_size = 24;
            cursor_theme = "Bibata-Modern-Classic";
            drag_tile_to_tile = 1;
            repeat_rate = 25;
            repeat_delay = 600;
            numlockon = 1;
            xkb_rules_layout = "us";
            tap_to_click = 1;
            tap_and_drag = 1;
            drag_lock = 1;
            trackpad_disable_while_typing = 1;

            monitorrule = [ "name:eDP-1,scale:1.25,vrr:1" ];
            tagrule = map (tag: "id:${toString tag},layout_name:tile") (lib.range 1 9);

            windowrule = [
              "isfloating:1,appid:^Rofi$"
              "isnoborder:1,appid:^Rofi$"
              "isfloating:1,appid:^xdg-desktop-portal-gtk$"
              "isfloating:1,appid:^blueman-manager$"
              "isoverlay:1,appid:^com.gabm.satty$"
              "unfocused_opacity:1.0,focused_opacity:1.0,appid:^foot$"
            ];
            layerrule = [
              "noshadow:1,layer_name:swaync-control-center"
              "noshadow:1,layer_name:swaync-notification-window"
              "animation_type_open:fade,layer_name:swaync-control-center"
              "animation_type_close:fade,layer_name:swaync-control-center"
              "animation_type_open:fade,layer_name:swayosd"
              "animation_type_close:fade,layer_name:swayosd"
            ];

            bind = [
              "SUPER,Return,spawn_shell,${footCommand}"
              "SUPER,t,spawn_shell,${footCommand}"
              "SUPER,slash,spawn_shell,${footCommand} --app-id=quickterminal"
              "SUPER,b,spawn,zen-twilight"
              "SUPER+ALT,b,spawn,brave"
              "SUPER,e,spawn,thunar"
              "SUPER+ALT,o,spawn_shell,${footCommand} --app-id=opencode -e opencode"
              ''SUPER,z,spawn_shell,${lib.getExe pkgs.rofi} -config "$HOME/.config/mango/rofi/config.rasi" -show drun''
              "SUPER,space,spawn,${pkgs.swaynotificationcenter}/bin/swaync-client -t"
              "SUPER+SHIFT,n,spawn,${pkgs.swaynotificationcenter}/bin/swaync-client -t"
              ''SUPER+SHIFT,p,spawn_shell,${lib.getExe pkgs.wlogout} -C "$HOME/.config/mango/wlogout/style.css" -l "$HOME/.config/mango/wlogout/layout" -b 6 --protocol layer-shell''
              "SUPER+ALT,v,spawn_shell,${clipboardCommand}"
              "ALT,Tab,togglejump"

              "SUPER,o,toggleoverview,1"
              "SUPER,g,toggleoverview,1"
              "SUPER,q,killclient,"
              "SUPER,v,togglefloating,"
              "SUPER,f,togglemaximizescreen,"
              "SUPER+ALT,f,togglefullscreen,"
              "SUPER,r,switch_proportion_preset,"
              "SUPER+ALT,r,switch_layout,"
              "SUPER+SHIFT,r,reload_config,"
              "SUPER+SHIFT,e,quit,"
              "SUPER,Tab,focusstack,next"
              "SUPER+SHIFT,Tab,focusstack,prev"
              "SUPER,minus,setmfact,-0.05"
              "SUPER,equal,setmfact,+0.05"

              "SUPER,Left,focusdir,left"
              "SUPER,Down,focusdir,down"
              "SUPER,Up,focusdir,up"
              "SUPER,Right,focusdir,right"
              "SUPER,h,focusdir,left"
              "SUPER,j,focusdir,down"
              "SUPER,k,focusdir,up"
              "SUPER,l,focusdir,right"
              "SUPER+CTRL,Left,exchange_client,left"
              "SUPER+CTRL,Down,exchange_client,down"
              "SUPER+CTRL,Up,exchange_client,up"
              "SUPER+CTRL,Right,exchange_client,right"
              "SUPER+CTRL,h,exchange_client,left"
              "SUPER+CTRL,j,exchange_client,down"
              "SUPER+CTRL,k,exchange_client,up"
              "SUPER+CTRL,l,exchange_client,right"

              "SUPER,u,viewtoleft_have_client,0"
              "SUPER,i,viewtoright_have_client,0"
              "SUPER+CTRL,u,tagtoleft,0"
              "SUPER+CTRL,i,tagtoright,0"
            ]
            ++ map (tag: "SUPER,${toString tag},view,${toString tag},0") (lib.range 1 9)
            ++ map (tag: "SUPER+CTRL,${toString tag},tag,${toString tag},0") (lib.range 1 9)
            ++ [
              "SUPER+SHIFT,Left,focusmon,left"
              "SUPER+SHIFT,Down,focusmon,down"
              "SUPER+SHIFT,Up,focusmon,up"
              "SUPER+SHIFT,Right,focusmon,right"
              "SUPER+CTRL+SHIFT,Left,tagmon,left"
              "SUPER+CTRL+SHIFT,Down,tagmon,down"
              "SUPER+CTRL+SHIFT,Up,tagmon,up"
              "SUPER+CTRL+SHIFT,Right,tagmon,right"

              "SUPER+ALT,l,spawn,${pkgs.swaylock-effects}/bin/swaylock -f -c 201b14"
              "SUPER+ALT,p,spawn_shell,${pkgs.swaylock-effects}/bin/swaylock -f -c 201b14 & sleep 1; ${pkgs.systemd}/bin/systemctl suspend"
              "NONE,Print,spawn_shell,${screenshotCommand "region"}"
              "SHIFT,Print,spawn_shell,${screenshotCommand "output"}"
              "SUPER+SHIFT,s,spawn_shell,${screenshotCommand "annotate"}"

              "NONE,XF86AudioRaiseVolume,spawn,${pkgs.swayosd}/bin/swayosd-client --output-volume +5"
              "NONE,XF86AudioLowerVolume,spawn,${pkgs.swayosd}/bin/swayosd-client --output-volume -5"
              "NONE,XF86AudioMute,spawn,${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle"
              "NONE,XF86MonBrightnessUp,spawn,${pkgs.swayosd}/bin/swayosd-client --brightness +5"
              "NONE,XF86MonBrightnessDown,spawn,${pkgs.swayosd}/bin/swayosd-client --brightness -5"
              "NONE,XF86AudioPlay,spawn,${lib.getExe pkgs.playerctl} play-pause"
              "NONE,XF86AudioNext,spawn,${lib.getExe pkgs.playerctl} next"
              "NONE,XF86AudioPrev,spawn,${lib.getExe pkgs.playerctl} previous"
            ];
            mousebind = [
              "SUPER,btn_left,moveresize,curmove"
              "SUPER,btn_right,moveresize,curresize"
              "SUPER,btn_middle,killclient,"
            ];
            axisbind = [
              "SUPER,UP,viewtoleft_have_client"
              "SUPER,DOWN,viewtoright_have_client"
            ];
            gesturebind = [
              "NONE,left,3,focusdir,left"
              "NONE,right,3,focusdir,right"
              "NONE,up,4,toggleoverview,1"
              "NONE,down,4,toggleoverview,1"
            ];
          };
        };

        # 只链接独立组件；~/.config/mango/config.conf 与 autostart 继续由 HM/上游模块拥有。
        xdg.configFile = {
          "mango/Xresources".source = link "mango/Xresources";
          "mango/foot".source = link "mango/foot";
          "mango/rofi".source = link "mango/rofi";
          "mango/scripts".source = link "mango/scripts";
          "mango/swaync".source = link "mango/swaync";
          "mango/waybar".source = link "mango/waybar";
          "mango/wlogout".source = link "mango/wlogout";
        };

        systemd.user.services = {
          mango-session-guard = mkMangoService {
            description = "Mango session lifetime guard";
            execStart = "${mangoPackage}/bin/mmsg watch all-monitors";
            # IPC socket 关闭即说明 compositor 已退出；异步停止 target 避免 ExecStopPost 自等待。
            serviceConfig = {
              ExecStopPost = "${pkgs.systemd}/bin/systemctl --user --no-block stop mango-session.target";
              Restart = "no";
            };
          };
          mango-waybar = mkMangoService {
            description = "Mango Waybar";
            execStart = "${lib.getExe pkgs.waybar} -c %h/.config/mango/waybar/config.json -s %h/.config/mango/waybar/style.css";
          };
          mango-swaync = mkMangoService {
            description = "Mango notification center";
            execStart = "${pkgs.swaynotificationcenter}/bin/swaync -c %h/.config/mango/swaync/config.json -s %h/.config/mango/swaync/style.css";
          };
          mango-wallpaper = mkMangoService {
            description = "Mango wallpaper";
            execStart = "${lib.getExe pkgs.bash} %h/.config/mango/scripts/wallpaper.sh ${lib.getExe pkgs.swaybg}";
          };
          mango-swayosd = mkMangoService {
            description = "Mango volume and brightness OSD";
            execStart = "${pkgs.swayosd}/bin/swayosd-server";
          };
          mango-swayidle = mkMangoService {
            description = "Mango idle policy";
            execStart = ''
              ${lib.getExe pkgs.swayidle} -w \
                timeout 600 '${pkgs.swaylock-effects}/bin/swaylock -f -c 201b14' \
                timeout 900 '${mangoPackage}/bin/mmsg dispatch sleep_monitor,eDP-1' \
                  resume '${mangoPackage}/bin/mmsg dispatch wakeup_monitor,eDP-1' \
                timeout 1800 '${pkgs.systemd}/bin/systemctl suspend' \
                before-sleep '${pkgs.swaylock-effects}/bin/swaylock -f -c 201b14'
            '';
          };
          mango-wlsunset = mkMangoService {
            description = "Mango night light";
            execStart = "${lib.getExe pkgs.wlsunset} -T 6500 -t 3500";
          };
          mango-clip-persist = mkMangoService {
            description = "Mango persistent clipboard";
            execStart = "${lib.getExe pkgs.wl-clip-persist} --clipboard regular --reconnect-tries 0";
          };
          mango-cliphist-text = mkMangoService {
            description = "Mango text clipboard history";
            execStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${lib.getExe pkgs.cliphist} store";
          };
          mango-cliphist-image = mkMangoService {
            description = "Mango image clipboard history";
            execStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${lib.getExe pkgs.cliphist} store";
          };
          mango-network-applet = mkMangoService {
            description = "Mango NetworkManager applet";
            execStart = "${lib.getExe pkgs.networkmanagerapplet} --indicator";
          };
          mango-bluetooth-applet = mkMangoService {
            description = "Mango Bluetooth applet";
            execStart = "${pkgs.blueman}/bin/blueman-applet";
          };
          mango-polkit-agent = mkMangoService {
            description = "Mango Polkit agent";
            execStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          };
          mango-audio-idle-inhibitor = mkMangoService {
            description = "Mango audio idle inhibitor";
            execStart = lib.getExe pkgs.sway-audio-idle-inhibit;
          };
          mango-fcitx5 = mkMangoService {
            description = "Mango input method";
            execStart = "${pkgs.fcitx5}/bin/fcitx5 --replace";
          };
          mango-udiskie = mkMangoService {
            description = "Mango removable media automounter";
            execStart = "${lib.getExe pkgs.udiskie} --automount --tray";
          };
          mango-xsettingsd = mkMangoService {
            description = "Mango XSettings bridge";
            execStart = lib.getExe pkgs.xsettingsd;
          };
          mango-xwayland-dpi = mkMangoService {
            description = "Mango XWayland DPI";
            execStart = "${lib.getExe pkgs.xrdb} -merge %h/.config/mango/Xresources";
            serviceConfig = {
              RemainAfterExit = true;
              Restart = "no";
              Type = "oneshot";
            };
          };
        };
      };
  };
}
