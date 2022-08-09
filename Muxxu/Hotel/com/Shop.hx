import Protocol;

#if flash Fail! #end

enum ShopItemEffect {
	S_Item(i:_Item);
	S_Money(n:Int);
	S_Staff;
	S_Pack(cat:Int);
}

typedef ShopItem = {
	var id			: Int;
	var name		: String;
	var desc		: String;
	var cat			: String;
	var shortCat	: String;
	var catTag		: String;
	var catId		: Int;
	var effect		: ShopItemEffect;
	var icon		: Null<String>;
	var money		: Int;
	var tokens		: Int;
	var priority	: Int;
}

class ShopXml {
	public static var ICON_PATH = "img/icons/%.png";
	private static var BASE	: IntHash<ShopItem> = init();
	public var items		: IntHash<ShopItem>;
	
	private static function init() {
		var raw = neko.io.File.getContent(Config.TPL+"../../xml/"+Config.LANG+"/shop.xml");
		if ( raw==null || raw=="" )
			throw "no shop data";
			
		var all = new IntHash();
		var xml = Xml.parse(raw);
		var fast = new haxe.xml.Fast(xml.firstChild());
		
		var id = 0;
		var catId = 0;
		for(ncat in fast.nodes.cat) {
			for (node in ncat.nodes.p) {
				var raw = StringTools.replace(node.att.id, ")", "");
				var key = raw.split("(")[0].toLowerCase();
				var data = raw.split("(")[1];
				var p : ShopItem = {
					id			: id,
					name		: if (node.has.name) node.att.name else "?",
					desc		: if (node.innerHTML != null) node.innerHTML else "?",
					cat			: ncat.att.name,
					shortCat	: if (ncat.has.short) ncat.att.short else null,
					catTag		: ncat.att.tag,
					catId		: catId,
					effect		: null,
					icon		: if(node.has.icon) StringTools.replace(ICON_PATH, "%", node.att.icon) else null,
					money		: if (node.has.money) Std.parseInt(node.att.money) else 0,
					tokens		: if (node.has.token) Std.parseInt(node.att.token) else 0,
					priority	: if (node.has.priority) Std.parseInt(node.att.priority) else 0,
				}
				switch(key) {
					case "staff" :
						p.effect = S_Staff;
						p.money = 99999;
						p.tokens = 99999;
					case "money" :
						p.effect = S_Money(Std.parseInt(data));
					case "item" :
						var it = Type.createEnum(_Item, "_"+data);
						var tdata = T.getItemText(it);
						p.effect = S_Item(it);
						p.name = tdata._name;
						p.desc = tdata._rule;
						p.icon = StringTools.replace(ICON_PATH, "%", "item_"+Std.string(it).substr(1).toLowerCase());
					case "pack" :
						p.effect = S_Pack(catId);
						p.desc = T.get.ShopPack;
					default			: throw "unknown shop key "+key;
				}
					
				all.set(id, p);
				id++;
			}
			catId++;
		}
		
		return all;
	}
	
	public static function getCategories() {
		var all = new Hash();
		for (sitem in BASE)
			all.set( sitem.catTag, {
				id		: sitem.catId,
				name	: sitem.cat,
				short	: sitem.shortCat,
			} );
		return all;
	}
	
	public static function getShortCategories() {
		var catHash = new IntHash();
		for (sitem in BASE)
			switch(sitem.effect) {
				case S_Item(item):
					catHash.set( Type.enumIndex(item), sitem.shortCat );
				case S_Staff :
				case S_Money(_) :
				case S_Pack(_) :
			}
		return catHash;
	}
	
	public function new(hotel:_Hotel) {
		items = haxe.Unserializer.run( haxe.Serializer.run(BASE) );
		for (sitem in items)
			switch(sitem.effect) {
				case S_Item(item):
				case S_Staff :
					var data = hotel.getStaffCost();
					sitem.money = data.money;
					sitem.tokens = data.tokens;
				case S_Money(n) :
					sitem.desc = StringTools.replace(sitem.desc, "%", Std.string(n));
				case S_Pack(catId):
					sitem.desc = StringTools.replace(sitem.desc, "%", sitem.cat);
			}
	}
	
	public function getSorted() {
		// groupement par catégorie
		var allCats = new Array();
		for (item in items) {
			if ( allCats[item.catId]==null )
				allCats[item.catId] = new Array();
			allCats[item.catId].push(item);
		}
		
		// tri de chaque catégorie
		for (cat in allCats)
			cat.sort( function(a,b) {
				if (a.priority<b.priority)	return 1;
				if (a.priority>b.priority)	return -1;
				//if (a.money<b.money)	return -1;
				//if (a.money>b.money)	return 1;
				if (a.name<b.name)		return -1;
				if (a.name>b.name)		return 1;
				return 0;
			});
			
		// liste finale
		var final = new Array();
		for (cat in allCats)
			for (it in cat)
				final.push(it);
		
		return final;
	}
}
