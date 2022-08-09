class Element{//}
	
	static var RAY = 12
	static var BUMP = 8
	
	var flActive:bool;
	
	var x:float;
	var y:float;
	var id:int;
	var sid:int;
	var root:MovieClip;
	
	function new(px,py,pid){
		x = px;
		y = py;
		id = pid;
		Cs.game.eList.push(this)
		if(id==4)sid = Std.random(7);
				

		
		flActive = false;
	}
	
	function update(){
	
	}
	
	function collide(ball){
		switch(id){
			case 0:
			case 1:
			case 2: // EXTRA POINTS
				KKApi.addScore(Cs.SCORE_BONUS[id])
				gerb(16)
				kill();
				break;
			
			case 3: // EXTRA TIME
				Cs.game.gameTimer = Math.min(Cs.game.gameTimer+Cs.BONUS_TIME, Cs.TIME_MAX )
				explode(16)
				kill();
				break;
			
			case 4: // EXTRA BALL
				var b = Cs.game.genBille(x,y)
				b.setColor(sid+1)
				kill();
				break;
			
			case 5: // EXTRA ZOOM
				break;
			
			case 6: // BUMPER
				var dx = ball.x - x;
				var dy = ball.y - y;
				var d = RAY+Ball.RAY - Math.sqrt(dy*dy+dx*dx)
				var a = Math.atan2(dy,dx)
				var ca = Math.cos(a)
				var sa = Math.sin(a)
				ball.x += ca*d
				ball.y += sa*d
				ball.vx += ca*BUMP
				ball.vy += sa*BUMP
				break
				
				
		}
	}
	
	function explode(max){
		for( var i=0; i<max; i++ ){
			var p = Cs.game.newPart("mcLightFlip")
			var a = (i/max)*6.28;
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var sp = 1+Math.random()*4
			var ray = 10
			
			p.x = x+ca*ray
			p.y = y+sa*ray
			p.vx  = ca*sp
			p.vy  = sa*sp
			p.timer = 10+Math.random()*120
			p.fadeType = 0;
			p.weight = 0.1+Math.random()*0.3
			p.bouncer = new Bouncer(p)
		}	
	}
	
	function gerb(max){
		for( var i=0; i<max; i++ ){
			var p = Cs.game.newPart("partFlamb")
			var a = (i/max)*6.28;
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var sp = 0.5+Math.random()*3
			var ray = 4
			
			p.x = x+ca*ray
			p.y = y+sa*ray
			p.vx  = ca*sp
			p.vy  = sa*sp
			p.timer = 10+Math.random()*15
			p.fadeType = 0;
			p.setScale(30+Math.random()*50)
			p.root.gotoAndStop(string(id+1))
			p.bouncer = new Bouncer(p)
		}	
		
		var p = Cs.game.newPart("partSpark") 
		p.x = x
		p.y = y
		p.setScale(150)
		p.updatePos();
	}	
	
	function kill(){
		root.removeMovieClip();
		Cs.game.eList.remove(this)
	}

	function attach(){
		root = Cs.game.dm.attach("mcElement",Game.DP_ELEMENT)
		root._x = x;
		root._y = y;
		root.gotoAndStop(string(id+1))

		if(id==4)downcast(root).sub.sub.gotoAndStop(string(sid+1));
		flActive = true;
	};
	function detach(){
		flActive = false;
		root.removeMovieClip();
	};

	
	
	
//{	
}