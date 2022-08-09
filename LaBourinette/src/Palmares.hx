
enum PalmaresKind {
	@meta({ optional:false, steps:[3,   20,  100] }) Victories;
	@meta({ optional:false, steps:[20, 300, 3000] }) Picorons;
	@meta({ optional:false, steps:[5,   50,  500] }) Picostars;
	@meta({ optional:false, steps:[5,   50,  250] }) Games;
	@meta({ optional:false, steps:[5,   20,  150] }) Injures;
	@meta({ optional:false, steps:[5,   50,  500] }) Corruptions;
	@meta({ optional:false, steps:[5,   30,  150] }) Players;
	@meta({ optional:true,  steps:[1            ] }) BetaTester;
	@meta({ optional:false, steps:[1,   30,  100] }) SoloWinner;
	@meta({ optional:false, steps:[5,   30,  100] }) Defies;
	@meta({ optional:false, steps:[3,   15,  100] }) Hooligans;
}

typedef PalmaresData = Array<Int>;

class PalmaresLine {
	public var kind:PalmaresKind;
	public var value:Int;
	public var meta:{ optional:Bool, steps:Array<Int>, label:String, titles:Array<String> };

	public function new (k, v){
		this.kind = k;
		this.value = v == null ? 0 : v;
		this.meta = cast Reflect.field(haxe.rtti.Meta.getFields(PalmaresKind), Std.string(k)).meta[0];
	}

	public function getCss() : String {
		return Std.string(kind).toLowerCase();
	}

	public function getLevel() : Int {
		var level = 0;
		for (v in meta.steps)
			if (value < v)
				return level;
			else
				++level;
		return level;
	}

	public function getTitleKey() : String {
		var level = getLevel();
		if (level == 0)
			return null;
		return Std.string(kind)+"_title"+(level-1);
	}

	public function getLabel() : String {
		return Text.getText(Std.string(kind)+"_label");
	}

	public function getTitle() : String {
		var key = getTitleKey();
		if (key == null)
			return "";
		return Text.getText(key);
	}

	public function isVisible() : Bool {
		return !meta.optional || value > 0;
	}
}

class Palmares {
	var team : db.Team;
	var data : PalmaresData;

	public function new(t:db.Team){
		this.team = t;
		this.data = if (team.spalmares == null) [] else haxe.Unserializer.run(team.spalmares);
	}

	public function isBeta() : Bool {
		var v = getLine(BetaTester);
		return (v != null) && (v.value > 0);
	}

	public function incLine( k:PalmaresKind, ?v=1 ){
		if (team.skind == 0 || team.isBot() || v == 0)
			return;
		var index = tools.EnumTools.indexOf(k);
		if (data[index] == null)
			data[index] = v;
		else
			data[index] += v;
	}


	public function setLine( k:PalmaresKind, v:Int ) : Bool {
		if (team.skind == 0 || team.isBot() || v == 0)
			return false;
		var index = tools.EnumTools.indexOf(k);
		if (data[index] == v)
			return false;
		data[index] = v;
		return true;
	}

	public function update(){
		if (team.skind == 0 || team.isBot())
			return;
		if (data.length > 0)
			team.spalmares = haxe.Serializer.run(data);
	}

	public function getLine( k:PalmaresKind ) : PalmaresLine {
		for (v in iterator()){
			if (v.kind == k)
				return v;
		}
		return null;
	}

	public function iterator() : Iterator<PalmaresLine> {
		var result = [];
		var i = 0;
		var me = this;
		tools.EnumTools.foreach(PalmaresKind, function(e){
			result.push(new PalmaresLine(e, me.data[i++]));
		});
		var result = Lambda.filter(result, function(r) return r.isVisible());
		return result.iterator();
	}
}