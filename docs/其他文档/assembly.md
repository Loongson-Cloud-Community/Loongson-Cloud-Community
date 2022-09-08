## 常用汇编代码段

## crc32
x86
```
asm volatile(
    "crc32q %[buf], %[crc]\n\t"
    :[crc]"=r"(crc64)
    :"0"(crc64), [buf]"r"(*p)
);
```
aarch64
```
asm volatile(
    "crc32cx %w[c], %w[c], %x[v]"
    :[c]"=r"(crc64)
    :"0"(crc64), [v]"r"(*p)
);
```

loongarch64
```
// TODO
```

## cmpxchag

x86
```
T ret;
__asm__ __volatile__("lock; cmpxchg %1, (%2);"
                     :"=a"(ret)
                      // GCC may produces %sil or %dil for
                      // constraint "r", but some of apple's gas
                      // dosn't know the 8 bit registers.
                      // We use "q" to avoid these registers.
                     :"q"(newval), "q"(ptr), "a"(oldval)
                     :"memory", "cc");
return ret;
```
loongarch64
```
// TODO
```
