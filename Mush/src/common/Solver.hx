package ;

import mt.Assert;
import Protocol;
// DE : compile pas a cause de SEG
//import mt.bumdum9.Lib;


import db.Hero;
import db.Hunter;
import db.Ship;

using Logic;
using Ex;
using Utils;
using ItemUtils;
using Logic;

import Types;


/**
 * ...
 * @author de
 */

class Solver
{//}

	public static function getTurretDamage( ship :Ship, rinfos : RoomInfos ) : {min:Int,max:Int}
	{
		var data = Protocol.shipStatsDb( TURRET );
		var b = { min: data.atk_min, max:data.atk_max };
		if( rinfos.inventory.hasWorking( INSECTOID_SHELL) )	{
			b.min *= 2;
			b.max *= 2;
		}
		
		var hs = ship.listHeroesInRoom( rinfos.id, false);
		for ( h in hs ) {
			if (h.skillsHas( GUNNER )) {
				b.min *= 2;
				b.max *= 2;
			}
		}
		return b;
	}
	
	public static function calcPilgredProgres( pil : logic.Pilgred, hero:  Hero)
	{
		var ship = hero.ship;
		
		var ptouch = pil.touch;
		var touch = (ptouch !=null && hero.id == ptouch.id) ? ptouch.qty : 0;
		
		var base = getBaseProgress( Gameplay.PILGRED_TAGS, Gameplay.PILGRED_MOD, hero, touch );
		
		return base;
	}
	
	public static function calcProjProgres(p:ProjectInfos, hero : Hero) : {min:Int,max:Int}
	{
		var ship = hero.ship;
		var data = Protocol.projectDb(p.id);
		
		var ptouch = ship.projectData.get(p.id).touch;
		var touch = (ptouch !=null && hero.id == ptouch.id) ? ptouch.qty : 0;
		
		var base = getBaseProgress( data.tags, data.mod, hero, touch );
		
		if( ship.neronVal( NB_CPU_PRIORITIES ) == 0)
		{
			base.min+=Gameplay.NERON_BIOS_PROJ_BOOST;
			base.max= base.min + (base.min>>1);
		}
		
		for( h in ship.liveHeroes(false))
			if (h.skillsHas(NERON_ONLY_FRIEND))
			{
				base.min = base.max;
				break;
			}
			
		return base;
	}
	
	public static function calcRschProgres(r:RschInfo, hero : Hero) : {min:Int,max:Int}
	{
		var ship = hero.ship;
		var data = Protocol.researchDb(r.id);
		
		var rtouch = ship.researchList.get(r.id).touch;
		var touch = (rtouch !=null && hero.id == rtouch.id) ? rtouch.qty : 0;
		
		var base = getBaseProgress( Gameplay.RESEARCH_TAGS, data.dif, hero, touch );
		
		if( ship.neronVal( NB_CPU_PRIORITIES ) == 2)
		{
			base.min+=Gameplay.NERON_BIOS_RSCH_BOOST;
			base.max= base.min + (base.min>>1);
		}
		
		if ( ship.getRoom( NEXUS_ROOM).inventory.hasWorking(COMPUTER_JELLY)) {
			base.min += 3;
			base.max += 3;
		}
		
		return base;
	}
	
	public static function getBaseProgress( tags : Array<SkillId>,
											diff : Int,
											hero: Hero,
											touches:Int)
	{
		var base = Gameplay.DIG_RATE;
		base = Std.int( base * diff / 10 );
		
		for ( t in tags)
			if ( hero.skillsHas( t ) )
				base += Gameplay.DIG_BOOST;
			
		base -= touches * 2;
		base =  MathEx.maxi( base, 0);
		return { min:base, max:base + (base>>1) };
	}
	
	//returns true whether action was fully successful
	public static function evalPatrolShipLandTakeOff(a : ActionId,hero: Hero, patrol:db.Patrol) : Bool
	{
		var loc = hero.loc();
		var ship  = hero.ship;
		mt.gx.Debug.assert(patrol.isLocked());
		
		var d = 0;
		var pc = 20;
		
		if (hero.skillsHas( PILOT ))
			return true;
		
		ActionLogic.iterEffects( hero,
			function(x)
			switch(x)
			{
				default:
				case IncrActionOdd(ac, v):
				if ( ac == a )
					pc = Std.int(pc+v);
				case MulActionOdd(ac, v):
				if ( ac == a )
					pc = Std.int( pc * v );
			}
		);
		
		if( !Dice.percent( pc ) )
		{
			var r = ShipLogic.hurtHull( ship, Dice.roll(2, 4) );
			patrol.hurt( 1 );
			hero.hurt(Dice.roll(0, 2));
			return false;
		}
		
		return true;
	}
	
	public static inline function hasActionOdds( x : ActionData) : Bool
		return Protocol.actionDb( x.id).proba != null;
	
	public static function calcActionOdds( hero:Hero, x : ActionData, ? item : ItemDesc, ?tgt:Hero, ?tgtPnj:db.PNJ) : Null<Int>
	{
		var res = null;
		var dbg = false;
		var s = hero.ship;
		
		#if debug
		if ( ActionLogic.traceAction == x.id )
		if ( ActionLogic.traceAction == x.id )
			dbg = true;
		#end
		
		var acData = Protocol.actionDb( x.id);
		var base = acData.proba;
		if( base == null) return null;
							
		switch(  x.id )
		{
			default:
				
			case DISASSEMBLE:
					var itData = Protocol.itemDb( item.id );
					if( itData.rep > 0) base = Std.int( 1.0 / itData.rep * 100.0);
				
			case REPAIR_OBJECT:
			{
				var itData = Protocol.itemDb( item.id );
				if( itData.rep > 0) base = Std.int( 1.0 / itData.rep * 100.0);
			}
			
			case SABOTAGE:
			{
				var itData = Protocol.itemDb( item.id );
				if ( itData.rep > 0) base = Std.int( 1.0 / itData.rep * 100.0);
					
				if ( item.status.has(REINFORCED))
					base >>= 2;
			}
			
			case PATROL_SHIP_ATTACK:	base = Utils.stanceData( hero.data.patrolStance ).hit;
			case TURRET_ATTACK : 		base = Protocol.shipStatsDb( TURRET ).hit;
			
			case BRAWL,ATTACK,AGGRO_ATTACK,SHOOT:
				if ( tgt != null)
					base = calcAggro( hero, x, item, tgt);
				else if ( tgtPnj != null)
					base = calcAggroPnj( hero, x, item, tgtPnj );
					
			case USE_EXTINGUISHER:
				//cancel the odd
				if ( hero.skillsHas(FIREMAN) )
					return null;
		}
		
		if( dbg ) Debug.MSG("caclOdds : base "+base );
		
		var basePostMod = 1.0;
		
		//apply modifiers
		ActionLogic.iterEffectsCached( hero,
				function(e)
				{
					switch(e)
					{
						case IncrActionOdd( a,d ):
						if( x.id == a )
						{
							if( dbg ) Debug.MSG("caclOdds : incred " + a );
							base += d;
						}
						
						case MulActionOdd( a , v ):
						{
							if( x.id == a )
							{
								if ( dbg ) Debug.MSG("caclOdds : muled " );
								basePostMod *= v;
							}
						}
						
						case MulEngActionOdd(v):
						{
							if ( Protocol.actionDb(x.id).color == ENG )
								basePostMod *= v;
						}
						
						case BoostActionOdd( a ):
						{
							if( a == x.id )
							{
								if( dbg ) Debug.MSG("caclOdds : boosted " );
								var v = acData.fail_coef;
								base = Std.int( base * v );
							}
						}
						case ToHit( v ):
						{
							//already considered for aggro attacks
							if ( [PATROL_SHIP_ATTACK, TURRET_ATTACK, SHOOT ].has( x.id ))
								basePostMod +=  v / 100.0;
						}
						default:
					}
				}
		);
		
		if ( hero.skillsHas( EXPERT )) basePostMod += 0.2;
		
		if ( hero.skillsHas( POLYMATH )) basePostMod -= 0.1;
		
		base = Std.int( basePostMod * base );
		
		if( dbg ) Debug.MSG("caclOdds : mod base "+base );
			
		if( hero.data.lastAction != null
		&&	hero.data.lastAction.a == x.id)
		{
			if ( dbg ) Debug.MSG("caclOdds : accumed" );
			
			var coef = acData.fail_coef;
			if ( coef == null ) coef = 1.25;
			
			if ( hero.skillsHas(PERSISTENT))
				coef = coef * Gameplay.PERSISTENT_FACTOR;
			
			mt.Assert.notNull( hero.data.lastAction.accum );
			
			var v = Std.int( base * Math.pow( coef, hero.data.lastAction.accum ));
			res = v;
		}
		else
		{
			if( dbg ) Debug.MSG("caclOdds : reset" );
			res = base;
		}
		
		if ( hero.isParia()) res = Std.int(res * 0.8);
		
		if( dbg ) Debug.MSG("caclOdds : res " + res );
		return  MathEx.clampi(res, 0, 99);
	}
	
	static function calcAggroPnj(hero : Hero, x : ActionData, it : ItemDesc, pnj:db.PNJ) : Int
	{
		Debug.NOT_NULL(hero);
		
		var ship = hero.ship;
		var loc = hero.location;
		var addData = it!=null ? Protocol.toolDb( it.id ) : null;
		var isKnife = addData != null && (addData.cat == BLADES);
		var isFist = ( x.id == BRAWL || x.id == AGGRO_ATTACK );
		var isArm = !isKnife && !isFist;
		
		if ( isFist )
			addData = Protocol.toolDb( FIST );
		
		var evtTable = isFist
					? HeroLogic.FIST_EVT_TABLE
					: (isKnife ? HeroLogic.KNIFE_EVT_TABLE : HeroLogic.WEAPON_EVT_TABLE);
					
		Debug.ASSERT( hero != null );
		Debug.ASSERT( hero.skills != null );
		
		var atk : Attack = HeroLogic.shallowAttack();
		atk.tgt = pnj;
		atk.cst = hero;
		if (addData != null&& addData.hitRate != null ) 	atk.hitRate = addData.hitRate;
		if ( !isFist && !isKnife)
		{
			ActionLogic.iterEffects(hero,
			function(fx)
				switch(fx) { case ToHit(b): atk.hitRate += b; default:}
			);
		}
		
		return atk.hitRate;
	}
	
	static function calcAggro(hero : Hero, x : ActionData, it : ItemDesc,tgt:Hero) : Int
	{
		Debug.NOT_NULL(hero);
		var ship = hero.ship;
		var loc = hero.location;
		var addData = it != null ? Protocol.toolDb( it.id ) : null;
		
		var isKnife = addData != null && (addData.cat == BLADES);
		var isFist = ( x.id == BRAWL || x.id == AGGRO_ATTACK );
		var isArm = !isKnife && !isFist;
		
		if ( isFist )
			addData = Protocol.toolDb( FIST );
		
		var evtTable = isFist
					? HeroLogic.FIST_EVT_TABLE
					: (isKnife ? HeroLogic.KNIFE_EVT_TABLE : HeroLogic.WEAPON_EVT_TABLE);
					
		Debug.ASSERT( hero != null );
		Debug.ASSERT( hero.skills != null );
		
		Debug.ASSERT( tgt != null );
		
		var atk : Attack = HeroLogic.shallowAttack();
		atk.tgt = tgt;
		atk.cst = hero;
		
		if (addData != null)
			atk.hitRate = addData.hitRate;
		
		if ( !isFist && !isKnife){
			ActionLogic.iterEffects(hero, function(fx){
				switch(fx) { case ToHit(b): atk.hitRate += b; default:};
			});
		}
		
		if( tgt.skillsHas( ESCAPE ) && (isFist||isKnife))
			atk.hitRate = (atk.hitRate * 3) >> 2;
			
		if ( tgt.flags.has(SLEEPY))
			atk.hitRate = Std.int( atk.hitRate * 1.50 );
		
		return atk.hitRate;
	}
	
	
	/*
	static var DRUG_BASE_EFFECT = [
		INC_MORAL(1), INC_MORAL(3),
		INC_ACTION(1), INC_ACTION(3),
		INC_MOVE(2), INC_MOVE(4),
		CURE(COLD),
		CURE(GASTROENTERITIS),
		CURE(VITAMIN_DEFICIT),
		CURE(TAPROOT),
		CURE(FLU),
		CURE(CHRONIC_HEADACHE),
	];
	static var DRUG_EXTRA_EFFECT = [
		CURE(SINUS_STORM),
		CURE(RUBEOLA),
		CURE(SYPHILIS),
		CURE(DEPRESSION),
		CURE(RASH),
		CURE(PARANOIA),
		CURE(SEPSIS),
		INC_MORAL(-1),
		INC_MORAL(-2),
		INC_MOVE(-2),
		INC_MOVE(-5),
	];
	*/
	
	// Renvoie la liste des effets des "max" médicaments de la partie
	/* DE : commpile pas...
	static function genDrugList() {
		var list = [];
		
		// INITIAL EFFECT
		for( e in DRUG_BASE_EFFECT ) list.push([e]);
		Arr.shuffle(list);
		
		// ADD EXTRA EFFECTS
		var extra = DRUG_EXTRA_EFFECT.copy();
		while( extra.length > 0 ) {
			var a = list[Std.random(list.length)];
			
			var ok = true;
			for( k in a ) {
				switch(k) {
					case INC_MORAL(n), INC_MOVE(n), INC_ACTION(n) :
						ok = ok && Type.enumIndex(k) != Type.enumIndex(extra[extra.length - 1]);
					default:
				}
			}
			if( ok )a.push(extra.pop());
		}
		
		return list;
	}
	*/
	
	// Renvoie la liste des effets des "max" plantes de la partie
	static function genPlantList(max=12) {
		
		
	}
	
	//returns true if this hit should be decreasing
	public static function decreasingProductivity( nb, every) : Bool
	{
		return ( nb % ( 1 + Std.int(nb / every) ) == 0 );
	}
	

//{
}





