enum Pos {
	Att(p:AttPos);
	Def(p:DefPos);
	Bat;
}

enum AttPos {
	AttL;
	AttR;
	Bat1;
	Bat2;
	Bat3;
	ASub;
}

enum DefPos {
	Thro;
	DefL;
	DefM;
	DefR;
	DefF;
	DSub;
}

class Parameters {
	public var players : Array<Int>;
	public var thro2 : Null<Int>; // second thrower in case first one is out
	public var thro : Null<Int>;
	public var defL : Null<Int>; // defender left
	public var defM : Null<Int>; // defender middle
	public var defR : Null<Int>; // defender right
	public var defF : Null<Int>; // defender far
	public var dsub : Null<Int>; // sub1
	public var attL : Null<Int>; // attacker left
	public var attR : Null<Int>; // attacker right
	public var bat1 : Null<Int>; // batter one
	public var bat2 : Null<Int>; // batter two
	public var bat3 : Null<Int>; // batter three
	public var asub : Null<Int>; // sub1

	//
	// READ ONLY METHODS
	//

	public function getDefPos( pid:Int ) : DefPos {
		if (thro == pid) return Thro;
		if (defL == pid) return DefL;
		if (defM == pid) return DefM;
		if (defR == pid) return DefR;
		if (defF == pid) return DefF;
		if (dsub == pid) return DSub;
		return null;
	}

	public function getAttPos( pid:Int ) : AttPos {
		if (attL == pid) return AttL;
		if (attR == pid) return AttR;
		if (bat1 == pid) return Bat1;
		if (bat2 == pid) return Bat2;
		if (bat3 == pid) return Bat3;
		if (asub == pid) return ASub;
		return null;
	}

	public function getAtt( p:AttPos ) : Int {
		return switch (p){
			case AttL: attL;
			case AttR: attR;
			case Bat1: bat1;
			case Bat2: bat2;
			case Bat3: bat3;
			case ASub: asub;
			default: null;
		}
	}

	public function getDef( p:DefPos ) : Int {
		return switch (p){
			case Thro: thro;
			case DefL: defL;
			case DefM: defM;
			case DefR: defR;
			case DefF: defF;
			case DSub: dsub;
			default: null;
		}
	}

	//
	// That is for the game engine
	//

	function setAtt( p:AttPos, v:Int ){
		if (p == null)
			return;
		switch (p){
			case AttL: attL = v;
			case AttR: attR = v;
			case Bat1: bat1 = v;
			case Bat2: bat2 = v;
			case Bat3: bat3 = v;
			case ASub: asub = v;
		}
	}

	function setDef( p:DefPos, v:Int ){
		if (p == null)
			return;
		switch (p){
			case Thro: thro = v;
			case DefL: defL = v;
			case DefM: defM = v;
			case DefR: defR = v;
			case DefF: defF = v;
			case DSub: dsub = v;
		}
	}

	//
	// MAIN MODIFICATION METHODS ARE RESERVED TO NEKO
	//
	#if neko

	public function new( ps:List<db.GamePlayer>, ?short:Array<{id:Int, attPos:AttPos, defPos:DefPos, secondThrower:Bool}> ){
		players = [];
		for (p in ps){
			players.push(p.playerId);
			setAtt(p.att, p.playerId);
			setDef(p.def, p.playerId);
			if (p.secondThrower)
				thro2 = p.playerId;
		}
		if (short != null){
			for (p in short){
				players.push(p.id);
				setAtt(p.attPos, p.id);
				setDef(p.defPos, p.id);
				if (p.secondThrower)
					thro2 = p.id;
			}
		}
	}

	function cleanup(){
		if (!Lambda.has(players, thro2)) thro2 = null;
		if (!Lambda.has(players, thro)) thro = null;
		if (!Lambda.has(players, defL)) defL = null;
		if (!Lambda.has(players, defM)) defM = null;
		if (!Lambda.has(players, defR)) defR = null;
		if (!Lambda.has(players, defF)) defF = null;
		if (!Lambda.has(players, dsub)) dsub = null;
		if (!Lambda.has(players, attL)) attL = null;
		if (!Lambda.has(players, attR)) attR = null;
		if (!Lambda.has(players, bat1)) bat1 = null;
		if (!Lambda.has(players, bat2)) bat2 = null;
		if (!Lambda.has(players, bat3)) bat3 = null;
		if (!Lambda.has(players, asub)) asub = null;
	}

	function findFirstEmptyDefPos() : DefPos {
		if (thro == null) return Thro;
		if (defL == null) return DefL;
		if (defM == null) return DefM;
		if (defR == null) return DefR;
		if (defF == null) return DefF;
		if (dsub == null) return DSub;
		return null;
	}

	function findFirstEmptyAttPos() : AttPos {
		if (bat1 == null) return Bat1;
		if (bat2 == null) return Bat2;
		if (bat3 == null) return Bat3;
		if (attL == null) return AttL;
		if (attR == null) return AttR;
		if (asub == null) return ASub;
		return null;
	}

	public function addPlayer( p:db.Player ){
		players.push(p.id);
		setPlayerDefPos(p, findFirstEmptyDefPos());
		setPlayerAttPos(p, findFirstEmptyAttPos());
	}

	public function delPlayer( pId:Int ){
		players.remove(pId);
		cleanup();
	}

	public function setPlayerDefPos( p:db.Player, pos:DefPos ) : Void {
		var old = getDefPos(p.id);
		if (old != null)
			setDef(old, null);
		setDef(pos, p.id);
	}

	public function setPlayerAttPos( p:db.Player, pos:AttPos ) : Void {
		var old = getAttPos(p.id);
		if (old != null)
			setAtt(old, null);
		setAtt(pos, p.id);
	}

	public function isEmpty() : Bool {
		return players.length == 0;
	}

	public function isFull() : Bool {
		return players.length >= GConfig.MAX_GAME_TEAM_SIZE;
	}

	public function contains( p:db.Player ) : Bool {
		return Lambda.has(players, p.id);
	}
	#end

	#if !js

	public function isReady() : Bool {
		return players.length >= GConfig.MIN_GAME_TEAM_SIZE
			&& thro != null && defF != null && defM != null && defR != null && defL != null
			&& attL != null && attR != null && bat1 != null && bat2 != null && bat3 != null;
	}

	#end
}

#if neko

class GameParameters {
	var players  : List<db.GamePlayer>;
	var params : Parameters;
	var game : db.Game;
	var team : db.Team;

	public function new( game:db.Game, team:db.Team, lock:Bool ){
		this.game = game;
		this.team = team;
		if (team == null)
			throw "'Team' parameter is null";
		players = db.GamePlayer.getTeam(game, team, lock);
		params = new Parameters(players);
	}

	public function reset(){
		for (p in db.GamePlayer.manager.search({ gameId:game.id, teamId:team.id }, true))
			p.reset();
		players = new List();
	}

	public function getPlayers() : List<db.Player> {
		return Lambda.map(players, function(p) return p.player);
	}

	public function setConfig( conf:db.TeamConfig ){
		reset();
		conf.sanitize();
		params = conf.getParams();
		var players = new List();
		for (pid in params.players){
			var player = db.Player.manager.get(pid,true);
			if (!player.canPlay())
				params.delPlayer(player.id);
			else
				players.push(player);
		}
		update();
	}

	public function getParameters() : Parameters {
		return params;
	}

	public function update(){
		var lst = Lambda.list(params.players);
		var old = db.GamePlayer.manager.search({ gameId:game.id, teamId:team.id }, true);
		for (p in old){
			if (Lambda.has(lst, p.playerId)){
				p.att = params.getAttPos(p.playerId);
				p.def = params.getDefPos(p.playerId);
				p.secondThrower = params.thro2 == p.playerId;
				p.update();
				lst.remove(p.playerId);
			}
			else {
				p.reset();
			}
		}
		for (p in lst){
			var gp = new db.GamePlayer();
			gp.game = game;
			gp.team = team;
			gp.playerId = p;
			gp.att = params.getAttPos(p);
			gp.def = params.getDefPos(p);
			gp.secondThrower = params.thro2 == p;
			gp.insert();
		}
	}
}

#end