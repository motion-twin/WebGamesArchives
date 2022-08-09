class Gen
{
	var maHash : Hash<Array<String>>;
	var raw : String ;
	var seed : Int;
	var rseed : mt.Rand;
	
	public function new(s : String) {
		raw = s;
		seed = 0;
		rseed = new mt.Rand(0);
		maHash = new Hash<Array<String>>();
		initHash();
	}
	
	
	public function get(key:String, seed_:Int) {
		seed = seed_;
		var str = "";
	}
	
	public function getName(s : String, seed:Int) {
		this.seed = seed;
		var myString = "";
		var tabLine = raw.split("\n");
		var tabRecur = new Array();
		var recur = chercheString(s);
		tabRecur = recur.split("%");
		for (i in 0...tabRecur.length)
			//if (i % 2 != 0)
				tabRecur[i] = getName(tabRecur[i],seed);
			//else
				//tabRecur[i] = applyGender(tabRecur[i]);

		return tabRecur.join("");
	}
	
	private function clearLine(array : Array<String>,?shar=0) {
		//espace
		for (i in 0...array.length) {
			if(shar != 0)
				array[i] = StringTools.trim(array[i]);
			else
			array[i] = StringTools.rtrim(array[i]);
		}
		//ligne
		for (i in 0...array.length) {
			if(array[i] == "")
				array.remove(array[i]);
		}
		return array;
	}
	
	private function chercheString(s) {
		rseed.initSeed(seed);
		if (maHash.get(s) == null)
			throw "string: "+s+" introuvable";
		return maHash.get(s)[rseed.random(maHash.get(s).length)];
	}
	
	private function initHash() {
		var array = new Array();
		array = raw.split("\n");
		clearLine(array);
		var arrayS = new Array();
		var keyString = "";
		for (i in array) {
			if (i.charAt(0) != "\t") {
				if ( (keyString != "") && (arrayS != null) ) {
					arrayS = clearLine(arrayS,1);
					maHash.set(keyString, arrayS);
				}
				keyString = i;
				arrayS = new Array();
			}
			else {
				arrayS.push(i);
			}
		}
	}
	
	public function format(key:String, data:Dynamic, seed) {
		var str = getName(key,seed);
		for (fieldName in Reflect.fields(data)) {
			var value = Reflect.field(data, fieldName);
			str = StringTools.replace(str, "::" + fieldName + "::", value);
		}
		return str;
	}
}