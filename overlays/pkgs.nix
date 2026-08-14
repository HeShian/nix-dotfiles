# 把 pkgs/ 自打包软件注入包集（之后直接用 pkgs.<name> 引用）
final: prev: import ../pkgs { pkgs = final; }
