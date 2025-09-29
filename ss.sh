#!/usr/bin/env bash
set -Eeuo pipefail

# 必填：你的上传接口地址（指向这段PHP的URL）
UPLOAD_URL="http://ss.792.cool/upload.php"

# 必填：选择目录（只能是 FENG 或 MIMI，与PHP代码限制一致）
DIRECTORY="MIMI"

# 必填：上传前缀（PHP端会用它生成目标文件名的一部分）
PREFIX="socks5"

# 可改：执行命令所在目录与命令
CMD_DIR="/opt/v2ss/bin"
EXPORT_CMD="./export -socks5"

# 生成上传文件名（客户端侧，仅用于 multipart 的 filename；最终名由服务端重命名）
TIMESTAMP="$(date +'%Y%m%d-%H%M%S')"
BASENAME="export_socks5_last2_${TIMESTAMP}"
TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "${TMP_FILE}" || true
}
trap cleanup EXIT

# 依赖检查
command -v curl >/dev/null 2>&1 || { echo "缺少 curl，请先安装"; exit 1; }

# 运行命令并拿最后2行
OUTPUT="$(
  cd "${CMD_DIR}"
  ${EXPORT_CMD}
)"
printf '%s\n' "${OUTPUT}" | tail -n 2 > "${TMP_FILE}"

# 上传到你的PHP接口
# 注意：服务器端会根据 directory 和 prefix 生成最终文件名并保存到 /www/wwwroot/ss.792.cool/uploads/{DIRECTORY}/
RESPONSE="$(
  curl -fsS -m 30 -X POST "${UPLOAD_URL}" \
    -F "directory=${DIRECTORY}" \
    -F "prefix=${PREFIX}" \
    -F "file=@${TMP_FILE};type=text/plain;filename=${BASENAME}.txt"
)"

# 打印服务端返回的JSON
echo "${RESPONSE}"