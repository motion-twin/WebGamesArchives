#if js
JS MUST NOT CONTAIN THIS
#end

import BodyPart;

private class ItemProxy extends haxe.xml.Proxy<"lang/fr/tpl/items.xml",Item> {}

enum _ItemFamily {
	HAMMER;
	ARMOR(part:BodyPart);
	DRUG;
	ORGAN(part:BodyPart);
}

enum _ItemCarac {
	_HideFault(modifier:Int); // en cas de faute, ne pas être sifflé
	_KillBall(modifier:Int); // écraser un picoron (attaquant)
	_PassBall(modifier:Int); // passer la balle avec précision
	_CatchBall(modifier:Int); // attraper un picoron (défenseur)
	_ThrowPrecision(modifier:Int); // précision de lancer
	_AllThrows(modifier:Int); // modifie tous les skills de lancer
	_PowerThrow(modifier:Int); // lancer en puissance
	_SpeedThrow(modifier:Int); // lancer en rapidité
	_CurveThrow(modifier:Int); // lancer courbe
	_AllReceptions(modifier:Int); // modifie tous les skill de réception
	_PowerReception(modifier:Int); // rattraper des lancers en puissance
	_SpeedReception(modifier:Int); // rattraper des lancers en rapidité
	_CurveReception(modifier:Int); // rattraper des lancers courbes
	_BatPrecision(modifier:Int); // précision du batteur lorsque lancer rattrapé
	_BatPower(modifier:Int); // puissance du batteur (distance)
	_Initiative(modifer:Int); // initiative des joueurs (ordre des IA, peu important)
	_Attack(modifier:Int); // mettre un coup à un adversaire
	_Push(modifier:Int); // pousser un adversaire
	_Esquive(modifier:Int); // esquiver un coup ou une poussette
	_Speed(modifier:Int); // vitesse du maraveux
	_AttractPico(modifier:Int); // attire picoron
	_None;
	_Hurt(modifier:Int); // blesser l'adversaire
}

enum _DrugEffect {
	_None;
	_IncSkill(sm:_ItemCarac);
	_IncLife(max:Int);
	_IncMorale(max:Int);
	_IncAggr(max:Int);
	// TODO: speed
}

class Item {
	public var xid : String;
	public var dbid : String;
	public var family : _ItemFamily;
	public var name : String;
	public var desc : String;
	public var maxLife : Null<Int>;
	public var price : Int;
	public var active : Bool;
	public var frequency : Int;
	public var caracs : Array<_ItemCarac>;
	public var faceId : Int;
	public var level : Int;

	public function getSmallDesc() : String {
		return ((caracs != null && caracs.length > 0) ? "\n"+Lambda.map(caracs, caracToString).join(", ") : "");
	}

	public function getKind() : String {
		return switch (family){
			case HAMMER: "Hammer";
			case ARMOR(p): "Armor";
			case DRUG: "Drug";
			case ORGAN(p): "Organ";
		}
	}

	public function getKindImage() : String {
		return switch (family){
			case HAMMER: "equip_type_maillet.jpg";
			case ARMOR(p):
				switch (p){
					case _HEAD: "equip_type_tete.jpg";
					case _ARM0,_ARM1: "equip_type_bras.jpg";
					case _CHEST: "equip_type_corps.jpg";
					case _LEGS: "equip_type_jambes.jpg";
				}
			case DRUG: "equip_type_poche.jpg";
			case ORGAN(p): "equip_type_poche.jpg";
		}
	}

	public function getDesc() : String {
		return desc;
	}

	public function getPrice() : Int {
		return price;
	}

	public function getResellPrice() : Int {
		return Math.ceil(0.7*price);
	}

	public function canBeRepaired() : Bool {
		return true;
	}

	function new(x:Xml, family:_ItemFamily){
		this.xid = x.get("id");
		this.family = family;
		this.dbid = x.get("dbId");
		this.name = x.get("name");
		var content = new StringBuf();
		for (c in x.firstElement())
			content.add(c.toString());
		this.desc = content.toString();
		this.price = Std.parseInt(x.get("price"));
		this.maxLife = Std.parseInt(x.get("life"));
		if (this.maxLife == null)
			this.maxLife = 1;
		this.caracs = parseCaracs(x.get("caracs"));
		this.faceId = Std.parseInt(dbid.substr(1));
		this.active = true; // TODO
		this.frequency = Std.parseInt(x.get("frequency"));
		this.level = Std.parseInt(x.get("level"));
	}

	function parseCaracs(s) : Array<_ItemCarac> {
		if (s == null || s == "")
			return [];
		var r = [];
		for (c in s.split(",")){
			if (c == "None"){
				r.push(_ItemCarac._None);
				continue;
			}
			var creg = ~/^([A-Za-z0-9]+)\(([-0-9\.]+)\)$/;
			if (!creg.match(c))
				throw "Bad carac format "+s+" in item "+dbid;
			r.push(
				Type.createEnum(_ItemCarac, "_"+creg.matched(1), [Std.parseInt(creg.matched(2))])
			);
		}
		return r;
	}

	inline public static function pm(v:Int){
		return "(" + (v >= 0 ? "+"+v : ""+v) + ")";
	}

	public static function caracToString( c:_ItemCarac ) : String {
		switch (c){
			case _None: return "Aucun bonus";
			case _HideFault(m): return "Cacher faute"+pm(m);
			case _KillBall(m): return "Ecraser picoron"+pm(m);
			case _PassBall(m): return "Passer picoron"+pm(m);
			case _CatchBall(m): return "Attraper"+pm(m);
			case _ThrowPrecision(m): return "Précision lancer"+pm(m);
			case _PowerThrow(m): return "Lancer fort"+pm(m);
			case _SpeedThrow(m): return "Lancer rapide"+pm(m);
			case _CurveThrow(m): return "Lancer courbe"+pm(m);
			case _AllThrows(m): return "Tous lancers"+pm(m);
			case _PowerReception(m): return "Swing fort"+pm(m);
			case _SpeedReception(m): return "Swing rapide"+pm(m);
			case _CurveReception(m): return "Swing courbe"+pm(m);
			case _AllReceptions(m): return "Tous swings"+pm(m);
			case _BatPrecision(m): return "Précision du swing"+pm(m);
			case _BatPower(m): return "Puissance du swing"+pm(m);
			case _Initiative(m): return "Initiative"+pm(m);
			case _Attack(m): return "Maraver"+pm(m);
			case _Push(m): return "Pousser"+pm(m);
			case _Esquive(m): return "Esquiver"+pm(m);
			case _Speed(m): return "Vitesse"+pm(m);
			case _AttractPico(m): return "Attire picoron"+pm(m);
			case _Hurt(m): return "Blesser"+pm(m);
		}
	}

	public function toString() : String {
		return xid;
	}
}

class Organ extends Item {
	public static var allOrgans = new Array<Organ>();
	public var index : Int;
	public var bodyPart : BodyPart;
	public var surgeryFactor : Float;
	public function new(x:Xml){
		bodyPart = tools.EnumTools.fromString(BodyPart, "_"+x.get("part"));
		super(x, ORGAN(bodyPart));
		surgeryFactor = Std.parseFloat(x.get("factor"));
		allOrgans.push(this);
		index = allOrgans.length;
	}

	override public function canBeRepaired() : Bool {
		return false;
	}

	override public function getSmallDesc() : String {
		return "Greffe permettant de soigner plus rapidement une blessure sur cet organe : "+(surgeryFactor*100)+" % de PA économisés.";
	}

	public static function random( ?bodyPart:BodyPart, ?seed:mt.Rand ){
		var avail = Lambda.list(allOrgans);
		if (avail.length == 0)
			throw "No organ defined";
		if (bodyPart != null)
			avail = Lambda.filter(avail, function(o) return o.bodyPart == bodyPart);
		if (avail.length == 0)
			throw "No organ after body filter";
		return tools.ArrayTools.at(avail, (seed == null) ? Std.random(avail.length) : seed.random(avail.length));
	}

	public static function getByIndex(i:Int) : Organ {
		return allOrgans[i-1];
	}
}

class Hammer extends Item {
	public static var allHammers = new List<Hammer>();
	public function new(x:Xml){
		super(x, HAMMER);
		allHammers.push(this);
	}
}

class Armor extends Item {
	public static var allArmors = new List<Armor>();
	public var bodyPart : BodyPart;
	public function new(x:Xml){
		bodyPart = switch(x.get("kind")){
			case "HEAD": BodyPart._HEAD;
			case "LEGS": BodyPart._LEGS;
			case "ARM":  BodyPart._ARM0;
			case "CHEST": BodyPart._CHEST;
			default: throw "Unsupported Armor kind "+x.get("kind")+" in items.xml";
		}
		super(x, ARMOR(bodyPart));
		allArmors.push(this);
	}
}

class Drug extends Item {
	public static var allDrugs = new List<Drug>();
	public var duration : Int;
	public var effects : Array<_DrugEffect>;
	public function new(x:Xml){
		super(x, DRUG);
		duration = Std.parseInt(x.get("duration"));
		effects = parseEffects(x.get("effects"));
		allDrugs.push(this);
	}

	override function getSmallDesc() : String {
		return ((effects != null && effects.length > 0) ? "\n"+Lambda.map(effects, effectToString).join(", ") : "");
	}

	override function canBeRepaired() : Bool {
		return false;
	}

	static function effectToString(e:_DrugEffect) : String {
		return switch (e){
			case _None: "Aucun effet particulier";
			case _IncSkill(c): Item.caracToString(c);
			case _IncLife(v): "Souffle "+Item.pm(v);
			case _IncMorale(v): "Moral "+Item.pm(v);
			case _IncAggr(v): "Aggressivité "+Item.pm(v);
		}
	}

	function parseEffects(s:String){
		if (s == null || s == "")
			return [];
		var r = [];
		for (c in s.split(",")){
			if (~/^[a-zA-Z0-9]+$/.match(c)){
				r.push(
					Type.createEnum(_DrugEffect, "_"+c, [])
				);
			}
			else {
				var creg = ~/^([A-Za-z0-9]+)\(([-0-9\.]+)\)$/;
				if (!creg.match(c))
					throw "Bad carac format "+s+" in item "+dbid;
				r.push(
					Type.createEnum(_DrugEffect, "_"+creg.matched(1), [Std.parseInt(creg.matched(2))])
				);
			}
		}
		return r;
	}
}

class ItemDb {
	public static var ALLBYID : Hash<Item> = new Hash();
	public static var ALL : Hash<Item> = {
		#if neko
		var xml = Xml.parse(neko.io.File.getContent(Config.TPL+"items.xml")).firstElement();
		#else
		var xml = Xml.parse(haxe.Resource.getString("items.xml")).firstElement();
		#end
		var h = new Hash();
		var addItem = function(i:Item){
			h.set(i.xid, i);
			ALLBYID.set(i.dbid, i);
		};
		for (x in xml.elements()){
			switch (x.nodeName){
				case "item":
					switch (x.get("kind")){
						case "HAMMER":
							addItem(new Hammer(x));
						case "HEAD","CHEST","ARM","LEGS":
							addItem(new Armor(x));
						default:
							throw "Unsuported item.xml "+x;
					}

				case "drug":
					addItem(new Drug(x));

				case "organ":
					addItem(new Organ(x));
			}
		}
		h;
	};

	// Get use the CodeId since it is called by the program like 'ItemDb.get.POURFENDEUR_DE_MOUCHES'
	public static var get = new ItemProxy(ALL.get);
	// ItemDb.getById("a01") uses the DbId since it is called by code working dynamically with abstract items.
	public static function getById( id:String ) : Item {
		return ALLBYID.get(id);
	}

	public static function random( filter:Item->Bool ){
		var avail = Lambda.list(ALL).filter(filter);
		var array = Lambda.array(avail);
		if (array.length == 0)
			return null;
		return array[Std.random(array.length)];
	}
}
