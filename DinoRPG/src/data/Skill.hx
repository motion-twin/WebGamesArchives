package data;

enum SkillType {
	SPermanent;
	SEvent;
	SAttack;
	SSpecial;
	SUnique;
	SGather;
	SInvocation;
}

typedef Skill = {
	var id : String;
	var sid : Int;
	var name : String;
	var elt : Int;
	var elt2 : Null<Int>;
	var elt3 : Null<Int>;
	var desc : String;
	var require : Array<Int>;
	var level : Int;
	var type : SkillType;
	var candisable : Bool;
	var restricted : Null<Array<String>>;
	var isSphere : Bool;
	var isNextGen : Bool;
	var energy : Int;
}

using Lambda;
class SkillXML extends haxe.xml.Proxy<"skills.xml",Skill> {
	
	inline static var DEFAULT_ENERGY_COST = 20;
	
	public static function parse() {
		return new data.Container<Skill,SkillXML>().parse("skills.xml",function(id,iid,s) {
			var type = switch( s.att.type ) {
				case "P": SPermanent;
				case "E": SEvent;
				case "A": SAttack;
				case "S": SSpecial;
				case "U": SUnique;
				case "G": SGather;
				case "I": SInvocation;
				default: throw "Unknown skill type : "+s.att.type;
			};
			var req = 	if( s.has.require ) s.att.require.split(":").map(Tools.makeId).array()
						else new Array();
			return {
				id : id,
				sid : iid,
				name : s.att.name,
				elt : Tools.element(s.att.elt),
				elt2 : s.has.elt2 ? Tools.element(s.att.elt2) : null,
				elt3 : s.has.elt3 ? Tools.element(s.att.elt3) : null,
				desc : Tools.format(s.innerData),
				require : req,
				type : type,
				level : if( s.has.level ) Std.parseInt(s.att.level ) else null,
				candisable : type == SEvent || type == SAttack || s.has.candisable,
				restricted : if( s.has.restricted ) s.att.restricted.split(':') else null,
				isSphere : false,
				isNextGen : false,
				energy : if( s.has.energy ) Std.parseInt(s.att.energy) else DEFAULT_ENERGY_COST,
			};
		});
	}
	
	static function calculateLevel( s : Skill ) {
		if( s.level != null )
			return s.level;
		var max = 0;
		for( sid in s.require ) {
			var l = calculateLevel(Data.SKILLS.getId(sid));
			if( l > max ) max = l;
		}
		max += 1;
		s.level = max;
		return max;
	}
	
	static function hasRequirement(s : Skill, r : Skill ) {
		return s.require.has( r.sid );
		//return s.require.map( function(sid) return Data.SKILLS.getId(sid) ).has(r);
	}
	
	static function checkNextGen( s : Skill ) {
		if( s.require == null ) return;
		if( s.isNextGen ) return;
		//
		if( s == Data.SKILLS.list.lvlup ) {
			s.isNextGen = true;
		} else if( hasRequirement(s, Data.SKILLS.list.lvlup) ) {
			s.isNextGen = true;
		} else {
			for( sid in s.require ) {
				var r = Data.SKILLS.getId(sid);
				checkNextGen( r );
				if( r.isNextGen ) s.isNextGen = true;
			}
		}
	}
	
	public static function check() {
		for( s in Data.SKILLS ) {
			calculateLevel(s);
			s.isNextGen = hasRequirement(s, Data.SKILLS.list.lvlup);
		}
		for( s in Data.SKILLS ) {
			s.isSphere = hasRequirement(s, Data.SKILLS.list.sphere);
		}
		for( s in Data.SKILLS ) {
			checkNextGen(s);
		}
		for( s in Data.SKILLS ) {
			if( s.energy == null )
				throw s.name + " has a null energy cost";
		}
	}
}
