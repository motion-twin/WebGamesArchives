package fight;
import Fight;
import fight.Fighter;
import fight.skills.Abysse;
import fight.skills.Amazonie;
import fight.skills.Cendres;
import fight.skills.Ouranos;
import fight.skills.StElme;

using Lambda;
using Std;
class ObjectsImpl {

	var f : fight.Fighter;
	var m : fight.Manager;
	var o : data.Object;
	var i : db.Equip;

	public function new() {
	}

	public function apply( o, f, m, i ) {
		this.o = o;
		this.f = f;
		this.m = m;
		this.i = i;
		var m = Reflect.field(this, "_"+o.id);
		Reflect.callMethod(this, m, []);
	}

	public function check() {
		var f = Type.getInstanceFields(ObjectsImpl);
		for( o in Data.OBJECTS )
			if( o.fight != null && !f.remove("_"+o.id) )
				throw "Object no implemented : "+o.id+" ("+o.name+")";
		for( m in f )
			if( m.charAt(0) == "_" )
				throw "Unknown object implementation : "+m;
	}
	
	function regen( n : Int ) {
		if( f.dino != null )
			n = Std.int(n * Skills.calculateObjectLifeBonus(f.dino));
		m.regenerate(f,_LObject,n);
	}

	// -------------------------------------------------------------------------------------
	
	function _burger() {
		if( f.life == f.startLife || (f.life > 15 && f.startLife - f.life < 10) )
			m.cancel();
		regen(10);
	}
	
	function _ration() {
		var f = f, m = m, o = o;
		var delta = 20 - (f.startLife - f.life);
		if( delta < 0 )
			delta = 0;
		if( f.startLife == f.life || m.random(delta+1) != 0 )
			m.cancel();
		regen(20);
	}

	function _hlmsos() {
		f.armor += 1;
	}

	function _noyau() {
		f.nextAssaultBonus += 10;
	}

	function _ppoiv() {
		f.nextAssaultBonus += 10;
	}

	function _zippo() {
		m.status(f,_SFlames,DLong);
	}

	function _flamch() {
		m.addMonster(Data.MONSTERS.list.flam,f.side);
	}

	function _combi() {
		f.defense[Data.FIRE] += 20;
	}

	function _mergz() {
		var f = f, m = m, o = o;
		if( f.life == f.startLife )
			m.cancel();
		// -10% defense
		for( i in 0...6 )
			f.defense[i] -= f.defense[i] / 10;
		// + 1-4 pv
		m.regenerate(f,_LNormal,1 + m.randomProbas([10,7,5,3]));
	}
	
	
	function _regen() {
		// newday effect
	}
	

	// OBJECTS WORLD 5

	function _amour() {
		var f = f, m = m, o = o;
		
		var ok = false;
		for( f in m.side(!f.side) )
			if( f.hasStatus(_SFly) )
				ok = true;
		if( !ok )
			m.cancel();
		f.canFightFlying = true;
	}

	function _monoch() {
		var f = f, m = m, o = o;
		if( f.elementsOrder.length == 1 ) m.cancel();
		if( m.result(f.side).rules.cancelMonochromatic ) {
			m.object(f,Data.OBJECTS.list.mantic);
			return;
		}
		var max = f.elements[0];
		var e = 0;
		for( i in 1...5 )
			if( f.elements[i] > max ) {
				max = f.elements[i];
				e = i;
			}
		f.elementsOrder = [e];
	}

	function _fuca() {
		var f = f, m = m, o = o;
		if( f.underFuca ) m.cancel();
		if( f.timeMultiplier < 0.51 ) m.cancel();
		f.timeMultiplier *= 0.75;
		f.underFuca = true;
	}

	function _antip() {
		var prot = false;
		var f = f, m = m, i = i, o = o;
		f.onStatus.push(function(s) return switch( s ) {
			case _SPoison(_):
				if( !prot ) {
					prot = true;
					m.object(f, o);
					if( m.deleteObjects && f.deleteObjects )
						i.delete();
				}
				false;
			default: true;
		});
	}

	function _confus() {
		var f = f, m = m, o = o;
		
		var tl = m.side(!f.side);
		if( tl.length < 2 )
			m.cancel();
		// can't attack target while stoned !
		for( status in f.status ) {
			if( status.status == _SStoned  || status.status == _SStun ) {
				return;
			}
		}
		//TODO ADD A ACHECK TO THE T1 && T2 STATUS !
		var t1 = tl[m.random(tl.length)];
		var t2;
		do {
			t2 = tl[m.random(tl.length)];
		} while( t1 == t2 );
		
		//NEW remplacé par une attaque de type A
		m.attackTarget(t1,t2,_GNormal,_LNormal,null,null,false);
	}

	function _bamboo() {
		m.addMonster(Data.MONSTERS.list.bamboo,f.side);
	}
	
	function _cgold() {
		// nothing
	}
	
	function _mbrais() {
		var add = function(f:Fighter) {
			f.assaultsBonus[Data.FIRE] += Std.int(f.assaultValue(Data.FIRE) * 0.3);
		}
		for( f in m.side(true) )
			add(f);
		for( f in m.side(false) )
			add(f);
	}

	function _trouil() {
		// nothing
	}
	
	function _mencly() {
		// nothing
	}

	function _mbeer() {
		m.result(true).rules.canHealDinoz = false;
		m.result(false).rules.canHealDinoz = false;
		//
		m.result(true).flags.underBeer = true;
		m.result(false).flags.underBeer = true;
	}
	
	function _cofee() {
		var f = f, m = m, o = o;
		
		if( !m.result(f.side).flags.underBeer )
		{
			m.cancel();
			return;
		}
		m.result(f.side).rules.canHealDinoz = true;
		m.result(f.side).flags.underBeer = false;
	}
	
	function _mantip() {
		var prot = false;
		var f = f, m = m, o = o;
		f.onStatus.push(function(s) return switch( s ) {
			case _SPoison(_):
				if( !prot ) {
					m.object(f,o);
					prot = true;
				}
				false;
			default: true;
		});
	}

	function _mbeli() {
		f.castleAttacks++;
	}

	function _mbann() {
		var m = m, o = o, f = f;
		var onInvoc = function(f2:Fighter, from:Fighter) {
			if( f.life <= 0 || m.escaped.has(f) ) return;
			m.object(f, o);
			if( !Lambda.has( m.escaped, f2 ) ) {
				m.history(_HEscape(f2.id));
				m.escapeFromFight(f2);
			}
		}
		m.result(true).rules.onInvoc = onInvoc;
		m.result(false).rules.onInvoc = onInvoc;
	}
	
	function _mantic() {
		var m = m, o = o, f = f;
		m.result(!f.side).rules.cancelMonochromatic = true;
	}
	
	function _mbala2() {
		// désactivé
	}
	
	function _mbalan() {
		var f = f, m = m, o = o, i = i;
		
		if( ! m.enableBalance ) return;
		
		f.onKill.push(function() {
			var dl = new Array();
			for( f in m.side(!f.side) )
				if( f.dino != null && f.life > 0 )
					dl.push(f);
			var d = dl[m.random(dl.length)];
			if( d != null ) {
				m.object(f,o);
				if( m.result(d.side).rules.onBalance(d) )
					m.lost(d, _LSkull(3), d.life);
				var i = db.Equip.manager.get(i.id);
				i.oid = Data.OBJECTS.list.mbala2.oid;
				i.update();
			}
			return true;
		});
	}
	
	function _piran() {
		m.addMonster(Data.MONSTERS.list.pira,f.side);
	}
	
	//AERIS
	//level7
	function _amazon() {
		if ( m.getEnv() != null ) m.cancel();
		else m.setEnv( new Amazonie(f, m) );
	}
	
	function _cendre() {
		if ( m.getEnv() != null ) m.cancel();
		else m.setEnv( new Cendres(f, m) );
	}
	
	function _abysse() {
		if ( m.getEnv() != null ) m.cancel();
		else m.setEnv( new Abysse(f, m) );
	}
	
	function _stelme() {
		if ( m.getEnv() != null ) m.cancel();
		else m.setEnv( new StElme(f, m) );
	}
	
	function _ourano() {
		if ( m.getEnv() != null ) m.cancel();
		else m.setEnv( new Ouranos(f, m) );
	}
	
	function _ptime() {
		var f = f, m = m, i = i, o = o;
		var protected = false;
		
		m.result(f.side).flags.mtimeProtected = function() {
			if( f.life <= 0 || m.escaped.has(f) ) return protected;
			if( !protected ) {
				m.object(f, o);
				if( m.deleteObjects && f.deleteObjects )
					i.delete();
				protected = true;
			}
			return protected;				
		};
	}
	
	function _mtime() {
		var f = f, m = m, i = i, o = o;
		m.onStartFight.push(function() {
			if( f.life <= 0 || m.escaped.has(f) ) return;
			m.object(f, o);
			var dl = [];
			for( side in [true, false] )
				if ( !m.result(side).flags.mtimeProtected() )
					dl = dl.concat( m.side(side) );
			//
			for( f in dl )
				if( f.dino != null ) {
					var ev = new Array();
					for( e in f.events )
						switch( e.notify ) {
						case NSkill(_):
						case NObject(_): ev.push(e);
						}
					f.events = ev;
				}
		});
	}

	function _mpdim() {
		var f = f, m = m, i = i, o = o;
		var first = true;
		var escape = true;
		m.onNextTurn.push(function(_) {
			if( f.life <= 0 || m.escaped.has(f) ) return;
			
			for( t in [true, false] )
				for( f2 in m.side(t).copy() )
					if( f2.dino != null && (f2.life > 0 && f2.life < 10 && f2.startLife > 10) ) {
						if( first ) {
							m.object(f, Data.OBJECTS.list.mpdim);
							first = false;
						}
						if( !m.result(f2.side).canEscape ) {
							if( escape ) {
								m.text(Text.get.cant_escape);
								escape = false;
							}
							continue;
						}
						if( !f2.canEscape ) {
							m.object( f2, Data.OBJECTS.list.agrav );
							continue;
						}
						var l = new List();
						l.add({ _tid : f2.id, _life : 0 });
						m.history(_HDamagesGroup(f.id, l, _GrHole));
						m.escapeFromFight(f2);
					}
		});
	}

	function _mbaget() {
		var f = f, m = m, i = i, o = o;
		f.addAttack(0, 100, cast { name : o.name, energy: 0, level: 0 }, function() {
			if( f.life <= 0 || m.escaped.has(f) ) return;
			
			var dl = new Array();
			for( t in [true,false] )
				for( f in m.side(t) )
					if( f.dino != null )
						dl.push(f);
			var d = dl[m.random(dl.length)];
			var life = Std.int(d.life * 0.3);
			m.lost(d, _LSkull(1), life);
		});
	}

	function _vlife() {
		var f = f, m = m, i = i, o = o;
		var used = false;
		if( f.life >= 20 ) {
			f.afterDefense.push(function(inf) {
				//var active = (f.life + inf.lost) > 20;
				//trace("voleur de vie : " + active + " life="+f.life+" used:"+used);
				if ( !used && f.life <= 20 ) {
					var l = m.side(!f.side);
					var t = l[Std.random(l.length)];
					if ( t != null ) {
						used = true;
						m.object(f, o);
						m.lost(t, _LSkull(3), 30);
						m.regenerate(f, _LObject, 30);
					}
				}
			});
		}
	}
	
	function _mhelp() {
		var last = null, first = true;
		var f = f, m = m, o = o;
		
		f.hasSifflet = true;
		f.afterAttack.push(function(inf) {
			if( inf.assault ) last = inf;
		});
		
		m.onNextTurn.push(function(f2) {
			if( f.life <= 0 || m.escaped.has(f) ) return;
			
			if ( f2 != f || last == null || !last.assault 
				|| last.target == null || last.target.dino == null 
				|| last.lost <= 0 )  
				return;
			
			if( first ) {
				m.object(f, o);
				first = false;
			}
			
			for( f2 in m.side(f.side) ) {
				if( f2.life > 0 && f2 != f && f2.time < Manager.INFINITE && !f2.hasSifflet) {
					var e = f2.currentElement(false);
					m.attackTarget(f2, last.target, _GNormal, Manager.elements[e], null, f2.attack(e, 1), true);
				}
			}
			
			last = null;
		});
	}

	function costume( mo : data.Monster ) {
		if( f.costumeFlag )
			return;
		var f = f, m = m, i = i, o = o;
		
		m.setSkin(f, mo);
		f.costumeFlag = true;
		f.afterDefense.push(function(inf) {
			if( i != null && inf.lost > 0 && inf.dmg[Data.FIRE] > 0 ) {
				if( m.deleteObjects && f.deleteObjects )
					i.delete();
				i = null;
				m.lost(f, _LFire, 3);
				m.history(_HEscape(f.id));
				m.history(_HAdd(f.infos()));
				f.costumeFlag = false;
			}
		});
	}

	function _costve() {
		costume(Data.MONSTERS.list.mugard);
	}

	function _costgb() {
		costume(Data.MONSTERS.list.goblin);
	}

	function _danger() {
		var f = f, m = m, i = i, o = o;
		var callb = null;
		callb = function(life) {
			if( life <= 25 )
				return life;
			if( m.deleteObjects && f.deleteObjects )
				i.delete();
			f.onLost.remove(callb);
			m.object(f, o);
			return 0;
		};
		f.onLost.push(callb);
	}

	function _surviv() {
		var delta = Math.round((50 - (f.startLife - f.life)) / 10);
		if( delta < 0 )
			delta = 0;
		if( (f.startLife - f.life) <= 10 || m.random(delta + 1) != 0 )
			m.cancel();
		regen(40);
	}

	// -------------------------------------------------------------------------------------
	// NOUVEAUX OBJETS MAGIQUES
	// -------------------------------------------------------------------------------------
	function _plandc() {
		// used in a different place when user is doing a levelUp
	}
	
	function _mindim() {
		var f = f, m = m, i = i, o = o;
		for( side in [false, true] ) {
			var rules = m.result(side).rules;
			var old = rules.onHypnose;
			rules.onHypnose = function(pf, pt) {
				if( f.life > 0 && !m.escaped.has(f) ) {
					if( !m.getDeads().has(f) && f.side == pt.side ) {
						m.object(f, o);
						return false;
					}
				}
				if( old == null ) return true;
				else return old(pf, pt);
			}
		}
	}
	
	function _tearlf() {
		var f = f, m = m, i = i, o = o;
		var maxLife = (f.dino != null) ? f.dino.maxLife : f.startLife;
		f.cloneDefaultLife = (0.1 * maxLife).int();
	}
	
	function _dampt() {
		var f = f, m = m, i = i, o = o;
		m.onStartFight.push(function() {
			if( f.life > 0 && !m.escaped.has(f) )
				m.object(f, o);
		});
		f.initMultiplier *= 0.5; // 50%
	}
	
	function _agrav() {// Combinaison anti-gravité
		var f = f, m = m, i = i, o = o;
		for( lf in m.side(f.side) )
			lf.canEscape = false;
	}
	
	function _stero() {
		var f = f, m = m, i = i, o = o;
		f.cantReduceMaxEnergy = true;
	}
	
	function _loking() {
		var f = f, m = m, i = i, o = o;
		var t:Fighter = null;
		// get targetnop
		var duration = 3;
		function lockElement() {
			duration--;
			if( duration == 0 ) {
				if( m.isActive(t) )
					t.lockedElement = false;
				m.removeCycleListener( lockElement );
			}
		}
		//
		m.onStartFight.add( function() {		
			var tl = m.side(!f.side);
			t = tl[Std.random(tl.length)];
			if ( t == null || !m.isActive(t) ) return;
			// ---------------------------------------
			m.object(f, o);
			t.cyclePos = t.elementsOrder.length - 1;
			t.lockedElement = true;
			m.addCycleListener( lockElement );
			m.notify(t, _NMonoElt);
		} );
	}
}
