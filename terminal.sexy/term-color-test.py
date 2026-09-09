#!/usr/bin/python3

FG_LIST = [""] + [ f";{i}" for i in range(30,38) ]
BG_LIST = [""] + [ f";{i}" for i in range(40,48) ]

for bld in ["", 1]:
    for fg in FG_LIST:
        for bg in BG_LIST:
            print(f" \033[{bld}{fg}{bg}m{bld:1}{fg}{bg}\033[0m", end="")
        print("")
        print("")
