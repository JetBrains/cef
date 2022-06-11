#!/bin/bash

set -exuo pipefail

architecture=$1 # arm64 or x64
case "${architecture}" in
    x64)
      ;;
    arm64)
      ;;
    *)
      echo "Unsupported arch: ${architecture}"
      exit 1
esac

# CD to the directory where cef/jb/tools/linux is a valid path
cd "$(dirname "$0")/../../../.."

echo "Build env:"
cat cef/jb/tools/linux/build.env

echo "Create project:"
bash cef/jb/tools/linux/create_project.sh "${architecture}"

echo "Build project:"
bash cef/jb/tools/linux/build.sh "${architecture}"

echo "Create distributive:"
bash cef/jb/tools/linux/create_distr.sh "${architecture}"
