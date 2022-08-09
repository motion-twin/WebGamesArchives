package data;

typedef Sneak = {
	var id : String;
	var sid : Int;
	var level : Int;
	var name : String;
	var enter : Map;
	var exit : Map;
	var fail : Map;
	var messages : { success:String, fightStart:String, fightWon:String, fightLost:String };
	var cond : Condition;
	var scenario : Scenario;
	var monsters : List<Monster>;
}

class SneakXML extends haxe.xml.Proxy<"sneaks.xml",Sneak> {

	public static function parse() {
		return new data.Container < Sneak, SneakXML > ().parse("sneaks.xml", function(id, sid, s) {
			var enter = s.node.enter;
			var exit = s.node.exit;
			var fail = s.node.fail;
			var messages = s.node.messages;
			var d : Sneak = {
				id : id,
				sid : sid,
				level : Std.parseInt(s.att.level),
				enter : Data.MAP.getName(enter.att.place),
				fail : Data.MAP.getName(fail.att.place),
				exit : Data.MAP.getName(exit.att.place),
				monsters : Lambda.map( s.node.monsters.innerData.split(':'), function(id) return Data.MONSTERS.getName(id) ),
				messages : {
						success : if(messages.hasNode.success) StringTools.trim(messages.node.success.innerData),
						fightStart : if( messages.hasNode.fightStart ) StringTools.trim(messages.node.fightStart.innerData),
						fightWon : if( messages.hasNode.fightWon ) StringTools.trim(messages.node.fightWon.innerData),
						fightLost : if( messages.hasNode.fightStart ) StringTools.trim(messages.node.fightLost.innerData),
					},
				name : s.att.name,
				cond : if(  s.has.cond ) Script.parse(s.att.cond) else Condition.CTrue,
				scenario : Data.SCENARIOS.getName( s.att.scenario ),
			};
			if(  d.enter.sneaks == null )
				d.enter.sneaks = new List<Sneak>();
			d.enter.sneaks.add( d );
			return d;
		});
	}

}
