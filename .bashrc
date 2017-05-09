[ -z ${PROJET_HOME+x} ] && cd ${PROJECT_HOME} 2>&1 >/dev/null

dirList=$(find . -type d | sed -e 's/^\.\///' | grep -v '\.' | sort)
dirCnt=$(echo ${dirList} | wc -l)
if [[ ${dirCnt} -eq 0 ]]; then
  exit
fi
dirList=". ${dirList}"
printf "Please select folder:\n"
#elect dir in $(find . -type d | sed -e 's/^\.\///' | grep -v '\.' | sort); do 
select dir in ${dirList}; do
  [[ -n "${dir}" ]] && break;
  echo ">>> Invalid Selection";
done
cd "${dir}" && pwd
