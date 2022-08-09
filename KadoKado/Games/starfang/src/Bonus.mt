class Bonus extends Phys{//}

	static var ID_MAX = 4
	static var BOUNCE_MAX = 5
	static var SPEED = 3
	
	static var SCORE = KKApi.aconst([1000,3000,12000]);
	static var STATS = [
		120,		// NORMAL
		100,		// SPEEDER
		30,		// ONDE
		80,		// FLAMER
		1,		// BLACK SPOT
		70,		// AIRSTRIKE
		30,		// SHIELD
		70,		// MAGIC BALL
		80,		// TELEPORT
		20,		// HYPERTHRUST
		7,		// POWER BALL
		0,
		0,
		0,
		0,		
		300,		// GREEN
		50,		// BLUE
		5		// PINK
	]
	
	var id:int;
	var bounce:int;
	var dm:DepthManager;
	
	function new(mc){
		Cs.game.bonusList.push(this)
		super(mc)
		bounce = 0;
		ray = 15;
		dm = new DepthManager(root)
		id = getRandomId();
		var a = 0.775+Std.random(4)*1.57
		vx = Math.cos(a)*SPEED
		vy = Math.sin(a)*SPEED
		root.gotoAndStop(string(id+1));
		
	}
	
	function getRandomId(){
		var max = 0
		for( var i=0; i<STATS.length; i++ ){
			max += STATS[i]
		}
		var rnd = Std.random(max)
		var cur = 0
		for( var i=0; i<STATS.length; i++ ){
			cur += STATS[i]
			if(cur>rnd){
				return i
			}
		}
		return 0;
		
	}
	
	function update(){
		super.update();
		if( collide(Cs.game.hero) )take();

		if(bounce<BOUNCE_MAX){
			checkBounds();
		}else{
			if(isOut(ray))kill();
		}
		if(id>=15 && id<=17){
			for(var i=0; i<2; i++){
				var p = new Part(dm.attach("partRay",1));
				p.root.gotoAndStop(string(id-14));
				p.vr = (Math.random()*2-1)*10
				p.fadeType = 1
				p.scale = 50+Math.random()*100
				p.root._xscale = 10+Math.random()*20
				p.root._yscale = p.scale
				p.root._rotation = Math.random()*360
				p.timer = 10+Math.random()*10
				p.root._x =0
				p.root._y =0
				
			}
		}
		
	}
	
	function take(){
		Cs.game.stats.$b.push(id)
		switch(id){
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
				Cs.game.hero.updateWeapon(id);
				break;
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
				Cs.game.hero.updateSecondary(id-5);
				break;
			case 15:
			case 16:
			case 17:
				var sc = SCORE[id-15]
				KKApi.addScore(sc)
				var mc = Cs.game.dm.attach("mcTextField",Game.DP_PARTS)
				downcast(mc).txt = KKApi.val(sc);
				mc._x = x;
				mc._y = y;
				exploPaillette();
				break;
		}
		kill();	
	}
	
	function exploPaillette(){
		for( var i=0; i<24; i++ ){
			var p = new Part(Cs.game.dm.attach("partPaillette",Game.DP_PARTS))
			p.root.gotoAndStop(string(id-14))
			var a = Math.random()*6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var r = 5+Math.random()*ray
			var sp = 0.5+Math.random()*2
			p.x = x+ca*r;
			p.y = y+sa*r;
			p.vx = ca*sp
			p.vy = sa*sp
			p.vr = (Math.random()*2-1)*20
			p.timer = 10+Math.random()*20
			p.setScale(10+Math.random()*50)
			p.root._rotation = Math.random()*360
			p.fadeType = 0;
			
		}		
		for( var i=0; i<12; i++ ){
			var p = newPart("partLight",ray,1+Math.random()*3)
			p.setScale(50+Math.random()*100)
		}		
	}
	
	function newPart(link,r,sp){
		var p = new Part(Cs.game.dm.attach(link,Game.DP_PARTS))
		var a = Math.random()*6.28
		var ca = Math.cos(a)
		var sa = Math.sin(a)
		p.x = x+ca*r;
		p.y = y+sa*r;
		p.vx = ca*sp
		p.vy = sa*sp
		p.timer = 10+Math.random()*10
		p.fadeType = 0;
		return p;
	}
	
		
	function checkBounds(){
		if( x<ray || x>Cs.mcw-ray ){
			vx *= -1;
			x = Cs.mm(ray,x,Cs.mcw-ray);
			bounce++
		}
		if(y<ray || y>Cs.mch-ray ){
			vy *= -1;
			y = Cs.mm(ray,y,Cs.mch-ray);
			bounce++
		}
	}

	function kill(){
		Cs.game.bonusList.remove(this)
		super.kill()
	}
	
//{
}