package ac.struct;
import Protocole;
import mt.bumdum9.Lib;



class HeroUpkeep extends ac.Action {//}
	

	override function init() {
		super.init();
	
		
		for ( h in game.heroes ) {
		
			// RAGE
			var rage = h.readStock(RAGE);
			if ( rage > 0  && !h.haveStatus(STA_CLOCK) ) {
				add( new ac.MoveMid(h.folk) );
				var damage = rage;
				if ( h.have(INDOMITABLE) ) damage++;
				add( new ac.hero.Attack(h, game.monster,damage) );
				add( new ac.hero.MoveBack(h.folk) );
			}
			
			// KUNAI
			if ( h.readStock(KUNAI) > 0 && !h.haveStatus(STA_CLOCK) ) {
				var dt = [PHYSICAL, PROJECTILE];
				if ( h.have(ACID_BURST ) ) dt.push(ACID);
				//add( new ac.hero.Attack(h, game.monster, 1, dt) );
				add( new ac.hero.Projectile(h, game.monster, 3, 1, dt) );
				h.stock--;
			}
			


			// NATURAL BALANCE
			if ( h.board.breathes.length % 2 == 1 && h.have(NATURAL_BALANCE) ) 	add( new ac.hero.Regeneration(h, 1) );
			
			// REJUVENATION
			if ( h.haveStatus(STA_REJUVENATION) )  								add( new ac.hero.Regeneration(h,2) );
			
			// SCHIZOFRENIA
			if ( h.have(SCHIZOFRENIA) && game.heroes.length > 0 ) {
				var a = [];
				for ( h2 in game.heroes ) {
					if ( h == h2 ) continue;
					a = a.concat(h2.data.balls);
				}
				add( new ac.hero.Regeneration(h,1,[a[Std.random(a.length)]]) );
			}
			
		}

		
		add( new ac.PoisonCheck() );
		
		add( new CheckDeath() );
		
		add( new ac.hero.ShieldMove() );
		

		for ( h in game.heroes ) {
			h.onUpkeep();
			h.unfreshStock();
			h.majInter();
			add( new ac.Fall() );
		}
		
		
		
		onEndTasks = kill;
		
	}
	
	/*
	override function update() {
		super.update();
		trace(tasks.length+" "+tasks[0]);
	}
	*/


	
//{
}






