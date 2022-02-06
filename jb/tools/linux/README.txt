# Copyright 2022 JetBrains s.r.o.

In order to retrieve sources, create project and build, execute the following:

$ mkdir chromium
$ mv cef chromium
$ cd chromium

# for debug
$ export project_conf=Debug

$ cef/jb/tools/common/get_sources.sh
$ cef/jb/tools/linux/create_project.sh
$ cef/jb/tools/linux/build.sh
$ cef/jb/tools/linux/create_distr.sh