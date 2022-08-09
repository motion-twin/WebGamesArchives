class bads.Asteroid extends Bads{//}
	
	static var SIZE = [6,12,25,50,100]
	
	var type:int;
	var size:int;
	var destructPoint:int;
	var division:int;
	var speed:float;
	
	function new(mc){
		super(mc);
		destructPoint = 1;
		division = 2
		speed= 1.5 
		hp = 1;
		
		

	}
	
	function initStartPosition(){
		super.initStartPosition();
		//var a = Math.random()*6.28
		var a = 0.77+(Math.random()*2-1)*0.2 + Std.random(4)*1.57
		
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
	}

	function update(){
		super.update();
		checkWarp();
		
	
	}
	
	function hit(shot){
		super.hit(shot);
		var x = shot.x
		var y = shot.y
		var ang = getAng(shot)
		if(hp>0){
			for( var i=0; i<3; i++ ){
				var p = getRandomPart(type+1);
				var a = ang+(Math.random()*2-1)*1.57
				var sp = 0.5+Math.random()*3
				p.x = x;
				p.y = y;
				p.vx = vx+Math.cos(a)*sp
				p.vy = vy+Math.sin(a)*sp
				p.vr = (Math.random()*2-1)*15
				p.timer = 10+Math.random()*10
				p.fadeType = 0
				p.root._rotation = Math.random()*360				
			}
		}
		
	}

	function setInfo(t,s){
		type = t;
		size = s
		root.gotoAndStop(string(type+1));
		root.sub.gotoAndStop(string(size+1));
		ray = SIZE[size];
		
		hp = 1+size
		
		switch(type){
			case 0: // NORMAL
				hp--;
				speed *= 0.5
				break;
			case 1: // SMALLER
				speed *= 1.25
				destructPoint = 0
				break;
			case 2: // SPEEDER
				speed *= 3
				break;			
			case 3: // FRAGMENTER
				hp *= 2
				speed *= 1.5
				division = 3
				break;
			case 4: // STRONG
				speed *= 1.5
				hp *= 4
				break;
		}
		dif = Math.pow(division,size)*(hp+speed*0.3);
		score = KKApi.cmult(Cs.SCORE_ASTEROID[type],KKApi.const(size));
		vr = (10/size+2)*(Math.random()*2-1)
	}
	
	function explode(){
		
		if( ( Cs.game.flOption && Std.random(Cs.game.badsList.length) == 0) || Std.random(30) == 0 ){
			Cs.game.flOption = false;
			var bonus = new Bonus(Cs.game.dm.attach("mcBonus",Game.DP_SHOT))
			bonus.x = x;
			bonus.y = y;
		}
		
		
		//
		if(size>destructPoint){
			for( var i=0; i<2; i++ ){
				var a = Math.atan2(vy,vx) + 1.57*((i*2)-1)
				var sp = new bads.Asteroid(Cs.game.dm.attach("mcAsteroid",Game.DP_BADS));
				sp.setInfo(type,size-1)
				var ca = Math.cos(a)
				var sa = Math.sin(a)
				var ray = SIZE[sp.size]
				sp.x = x+ca*ray;
				sp.y = y+sa*ray;
				sp.vx = ca*sp.speed;
				sp.vy = sa*sp.speed;
			}
		}
		
		fxOnde(ray*2+30);
		throwDebris(type+1,(size+1)/5)
		
		super.explode();
	}
	

	
//{
}