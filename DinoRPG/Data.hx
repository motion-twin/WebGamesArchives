import data.Container;
import data.Family;
import data.Collection;
import data.Effect;
import data.Monster;
import data.Skill;
import data.Map;
import data.Action;
import data.Object;
import data.Mission;
import data.Dialog;
import data.Ingredient;
import data.Background;
import data.Shop;
import data.Gather;
import data.Status;
import data.Scenario;
import data.Building;
import data.Dungeon;
import data.Spell;
import data.ClanAction;
import data.Sneak;
import data.Challenge;
import data.Updates;
import data.UserVar;
import data.ClanVar;
import data.DinoVar;
import data.GameVar;
import data.Tutorial;
import data.Event.Event;
import data.GameRewards;
import data.Goal;

typedef DinoExport = {
	var maxLife:Int;
	var water : Int;
	var fire:Int;
	var air: Int;
	var thunder:Int;
	var wood:Int;
	var level:Int;
	var xp:Int;
	var gfx:String;
	var skills:List<SkillExport>;
	var fx:List<Int>;
}

typedef SkillExport = {
	var active:Bool;
	var sid:Int;
	var unlocked:Bool;
}

class Data {

	public static inline var FIRE = 0;
	public static inline var WOOD = 1;
	public static inline var WATER = 2;
	public static inline var THUNDER = 3;
	public static inline var AIR = 4;
	public static inline var VOID = 5;

	public static var ELEMENTS = {
		var a = new Array();
		var texts = Text.get.elements_names.split(":");
		var names = ["fire","wood","water","thunder","air","void"];
		for( i in 0...6 )
			a.push({
				id : i,
				name : names[i],
				text : texts[i],
			});
		a;
	}

	public static function xml( file ) {
		var data = sys.io.File.getContent(Config.XML_PATH + file);
		//Added to make possible complex compare with other languages
		data = StringTools.replace(data, "::ignore::", "");
		return try Xml.parse(data).firstElement() catch( e : Dynamic ) neko.Lib.rethrow("In "+file+" : "+Std.string(e));
	}

	public static function isActive(flag) {
		var a = ACTIVE.get(flag);
		if( a == null ) throw "Unknown active '"+flag+"'";
		return a;
	}

	static function initActive() {
		var x = new haxe.xml.Fast(xml("active.xml"));
		var h = new Hash();
		for( x in x.elements )
			h.set(x.name, x.att.active == "1");
		#if twinoid
		h.set("twinoid", true);
		#end
		return h;
	}

	public static var ZONES = Lambda.array(Lambda.map(Text.get.zones.split(":"),function(z) { return { id : z }}));
	public static var ACTIVE : Hash<Bool>;
	public static var COLLECTION : Container<Collection,CollectionXML>;
	public static var DINOZ_FAMILY = new Array<data.Family>();
	public static var DINOZ : Container<Family,FamilyXML>;
	public static var EFFECTS : Container<Effect,EffectXML>;
	public static var ACTIONS : Container<Action,ActionXML>;
	public static var BACKGROUNDS : Container<Background,BackgroundXML>;
	public static var MAP : Container<Map,MapXML>;
	public static var STATUS : Container<Status,StatusXML>;
	public static var SKILLS : Container<Skill,SkillXML>;
	public static var INGREDIENTS : Container<Ingredient,IngredientXML>;
	public static var OBJECTS : Container<Object,ObjectXML>;
	public static var MONSTER_PLACES = new IntHash<List<{ p : Int, m : data.Monster }>>();
	public static var MONSTERS : Container<Monster,MonsterXML>;
	public static var MISSIONS : Container<Mission,Dynamic>;
	public static var DIALOGS : Hash<Dialog>;
	public static var SHOPS : Container<Shop,ShopXML>;
	public static var GATHER : Container<Gather,GatherXML>;
	public static var SCENARIOS : Container<Scenario,ScenarioXML>;
	public static var TEXT : ScenarioTexts;
	public static var BUILDINGS : Container<Building,BuildingXML>;
	public static var DUNGEONS : Container<Dungeon,DungeonXML>;
	public static var SPELLS : Container<Spell,SpellXML>;
	public static var CLAN_ACTIONS : Container<ClanAction,ClanActionXML>;
	public static var SNEAKS : Container<Sneak, SneakXML>;
	public static var CHALLENGES : Container<Challenge, ChallengeXML>;
	public static var UPDATES : Container<Updates, UpdatesXML>;
	public static var USERVARS : Container<UserVar, UserVarXML>;
	public static var CLANVARS : Container<ClanVar, ClanVarXML>;
	public static var GAMEVARS : Container<GameVar, GameVarXML>;
	public static var DINOVARS : Container<DinoVar, DinoVarXML>;
	public static var TUTORIAL : Container<Tutorial, TutorialXML>;
	public static var REWARDS : Container<GameRewards, GameRewardsXML>;
	public static var GOALS : Container<Goal, GoalXML>;
	
	public static function initialize() {
		var file = Config.TPL_TMP + "datas.bin";
		if( !Config.DEBUG ) {
			var d = neko.Lib.localUnserialize(neko.Lib.bytesReference(sys.io.File.getContent(file)));
			untyped Data = d;
			return;
		}
		ACTIVE = initActive();
		COLLECTION = CollectionXML.parse();
		SKILLS = SkillXML.parse();
		DINOZ = FamilyXML.parse();
		for( d in DINOZ )
			DINOZ_FAMILY[d.gfx] = d;
		
		EFFECTS = EffectXML.parse();
		ACTIONS = ActionXML.parse();
		BACKGROUNDS = BackgroundXML.parse();
		SCENARIOS = ScenarioXML.parse();
		TEXT = new ScenarioTexts(ScenarioXML.TEXTS.get);
		MAP = MapXML.parse();
		INGREDIENTS = IngredientXML.parse();
		OBJECTS = ObjectXML.parse();
		for( m in MAP )
			MONSTER_PLACES.set(m.mid,new List());
		MONSTERS = MonsterXML.parse();
		STATUS = StatusXML.parse();
		
		CLAN_ACTIONS = ClanActionXML.parse();
		GAMEVARS = GameVarXML.parse();
		USERVARS = UserVarXML.parse();
		CLANVARS = ClanVarXML.parse();
		DINOVARS = DinoVarXML.parse();
		MISSIONS = MissionXML.parse();
		DUNGEONS = DungeonXML.parse();
		SNEAKS = SneakXML.parse();
		DIALOGS = DialogXML.parse();
		SHOPS = ShopXML.parse();
		GATHER = GatherXML.parse();
		REWARDS = GameRewardsXML.parse();
		BUILDINGS = BuildingXML.parse();
		SPELLS = sys.FileSystem.exists(Config.XML_PATH+"spells.xml") ? SpellXML.parse() : new Container<Spell,SpellXML>();
		CHALLENGES = ChallengeXML.parse();
		UPDATES = UpdatesXML.parse();
		TUTORIAL = TutorialXML.parse();
		GOALS = GoalXML.parse();
		
		MapXML.check();
		SkillXML.check();
		MissionXML.check();
		BuildingXML.check();
		
		new fight.SkillsImpl().check();
		new fight.ObjectsImpl().check();
		var f = sys.io.File.write(file,true);
		f.writeString(neko.Lib.stringReference(neko.Lib.serialize(Data)));
		f.close();
	}

	static var _ = initialize();
}
