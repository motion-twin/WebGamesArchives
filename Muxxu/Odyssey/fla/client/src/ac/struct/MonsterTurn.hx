package ac.struct;
import Protocole;
import mt.bumdum9.Lib;



class MonsterTurn extends ac.Action {//}
	
	
	var mon:Monster;
	
	override function init() {
		super.init();
		mon = game.monster;

		if ( !game.monster.summonSickness ) play();
		onEndTasks = endTurn;
		
		
	}
	

	
	
	function endTurn() {
		mon.onEndTurn();
		mon.onPlayTurn();
		mon.majInter();
		add( new ac.Fall() );
		add( new CheckDeath() );
		onEndTasks = kill;
	}
	
	// PLAY
	public function play() {
		

		
		var act = mon.getNextAction();
	
		
		
		// TRG
		var targetables = game.heroes.copy();
		targetables.reverse();
		var protectNext = false;
		for ( h in targetables ) {
			if ( protectNext ) {
				protectNext = false;
				targetables.remove(h);
			}
			if ( h.have(BODYGUARD) ) protectNext = true;
		}
		
		var trg = targetables[0];
		var randomTrg = targetables[Std.random(targetables.length)];
		if ( mon.have(FLYING) ) trg = seekBestTarget(targetables);
		
		// CHECK ABORT
		var data = Data.ACTIONS[Type.enumIndex(act)];
		var abort = false;
		if ( mon.haveStatus(STA_PACIFISM) && data.attack ) 		act = AC_ABORT;
		if ( mon.haveStatus(STA_PACIFISM_2) && data.attack ) 	act = AC_ABORT;
		if ( mon.haveStatus(STA_PACIFISM_2) && data.magic )		act = AC_ABORT;
		
		// MAIN
		switch(act) {
			case AC_ABORT, AC_WAIT, AC_FREEZE, AC_SLEEP:
			case AC_ATK:
				attack(trg);
				
			case AC_DOUBLE_ATK :
				attack(trg);
				attack(trg);
				
			case AC_CHARGE :
				attack(trg);
				trg.armor = trg.armor >> 1;
			


			case AC_KAMIKAZE :
				add( new ac.mon.Kamikaze(mon,trg) );
				//add( new ac.MonsterAttack(mon,trg,mon.life*2,[FIRE]) );
				//mon.life = 0;
				
			case AC_POWER_UP :
				mon.bonus_atk++;
				
			case AC_REGENERATE :
				mon.incLife(1);
				mon.folk.fxHeal();
				
			case AC_BARRIER :
				mon.incArmor(3);
				
			// MAGIC
			case AC_FIREBREATH :		add( new ac.mon.magic.Firebreath(mon, trg) );
			case AC_THUNDER :			add( new ac.mon.magic.Thunder(mon) );
			case AC_BUBBLE :			add( new ac.mon.magic.Bubble(mon, trg) );
			case AC_DRAIN :				add( new ac.mon.magic.Drain(mon, trg) );
			case AC_MIND_ATTACK :		add( new ac.mon.magic.MindAttack(mon, trg) );
			case AC_SNOW_FLAKE :
				
				var best = 0;
				for ( h in targetables ) {
					var score = 0;
					for ( b in h.board.balls )
						if ( !b.isFrozen() )
							score++;
					
					if ( score > best ) {
						best = score;
						trg = h;
					}
				}
			
				add( new ac.mon.magic.SnowFlake(mon, trg) );
			
			case AC_DEMORALIZE :		add( new ac.mon.magic.Demoralize(mon, trg) );
			case AC_PROVOKE :			add( new ac.mon.magic.Provoke(mon, trg) );
			case AC_LASER :				add( new ac.mon.magic.Laser(mon, trg) );
			case AC_INTIMIDATE :
				
			case AC_POISON_BREATH :		add( new ac.mon.PoisonBreath(mon, trg) );
				

			case AC_CYCLOP_LOOK :
				add( new ac.hero.CyclopEye(mon,trg));
				
			default : trace("TODO : " + act);
		}
		
		// ACTIONS AUTO
		if ( mon.have(STONE_GAZE) && mon.isActive() && trg.board.getRandomBall() != null ) {
			add( new ac.mon.magic.StoneGaze(mon,trg) );
		}
		//
		
		
		
		mon.majInter();
		

	}
	
	function attack(trg) {
		var targets = null;
		if ( mon.have(WINDMILL) ) 	targets = game.heroes.copy();
		add( new ac.MonsterAttack( mon, trg, cast targets, mon.getAttack()) );
	}
	function specialAttack(trg,act:ActionType) {
		var data = Data.ACTIONS[Type.enumIndex(act)];
		add( new ac.MonsterAttack(mon,trg,data.damage,data.damageTypes) );
	}

	
	//
	function getTargetWithoutStatus(sta) {
		var a = [];
		for ( h in game.heroes ) if ( !h.haveStatus(sta) ) a.push(h);
		return a[Std.random(a.length)];
	}
		
	public function seekBestTarget(list:Array<Hero>) {
		var best:Hero = null;
		for ( h in list ) {
			if ( best == null || h.armor < best.armor ) best = h;
		}
		return best;
	}
	


	
//{
}






