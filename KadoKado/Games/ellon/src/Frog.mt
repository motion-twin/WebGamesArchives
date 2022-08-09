class Frog extends Bads{//}


	
	var step:int;
	var explodeTimer:float;
	
	function new(mc){
		level = 16
		super(mc)
		ray = 18//26
		hp = 30
		//frict = 0.98
		score = Cs.SCORE_FROG

		x = Cs.mcw+ray+5
		initGround();
		gid = 6
		
		//
		explodeTimer = 120;
		
		
	}
	
	function update(){
		super.update();
		//Log.print(root._xscale+";"+root._yscale)
		switch(step){
			case 0:
				var h = Cs.mcw*0.5
				var dx =  - x
				if(x<h && Math.random()*(x/h) < 0.1 ){
					step = 1;
					root.gotoAndPlay("jumpStart");
					var ma = 0.3;
					var a = -(ma+Math.random()*(1.57-2*ma));
					var sp = 10+Math.random()*8;
					vx = Math.cos(a)*sp;
					vy = Math.sin(a)*sp - Math.random()*5;
					frict = 0.98;
					weight = 0.7;
				}
				break;
			case 1:
				if( y > Cs.GL ){
					initGround();
				}
				break;
		}
		explodeTimer -= Timer.tmod;
		if( explodeTimer < 0 && y<230 ){
			var max = 64
			var cr  = 8;
			for( var i=0; i<max; i++ ){
				var shot = newShot();
				var a = i/max * 6.28;
				var ca = Math.cos(a);
				var sa = Math.sin(a);
				var sp = 3+( i%3  )*1.5;
				shot.x += ca*cr*sp;
				shot.y += sa*cr*sp;				
				shot.vx = ca*sp;
				shot.vy = sa*sp;
				shot.setSkin(8);
			}
			kill();
		}
		
	}
	
	function hit(shot){
		explodeTimer += shot.damage*20;
		super.hit(shot);
	}
	
	function initGround(){
		step = 0
		weight = null
		frict = 1
		vx = -Cs.SCROLL_SPEED
		vy = 0
		y = Cs.GL-ray*0.5
		root.gotoAndPlay("land")
		root._rotation = 0
	}
	

//{
}