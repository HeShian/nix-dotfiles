# den 实体元数据的类型化声明（den 实体本是 freeform，schema 层补上受检项：
# host.nix 拼错属性名会因对应 option 未定义而在声明处报错，而非深处求值时才爆）
_: {
  den.schema.host =
    { lib, ... }:
    {
      options = {
        cpu = lib.mkOption {
          type = lib.types.enum [
            "amd"
            "intel"
          ];
          description = "CPU 厂商（微码更新分派）";
        };
        gpu = lib.mkOption {
          type = lib.types.enum [
            "nvidia"
            "amd"
            "intel"
          ];
          description = "GPU 厂商（驱动与 VA-API 分派）";
        };
        disk = lib.mkOption {
          type = lib.types.str;
          description = "系统盘设备路径（disko 目标盘）";
        };
        primaryUser = lib.mkOption {
          type = lib.types.str;
          description = "主用户（SSH 公钥与 agenix 密钥属主）";
        };
        proxy = lib.mkOption {
          default = null;
          type = lib.types.nullOr (
            lib.types.submodule {
              options = {
                default = lib.mkOption {
                  type = lib.types.str;
                  description = "系统默认 HTTP(S) 代理";
                };
                noProxy = lib.mkOption {
                  default = null;
                  type = lib.types.nullOr lib.types.str;
                  description = "不经代理的主机或地址";
                };
              };
            }
          );
          description = "可选的主机级代理配置";
        };
      };
    };
  den.schema.user =
    { lib, ... }:
    {
      options = {
        email = lib.mkOption {
          type = lib.types.str;
          description = "git 提交署名邮箱";
        };
        isAdmin = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = "是否加入 wheel/libvirtd 管理组";
        };
        sshAuthorizedKeys = lib.mkOption {
          default = [ ];
          type = lib.types.listOf lib.types.str;
          description = "该用户允许登录的 SSH 公钥";
        };
      };
    };
}
