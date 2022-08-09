class Bactery extends Bads{//}

	static var MARGIN = 10
	
	var decal:float;
	var dif:float;
	var wTimer:float;
	var sleep:float;
	
	var bloupDecal:float;
	var bloupSpeed:float;
	
	function new(mc){
		level = 5
		super(mc)
		ray = 14
		hp = 10
		//root.stop();
		frict = 0.97
		score = Cs.SCORE_BACTERY
		gid = 7
		decal = Math.random()*628;
		wTimer = 400
		
		dif = Math.random()*50;
		sleep = 0
		x = Cs.mcw+ray+5
		y = MARGIN + Math.random()*(Cs.GL+MARGIN*2)
		newTrg();
		Cs.bact++
	}
	
	function update(){
		super.update();

		dif += 3*Timer.tmod
		wTimer -= (1+dif*0.005)*Timer.tmod;
		if(wTimer<0){
			wTimer = 500
			newTrg();
			if(Std.random(4)==0 && Cs.bact<16 ){
				
				var b = new Bactery( Cs.game.mdm.attach("mcBactery",Game.DP_MONSTER) );
				b.x = x;
				b.y = y;
				b.dif = dif
				b.sleep = 1
				Cs.game.monsterLevel-=b.level;
				b.level = 0;
				for( var i=0; i<8; i++ ){
					var p  = new Part(Cs.game.mdm.attach("partBactery",Game.DP_PARTS))
					var a = 6.28*i/8//Math.random()*6.28
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var sp = 0.3+Math.random()*2.5
					p.x = x + ca*ray;
					p.y = y + sa*ray;
					p.vx = ca*sp
					p.vy = sa*sp
					p.scale = 100+Math.random()*100
					p.root._xscale = p.scale;
					p.root._yscale = p.scale;
					p.timer = 10+Math.random()*10
					p.fadeType = 0
				}
				b.bloup();
				bloup();
			}
		}

		if(bloupSpeed!=null){
			bloupSpeed *= Math.pow(0.96,Timer.tmod)
			bloupDecal = (bloupDecal+bloupSpeed*2*Timer.tmod)%628;
			var amp = bloupSpeed*0.5;
			root._xscale = 100+Math.cos(bloupDecal/100)*amp
			root._yscale = 100+Math.sin(bloupDecal/100)*amp
			if(bloupSpeed<1){
				bloupSpeed = null
			}
			
		}
		
		checkGround()
		
		
		move()
		bounceFamily();
		
		
	}
	
	function bloup(){
		bloupSpeed = 66
		bloupDecal = Math.random()*628
	}
	
	function move(){
		decal  = (decal+17*Timer.tmod)%628
		var r = Math.max(10,150-dif*0.3)
		var pos = {
			x:trg.x+Math.cos(decal/100)*r
			y:trg.y+Math.sin(decal/100)*r 
		}
		
		sleep = Math.min(sleep+(0.01*Timer.tmod),1)
		
		var speed = Math.min(0.1+dif*0.0001,0.5)*sleep
		speedToward(pos,0.2,speed)
			
		var b = 0.3
		if( x < ray+MARGIN ){
			vx += b*Timer.tmod;
		}
		if( x > Cs.mcw-(ray+MARGIN) && sleep>=1){
			vx -=  b*Timer.tmod;
		}
		if( y < ray+MARGIN ){
			vy +=  b*Timer.tmod;
		}
		if( y > Cs.GL-(ray+MARGIN) ){
			vy -= b*Timer.tmod;
		}	
	}
	
	
	
	function hit(shot){
		super.hit(shot)
		var a = Math.atan2(shot.vy,shot.vx)
		vx += Math.cos(a)*shot.damage*4;
		vy += Math.sin(a)*shot.damage*4;
	}
	
	function newTrg(){
		
		var r = Math.random()*Math.max(0,200-dif*0.3)
		var a = Math.random()*6.28
		
		var h = Cs.game.hero
		
		trg = {
			x:Cs.mm( 50+MARGIN, h.x+Math.cos(a)*r, Cs.mcw-MARGIN )
			y:Cs.mm( MARGIN, h.y+Math.sin(a)*r, Cs.GL-MARGIN )
		}
		
	};
	
	function kill(){
		Cs.bact--
		super.kill();
	}

//{
}