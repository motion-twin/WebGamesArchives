
typedef NameData = {
	var name : Null<String>;
}

class Names {
	
	public static var NAMES = #if no_names new Array<NameData>() #else ods.Data.parse("names.ods", "names", NameData) #end;

	#if neko
	static function getCacheFile(file) return Config.TPL + file
	#end
}