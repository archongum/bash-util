#!/usr/bin/env bash

#====================== log ======================

function log_info() {
  # Usage: log_info "this is the info log message"
  echo "$(date "+%Y-%m-%d %H:%M:%S") [INFO]: $@"
}

function log_warnning() {
  # Usage: log_warnning "this is the warning log message"
  echo "$(date "+%Y-%m-%d %H:%M:%S") [WARN]: $@"
}

function log_error() {
  # Usage: log_error "this is the error log message"
  echo "$(date "+%Y-%m-%d %H:%M:%S") [ERROR]: $@"
}

function log_exit() {
  # Usage: log_exit "the log message before exit"
  log_error "$@"
  exit 1
}

# ====================== date ======================

function date_format() {
  # Usage: date_format 20200101 [formatter (DEFAULT: %Y%m%d)]
  local d
  local formatter
  d=$1
  [[ -z ${d} ]] && log_exit "Usage: date_format [date] [formatter(optional)]"
  formatter=$2
  foramtter=${formatter:="%Y%m%d"}
  echo $(date -d "${d}" "+${formatter}")
}

function get_date_from() {
  # Usage: get_date_from 20200101 [interval day (DEFAULT:0)]
  local base_date
  local interval
  base_date=$1
  [[ -z ${base_date} ]] && log_exit "Usage: get_date_from [date] [interval day(optional)]"
  interval=$2
  interval=${interval:=0}
  echo $(date -d "${base_date} ${interval} day" "+%Y%m%d")
}

function get_date() {
  # Usage: get_date [interval day (DEFAULT:0)]
  get_date_from $(date "+%Y%m%d") $1
}

function get_timestamp() {
  # Usage: get_timestamp
  echo $(date "+%Y-%m-%d %H:%M:%S")
}

function get_timestamp_compact_sec() {
  # Usage: get_timestamp_compact_sec
  echo $(date "+%Y%m%d%H%M%S")
}

function get_timestamp_compact_milli() {
  # Usage: get_timestamp_compact_milli
  echo $(date "+%Y%m%d%H%M%S%N") | cut -c1-17
}

function get_unix_milli() {
  # Usage: get_unix_milli
  echo $(date "+%s%N") | cut -c1-13
}

function get_unix_sec() {
  # Usage: get_unix_sec
  echo $(date "+%s")
}

#====================== echo ======================

function echo_separator() {
  # Usage: echo_separator #
  local result
  local char

  if [[ -z "${1}" ]]; then
    char="="
  else
    char="${1:0:1}"
  fi

  for i in {1..80}; do
    result="${result}${char}"
  done

  echo ${result}
}

#====================== confirm======================
function get_confirm() {
  # Usage: x=$(get_confirm "do you want to continue?")
  #        if [ "$x" = "yes" ]
  QUESTION="$1"
  read -p "${QUESTION} [yN] " ANSWER
  if [[ "${ANSWER}" == "y" ]] || [[ "${ANSWER}" == "Y" ]]; then
    echo "yes"
  else
    echo "no"
  fi
}

#====================== if ======================
#====================== if-then ======================
function if_error_then_exit() {
  # Usage: if_error_then_exit $? "fail, and exit"
  if [ "$1" -ne 0 ]; then
    log_error "$2"
    exit 1
  fi
}

function if_empty_then_exit() {
  # Usage: if_empty_then_exit ${1} "param 1 required"
  if [ -z "$1" ]; then
    log_error "$2"
    exit 1
  fi
}

function if_empty_then_return_default() {
  # Usage: A=$(if_empty_return_default "${1}" 123)
  if [ -z "${1}" ]; then
    echo "${2}"
  else
    echo "${1}"
  fi
}

function if_empty_then_log_warnning() {
  # Usage: if_empty_then_log_warnning "$1" "the param 1 is empty"
  if [ -z "${1}" ]; then
    log_warnning "${2}"
  fi
}

function if_path_not_exist_then_exit() {
  # Usage: if_path_not_exist_then_exit "/tmp/a.txt" "/tmp/a.txt is not exists"
  if [ ! -e "$1" ]; then
    log_error "$2"
    exit 1
  fi
}

# action
function if_file_not_exist_then_touch() {
  # Usage: if_file_not_exist_then_touch "/tmp/a.txt"
  [ -e "$1" ] || touch "$1"
  return $?
}
function if_dir_not_exist_then_mkdir() {
  # Usage: if_dir_not_exist_then_mkdir "/tmp/abc"
  [ -d "$1" ] || mkdir -p "$1"
  return $?
}

function if_file_exist_then_remove() {
  # Usage: if_file_exist_then_remove "/tmp/a.txt"
  if [ -e "$1" ]; then
    rm "$1"
    return $?
  fi
}

function if_dir_exist_then_remove() {
  # Usage: if_dir_exist_then_remove "/tmp/abc"
  if [ -e "$1" ]; then
    rm -rf "$1"
    return $?
  fi
}

function if_file_or_dir_exist_then_move_to() {
  if [ -e "$1" ]; then
    mv "$1" "$2"
    return $?
  fi
}

function if_file_or_dir_exist_then_copy_to() {
  if [ -e "$1" ]; then
    cp -r "$1" "$2"
    return $?
  fi
}

#====================== is ======================

function is_command_exists() {
  type "$1" &>/dev/null
}

#====================== dir  ======================

function remkdir() {
  # Usage: remkdir "/tmp/abc"
  if [ -e "$1" ]; then
    rm -rf "$1"
    local rc=$?
    if [ "$rc" -ne 0 ]; then
      log_error "remkdir: fail, when do [rm -rf ${1}]"
      return "$rc"
    fi
  fi
  mkdir -p "$1"
  return $?
}

# TODO: add to gen date list

#====================== tar ======================
function do_tar() {
  # Usage: do_tar example.tar.gz example
  PKG_NAME="${1}"
  DIR="${2}"
  if_file_exist_then_remove "${PKG_NAME}"
  tar -czf "${PKG_NAME}" "${DIR}"
  if_error_then_exit "$?" "tar -czf ${PKG_NAME} ${DIR} fail"
}

#====================== string ======================
# reference https://github.com/dylanaraps/pure-bash-bible

function string_trim() {
  # Usage: string_trim "   example   string    "
  : "${1#"${1%%[![:space:]]*}"}"
  : "${_%"${_##*[![:space:]]}"}"
  printf '%s\n' "$_"
}

function string_split() {
  # Usage: string_split "string" "delimiter"
  IFS=$'\n' read -d "" -ra arr <<<"${1//$2/$'\n'}"
  printf '%s\n' "${arr[@]}"
}

function string_lstrip() {
  # Usage: string_lstrip "string" "pattern"
  printf '%s\n' "${1##$2}"
}

function string_rstrip() {
  # Usage: string_rstrip "string" "pattern"
  printf '%s\n' "${1%%$2}"
}

# Requires bash 4+
function string_to_lower() {
  # Usage: string_to_lower "string"
  printf '%s\n' "${1,,}"
}

# Requires bash 4+
function string_to_upper() {
  # Usage: string_to_upper "string"
  printf '%s\n' "${1^^}"
}

function string_contains() {
  # Usage: string_contains hello he
  [[ "${1}" == *${2}* ]]
}

function string_starts_with() {
  # Usage: string_starts_with hello he
  [[ "${1}" == ${2}* ]]
}

function string_ends_with() {
  # Usage: string_ends_wit hello lo
  [[ "${1}" == *${2} ]]
}

function string_regex() {
  # Usage: string_regex "string" "regex"
  [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[1]}"
}

#====================== array ======================
# reference https://github.com/dylanaraps/pure-bash-bible
function array_reverse() {
  # Usage: array_reverse "array"
  shopt -s extdebug
  f() (printf '%s\n' "${BASH_ARGV[@]}")
  f "$@"
  shopt -u extdebug
}

function array_remove_dups() {
  # Usage: array_remove_dups "array"
  declare -A tmp_array

  for i in "$@"; do
    [[ "$i" ]] && IFS=" " tmp_array["${i:- }"]=1
  done

  printf '%s\n' "${!tmp_array[@]}"
}

function array_random_element() {
  # Usage: array_random_element "array"
  local arr=("$@")
  printf '%s\n' "${arr[RANDOM % $#]}"
}

#====================== program ======================

function run_command_in_background() {
  # Usage: run_command_in_background ./some_script.sh
  (nohup "$@" &>/dev/null &)
}

#====================== others ======================
function generate_uuid() {
  # Usage: generate_uuid
  C="89ab"

  for ((N = 0; N < 16; ++N)); do
    B="$((RANDOM % 256))"

    case "$N" in
    6) printf '4%x' "$((B % 16))" ;;
    8) printf '%c%x' "${C:$RANDOM%${#C}:1}" "$((B % 16))" ;;

    3 | 5 | 7 | 9)
      printf '%02x-' "$B"
      ;;

    *)
      printf '%02x' "$B"
      ;;
    esac
  done

  printf '\n'
}
