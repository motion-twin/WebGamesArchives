import Protocole;
import mt.bumdum9.Lib;

class Data implements haxe.Public {//}

	static var SKILLS = 	mt.data.Mods.parseODS( "client.ods", "skills", DataSkill );
	static var STATUS = 	mt.data.Mods.parseODS( "client.ods", "status", DataStatus );
	static var ACTIONS = 	mt.data.Mods.parseODS( "client.ods", "actions", DataAction );

	
	static var BALLS = 	{
		var data = mt.data.Mods.parseODS( "client.ods", "balls", DataBall );
		data.push(data[data.length-1]);
		data;
	}
	static var SPELLS = 	mt.data.Mods.parseODS( "client.ods", "spells", DataSpell );

	static var SPELL_MAX = 10;
	
	static function getGhost(type:HeroType):HeroGhost {
		
		return { skills:[], name : null, awakening:0, knowledge:0, type:type, id:0, state:null, tid:Std.string(type).split("_").join("") };
	}
	
	static function ballDb(id) {
		return BALLS[Type.enumIndex(id)];
	}
	
	
//{
}
	