#!/bin/bash

set -exuo pipefail

# CD to the directory where cef/jb/tools/linux is a valid path
cd "$(dirname "$0")/../../../.."

echo "Build env:"
cat cef/jb/tools/linux/build.env

echo "Create project:"
bash cef/jb/tools/linux/create_project.sh x64

echo "Build project:"
bash cef/jb/tools/linux/build.sh x64

echo "Create distributive:"
bash cef/jb/tools/linux/create_distr.sh x64
