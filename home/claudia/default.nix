{ userName, userEmail, ... }:
{
  imports = [
    ../../modules/home
  ];
  # 用户身份（git 提交署名）
  programs.git = {
    enable = true;
    settings.user = {
      email = userEmail;
      name = userName;
    };
  };
}
