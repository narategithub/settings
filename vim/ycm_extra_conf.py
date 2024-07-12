import os
import re
import json
import socket
import subprocess as sp

# NOTE: `filename` is acutally a path.

RE_SEARCH_START = re.compile(r'#include .* search starts here:')

def gcc_include_search_paths():
    search_start = 0
    paths = []
    out = sp.check_output("gcc -E -v - < /dev/null",
                          shell=True, stderr=sp.STDOUT)
    for line in out.decode().splitlines():
        if RE_SEARCH_START.match(line):
            search_start = 1
            continue
        if search_start and line.startswith(' /'):
            paths.append(line.strip())
            continue
        search_start = 0
    return paths

def guess_project_root(filename):
    dpath = os.path.dirname(filename)
    dlist = dpath.split("/")
    dpath = "/"
    while dlist:
        dpath += "/" + dlist[0]
        dlist.pop(0)
        if os.path.exists(f"{dpath}/configure.ac") or \
           os.path.exists(f"{dpath}/README.md"):
            return dpath
    return None

def guess_project_incdirs(proot):
    tgt = [ proot ]
    _pdirs = [ proot ]
    for d in os.listdir(proot):
        _ent = f"{proot}/{d}"
        if os.path.isdir(_ent):
            _pdirs.append(_ent)
            if _ent.startswith("build"): # include build dir
                tgt.append(_ent)
    _guess = [ "src", "include" ]
    for a in _pdirs:
        for b in _guess:
            _ent = f"{a}/{b}"
            if os.path.isdir(_ent):
                tgt.append(_ent)
    return tgt

def c_handle(filename):
    flags = [ '-Wall', '-x', 'c', '-DDEBUG' ]
    flags += [ '-I' + p for p in gcc_include_search_paths() ]
    pdir = guess_project_root(filename)
    if pdir:
        flags += [ '-I' + p for p in guess_project_incdirs(pdir) ]
        path = f"{pdir}/.ycm_incdir"
        if os.path.isfile(path):
            f = open(path)
            lines = f.readlines()
            ents = [ l.strip() for l in lines ]
            flags += [ '-I' + e for e in ents ]
    return {'flags': flags, 'do_cache': True}

type_handle = {
        '.c': c_handle,
        '.h': c_handle,
        }

def Settings(filename, **kwargs):
    try:
        name, ext = os.path.splitext(filename)
        return type_handle[ext](filename)
    except Exception as e:
        return c_handle(filename)

if __name__ == '__main__':
    # testing
    obj = Settings("/a/b/c.h")
    print(json.dumps(obj, indent=2))
