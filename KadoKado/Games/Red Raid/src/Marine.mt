class Marine extends Ally{//}

	
	
	
	function new(mc){
		type = 0
		super(mc)
		
		va = 1;
		ca = 0.3;
		ray = 10;
		tol = 10;
		
		hpMax = 10;
		frame = 0;
	
		accel = 0.2
		speedMax = 3
		
		
		range = 60;
		damage = 2;
		rate = 4;
		swivel = 0.8
		
		
	}
	
	function update(){
		super.update();
		

	
		
	}
	

	

	
	function attack(trg){
		downcast(skin).b.gotoAndPlay("2")
		var mc = Cs.game.dm.attach("partFlashLight",Game.DP_SHADOW)
		mc._x = x;
		mc._y = y;
		mc._rotation = root._rotation
		
		super.attack(trg)


		
	}
	

//{
}