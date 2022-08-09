package mt.gx;

typedef StringMap<T> = #if flash
haxe.ds.UnsafeStringMap<T>
#else
haxe.ds.StringMap<T>
#end