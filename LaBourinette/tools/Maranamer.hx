class Maranamer {
	public static function main(){
		var file = neko.io.File.getContent("../lang/fr/maranamer.txt");
		var namer = new tools.Namer(file);
		for (i in 0...100)
			neko.Lib.println(namer.name());
	}
}
