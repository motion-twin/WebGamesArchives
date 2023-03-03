import db.CityBuilding;
import db.ZoneItem;
import db.Tool;

class Building {
	
	public var id			: Int;

	public var key			: String;
	public var name 		: String;
	public var def			: Int;
	public var description	: String;
	public var needList 	: List<{ t: Tool, amount : Int}>;
	public var parent		: String;
	public var temporary	: Bool;
	public var paCost		: Int;
	public var icon			: String;
	public var hasLevels	: Bool;
	public var unbreakable	: Bool;
	public var mod			: String;
	public var drop			: data.Drop;

	public function new() {
		id = 0;
		name = "#NAME";
		needList = new List();
		parent = "";
		def = 0;
		description = "#DESC";
		temporary = false;
		paCost = 0;
	}

	public function print() {
		return "<strong>"+name+"</strong>";
	}
	
	public function getParent() {
		return if(parent=="") null else XmlData.getBuildingByKey(parent);
	}
	
	public function getDepth() {
		var n = 0;
		var b = this;
		while( (b=b.getParent()) != null )
			n++;
		return n;
	}
	
	public function getParents() { // renvoie la liste de toutes les dépendances
		var list = new List();
		var b = this;
		while(b.parent!="") {
			b = b.getParent();
			list.add(b);
		}
		return list;
	}
	
	public function getRarityColor() {
		return mt.deepnight.Color.intToHex(
			switch(drop) {
				case data.Drop.b	: 0xC0C0C0;
				case data.Drop.c	: 0x80FF00;
				case data.Drop.u	: 0xFFFF00;
				case data.Drop.r	: 0x0080FF;
				case data.Drop.e	: 0xA953FF;
			}
		);
	}
	
	public function printParents() {
		var arr = new Array();
		for(b in getParents())
			arr.push(b.print());
		arr.reverse();
		return arr.join(" &gt; ");
	}
}
