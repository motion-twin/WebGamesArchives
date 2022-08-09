import com.Protocol;

private typedef Init = haxe.macro.MacroType<[cdb.Module.build("data.cdb")]>;

#if mesCouilles
class Data {} // flashdevel top level hack
#end

class DataTools {
	public static inline function getWallTexture(frame:Int) return Data.WallPaper.all[frame];
	//public static inline function getBed(frame:Int) return Data.Bed.all[frame];
	//public static inline function getBath(frame:Int) return Data.Bed.all[frame];

	public static function getQuest(?sid:String, ?id:Data.QuestKind) : Null<Data.Quest> {
		if( sid==null )
			sid = id.toString();
		for(q in Data.Quest.all)
			if( q.id.toString()==sid )
				return q;
		return null;
	}

	public static inline function isDaily(?sid:String, ?id:Data.QuestKind) {
		var q = getQuest(sid, id);
		return q==null ? false : q.rarityId!=Data.RarityKind.Never;
	}

	public static function getWallColor(id:String) : Null<Data.WallColor> {
		for(c in Data.WallColor.all)
			if( c.id.toString()==id )
				return c;
		return null;
	}

	static inline function teint(c:Int) return mt.deepnight.Color.mix(c, 0x4e00ff, 0.2);

	public static function getWallColorCode(id:String, ?addAlpha=false) : Int {
		var e = getWallColor(id);
		var c = teint( e==null ? 0x808080 : e.color );
		return addAlpha ? 0xff<<24 | c : c;
	}

	public static function getBoss(curLevel:Int) {
		return Data.Boss.all[ mt.MLib.min( curLevel, Data.Boss.all.length-1 ) ];
	}

	public static inline function getRarityValue(e:Data.RarityKind) : Int {
		return Data.Rarity.get(e).value;
	}

	public static function getCustomItemRarity(i:Item) {
		switch( i ) {
			case I_Bed(f) : return Data.Bed.all[f].rarityId;
			case I_Bath(f) : return Data.Bath.all[f].rarityId;
			case I_Ceil(f) : return Data.Ceil.all[f].rarityId;
			case I_Furn(f) : return Data.Furn.all[f].rarityId;
			case I_Wall(f) : return Data.WallFurn.all[f].rarityId;

			case I_Texture(f) : return Data.WallPaper.all[f].rarityId;
			case I_Color(id) : return Data.WallColor.resolve(id).rarityId;

			default : return Data.RarityKind.Never;
		}
	}

	public static function convertAffect(e:Data.BossAffectKind) : Affect {
		return switch( e ) {
			case Data.BossAffectKind.Cold : Cold;
			case Data.BossAffectKind.Heat : Heat;
			case Data.BossAffectKind.Noise : Noise;
			case Data.BossAffectKind.Odor : Odor;
			case Data.BossAffectKind.Sunlight : SunLight;
		}
	}

	public static function getEvents(now:Float) : Array<Data.Event> {
		var a = [];
		for(e in Data.Event.all)
			if( hasEvent(e.id, now, false) )
				a.push(e);
		return a;
	}

	public static function hasEvent(id:Data.EventKind, now:Float, withTolerance:Bool) {
		var e = Data.Event.get(id);
		//#if debug return true; #end

		#if !debug
		if( !e.active )
			return false;
		#end

		var now = Date.fromTime(now);
		var start = e.start.split("-");
		var end = e.end.split("-");

		var now = (now.getMonth()+1)*32 + now.getDate();
		var start = Std.parseInt(start[0])*32 + Std.parseInt(start[1]);
		var end = Std.parseInt(end[0])*32 + Std.parseInt(end[1]);

		var tolerance = withTolerance ? 1 : 0;
		if( end>=start )
			return now>=start-tolerance && now<=end+tolerance;
		else
			return now>=start-tolerance || now<=end+tolerance;

		//var start = e.start.split("-");
		//var end = e.end.split("-");
		//return {
			//id		: id,
			//start	: { month:Std.parseInt(start[0]), day:Std.parseInt(start[1]) },
			//end		: { month:Std.parseInt(end[0]), day:Std.parseInt(end[1]) },
		//}
	}

	public static function getDailyReward(day:Int) {
		for(dr in Data.DailyReward.all)
			if( dr.day==day )
				return dr;
		return Data.DailyReward.all[0];
	}
}
