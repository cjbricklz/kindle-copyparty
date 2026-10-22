import sys
src, dst = sys.argv[1], sys.argv[2]
d = open(src,'rb').read()
print("magic", d[:4], "len", len(d))
tbl = bytes((((b^0x7a)>>4)|((b^0x7a)<<4))&0xff for b in range(256))
m = d.translate(tbl)
i = m.find(b'\x1f\x8b\x08')
print("gzip at", i)
if i < 0: sys.exit(1)
open(dst,'wb').write(m[i:])
