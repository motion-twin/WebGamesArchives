class Grenadier extends Ally{//}

	
	
	
	function new(mc){
		type = 1
		super(mc)
		
		va = 1;
		ca = 0.3;
		ray = 10;
		tol = 10;
		
		hpMax = 10;
		frame = 0;
	
		accel = 0.2
		speedMax = 3
		
		
		range = 180;
		damage = 1000;
		rate = 100;
		swivel = 0.2
		
		
		
	}
	
	function update(){
		super.update();
		

	
		
	}
	

	

	
	function attack(trg){
		//downcast(skin).b.gotoAndPlay("2")
		//super.attack(trg)
		
		skin.gotoAndPlay("launch")
		frame = null;
		
		if( Math.abs(Cs.hMod(getAng(trg)-angle,3.14) ) > 0.1 )return;
		var sp = new Grenade(null);
		sp.setPos(x,y) 
		var dec = 10
		sp.setTrg(trg.x+(Math.random()*2-1)*dec,trg.y+(Math.random()*2-1)*dec) 
		
		cd = rate
		
	}
	

//{
}