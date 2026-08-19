#!/usr/bin/env bash
# Mango 会话入口：先把 compositor 环境交给 systemd，再启动所有会话限定服务。
set -euo pipefail

dbus-update-activation-environment --systemd \
  DISPLAY \
  WAYLAND_DISPLAY \
  XDG_CURRENT_DESKTOP \
  XDG_SESSION_TYPE \
  NIXOS_OZONE_WL \
  QT_IM_MODULE \
  SDL_IM_MODULE \
  XMODIFIERS \
  XCURSOR_THEME \
  XCURSOR_SIZE \
  MANGO_INSTANCE_SIGNATURE

systemctl --user reset-failed
systemctl --user start mango-session.target
