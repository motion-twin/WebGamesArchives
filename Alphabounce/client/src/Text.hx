class Text {//}

	static var initialized = false;
	public static var get = TextFr;

	public static function setLang( lang:String ){
		get = switch (lang){
			case "fr": cast TextFr;
			case "en": cast haxe.Unserializer.run(haxe.Resource.getString("TextEn"));
			case "es": cast haxe.Unserializer.run(haxe.Resource.getString("TextEs"));
			case "de": cast haxe.Unserializer.run(haxe.Resource.getString("TextDe"));
			default:   cast TextFr;
		}
		
		if (initialized)
			return;

		for (i in 0...(MissionInfo.MISSILE_MAX-1)){
			var id = MissionInfo.MISSILE+(i+1);
			get.ITEM_NAMES.insert(id, "Missile "+(i+2));
		}

		initialized = true;
	}
}
