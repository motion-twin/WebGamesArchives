package game;
import game.Geom;
import GameParameters;

class Field {
	var resolver : Resolver;
	public var batt : PlayerData;
	public var defF : PlayerData;
	public var defL : PlayerData;
	public var defM : PlayerData;
	public var defR : PlayerData;
	public var thro : PlayerData;
	public var attL : PlayerData;
	public var attR : PlayerData;
	public var players : Array<PlayerData>;

	public function new(resolver:Resolver){
		this.resolver = resolver;
	}

	public function update(battler:PlayerData, thrower:PlayerData){
		for (p in resolver.players){
			p.pos = null;
			p.setPos(null);
		}
		batt = battler;
		attL = resolver.attTeam.getAtt(AttL);
		attR = resolver.attTeam.getAtt(AttR);
		//trace("Throw="+thrower.id);
		thro = thrower;
		defF = resolver.defTeam.getDef(DefF);
		defL = resolver.defTeam.getDef(DefL);
		defM = resolver.defTeam.getDef(DefM);
		defR = resolver.defTeam.getDef(DefR);
		players = [];
		if (batt != null){ batt.pos = Bat;       if (Lambda.has(players,batt)) throw "batt already in players array."; players.push(batt); }
		if (attL != null){ attL.pos = Att(AttL); if (Lambda.has(players,attL)) throw "attl already in players array."; players.push(attL); }
		if (attR != null){ attR.pos = Att(AttR); if (Lambda.has(players,attR)) throw "attr already in players array."; players.push(attR); }
		if (thro != null){ thro.pos = Def(Thro); if (Lambda.has(players,thro)) throw "thro already in players array."; players.push(thro); }
		if (defF != null){ defF.pos = Def(DefF); if (Lambda.has(players,defF)) throw "defF already in players array."; players.push(defF); }
		if (defL != null){ defL.pos = Def(DefL); if (Lambda.has(players,defL)) throw "defL already in players array."; players.push(defL); }
		if (defM != null){ defM.pos = Def(DefM); if (Lambda.has(players,defM)) throw "defM already in players array."; players.push(defM); }
		if (defR != null){ defR.pos = Def(DefR); if (Lambda.has(players,defR)) throw "defR already in players array."; players.push(defR); }
		for (i in 0...players.length)
			players[i].idx = i + 2;
	}

	public var squareDistances : Array<Array<Float>>;

	public function updateDistances(){
		if (squareDistances == null){
			squareDistances = [];
			for (i in 0...10)
				squareDistances[i] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
		}
		squareDistances[1][0] = squareDistances[0][1] = resolver.ball.position.lengthSquared();
		for (i in 0...players.length){
			var p = players[i];
			var d = p.position.lengthSquared();
			squareDistances[p.idx][0] = d;
			squareDistances[0][p.idx] = d;
			var d = p.position.distanceSquared(resolver.state == GameState.FLY ? resolver.ball.middleCourse : resolver.ball.position);
			squareDistances[p.idx][1] = d;
			squareDistances[1][p.idx] = d;
			squareDistances[p.idx][p.idx] = 0;
			for (j in (i+1)...players.length){
				var p2 = players[j];
				var d = p.position.distanceSquared(p2.position);
				squareDistances[p.idx][p2.idx] = d;
				squareDistances[p2.idx][p.idx] = d;
			}
		}
	}

	public function sortDistances(targetIdx:Int,  candidates:Array<PlayerData>){
		var dist = squareDistances;
		candidates.sort(
			function(a,b){
				var cmp = Reflect.compare(dist[targetIdx][a.idx], dist[targetIdx][b.idx]);
				if (cmp != 0)
					return cmp;
				return Reflect.compare(a.idx, b.idx);
			}
		);
	}

	public function distance(i1:Int, i2:Int) : Float {
		return Math.sqrt(squareDistances[i1][i2]);
	}

	static var OUT = new Point(-100, 0);
	static var BATT_POS = new Point( 1, -3);
	static var ATTL_POS = new Point(70, 0).rotate(-Math.PI/8);
	static var ATTR_POS = new Point(70, 0).rotate( Math.PI/8);
	public static var THRO_POS = new Point(20, 0);
	static var DEFF_POS = new Point(80, 0);
	static var DEFL_POS = new Point(60, 0).rotate(-Math.PI/6);
	static var DEFM_POS = new Point(60, 0);
	static var DEFR_POS = new Point(60, 0).rotate( Math.PI/6);

	public static var RECEPTION_ZONE = [
		new Point(-2.5, -2.5),
		new Point(-2.5,  2.5)
	];

	public static function getReceptionRect() : { x:Float, y:Float, w:Float, h:Float } {
		var w = 4.0;
		var r = {
			x:RECEPTION_ZONE[0].x-w,
			y:RECEPTION_ZONE[0].y,
			w:w,
			h:RECEPTION_ZONE[1].y-RECEPTION_ZONE[0].y
		};
		return r;
	}


	public static function posToPoint(pos:Pos) : Point {
		if (pos == null)
			return null;
		switch (pos){
			case Att(p):
				if (p == null)
					return null;
				return switch (p){
					case AttL: ATTL_POS;
					case AttR: ATTR_POS;
					default:   null;
				}
			case Def(p):
				if (p == null)
					return null;
				return switch (p){
					case Thro: THRO_POS;
					case DefF: DEFF_POS;
					case DefL: DEFL_POS;
					case DefM: DEFM_POS;
					case DefR: DEFR_POS;
					default:   null;
				}
			case Bat:
				return BATT_POS;
			default:
				return null;
		}
	}
}