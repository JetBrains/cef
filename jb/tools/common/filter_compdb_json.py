# Copyright 2021 JetBrains s.r.o.
# Use of this source code is governed by the Apache 2.0 license that can be found in the LICENSE file.

import os
import sys


def read_filters():
    arr = []
    while True:
        f = filter_file.readline()
        if not f:
            break
        arr.append(f.rstrip('\n'))
    return arr


def apply_filter(path_line):
    for f in filters:
        if f in path_line:
            return True
    return False


if len(sys.argv) != 3:
    print("Usage:")
    print(os.path.basename(__file__) + " <compilation_database.json> <include_list>")
    exit(-1)

json_file_path = sys.argv[1]
include_list_path = sys.argv[2]

json_file_dir = os.path.dirname(os.path.abspath(json_file_path))

with open(json_file_path, 'r') as json_file_in, \
        open(include_list_path, 'r') as filter_file:

    filters = read_filters()
    compile_command = ""
    print ("[")

    while True:
        line = json_file_in.readline()
        if line == "[\n":
            continue
        if not line or line == "]\n":
            break

        if "\"directory\":" in line:
            compile_command += "    \"directory\": \"{}\",\n".format(json_file_dir)
        else:
            compile_command += line

        if "\"file\":" in line:
            fileLine = line

            # add the lines after "file" including the closing "}"
            while "}" not in line:
                line = json_file_in.readline()
                compile_command += line

            if apply_filter(fileLine):
                print (compile_command.rstrip())

            compile_command = ""

    print ("]")
