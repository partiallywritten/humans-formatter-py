# humans-formatter-zig
Re-implementation of my pypi library, [humans-formatter](https://pypi.org/project/humans-formatter/) in zig.


### Usage
```py
import humans

# time formatting
# time(ms: int, compound: bool = False, round: bool = False)
# 	- Format milliseconds into human readable form. Use only one argument except 'ms' at a time
print(humans.time(<time-in-ms>, compound=True)


# byte formatting
# bytes(size: int)
# 	- Convert bytes into human readable KiB/MiB/etc.
print(humans.bytes(<bytes>)


# see docs
print(humans.__doc__)
print(humans.time.__doc__)
print(humans.bytes.__doc__)
```

### Build it
```sh
zig build-lib -dynamic -O ReleaseFast -I /usr/include/python<x.xx> -femit-bin=humans.so -lc wraps.zig
```
Replace with your python version (`python --version`) and path


### Performance results
```
Time Formatter
 Faster: True
 Speedup: 5.17x
 humans: 0.07622953100053564
 origin: 0.3940906799998629

Human Bytes
 Faster: True
 Speedup: 4.50x
 humans: 0.18568539199986844
 origin: 0.8354882809999253
 
Tested on home server: i3-4130, 2TB HDD on arch linux, python 3.14.3 & zig 0.15.2
```

see [test.py](tests/test.py) and [python implementation](tests/origin.py) for more info.
Both are optimized and implementations of the same logic
