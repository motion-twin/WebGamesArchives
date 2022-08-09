package fight;
import Fight._AddFighterEffect;
import Fight._EndBehaviour;

using Std;
class Result {
	
	static var XP_NEWB_BONUS = [15,10,6.6,4.3,2.5];
	
	public var manager : Manager;
	public var fighters : List<Fighter>;
	public var side : Bool;
	public var player : Bool;
	
	public var goldReason : String;
	public var goldFactor : Float;
	public var goldBonus : Float;
	public var xpFactor : Float;
	public var xpBonus : Float;
	public var dinoz : List<{ winXp : Int, lostLife : Int, d : db.Dino, f : Fighter }>;
	public var won : Bool;
	public var winXp : Int;
	public var lostLife : Int;
	public var gold : Int;
	public var levelup : Bool;
	public var turns : Int;
	public var requireKillAll : Bool;
	public var canEscape : Bool;
	
	public var addfx : _AddFighterEffect;
	public var end : _EndBehaviour;
	public var other : Result;
	
	public var disableTrophies : Bool;
	
	public var flags : {
		var underBeer : Bool;
		var mtimeProtected : Void->Bool;
	};
	
	public var rules : {
		var canHealDinoz : Bool;
		var cancelMonochromatic : Bool;
		var cancelTrouNoir : Bool;
		var cancelSylfide : Bool;
		var cancelPoudreDim : Bool;
		var onInvoc : Fighter -> Fighter -> Void;
		var onBalance : Fighter -> Bool;
		var onHypnose : Fighter -> Fighter -> Bool;
		var onHeal : List<Fighter -> Int -> Void>;
	};
	
	public function new(m,s) {
		goldReason = "fight";
		
		xpFactor = 1.0;
		goldFactor = 1.0;
		xpBonus = goldBonus = 0.0;
		won = false;
		side = s;
		player = s;
		gold = 0;
		lostLife = 0;
		winXp = 0;
		turns = 0;
		manager = m;
		canEscape = true;
		end = s ? _EBEscape : _EBStand;
		dinoz = new List();
		fighters = new List();
		
		flags = {
			underBeer : false,
			mtimeProtected : function() { return false; },
		};
		
		rules = {
			canHealDinoz : true,
			cancelMonochromatic : false,
			cancelTrouNoir : false,
			cancelSylfide : false,
			cancelPoudreDim : false,
			onInvoc   : function(i, f) {},
			onBalance : function(f) return true,
			onHypnose : function(f, t) return true,
			onHeal	: new List(),
		};
	}
	
	public function addMonster( f : Fighter ) {
		fighters.add(f);
	}
	
	public function addDinoz( f : Fighter ) {
		dinoz.add({ winXp : 0, lostLife : 0, f : f, d : f.dino });
		fighters.add(f);
	}
	
	public dynamic function calculateVictory() {
		var won = manager.side(side).length > 0;
		if( won && requireKillAll ) {
			for( f in other.fighters ) {
				if( f.life > 0 ) {
					return false;
				}
			}
		}
		return won;
	}
	
	public function calculateFighterXp( f : Fighter ) : Float {
		if( f.life > 0 )
			return Math.min(Math.sqrt(f.startLife - f.life), 10);
		if( f.monster != null )
			return f.monster.xp;
		return 10;
	}
	
	public function calculateFighterGold( f : Fighter ) : Float {
		return f.monster != null ? f.monster.gold : 1.0;
	}
	
	public dynamic function calculate() {
		var fgold = goldBonus;
		var escaped:List<Fighter> = manager.getEscaped();
		// update life
		var tlevel = 0;
		for( d in dinoz ) {
			if( d.f.dino == null ) {
				// the dinoz might be a fantom of
				// the original dinoz. It means we will
				// not update it in database
				dinoz.remove(d);
				continue;
			}
			d.lostLife = d.f.startLife - d.f.life;
			lostLife += d.lostLife;
			d.d.life = d.f.life;
			tlevel += d.d.level;
		}
		
		// give xp
		for( r in dinoz ) {
			//if escaped, no XP !
			if( Lambda.has( escaped, r.f) )
				continue;
			var d = r.d;
			var xp = xpBonus;
			var cur = d.level / tlevel;
			
			/** HACK to restrict the use of low level dinoz in order to make easy money **/
			var gfact = 1.0;
			if( d.xp >= d.nextLevelXP() && d.level <= 5 )
				gfact = 0.1;
			/** HACK to make dinoz with malediction not generating gold **/
			if( d.hasEffect( Data.EFFECTS.list.maudit ) && d.level < Config.HACK_PROTECTION_LEVEL )
				gfact = 0.0;
			
			for( f in other.fighters ) {
				var factor = if( f.level >= d.level ) 1 else 4 / (4 + (d.level - f.level));
				fgold += calculateFighterGold(f) * factor * cur * gfact;
				xp += calculateFighterXp(f) * factor * cur;
				// newbie bonus
				if( d.level <= 5 ) xp += XP_NEWB_BONUS[d.level - 1] * cur;
				// bonus for fighters of same level of the monster
				if( f.monster != null && Math.abs(f.level - d.level) <= 5 ) xp += f.monster.xpBonus;
			}
			
			if( !disableTrophies && d.life <= 0 ) {
				if( d.owner != null )
					d.owner.incrVar(Data.USERVARS.list.deaths, 1);
				continue;
			}
			
			//previous xp coef computation
			var lvlDiff = Config.ABSOLUTE_MAX_LEVEL - d.level;
			var xpf = 1.2 + 0.8 * ((lvlDiff) / Config.ABSOLUTE_MAX_LEVEL);
			if ( xpf < 1.0 ) xpf = 1.0;
			
			//new one, applied if better
			if( (Config.ABSOLUTE_MAX_LEVEL / Config.INITIAL_MAX_LEVEL) > xpf )
				xpf = (Config.ABSOLUTE_MAX_LEVEL / Config.INITIAL_MAX_LEVEL);
			
			var xp = Skills.calculateXPBonus(d, Math.round(xp * xpFactor * xpf));
			var max = d.nextLevelXP();
			if( d.xp + xp > max ) {
				xp = max - d.xp;
				if( xp < 0 ) xp = 0;
				levelup = true;
			}
			d.xp += xp;
			r.winXp = xp;
			winXp += xp;
		}
		
		// calculate gold
		var fprob = Std.random(100);
		var gmult = if( fprob < 1 ) 10 else if( fprob < 11 ) 3 else 1; // avg : 1.3
		var g = (Std.random(10) + 20) * 10;
		if( won ) {
			// fgold should be <= 1, so we have an average or 320 G per fight
			gold += Std.int(g * gmult * fgold * goldFactor);
		}
		
		// update dinoz missions
		var monsters = new List();
		var oppDinoz = new List();
		for( f in other.fighters ) {
			if( f.monster != null && f.life == 0 )
				monsters.add(f.monster);
			if(  f.dino != null && f.life == 0 )
				oppDinoz.add( f.dino );
		}
		
		if( !monsters.isEmpty() ) {
			var pos = manager.getPosition();
			var d0 = dinoz.first();
			if( won && d0 != null && d0.d.owner != null && d0.d.owner.id != null )
				Events.afterFight(d0.d.owner,this,monsters);
			for( r in dinoz )
				handler.Missions.afterFight(r.d,pos,monsters);
		}
		
		// FOR TROPHIES
		if( !disableTrophies ) {
			var users = new List();
			for ( d in dinoz )
				if(  !Lambda.exists(users, function(u) return u == d.d.owner) )
					users.add(d.d.owner);
			for ( u in users ) {
				if(  u == null ) continue;
				u.incrVar(Data.USERVARS.list.killm, monsters.length);
				u.incrVar(Data.USERVARS.list.killd, oppDinoz.length);
			}
		}
	}
	
	public static function monsterLevelProba( level : Int, p : Int, monsterLvl : Int ) {
		var delta : Float = level - monsterLvl;
		if( delta < 0 ) {
			if( delta < -3 )
				return 0;
			delta = -delta * 3;
		}
		delta = Std.int(Math.pow(delta, 1.5));
		return Math.round(p * 1000 / (3 + delta));
	}
	
	public function generateMonsters( pow, ?ml, ?dino ) {
		// calculate level total
		var tlevel = 0;
		var maxlevel = 0;
		for( f in fighters ) {
			tlevel += f.level;
			if( f.level > maxlevel )
				maxlevel = f.level;
		}
		
		// adjust group difficulty
		//	-20% for 2 , -30% for 3 ...
		var count = fighters.length;
		var dif = (count + 2) / (count * 2 + 1);
		tlevel = Math.round(tlevel * dif);
		tlevel += (pow - 1) * 3;
		tlevel += Std.int((pow - 1) * 0.3 * tlevel); // +30% per power level
		var mdelta = Std.int(tlevel / 4);
		if( mdelta < 2 ) mdelta = 2;
		
		// choose monsters
		if(  ml == null ) {
			// we don't show event monsters on forced monsters list
			var evCfg = switch( db.GConfig.getEvent(false) ) {
				case data.Event.MonsterSpecial(cfg): cfg;
				default : null;
			}
			var specialProb = Std.random(100);
			var pos = manager.getPosition();
			ml = Data.MONSTER_PLACES.get(pos.mid).map(function(inf) {
				if( inf.m.special ) {
					var display =  inf.p >= specialProb;
					return { m : inf.m, p : monsterLevelProba(maxlevel, display ? 100 : 0, maxlevel ) };
				} else {
					return { m : inf.m, p : monsterLevelProba(maxlevel, inf.p, inf.m.level) };
				}
			});
			//filtre les monstres actifs
			// we count the special monsters only if enabled by a special event
			ml = Lambda.filter( ml, function(o) return (Script.eval(dino, o.m.cond) && (!o.m.special || (evCfg != null && Lambda.has(evCfg.monsters, o.m))) ));
			if( ml.length != 0 ) {
				switch( db.GConfig.getEvent(false) ) {
					case data.Event.MonsterHunter(cfg):
						for ( i in cfg.items )
							for ( p in i.places )
								if(  p.mid == pos.mid )
									for( m in i.monsters )
										if( maxlevel > m.level ) {
											ml.add( { m : m, p : monsterLevelProba( (tlevel/count).int(), 100, m.level ) } );//TODO 50% is currently a constant value
										}
					default:
				}
			}
			ml = fight.Scenario.buildMonsters(this,ml);
			for( r in dinoz )
				handler.Missions.updateMonstersProbas(r.d, pos, ml);
		}
		
		var mlevel = 0;
		var monsters = new List();
		// null proba = forced monster
		var tot = 0;
		for( m in ml )
			if( m.p == null ) {
				mlevel += m.m.level;
				monsters.add(m.m);
				ml.remove(m);
			} else
				tot += m.p;
				
		// force some monsters to appear
		if( monsters.isEmpty() && tot == 0 )
			for( m in ml )
				m.p = 100;
		
		// select at random
		var ml = Lambda.array(ml);
		var rnd = new neko.Random();
		while ( mlevel < tlevel ) {
			var mpos = data.Tools.random(ml, function(m) { return m.p; }, rnd);
			if( mpos == null )
				break;
			var m = ml[mpos].m;
			var count = if( m.groups == null ) 1 else 1 + data.Tools.random(m.groups,function(f) { return f; },rnd);
			for( i in 0...count ) {
				mlevel += m.level;
				monsters.add(m);
				if( count > 1 && mlevel >= tlevel && m.groups[i] != 0 )
					break;
			}
			if(  m.special ) ml.remove(ml[mpos]);
			mlevel += mdelta;
		}
		return monsters;
	}
}
