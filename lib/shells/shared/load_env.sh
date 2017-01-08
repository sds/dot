# Loads environment variables from the specified file
load_env() {
  dot::eval_env_file "$1" | while read -r line; do
    name="$(echo "$line" | cut -d= -f1)"
    value="${line#$name=}"
    eval "export $name='$value'"
  done
}
