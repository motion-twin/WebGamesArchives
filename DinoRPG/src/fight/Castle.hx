package fight;
import Fight;

class Castle {

	var manager : Manager;
	public var castle : db.ClanCastle;
	public var buildings : List<data.Building>;
	public var time : Int;
	public var life : Int;
	public var destroyed : Bool;
	public var helper : Null<data.Monster>;
	public var ground : Int;
	public var armor : Int;

	var fixDamages : Null<Int>;
	
	public function new(m,c, damages) {
		this.manager = m;
		this.fixDamages = damages;
		m.onStartFight.add(onStartFight);
		m.onEndFight.add(onEndFight);
		castle = c;
		life = c.life;
		buildings = c.getCurrentBuildings();
		// remove buildings that have been upgraded
		for( b in buildings ) {
			var r = b.require;
			while( r != null ) {
				buildings.remove(r);
				r = r.require;
			}
		}
		// apply building effect
		ground = 0;
		armor = 0;
		var cfg = db.GConfig.getWar();
		time = (cfg == null) ? 0 : cfg.attackTime;
		for( b in buildings )
			switch( b ) {
			case Data.BUILDINGS.list.camp1:
				helper = Data.MONSTERS.list.goupi;
			case Data.BUILDINGS.list.camp2:
				helper = Data.MONSTERS.list.flam;
			case Data.BUILDINGS.list.camp3:
				helper = Data.MONSTERS.list.korgon;
			case Data.BUILDINGS.list.slow1:
				ground = 1;
			case Data.BUILDINGS.list.slow2:
				ground = 2;
			case Data.BUILDINGS.list.slow3:
				ground = 3;
			case Data.BUILDINGS.list.def1:
				armor = 1;
			case Data.BUILDINGS.list.def2:
				armor = 2;
			case Data.BUILDINGS.list.def3:
				armor = 3;
			}
		destroyed = false;
	}
	
	function onStartFight() {
		var S = Data.SPELLS.list;
		var me = this;
		var dup = new Hash();
		for( cs in castle.getSpells() ) {
			var s = Data.SPELLS.getId(cs.sid);
			if( dup.exists(s.id) )
				continue;
			dup.set(s.id,true);
			switch( s ) {
			case S.antib:
				var first = true;
				manager.res.rules.onBalance = manager.res.other.rules.onBalance = function(f) {
					if( !first ) return true;
					first = false;
					cs.delete();
					me.manager.announceText(f,s.name);
					return false;
				};
			case S.nowat:
				manager.text(s.name);
				cs.delete();
				for( f in manager.side(true).concat(manager.side(false)) ) {
					f.modDefense(Data.WATER,-f.elements[Data.WATER]);
					f.elements[Data.WATER] = 0;
				}
			case S.nofdr:
				manager.text(s.name);
				cs.delete();
				for( f in manager.side(true).concat(manager.side(false)) ) {
					f.modDefense(Data.THUNDER,-f.elements[Data.THUNDER]);
					f.elements[Data.THUNDER] = 0;
				}
			case S.invoc:
				cs.delete();
				for( f in manager.side(false).copy() ) {
					manager.history(_HEscape(f.id));
					manager.removeFromFight(f);
				}
				var t = manager.side(true)[0];
				if( t != null )
					manager.text("???",t);
				manager.text(s.name);
				var t = manager.addMonster(Data.MONSTERS.list.vener2,false);
				manager.invocated(t,t);
			case S.antihy:
				var firstL = true;
				var firstR = true;
				var oldL = manager.result(false).rules.onHypnose;
				var oldR = manager.result(true).rules.onHypnose;
				
				manager.result(false).rules.onHypnose = function(f,t) {
					if ( !firstL ) return true;
					if ( oldR != null && !oldR(f, t) ) return false;
					
					firstL = false;
					cs.delete();
					var m = me.manager;
					m.announceText(t,s.name);
					m.setSide(f,t.side);
					f.hypnotized = !f.hypnotized;
					m.effect(_SFHypnose(t.id,f.id));
					return false;
				};
				
				manager.result(true).rules.onHypnose = function(f,t) {
					if ( !firstR ) return true;
					if ( oldL != null && !oldL(f, t) ) return false;
					
					firstR = false;
					cs.delete();
					var m = me.manager;
					m.announceText(t,s.name);
					m.setSide(f,t.side);
					f.hypnotized = !f.hypnotized;
					m.effect(_SFHypnose(t.id,f.id));
					return false;
				};
			case S.noatt:
				var att = manager.side(true);
				if( att.length > 1 ) {
					var f = att[Std.random(att.length)];
					if( manager.isActive(f) ) {
						manager.announceText(f,s.name);
						manager.history(_HEscape(f.id));
						manager.removeFromFight(f);
						cs.delete();
					}
				}
			}
		}
	}
	
	function onEndFight() {
		var S = Data.SPELLS.list;
		var defenders = manager.side(false);
		var hasDino = null;
		for( f in defenders )
			if( f.dino != null && f.life < f.startLife ) {
				hasDino = f;
				break;
			}
		if( hasDino != null ) {
			var heals = [{ s : S.heal3, l : 100 },{ s : S.heal2, l : 30 },{ s : S.heal1, l : 10 }];
			for( h in heals )
				if( castle.useSpell(h.s) ) {
					manager.announceText(hasDino,h.s.name);
					for( f in defenders )
						if( f.dino != null )
							manager.regenerate(f,_LHeal,h.l);
					break;
				}
		}
	}

	public function getSlowTime() {
		return DateTools.minutes([10,15,20,30,8*60][ground]);
	}

	public function attack( f : Fighter ) {
		if( f.hypnotized )
			return;
		for( i in 0...f.castleAttacks ) {
			if( destroyed )
				return;
			var dmg = 0;
			if( fixDamages == null ) {
				for( i in 0...5 )
					dmg += f.elements[i];
				dmg = Math.round( Math.pow(dmg, 0.7) / 2 ) - [0,1,2,3][armor];
			} else {
				dmg = fixDamages;
				if( f.dino == null ) // si pas un dinoz
					dmg = Std.int(.5 * dmg);
			}
			if( dmg < 0 ) dmg = 0;
			if( dmg > life ) dmg = life;
			life -= dmg;
			manager.attackCastle(f, dmg);
			if( castle != null ) castle.life = life;
			if( life == 0 ) destroyed = true;
		}
	}

	public function infos( fight ) : CastleInfos {
		var color = 0;
		if( castle.mana != null ) {
			if( castle.hasSpell(Data.SPELLS.list.paint1) ) color = 1;
			if( castle.hasSpell(Data.SPELLS.list.paint2) ) color = 2;
		}
		return {
			_life : life,
			_max : castle.maxLife,
			_armor : armor,
			_cage : if( helper == null ) null else if( helper.gfx != null ) helper.gfx else helper.frame,
			_ground : ground,
			_repair : if( fight ) 0 else castle.repairLevel,
			_color : color,
			_invisible : castle.clan.isInvisible(),
		};
	}

}