class ac.piou.Flamer extends ac.Piou{//}

	//static var DIG_TEMPO = 3//5
	var rnd :Random;
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("blowFlame")
		rnd = new Random(666);
		piou.initWalkState();
	}
	
	function update(){
		super.update();
		
		
		piou.walk();
		//Level.genHole(piou.x,piou.y-Piou.RAY,Piou.RAY)
		var sc = (2*Piou.RAY)/100
		if( !Level.holeSecure( "mcHole", piou.x, piou.y-Piou.RAY, sc, sc,0, 1  ) ){
			go()
			kill()
		}
		
		
		//
		timer = 5
		var ray = 8
		var p = new sp.Flame(null);
		var c = (rnd.rand()*2-1)
		var a =  c*0.3 + 1.57 - piou.sens*1.2
		
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		var sp = 3+rnd.rand()*5 - Math.abs(c)*2
		p.x = piou.x + ca*ray;
		p.y = piou.y + sa*ray - 5
		p.vx = ca*sp
		p.vy = sa*sp
		p.ray = 6
		if(piou.step == Piou.FALL ){
			kill();
		}
			
				
	}	
	
	function interrupt(){
		super.interrupt();
	}

	
	
//{
}