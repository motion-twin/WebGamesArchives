class Bonus extends Phys{//}

	
	
	static var ID_MAX = 4
	static var SPEED = 3
	static var SCORE = KKApi.aconst([1000,3000,12000]);

	static var WP_PLASMA =	0;
	static var WP_SIDER =	1;
	static var WP_LASER =	2;
	static var WP_SPEED =	3;
	static var WP_VOID =	4;
	static var WP_MISSILE = 5;
	
	static var NB = 0
	
	static var STATS = [
		100,		// PLASMA
		60,		// SIDER
		50,		// LASER
		70,		// SPEED
		70,		// VOID
		70,		// MISSILE
		30,		// SLOT
		0,		// MAGIC BALL
		0,		// TELEPORT
		0,		// HYPERTHRUST
		0,		// POWER BALL
		0,
		0,
		0,
		0,		
		0,		// GREEN
		0,		// BLUE
		0		// PINK
	]
	
	var id:int;
	var dm:DepthManager;
	
	function new(mc){
		Cs.game.bonusList.push(this)
		if(mc==null)mc = Cs.game.dm.attach("mcBonus",Game.DP_BADS);
		super(mc)

		ray = 15;
		dm = new DepthManager(root)
		id = getRandomId();
		var a = 0.775+Std.random(2)*1.57//Std.random(4)*1.57
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

		checkBounds();
		if(isOut(ray*2))kill();

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
		
		switch(id){
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
				Cs.game.hero.addWeapon(id);
				break;
			case 6:
				Cs.game.hero.addBox();
				break;
			case 7:
		}
		Cs.game.stats.$b.push([Stykades.dif,id])
		kill();
	}
	
	/*
	function exploPaillette(){
		
		var max = 24*Game.PM
		for( var i=0; i<max; i++ ){
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
	*/
		
	function checkBounds(){
		if( x<ray || x>Cs.mcw-ray ){
			vx *= -1;
			x = Cs.mm(ray,x,Cs.mcw-ray);

		}
		if( y>Cs.mch-ray ){
			vy *= -1;
			y = Cs.mm(ray,y,Cs.mch-ray);
		}
	}

	function kill(){
		Cs.game.bonusList.remove(this)
		super.kill()
	}
	
//{
}