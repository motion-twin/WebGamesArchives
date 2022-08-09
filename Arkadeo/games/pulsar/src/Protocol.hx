import Protocol;
import mt.bumdum9.Lib;

@:build(ods.Data.build("data.ods", "bads", "id")) enum BadType { }
@:build(ods.Data.build("data.ods", "upgrades", "id")) enum UpgradeType { }

typedef DataBad = {
	id:BadType,
	dif:Int,
	life:Int,
	
	sfx_hit:Int,
	sfx_explo:Int,
};

typedef DataWave = {
	max:Int,
	weight:Int,
	chrono:Int,
	bads:Array<BadType>,
	type:WaveType,
	start:Null<Int>,
	end:Null<Int>,
	test:Bool,
	minLevel:Int,
}

enum PowerUp {
	@weight(4) POWER;
	@weight(3) FIRERATE;
	@weight(2) MULTI;
	@weight(1) TEMPO;
	@weight(2) LONG;
	@weight(4) BOMB;
	@weight(4) SIDES;
}

enum WaveType {
	POINT;
	CORNER;
	PATH(gap:Int);
	CIRCLE(ray:Int);
	NOISE;
	SIDE;
	CIRCLE_SEEK(ray:Int);
	MIRROR;
	BORDER;
	
	KAMIKAZE_PATH;
}


typedef RunState = {
	upgrades : Array<UpgradeType>,
}