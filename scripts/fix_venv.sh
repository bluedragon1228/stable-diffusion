#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <OLD_VENV> <NEW_VENV>"
  echo "   eg: $0 /home/ubuntu/test/venv /home/ubuntu/test/venv2"
  exit 1
fi

OLD_PATH=${1}
NEW_PATH=${2}

cd ${NEW_PATH}/bin
sed -i "s|VIRTUAL_ENV=\"${OLD_PATH}\"|VIRTUAL_ENV=\"${NEW_PATH}\"|" activate
sed -i 's|#!/venv/bin/python3|#!/workspace/venv/bin/python3|' *
