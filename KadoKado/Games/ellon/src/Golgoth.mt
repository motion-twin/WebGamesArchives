class Golgoth extends Bads{//}

	static var EYE_POS = [[-31,-2],[-17,3]]
	
	
	var decal:float;
	var sleep:float;
	var wTimer:float;
	var step:int;

	
	function new(mc){
		level = 28
		super(mc)
		ray = 40
		hp = 50
		frict = 0.98
		
		x= Cs.mcw+ray+30
		y= Cs.GL*0.5
		decal = 0;
		sleep = 0
		//
		initStep(2)
		wTimer = 140
		gid = 4
		//
		score = Cs.SCORE_GOLGOTH
	}
	
	function update(){
		super.update();
		//Log.print(int(x)+";"+int(y))
		move();
		wTimer -= Timer.tmod;
		switch(step){
			case 0:
				if(wTimer<0){
					initStep(2)
				}
				break;
			case 1:
				if(wTimer<0){
					root.gotoAndPlay("shootBig");
					var s = newAimedShot(14,0);
					s.setSkin(10)
					//var sc = 500
					//s.root._xscale = sc;
					//s.root._yscale = sc;
					s.ray = 20;
					vx -= s.vx*0.5;
					vy -= s.vy*0.5;
					initStep(2)
				}
				break;
	
			case 2:
				if(wTimer<0){
					initStep(Std.random(2));
				}
		}
		

		
	}
	
	function initStep(n){
		step = n;
		switch(step){
			case 0:
				shootRate = 1
				wTimer = 150
				break;
			case 1:
				shootRate = null;
				wTimer = 30+Math.random()*100
				root.gotoAndPlay("warning")
				break;
	
			case 2:
				shootRate = null;
				wTimer = 40+Math.random()*40
				break;			
		}			
	}
	
	
	function shoot(){

		root.gotoAndPlay("shootShort");
		var h = Cs.game.hero;
		for( var i=0; i<2; i++ ){
			var p = EYE_POS[i]
			var s = newShot();
			s.x = x+p[0]*root._xscale/100;
			s.y = y+p[1];
			var dx = h.x+p[0]+17 - s.x;
			var dy = h.y - s.y;
			s.a = Math.atan2(dy,dx);
			var sp = 6
			s.vx = Math.cos(s.a)*sp
			s.vy = Math.sin(s.a)*sp
			s.orient();
			s.setSkin(9)
			s.root._rotation = Math.random()*360
			cooldown = 16
		}

	}

	function move(){
		
		sleep = Math.min(sleep+0.01*Timer.tmod,1)
		
		decal=(decal+17*Timer.tmod)%628;
		
		var h = Cs.game.hero
		var mw  = Cs.mcw*0.5
		var mh  = Cs.GL*0.5		
		var r = 25//42
		var cc = 0.7
		var trg = {
			x:(mw-(h.x-mw)*cc)+Math.cos(decal/100)*r
			y:(mh-(h.y-mh)*cc)+Math.sin(decal/100)*r
		}
		var speed = 0.5*sleep
		speedToward(trg,0.2,speed)

		// RECAL
		bounceFamily()
		
		// REBOND
		if(y+ray>Cs.GL){
			y = Cs.GL-ray
			vy*=-0.8
			
			for( var i=0; i<4; i++){
				genGroundSmoke();
			}
		}
		
		
		//
		var sens = root._xscale/100
		if((h.x-x)*sens>0)setSens(-sens);
		root._rotation = -((h.y-y)*0.1)*root._xscale/100

	}
	

//{
}