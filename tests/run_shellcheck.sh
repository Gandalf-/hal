#!/bin/bash

# shellcheck disable=SC2046
cd ..
ret=0

while read -r file; do

  printf "%-30s" "$file"
  if shellcheck --exclude=SC1091 "$file"; then
    echo -e "pass"
  else
    ret=1
    echo -e "fail"
  fi

done < <(find . -name "*.sh")

exit $ret

