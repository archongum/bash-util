#!/bin/bash
# -------------------- start: getopt --------------------
__script_name__=$(basename "$0")

# TODO: change
function print_usage() {
  cat <<EOF

Usage: ${__script_name__} [OPTIONS]
Options:
  -s --server:            presto server
  --catalog:              presto catalog
  --extract_start_time:   [OPTIONAL] extract start time (format: "2019-08-21T00:00:00Z" or "yesterday")

EOF
}

# TODO: change
__getopt_tmp__=$(getopt \
  -o s: \
  --long server:,catalog:,extract_start_time: \
  -- "$@")

if [[ $? -ne 0 ]]; then
  print_usage
  exit 1
fi

eval set -- "${__getopt_tmp__}"

# TODO: change
while true; do
  case "$1" in
  -s | --server)
    server="$2"
    shift 2
    ;;
  --catalog)
    catalog="$2"
    shift 2
    ;;
  --extract_start_time)
    extract_start_time="$2"
    shift 2
    ;;
  --)
    shift
    break
    ;;
  *) break ;;
  esac
done

# print parameters
# TODO: change
cat <<EOF

-----------------------  begin: parameters  -----------------------
server             : ${server}
catalog            : ${catalog}
extract_start_time : ${extract_start_time}
-----------------------  end: parameters    -----------------------

EOF

# check
function assert_not_empty() {
  for p in "$@"; do
    if [[ -z "${p}" ]]; then
      echo "$(date "+%Y-%m-%d %H:%M:%S") [ERROR]: parameter(s) is empty."
      print_usage
      exit 1
    fi
  done
}

# TODO: change
assert_not_empty \
  "${server}" \
  "${catalog}"

# -------------------- end: getopt --------------------
