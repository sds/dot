# Loads environment variables from the specified file
load_env() {
  while read -r line; do
    name="$(echo "$line" | cut -d= -f1)"
    value="${line#$name=}"
    export $name="$value"
  done <<< "$(dot::eval_env_file "$1")"
}
