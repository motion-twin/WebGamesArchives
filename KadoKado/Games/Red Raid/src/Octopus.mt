class Octopus extends Alien{//}

	
	
	
	function new(mc){
		type = 2
		super(mc)
		
		range = 4
		damage = 6
		rate = 20
		view = 50
		
		//
		va = 0.1
		ca = 0.1
		ray = 29
		tol = 10
		hpMax = 360
		
		//
		accel = 0.1
		speedMax = 0.7		
		
		//
		mass = 0
		
		score = Cs.C1500
		value = 18
		armor = 1
		
		//
		ma = 0.2
		
		
	}
	
	function update(){
		super.update();
	
	}
	
	function die(ba){
		for( var i=0; i<4; i++ )throwGibs(300,ba);
		for( var i=0; i<12; i++ )throwGibs(180,ba);
		spawnBonus();
		super.die(ba);
	}
	
	function attack(){
		
		var sp  = downcast(wp)
		
		if(sp.type<3){
			frame = null;
			cd = 30
			skin.gotoAndPlay("attack");
			downcast(skin).ally.gotoAndStop(string(sp.type+2))
			downcast(wp).kill()
		}else{
			super.attack();
			downcast(skin).ally.stop();
		}	
	}

//{
}