function get_os_name () {
  if [[ "$OSTYPE" =~ ^darwin* ]]; then
    OS_NAME="mac"

    return 0
  fi

  OS_NAME="linux"
}

function get_binaries_arch () {
  get_os_name

  export BINARIES_ARCH_NAME=$OS_NAME-`uname -m`
}