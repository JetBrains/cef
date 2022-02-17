which sccache
if [ $? -ne 0 ]; then
    echo "sccache isn't installed, nothing to do"
    exit 0
fi

source ./cef/jb/tools/mac/build.env

# Uncomment for debug logging
# export SCCACHE_ERROR_LOG=/Users/bocha/projects/cef/sccache_log.txt
# export SCCACHE_LOG=trace

echo "Restart sccache server in environemnt:"
cat ./cef/jb/tools/mac/build.env

sccache --stop-server
sccache --start-server
sccache -s
