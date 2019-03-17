# Loads environment variables from the specified file
load_env() {
  dot::eval_env_file "$1" | while read -r line; do
    name="$(echo "$line" | cut -d= -f1)"
    if [ -z "$name" ]; then
      # Sometimes an additional empty line sneaks in. Ignore it.
      continue
    fi
    value="${line#$name=}"
    export $name="$value"
  done
}
