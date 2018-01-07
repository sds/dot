# Prepends an item to a delimited list in a string if it is not already present.
# Useful for modifying the PATH environment variable.
prepend_if_missing() {
  if ! echo "$3" | grep -Eq "(^|$2)$1($|$2)" 2>&1 >/dev/null ; then
    echo "${1}${2}${3}"
  else
    echo "$3"
  fi
}
