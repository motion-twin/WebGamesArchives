package data ;

import db.NewsPaper.GESlot ;


class GESlotXML {
	
	static public function parse() {
		var res = [new Hash(), new Hash()] ;
		
		for( e in Data.xml("guildian.xml").elements() ) {
			parseSlot(new haxe.xml.Fast(e), res) ;
		}
		
		return res ;
		
	}

	
	static function parseSlot(d : haxe.xml.Fast, h : Array<Hash<GESlot>>) {
		 var g = {
			id : d.att.id,
			title : d.att.title,
			date : null,
			author : null,
			content : null,
			img : d.att.img,
			specialImg : null,
			type : Text.getText(d.att.type + "_guildian"),
			slot : null
		}
		
		if (d.att.type == "pub") {
			g.slot = db.NewsPaper.IMG_AD ;
			h[1].set(g.id, g) ;
		} else {
			g.content = Data.TEXTDESC.format(d.innerData) ;
			g.slot = db.NewsPaper.FLAVOR_TEXT ;
			h[0].set(g.id, g) ;
		}
		
	}
	
}