package fight;
import data.Tools;
import Fight;
import fight.Fighter;
import fight.Fighter.TAAttack;
typedef F = fight.Fighter;
typedef M = fight.Manager;

using Lambda;
using Std;
class SkillsImpl {

	var s : data.Skill;

	public function new() {
	}
	
	public function apply( s, f : F, m : M ) {
		this.s = s;
		var method = Reflect.field(this, "_" + s.id);
		
		if( s.type == data.Skill.SkillType.SPermanent )
			f.energy -= s.energy;
	
		Reflect.callMethod(this,method,[f,m]);
	}

	static public function applySkill( s, f : F, m : M ) {
		new SkillsImpl().apply( s, f, m );
	}
	
	public function check() {
		var f = Type.getInstanceFields(SkillsImpl);
		for( s in Data.SKILLS )
			if( !f.remove("_"+s.id) )
				throw "Skill not implemented : "+s.id+" ("+s.name+")";
		for( m in f )
			if( m.charAt(0) == "_" )
				throw "Unknown skill implementation : "+m;
	}

	// filters priority, lower occurs first
	static var PFILTER_ROCK = 0;//unused
	static var PFILTER_BEST_RATIO = 1;
	static var PFILTER_LOW_LIFE = 2;
	static var PFILTER_SAME_TARGET = 3;
	static var PFILTER_ALL_OTHERS = 4;//unused
	
	// filters priority, lower occurs first
		//SPHERE FILTERS
	static inline var SFILTER_SPHERE_WOOD = 0;
	static inline var SFILTER_SPHERE_WATER = 1;
	static inline var SFILTER_SPHERE_THUNDER = 2;
	static inline var SFILTER_SPHERE_FIRE = 3;
	static inline var SFILTER_SPHERE_AIR = 4;
	

	static function selection( targets : Array<Fighter>, cond ) {
		targets.sort(cond);
		var p = 1;
		var t0 = targets[0];
		while( p < targets.length && cond(t0, targets[p]) == 0 )
			p++;
		return targets.slice(0,p);
	}

	function noPoison( f : F ) {
		f.onStatus.push(function(s) return switch(s) { case _SPoison(_): false; default: true; });
	}

	// --------------------------- TEST ------------------------------------------

	function _test( f : F, m : M ) {
	}
	
	function _nodead( f : F, m : M ) {
		f.onKill.add( function() {
			m.history(_HEscape(f.id));
			m.removeFromFight(f);
			return false;
		} );
	}
	
	// --------------------------- FIRE ------------------------------------------

	function _force( f : F, m : M ) {
		f.allAssaultsBonus += 1;
	}

	function _griffe( f : F, m : M ) {
		f.assaultsBonus[Data.FIRE] += 7;
	}

	function _colere( f : F, m : M ) {
		f.addEvent(1, 20, s, function() {
			f.nextAssaultMultiplier *= 1.25;
			m.effect( _SFAura( f.id, 0xFF0000, 0 )  );
		});
	}

	/*2*/
	function _artmat( f : F, m : M ) {
		f.allAssaultsBonus += 2;
	}

	function _charge( f : F, m : M ) {
		f.nextAssaultBonus += 5;
	}

	function _soufla( f : F, m : M ) {
		f.addAttack(1, 10, s, function() {
			m.attackGroup(f, _GrBlow, f.attack(Data.FIRE, 5));
		});
	}

	function _chass1( f : F, m : M ) {
		// gather
	}

	function _sangch( f : F, m : M ) {
		f.time -= (4 * M.TIMECOEF * f.initMultiplier).int();
	}

	function _furie( f : F, m : M ) {
		f.allAssaultsBonus += 3;
		for( i in 0...6 )
			f.defense[i] -= 2;
	}

	/*3*/
	function _vigila( f : F, m : M ) {
		f.modDefense(Data.FIRE, 5);
	}

	function _waikk( f : F, m : M ) {
		f.counterAttack *= 1.1;
		f.time += (5 * M.TIMECOEF * f.initMultiplier).int();
	}

	function _paumes( f : F, m : M ) {
		f.addAttack(2, 15, s, function() {
			f.time += (15 * M.TIMECOEF * f.initMultiplier).int();
			m.attackFrom(f, _GNormal, _LFire, false, f.attack(Data.FIRE, 10));
			m.notify(f, _NInitDown );
		});
	}

	function _kamikz( f : F, m : M ) {
		f.addAttack(1, 5, s, function() {
			m.attackFrom(f, _GSpecial(0xFF8800, 0x880000), _LExplode, false, f.attack(Data.FIRE, 15));
			m.lost(f, _LFire, Std.int(f.life/2));
		});
	}

	function _combus( f : F, m : M ) {
		f.addEvent(1, 10, s, function() {
			for( t in m.side(!f.side) )
				m.lostFix(t, _LFire, t.elements[Data.WOOD]);
		});
	}

	function _bdefeu( f : F, m : M ) {
		f.addAttack(2, 15, s, function() {
			m.attackSingle(f, _GrFireball, f.attack(Data.FIRE, 7));
		});
	}

	function _coulee( f : F, m : M ) {
		f.addAttack(8, 5, s, function() {
			m.attackSingle(f, _GrLava, f.attack(Data.FIRE, 12));
		});
	}

	function _chass2( f : F, m : M ) {
		// gather
	}

	function _sieste( f : F, m : M ) {
		f.addAttack(1, 5, s, function() {
			m.regenerate(f, _LHeal, m.random(20)+1);
			m.status(f, _SSleep, DShort);
		});
	}

	function _coeura( f : F, m : M ) {
		f.assaultsBonus[Data.FIRE] += 12;
	}
	
	function _aurinc( f : F, m : M ) {
		// permanent
	}
	
	function _venge( f : F, m : M ) {
		f.counterAttack *= 1.05;
	}
	
	/*4*/
	function _chefdg( f : F, m : M ) {
		for( t in m.side(f.side) )
			t.allAssaultsBonus += 2;
	}
	
	function _belier( f : F, m : M ) {
		f.nextAssaultBonus += 20;
	}
	
	function _torche( f : F, m : M ) {
		m.status(f,_SFlames,DInfinite);
	}
	
	function _chass3( f : F, m : M ) {
		// gather
	}

	function _self( f : F, m : M ) {
		f.onStatus.push(function(s) {
			return !m.isBadStatus(s);
		});
		f.time += (3 * M.TIMECOEF * f.initMultiplier).int();
	}

	function _meteor( f : F, m : M ) {
		f.addAttack(4, 7, s, function() {
			m.attackGroup(f, _GrMeteor, f.attack(Data.FIRE, 10));
		});
	}

	function _brave( f : F, m : M ) {
		f.timeMultiplier *= 0.85;
	}

	// --------------------------- WOOD ------------------------------------------

	function _endur( f : F, m : M ) {
		f.modDefense(Data.WOOD,2);
	}

	function _sauvag( f : F, m : M ) {
		f.assaultsBonus[Data.WOOD] += 5;
	}

	function _carapc( f : F, m : M ) {
		f.armor += 1;
	}

	/*2*/
	function _croiss( f : F, m : M ) {
		f.allAssaultsBonus += 1;
	}

	function _fouill( f : F, m : M ) {
		// permanent
	}

	function _tenace( f : F, m : M ) {
		f.minDamage++;
	}

	function _renfor( f : F, m : M ) {
		f.addEvent(3, 15, s, function() {
			var t = m.addMonster(Data.MONSTERS.list.rkrgns, f.side);
			m.invocated(f,t);
		});
	}

	function _vignes( f : F, m : M ) {
		var proba = 20;
		f.addEvent(2, proba, s, function() {
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if( t == null ) return;
			if( !t.hasStatus(_SFly) ) {
				t.time += (15 * M.TIMECOEF * t.initMultiplier).int();
				m.notify(t, _NInitDown );
			}
			m.effectGroup( f, [t], _GrVigne );
			
		});
	}

	function _boost1( f : F, m : M ) {
		// permanent
	}

	/*3*/
	function _largem( f : F, m : M ) {
		f.assaultsBonus[Data.WOOD] += 15;
	}

	function _cocon( f : F, m : M ) {
		// permanent
	}

	function _detect( f : F, m : M ) {
		// permanent
	}

	function _fouil2( f : F, m : M ) {
		// gather
	}

	function _charsm( f : F, m : M ) {
		// permanent
	}

	function _resmag( f : F, m : M ) {
		f.addEvent(1, 50, s, function() {
			m.effect(_SFAura( f.id, 0xAAFF00, 1 ));
			m.removeStatus( f, false );
		});
	}

	function _acroba( f : F, m : M ) {
		f.timeMultiplier *= 0.85;
	}

	function _instin( f : F, m : M ) {
		// permanent
	}

	function _etatpr( f : F, m : M ) {
		f.addEvent(3, 10, s, function() {
			m.effect(_SFAura( f.id, 0xAAFF00, 1 ));
			for( t in m.side(f.side) )
				m.removeStatus(t, false);
			for( t in m.side(!f.side) )
				m.removeStatus(t, true);
		});
	}

	function _prprec( f : F, m : M ) {
		f.addEvent(2, 10, s, function() {
			var tids = new List();
			m.history(_HDamagesGroup(f.id, tids, _GrHeal(0)));
			for( t in m.side(f.side) )
				if( t != f ) {
					var life = m.regenerate(t, null, 1+m.random(f.elements[Data.WOOD]));
					tids.add({ _tid : t.id, _life : life });
				}
		});
	}

	function _herita( f : F, m : M ) {
		f.assaultsBonus[Data.WOOD] += 12;
		f.armor += 1;
	}

	function _boost2( f : F, m : M ) {
		// permanent
	}

	/*4*/
	function _geant( f : F, m : M ) {
		f.allAssaultsBonus += 5;
		f.timeMultiplier *= 1.2;
	}

	function _archeo( f : F, m : M ) {
		// permanent
	}

	function _leader( f : F, m : M ) {
		// permanent
	}

	function _inge( f : F, m : M ) {
		// permanent
	}

	function _garde( f : F, m : M ) {
		for( t in m.side(f.side) )
			t.modDefense(Data.WOOD, 3);
	}

	function _esprit( f : F, m : M ) {
		f.addEvent(4, 20, s, function() {
			var t = m.addMonster(Data.MONSTERS.list.egrllz, f.side);
			m.status(t, _SIntang, DInfinite);
			m.invocated(f, t);
		});
	}

	function _coloss( f : F, m : M ) {
		f.allAssaultsBonus += 15;
		f.timeMultiplier *= 1.2;
	}

	// --------------------------- WATER -----------------------------------------

	function _percep( f : F, m : M ) {
		f.assaultsBonus[Data.WATER] += 4;
		f.perception = true;
		f.canFightIntang = true;
	}

	function _mutat( f : F, m : M ) {
		// permanent
	}

	function _canon( f : F, m : M ) {
		f.addAttack(1, 25, s, function() {
			m.attackSingle( f, _GrWaterCanon, f.attack(Data.WATER, 6) );
		});
	}

	/*2*/
	function _csourn( f : F, m : M ) {
		f.addAttack(3, 7, s, function() {
			var inf = m.attackFrom(f, _GSpecial(0x00CCFF, 0x000044), _LNormal, true);
			if( inf != null && inf.lost > 0 )
				m.lostFix(inf.target, _LSkull(1), if( inf.target.perception || inf.target.isBoss() ) 0 else Std.int(inf.target.life/2));
		});
	}

	function _peche1( f : F, m : M ) {
		// gather
	}

	function _poche( f : F, m : M ) {
		// permanent
	}

	function _karate( f : F, m : M ) {
		f.assaultsBonus[Data.WATER] += 10;
		f.powerBonus[Data.WATER] += 10;
	}

	function _gel( f : F, m : M ) {
		f.addAttack(1, 10, s, function() {
			var inf = m.attackSingle(f, _GrIce, f.attack(Data.WATER, 5));
			if( inf != null && !inf.esquive )
				m.status(inf.target, _SSlow, DMedium);
		});
	}

	function _douche( f : F, m : M ) {
		f.addEvent(1, 40, s, function() {
			m.attackGroup(f, _GrShower, f.attack(Data.WATER, 2));
		});
	}

	/*3*/
	function _cfatal( f : F, m : M ) {
		f.addAttack(4, 2, s, function() {
			var inf = m.attackFrom(f, _GSpecial(0xFF0000, 0x0000FF), _LNormal, true, _EBack);
			if( inf != null && inf.lost > 0 )
				m.lostFix(inf.target, _LSkull(2), if( inf.target.perception || inf.target.isBoss() ) 0 else inf.target.life);
		});
	}

	function _esousm( f : F, m : M ) {
		// permanent
	}

	function _peche2( f : F, m : M ) {
		// gather
	}

	function _marecg( f : F, m : M ) {
		m.effect( _SFSwamp(f.id)  );
		f.addEvent(6, 15, s, function() {
			for( t in m.side(!f.side) )
				m.status(t, _SSlow, DMedium);
		});
	}

	function _spitie( f : F, m : M ) {
		f.targetFilters[PFILTER_LOW_LIFE] = function(fl) {
			return selection(fl, function(f1,f2) { return f1.life - f2.life; });
		};
	}

	function _sumo( f : F, m : M ) {
		// permanent
	}

	function _griffp( f : F, m : M ) {
		f.afterAttack.add(function( inf : AttackInfos ) {
			if( inf.assault && inf.lost > 0 && inf.dmg[Data.WATER] > 0 )
				m.status(inf.target, _SPoison(14), DMedium);
		});
	}

	function _clone( f : F, m : M ) {
		var proba = 15;
		f.addEvent(8, proba, s, function() {
			var c = f.clone(m.generateId(), f.cloneDefaultLife);
			c.level = 1;
			m.addFighter(c);
			c.finalize();
			m.invocated(f,c);
		});
	}

	function _zero( f : F, m : M ) {
		f.defense[Data.FIRE] += 25;
	}

	function _petrif( f : F, m : M ) {
		f.addAttack(1, 10, s, function() {
			var targets = m.side(!f.side);
			var t = targets[m.random(targets.length)];
			if( t == null )
				m.cancel();
			m.cancelStatus(t, _SFly);
			m.cancelStatus(t, _SIntang);
			m.status(t, _SStoned, DMedium);
			if( t.isBoss() )
				m.cancelStatus(t,_SStoned);
		});
	}

	function _accup( f : F, m : M ) {
		m.status(f, _SHeal(1), DInfinite);
		f.afterDefense.add(function( inf : AttackInfos ) {
			if( inf.lost > 0 && inf.assault )
				m.lost(inf.from, _LNormal, 1);
		});
	}

	function _sappe( f : F, m : M ) {
		m.onStartFight.add(function() {
			for( e in f.events )
				switch( e.notify ) {
				case NObject(_):
					e.proba = Std.int( e.proba * 1.5 );
					if( e.proba > 100 ) e.proba = 100;
				default:
				}
		});
	}

	/*4*/
	function _esous2( f : F, m : M ) {
		// permanent
	}

	function _peche3( f : F, m : M ) {
		// gather
	}

	function _cuisin( f : F, m : M ) {
		// permanent
	}

	function _sangac( f : F, m : M ) {
		f.afterDefense.add(function( inf : AttackInfos ) {
			if( inf.lost > 0 && inf.assault && m.random(2) == 0 )
				m.lostFix(inf.from, _LAcid, Std.int(f.elements[Data.WATER] / 2));
		});
	}

	function _rayonk( f : F, m : M ) {
		f.addAttack(1, 20, s, function() {
			m.attackGroup(f, _GrLevitRay, f.attack(Data.WATER, 7));
			// casse les murs de boue
			for( f2 in m.side(!f.side) ) {
				m.effect( _SFMudWall( f2.id, true ) );
			}
		});
	}

	function _magasi( f : F, m : M ) {
		// permanent
	}

	/*5*/
	function _mnage( f : F, m : M ) {
		// permanent
	}

	// --------------------------- THUNDER ---------------------------------------

	function _celer( f : F, m : M ) {
		f.timeMultiplier *= 0.85;
	}

	function _focus( f : F, m : M ) {
		f.addEvent(1, 30, s, function() {
			m.effect(_SFFocus(f.id, 0xFFFF00));
			f.nextAssaultBonus += f.elements[Data.THUNDER];
		});
	}

	function _intell( f : F, m : M ) {
		// permanent
	}

	/*2*/
	function _eclair( f : F, m : M ) {
		f.timeMultipliers[Data.THUNDER] *= 0.6;
	}

	function _double( f : F, m : M ) {
		f.multiAttack *= 1.2;
	}

	function _concen( f : F, m : M ) {
		var old = null;
		f.afterAttack.add(function(i : AttackInfos) {
			if( i.assault && i.target.side != f.side )
				old = i.target;
		});
		f.targetFilters[PFILTER_SAME_TARGET] = function(fl) {
			if( fl.remove(old) )
				return [old];
			return fl;
		};
	}

	function _regen( f : F, m : M ) {
		// permanent
	}

	function _energy( f : F, m : M ) {
		// gather
	}

	function _premso( f : F, m : M ) {
		f.afterFight.add(function() {
			if( f.life > 0 && f.life < f.startLife )
				m.regenerate(f, _LHeal, 1);
		});
	}

	/*3*/
	function _embuch( f : F, m : M ) {
		f.time -= (7 * M.TIMECOEF * f.initMultiplier).int();
	}

	function _foudre( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			m.attackSingle(f, _GrLightning, f.attack(Data.THUNDER, 10));
		});
	}

	function _plandc( f : F, m : M ) {
		// permanent
	}

	function _danse( f : F, m : M ) {
		f.addAttack(3, 10, s, function() {
			for( i in 0...5 )
				m.attackFrom(f, _GSpecial(0xFFFFFF, 0xFFFF00), _LLightning, true, f.attack(Data.THUNDER, 3));
		});
	}

	function _kaos( f : F, m : M ) {
		f.assaultsBonus[Data.FIRE] += 6;
		f.assaultsBonus[Data.THUNDER] += 6;
	}

	function _gaia( f : F, m : M ) {
		f.modDefense(Data.THUNDER,3);
		f.modDefense(Data.WOOD,3);
	}

	function _hermet( f : F, m : M ) {
		f.addEvent(1, 30, s, function() {
			if( !m.status(f, _SShield, DInfinite) )
				m.cancel();
		});
	}

	function _puree( f : F, m : M ) {
		f.addEvent(3, 15, s, function() {
			m.effect(_SFAura(f.id, 0xFFFF00, 1));
			var ok = false;
			for( t in m.side(f.side) )
				if( m.removeStatus(t,false) )
					ok = true;
			if( !ok ) {
				m.ignoreAnnounce(); // hack : pop Aura
				m.ignoreAnnounce();
			}
		});
	}

	function _fiselt( f : F, m : M ) {
		// gather
	}

	function _crocs( f : F, m : M ) {
		f.allAssaultsBonus += 2;
	}

	function _medeci( f : F, m : M ) {
		f.afterFight.add(function() {
			if( f.life > 0 && f.life < f.startLife )
				m.regenerate(f, _LHeal, m.random(4));
		});
	}

	function _adrena( f : F, m : M ) {
		f.timeMultipliers[Data.THUNDER] *= 0.5;
	}

	/*4*/
	function _reinca( f : F, m : M ) {
		// permanent
	}

	function _crepus( f : F, m : M ) {
		f.addAttack(3, 5, s, function() {
			m.attackGroup(f, _GrCrepuscule, f.customAttack(6, 0, 0, 6, 0));
		});
	}

	function _aubefe( f : F, m : M ) {
		f.addAttack(3, 10, s, function() {
			var pv = f.elements[Data.THUNDER] * 2 + f.elements[Data.WOOD] * 2;
			var tids = new List();
			m.history(_HDamagesGroup(f.id, tids, _GrHeal(0)));
			for( t in m.side(f.side) ) {
				var life = m.regenerate(t, null, 1+m.random(pv));
				tids.add({ _tid : t.id, _life : life });
			}
		});
	}

	function _benede( f : F, m : M ) {
		f.addEvent(3, 25, s, function() {
			for( t in m.side(f.side) )
				m.status(t, _SBless, DMedium);
		});
	}

	function _marcha( f : F, m : M ) {
		// permanent
	}

	function _branca( f : F, m : M ) {
		f.afterFight.add(function() {
			var poss = new Array();
			for( f2 in m.side(f.side) )
				if( f != f2 && f2.life > 0 && f2.life < f2.startLife )
					poss.push(f2);
			if( poss.length > 0 )
				m.regenerate(poss[m.random(poss.length)],_LHeal,1+m.random(5));
		});
	}

	/*5*/
	function _archcr( f : F, m : M ) {
		// permanent
	}

	function _archgn( f : F, m : M ) {
		// permanent
	}

	function _pretre( f : F, m : M ) {
		// permanent
	}

	// --------------------------- AIR -------------------------------------------

	function _agili( f : F, m : M ) {
		f.assaultsBonus[Data.AIR] += 5;
	}

	function _strate( f : F, m : M ) {
		// sort elements based on medium ennemies defense
		var defs = new Array();
		for( i in 0...5 )
			defs[i] = { elt : i, v : -f.elements[i]*5 };
		for( f in m.side(!f.side) )
			for( i in 0...5 )
				defs[i].v += Math.ceil(f.defense[i]);
		defs.sort(function(a,b) { return a.v - b.v; });
		for( i in 0...5 )
			f.elementsOrder[i] = defs[i].elt;
	}

	function _mistra( f : F, m : M ) {
		f.addAttack(1, 15, s, function() {
			m.attackGroup(f, _GrMistral, f.attack(Data.AIR,3));
		});
	}

	function _envol( f : F, m : M ) {
		f.addAttack(1, 30, s, function() {
			m.attackFrom(f, _GNormal, _LNormal, true);
			if( f.life > 0 )
				m.status(f, _SFly, DInfinite);
		});
	}

	/*2*/
	function _esquiv( f : F, m : M ) {
		f.esquive *= 1.1;
	}

	function _sesqui( f : F, m : M ) {
		f.superEsquive *= 1.15;
	}
	
	function _saut( f : F, m : M ) {
		f.canFightFlying = true;
	}

	function _analys( f : F, m : M ) {
		f.targetFilters[PFILTER_BEST_RATIO] = function(fl) {
			var e = f.currentElement();
			return selection(fl,function(f1,f2) { return Std.int(f1.defense[e] - f2.defense[e]); });
		}
	}

	function _cueill( f : F, m : M ) {
		// gather
	}

	function _tornad( f : F, m : M ) {
		f.addAttack(5, 3, s, function() {
			for( t in m.side(!f.side) )
				m.cancelStatus(t,_SFly);
			m.attackGroup( f, _GrTornade, f.attack(Data.AIR,10) );
		});
	}

	function _taichi( f : F, m : M ) {
		f.assaultsBonus[Data.AIR] += 15;
		f.timeMultipliers[Data.AIR] *= 1.2;
	}

	/*3*/
	function _elasti( f : F, m : M ) {
		f.assaultsBonus[Data.AIR] += 10;
		f.modDefense(Data.AIR,3);
	}

	function _disque( f : F, m : M ) {
		f.addAttack(8, 7, s, function() {
			m.attackSingle( f, _GrDisc, f.attack(Data.AIR,12) );
		});
	}

	function _aplong( f : F, m : M ) {
		f.addAttack(5, 20, s, function() {
			f.nextAssaultBonus += 2 * f.elements[Data.AIR];
			m.attackFrom(f, _GOver, _LAir, true, _EDrop);
		});
	}

	function _furtiv( f : F, m : M ) {
		f.modDefense(Data.AIR, 2);
		f.modDefense(Data.WATER, 2);
		f.modDefense(Data.THUNDER, 2);
	}

	function _specia( f : F, m : M ) {
		f.elementsOrder.remove(f.elementsOrder[4]);
	}

	function _talona( f : F, m : M ) {
		f.allAssaultsBonus += 2;
	}

	function _nuaget( f : F, m : M ) {
		f.addAttack(3, 10, s, function() {
			m.effect( _SFCloud(f.id,0,0x008800) );
			for( t in m.side(!f.side) )
				m.status(t, _SPoison(f.elements[Data.AIR]), DMedium);
		});
	}

	function _oeil( f : F, m : M ) {
		// gather
	}

	function _formev( f : F, m : M ) {
		var s = s;
		f.defenses.add(function(inf) {
			if( m.random(100) < 6 ) {
				m.announce(f,s);
				m.status(f, _SIntang, DShort);
			}
		});
	}
	
	function _ventvf( f : F, m : M ) {
		f.addEvent(2,15,s,function() {
			m.status(f, _SQuick, DShort);
		});
	}
	
	function _eveil( f : F, m : M ) {
		f.timeMultipliers[Data.AIR] *= 1.2;
	}
	
	function _paumej( f : F, m : M ) {	// paume ejectable
		f.addAttack(2, 15, s, function() {
			f.nextAssaultMultiplier *= 2;
			var inf = m.attackFrom(f, _GSpecial(0xFFFFFF, 0x00FFFF), _LNormal, true, _EEject);
			if( inf != null && inf.lost > 0 ) {
				f.time += (15 * M.TIMECOEF * f.initMultiplier).int();
				m.notify(f, _NInitDown );
			}
		});
	}

	/*4*/
	function _tnoir( f : F, m : M ) { // trou noir
		var escape = false;
		var proba = 3;
		f.addAttack(10, proba, s, function() {
			if( !m.result(f.side).canEscape || m.result(f.side).rules.cancelTrouNoir ) {
				if( !escape )
					m.text(Text.get.cant_escape);
				escape = true;
				return;
			}
			
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if ( t == null ) return;
			
			if ( false == t.canEscape ) {
				m.object( t, Data.OBJECTS.list.agrav );
				escape = true;
			} else {
				var inf = m.attackSingle(f, _GrHole, f.attack(Data.AIR, 0), t);
				if( inf != null && !inf.esquive && !inf.target.isBoss() ) {
					m.removeFromFight(inf.target);
				}
			}
		});
	}

	function _maitrl( f : F, m : M ) {
		for( f in m.side(f.side) )
			f.canFightFlying = true;
	}

	function _prof( f : F, m : M ) {
		// permanent
	}

	function _halein( f : F, m : M ) {
		f.afterAttack.add(function(inf) {
			if( inf.lost > 0 && inf.assault )
				m.status(inf.target, _SPoison(f.elements[Data.AIR]), DLong);
		});
	}

	function _sdevie( f : F, m : M ) {
		noPoison(f);
	}

	function _medsol( f : F, m : M ) {
		f.timeMultipliers[Data.AIR] *= 1.5;
		f.modDefense(Data.AIR, 3);
	}

	/*5*/
	function _medtra( f : F, m : M ) {
		f.timeMultipliers[Data.AIR] *= 1.5;
		f.modDefense(Data.AIR, 6);
	}

	/*6*/
	function _formee( f : F, m : M ) {
		m.status(f, _SIntang, DInfinite);
	}

	// --------------------------- VOID -----------------------------------------

	function _crush( f : F, m : M ) {
		f.cancelArmor = true;
	}

	function _rock( f : F, m : M ) {
		f.markAsRock = true;
	}

	function _ccorne( f : F, m : M ) {
		f.nextAssaultMultiplier *= 1.2;
	}

	function _ninja( f : F, m : M ) {
		f.esquive *= 1.1;
	}

	function _coque( f : F, m : M ) {
		f.armor += 1;
	}

	function _carap( f : F, m : M ) {
		var s = s;
		f.defenses.add(function(inf) {
			if( inf.assault && m.random(100) < 5 ) {
				m.announce(f, s);
				inf.lost -= 5;
				if( inf.lost < 0 ) inf.lost = 0;
			}
		});
	}

	function _napoma( f : F, m : M ) {
		//IMPLEMENTED IN INVENTORY.hx
	}
	
	// ------------------------ DEMONS -----------------------------------------

	function _demwnk( f : F, m : M ) {
		for( i in 0...6 )
			f.defense[i] += 6;
	}

	function _demgrl( f : F, m : M ) {
		f.allAssaultsBonus += 5;
	}

	function _dempig( f : F, m : M ) {
		f.addAttack(2, 20, s, function() {
			m.attackSingle(f, _GrCharge, f.customAttack(5, 3, 0, 0, 0), _GSpecial(0xFFFF00, 0xFF0000));
		});
	}

	function _demwan( f : F, m : M ) {
		f.addEvent(5, 5, s, function() {
			var tl = m.side(f.side);
			m.effect(_SFAura( f.id, 0xFFFF00, 1 ));
			var tids = new Array();
			m.effect(_SFSpeed( f.id, tids ));
			for( f in tl ) {
				tids.push(f.id);
				m.status(f, _SQuick, DMedium);
			}
		});
	}

	function _dempla( f : F, m : M ) {
		f.maxEnergy = (1.25 * f.maxEnergy).int();
		f.recoveryMultiplier *= 1.25;
	}
	
	function _demkab( f : F, m : M ) {
		if( m.getPosition().zone == 9 ) {
			f.allAssaultsBonus += 30;
		}
	}
	
	function _demmou( f : F, m : M ) {
		if( m.getPosition().zone == 4 ) {
			f.allAssaultsBonus += 30;
		}
	}
	
	// ------------------------ SPHERES -----------------------------------------

	function _sphere( f : F, m : M ) {
		// dummy
	}

	function _braser( f : F, m : M ) {
		f.addEvent(1, 25, s, function() {
			m.attackGroup(f, _GrShower2(1), f.attack(Data.FIRE, 3));
		});
	}

	function _detona( f : F, m : M ) {
		f.addEvent(1, 10, s, function() {
			if( f.life <= 5 )
				m.cancel();
	
			var tl = m.side(!f.side).concat(m.side(f.side));
			tl.remove(f);// on applique pas l'effet sur ce Dinoz
			
			m.effect(_SFAura2(f.id, 0xFF0000, null, 1));
			m.lost(f, _LBurn(5), 5);
			// on utilise le multiplicateur d'init du lanceur, pour le pénaliser dans son gain
			var value = (15 * M.TIMECOEF * f.initMultiplier);
			for( t in tl ) {
				t.time += (value * t.initMultiplier).int();
			}
			m.notify( f, _NInitUp );
		});
	}
	
	function _pheart( f : F, m : M ) {
		// regen
	}

	function _launch( f : F, m : M ) {
		f.addAttack(3, 15, s, function() {
			m.attackSingle(f, _GrProjectile("gland"), f.attack(Data.WOOD, 5));
		});
	}

	function _gratte( f : F, m : M ) {
		// gather
	}

	function _beigne( f : F, m : M ) {
		f.addEvent(4, 10, s, function() {
			m.effect(_SFAura2(f.id,0x00FF00,null,0));
			f.nextAssaultMultiplier *= 2.0;
		});
	}

	function _vital( f : F, m : M ) {
		// life
	}

	function _moigno( f : F, m : M ) {
		f.addAttack(4, 8, s, function() {
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if( t != null ) {
				m.effect(_SFAttach(t.id, "fxOndeFocus"));
				m.lost(t, _LWater, 0);// fx
				t.time += (25 * M.TIMECOEF * t.initMultiplier).int();
				m.notify(t, _NInitDown );
			}
		});
	}

	function _deluge( f : F, m : M ) {
		f.addAttack(5, 5, s, function() {
			var tl = m.side(!f.side);
			var linf = m.attackGroup(f, _GrDeluge, f.attack(Data.WATER, 10));
			for( t in tl ) {
				t.time += (8 * M.TIMECOEF * t.initMultiplier).int();
			}
			m.notifyGroup(tl.list(), _NInitDown );
		});
	}

	function _reflex( f : F, m : M ) {
		f.time -= (5 * M.TIMECOEF);
	}

	function _sclair( f : F, m : M ) {
		f.addAttack(3, 10, s, function() {
			m.attackGroup(f, _GrChainLightning, f.attack(Data.THUNDER, 10), 3);
		});
	}

	function _surviv( f : F, m : M ) {
		var sflag = true;
		var s = s;
		f.onKill.push(function() {
			if( !sflag )
				return true;
			f.life = 0;
			sflag = false;
			m.announce(f,s);
			m.effect(_SFAttach(f.id,"fxSurvivor"));
			return m.regenerate(f,_LHeal,12) <= 0;
		});
	}
	
	function _aiguil( f : F, m : M ) {
		f.addEvent(1, 15, s, function() {
			m.attackSingle(f, _GrProjectile("aiguillon"), f.attack(Data.AIR, 3));
		});
	}

	function _aurap( f : F, m : M ) {
		var s = s;
		var tl = new Array();
		f.afterDefense.add(function(inf:AttackInfos) {
			if( inf.assault && inf.lost > 0 && !inf.from.hasStatus(_SPoison(0)) ) {
				m.announce(f,s);
				var pos = m.historyPosition();
				if( !m.status(inf.from,_SPoison(10),DMedium) && m.historyPosition() == pos ) {
					if( tl.remove(inf.from.id) )
						m.ignoreAnnounce();
					tl.push(inf.from.id);
				}
			}
		});
	}

	function _hypno( f : F, m : M ) {
		var used = false;
		var cycles = 4;
		
		f.addAttack(7, 5, s, function() {
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if( t == null || t.isBoss() || used || tl.length == 1 || m.escaped.has(t) || m.getDeads().has(t) )
				m.cancel();
			
			used = true;
			if( !m.result(f.side).rules.onHypnose(f,t) )
				return;
				
			var cancelHypnose = t.hypnotized;
			m.setSide(t, !t.side);
			t.hypnotized = !t.hypnotized;
			m.effect(_SFAura2(f.id, 0x0000FF, null, 2));
			m.effect(_SFHypnose(f.id, t.id));
			
			if( cancelHypnose ) {
				var ref = m.side( t.side )[0];
				if( ref != null )
					m.history( _HGoto( t.id, ref.id, _GNormal ) );
				m.history( _HFlip( t.id ) );
			} else {
				function onCycle() {
					cycles --;
					if( cycles <= 0 ) {
						if( t.life > 0 && !m.escaped.has(t) && t.hypnotized ) {
							m.setSide( t, !t.side );
							t.hypnotized = !t.hypnotized;
							var ref = m.side( t.side )[0];
							if( ref != null )
								m.history( _HGoto( t.id, ref.id, _GNormal ) );
							m.history( _HFlip( t.id ) );
						}
						m.removeCycleListener( onCycle );
					}
				}
				m.addCycleListener( onCycle );
			}
		});
	}
	
	// ------------------------ DOUBLES -----------------------------------------

	function _multi( f : F, m : M ) {
		// nothing
	}

	function _barmor( f : F, m : M ) {
		f.armor += 3;
	}

	function _melemt( f : F, m : M ) {
		// elements
	}

	function _sprint( f : F, m : M ) {
		f.time -= (6 * M.TIMECOEF);
	}

	function _vendet( f : F, m : M ) {
		f.counterAttack *= 1.2;
	}

	function _increv( f : F, m : M ) {
		for( i in 0...6 )
			f.defense[i] += 2;
	}

	function _choc( f : F, m : M ) {
		f.assaultsBonus[Data.WOOD] += f.elements[Data.THUNDER];
		f.assaultsBonus[Data.THUNDER] += f.elements[Data.WOOD];
	}

	function _secous( f : F, m : M ) {
		f.addAttack(2, 20, s, function() {
			m.attackGroup(f,_GrTremor,f.customAttack(0,4,0,0,4),function(f:Fighter) return !f.hasStatus(_SFly));
		});
	}
	
	function _elctly( f : F, m : M ) {
		for( f in m.side(f.side) )
			f.timeMultiplier *= 0.95;
	}
	
	function _bulle( f : F, m : M ) {
		var bulle = false;
		var armor = (f.elements[Data.WATER] + f.elements[Data.AIR]) / (f.elements[Data.WATER] + f.elements[Data.AIR] + f.elements[Data.FIRE] + f.elements[Data.THUNDER] + f.elements[Data.WOOD]);
		if(  armor < 0.3 ) armor = 0.3;
		f.defenses.add(function(inf:AttackInfos) {
			if( !inf.invoc && !inf.assault && !inf.from.isBoss() && inf.dmg[Data.WOOD] == 0 && inf.dmg[Data.VOID] == 0 ) {
				var lost = ( (1 - armor) * inf.lost ).int();
				inf.lost = if(  lost == 0 ) 1 else lost;
				bulle = true;
			}
		});
		f.afterDefense.add(function(inf) {
			if( bulle ) {
				m.effect(_SFAttach(f.id,"fxBubble"));
				bulle = false;
			}
		});
	}

	function _surcha( f : F, m : M ) {
		f.multiAttack *= 1.15;
	}

	// ------------------------ MONSTRES -----------------------------------------

	var renfort_proba : Float;
	function _renfrt( f : F, m : M ) {
		if( renfort_proba == null )
			renfort_proba = 10;
		else {
			renfort_proba -= 3.5; // [10,7,3]
			if( renfort_proba <= 0 )
				return;
		}
		var done = false;
		f.addAttack(1,Math.ceil(renfort_proba),s,function() {
			if( done )
				m.cancel();
			done = true;
			m.addMonster(f.monster,f.side);
		});
	}

	var wormrf_proba : Float;
	function _wormrf( f : F, m : M ) {
		if( wormrf_proba == null )
			wormrf_proba = 10;
		else {
			wormrf_proba -= 3.5; // [10,7,3]
			if( wormrf_proba <= 0 )
				return;
		}
		var done = false;
		f.addAttack(1, Math.ceil(wormrf_proba), s, function() {
			if( done )
				m.cancel();
			done = true;
			m.addMonster(Data.MONSTERS.list.wormy,f.side);
		});
	}

	function _absorb( f : F, m : M ) {	// gluon
		f.addAttack(1, 25, s, function() {
			var inf = m.attackFrom( f, _GSpecial(0xFFFFFF,0x66FF00), _LWater, true, [0,0,0,0,0,10] );
			if( inf != null )
				m.regenerate(f,_LHeal,inf.lost);
		});
	}

	function _fregen( f : F, m : M ) { // geant vert
		f.addEvent(1, 60, s, function() {
			if( f.startLife == f.life )
				m.cancel();
			m.regenerate( f, _LHeal, Std.int(f.startLife * 0.1) );
		});
	}

	function _goblin( f : F, m : M ) {
		f.counterAttack *= 1.5;
		f.multiAttack *= 1.3;
	}

	function _electr( f : F, m : M ) {	// anguilloz
		f.afterDefense.add(function(inf) {
			if( inf.assault && inf.lost > 0 )
				m.lost(inf.from,_LLightning,1+m.random(3));
		});
	}

	function _coqdur( f : F, m : M ) {
		f.timeMultiplier *= 0.4;
	}

	function _envol2( f : F, m : M ) {
		f.addAttack(1, 60, s, function() {
			m.attackFrom(f,_GNormal,_LNormal,true);
			if( f.life > 0 )
				m.status(f,_SFly,DInfinite);
		});
	}

	function _intang( f : F, m : M ) {
		f.addEvent(1, 30, s, function() {
			if( f.hasStatus(_SIntang) )
				m.cancel();
			m.status(f,_SIntang,DShort);
		});
	}

	function _resist( f : F, m : M ) {
		var s = s;
		f.defenses.add(function(inf) {
			if( !inf.assault ) {
				m.announce(f,s);
				inf.lost = 0;
			}
		});
	}

	function _protct( f : F, m : M ) {
		f.defenses.add(function(inf) {
			if( inf.assault )
				inf.lost = Math.ceil(inf.lost / 3);
		});
	}

	function _sentin( f : F, m : M ) {
		f.counterAttack *= 1.9;
		f.addAttack(0, 100, s, function() {
			m.ignoreAnnounce();
		});
	}

	function _comet( f : F, m : M ) {
		f.timeMultiplier *= 1.5;
		f.elements[Data.WOOD] = 15;
		f.addAttack(1, 30, s, function() {
			m.attackGroup(f,_GrMeteor,[20,0,0,0,0,30]);
		});
	}

	function _vener( f : F, m : M ) {
		f.addAttack(1, 100, s, function() {
			m.ignoreAnnounce();
			m.attackGroup(f,_GrMeteor,[50,0,0,0,50,0]);
		});
	}
	
	function _grizou( f : F, m : M ) {
		f.addAttack(1, 100, s, function() {
			m.ignoreAnnounce();
			m.attackGroup( f, _GrAnim("superattack"), [0,0,0,0,0,f.elements[Data.VOID]]);
		});
	}
	
	//just for fx
	function _morph( f : F, m : M ) {
		m.onStartFight.add( function() {
			m.effect( _SFAnim(f.id, "morph") );
			m.history( _HPause(30 * M.TIMECOEF) );
		} );
	}
	
	function _grizhs( f : F, m : M ) {
		f.onKill.add( function() {
			m.ignoreAnnounce();
			m.history( _HFx( _SFRay(f.id) ) );
			return true;
		} );
	}
	
	function _rapaca( f : F, m : M ) {
		f.addAttack(3, 25, s, function() {
			m.ignoreAnnounce();
			for( t in m.side(!f.side) )
				m.cancelStatus(t,_SFly);
			m.attackGroup( f, _GrTornade, f.attack(Data.AIR,40) );
		});
		
		f.addAttack(1, 100, s, function() {
			m.ignoreAnnounce();
			m.attackSingle(f,_GrProjectile("lame"),f.attack(Data.AIR,25));
		});
	}
	
	function _quake( f : F, m : M ) {
		var p = f.elements[f.elementsOrder[0]] * 5;
		if( p < 40 )
			p = 40;
		f.addAttack(2, 25, s, function() {
			m.attackGroup(f, _GrJumpAttack("shake"), [0,0,0,0,0,p], function(f:Fighter) return !f.hasStatus(_SFly));
		});
	}
	
	function _bite( f : F, m : M ) {
		f.addAttack(1, 15, s, function() {
			m.attackFrom(f,_GSpecial(0x0000FF,0),_LNormal,true,[0,0,0,0,0,7]);
		});
	}

	function _gtour( f : F, m : M ) {
		var att = 10;
		f.time += (30 * M.TIMECOEF);
		f.timeMultiplier *= 3;
		f.elements = [att,att,att,att,att,att];
		f.canFightFlying = f.canFightIntang = true;
		var e = m.random(5);
		f.elementsOrder = [e];
		f.addEvent(1,50,s,function() {
			var old = e;
			do {
				e = m.random(5);
			} while( e == old );
			f.elementsOrder = [e];
		});
		f.defenses.add(function(inf) {
			inf.lost = if( inf.dmg[e] > 0 ) m.random(3) + 29 else 0;
		});
	}

	function _off( f : F, m : M ) {
		f.time += (100000);
		m.history(_HStatus(f.id,_SSleep));
		f.defenses.add(function(inf) {
			inf.lost = 1;
		});
	}

	function _scorp( f : F,  m : M ) {
		f.esquive *= 1.6;
		f.timeMultiplier *= 1.5;
		noPoison(f);
		f.addAttack(1, 20, s, function() {
			var inf = m.attackFrom(f,_GSpecial(0x800080,0xFF00FF),_LPoison,true);
			if( inf.target != null && inf.lost > 0 )
				m.status(inf.target,_SPoison(5),DInfinite);
			var att = f.attacks[0];
			att.proba >>= 1;
		});
	}

	function _worm( f : F, m : M ) {
		var regen = null;
		f.canFightFlying = true;
		f.life = f.startLife >> 1;
		// absorb water damages
		f.defenses.add(function(inf) {
			if( inf.dmg[Data.WATER] == 0 )
				return;
			regen = inf.lost;
			inf.lost = 0;
		});
		f.afterDefense.push(function(inf) {
			if( regen != null ) {
				m.regenerate(f,_LWater,regen);
				regen = null;
			}
		});
	}

	function _escap( f : F, m : M ) {
		f.addAttack(10, 100, s, function() {
			if ( m.escaped.has(f) || m.getDeads().has(f) ) m.cancel();
			
			m.history(_HEscape(f.id));
			m.removeFromFight(f);
		});
	}

	function _coward( f : F, m : M ) {
		f.addAttack(10, 20, s, function() {
			if ( m.escaped.has(f) || m.getDeads().has(f) ) m.cancel();
			
			m.history(_HEscape(f.id));
			m.removeFromFight(f);
		});
	}

	function vol( f : F, m : M, p : Int ) {
		var tot = 0;
		f.addAttack(1, p, s, function() {
			var inf = m.attackFrom(f,_GNormal,_LObject,true);
			if( inf.target == null || inf.lost == 0 )
				return;
			var g = (m.random(5)+8) * 10;
			tot += g;
			m.result(!f.side).gold -= g;
			var obj = Data.OBJECTS.list.gold;
			m.history(_HObject(f.id,g + obj.name,obj.id));
			f.attacks[0].proba = 0; // no more
			f.addAttack(1, 60, Data.SKILLS.list.escap, function() {
				m.history(_HEscape(f.id));
				m.removeFromFight(f);
			});
		});
		// give back stolen gold
		f.afterDefense.add(function(_) {
			if( tot == 0 )
				return;
			if( f.life <= 0 ) {
				m.result(!f.side).gold += tot;
				tot = 0;
			}
		});
	}

	function _brig1( f : F, m : M ) {
		f.timeMultiplier *= 1.7;
		vol(f,m,10);
	}

	function _brig2( f : F, m : M ) {
		f.timeMultiplier *= 0.7;
		f.time -= (15 * M.TIMECOEF); // embuscade
		f.multiAttack *= 1.3;
		vol(f,m,5);
	}

	function _brig3( f : F, m : M ) {
		vol(f,m,30);
	}

	function _worm2( f : F, m : M ) {
		f.timeMultiplier *= 0.6;
		f.addAttack(1, 100, s, function() {
			m.ignoreAnnounce();
			m.attackSingle(f,_GrProjectile("sand"),f.attack(Data.VOID,5));
		});
	}

	function _cactus( f : F, m : M ) {
		f.esquive *= 1.3;
		f.timeMultiplier *= 1.3;
		var count = 1;
		f.afterDefense.add(function(inf) {
			if( inf.assault && inf.lost > 0 )
				m.lost(inf.from,_LPoison,count++);
		});
	}

	function _igor( f : F, m : M ) {
		f.esquive *= 1.5;
		f.timeMultiplier *= 3;
		f.addAttack(1, 30, s, function() {
			for( f in m.side(f.side) )
				m.status(f,_SIntang,DShort);
		});
	}

	function _yakuzi( f : F, m : M ) {
		f.multiAttack *= 1.25;
		f.addEvent(8, 15, s, function() {
			var c = f.clone(m.generateId(),1);
			c.level = 1;
			m.addFighter(c);
			c.finalize();
		});
	}

	function _ggoupi( f : F, m : M ) {
		var s = this.s;
		noPoison(f);
		f.afterDefense.add(function(inf:AttackInfos) {
			if( inf.assault && inf.lost > 0 && m.random(5) == 0 ) {
				m.announce(f,s);
				m.status(inf.from,_SPoison(3),DShort);
			}
		});
	}
	
	function _amazon( f : F, m : M ) {
		f.addEvent(3, 20, s, function() {
			if( m.getEnv() == null || !m.getEnv().playing || m.getEnv().getCaster().side != f.side )
				m.setEnv( new fight.skills.Amazonie(f, m) );
		});
	}
	
	function _cendre( f : F, m : M ) {
		f.addEvent(3, 20, s, function() {
			if( m.getEnv() == null || !m.getEnv().playing || m.getEnv().getCaster().side != f.side )
				m.setEnv( new fight.skills.Cendres(f, m) );
			else
				m.ignoreAnnounce();
		});
	}
	
	function _abysse( f : F, m : M ) {
		f.addEvent(3, 20, s, function() {
			if( m.getEnv() == null || !m.getEnv().playing || m.getEnv().getCaster().side != f.side )
				m.setEnv( new fight.skills.Abysse(f, m) );
			else
				m.ignoreAnnounce();
		});
	}
	
	function _stelme( f : F, m : M ) {
		f.addEvent(3, 20, s, function() {
			if( m.getEnv() == null || !m.getEnv().playing || m.getEnv().getCaster().side != f.side )
				m.setEnv( new fight.skills.StElme(f, m) );
			else
				m.ignoreAnnounce();
		});
	}
	
	function _ourano( f : F, m : M ) {
		f.addEvent(3, 20, s, function() {
			if( m.getEnv() == null || !m.getEnv().playing || m.getEnv().getCaster().side != f.side )
				m.setEnv( new fight.skills.Ouranos(f, m) );
			else
				m.ignoreAnnounce();
		});
	}
	/// --------
	
	function _elhelp( f : F, m : M ) {
		f.time -= (100 * M.TIMECOEF);
		f.addAttack(1, 100, s, function() {
			m.ignoreAnnounce();
			m.announce(f,Data.SKILLS.list.sclair);
			m.attackGroup(f,_GrChainLightning,[0,0,0,0,200,0]);
			m.history(_HEscape(f.id));
			m.removeFromFight(f);
		});
	}

	function _bmaudt( f : F, m : M ) {
		var mlist = new Array();
		f.addEvent(1, 100, s, function() {
			var tl = new Array();
			for( f in m.side(!f.side) )
				if( f.dino != null && !Lambda.has(mlist,f.dino) )
					tl.push(f);
			var t = tl[m.random(tl.length)];
			if( t == null ) {
				f.attacks = [];
				m.cancel();
			}
			m.lost(t,_LSkull(2.5),Math.ceil(t.life/2));
			mlist.push(t.dino);
		});
		m.onEndFight.add(function() {
			if( !m.res.won )
				return;
			for( d in mlist )
				if( !d.hasSkill(Data.SKILLS.list.sdevie) && d.addEffect(Data.EFFECTS.list.maudit) )
					m.text(Text.format(Text.get.maudit_notice,{ name : d.name }));
		});
	}

	function _attall( f : F, m : M ) {
		f.addAttack(1, 100, s, function() {
			m.ignoreAnnounce();
			var t = null;
			for( f2 in m.side(f.side) )
				if( f.monster == f2.monster && f2.time < Manager.INFINITE ) {
					if( t == null )
						t = m.attackFrom(f2,_GNormal,_LNormal,true).target;
					else
						m.attackTarget(f2,t,_GNormal,_LNormal,null,null,true);
				}
		});
	}

	function _rminit( f : F, m : M ) {
		for ( f2 in m.side(f.side) ) {
			f2.time = 1;
		}
		for ( f2 in m.side(!f.side) ) {
			f2.time = 0;
		}
	}

	function _healg( f : F, m : M ) {
		f.addEvent(1, 100, s, function() {
			m.ignoreAnnounce();
			for( f in m.side(f.side) )
				m.regenerate(f,_LHeal,1);
			for( f2 in m.getDeads() )
				if( f2.side == f.side )
					m.regenerate(f2,_LHeal,1);
		});
	}

	function _mantoo( f : F, m : M ) {
		noPoison(f);
		f.addAttack(3, 15, s, function() {
			m.effect( _SFCloud(f.id,0,0x405800) );
			for( t in m.side(!f.side) )
				m.status(t,_SPoison(3),DMedium);
		});
	}

	function _mosqui( f : F, m : M ) {
		f.timeMultiplier *= 0.6;
		f.esquive *= 1.2;
		f.addEvent(10, 50, s, function() {
			m.ignoreAnnounce();
			var tl = m.side(f.side).copy();
			while( tl.length > 0 ) {
				var t = tl[m.random(tl.length)];
				tl.remove(t);
				if( !t.hasStatus(_SIntang) ) {
					m.effect( _SFAura( f.id, 0xFFFFFF, 1 )  );
					m.status(t,_SIntang,DMedium);
					return;
				}
			}
		});
		f.addEvent(5, 30, s, function() {
			m.ignoreAnnounce();
			m.effect( _SFAura( f.id, 0x608000, 0 )  );
			m.addMonster(Data.MONSTERS.list.minim2,f.side);
		});
	}

	function _mugard( f : F, m : M ) {
		f.defenses.add(function(inf) {
			if( inf.dmg[Data.THUNDER] > 0 )
				inf.lost = 0;
		});
		f.afterDefense.add(function(inf) {
			if( inf.dmg[Data.THUNDER] > 0 )
				m.attackGroup(f,_GrChainLightning,inf.dmg,1);
			if( inf.dmg[Data.FIRE] > 0 )
				m.status(f,_SFlames,DShort);
		});
	}

	function _frutox( f : F, m : M ) {
		var first = true;
		f.time -= (20 * M.TIMECOEF);
		f.addEvent(10, 60, s, function() {
			if( first ) first = false else m.ignoreAnnounce();
			for( f2 in m.side(f.side) ) {
				m.effect( _SFAura(f2.id,0xFFCC3A, 1) );
				f2.time -= (5 * M.TIMECOEF * f2.initMultiplier).int();
				f.time += (3 * M.TIMECOEF * f.initMultiplier).int();
			}
		});
	}

	function _cuzbos( f : F, m : M ) {
		f.timeMultiplier *= 1.5;
		f.allAssaultsBonus += 25;
		f.time -= (100 * M.TIMECOEF);
		noPoison(f);
		m.onStartFight.add(function() m.text(Data.TEXT.cuzboss_begin,f));
		f.onKill.add(function() {
			m.text(Data.TEXT.cuzboss_end,f);
			var found = false;
			for( f in m.side(!f.side) )
				if( f.dino != null ) {
					m.effect( _SFAura(f.id,0,1) );
					f.dino.addEffect(Data.EFFECTS.list.cuzmal);
					found = true;
				}
			if( !found )
				m.regenerate(f, _LHeal, 300);
			return found;
		});
		f.addAttack(1, 20, s, function() {
			var pow = f.attack(f.currentElement(true), 8);
			m.attackGroup(f,_GrCrepuscule,pow);
		});
		f.addAttack(2, 10, s, function() {
			m.ignoreAnnounce();
			m.regenerate(f,_LHeal,50);
		});
	}

	function _grotox( f : F, m : M ) {
		f.timeMultiplier *= 0.4;
		f.addAttack(2, 30, s, function() {
			m.attackGroup(f,_GrTremor,[0,0,0,0,0,60],function(f:Fighter) return !f.hasStatus(_SFly));
		});
		// patch for simulation
		if( m.getPosition() != Data.MAP.list.mfpalc ) {
			f.onKill.add(function() {
				for( f in m.side(f.side) )
					m.removeFromFight(f);
				return false;
			});
			for( i in 0...3 )
				m.addMonster(Data.MONSTERS.list.frutox);
		}
	}

	function _infini( f : F, m : M ) {
		var s = s;
		m.res.calculate = function() {}; // can't win
		f.onKill.add(function() {
			m.announce(f,s);
			var count = m.side(f.side).length;
			if( count < 6 )
				m.addMonster(f.monster);
			if( count < 5 )
				m.addMonster(f.monster);
			return true;
		});
	}

	function _ffrutx( f : F, m : M ) {
		var first = true;
		f.time -= (15 * M.TIMECOEF);
		f.flyAfterAttack = true;
		f.addEvent(10, 60, s, function() {
			var tl = m.side(f.side).copy();
			while( tl.length > 0 ) {
				var t = tl[m.random(tl.length)];
				tl.remove(t);
				if( m.status(t, _SFly, DInfinite) )
					return;
			}
			m.cancel();
		});
	}

	function _singmu( f : F, m : M ) {
		f.multiAttack *= 1.5;
		f.timeMultiplier *= 0.3;
	}
	
	//NIMBAO
	function _ecuren( f : F, m : M ) {
		f.multiAttack *= 1.4;
		f.timeMultiplier *= 0.7;
	}
	
	function _gromst( f : F, m : M ) {
		f.counterAttack *= 1.6;
		f.timeMultiplier *= 1.1;
	}
	
	function _cyclo( f : F, m : M ) {
		f.esquive *= 1.15;
		f.multiAttack *= 1.3;
	}
	
	function _lapouf( f : F, m : M ) {
		f.esquive *= 1.05;
		f.multiAttack *= 1.05;
		f.counterAttack *= 1.1;
		f.timeMultiplier *= 0.5;
	}
	
	// SAINT VALENTIN
	function _febrez( f : F, m : M ) {
		var c = function( f2: Fighter) {  if(  f2.dino != null) return Std.int(0.05 * f2.dino.maxLife + .5) else return 0; };
		f.afterAttack.add( function( inf : AttackInfos ) {
			if( inf.lost > 0 && inf.target.dino != null ) {
				m.popHistory();
				m.history( _HDamages( f.id, inf.target.id, 0, _LNormal, null ) );
				m.regenerate( inf.target, _LHeal, c(inf.target) );
			}
		});
	}
	
	// -------------------- INVOCATIONS -------------------
	function _invoc( f : F, m : M ) {
		//empty
	}
	
	function _herco( f:F, m:M ) {
		var s = s;
		f.addAttack(4, 15, s, function() {
			if( f.invocations <= 0 ) {
				m.cancel();
				return;
			}
			f.invocations --;
			m.attackGroup(f, _GrInvoc("herco"), f.customAttack(10,10,10,10,10));
		});
	}
	
	function _vulcan( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.attackGroup( f, _GrInvoc("vulcan"), f.attack(Data.FIRE, 20) );
		});
	}
	
	function _ifrit( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.history(_HDamagesGroup(f.id, new List(), _GrInvoc("ifrit")));
			var dl = m.side(f.side).copy();
			for( d in dl ) {
				d.defense[Data.FIRE] += 20;
			}
			m.notifyGroup( dl.list(), _NFire );
		});
	}
	
	function _salama( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.attackSingle( f, _GrInvoc("salama"), f.attack(Data.FIRE, 30) );
		});
	}
	
	function _bluewh( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.history(_HDamagesGroup(f.id, new List(), _GrInvoc("bluewh")));
			var dl = m.side(f.side).list();
			for( d in dl ) {
				d.defense[Data.WATER] += 20;
			}
			m.notifyGroup( dl, _NWater );
		});
	}
	
	function _leviat( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.attackGroup( f, _GrInvoc("leviat"), f.attack(Data.WATER, 20) );
		});
	}
	
	function _ondine( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.attackSingle( f, _GrInvoc("ondine"), f.attack(Data.WATER, 30) );
		});
	}
	
	function _louga( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.attackGroup( f, _GrInvoc("louga"), f.attack(Data.WOOD, 30) );
		});
	}
	
	function _fairy( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.history(_HDamagesGroup(f.id, new List(), _GrInvoc("fairy")));
			var dl = m.side(!f.side);
			for( d in dl) {// on prend la logique inverse, plus simple à réaliser
				d.time += (10 * M.TIMECOEF * d.initMultiplier).int();
			}
			m.notifyGroup( dl.list(), _NInitDown );
		});
	}
	
	function _yggdra( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.history(_HDamagesGroup(f.id, new List(), _GrInvoc("yggdra")));
			var dl = m.side(f.side);
			for( d in dl ) {
				d.defense[Data.WOOD] += 20;
			}
			m.notifyGroup( dl.list(), _NWood );
		});
	}
	
	function _raijin( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.attackGroup( f, _GrInvoc("raijin"), f.attack(Data.THUNDER, 20) );
		});
	}
	
	function _golem( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.history(_HDamagesGroup(f.id, new List(), _GrInvoc("golem")));
			var dl = m.side(f.side);
			for( d in dl ) {
				d.defense[Data.THUNDER] += 20;
			}
			m.notifyGroup( dl.list(), _NThunder );
		});
	}
	
	function _goku( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.history(_HDamagesGroup(f.id, new List(), _GrInvoc("goku")));
			var dl = m.side(f.side);
			for( d in dl ) {
				d.esquive *= 1.2;
			}
			m.notifyGroup( dl.list(), _NSnake );
		});
	}
	
	function _djinn( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.attackGroup(f, _GrInvoc("djinn"), f.attack(Data.AIR, 20));
		});
	}
	
	function _fujin( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			var canUse = true;
			for ( f2 in m.side(f.side) )
				if ( f2.hasUsedFujin )
					canUse = false;
			
			if( !canUse || f.invocations <= 0 ) {
				m.cancel();
				return;
			}
			
			f.invocations --;
			f.hasUsedFujin = true;
			m.history(_HDamagesGroup(f.id, new List(), _GrInvoc("fujin")));
			var dl = m.side(f.side);
			for( d in dl ) {
				d.timeMultiplier *= 0.5;
			}
			m.notifyGroup( dl.list(), _NQuick );
		});
	}
	
	function _totem( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.attackSingle(f, _GrInvoc("totem"), f.attack(Data.AIR, 30));
		});
	}
	
	function _boudda( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.history(_HDamagesGroup(f.id, new List(), _GrInvoc("boudda")));
			var dl = m.side(f.side);
			for( d in dl ) {
				for( el in Data.ELEMENTS )
					d.defense[el.id] += 10;
			}
			m.notifyGroup(dl.list(), _NStrong );
		});
	}
	
	function _hades( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.history(_HDamagesGroup(f.id, new List(), _GrInvoc("hades")));
			var dl = m.side(!f.side);
			for( t in dl ) {
				m.status( t, _SPoison(14), DMedium );// poison
				t.timeMultiplier *= 1.5;// ralentissement
			}
			m.notifyGroup(dl.list(), _NSlow );
		});
	}
	
	function _reiruc( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 ) {
				//m.text( Text.get.cant_invoc );
				m.cancel();
				return;
			}
			f.invocations --;
			m.history( _HDamagesGroup( f.id, new List(), _GrInvoc("reiruc") ) );
			var tl = m.side(!f.side);
			for( t in tl ) {
				t.energy = 0;
			}
			m.notifyGroup(tl.list(), _NDown);
		});
	}
	
	// ------------------- QUETZU SPECIFICS -------------------------- \\
	
	//feu N2
	function _propul( f : F, m : M ) {
		f.timeMultipliers[Data.FIRE] *= 0.7;
		f.elements[Data.FIRE] -= 2;
	}
	
	//feu N3
	function _grifff( f : F, m : M ) {
		f.afterAttack.add( function( inf : AttackInfos ) {
			if( inf.target != null && inf.assault && !inf.esquive ) {
				m.status(inf.target, _SBurn(inf.target.elements[Data.FIRE]), DMedium);
			}
		});
	}
	
	//eau N2
	function _ecaill( f : F, m : M ) {
		f.armor += 2;
	}
	
	//eau N3
	function _skin( f : F, m : M ) {
		f.esquive *= 1.1;
		f.timeMultipliers[Data.WATER] *= 1.15;
	}
	
	//foudre N4
	function _quetza( f : F, m : M ) {
		f.addAttack(4, 10, s, function() {
			if( f.invocations <= 0 )
				m.cancel();
			f.invocations --;
			m.attackGroup( f, _GrInvoc("quetza"), f.attack(Data.THUNDER, 40));
		});
	}
	
	// ----------------------------- OTHERS ------------------------------- \\
	
	function _friend( f : F, m : M ) {
		var scenario = Data.SCENARIOS.list.friend;
		var p = db.Scenario.get( scenario, App.user ) + 1;
		db.Scenario.set( scenario, App.user, p );
		//
		var caller = null;
		var leave = p >= 10;
		for( f2 in m.result(f.side).fighters ) {
			if( f2.dino == null ) continue;
			if( f2.dino.friend == null ) continue;
			var n = Data.MONSTERS.getId(f2.dino.friend).name;
			if( n == f.name ) {
				caller = f2;
				break;
			}
		}
		if( leave ) {
			caller.dino.friend = null;
			caller.dino.update();
		}
		//
		noPoison(f);
		//
		if( leave ) {
			f.beforeTurn.add( function() {
				switch( caller.dino.friend ) {
					case Data.MONSTERS.list.mandr2.mid :
						m.text(Text.format(Text.get.mandragore_combat_friend_annonce));
						m.announceText(f, Text.format(Text.get.mandragore_combat_friend_skill) );
					default:
				}
				for( t in m.side(!f.side) )
					m.attackTarget(f, t, _GNormal, _LNormal, null, null, true);
			});
		}
		//
		m.onEndFight.add( function() {
			if( leave ) {
				switch( caller.dino.friend ) {
					case Data.MONSTERS.list.mandr2.mid :
						m.text(Text.format(Text.get.mandragore_combat_friend_fin));
					default:
				}
			}
		});
	}
	
	function _mbao(f : F, m : M ) {
		m.onEndFight.add( function() {
			var showText = false;
			for( d in m.res.dinoz ) {
				if( d.f.life < d.f.startLife ) {
					m.regenerate(d.f, _LHeal, d.f.startLife - d.f.life );
					showText = true;
				}
			}
			if( showText ) m.text(Data.TEXT.bao_heal);
		});
	}
	
	
	/********************   LEVEL 50+   **********************/
	function _lvlup(f : F, m : M) {
	}
	
	function _pgbrai(f : F, m : M) {
		f.assaultsBonus[Data.FIRE] += 20;
	}
	
	function _arfeu(f : F, m : M) {
		f.defense[Data.WOOD] += 20;
	}
	
	function _rouge(f : F, m : M ) {
		if( m.getPosition().zone == 1 ) {
			f.allAssaultsBonus += 20;
		}
	}
	
	function _magma(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
		f.assaultsBonus[Data.FIRE] += 5;
	}
	
	function _crigue(f : F, m : M ) {
		//already sorted after finalize call
		var s = s, f = f, m = m;
		f.addAttack(7, 10, s, function() {
			var eltsAttacks = f.attacks.filter( function( fevt ) return fevt.notify != s ).array();
			eltsAttacks.sort(function( a1, a2 ) return a2.notify.level - a1.notify.level );
			var attack = eltsAttacks[0];
			if( attack == null ) return;
			m.effect( _SFGenerate( f.id, 0xFF0000, 2, 1 ) );
			f.nextAttack = attack;
		});
	}
	
	function _fiebru(f : F, m : M ) {
		f.multiAttack *= 1.3;
	}

	function _recroc(f : F, m : M ) {
		f.addAttack(7, 15, s, function() {
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if( t == null ) return;
			t.attacksFilters[ SFILTER_SPHERE_WOOD ] = function( pAttacks:TAAttack ):TAAttack {
				return pAttacks.filter( function( a ) { return  !(a.notify.isSphere && [a.notify.elt, a.notify.elt2, a.notify.elt3].has(Data.WOOD)); } ).array();
			};
			m.history( _HFx( _SFAttachAnim( t.id, "_receptacle", "wood" ) ) );
		});
	}
	
	function _acclam(f : F, m : M ) {
		f.addAttack(6, 15, s, function() {
			var dl = m.side(f.side).list();
			for( t in dl ) {
				t.recoveryMultiplier *= 1.3;
			}
			m.notifyGroup( dl, _NUp );
		});
	}
	
	function _extenu(f : F, m : M ) {
		f.addAttack(4, 15, s, function() {
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if( t == null ) return;
			t.recoveryMultiplier *= 0.75;
			m.notify( t, _NDown );
		});
	}
	
	function _phonix(f : F, m : M ) {
		var sflag = true;
		var s = s;
		f.onKill.push(function() {
			if( sflag == false )
				return true;
			f.life = 0;
			sflag = false;
			//
			m.announce(f, s);
			m.effect(_SFLeaf(f.id, "_plume"));
			m.regenerate(f, _LHeal, 12);
			// INIT
			var tl = m.side(!f.side).concat(m.side(f.side));
			tl.remove(f);// on applique pas l'effet sur ce Dinoz
			var value = (10 * M.TIMECOEF * f.initMultiplier);
			for( t in tl ) {
				t.time += (value * t.initMultiplier).int();
			}
			m.notify( f, _NInitUp );
			return false;
		});
	}
	
	function _artemi(f : F, m : M ) {
		//IMPLEMENTED in GATHER.hx
	}
	
	function _cendr2(f : F, m : M ) {
		_cendre(f, m);
	}
	
	function _joker(f : F, m : M ) {
		var s = s;
		var success = Std.random(2) == 0;
		m.onStartFight.add( function() {
			m.announce(f, s);
			m.effect( _SFRandom( f.id, "joker", success ) );
		});
		if( !success ) {
			f.timeMultiplier *= 1.25;
		} else {
			f.timeMultiplier *= 0.75;
		}
	}
	
	function _protei(f : F, m : M ) {
		f.maxEnergy = Std.int( f.maxEnergy * 1.3 );
	}
	
	function _coustr(f : F, m : M ) {
		f.assaultsBonus[Data.WOOD] += 20;
		f.defense[Data.WATER] += 20;
	}
	
	//TODO CHECK
	function _vert(f : F, m : M ) {
		if( m.getPosition().zone == 3 ) {
			f.allAssaultsBonus += 20;
		}
	}
	
	function _lifsrc(f : F, m : M ) {
		var s = s;
		f.afterDefense.add( function(inf : AttackInfos ) {
			if( inf.assault && inf.lost > 0 && m.random(5) == 0 ) {
				m.announce(f, s);
				//
				var life = Std.int( 1 + 0.05 * inf.from.life);//5%
				m.lost( inf.from, _LSkull(1), life);
				m.regenerate( f, _LHeal, life );
			}
		} );
	}
	
	function _videne(f : F, m : M ) {
		var s = s;
		f.afterDefense.add( function(inf : AttackInfos ) {
			if( inf.assault && inf.lost > 0 && m.random(5) == 0 ) {
				m.announce(f, s);
				inf.from.recoveryMultiplier *= 0.85;
				m.notify( inf.from, _NDown );
			}
		} );
	}
	
	function _acilac(f : F, m : M) {
		f.maxEnergy = Std.int( f.maxEnergy * 0.85 );
	}
	
	function _boudin(f : F, m : M) {
		var protecting = new IntHash();
		var s = s;
		f.addEvent( 9, 10, s, function() {
			var tl = m.side(f.side);
			tl = Lambda.array(Lambda.filter(tl, function(f2) return f2.dinoRef == null ));
			if( tl.length < 2 ) m.cancel();
			tl.sort( function(f1, f2) { return f1.life - f2.life; } );
			if( tl[0] == f ) tl.shift();
			var t = tl[0];
			
			m.notify(t, _NShield);
			if( protecting.exists(t.id) ) return;
			
			protecting.set(t.id, t);
			t.onTargeted.add( function( target ) {
				if ( f.life > 0 ) {
					m.history(_HGoto(f.id,target.id,_GNormal));
					return f;
				} else {
					return target;
				}
			} );
		} );
	}
	
	function _forcon(f : F, m : M) {
		if( f.minAssaultDamage < 10 )
			f.minAssaultDamage = 10;
	}
	
	function _lanroc(f : F, m : M) {
		f.addAttack( 7, 10, s, function() {
			m.attackSingle(f, _GrProjectile("rocher", null, 0.13), f.attack(Data.WOOD, 10));
		} );
	}
	
	function _oxygen(f : F, m : M) {
		f.maxEnergy = (f.maxEnergy * 1.2).int();
	}
	
	function _lifstr(f : F, m : M) {
		f.time -= (20 * M.TIMECOEF * f.initMultiplier).int();
	}
	
	function _champo(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
	}
	
	function _courba(f : F, m : M ) {
		f.addEvent( 5, 10, s, function() {
			var opp = m.side( !f.side );
			var t = opp[Std.random(opp.length)];
			if( t == null ) return;
			t.maxEnergy = (t.maxEnergy * 0.7).int();
			m.logMaxEnergy([t]);
			m.effect( _SFAttachAnim(t.id, "_enduranceOff") );
		});
	}
	
	function _berser(f : F, m : M ) {
		f.addEvent( 8, 10, s, function() {
			f.events = [];
			f.attacks = [];
			m.effect( _SFBlink( f.id, 0xEC0000, 70 ) );
			f.assaultMultiplier = 2;
		} );
	}
	
	function _peafer(f : F, m : M ) {
		// IMPLEMENTED IN SKILLS.hx
	}
	
	function _mudwal(f : F, m : M ) {
		var wall = false, protection = 0;
		var s = s;
		var defaultProtection = 30;
		
		//fonction à ajouter puis supprimer de la liste des defenses du fighter
		function mudDefense(inf) {
			if( !wall ) {
				wall = true;
				protection = defaultProtection;
				//ANNOUNCE
				m.announce(f, s);
				//EFFECT
				m.effect( _SFMudWall( f.id, false ) );
			}
			protection -= inf.lost;
			if( protection < 0 )
				inf.lost = -protection;
			else
				inf.lost = 0;
		}
		
		f.addEvent( 8, 5, s, function() {
			m.ignoreAnnounce();
			if( wall ) {
				protection = defaultProtection;
				return;
			}
			//
			f.defenses.add(mudDefense);
			//
			f.afterDefense.add(function(inf) {
				if( wall && protection <= 0 ) {
					m.effect( _SFMudWall( f.id, true ) );
					f.defenses.remove(mudDefense);
					wall = false;
				}
			});
		});
	}
	
	function _peaaci(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
	}
	
	function _sharig(f : F, m : M ) {
		var copied = new List();
		var proba = 1.2 * M.PROBA_MULTIPLIER;
		var skill = s;
		m.onAnnounce.add( function(f2, s2) {
			if( f2 != f && f2.side != f.side && !f2.isBoss() && m.test(proba) && !copied.has(s2) ) {
				m.announce( f, skill );
				SkillsImpl.applySkill(s2, f, m);
				m.notify( f, _NSharignan );
				copied.add(s2);
			}
		});
	}
	
	function _amazo2(f : F, m : M ) {
		_amazon(f, m);
	}
	
	function _recaqu(f : F, m : M ) {
		f.addAttack(7, 15, s, function() {
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if( t == null ) return;
			t.attacksFilters[ SFILTER_SPHERE_WATER ] = function( pAttacks:TAAttack ):TAAttack {
				return pAttacks.filter( function( a ) { return  !(a.notify.isSphere && [a.notify.elt, a.notify.elt2, a.notify.elt3].has(Data.WATER)); } ).array();
			};
			m.history( _HFx( _SFAttachAnim( t.id, "_receptacle", "water" ) ) );
		});
	}
	
	function _mueac(f : F, m : M ) {
		f.defense[Data.THUNDER] += 20;
	}
	
	function _tourbi(f : F, m : M ) {
		f.assaultsBonus[Data.WATER] += 20;
	}
	
	function _bandie(f : F, m : M ) {
		f.addEvent( 8, 10, s, function() {
			if( f.life <= 0 || m.escaped.has(f) ) return;
			var opp = m.side(!f.side);
			var t = opp[Std.random(opp.length)];
			if( t == null ) m.cancel();
			if( t.life <= 0 || m.escaped.has(t) ) m.cancel();
			t.invocations = -100;// on ne peut pas le recharger
			m.notify( t, _NSilence );
		});
	}
	
	function _odivi(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
	}
	
	function _clepto(f : F, m : M ) {
		var s = s, f = f, m = m;
		var opp = m.side(!f.side);
		var t = opp[Std.random(opp.length)];
		if( t == null ) return;
		t.restrictions.push( Restriction.RObject );
		m.onStartFight.add( function() {
			m.announce(f, s);
			m.notify(t, _NNoUse);
		} );
	}
	
	function _bleu(f : F, m : M ) {
		if( m.getPosition().zone == 2 ) {
			f.allAssaultsBonus += 20;
		}
	}
	
	function _efflu(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
	}
	
	function _nemo(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
	}
	
	function _carabl(f : F, m : M ) {
		f.armor += 10;
		f.timeMultiplier *= 1.2;
	}
	
	function _diete(f : F, m : M ) {
		f.addEvent( 8, 15, s, function() {
			var opp = m.side( !f.side );
			var t = opp[Std.random(opp.length)];
			m.status(t, _SMonoElt(Std.random(6)), DMedium);
		});
	}
	
	function _abyss2(f : F, m : M ) {
		this._abysse(f, m);
	}
	
	function _gamma(f : F, m : M ) {
		f.allAssaultsBonus += 5;
		//life bonus implemented in SKILLS.hx
		f.time += (10 * f.timeMultiplier * M.TIMECOEF).int();
	}
	
	function _hyperv(f : F, m : M ) {
		var done = false;
		f.addAttack( 8, 15, s, function() {
			if( done ) {
				m.cancel();
				return;
			}
			done = true;
			var tl = m.side( !f.side );
			m.history(_HDamagesGroup(f.id, tl.map( function(f) return {_tid:f.id, _life:0} ), _GrRafale("partWind", 10, 2.5 )));
			for( of in tl ) {
				of.maxEnergy = (of.maxEnergy * 0.8).int();
				m.effect( _SFAttachAnim(of.id, "_enduranceOff") );
			}
			m.logMaxEnergy(tl);
		});
	}
	
	function _thera(f : F, m : M ) {
		var f = f, m = m, skill = s;
		var proba =  1.15 * M.PROBA_MULTIPLIER;
		var canCopyHeal = true;
		//
		m.onNextTurn.add( function(f) {
			canCopyHeal = true;
		});
		
		m.result(!f.side).rules.onHeal.add(function(t, life) {
			if( f.life > 0 && canCopyHeal && m.test(proba) ) {
				canCopyHeal = false;
				m.announce(f, skill);
				m.regenerate(f, _LHeal, life);
			}
		});
	}
	
	function _vitmar(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
	}
	
	function _rectes(f : F, m : M ) {
		f.addAttack(7, 15, s, function() {
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if( t == null ) return;
			t.attacksFilters[ SFILTER_SPHERE_THUNDER ] = function( pAttacks:TAAttack ) : TAAttack {
				return pAttacks.filter( function( a ) { return  !(a.notify.isSphere && [a.notify.elt, a.notify.elt2, a.notify.elt3].has(Data.THUNDER)); } ).array();
			};
			m.history( _HFx( _SFAttachAnim( t.id, "_receptacle", "thunder" ) ) );
		});
	}
	
	function _barelc(f : F, m : M ) {
		f.defense[Data.AIR] += 20;
	}
	
	function _zeus(f : F, m : M ) {
		f.assaultsBonus[Data.THUNDER] += 20;
	}
	
	function _jaune(f : F, m : M ) {
		if( m.getPosition().zone == 5 ) {
			f.allAssaultsBonus += 20;
		}
	}
	
	function _flash(f : F, m : M ) {
		f.addEvent( 7, 15, s, function() {
			var tl = m.side(!f.side);
			var t = tl[Std.random(tl.length)];
			if( t == null ) return;
			m.status( t, _SDazzled(3), DMedium );
		});
	}
	
	function _crampe(f : F, m : M ) {
		f.addEvent( 7, 10, s, function() {
			f.energy -= 10;
			f.recoveryMultiplier *= 0.85;
			m.notify( f, _NDown );
		});
	}
	
	function _batsup(f : F, m : M ) {
		f.time += (15 * f.timeMultiplier * M.TIMECOEF).int();
	}
	
	function _einste(f : F, m : M ) {
		//IMPLEMENTED in SKILLS.hx
	}
	
	//ajoute une 2eme fois la compétence d'invocation => double la proba
	function _oracle(f : F, m : M ) {
		if( f.dino == null ) return;
		for( skill in f.dino.getSkills() ) {
			var dskill = Data.SKILLS.getId(skill.sid);
			if( dskill.type == data.Skill.SkillType.SInvocation ) {
				SkillsImpl.applySkill(dskill, f, m);
				return;
			}
		}
	}
	
	function _soumor(f : F, m : M ) {
		f.maxEnergy = (f.maxEnergy * 1.1).int();
	}
	
	function _recaer(f : F, m : M ) {
		f.addAttack(7, 15, s, function() {
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if( t == null ) return;
			t.attacksFilters[ SFILTER_SPHERE_AIR ] = function( pAttacks:TAAttack ):TAAttack {
				return pAttacks.filter( function( a ) { return  !(a.notify.isSphere && [a.notify.elt, a.notify.elt2, a.notify.elt3].has(Data.AIR)); } ).array();
			};
			m.history( _HFx( _SFAttachAnim( t.id, "_receptacle", "air" ) ) );
		});
	}
	
	function _stelm2(f : F, m : M ) {
		_stelme(f, m);
	}
	
	function _remane(f : F, m : M ) {
		f.esquive *= 1.2;
	}
	
	function _sticar(f : F, m : M ) {
		f.recoveryMultiplier *= 1.2;
	}
	
	function _sange(f : F, m : M ) {
		f.defense[Data.FIRE] += 20;
	}
	
	function _ouraga(f : F, m : M ) {
		f.assaultsBonus[Data.AIR] += 20;
	}
	
	function _blanc(f : F, m : M ) {
		if( m.getPosition().zone == 8 ) {
			f.allAssaultsBonus += 20;
		}
	}
	
	function _flagel(f : F, m : M ) {
		f.recoveryMultiplier *= 0.85;
	}
	
	function _doufac(f : F, m : M ) {
		var s = s;
		var success = Std.random(2) == 0;
		m.onStartFight.add( function() {
			m.announce(f, s);
			m.effect( _SFRandom( f.id, "face", success ) );
		});
		if( !success ) {
			f.time += (10 * f.timeMultiplier * M.TIMECOEF).int();
		} else {
			f.time -= (10 * f.timeMultiplier * M.TIMECOEF).int();
		}
	}
	
	function _maicor(f : F, m : M ) {
		f.recoveryMultiplier *= 1.25;
	}
	
	function _anaero(f : F, m : M ) {
		f.maxEnergy = (f.maxEnergy * 0.75).int();
	}
	
	function _twino5(f : F, m : M ) {
		f.maxEnergy = (f.maxEnergy * 1.5).int();
	}
	
	function _ouran2(f : F, m : M ) {
		this._ourano(f, m);
	}
	
	function _londuo(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
	}
	
	function _surhad(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
	}
	
	function _recthe(f : F, m : M ) {
		f.addAttack(7, 15, s, function() {
			var tl = m.side(!f.side);
			var t = tl[m.random(tl.length)];
			if( t == null ) return;
			t.attacksFilters[ SFILTER_SPHERE_FIRE ] = function( pAttacks:TAAttack ):TAAttack {
				return pAttacks.filter( function( a ) { return  !(a.notify.isSphere && [a.notify.elt, a.notify.elt2, a.notify.elt3].has(Data.FIRE)); } ).array();
			};
			m.history( _HFx( _SFAttachAnim( t.id, "_receptacle", "fire" ) ) );
		});
	}
	
	function _sylphe(f : F, m : M ) {
		var escape = false;
		var proba = 10;
		var s = s;
		f.addAttack(10, proba, s, function() {
			if( !m.result(f.side).canEscape || m.result(!f.side).rules.cancelSylfide ) {
				if( !escape )
					m.text(Text.get.cant_escape_opponents);
				escape = true;
				return;
			}
			
			var tl = m.side(!f.side);
			var t = tl[Std.random(tl.length)];
			if( t == null ) return;
			if( !t.canEscape || t.isBoss() ) {
				if( !t.canEscape  )
					m.object( t, Data.OBJECTS.list.agrav );
				escape = true;
				return;
			}
			
			var l = new List();
			l.add({ _tid : t.id, _life : 0 });
			m.history(_HDamagesGroup(f.id, l, _GrSylfide));
			m.removeFromFight(t);
		});
	}
	
	function _mutin(f : F, m : M ) {
		f.addEvent(10, 10, s, function() {
			var tl = m.side(!f.side);
			var clones = tl.filter( function(f) return f.dinoRef != null );
			for( c in clones ) {
				m.setSide(c, !c.side);
				m.effect(_SFAura2(c.id, 0x0000FF, null, 2));
			}
		});
	}
	
	function _messie(f : F, m : M ) {
		//IMPLEMENTED IN SKILLS.hx
	}
	
	function _qigong(f : F, m : M ) {
		var proba =  1.3 * M.PROBA_MULTIPLIER;
		var s = s;
		//m.onStartFight.add( function() {
		//	m.announce(f, s);
		//} );
		f.afterAttack.add( function( inf:AttackInfos)  {
			if( inf.assault && inf.lost > 0 && !inf.esquive)  {
				if( m.test(proba) ) {
					m.announce(f, s);
					m.history( _HFx( _SFAttachAnim( f.id, "_qigong" ) ) );
					var f = inf.from;
					var t = inf.target;
					//
					var ener = t.energy;
					t.energy -= ener;
					f.energy += ener;
					//
					m.notify( f, _NUp );
					m.notify( t, _NDown );
					//
					m.logEnergy([f, t]);
				}
			}
		} );
	}
	
	function _maicol(f : F, m : M) {
		f.addEvent( 10, 15, s, function() {
			if( f.cantEsquiveAssault ) m.cancel();
			f.cantEsquiveAssault = true;
		});
	}
	
	function _cognon(f : F, m : M) {
		f.addAttack(8, 15, s, function() {
			var targets = m.side(!f.side);
			var t = targets[m.random(targets.length)];
			if( t == null )
				m.cancel();
			m.attackTarget(f, t, _GNormal, _LNormal, null, null, true);
			m.cancelStatus(t, _SFly);
			m.cancelStatus(t, _SIntang);
			m.status(t, _SStun, DMedium);
			if( t.isBoss() )
				m.cancelStatus(t,_SStun);
		});
	}
	
	function _mama(f:F, m:M) {
		var s = s;
		f.addAttack(6, 15, s, function() {
			if( f.invocations <= 0 ) {
				m.cancel();
				return;
			}
			
			f.invocations --;
			m.attackGroup(f, _GrInvoc("bigma"), f.customAttack(3, 3, 3, 3, 3));
			for ( ff in m.all) {
				if ( ff.life > 0 ) ff.energy = 0;
				//will be loggued to the client by the manager 
			}
			for( ff in m.side(!f.side) ) {
				m.cancelStatus(ff, _SFly);
				m.cancelStatus(ff, _SIntang);
				m.status(ff, _SStun, DMedium);
			}
		});
	}
}
