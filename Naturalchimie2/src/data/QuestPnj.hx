package data ;

typedef QuestPnj = {
	var id : String ;
	var name : String ;
	var school : String ;
	var gid : String ;
	var zone : String ;
}


class QuestPnjXML {
	public static function parse() {
		var h = new Hash() ;
		var file = "questPnjs.xml" ;
		for( e in Data.xml(file).elements() ) {
			parsePnj(new haxe.xml.Fast(e), h) ;
		}
		return h ;
	}

	
	static function parsePnj(d : haxe.xml.Fast, h : Hash<QuestPnj>) {
		var data : QuestPnj = {
				id : d.att.id,
				name : d.att.name,
				school : d.att.school,
				gid : d.att.gid,
				zone : d.att.zone
			} ;
		h.set(data.id, data) ;
	}

}
