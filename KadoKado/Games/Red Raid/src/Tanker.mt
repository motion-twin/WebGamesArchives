class Tanker extends Alien{//}

	
	
	
	function new(mc){
		type = 1
		super(mc)
		
		range = 11
		damage = 3
		rate = 12
		view = 50
		
		//
		va = 0.2
		ca = 0.2
		ray = 20
		tol = 10
		hpMax = 61
		
		//
		accel = 0.1
		speedMax = 1.5		
		
		//
		mass = 0.2
		
		score = Cs.C250
		value = 5
		
	}
	
	function update(){
		super.update();
	

	
		
	}
	
	function die(ba){
		throwGibs(200,ba)
		for( var i=0; i<3; i++ )throwGibs(100,ba)
		
		
		
		if( Math.random() < 0.1 + Cs.GAME_MODE*0.3 ){
			spawnBonus();
		}else{
			if( Cs.GAME_MODE == 1 && Math.random() < Cs.RENFORT_STATS[0]  ){
				spawnTroup();
				if(Cs.RENFORT_STATS.length>1)Cs.RENFORT_STATS.shift();
			}
			
		}
		
		
		
		super.die(ba);
	}
	
	
	
	
//{
}