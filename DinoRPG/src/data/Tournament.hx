package data;
import db.Tournament;

typedef TournamentFighter = {
	var name : String;
	var title : String;
	var parts : Array<Int>;
	var level : Int;
	var gfx : String;
	var chk : Int;
	var fam : data.Family;
}

typedef Tournament = {
	var pre : Array<String>;
	var mid : Array<String>;
	var post : Array<String>;
	var title : Array<String>;
	var qual : Array<String>;
	var fighters : Array<TournamentFighter>;
}

class TournamentXML {

	static var data : Tournament;

	static function separate( str : String ) {
		var lines = ~/\r?\n|\r/g.split(str);
		var i = 0;
		while( i < lines.length ) {
			var l = StringTools.trim(lines[i]);
			if( l == "" ) {
				lines.splice(i,1);
				continue;
			}
			lines[i++] = l;
		}
		return lines;
	}

	static function initData() : Tournament {
		var x = new haxe.xml.Fast(Data.xml("tournament.xml"));
		return {
			pre : separate(x.node.pre.innerData),
			mid : separate(x.node.mid.innerData),
			post : separate(x.node.post.innerData),
			title : separate(x.node.title.innerData),
			qual : separate(x.node.qual.innerData),
			fighters : new Array(),
		};
	}

	static function findSimilar( parts : Array<Int>, level : Int ) {
		for( i in 1...level ) {
			var f = data.fighters[i];
			if( f.parts == null )
				continue;
			var count =
				(f.parts[0] == parts[0]?1:0) +
				(f.parts[1] == parts[1]?1:0) +
				(f.parts[2] == parts[2]?1:0) +
				(f.parts[3] == parts[3]?1:0) +
				(f.parts[4] == parts[4]?1:0);
			if( count >= 2 )
				return true;
		}
		return false;
	}

	public static function genFighter( level ) {
		if( data == null )
			data = initData();
		var f = data.fighters[level];
		if( f != null )
			return f;
		if( level > 1 && data.fighters[level-1] == null )
			genFighter(level-1);
		var r = new neko.Random();
		r.setSeed(level * 11 + 46);
		var parts;
		do {
			parts = [
				r.int(data.pre.length),
				r.int(data.mid.length),
				r.int(data.post.length),
				r.int(data.title.length),
				r.int(data.qual.length),
			];
		} while( findSimilar(parts,level) );
		var fam;
		var fcount = 12;
		do {
			fam = Data.DINOZ_FAMILY[r.int(fcount)];
			if( fam == null )
				continue;
		} while( fam == null );
		var name = data.pre[parts[0]] + data.mid[parts[1]] + data.post[parts[2]];
		var title = data.title[parts[3]] + " " + data.qual[parts[4]];
		var lvl = 5 + level;
		var gfx = UID.CHARS.charAt(fam.gfx)+UID.CHARS.charAt((lvl >= 9)?9:0)+UID.make(11,r.int)+UID.CHARS.charAt(0)+UID.CHARS.charAt(0)+UID.CHARS.charAt(0);
		var f : TournamentFighter = {
			name : name,
			title : title,
			parts : parts,
			level : lvl,
			gfx : gfx,
			chk : db.Dino.calculateCheckSum(gfx),
			fam : Data.DINOZ_FAMILY[UID.CHARS.indexOf(gfx.charAt(0))],
		};
		data.fighters[level] = f;
		return f;
	}
	
	public static function genRandName() {
		if( data == null )
			data = initData();
		var level = 2+Std.random(45);
		var r = new neko.Random();
		r.setSeed(level * 11 + 46);
		var parts;
		parts = [
				r.int(data.pre.length),
				r.int(data.mid.length),
				r.int(data.post.length),
				r.int(data.title.length),
				r.int(data.qual.length),
			];
		return data.pre[parts[0]] + data.mid[parts[1]] + data.post[parts[2]];
	}

}