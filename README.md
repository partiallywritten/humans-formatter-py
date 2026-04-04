# humans-formatter-zig
Rough implementation of my pypi library, [humans-formatter](https://pypi.org/project/humans-formatter/) in zig.
This will be replacing original C version when I'm done

### Where it is now
As of 4th Apr 2026, basic api and basic c wrapping is done but needs final polishes, modularity of the own code and some bug fixes.

### Performance results
```
Time Formatter
 Faster: True
 Speedup: 5.75x
 humans: 0.07837898399975529
 origin: 0.45095783799933997

Human Bytes
 Faster: True
 Speedup: 5.53x
 humans: 0.1857211879996612
 origin: 1.0276613500000167
 
Tested on home server: i3-4130, 2TB HDD on arch linux, python 3.14.3 & zig 0.15.2
```

see [test.py](tests/test.py) and [python implementation](tests/origin.py) for more info.
Please note that, this isn't apples to apples comparison as python implementation is lacking in features and lightweight in logic.
