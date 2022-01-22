#!/bin/bash

NEWFILEPATH=$1

#
# Get the size of new artifact
#
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)
      NEWFILESIZE=$(stat -c%s "$NEWFILEPATH")
      ;;
    Darwin*)
      NEWFILESIZE=$(stat -f%z "$NEWFILEPATH")
      ;;
    CYGWIN*)
      NEWFILESIZE=$(stat -c%s "$NEWFILEPATH")
      ;;
    MINGW*)
      NEWFILESIZE=$(stat -c%s "$NEWFILEPATH")
      ;;
    *)
      echo "Unknown machine: ${unameOut}"
      exit 1
esac

echo "New size of $NEWFILEPATH = $NEWFILESIZE bytes."

# example: IntellijCustomJdk_CefMaster_CefLinuxX64
CONFIGID=$2

#
# Request info about articats of last pinned build of CONFIGID
#
# TODO: replace with correct token 
CURL_RESPONSE=$(curl --header "Authorization: Bearer eyJ0eXAiOiAiVENWMiJ9.TEthc2pNVlBpRjhNT3B2czhSTkxmUlp3eDlZ.NTlmNWNjOWUtZGExZS00NzdkLThhZTYtNGUyNzJmNmU4MDkw" "https://buildserver.labs.intellij.net/app/rest/builds/pinned:true,buildType:(id:$CONFIGID),branch:(default:true)?fields=id,number,artifacts(file(name,size))")


# returns such xml:
#
# <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
# <build id="160442036" number="88">
#     <artifacts>
#         <file name="cef_binary_97.2.23+g56ace92+chromium-97.0.4692.45_linux64_minimal.zip" size="175298437"/>
#         <file name="compile_commands.json" size="287367109"/>
#     </artifacts>
# </build>

echo "Atrifacts of last pinned build of $CONFIGID :\n"
echo $CURL_RESPONSE

# Find size (in response) with reg exp
re='name=\"(cef_binary_[^\"]+)\" size=\"([0-9]+)\"'

if [[ $CURL_RESPONSE =~ $re ]]; then
  OLDFILENAME=${BASH_REMATCH[1]}
  echo "Prev artifact name: $OLDFILENAME"
  OLDFILESIZE=${BASH_REMATCH[2]}
  echo "Prev artifact size = $OLDFILESIZE"

  let allowedSize=OLDFILESIZE+OLDFILESIZE/20 # use 5% threshold
  echo "Allowed size = $allowedSize"
  if [[ "$NEWFILESIZE" -gt "$allowedSize" ]]; then
    echo "ERROR: new size is significally greater than prev size (need to investigate)"
    exit 1
  fi
else
  echo "ERROR: can't find string with size in xml response:"
  echo $CURL_RESPONSE
  exit 1
fi
