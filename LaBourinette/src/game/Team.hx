package game;
import GameParameters;
import game.Event;
import game.InitialData;
import Vice;

enum Mode {
	ATTACK;
	DEFENSE;
}

class TeamStats implements game.GameListener {
	var resolver : game.Resolver;
	var team : Team;
	public var games : Int;
	public var strikes : Int;
	public var picopafs : Int;
	public var picosafes : Int;
	public var picostars : Int;
	public var injures : Int;
	public var victories : Int;

	public function new( t:game.Team, r:game.Resolver ){
		this.team = t;
		this.resolver = r;
		strikes = picopafs = picosafes = picostars = injures = victories = 0;
		games = 1;
		r.addEventListener(this);
	}

	public function countKilledPicorons() : Int {
		return strikes + picopafs + picostars + picosafes;
	}

	inline function isAttacker() : Bool { return team == resolver.attTeam; }
	inline function isDefender() : Bool { return team == resolver.defTeam; }

	public function onEvent( e:Event ){
		switch (e){
			case PicoStar: if (isAttacker()) picostars++;
			case PicoPaf(pid): if (isAttacker()) picopafs++;
			case Strike: if (isDefender()) strikes++;
			case PicoSafe(pid): if (isDefender()) picosafes++;
			case Bobo(p, o): if (p.team != team) injures++;
			case Injure(p, o): if (p.team != team) injures++;
			case Winner(t): if (t == team) victories++;
			default:
		}
	}
}

class Team {
	// must not be modified, there are start data and parameters
	public var id : Int;
	public var name : String;
	var param : Parameters; // user's param
	public var iplayers : List<BasePlayer>;
	public var ihooligans : Array<IHooligan>;
	// initialized by the initialize() method
	public var players : List<PlayerData>;
	public var leader : PlayerData;
	public var score : Int;
	var substituter : game.Substituter;
	var currentTeam : Array<{ pos:Pos, p:PlayerData }>;
	public var mode : Mode;
	public var stolenItems : List<IItem>;
	public var hooligansVictories : List<Int>;
	public var corruptBonus : Int;
	public var x : Float;
	public var y : Float;
	public var stats : TeamStats;

	public function new(id:Int, name:String, players:List<BasePlayer>, params:Parameters, corruptBonus:Int, hooligans:List<IHooligan>){
		if (params == null)
			throw "Parameters is null for team "+name;
		this.id = id;
		this.name = name;
		this.iplayers = players;
		this.ihooligans = hooligans == null ? [] : Lambda.array(hooligans);
		this.param = params;
		this.corruptBonus = corruptBonus;
		this.score = 0;
	}

	public function initialize( r:Resolver ){
		players = new List();
		leader = null;
		stolenItems = new List();
		hooligansVictories = new List();
		stats = new TeamStats(this, r);
		if (id == 0){
			x = 5;
			y = 29;
		}
		else {
			x = 5;
			y = -29;
		}
		for (ip in iplayers){
			var p = new PlayerData(ip);
			p.team = this;
			p.x = x;
			p.y = y;
			p.resolver = r;
			p.defPos = param.getDefPos(p.id);
			p.attPos = param.getAttPos(p.id);
			p.secondThrower = param.thro2 == p.id;
			players.push(p);
			r.playersHash.set(p.id, p);
			r.players.push(p);
			r.event(DefPlayer(this, ip));
			if (p.hasCompetence(Competence.get.RefereeFriend)){
				corruptBonus += 5;
			}
		}
		for (p in players){
			p.computeSkills();
			p.preselectInGameVices();
		}
		substituter = new Substituter(this, param);
		for (p in players)
			p.runVices(ViceWhen._BeforeGame);
	}

	public function onFault(){
		for (p in players)
			if (p.isOnField())
				p.runVices(ViceWhen._TeamFault);
	}

	public function gameOver( r:Resolver ){
		for (p in players){
			p.runVices(ViceWhen._AfterGame);
			p.onGameOver();
		}
	}

	public function optimize( event:game.Event->Void, batNumber:Int, canSubstituteBattler:Bool ) : Bool {
		var p = switch (batNumber){
			case 0: Bat1;
			case 1: Bat2;
			case 2: Bat3;
			default: null;
		}
		var canDoIt = substituter.optimize(p, canSubstituteBattler);
		if (!canDoIt)
			return false;
		var replacements = substituter.getReplacements();
		for (replacement in replacements){
			if (replacement.oldP != null)
				event(Replace(replacement.oldP, replacement.newP, replacement.pos));
			else
				event(Replace(null, replacement.newP, replacement.pos));
		}
		return true;
	}

	public function setMode( m:Mode ){
		this.mode = m;
		for (p in players)
			p.computeSkills();
	}

	public function isParamReady() : Bool {
		return param.isReady();
	}

	public function getNextBattler(batNumber:Int) : PlayerData {
		var pos = switch (batNumber){
			case 0: Bat1;
			case 1: Bat2;
			case 2: Bat3;
			default: null;
		}
		return getAtt(pos);
	}

	public function updateLife(modifier:Int) : Void {
		for (p in players)
			p.updateLife(modifier);
	}

	public function publicSpirit(roll:Int) : Void {
		var chances = 5;
		for (p in players)
			if (p.hasCompetence(Competence.get.StadiumStar)){
				chances = 15;
				break;
			}
		if (roll < chances)
			updateSpirit(1, 50);
	}

	public function updateSpirit(modifier:Float, proba:Int) : Void {
		if (modifier == 0.0)
			return;
		for (p in players)
			p.updateSpirit(modifier, proba);
	}

	public function getDef(pos:DefPos) : PlayerData {
		for (p in players)
			if (p.defPos == pos)
				return p;
		return null;
	}

	public function getAtt(pos:AttPos) : PlayerData {
		for (p in players)
			if (p.attPos == pos)
				return p;
		return null;
	}

	function getPlayer(id:Null<Int>){
		if (id == null)
			return null;
		for (p in players)
			if (p.id == id)
				return p;
		return null;
	}

	public function toString() : String {
		return "team#"+id+" ("+name+")";
	}
}