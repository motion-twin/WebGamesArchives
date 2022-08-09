class Ball extends PhysicObj {//}

	
	var state:int;
	var frame:float;
	var vitRot:float;
	
	var mc : MovieClip;
	var game : Game;
	var ship : bool;
	var id : int;

	var ox : float;
	var oy : float;
	var inhole : bool;

	var colflag : bool;
	var bande : int;
	var bandeLast : bool;

	function new(g,i,px,py) {
		dx = 0;
		dy = 0;
		game = g;
		ship = (i == 0);
		id = i - 1;
		x = px;
		y = py;
		ox = x;
		oy = y;
		r = Const.BALL_RAY;
		mass = ship?Const.SHIP_MASS:Const.BALL_MASS;
		mc = game.dmanager.attach(ship?"ship":"ball",Const.PLAN_BALL);
		if( !ship )
			initColor(mc,id);
		mc._x = x;
		mc._y = y;
		
		state = 0;
		vitRot = 0;
	}

	static function initColor(mc : MovieClip,id) {
		var c = Const.COLORS[id];
		var col = new Color(downcast(mc).base);
		var t = {
			ra : 100,
			rb : (c >> 16) - 255,
			ga : 100,
			gb : ((c >> 8) & 0xFF) - 255,
			ba : 100,
			bb : (c & 0xFF) - 255,
			aa : 100,
			ab : 0
		};
		col.setTransform(t);
		downcast(mc).color = t;
	}

	function dist(tx,ty) {
		var dx = tx - x;
		var dy = ty - y;		
		return Math.sqrt(dx * dx + dy * dy);
	}

	function hole() {
		if( !colflag )
			return false;
		var l = ship?Const.SHIP_LIMIT:Const.LIMIT;
		if( dist(0,Const.MIN_Y) <= l ) {
			inhole = true;
			ox = 0;
			oy = Const.MIN_Y;
		} else if( dist(0,300) <= l ) {
			inhole = true;
			ox = 0;
			oy = 300;
		} else if( dist(300,Const.MIN_Y) <= l ) {
			inhole = true;
			ox = 300;
			oy = Const.MIN_Y;
		} else if( dist(300,300) <= l ) {
			inhole = true;
			ox = 300;
			oy = 300;
		}
		return inhole;
	}

	function update(t) {
		if( inhole ) {
			var s;
			if( dist(ox,oy) > 10 ) {
				s = mc._xscale * Math.pow(0.97,t);
				x = x * 0.95 + 0.05 * ox;
				y = y * 0.95 + 0.05 * oy;
			} else {
				s = mc._xscale * Math.pow(0.95,t);
				x += Std.random(3) - 1;
				y += Std.random(3) - 1;				
				if( s < 5 )
					return false;				
			}
			mc._rotation += t * Math.sqrt(100 - s);
			mc._xscale = s;
			mc._yscale = s;
			mc._x = x;
			mc._y = y;
			
			//GFX
			if( state !=3 ){
				state = 3
				mc.gotoAndPlay("death")
			}
			//		
			return true;
		} else {
			var dx = x - ox//ox - x;
			var dy = y - oy//oy - y;
			ox = x;
			oy = y;
			mc._x = x;
			mc._y = y;
			
			//GFX
			var dist = Math.sqrt(dx*dx+dy*dy)
			
			if(ship){
				if( game.state != Game.CHOOSE_WAY ){
					vitRot *= Math.pow(0.95, Timer.tmod )
					mc._rotation += vitRot
				}else{
					vitRot = 0
				}
				
				//if( dist > 8 ){
					var q = game.dmanager.attach("queue",Const.PLAN_LINE)
					q._x = x
					q._y = y
					q._rotation = mc._rotation
					var frame = 1+int(Math.max(0,(10-dist)))
				
					q.gotoAndPlay(string(frame))
				//}
				
				
			}else{
				var flMove = dist > 1
				
				if( dist < 1 ){
					initState(0)
				}else if( dist < 3 ){
					initState(1)		
				}else{
					initState(2)
				}
				
				switch(state){
					case 1:
						mc._rotation *=0.9
						break;
					case 2 :	// ROLL
						mc._rotation = Math.atan2(dy,dx)/0.0174
					
						frame = (frame+dist*0.2)%10
						mc.gotoAndStop(string(50+frame))
					
						break;
				}
			}
			return( dist / t >= Const.EPSILON );
		}
	}
	
	function onCollide(trg) {
		colflag = true;
		if( ship ) {
			vitRot += Math.random()*20;
			if( trg == null ) {
				if( !bandeLast )
					bande++;
			} else
				bandeLast = true;
		}
	}
	
	function initState(n){
		if( n == state )return;
		switch(state){
			case 2 :
				mc._rotation -= 90
				break;
		}
		var old = state
		state = n
		switch(state){
			case 0:
				mc.gotoAndPlay("base")
				break;
			case 1:
				if( old == 2 ){
					mc.gotoAndPlay("animMove")
				}else{
					mc.gotoAndPlay("move")
				}
				
				break;
			case 2 :
				mc.gotoAndPlay("roll")
				mc._rotation = Math.atan2(dy,dx)/0.0174
				break;
		}
		
		
	}
	
	
	

	function destroy() {
		mc.removeMovieClip();
	}

	
	//{
}