class Scripts {
	public static function main() {
		var urls = new List();
		for (line in neko.io.File.getContent("externals.txt").split("\n")) {
			line = StringTools.trim(line);
			if(line.length>0)
				urls.add(line);
		}

		for(url in urls) {
			var name = url.substr(url.indexOf("//")+2);
			name = StringTools.replace(name, "/", "_");
			name = StringTools.replace(name, ".", "_");
			var f = neko.io.File.write("externals/"+name+".js", true);
			f.writeString( haxe.Http.requestUrl(url) );
			f.close();
		}
	}
}