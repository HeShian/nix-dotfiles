# deepseek-harness（dsh）：DeepSeek 开源 agent harness（developer preview，发版极快）
# 上游是 pnpm monorepo 无 npm lockfile，这里用本目录自建的 package-lock.json
# + buildNpmPackage 打包官方 npm 包（纯 JS，无原生编译）
# 升级步骤：改 version → 本目录执行
# `npm install --package-lock-only --ignore-scripts @deepseek-ai/dsh@<version>`
# 重新生成 lockfile → npmDepsHash 置 lib.fakeHash 构建取新 hash 填回
{ lib, buildNpmPackage, nodejs, makeWrapper, bash }:
buildNpmPackage rec {
    pname = "dsh";
    version = "0.1.0-rc.6";
    src = ./.;
    npmDepsHash = "sha256-WD/anFfKD4ioL0e+VAbBY0ZoJT+ecb58jea3LTOO9fE=";
    dontNpmBuild = true;
    nativeBuildInputs = [ makeWrapper ];
    # 本项目 package.json 只是依赖清单，跳过默认 install 的 pack 流程，
    # 直接把完整 node_modules 拷出并包出 dsh 入口
    # web profile 的 cordis-plugin-hmr 要求 node 带 --expose-internals
    #（cordis loader 仅在此时暴露 internal ESM loader，见 cordis-plugin-loader/lib/index.js）
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp -r node_modules $out/lib/node_modules
      # dsh-terminal-bash 的 shellPath 默认 /bin/bash，NixOS 上不存在
      #（会导致 "PTY shell exited during startup"），改为 nix store 的 bash
      substituteInPlace $out/lib/node_modules/@deepseek-ai/dsh-terminal-bash/lib/index.js \
        --replace-fail 'default("/bin/bash")' 'default("${bash}/bin/bash")'
      makeWrapper ${nodejs}/bin/node $out/bin/dsh \
        --add-flags "--expose-internals $out/lib/node_modules/@deepseek-ai/dsh/lib/bin.js"
      runHook postInstall
    '';
    meta = {
      description = "DeepSeek Harness：开源 agent harness（dsh CLI + Web UI）";
      homepage = "https://github.com/deepseek-ai/deepseek-harness";
      license = lib.licenses.mit;
      mainProgram = "dsh";
      platforms = [
        "x86_64-linux"
      ];
    };
  }
