# 仓库级检查：安装变体契约、双合成器配置、Shell、静态格式及双语文档。
{
  inputs,
  lib,
  self,
  ...
}:
let
  hostsDir = ../../hosts;
  hostDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir);
  hostNames = builtins.attrNames hostDirs;
  hostParams = lib.mapAttrs (name: _: import (hostsDir + "/${name}/host.nix")) hostDirs;

  hostContractHolds =
    name:
    let
      normal = self.nixosConfigurations.${name}.config;
      install = self.nixosConfigurations."${name}-install".config;
      params = hostParams.${name};
      proxy = params.proxy or null;
      userNames = builtins.attrNames params.users;
    in
    normal.networking.hostName == name
    && install.networking.hostName == name
    && normal.nix.settings.sandbox
    && install.nix.settings.sandbox
    && normal.services.flatpak.enable
    && !install.services.flatpak.enable
    && normal.age.secrets != { }
    && install.age.secrets == { }
    && builtins.hasAttr "home-manager" normal
    && !(builtins.hasAttr "home-manager" install)
    && normal.programs.niri.enable
    && normal.programs.mango.enable
    && install.programs.niri.enable
    && !install.programs.mango.enable
    && normal.programs.noctalia-greeter.settings.session.default == "niri"
    && install.programs.noctalia-greeter.settings.session.default == "niri"
    && lib.all (user: builtins.hasAttr user normal."home-manager".users) userNames
    && lib.all (user: normal."home-manager".users.${user}.wayland.windowManager.mango.enable) userNames
    && lib.all (
      user:
      builtins.elem "wheel" normal.users.users.${user}.extraGroups
      == (params.users.${user}.isAdmin or false)
      &&
        normal.users.users.${user}.openssh.authorizedKeys.keys
        == (params.users.${user}.sshAuthorizedKeys or [ ])
    ) userNames
    && normal.systemd.services.v2raya.environment.V2RAYA_ADDRESS == "127.0.0.1:2017"
    && (
      proxy == null
      || (
        normal.networking.proxy.default == proxy.default
        && normal.networking.proxy.noProxy == (proxy.noProxy or null)
      )
    );
  failedContractHosts = lib.filter (name: !(hostContractHolds name)) hostNames;
  # 引用 source 会把上游 HM 模块内置的 `mango -p` 验证纳入 flake check。
  mangoConfigSources = lib.concatMap (
    name:
    let
      normal = self.nixosConfigurations.${name}.config;
      userNames = builtins.attrNames hostParams.${name}.users;
    in
    map (user: normal."home-manager".users.${user}.xdg.configFile."mango/config.conf".source) userNames
  ) hostNames;
in
{
  perSystem =
    { pkgs, system, ... }:
    {
      checks = {
        install-contract =
          assert lib.assertMsg (failedContractHosts == [ ])
            "normal/install configuration contract failed for: ${lib.concatStringsSep ", " failedContractHosts}";
          pkgs.runCommand "install-contract" { } ''
            test -x ${inputs.disko.packages.${system}.disko}/bin/disko
            touch "$out"
          '';

        shellcheck = pkgs.runCommand "shellcheck" { nativeBuildInputs = [ pkgs.shellcheck ]; } ''
          cd ${self}
          shellcheck --severity=warning init.sh dotfiles/niri/scripts/* dotfiles/mango/scripts/*.sh
          touch "$out"
        '';

        niri-config = pkgs.runCommand "niri-config" { nativeBuildInputs = [ pkgs.niri ]; } ''
          cp -R ${self}/dotfiles/niri "$TMPDIR/niri"
          chmod -R u+w "$TMPDIR/niri"
          touch "$TMPDIR/niri/noctalia.kdl"
          niri validate --config "$TMPDIR/niri/config.kdl"
          touch "$out"
        '';

        mango-config = pkgs.runCommand "mango-config" { } ''
          ${lib.concatMapStringsSep "\n" (source: "test -s ${source}") mangoConfigSources}
          touch "$out"
        '';

        static-syntax =
          pkgs.runCommand "static-syntax"
            {
              nativeBuildInputs = with pkgs; [
                jq
                libxml2
                lua
                taplo
                yq-go
              ];
            }
            ''
              cd ${self}

              find dotfiles/nvim -type f -name '*.lua' -print0 | xargs -0 -n1 luac -p

              for file in \
                dotfiles/nvim/lazy-lock.json \
                dotfiles/mango/swaync/config.json \
                dotfiles/mango/waybar/config.json \
                pkgs/dsh/package.json \
                pkgs/dsh/package-lock.json; do
                jq empty "$file"
              done
              jq --slurp empty dotfiles/mango/wlogout/layout
              sed '/^[[:space:]]*\/\//d' dotfiles/fastfetch/config.jsonc | jq empty

              taplo check dotfiles/noctalia/config.toml dotfiles/noctalia/settings.toml
              yq eval '.' .github/workflows/check.yml dotfiles/rime/default.custom.yaml >/dev/null
              xmllint --noout dotfiles/Thunar/uca.xml
              touch "$out"
            '';

        docs =
          pkgs.runCommand "docs"
            {
              nativeBuildInputs = [
                pkgs.cacert
                pkgs.lychee
              ];
            }
            ''
              cd ${self}
              export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
              lychee --offline --no-progress README.md README_EN.md doc/zh/*.md doc/en/*.md

              for base in README architecture maintenance agenix software shortcuts theming; do
                if [ "$base" = README ]; then
                  zh=README.md
                  en=README_EN.md
                else
                  zh="doc/zh/$base.md"
                  en="doc/en/$base.md"
                fi
                test "$(grep -c '^#{1,6} ' "$zh")" = "$(grep -c '^#{1,6} ' "$en")"
              done
              touch "$out"
            '';
      };
    };
}
