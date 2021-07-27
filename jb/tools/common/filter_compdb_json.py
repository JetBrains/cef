# Copyright 2021 JetBrains s.r.o. Use of this source code is governed by the Apache 2.0 license that can be found in the LICENSE file.

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

with open(json_file_path, 'r') as json_file_in, \
        open("filtered_" + json_file_path, 'w') as json_file_out, \
        open(include_list_path, 'r') as filter_file:

    filters = read_filters()
    compile_command = ""
    first_write = True

    json_file_out.truncate(0)
    json_file_out.write("[\n")

    while True:
        line = json_file_in.readline()
        if line == "[\n":
            continue
        if not line or line == "]\n":
            break

        compile_command += line
        if "\"file\":" in line:
            if apply_filter(line):
                if not first_write:
                    json_file_out.write("  },\n")
                else:
                    first_write = False
                json_file_out.write(compile_command)
            # skip "}"
            json_file_in.readline()
            compile_command = ""

    json_file_out.write("  }\n]\n")
