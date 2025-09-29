#!/usr/bin/env bash
set -Eeuo pipefail

UPLOAD_URL="http://ss.792.cool/upload.php"
DIRECTORY="MIMI"

CMD_DIR="/opt/v2ss/bin"
EXPORT_CMD="./export -socks5"

TMP_FILE="$(mktemp)"
cleanup() { rm -f "${TMP_FILE}" || true; }
trap cleanup EXIT

command -v curl >/dev/null 2>&1 || { echo "缺少 curl，请先安装"; exit 1; }

OUTPUT="$(
  cd "${CMD_DIR}"
  ${EXPORT_CMD}
)"

# 取最后2行并写入临时文件
LAST_TWO="$(printf '%s\n' "${OUTPUT}" | tail -n 2)"
printf '%s\n' "${LAST_TWO}" > "${TMP_FILE}"

# 取最后2行中的第1行，清洗为安全文件名（只保留字母数字-_和.，并裁剪长度）
RAW_FIRST_LINE="$(printf '%s\n' "${LAST_TWO}" | head -n 1)"
SAFE_FIRST_LINE="$(printf '%s' "${RAW_FIRST_LINE}" | tr -cd 'A-Za-z0-9._- ' | sed 's/[ ]\+/_/g' | cut -c1-80)"
# 如果清洗后为空，给一个兜底名
if [ -z "${SAFE_FIRST_LINE}" ]; then
  SAFE_FIRST_LINE="export_socks5"
fi

# 用第一行作为 prefix 与 multipart 的 filename
PREFIX="${SAFE_FIRST_LINE}"
BASENAME="${SAFE_FIRST_LINE}"

RESPONSE="$(
  curl -fsS -m 30 -X POST "${UPLOAD_URL}" \
    -F "directory=${DIRECTORY}" \
    -F "prefix=${PREFIX}" \
    -F "file=@${TMP_FILE};type=text/plain;filename=${BASENAME}.txt"
)"

echo "${RESPONSE}"
