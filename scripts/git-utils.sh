function git_clone_or_update () {
  local git_url=$1
  local branch=$2
  local lib_path=$3
  local current_path=`pwd`

  if [ -d $lib_path ]; then
    cd $lib_path
    git checkout $branch
    git fetch
  else
    git clone $git_url $lib_path
    cd $lib_path
    git checkout $branch
  fi

  cd $current_path
}