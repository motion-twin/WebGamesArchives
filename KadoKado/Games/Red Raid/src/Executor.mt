class Executor extends Alien{//}
	
	var baseRay:float;
	
	function new(mc){
		type = 5
		super(mc)
		
		range = 2
		damage = 40
		rate = 120
		view = 50
		
		//
		va = 0.4
		ca = 0.2
		ray = 12
		tol = 10
		hpMax = 200
		
		//
		accel = 1
		speedMax = 3		
		
		//
		mass = 0.3
		score = Cs.C2000;
		value = 8
		armor = -1
		
		//
		//ma = 0.2
		
		
		//
		baseRay = ray;
		
	}
	
	function update(){

		super.update();
		if(cd>0){
			vx *=0.1
			vy *=0.1
		}else{

			if(Math.random()/Timer.tmod< 0.1 ){
				var p = new Part(Cs.game.dm.attach("partSmallTache",Game.DP_GROUND))
				p.x = x+(Math.random()*2-1)*10; 
				p.y = y+(Math.random()*2-1)*10;
				p.setScale(50+Math.random()*150)
				p.timer = 30+Math.random()*20
				p.fadeType = 0
			}
		}

	}
	
	function die(ba){
		
		var max = 10
		for( var i=0; i<max; i++ ){
			var p = new Part(Cs.game.dm.attach("partGel",Game.DP_PART))
			var a = Math.random()*6.28
			if(ba!=null){
				a = ba+(Math.random()*2-1)
			}
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var cc = 0.8+Math.random()*0.8
			p.x = x + ca*ray*cc
			p.y = y + sa*ray*cc		

			var sp = 1+Math.random()*6
			p.vx = ca*sp
			p.vy = sa*sp
			p.timer = 10+Math.random()*10
			p.setScale(80+Math.random()*40)
			p.fadeType = 0;

			p.root.gotoAndStop(string(Std.random(p.root._totalframes)+1))
			p.root._rotation = Math.random()*360
		}
		var sp = new Part(Cs.game.dm.attach("partTache",Game.DP_GROUND))
		sp.x = x; 
		sp.y = y;
		sp.root._rotation = 180 + ba/0.0174//Math.random()*360
		sp.timer = 80+Math.random()*60
		
		ray = 0;
		super.die(ba);
	}
	
	function attack(){
		frame = null
		cd = rate
		var al = downcast(wp)
		skin.gotoAndStop(string(al.type+51))
		x = al.x
		y = al.y
		root._rotation = al.root._rotation
		ray = al.ray
		al.kill();
		//super.attack();
	}
	
	function hit( damage, ba ){
		var p = new Part(Cs.game.dm.attach("partGel",Game.DP_PART))
		var a = Math.random()*6.28
		if(ba!=null){
			a = ba+(Math.random()*2-1)
		}
		var ca = Math.cos(a)
		var sa = Math.sin(a)
		var cc = 0.8+Math.random()*0.6
		p.x = x + ca*ray*cc
		p.y = y + sa*ray*cc		

		var sp = 1+Math.random()*6
		p.vx = ca*sp
		p.vy = sa*sp
		p.timer = 10+Math.random()*10
		p.setScale(80+Math.random()*40)
		p.fadeType = 0;

		p.root.gotoAndStop(string(Std.random(p.root._totalframes)+1))
		p.root._rotation = Math.random()*360
		
		super.hit( damage, a )
	}
	

//{
}