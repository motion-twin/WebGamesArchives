package fight;
import data.Object;
import Fight;
import fight.Fighter;
import data.Fight.FightStat;

using Std;
using Lambda;
class Manager {

	public static var PROBA_MULTIPLIER = 1;
	public var enableEnergy : Bool;
	
	inline public static var TIMEBASE = 10;//base time, used to ensure compability
	inline public static var TIMECOEF = 10;

	public static var INFINITE = 1000000 * TIMECOEF;
	static var CYCLE = 6 * TIMECOEF;
	static var GORE = 0.9;
	public static var elements = [_LFire,_LWood,_LWater,_LLightning,_LAir,_LNormal];

	public var enableStats : Bool;
	public var stats : IntHash<FightStat>;
	
	public var canUseEquip : Bool;
	public var canUsePermanentEquipOnly : Bool;
	public var canUseCapture : Bool;
	public var deleteObjects : Bool;
	public var enableBalance : Bool;

	var fidGenerator : Int;
	var deads_tmp : List<Fighter>;
	var deads : List<Fighter>;
	public var escaped : List<Fighter>;//user who escaped the fight
	var attackers : Array<Fighter>;
	var defenders : Array<Fighter>;
	var attackResult : Result;
	var defendResult : Result;
	public var all : Array<Fighter>;
	var historyContent : List<_History>;
	var curtime : Int;
	var nextStatus : Int;
	var castle : fight.Castle;
	var position : data.Map;
	var timeout : { t : Int, callb : Void -> Bool };
	
	var skills : SkillsImpl;
	var objects : ObjectsImpl;
	
	var envSkill : { function init() : Void; function execute() : Void; function cancel() : Void; function getCaster() : Fighter; var playing(default, null):Bool; var timeout:Int; };
	public var res : Result;
	public var onNextTurn 	: List<Fighter -> Void>;
	public var onStartFight : List<Void -> Void>;
	public var onEndFight 	: List < Void -> Void >;
	public var onAnnounce : List<Fighter->data.Skill->Void> ;
	var onNextCycle 	: List<{nextCycle:Int, callb:Void -> Void}> ;
	
	var rnd:neko.Random;
	var fRandom : Int -> Int;
	
	public static function createStatObject() {
		return {side : false, dino :-1, user : -1,
				dead : false, attacks : 0, groupAttacks : 0, multis : 0, counters : 0, assaults : 0, esquives : 0,
				startLife : -1, finalLife : -1, lostLife : 0, regeneratedLife : 0, poison : 0, stoned : 0, sleep : 0,
				given	: [ { count:0, lost:0 }, { count:0, lost:0 }, { count:0, lost:0 }, { count:0, lost:0 }, { count:0, lost:0 }, { count:0, lost:0 } ],
				received: [ { count:0, lost:0 }, { count:0, lost:0 }, { count:0, lost:0 }, { count:0, lost:0 }, { count:0, lost:0 }, { count:0, lost:0 } ] };
	}
	
	static inline function FIX( life : Float ) {
		return Std.int(Math.pow(Math.max(life,0), 0.6));
	}

	public function new( position : data.Map ) {
		fidGenerator = 0;
		curtime = TIMEBASE;
		timeout = null;
		rnd = new neko.Random();
		fRandom = Std.random;
		nextStatus = INFINITE;
		skills = new SkillsImpl();
		objects = new ObjectsImpl();
		deads = new List();
		deads_tmp = new List();
		escaped = new List();
		attackers = new Array();
		defenders = new Array();
		all = new Array();
		historyContent = new List();
		onNextTurn = new List();
		onNextCycle = new List();
		onStartFight = new List();
		onAnnounce = new List();
		onEndFight = new List();
		this.position = position;
		attackResult = new Result(this,true);
		defendResult = new Result(this,false);
		attackResult.other = defendResult;
		defendResult.other = attackResult;
		res = attackResult;
		envSkill = null;
		canUseEquip = true;
		canUsePermanentEquipOnly = false;
		canUseCapture = true;
		enableStats = false;
		enableBalance = true;
		deleteObjects = true;
		stats = new IntHash();
		//
		enableEnergy = true;
	}

	public function setSeed(seed:Int) {
		rnd.setSeed(seed);
		fRandom = rnd.int;
	}
	
	inline public function random(f:Int):Int {
		return fRandom(f);
	}
	
	public function getEscaped() {
		return escaped;
	}
	
	public function result(side) {
		return side ? attackResult : defendResult;
	}

	public function getDeads() {
		return deads;
	}

	public function replay(h,won) {
		historyContent = h;
		attackResult.won = won;
		defendResult.won = !won;
		execute = function(?needPrepare=true) {};
	}

	public function hasWon() {
		return attackResult.won;
	}

	public function getHistory() {
		return historyContent;
	}

	public function getPosition() {
		return position;
	}

	public function getEnv() {
		return envSkill;
	}
	// ----------------------------------------------------- ENGINE ----------------------------------------------------------

	public function history(h) {
		historyContent.add(h);
	}

	public function notify( f : Fighter, n : _Notification ) {
		if( !isActive(f) ) return;
		var l = new List();
		l.add(f);
		notifyGroup( l, n );
	}
	
	public function notifyGroup( l : List<Fighter>, n : _Notification ) {
		history(_HNotify(l.map( function(f) return f.id ), n));
	}

	public function announce( f : Fighter, s : data.Skill ) {
		if( !isActive(f) ) return;
		history(_HAnnounce(f.id, s.name));
		for( fct in onAnnounce )
			fct(f, s);
	}

	public function announceText( f : Fighter, text : String ) {
		history(_HAnnounce(f.id,text));
	}

	public function object( f : Fighter, o : data.Object ) {
		if( !isActive(f) ) return;
		history(_HObject(f.id,o.name,o.id));
	}

	public function side( s : Bool ) {
		return if( s ) attackers else defenders;
	}

	public function setSide( f : Fighter, newSide : Bool ) {
		side(f.side).remove(f);
		f.side = newSide;
		side(newSide).push(f);
	}

	public function lost( f : Fighter, fx, life ) {
		for( callb in f.onLost )
			life = callb(life);
		f.life -= life;
		if( f.life <= 0 ) {
			deads_tmp.add(f);
		}
		history(_HLost(f.id, life, fx));
		if( enableStats ) {
			stats.get(f.id).lostLife += life;
		}
	}

	public function lostFix( f : Fighter, fx, life ) {
		lost( f, fx, if( f.balanced ) FIX(life*1.0) else life );
	}

	public function randomProbas( probas ) {
		return data.Tools.random(probas,function(t) return t,rnd);
	}

	public function regenerate( f : Fighter, fx, life ) {
		var dt = f.startLife - f.life;
		if( life > dt )
			life = dt;
		else if( life < 0 )
			life = 0;
		if( (f.dino != null || f.dinoRef != null) && !result(f.side).rules.canHealDinoz ) {
			history(_HFx(_SFAura(f.id,0xFF8080,3)));
			return 0;
		}
		f.life += life;
		if( fx != null )
			history(_HRegen(f.id,life,fx));
		if( deads.remove(f) ) {
			f.time = curtime + rnd.int(TIMEBASE * TIMECOEF);
			all.push(f);
			side(f.side).push(f);
		}
		if( enableStats )
			stats.get(f.id).regeneratedLife += life;
		
		if( this.result(f.side).rules != null )
			for( cb in this.result(f.side).rules.onHeal)
				cb(f, life);
		
		return life;
	}
	
	public function effectGroup( f : Fighter, targets : Array<Fighter>, fx ) {
		history(_HDamagesGroup(f.id,Lambda.map(targets,function(t) { return { _tid : t.id, _life : 0 }; }),fx));
	}

	public function effect( fx ) {
		history(_HFx(fx));
	}

	public function addFighter( f : Fighter ) {
		if( f.side )
			attackers.push(f);
		else
			defenders.push(f);
		all.push(f);
		var fx = result(f.side).addfx;
		if( fx == null && f.monster != null )
			fx = f.monster.addfx;
		history(_HAdd(f.infos(), fx));
		if( enableStats ) {
			var s = createStatObject();
			s.side = f.side;
			s.startLife = s.finalLife = f.startLife;
			if( f.dino != null ) {
				s.dino = f.dino.id;
				s.user = f.dino.uid;
			}
			stats.set( f.id, s );
		}
	}

	public function invocated( by : Fighter, f : Fighter ) {
		result(by.side).rules.onInvoc(f, by);
	}

	public function addMonster( m : data.Monster, ?side ) {
		if( side == null ) side = false;
		var f = new Fighter(generateId(), m.life, m.elements.copy(), side);
		f.level = m.level;
		f.name = m.name;
		f.monster = m;
		f.balanced = m.balance;
		f.time = curtime + rnd.int(TIMEBASE) * TIMECOEF;
		// don't use attack bonus since we want to use 'void' defense
		if( m.attackBonus > 0 ) {
			var e = f.elements[Data.VOID];
			if( e == null ) e = 0;
			f.elements[Data.VOID] = e + m.attackBonus;
		}
		for( i in 0...6 )
			f.defense[i] += m.defenseBonus;
		// don't use attacks with 0 element
		for( i in 0...f.elements.length )
			if( f.elements[i] == 0 )
				f.elementsOrder.remove(i);
		if( f.elementsOrder.length == 0 )
			f.elementsOrder = [Data.VOID];
		addFighter(f);
		for( s in m.skills )
			skills.apply(s,f,this);
		f.finalize();
		result(side).addMonster(f);
		return f;
	}

	public function addDinoz( d : db.Dino, ?side ) {
		if( side == null ) side = true;
		var f = new Fighter(generateId(), d.life, d.getElements(), side);
		f.dino = d;
		f.balanced = true;
		f.level = d.level;
		f.name = d.name;
		f.time = curtime + rnd.int(TIMEBASE) * TIMECOEF;
		addFighter(f);
		result(side).addDinoz(f);
		return f;
	}
	
	public function isActive(f:fight.Fighter) {
		return f != null && !(f.life <= 0 || Lambda.has(escaped, f) || Lambda.has(deads, f));
	}
	
	public function escapeFromFight(f) {
		escaped.add(f);
		removeFromFight(f);
	}

	public function removeFromFight(f) {
		// keep in result dinoz only
		all.remove(f);
		result(f.side).fighters.remove(f);
		side(f.side).remove(f);
		deads_tmp.remove(f);
		deads.remove(f);
	}

	public function removeAll() {
		while( all.length > 0 ) {
			var f = all.pop();
			removeFromFight(f);
		}
		while ( attackers.length > 0 )
			attackers.pop();
		while ( defenders.length > 0 )
			defenders.pop();
	}
	
	public function generateId() {
		return fidGenerator++;
	}

	public function cancel() {
		throw CancelEvent.Exception;
	}

	public function historyPosition() {
		return historyContent.length;
	}

	public function ignoreAnnounce() {
		// remove announce
		historyContent.remove(historyContent.last());
	}

	public function setSkin( f : Fighter, skin : data.Monster ) {
		for( h in historyContent )
			switch( h ) {
			case _HAdd(inf,_):
				if( inf._fid == f.id ) {
					inf._gfx = if( skin.gfx != null ) skin.gfx else skin.frame;
					inf._dino = skin.gfx != null;
					inf._size = skin.size;
					return;
				}
			default:
			}
	}
	
	public function setEnv( env : { function init() : Void; function execute() : Void; function cancel() : Void; function getCaster() : Fighter; var playing(default, null):Bool; var timeout : Int; } ) {
		if( envSkill != null ) envSkill.cancel();
		envSkill = env;
		if( envSkill != null ) envSkill.init();
	}

	public function prepare() {
		var me = this;
		
		var allDino = Lambda.filter( all, function(f) return f.dino != null ).array();
		// apply dinoz skills and inventory objects
		// ==================== OBJETS PERMANENTS ====================
		if( canUseEquip ) {
			for( f in allDino ) {
				for( i in f.dino.getEquip() ) {
					var o = Data.OBJECTS.getId(i.oid);
					if( o.fight == null || !o.lock ) continue;
					objects.apply(o, f, me, i);
				}
			}
		}
		
		// ==================== COMPETENCES ====================
		for( f in allDino ) {
			for( s in f.dino.getSkills() )
				if( s.active )
					skills.apply(Data.SKILLS.getId(s.sid), f, this);
		}
		
		for( f in allDino ) {
			if( !Lambda.has(f.restrictions, Restriction.REffects ) ) {
				for( e in f.dino.getEffects() )
					Effects.apply(f, this, e);
			}
		}
		
		// ==================== OBJETS NON PERMANENTS ====================
		if( canUseEquip && !canUsePermanentEquipOnly ) {
			for( f in allDino ) {
				if( !Lambda.has(f.restrictions, Restriction.RObject ) ) {
					for( i in f.dino.getEquip() ) {
						var o = Data.OBJECTS.getId(i.oid);
						if( o.fight == null || o.lock ) continue;
						if( o.fight.proba == 0 ) {
							objects.apply(o, f, me, i);
						} else {
							f.addObject(o.fight.priority, o.fight.proba, o, function() {
								me.objects.apply(o, f, me, i);
								if( me.deleteObjects && f.deleteObjects )
									i.delete();
							});
						}
					}
				}
			}
		}
		//
		for( f in allDino ) {
			f.energy = f.maxEnergy;
		}
		logMaxEnergy(allDino);
		logEnergy(allDino);
		// sort events and other by priority
		for( f in allDino )
			f.finalize();
	}
	
	function isEnvObject( o : Object ) : Bool {
		return switch( o.id ) {
			case Data.OBJECTS.list.stelme.id, Data.OBJECTS.list.ourano.id, Data.OBJECTS.list.abysse.id, Data.OBJECTS.list.amazon.id, Data.OBJECTS.list.cendre.id:
				true;
			default:
				false;
		}
	}
	
	function executeEvent( e ) {
		try {
			e.fx();
			return true;
		} catch( e : CancelEvent ) {
			popHistory();
			return false;
		}
	}

	public function popHistory() {
		var l = historyContent.last();
		historyContent.remove(l);
		return l;
	}
	
	function checkDeads() {
		var tmp = deads_tmp;
		if( tmp.isEmpty() )
			return attackers.length == 0 || defenders.length == 0;
		deads_tmp = new List();
		for( f in tmp )
			if( f.life <= 0 && all.remove(f) ) {
				var cancel = false;
				for( k in f.onKill )
					if( !k() ) {
						cancel = true;
						break;
					}
				if( cancel ) {
					// in case we removed from fight during this time
					if( Lambda.has(side(f.side),f) )
						all.push(f);
					continue;
				}
				if( envSkill != null && envSkill.getCaster() == f )  envSkill.cancel();
				f.life = 0;
				(if( f.side ) attackers else defenders).remove(f);
				deads.add(f);
				history(_HDead(f.id));
			}
		return checkDeads();
	}

	public function logEnergy( a : Array<Fighter> ) {
		var fids = a.map( function(f) return f.id ).array();
		var e = a.map( function(f) return f.energy ).array();
		history( _HEnergy( fids, e ) );
	}
	
	public function logMaxEnergy( a : Array<Fighter> ) {
		var fids = a.map( function(f) return f.id ).array();
		var e = a.map( function(f) return f.maxEnergy ).array();
		history( _HMaxEnergy( fids, e ) );
	}
	
	public function removeCycleListener( cb:Void->Void ) {
		for( n in onNextCycle )
			if( cb == n.callb )
				onNextCycle.remove(n);
	}
	
	public function addCycleListener( cb : Void->Void ) {
		onNextCycle.add( { nextCycle:CYCLE, callb:cb } );
	}
	
	public dynamic function execute( ?needPrepare = true) {
		if( needPrepare )
			prepare();
		if( this.enableEnergy )
			history(_HLog("Energy enabled"));
		history(_HDisplay());
		for( f in onStartFight )
			f();
		// start main loop
		var turns = 10000;
		curtime = 0;
		
		if( attackers.length > 0 && defenders.length > 0 ) {
			// put everybody to 0-based time		
			all.sort(function(f1,f2) { return f1.time - f2.time; });
			var t0 = all[0].time;
			for( f in all )
				f.time -= t0;
			
			lastFighter = null;
			while( turns-- > 0 ) {
				// select first to attack
				all.sort(function(f1, f2) { return f1.time - f2.time; });
				var f = all[0];
				// update status
				var dt = f.time - curtime;
				var idt = (dt / TIMECOEF).int();
				if( this.enableEnergy ) {
					Lambda.iter(all, function(lff) {
						if( lff != f )
							lff.energy += (lff.recoveryMultiplier * dt * 0.5).int();
					});
					logEnergy(all);
				}
				
				if( dt > 0 ) {
					var stat = ( nextStatus <= dt );
					if( stat )
						dt = nextStatus;
					curtime += dt;
					// end of limited time
					if( timeout != null && curtime >= timeout.t ) {
						curtime -= dt;
						dt = timeout.t - curtime;
						var old = timeout;
						timeout = null;
						if( !old.callb() ) {
							history(_HPause(idt));
							break;
						}
					}
					//
					if( envSkill != null && envSkill.playing && envSkill.getCaster() == f ) {
						envSkill.timeout -= dt;
						if ( envSkill.timeout <= 0 ) 
							envSkill.cancel();
					}
					// is new cycle (unlikely, dt is superior than a cycle value, but just in case)
					for( n in onNextCycle ) {
						n.nextCycle -= dt;
						if( n.nextCycle <= 0 ) {
							n.callb();
							n.nextCycle += CYCLE;
						}
					}
					//
					nextStatus = INFINITE;
					if( stat )
						history(_HPause(idt));
					for( f in all )
						updateStatus(f, dt);
					if( stat ) {
						if( checkDeads() )
							break;
						continue;
					}
				}
				history(_HPause(idt));
				// notify actions before fighter turn
				for( b in f.beforeTurn )
					b();
				// if env skill is applied
				if( envSkill != null && envSkill.playing && envSkill.getCaster() == f )
					envSkill.execute();
				
				// combo
				if( lastFighter != f ) {
					if( lastFighter != null ) lastFighter.combo = 0;
					f.combo = 0;
				}
				lastFighter = f;
				lastFighter.combo ++;
				//needed a hack for exceed combos
				if( lastFighter.combo <= 10 && (!enableEnergy || f.energy >= 5) ) {
					// event ?
					var flag = false;
					var nextEvent = f.nextEvent;
					f.nextEvent = null;
					//
					if( nextEvent == null ) {
						var fevents = f.events;
						for( filter in f.eventsFilters ) if( filter != null ) fevents = filter(fevents);
						for( e in fevents ) {
							var proba = e.proba;
							if( enableEnergy && e.energy > f.energy ) continue;
							if( rnd.int(100) < proba ) {
								nextEvent = e;
								break;
							}
						}
					}
					if( nextEvent != null ) {
						switch( nextEvent.notify ) {
							case NSkill(s): announce(f, s);
							case NObject(o):
								if( !(envSkill != null && envSkill.playing && isEnvObject(o) && f.side == envSkill.getCaster().side) )
									history(_HObject(f.id, o.name, o.id));
						}
						if( executeEvent(nextEvent) ) {
							f.energy -= nextEvent.energy;
							flag = checkDeads();
							logEnergy([f]);
						}
					}
					if( flag ) break;
					// attack ?
					var att = false;
					//forced attack ?
					var nextAttack = f.nextAttack;
					if( nextAttack == null ) {
						var fattacks = f.attacks;
						for( filter in f.attacksFilters ) 
							if( filter != null ) 
								fattacks = filter(fattacks);
						
						for( a in fattacks ) {
							var proba = a.proba;
							if( a.energy > f.energy ) {
								continue;
							}
							if( rnd.int(100) < proba ) {
								nextAttack = a;
								break;
							}
						}
					}
					
					if( nextAttack != null ) {
						announce(f, nextAttack.notify);
						if( executeEvent(nextAttack) ) {
							f.energy -= nextAttack.energy;
							att = true;
						}
					}
					
					if( nextAttack == f.nextAttack ) 
						f.nextAttack = null;
					
					// assault ?
					if( !att ) {
						attackFrom(f, _GNormal, _LNormal, true);
						f.energy -= 4;
					}
					logEnergy([f]);
				} else {
					//Le dinoz passe son tour
					history( _HFx( _STired( f.id ) ) );
				}
				
				// increase time
				var elt = f.currentElement(true);
				var dt = Std.int(TIMEBASE * TIMECOEF * f.timeMultiplier * f.timeMultipliers[elt]);
				if( dt <= 0 ) dt = 1;
				f.time += dt;
				// increase turns
				var s = f.side ? attackResult : defendResult;
				s.turns++;
				for( t in onNextTurn )
					t(f);
				// deads
				var flag = checkDeads();
				// post-process
				for( f in all ) {
					if( f.curTarget != null ) {
						f.curTarget = null;
						if( !f.noReturn )	history(_HReturn(f.id));
						else				f.noReturn = false;
					}
				}
				if( flag )	break;
			}
		}
		// attack castle
		if( castle != null && defenders.length == 0 )
			for( f in attackers )
				castle.attack(f);
		// execute after fight effects
		for( f in all )
			for( fx in f.afterFight )
				fx();
		// update status
		attackResult.won = attackResult.calculateVictory();
		defendResult.won = defendResult.calculateVictory();
		for( f in onEndFight )
			f();
		attackResult.calculate();
		defendResult.calculate();
		if( enableStats ) {
			for( d in deads ) {
				stats.get(d.id).dead = true;
				stats.get(d.id).finalLife = 0;
			}
			for( f in all )
				stats.get(f.id).finalLife = f.life;
		}
		// finish
		history(_HFinish(attackResult.end, defendResult.end));
	}

	// ---------------------------------------------------- CASTLE ---------------------------------------------------------

	public function addCastle(c, dofight, ?fixDamages : Null<Int> ) {
		castle = new fight.Castle(this,c, fixDamages);
		history(_HAddCastle(castle.infos(dofight)));
		return castle;
	}

	public function setTimeout(time, visible, ?callb) {
		time *= TIMECOEF;
		timeout = { t : time, callb : if( callb == null ) function() return false else callb };
		if( visible )
			history(_HTimeLimit( Std.int(time / TIMECOEF)));
	}

	public function attackCastle( f : Fighter, dmg : Int, ?fx ) {
		history(_HCastleAttack(f.id,dmg,fx));
	}

	public function text( txt : String, ?f : Fighter ) {
		if( f == null )
			history(_HText(txt));
		else
			history(_HTalk(f.id,txt));
	}
	
	// ---------------------------------------------------- FIGHT ---------------------------------------------------------
	
	public function test( p : Float ) {
		return rnd.int(100) < (p - 1) * 100;
	}
	
	public var lastFighter:Null<Fighter>;
	public function attackTarget(f : Fighter,t : Fighter,goto,fx,sfx,dmg,assault,?invoc=false) {
		if( t == null )
			throw "NULL target !";
			
		var energyCost = 2;
		var canCombo = assault;
		if( dmg == null ) {
			var elt = f.currentElement();
			dmg = f.attack(elt, if( elt == Data.VOID ) 1 else 5);
			if( fx == _LNormal )
				fx = elements[elt];
		} else {
			canCombo = false;
		}
		//
		var inf = { target : t, lost : 0, dmg : dmg, from : f, assault : assault, esquive : false, invoc : invoc };
		if ( f.combo >= 10 )
		{
			//Le dinoz passe son tour
			history( _HFx( _STired( f.id ) ) );
		}
		else
		{
			if( enableStats )
				stats.get(f.id).attacks ++;
			
			var scoreAtt = 2, scoreDef = 0, sum = 0;
			for( e in 0...6 ) {
				var v = dmg[e];
				scoreAtt += v;
				sum += v;
				if( v > 0 ) {
					scoreDef += Math.ceil(t.defense[e]) * v;
					if( assault )
						scoreAtt += f.assaultsBonus[e];
					else
						scoreAtt += f.powerBonus[e];
				}
			}
			
			if( assault ) {
				scoreAtt += f.allAssaultsBonus + f.nextAssaultBonus;
				scoreAtt = Std.int(scoreAtt * f.nextAssaultMultiplier * f.assaultMultiplier);
				f.nextAssaultBonus = 0;
				f.nextAssaultMultiplier = 1;
			}
			
			// if multi-elements attack, defends with average, not sum
			if( sum > 0 )
				scoreDef = Std.int(scoreDef / sum);

			if( !f.cancelArmor )
				scoreDef += t.armor;

			if( goto != null && f.curTarget != t ) {
				history(_HGoto(f.id,t.id,goto));
				f.curTarget = t;
				t.curTarget = f;
				t.noReturn = true;
			}
			//
			var tlife = 0;
			while ( f.combo < 10 ) {
				// combo
				f.combo ++;
				
				// calcul degats
				var bonus = rnd.float() * scoreAtt / 3; // up to +30% random
				var flife = (scoreAtt + bonus) * GORE - scoreDef;
				if( f.balanced && t.balanced )
					flife = FIX(flife);
				var life = Std.int(flife);
				if( life < f.minDamage )
					life = f.minDamage;
				if( assault && life < f.minAssaultDamage )
					life = f.minAssaultDamage;
				// apply defenses
				inf.lost = life;
				for( d in t.defenses )
					d(inf);
				
				// esquive
				var doEsquive = assault && test(t.esquive) && !f.cantEsquiveAssault;
				var doSuperEsquive = !assault && test(t.superEsquive) && !(t.hasStatus(_SStoned) || t.hasStatus(_SSleep) || t.hasStatus(_SFly) || t.hasStatus(_SStun)) ;
				inf.esquive = doEsquive || doSuperEsquive;
				
				// status speciaux
				var noDamage = false;
				if( assault && t.hasStatus(_SFly) && !f.hasStatus(_SFly) && !f.canFightFlying ) {
					noDamage = true;
					sfx = _EFlyCancel;
				}
				
				if( t.hasStatus(_SIntang) ) {
					if( (assault && f.canFightIntang) || dmg[Data.AIR] != 0 ) {
						inf.lost = 1;
						sfx = _EIntangBreak;
					} else {
						noDamage = true;
						sfx = _EIntangCancel;
					}
				}
				
				for( s in f.status ) {
					switch( s.status ) {
						case _SDazzled( pow ):
							if( Std.random(pow) == 0 ) {
								noDamage = true;//TODO make specific effect ??
								inf.esquive = true;
								sfx = _EMissed;
							}
						default:
					}
				}
				
				if( doEsquive || noDamage || doSuperEsquive )
					inf.lost = 0;
				
				if( enableStats && (doEsquive || doSuperEsquive))
					stats.get(t.id).esquives ++;
				
				// damages
				tlife += inf.lost;
				history(_HDamages(f.id, t.id, if(inf.esquive) null else inf.lost, fx, sfx));
				if( sfx == _EIntangBreak )
					cancelStatus(t, _SIntang);
				
				if( enableEnergy )
					f.energy -= energyCost;
				
				// after events
				for( evt in f.afterAttack )
					evt(inf);
				
				for( evt in inf.target.afterDefense )
					evt(inf);
				
				// combo ?
				if( canCombo && test(f.multiAttack) ) {
					if( enableStats )
						stats.get(f.id).multis ++;
					// combo
					energyCost ++;
					continue;
				}
				break;
			}
			
			inf.lost = tlife;
			t.life -= tlife;
			
			if( enableStats ) {
				if( assault )
					stats.get(f.id).assaults ++;
				var elt = Lambda.indexOf(elements, fx);
				if( elt == -1 ) elt = f.currentElement();
				stats.get(f.id).given[elt].count ++;
				stats.get(f.id).given[elt].lost += inf.lost;
				stats.get(t.id).received[elt].count ++;
				stats.get(t.id).received[elt].lost += inf.lost;
				stats.get(t.id).lostLife += inf.lost;
			}
			
			if( t.life <= 0 ) {
				deads_tmp.add(t);
			} else if( assault && test(t.counterAttack) ) {
				attackTarget(t, f, _GNormal, _LNormal, _ECounter, null, true, false);
				if( enableStats )
					stats.get(t.id).counters ++;
			}
		}
		return inf;
	}
	
	public function attackSingle( f : Fighter, fx, dmg, ?goto, ?target:Fighter ) {
		if( target == null ) {
			var l = side(!f.side);
			target = l[rnd.int(l.length)];
			for( fct in target.onTargeted )
				target = fct(target);
		}
		
		var old = historyContent;
		var invoc = switch(fx) {
			case _GrInvoc(_): true;
			default: false;
		}
		
		historyContent = new List();
		if( goto != null ) history(_HGoto(f.id,target.id,goto));
		var inf = attackTarget(f,target,null,null,null,dmg,false,invoc);
		groupHistory(f,old,fx);
		return inf;
	}

	public function attackGroup( f : Fighter, fx, dmg, ?count, ?filter ) {
		var old = historyContent;
		historyContent = new List();
		var l = side(!f.side);
		if( filter != null ) {
			var l2 = new Array();
			for( f in l )
				if( filter(f) )
					l2.push(f);
			l = l2;
		}
		if( count != null ) {
			l = l.copy();
			while( l.length > count )
				l.splice(rnd.int(l.length), 1);
		}
		if( enableStats )
			stats.get(f.id).groupAttacks ++;
			
		var invoc = switch(fx) {
			case _GrInvoc(_): true;
			default: false;
		}		
		var infs = new List();
		for( t in l ) {
			for( fct in t.onTargeted )
				t = fct(t);
			infs.add( attackTarget(f, t, null, null, null, dmg, false, invoc) );
		}
		groupHistory(f, old, fx);
		return infs;
	}

	function groupHistory( f : Fighter, old : List<_History>, fx ) {
		var targets = new List();
		var after = new List();
		var found = false;
		for( h in historyContent )
			switch( h ) {
			case _HDamages(fid,tid,life,fx,sfx):
				found = true;
				if( fid != f.id || fx != null || (sfx != null && sfx != _EMissed && sfx != _EIntangCancel && sfx != _EIntangBreak) )
					throw "ASSERT : "+Std.string(h);
				targets.add({ _tid : tid, _life : life });
			default:
				if( found )
					after.add(h);
				else
					old.add(h);
			}
		historyContent = old;
		history(_HDamagesGroup(f.id,targets,fx));
		for( e in after )
			historyContent.add(e);
	}

	public function attackFrom( f : Fighter, goto, fx, assault, ?sfx, ?dmg ) : AttackInfos {
		var tl = this.side(!f.side).copy();
		var tl = this.side(!f.side).copy();
		if( tl.length == 0 )
			return null;
		// filter fighters that can be targeted
		var canAttackFlying = f.canFightFlying || f.hasStatus(_SFly);
		var canAttackIntang = f.canFightIntang || (dmg != null && dmg[Data.AIR] > 0) || (dmg == null && f.currentElement() == Data.AIR);
		var invalids = new Array();
		for( t in tl )
			if( (!canAttackFlying && t.hasStatus(_SFly)) || (!canAttackIntang && t.hasStatus(_SIntang)) )
				invalids.push(t);
		if( invalids.length != tl.length )
			for( t in invalids )
				tl.remove(t);
		// if rock success, then choose between rock dinoz
		for( f in tl )
			if( f.markAsRock ) {
				if( rnd.int(2) == 0 )
					tl = Lambda.array(Lambda.filter(tl,function(f) { return f.markAsRock; }));
				break;
			}
		// now apply game filters
		for( filter in f.targetFilters )
			if( filter != null )
				tl = filter(tl);
		
		var t = tl[rnd.int(tl.length)];
		for( fct in t.onTargeted )
			t = fct(t);
		return attackTarget(f, t, goto, fx, sfx, dmg, assault);
	}

	// ---------------------------------------------------- STATUS ---------------------------------------------------------
	
	public function isBadStatus(s) {
		return switch( s ) {
		case _SSleep, _SSlow, _SStoned, _SPoison(_), _SBurn(_), _SMonoElt(_), _SDazzled(_), _SStun : true;
		case _SFlames, _SIntang, _SFly, _SQuick, _SShield, _SBless, _SHeal(_) : false;
		}
	}

	function applyStatus( f : Fighter, s : StatusInfos, on ) {
		var add = function(n) { return if( on ) n else -n; };
		var mul = function(n:Float) { return if( on ) n else 1/n; };
		switch( s.status ) {
		case _SSleep:
			if( on ) {
				f.time += INFINITE;
				var wakeup;
				var me = this;
				wakeup = function(inf) {
					if( !Std.is(me.envSkill, fight.skills.Amazonie) && inf.lost > 0 )
						me.cancelStatus(f,_SSleep);
					else if( Std.is(me.envSkill, fight.skills.Amazonie) && inf.lost > 10 )
						me.cancelStatus(f,_SSleep);
				};
				f.afterDefense.add(wakeup);
				s.cancel = function() { f.afterDefense.remove(wakeup); };
			} else {
				f.time = curtime + rnd.int(TIMEBASE * TIMECOEF);
			}
			if( enableStats )
				stats.get(f.id).sleep ++;
		case _SFlames:
			s.cycle = true;
			f.defense[Data.FIRE] += add(10);
			if( on ) {
				var me = this;
				var hit = function(inf) {
					if( inf.assault && inf.lost > 0 && inf.from != null )
						me.lostFix(inf.from,_LFire,f.elements[Data.FIRE]);
				};
				f.afterDefense.add(hit);
				s.cancel = function() { f.afterDefense.remove(hit); };
			}
		case _SBurn(pow):
			s.cycle = true;
			if( on ) {
				var me = this;
				var hit = function(inf) {
					if( inf.assault && inf.lost > 0 && inf.from != null )
						me.lostFix(inf.from,_LFire, 1);
				};
				f.afterDefense.add(hit);
				s.cancel = function() { f.afterDefense.remove(hit); };
			}
		case _SIntang:
			if( on ) {
				var me = this;
				var lose = function(inf) {
					if( inf.lost > 0 )
						me.cancelStatus(f,_SIntang);
				}
				f.afterDefense.add(lose);
				s.cancel = function() { f.afterDefense.remove(lose); };
			}
		case _SFly:
			if( on && !f.flyAfterAttack ) {
				var me = this;
				var lose = function(inf) {
					me.cancelStatus(f,_SFly);
				};
				f.afterAttack.add(lose);
				s.cancel = function() { f.afterAttack.remove(lose); };
			}
		case _SSlow:
			f.timeMultiplier *= mul(1.5);
		case _SQuick:
			f.timeMultiplier /= mul(1.5);
		case _SStoned:
			if( on ) {
				f.time += INFINITE;
				var counter = f.counterAttack;
				var esq = f.esquive;
				f.counterAttack = 1; // 0%
				f.esquive = 1;
				s.cancel = function() {
					f.counterAttack = counter;
					f.esquive = esq;
				}
			} else {
				f.time -= INFINITE;
				if( f.time < curtime ) {
					f.time = curtime;
				}
			}
			f.armor += add(5);
			if( on && enableStats )
				stats.get(f.id).stoned ++;
		case _SShield:
			f.armor += add(5);
		case _SBless:
			f.allAssaultsBonus += add(3);
		case _SPoison(_):
			if( on && enableStats )
				stats.get(f.id).poison ++;
			s.cycle = true;
		case _SHeal(_):
			s.cycle = true;
		case _SMonoElt(elt):
			f.lockedElement = on;
		case _SDazzled(_):
		case _SStun:
			var me = this;
			if ( on ) {
				f.time += INFINITE;
				s.cancel = function() {
					me.cancelStatus(f, _SStun);
				}
			} else {
				f.time -= INFINITE;
				if( f.time < curtime ) {
					f.time = curtime;
				}
			}
		}
	}

	public function status( f : Fighter, stat, length ) {
		var time = switch( length ) {
			case DShort: 	15 * TIMECOEF;
			case DMedium: 	30 * TIMECOEF;
			case DLong:	 	80 * TIMECOEF;
			case DInfinite: INFINITE;
		};
		for( test in f.onStatus )
			if( !test(stat) )
				return false;
		var c = Type.enumConstructor(cast stat);
		for( s in f.status )
			if( Type.enumConstructor(cast s.status) == c )
				return false;
		var inf = {
			status : stat,
			time : time,
			rem : 0,
			cycle : false,
			cancel : function() { },
		};
		applyStatus(f, inf, true);
		f.status.add(inf);
		history(_HStatus(f.id, stat));
		if( inf.cycle && nextStatus > CYCLE )
			nextStatus = CYCLE;
		else if( nextStatus > time )
			nextStatus = time;
		return true;
	}

	public function removeStatus( f : Fighter, goods ) {
		var ok = false;
		if( f == null || f.life == 0 ) return ok;
		
		for( s in f.status )
			if( isBadStatus(s.status) != goods && cancelStatus(f,s.status) )
				ok = true;
		return ok;
	}

	public function cancelStatus( f : Fighter, stat : _Status ) {
		if( f == null || f.life == 0 ) return false;
		
		var stat : EnumValue = cast stat;
		var c = Type.enumConstructor(stat);
		for( s in f.status )
			if( Type.enumConstructor(cast s.status) == c ) {
				applyStatus(f, s, false);
				f.status.remove(s);
				history(_HNoStatus(f.id, s.status));
				s.cancel();
				return true;
			}
		return false;
	}

	function executeStatus( f : Fighter, s : _Status ) {
		switch( s ) {
		case _SPoison(pow)	: this.lost(f, _LPoison, pow);
		case _SBurn(pow)	: this.lost(f, _LFire, pow);
		case _SHeal(pow)	: this.regenerate(f, _LHeal, pow);
		case _SFlames		: this.lost(f, _LFire, 1);
		default:
		}
	}

	function updateStatus( f : Fighter, dt : Int ) {
		for( s in f.status ) {
			s.time -= dt;
			if( s.cycle ) {
				s.rem += dt;
				if( s.rem == CYCLE ) {
					executeStatus(f, s.status);
					s.rem = 0;
				}
				var next = CYCLE - s.rem;
				if( nextStatus > next )
					nextStatus = next;
			}
			if( s.time <= 0 )
				this.cancelStatus(f, s.status);
			else if( nextStatus > s.time )
				nextStatus = s.time;
		}
	}
}
