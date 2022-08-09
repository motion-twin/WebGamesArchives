class PrepareTexts {

	static function serialize( c:Dynamic ){
		Reflect.setField(c, "prototype", null);
		Reflect.setField(c, "__name__", null);
		Reflect.setField(c, "__interfaces__", null);
		return haxe.Serializer.run(c);
	}

	static function write( data:String, file:String ){
		var out = neko.io.File.write(file, true);
		out.writeString(data);
		out.close();
	}

	public static function main(){
		write(serialize(TextFr), "TextFr.data");
		write(serialize(TextEn), "TextEn.data");
		write(serialize(TextEs), "TextEs.data");
		write(serialize(TextDe), "TextDe.data");
	}

}
