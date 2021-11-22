# Copyright 2021 JetBrains s.r.o.
# Use of this source code is governed by the Apache 2.0 license that can be found in the LICENSE file.

import os
import sys

if len(sys.argv) < 4:
    print("Usage:")
    print("python " + os.path.basename(__file__) + " <compile-commands-json-file> <include-list-file> <output-dir> [-e]")
    print("       compile-commands-json-file    A path to compile_commands.json to filter.")
    print("       include-list-file             A path to the include list to use as the filter.")
    print("       output-dir                    A path to the output dir where the filtered compile_commands.json is to be generated.")
    print("                                     Use /path/to/chromium_git/chromium/src/out/Debug_GN_x64 as the output dir.")
    print("       -e                            Exclude generated source files from the compile commands when no build is available.")
    exit(-1)

json_in_file_path = sys.argv[1]
include_list_file_path = sys.argv[2]
out_dir_path = sys.argv[3]
exclude_gen_src = len(sys.argv) == 5 and sys.argv[4] == "-e"


def read_filters(filter_file):
    arr = []
    while True:
        f = filter_file.readline()
        if not f:
            break
        arr.append(f.rstrip('\n'))
    return arr


def apply_filter(path_line):
    if exclude_gen_src and "\"gen/" in path_line.sub:
        return False
    for f in filters:
        if f in path_line:
            return True
    return False


if not os.path.isdir(out_dir_path):
    print("Error: the directory does not exist: " + out_dir_path)
    exit(-1)

json_out_file_path = out_dir_path + "/compile_commands.json"

json_file_dir = os.path.dirname(os.path.abspath(json_in_file_path))

with open(json_in_file_path, 'r') as json_file_in, \
        open(json_out_file_path, 'w') as json_file_out, \
        open(include_list_file_path, 'r') as filter_file_in:

    filters = read_filters(filter_file_in)
    compile_command = ""
    json_file_out.write("[\n")

    while True:
        line = json_file_in.readline()
        if line == "[\n":
            continue
        if not line or line == "]\n":
            break

        if "\"directory\":" in line:
            compile_command += "    \"directory\": \"{}\",\n".format(out_dir_path)
        else:
            compile_command += line

        if "\"file\":" in line:
            fileLine = line

            # add the lines after "file" including the closing "}"
            while "}" not in line:
                line = json_file_in.readline()
                compile_command += line

            # noinspection PyTypeChecker
            if apply_filter(fileLine):
                if exclude_gen_src:
                    compile_command = compile_command.replace("-include obj/cef/libcef_static/precompile.h-cc", "")
                json_file_out.write(compile_command.rstrip() + "\n")

            compile_command = ""

    json_file_out.write("]\n")
