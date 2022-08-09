package data;

typedef Spell = {
	var id : String;
	var sid : Int;
	var mana : Int;
	var name : String;
	var desc : String;
	var permanent : Bool;
	//manawar
	var manawar : Bool;
	var gold	: Int;
	//clan war
	var max : Int;
	var reputationMax : Null<Int>;
	var reputationMin : Null<Int>;
	var noWar : Bool;
	
	var daily : Bool;
}

class SpellXML extends haxe.xml.Proxy<"spells.xml",Spell> {

	public static function parse() {
		return new data.Container<Spell,SpellXML>(true).parse("spells.xml",function(id,sid,s) {
			return {
				id : id,
				sid : sid,
				name : s.att.name,
				desc : Tools.format(s.innerData),
				mana : Std.parseInt(s.att.mana),
				permanent : s.has.permanent,
				max : s.has.max ? Std.parseInt(s.att.max) : 100000,
				reputationMax : s.has.reputationMax ? Std.parseInt(s.att.reputationMax) : null,
				reputationMin : s.has.reputationMin ? Std.parseInt(s.att.reputationMin) : null,
				noWar : s.has.noWar ? Std.string(s.att.noWar) == "1" : false,
				
				manawar : s.has.manawar ? Std.string(s.att.manawar) == "1" : false,
				gold :  s.has.gold ? Std.parseInt(s.att.gold) : null,
				daily : s.has.daily ? Std.string(s.att.daily) == "1" : false,
			};
		});
	}

}