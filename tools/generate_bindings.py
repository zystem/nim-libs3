"""Regenerate raw.nim from bji/libs3 inc/libs3.h (4.1 API)."""
import re
import sys
from pathlib import Path
header = Path(sys.argv[1]).read_text()
notice = re.match(r'\s*(/\*.*?\*/)', header, flags=re.S)
if notice is None or 'Copyright' not in notice.group(1):
    raise SystemExit('Missing upstream copyright notice; review the header before generating')
s = re.sub(r'/\*.*?\*/', '', header, flags=re.S)
callbacks = set(re.findall(r'typedef\s+\w+\s+\(\*?(S3\w+Callback)\)', s))
def typ(t):
    t = re.sub(r'\bconst\b', '', t).strip()
    n = t.count('*')
    base = t.replace('*', '').strip()
    if base in callbacks:
        return base
    if base == 'char' and n:
        return 'ptr ' * (n-1) + 'cstring'
    if base == 'void' and n:
        return 'ptr ' * (n-1) + 'pointer'
    return 'ptr ' * n + {'int':'cint','char':'cchar','uint64_t':'uint64','int64_t':'int64','unsigned long':'culong','void':'void','fd_set':'TFdSet'}.get(base,base)
def decl(d):
    m = re.fullmatch(r'(.+?)(\w+)\s*(?:\[(\w+)\])?', d.strip())
    t,n,a=m.groups()
    return f'`{n}`', f'array[{a}, {typ(t)}]' if a else typ(t)
def params(p):
    return '; '.join(f'{n}: {t}' for n,t in map(decl, filter(str.strip,p.split(','))))
out=['#[\nUpstream header notice (preserved verbatim):\n' + notice.group(1) + '\n]#',
     '## See libs3/NOTICE.txt for provenance and third-party license terms.',
     '## Low-level bindings for bji/libs3 4.1. Requires libs3.h and -ls3.',
     '## Generated with tools/generate_bindings.py; C owns callback arguments.',
     'import std/posix', '{.passL: "-ls3".}', '', 'const']
for name,val in re.findall(r'^#define\s+(S3_\w+)\s+([^\n]+)', s,re.M):
    if re.fullmatch(r'\d+|"[^"]*"|\(S3_INIT_WINSOCK\)',val.strip()):
        out.append(f'  {name}* = {val.strip().strip("()") }')
out += ['', 'type']
for body,name in re.findall(r'typedef enum\s*\{(.*?)\}\s*(\w+);',s,re.S):
    out.append(f'  {name}* {{.importc, header: "libs3.h", size: sizeof(cint).}} = enum')
    for item in body.split(','):
        if item.strip(): out.append('    '+item.strip())
out += ['  S3RequestContext* {.importc, header: "libs3.h", incompleteStruct.} = object',
'  S3EmailGrantee* {.bycopy.} = object', '    emailAddress*: array[128, cchar]',
'  S3CanonicalGrantee* {.bycopy.} = object', '    id*: array[128, cchar]', '    displayName*: array[128, cchar]',
'  S3Grantee* {.union, bycopy.} = object', '    amazonCustomerByEmail*: S3EmailGrantee', '    canonicalUser*: S3CanonicalGrantee']
for name,body in re.findall(r'typedef struct (\w+)\s*\{(.*?)\}\s*\1;',s,re.S):
    out.append(f'  {name}* {{.importc, header: "libs3.h", bycopy.}} = object')
    if name=='S3AclGrant':
        out += ['    granteeType*: S3GranteeType', '    grantee*: S3Grantee', '    permission*: S3Permission']; continue
    for d in body.split(';'):
        if d.strip():
            n,t=decl(d); out.append(f'    {n}*: {t}')
for ret,name,p in re.findall(r'typedef\s+(\w+)\s+\(\*?(S3\w+Callback)\)\s*\((.*?)\);',s,re.S):
    out.append(f'  {name}* = proc ({params(p)}): {typ(ret)} {{.cdecl, raises: [].}}')
for ret,name,p in re.findall(r'^([\w ]+?\*?)\s*(S3_\w+)\s*\((.*?)\);',s,re.M|re.S):
    ret=ret.strip()
    if '\n' in ret: ret=ret.splitlines()[-1]
    out.append(f'proc {name}*({params(p)}): {typ(ret)} {{.cdecl, importc, header: "libs3.h".}}')
Path('src/libs3/raw.nim').write_text('\n'.join(out)+'\n')
