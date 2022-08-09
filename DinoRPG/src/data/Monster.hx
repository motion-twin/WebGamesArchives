package data;
import Fight._AddFighterEffect;
import Fight._Property;

typedef Monster = {
	var id : String;
	var mid : Int;
	var name : String;
	var elements : Array<Int>;
	var attackBonus : Int;
	var defenseBonus : Int;
	var groups : Null<Array<Int>>;
	var skills : List<Skill>;
	var life : Int;
	var size : Int;
	var level : Int;
	var xp : Int;
	var frame : String;
	var gfx : String;
	var addfx : Null<_AddFighterEffect>;
	var props : List<_Property>;
	var balance : Bool;
	var capture : Bool;
	var gold : Float;
	var xpBonus : Int;//bonus when dinoz is the same level
	var special : Bool;
	
	var cond : Condition;
}

class MonsterXML extends haxe.xml.Proxy<"monsters.xml",Monster> {

	static function setPlaces( m : haxe.xml.Fast, d : Monster ) {
		var proba = if( m.has.proba ) Std.parseInt(m.att.proba) else 100;
		if( m.has.zones )
			for( z in Tools.intArray(m.att.zones) )
				for( m in Data.MAP )
					if( m != null && m.zone == z )
						Data.MONSTER_PLACES.get(m.mid).push({ p : proba, m :  d });
		if( m.has.places )
			for( p in m.att.places.split(":") )
				Data.MONSTER_PLACES.get(Data.MAP.getName(p).mid).push({ p : proba, m :  d });
	}

	public static function parse() {
		return new data.Container<Monster,MonsterXML>(true).parse("monsters.xml",function(id,mid,m) {
			var elts = Tools.intArray(m.att.elts);
			var kind = elts.length;
			var skills = if( !m.has.skills )
				new List()
			else
				Lambda.map(m.att.skills.split(":"),function(s) { return Data.SKILLS.getName(s); });
			var level = Std.parseInt(m.att.level);
			var addfx = null;
			if( m.has.fx )
				addfx = switch( m.att.fx ) {
					case "stand": _AFStand;
					case "ground": _AFGround;
					case "fall": _AFFall;
					case "run":	_AFRun;
					case "grow": _AFGrow;
					case "fixed" : _AFPos(Std.parseInt(m.att.x), Std.parseInt(m.att.y));
					case "anim" : _AFAnim( m.att.anim );
					default: throw "Unknown fx "+m.att.fx;
				};
			var d : Monster = {
				id : id,
				mid : mid,
				name : m.att.name,
				elements : if( kind == 5 ) elts else [0,0,0,0,0,0],
				attackBonus : if( kind == 5 ) 0 else elts[0],
				defenseBonus : switch( kind ) { case 1: elts[0]; case 2: elts[1]; default: 0; },
				groups : if( m.has.groups ) Tools.intArray(m.att.groups) else null,
				skills : skills,
				life : Std.parseInt(m.att.life),
				size : if( m.has.size ) Std.parseInt(m.att.size) else 100,
				level : level,
				xp : if( m.has.xp ) Std.parseInt(m.att.xp) else 10,
				frame : if( m.has.frame ) m.att.frame else id,
				gfx : if( m.has.gfx ) m.att.gfx else null,
				addfx : addfx,
				balance : m.has.balance,
				props : new List(),
				capture : (m.has.zones || m.has.places) && !m.has.nocapture,
				gold : (m.has.gold) ? Std.parseFloat(m.att.gold) : 1.0,
				xpBonus : (m.has.xpBonus) ? Std.parseInt(m.att.xpBonus) : 0,
				special : m.has.special ? m.att.special == "1" : false,
				cond :  m.has.cond ? Script.parse(m.att.cond) : Condition.CTrue,
			};
			if( m.has.nomove )
				d.props.push(_PStatic);
			if( m.has.boss )
				d.props.push(_PBoss);
			if( m.has.groundonly )
				d.props.push(_PGroundOnly);
			if( m.has.dark )
				d.props.push(_PDark);
			setPlaces(m,d);
			for( x in m.elements )
				setPlaces(x,d);
			return d;
		});
	}

}
