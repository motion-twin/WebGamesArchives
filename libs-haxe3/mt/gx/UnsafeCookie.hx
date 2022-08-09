package mt.gx;

typedef Save  = Dynamic;
	
class UnsafeCookie {
	public var data : Save = null;
	static inline var mem_name = "unsafe_cookie.";
	var FORCE_RESET = false;
	var pkey = "";
	
	public function new(key:String) {
		load(key);
	}
	
	public function save() {
		var so = flash.net.SharedObject.getLocal(mem_name+pkey);
		so.data.mem = data;
		so.flush();
	}
	
	function load(key) {
		pkey = key;
		var so = flash.net.SharedObject.getLocal(mem_name+pkey);
		if(so.data.mem == null || FORCE_RESET ) {
			resetMem();
			save();
		}
		else
			data = so.data.mem;
	}
	
	function resetMem()	{
		data = { };
	}
}