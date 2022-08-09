package data;
import DungeonCodec.DungeonStruct;

enum DungeonScenarioKind {
	DSKNone;
	DSKObj( obj : data.Object, count : Int );
	DSKCollec( col : data.Collection );
	DSKMonsters( ml : List<data.Monster> );
	DSKBlock( sc : List<Int> );
}

typedef DungeonScenario = {
	var text : String;
	var icon : String;
	var reload : Bool;
	var msgIcon : Null<String>;
	var kind : DungeonScenarioKind;
	var pos : { l : Int, x : Int, y : Int };
}

typedef DungeonStage = {
	var rawData : String;
	var skin : String;
	var data : DungeonStruct;
	var scenarios : Array<DungeonScenario>;
}

typedef Dungeon = {
	var id : String;
	var did : Int;
	var name : String;
	var enter : { text : String, place : Map };
	var exit : { text : String, place : Map };
	var cond : Condition;
	var monsters : List<Monster>;
	var gold : Int;
	var stages : Array<DungeonStage>;
	var tower : Bool;
}

class DungeonXML extends haxe.xml.Proxy<"dungeons.xml",Dungeon> {

	public static function parse() {
		return new data.Container<Dungeon,DungeonXML>().parse("dungeons.xml",function(id,did,d) {
			var stages = new Array();
			for( s in d.nodes.stage ) {
				var scenarios = new Array<DungeonScenario>();
				for( s in s.nodes.scenario ) {
					var kind = if( s.has.obj )
						DSKObj(Data.OBJECTS.getName(s.att.obj),s.has.count ? Std.parseInt(s.att.count) : 1)
					else if( s.has.collec )
						DSKCollec(Data.COLLECTION.getName(s.att.collec));
					else if( s.has.monsters )
						DSKMonsters(Lambda.map(s.att.monsters.split(":"),Data.MONSTERS.getName));
					else if( s.has.block )
						DSKBlock(Lambda.map(s.att.block.split(":"),Std.parseInt));
					else {
						for( a in s.x.attributes() )
							switch( a ) {
							case "icon","micon", "reload":
							default: throw "Unknown attribute '"+a+"'";
							}
						DSKNone;
					}
					var text = StringTools.trim(s.innerHTML);
					scenarios.push({
						icon : if( s.has.icon ) s.att.icon else switch(kind) {
							case DSKMonsters(_),DSKBlock(_): null;
							case DSKObj(_,_), DSKCollec(_): "chest";
							default: s.att.icon;
						},
						msgIcon : if( s.has.micon ) s.att.micon else switch( kind ) {
							case DSKObj(_,_), DSKCollec(_): "chest";
							default : null;
						},
						text : (text == "") ? null : text,
						reload : s.has.reload,
						kind : kind,
						pos : null,
					});
				}
				stages.push({
					rawData : sys.io.File.getContent(Config.TPL+"../xml/dungeons/"+id+"_"+stages.length+".xml"),
					skin : s.att.skin,
					data : null,
					scenarios : scenarios,
				});
			}
			var ml = d.att.monsters.split(":");
			var enter = d.node.enter;
			var exit = d.node.exit;
			var d : Dungeon = {
				id : id,
				did : did,
				enter : { text : enter.innerData, place : Data.MAP.getName(enter.att.place) },
				exit : { text : exit.innerData, place : Data.MAP.getName(exit.att.place) },
				name : d.att.name,
				cond : if( d.has.cond ) Script.parse(d.att.cond) else Condition.CTrue,
				gold : Std.parseInt(d.att.gold),
				monsters : Lambda.map(ml,Data.MONSTERS.getName),
				stages : stages,
				tower : d.has.tower,
			};
			d.enter.place.dungeon = d;
			return d;
		});
	}

}
