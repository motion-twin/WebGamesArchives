class sp.Flame extends Part{//}

	var timer:float;
	var ray:float;
	
	function new(mc){
		mc = Cs.game.dm.attach( "mcExplosion" ,Game.DP_PART_2)
		super(mc)
		timer = 13
		setScale(15)
	}
	
	function update(){
		timer -= Timer.tmod;
		if(timer > 4 ){
			var px = int(x)
			var py = int(y)
			var r = 2
			if( fadeType == null && !Level.isZoneFree(px-r,px+r,py-r,py+r) ){
				var sc  = (2*ray)/100
				
				Level.holeSecure("mcHole",x,y,sc,sc,0,1);
				//
				timer = 6
				fadeType = 0
				bouncer = new Bouncer(this)
				if(Std.random(3)==0){
					var p = new Part(Cs.game.dm.attach("mcPixelBurn",Game.DP_PART_2));
					p.x = x;
					p.y = y;
					p.timer = 15+Math.random()*10
					p.bouncer = new Bouncer(p)
					p.weight  = 0.2+Math.random()*0.2
					p.vx = vx*0.3
					p.vy = vy*0.3
				}
			}
		}else if(timer<0 ){
			root = null;
			kill();
		}

		super.update();
	}
	

	
	
	
	
	
	
	
	
//{	
}