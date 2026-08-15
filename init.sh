#!/bin/sh
#
# init.sh — Live ISO 环境下的 NixOS 安装脚本
#
# 用途：交互确认 host.nix 的机器参数后，用 disko 分区并格式化目标磁盘，
#       安装精简系统，再 chroot 进新系统应用完整配置（含 Home Manager）
# 用法：sudo ./init.sh [--reset]（--reset 清除断点状态从头重来）
#       断点状态记录在 /mnt/var/lib/nix-dotfiles-install-state/，中断后重跑自动续装
# 警告：会分区并格式化 host.nix 指定的整块磁盘，运行中需输入 "ERASE <disk>" 确认
# 依赖：NixOS Live ISO 环境（自带 nix、nixos-install、nixos-enter、git）

set -e # 任何命令失败立即中止（配合 run_once：失败步骤不落标记，重跑时重试）

# 安装期代理：Live ISO 阶段拉取 flake 依赖需经此代理，属安装刚需而非可选项
export http_proxy="http://10.244.79.176:7890"
export https_proxy="http://10.244.79.176:7890"

USER_NAME=""
USER_EMAIL=""
HOST_NAME=""
DISK=""
CPU=""
GPU=""
USER_HOME=""
USER_DOCS=""
USER_PICTURES=""
DOTFILES_TARGET=""
WALLPAPERS_TARGET=""
STATE_DIR="/mnt/var/lib/nix-dotfiles-install-state"
RESET_STATE=0

if [ "$#" -gt 1 ] || { [ "$#" -eq 1 ] && [ "$1" != "--reset" ]; }; then
  echo "Usage: $0 [--reset]"
  exit 1
fi

if [ "${1:-}" = "--reset" ]; then
  RESET_STATE=1
fi

# 分区与 nixos-install 均需要 root 权限
if [ "$(id -u)" -ne 0 ]; then
  echo "please run in root (sudo $0)"
  exit 1
fi

# 后续步骤以相对路径引用仓库文件（如 read_host_config 的 hosts/*/host.nix），
# 先切到脚本所在目录（即仓库根），避免隐含依赖调用时的 cwd
cd "$(dirname "$0")"

# 断点状态机：每个步骤完成后在 STATE_DIR 下落一个 <step>.done 标记文件
step_done() {
  [ -f "${STATE_DIR}/$1.done" ]
}

mark_done() {
  mkdir -p "${STATE_DIR}"
  touch "${STATE_DIR}/$1.done"
}

# 幂等执行：步骤已完成则跳过，否则执行并落标记（断点续装的核心）
run_once() {
  step="$1"
  desc="$2"
  shift 2

  if step_done "${step}"; then
    echo "==> ${desc}: skipped"
    return 0
  fi

  echo "==> ${desc}"
  "$@"
  mark_done "${step}"
}

# 无条件执行：每次运行都执行（用于可安全重复的步骤）
run_always() {
  desc="$1"
  shift

  echo "==> ${desc}"
  "$@"
}

read_host_config() {
  # 多主机布局：以 hosts/ 下第一个主机目录的 host.nix 为模板提供提示默认值（只取目录，防普通文件混入）
  TEMPLATE_HOST=""
  for d in hosts/*/; do
    TEMPLATE_HOST="$(basename "$d")"
    break
  done
  # 用 nix 求值读取 host.nix 属性（Live ISO 自带 nix），比 sed 解析文本更稳健。
  # 求值失败时输出为空，由 validate_config 统一兜底报错（保持原有报错路径）。
  eval_host_attr() {
    nix --experimental-features "nix-command flakes" eval --impure --expr "(import ./hosts/${TEMPLATE_HOST}/host.nix).$1" --raw 2> /dev/null || true
  }
  USER_NAME="$(eval_host_attr userName)"
  USER_EMAIL="$(eval_host_attr userEmail)"
  # 主机名的权威来源是 hosts/ 目录名（flake 以目录名为 den host 名），模板默认取目录名
  HOST_NAME="${TEMPLATE_HOST}"
  DISK="$(eval_host_attr disk)"
  CPU="$(eval_host_attr cpu)"
  GPU="$(eval_host_attr gpu)"
  # 模板用户名，seed_home_dir 用它给新用户名复制一份 HM 配置
  TEMPLATE_USER="${USER_NAME}"
}

set_user_paths() {
  USER_HOME="/mnt/home/${USER_NAME}"
  USER_DOCS="${USER_HOME}/Documents"
  USER_PICTURES="${USER_HOME}/Pictures"
  DOTFILES_TARGET="${USER_DOCS}/nix-dotfiles"
  WALLPAPERS_TARGET="${USER_PICTURES}/wallpapers"
}

prompt_value() {
  label="$1"
  current="$2"
  options="${3:-}"

  if [ -n "${options}" ]; then
    printf '%s (%s) [%s]: ' "${label}" "${options}" "${current}" >&2
  else
    printf '%s [%s]: ' "${label}" "${current}" >&2
  fi

  read -r value
  if [ -n "${value}" ]; then
    printf '%s' "${value}"
  else
    printf '%s' "${current}"
  fi
}

validate_user_name() {
  case "$1" in
  "" | *[!a-z0-9_-]* | [!a-z_]*)
    echo "invalid userName: $1"
    echo "use lowercase letters, digits, '_' or '-', and start with a letter or '_'."
    exit 1
    ;;
  esac
}

validate_user_email() {
  # userEmail 会插值进未引用 heredoc 生成 host.nix，
  # 含双引号、反斜杠或换行会产生语法非法的 Nix 文件，必须在此拦截
  nl='
'
  case "$1" in
  "" | *\"* | *\\* | *"$nl"*)
    echo "invalid userEmail: must not be empty or contain '\"', '\' or newlines."
    exit 1
    ;;
  esac
}

validate_host_name() {
  case "$1" in
  "" | *[!A-Za-z0-9-]* | -* | *-)
    echo "invalid hostName: $1"
    echo "use letters, digits or '-', and do not start/end with '-'."
    exit 1
    ;;
  esac
}

validate_disk() {
  # DISK 会插值进未引用 heredoc 生成 host.nix（与 userEmail 同理必须拦截注入字符），
  # 且必须是 /dev/ 下的块设备路径
  case "$1" in
  /dev/*[!A-Za-z0-9/._-]* | "")
    echo "invalid disk: $1"
    echo "use a /dev/ path with only letters, digits, '/', '.', '_' or '-' (e.g. /dev/nvme0n1)."
    exit 1
    ;;
  /dev/*) ;; # /dev/ 前缀且字符集干净
  *)
    echo "invalid disk: $1"
    echo "must be a /dev/ path (e.g. /dev/nvme0n1)."
    exit 1
    ;;
  esac
}

validate_choice() {
  value="$1"
  choices="$2"
  label="$3"

  for choice in ${choices}; do
    if [ "${value}" = "${choice}" ]; then
      return 0
    fi
  done

  echo "invalid ${label}: ${value}"
  echo "valid values: ${choices}"
  exit 1
}

ask_host_config() {
  echo "==> Configure host"
  USER_NAME="$(prompt_value "User name" "${USER_NAME}")"
  USER_EMAIL="$(prompt_value "User email" "${USER_EMAIL}")"
  HOST_NAME="$(prompt_value "Host name" "${HOST_NAME}")"
  DISK="$(prompt_value "Target disk" "${DISK}")"
  CPU="$(prompt_value "CPU" "${CPU}" "amd/intel")"
  GPU="$(prompt_value "GPU" "${GPU}" "nvidia/amd/intel")"

  validate_user_name "${USER_NAME}"
  validate_user_email "${USER_EMAIL}"
  validate_host_name "${HOST_NAME}"
  validate_disk "${DISK}"
  validate_choice "${CPU}" "amd intel" "cpu"
  validate_choice "${GPU}" "nvidia amd intel" "gpu"
}

write_host_config() {
  cat > "hosts/${HOST_NAME}/host.nix" << EOF
{
  userName = "${USER_NAME}";
  userEmail = "${USER_EMAIL}";
  disk = "${DISK}";
  cpu = "${CPU}";
  gpu = "${GPU}";
  users = [ "${USER_NAME}" ];
}
EOF
}

validate_config() {
  if [ -z "${USER_NAME}" ] || [ -z "${USER_EMAIL}" ] || [ -z "${HOST_NAME}" ] || [ -z "${DISK}" ] || [ -z "${CPU}" ] || [ -z "${GPU}" ]; then
    echo "failed to read userName, userEmail, hostName, disk, cpu, or gpu from hosts/<host>/host.nix"
    exit 1
  fi

  # --reset 在确认配置有效后才清除断点状态，避免误清导致从头分区
  if [ "${RESET_STATE}" -eq 1 ]; then
    rm -rf "${STATE_DIR}"
  fi

  if [ ! -b "${DISK}" ]; then
    echo "target disk does not exist or is not a block device: ${DISK}"
    echo
    lsblk
    exit 1
  fi
}

# 分区前最后防线：展示安装摘要与 lsblk 现状，必须逐字输入 "ERASE <disk>" 才继续
confirm_disko() {
  echo "==> Install summary"
  echo "    User: ${USER_NAME}"
  echo "    Mail: ${USER_EMAIL}"
  echo "    Host: ${HOST_NAME}"
  echo "    Disk: ${DISK}"
  echo "    CPU : ${CPU}"
  echo "    GPU : ${GPU}"
  echo
  echo "==> Current block devices"
  lsblk
  echo
  echo "WARNING: this will repartition and format ${DISK}."
  echo "All data on ${DISK} will be erased."
  printf 'Type exactly "ERASE %s" to continue: ' "${DISK}"
  read -r CONFIRM
  if [ "${CONFIRM}" != "ERASE ${DISK}" ]; then
    echo "confirmation mismatch, aborting."
    exit 1
  fi
}

# 新机名没有对应 hosts/<name>/ 目录时，以模板主机的通用文件为种子
# （default.nix/disko.nix 均已参数化，不含机器特定内容）
seed_host_dir() {
  if [ ! -f "hosts/${HOST_NAME}/default.nix" ]; then
    mkdir -p "hosts/${HOST_NAME}"
    cp "hosts/${TEMPLATE_HOST}/default.nix" "hosts/${TEMPLATE_HOST}/disko.nix" "hosts/${HOST_NAME}/"
  fi
}

# 新用户名没有对应 home/<user>/ 目录时，从模板用户目录复制一份 HM 配置
seed_home_dir() {
  if [ ! -d "home/${USER_NAME}" ] && [ -n "${TEMPLATE_USER}" ]; then
    cp -r "home/${TEMPLATE_USER}" "home/${USER_NAME}"
  fi
}

run_disko() {
  desc="1. Running Disko for partitioning and mounting..."

  if step_done "01-disko"; then
    echo "==> ${desc}: skipped"
    return 0
  fi

  confirm_disko
  echo "==> ${desc}"
  # disko 直接取 flake.lock 锁定的版本，升级 disko 输入（nix flake update）后无需同步此处
  DISKO_STORE_PATH="$(nix --experimental-features "nix-command flakes" eval --raw .#inputs.disko.outPath)"
  nix --experimental-features "nix-command flakes" run "path:${DISKO_STORE_PATH}#disko" -- --mode destroy,format,mount "./hosts/${HOST_NAME}/disko.nix"
  mark_done "01-disko"
}

generate_hardware_config() {
  nixos-generate-config --no-filesystems --root /mnt
}

copy_config() {
  cp /mnt/etc/nixos/hardware-configuration.nix "hosts/${HOST_NAME}/"
  cp -r flake.* ./hosts/ ./home/ ./modules/ ./dotfiles/ ./secrets/ ./libs/ ./overlays/ ./pkgs/ /mnt/etc/nixos/
}

install_nixos() {
  nixos-install --flake "/mnt/etc/nixos#${HOST_NAME}-install"
}

set_user_password() {
  nixos-enter --root /mnt -c "passwd ${USER_NAME}"
}

# 把仓库拷贝到新系统的用户目录、克隆壁纸仓库，并修正属主
prepare_user_files() {
  mkdir -p "${USER_DOCS}" "${USER_PICTURES}"
  rm -rf "${DOTFILES_TARGET}"
  # 排除 nix build 产物符号链接（指向 Live ISO 的 store，拷贝进新系统即成悬空链接）
  rm -f result result-*
  cp -a . "${DOTFILES_TARGET}"

  if [ ! -d "${WALLPAPERS_TARGET}/.git" ]; then
    rm -rf "${WALLPAPERS_TARGET}"
    git clone https://codeberg.org/claudia010/wallpapers.git "${WALLPAPERS_TARGET}"
  fi

  nixos-enter --root /mnt -c "chown -R ${USER_NAME}:users /home/${USER_NAME}/Documents /home/${USER_NAME}/Pictures"
}

activate_full_system() {
  # agenix 在系统激活时用主机 SSH host key（/etc/ssh/ssh_host_ed25519_key）解密
  # secrets/ 下的密钥；全新安装时该 key 尚不存在，解密失败只会得到无解释的
  # activation 报错。先确认 host key 就位，给用户处理机会，再跑 nixos-rebuild switch。
  # 用户 Ctrl-C 中止后重跑本脚本，断点状态机会从本步骤继续。
  while [ ! -f /mnt/etc/ssh/ssh_host_ed25519_key ]; do
    cat << 'EOF'
==> 未找到主机 SSH host key: /mnt/etc/ssh/ssh_host_ed25519_key
    完整配置启用了 agenix，激活时需要用它解密 secrets/ 下的密钥，否则本步骤必然失败。
    请选择处理方式：
      1. 从备份恢复旧机器的 host key 到 /mnt/etc/ssh/（推荐，secrets 无需重加密）；
      2. 生成新 key:
           ssh-keygen -t ed25519 -f /mnt/etc/ssh/ssh_host_ed25519_key -N ""
         装好后进入新系统，把新公钥加入 secrets/secrets.nix 并用 agenix -r 重加密全部密钥。
    处理完成后回到这里按回车重新检查；按 Ctrl-C 中止（重跑 init.sh 会从本步骤继续）。
EOF
    read -r _
  done
  nixos-enter --root /mnt -c "nixos-rebuild switch --flake /home/${USER_NAME}/Documents/nix-dotfiles#${HOST_NAME}"
}

read_host_config
ask_host_config
seed_host_dir
write_host_config
seed_home_dir
set_user_paths
validate_config
run_disko
run_once "02-hardware" "2. Generating hardware configuration..." generate_hardware_config
run_always "3. Preparing configuration files..." copy_config
run_once "04-nixos-install" "4. Installing base NixOS..." install_nixos
run_once "05-user-files" "5. Preparing user files..." prepare_user_files
run_once "06-full-system" "6. Activating full system configuration..." activate_full_system
run_always "7. Setting user password..." set_user_password

# 全部步骤成功后清理断点状态目录，避免残留进装好的系统（/mnt 即新系统根）
rm -rf "${STATE_DIR}"
echo "==> Installation complete! Please remove the installation media and reboot."
