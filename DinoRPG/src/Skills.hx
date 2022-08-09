import fight.Fighter;
import Fight;
import data.Skill.SkillType;

using Lambda;
class Skills {

	static var S = Data.SKILLS.list;

	public static function calculateMaxDinoz( u : db.User ) {
		var max = 18;
		if( u.hasOneSkill(S.leader) )
			max += 3;
		if( u.hasOneSkill(S.messie) )
			max += 3;
		return max;
	}

	public static function calculateEquipSize( d : db.Dino ) {
		var n = 2;
		var s = d.getSkills();
		if( s.exists(S.poche.sid) )
			n += 1;
		if( d.uid != null && d.owner.hasOneSkill(S.inge) )
			n += 1;
		if( d.hasEffect(Data.EFFECTS.list.bckpck) )
			n += 1;
		if( s.exists( S.surhad.sid ) )
			n += 1;
		// +0 possible (up to 6)
		return n;
	}

	public static function calculateStockFactor( u : db.User ) {
		var f = 1.0;
		if( u != null && u.hasOneSkill(S.magasi) )
			f *= 1.5;
		if( Config.FREE_MODE || (u != null && u.isElite()) )
			f *= 1.2;
		return f;
	}

	public static function calculateIngredientStockFactor( u : db.User ) {
		var f = 1.0;
		if( Config.FREE_MODE || (u != null && u.isElite()) )
			f *= 1.2;
		return f;
	}

	public static function calculateShopDinozCount( u : db.User, demon : Bool ) {
		var n = demon ? 3 : 15;
		if( Config.FREE_MODE || u.isElite() ) n *= 2;
		return n;
	}

	public static function calculateGatherClicks( d : db.Dino, g : data.Gather ) {
		var G = Data.GATHER.list;
		var n = g.clicks;
		if( g.object != null ) {
			var qty = db.Object.manager.getStock(d.owner,g.object);
			return if( qty > n ) n else qty;
		}
		switch( g ) {
		case G.fo:
			if( d.hasSkill(S.fouil2) )
				n++;
			if( d.hasSkill(S.boost2) )
				n++;
			if( d.hasSkill(S.gratte) )
				n++;
			if( d.hasSkill(S.champo) )
				n++;
		case G.ch:
			if( d.hasSkill(S.artemi) )
				n++;
		case G.pe:
			if( d.hasSkill(S.nemo) )
				n++;
		case G.en, G.en2:
			if( d.hasSkill(S.einste) )
				n++;
		case G.cu, G.cu2, G.cu3:
			if( d.hasSkill(S.londuo) )
				n++;
		default:
		}
		//full clicks
		if ( d.owner.isAdmin ) n = 100;
		return n;
	}
	
	public static function calculateRegeneration( d : db.Dino ) {
		var reg = 1;
		var p = 0.5;
		var s = d.getSkills();
		if( s.exists(S.cocon.sid) )
			reg += 2;
		if( s.exists(S.regen.sid) )
			reg += 2;
		if( s.exists(S.pheart.sid) )
			p += 0.15;
		if( d.owner.hasOneSkill(S.pretre) )
			reg += 1;
		if( s.exists(S.odivi.sid) )
			reg *= 2;
		return { n : reg, p : p };
	}

	public static function calculateGroupSize( d : db.Dino ) {
		var n = 3;
		var s = d.getSkills();
		if( s.exists(S.boost1.sid) )
			n += 1;
		if( s.exists(S.charsm.sid) )
			n += 1;
		if( s.exists( S.efflu.sid ) )
			n += 1;
		return n;
	}

	public static function calculateXPBonus( d : db.Dino, xp : Int ) {
		var f = 1.0;
		var s = d.getSkills();
		if( s.exists(S.intell.sid) )
			f *= 1.05;
		if( d.owner != null && d.owner.hasOneSkill(S.prof) )
			f *= 1.05;
		if( d.hasEquip(Data.OBJECTS.list.mencly) )
			f *= 1.15;
		if( d.hasEffect(Data.EFFECTS.list.maudit) )
			f = 0;
		return Std.int(xp * f);
	}

	public static function calculateShopReduction( d : db.Dino, shopid : Int ) : Float {
		var f = 1.0;
		if( shopid == null && d.owner.hasOneSkill(S.marcha) )
			f *= 0.9;
		return f;
	}

	public static function calculateObjectLifeBonus( d : db.Dino ) : Float {
		var f = 1.0;
		if( d.owner.hasOneSkill(S.cuisin) )
			f *= 1.1;
		return f;
	}

	public static function calculateHealInfos( d : db.Dino ) {
		var regen = calculateRegeneration(d);
		var now = Date.now().getTime();
		var hours = (now - d.timer.getTime()) / (1000.0 * 60 * 60);
		if( hours < 0 )
			hours = 0;
		var life = Std.int(hours) * regen.n;
		var max = Std.int(d.maxLife * regen.p);
		var maxed = false;
		if( d.life + life >= max ) {
			life = max - d.life;
			if( life < 0 ) life = 0;
			maxed = true;
		}
		var ms = (1 - (hours - Std.int(hours))) * 60.0 * 60.0 * 1000.0;
		return {
			regen : regen.n,
			hours : hours,
			life : life,
			max : max,
			percent : Std.int(regen.p * 100),
			maxed : maxed,
			now : Date.now(),
			next : Date.fromTime(now + ms),
		};
	}

	public static function canFly( d : db.Dino ) {
		var fam = d.getFamily();
		return (
			fam == Data.DINOZ.list.nuagoz ||
			fam == Data.DINOZ.list.plan ||
			fam == Data.DINOZ.list.pteroz ||
			(fam == Data.DINOZ.list.soufle && d.level > 9 )
		);
	}

	public static function getLevelupInfos( d : db.Dino, ?forceElt ) {
		var r = new neko.Random();
		var rs = new mt.Rand(0);
		var seed = d.id + d.level * 1000;
		if( d.hasEffect(Data.EFFECTS.list.reinca) )
			seed += 100;
		if( d.hasEffect(Data.EFFECTS.list.renais) )
			seed += 200;
		
		rs.initSeed(seed);
		r.setSeed(rs.random(0x10000000));
		#if !fake
		if( App.session != null && App.session.plan_de_car == d.id )
			r.int(2);
		#end
		
		var etbl = d.getFamily().levelup.copy();
		var rtbl = new List();
		for( i in 0...5 ) {
			var e = data.Tools.random(etbl, function(i) return i, r);
			if( e == null ) continue;
			etbl[e] = 0;
			rtbl.add(e);
		}
		if( forceElt != null ) {
			rtbl = new List();
			rtbl.add(forceElt);
		}
		
		var skills = d.getSkills();
		var unlock = null, learn = null;
		var elt = null;
		
		var SKILLS = Lambda.list(Data.SKILLS);
		if( d.hasSkill( Data.SKILLS.list.lvlup ) )
			SKILLS = SKILLS.filter( function(s) return s.isNextGen || s.isSphere );
		
		while( true ) {
			unlock = new List();
			learn = new Array();
			elt = rtbl.pop();
			if( elt == null )
				return null;
			//
			for( s in SKILLS ) {
				if( s.elt != elt && s.elt2 != elt && s.elt3 != elt )
					continue;
				
				if( s.restricted != null && !Lambda.exists( s.restricted, function(f) return f == d.getFamily().id ) )
					continue;
				
				var ok = true;
				for( sdep in s.require ) {
					if( !skills.exists(sdep) ) {
						ok = false;
						break;
					}
				}
				
				if( ok ) {
					for( sdep in s.require ) {
						if( !skills.get(sdep).unlocked ) {
							ok = false;
							unlock.add(s);
							break;
						}
					}
				}
				
				//TODO  : make it reccursive here, because of rebirth
				if( ok ) {
					for( sdep in s.require ) {
						var dskill:db.Skill = skills.get(sdep);
						if( dskill.rebirth ) {
							//need deeper search
							for( sdep2 in Data.SKILLS.getId(sdep).require ) {
								if( !skills.exists(sdep2) ) {
									ok = false;
									break;
								}
							}
						}
						if( !ok ) break;
					}
				}
				
				if( ok && !skills.exists(s.sid) )
					learn.push(s);
			}
			
			if( learn.length > 0 || !unlock.isEmpty() ) {
				if( learn.length == 1 && learn[0] == S.envol && !canFly(d) && unlock.isEmpty() ) {
					//cas particulier du dinoz qui n'aurait plus qu'une connaissance dans cet element mais qu'il ne peut pas apprendre
				} else {
					break;
				}
			}
		}
		
		var envol = S.envol;
		if( learn.remove(envol) && canFly(d) )
			learn.push(envol);
		
		return {
			elt : elt,
			unlock : unlock,
			learn : learn,
			skills : skills,
		};
	}

	public static function hasSphere( d : db.Dino ) {
		for( s in d.getSkills() )
			if( Data.SKILLS.getId(s.sid).isSphere )
				return true;
		return false;
	}
	
	public static function countSphere( d : db.Dino ) {
		var count = 0;
		for( s in d.getSkills() )
			if( Data.SKILLS.getId(s.sid).isSphere )
				count++;
		return count;
	}
	
	public static function learn( d : db.Dino, s : data.Skill ) {
		switch( s ) {
		// FIRE
		case S.waikk:
			d.maxLife += 20;
		case S.coeura:
			d.maxLife += 20;
		case S.aurinc:
			d.fire += 2;
		case S.brave:
			d.fire += 6;
			d.maxLife += 50;
			//HACK to allow DinoBuilder to work with Fake Dino (DinoExport)
			if( Reflect.hasField(d, "id") )
			{
				// break follow
				d.follow = null;
				for( d2 in d.followers() ) {
					d2.follow = null;
					d2.update();
				}
			}
		// WOOD
		case S.croiss:
			d.maxLife += 20;
		case S.geant:
			d.maxLife += 30;
		case S.instin:
			d.wood += 2;
		case S.coloss:
			d.maxLife += 50;
		// WATER
		case S.mutat:
			d.maxLife += 30;
		case S.esousm:
			d.maxLife += 10;
		case S.sumo:
			d.maxLife += 100;
		case S.esous2:
			d.maxLife += 20;
		case S.mnage:
			d.water += 5;
		// THUNDER
		case S.archcr:
			d.fire += 2;
			d.thunder += 1;
		case S.archgn:
			d.wood += 2;
			d.thunder += 1;
		// AIR
		// SPHERE
		case S.vital:
			d.maxLife += 10;
		// DOUBLES
		case S.melemt:
			d.fire += 2;
			d.water += 2;
		//
		case S.magma:
			d.maxLife += 30;
			
		case S.peafer:
			d.maxLife += 50;
		case S.peaaci:
			d.maxLife += 100;
		case S.gamma:
			d.maxLife += 30;
		case S.vitmar:
			d.maxLife += 80;
		case S.batsup:
			d.maxLife += 50;
			
		}
	}
	
	public static function unlearn( d : db.Dino, s : data.Skill ) {
		switch( s ) {
		// FIRE
		case S.waikk:
			d.maxLife -= 20;
		case S.coeura:
			d.maxLife -= 20;
		case S.aurinc:
			d.fire -= 2;
		case S.brave:
			d.fire -= 6;
			d.maxLife -= 50;
		// WOOD
		case S.croiss:
			d.maxLife -= 20;
		case S.geant:
			d.maxLife -= 30;
		case S.instin:
			d.wood -= 2;
		case S.coloss:
			d.maxLife -= 50;
		// WATER
		case S.mutat:
			d.maxLife -= 30;
		case S.esousm:
			d.maxLife -= 10;
		case S.sumo:
			d.maxLife -= 100;
		case S.esous2:
			d.maxLife -= 20;
		case S.mnage:
			d.water -= 5;
		// THUNDER
		case S.archcr:
			d.fire -= 2;
			d.thunder -= 1;
		case S.archgn:
			d.wood -= 2;
			d.thunder -= 1;
		// AIR
		// SPHERE
		case S.vital:
			d.maxLife -= 10;
		// DOUBLES
		case S.melemt:
			d.fire -= 2;
			d.water -= 2;
		//
		case S.magma:
			d.maxLife -= 30;
		case S.peafer:
			d.maxLife -= 50;
		case S.peaaci:
			d.maxLife -= 100;
		case S.gamma:
			d.maxLife -= 30;
		case S.vitmar:
			d.maxLife -= 80;
		case S.batsup:
			d.maxLife -= 50;
		}
	}
}
