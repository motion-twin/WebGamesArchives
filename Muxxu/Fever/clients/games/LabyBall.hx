
import mt.bumdum9.Lib;

class LabyBall extends Game{//}

	static var Q = 16;
	//static var MAT_SHAPE = new phx.Material(0.2, 0.4, 1.5);
	static var MAT_SHAPE = new phx.Material(0.01, 0.4, 1.5);
	static var GRAV = 0.3;
	
	var size:Int;
	var gmax:Int;

	var map:flash.display.Sprite;
	var mdm:mt.DepthManager;
	var grid:Array<Array<Bool>>;
	
	var balls:Array<Phx>;

	override function init(dif:Float){
		gameTime =  600-dif*100;
		super.init(dif);
		size = 6;
		haxe.Log.setColor(0xFFFFFF);
		
		
		//BG
		bg = new flash.display.MovieClip();
		bg.graphics.beginFill(0x440000);
		bg.graphics.drawRect(0, 0, Cs.mcw, Cs.mch);
		dm.add(bg, 0);
		

		// GRID
		genGrid();
		
		// MAP
		map = new flash.display.Sprite();
		map.x = Cs.mcw * 0.5;
		map.y = Cs.mch * 0.5;
		dm.add(map, 2);
		mdm = new mt.DepthManager(map);

		
		// PHYSICS
		var wray = Std.int(((gmax + 1) * 16) * 0.5);
		var aabb = new phx.col.AABB( -wray, -wray, wray * 2, wray * 2);
		world = new phx.World( aabb, new phx.col.BruteForce() );
		world.sleepEpsilon = 0;
		initWorld();
		
		
		// DRAW
		balls = [];
		for( x in 0...gmax) {
			for( y in 0...gmax) {
				if( !grid[x][y] ) {
					initBall(x+0.5, y+0.5);
					continue;
				}
				
				var el = new pix.Element();
				el.drawFrame(Gfx.games.get("laby_ball_wall"), 0, 0);
				var p = getPos(x, y);
				el.x = p.x;
				el.y = p.y;
				mdm.add(el, 1);
				
				var shape = phx.Shape.makeBox(Q,Q,el.x,el.y);
				world.addStaticShape(shape);
				
			}
		}
		

		
	
	}
	
	function initBall(x,y) {
		
		
		// BALL
		var el = new pix.Element();
		el.drawFrame(Gfx.games.get("laby_ball"));
		

		
		var mc = new flash.display.MovieClip();
		mc.addChild(el);
		mdm.add(mc, 2);
		var p = getPos( x, y );
		mc.x = p.x;
		mc.y = p.y;
		mc.tabIndex = 0;
		
		var phx = new Phx(mc);
		phx.game = this;
		phx.material = MAT_SHAPE;
		phx.setPos(mc.x,mc.y);
		phx.setAngle(0);
		phx.setCirc(4);
		phx.orient = false;
		
		balls.push(phx);
	}
	
	inline function getPos(x:Float,y:Float) {
		return {
			x : (x-gmax*0.5)*Q,
			y : (y-gmax*0.5)*Q,
		}
	}
	inline function getGPos(x:Float,y:Float) {
		return {
			x : Std.int(x/Q +gmax*0.5),
			y :  Std.int(y/Q + gmax*0.5),
		}
	}
	
	
	function genGrid() {

		// LABY
		var lbg = new proc.LabyGen(size, size, Std.random(2000));
		lbg.snakeCoef = 1;
		lbg.lock = 8;
		var mid = Std.int(size * 0.5);
		lbg.startPos = { x:mid, y:mid };
		lbg.breakLimit = 100;
		lbg.launch();
		while( !lbg.ready ) lbg.update();
		var lab = new proc.Laby(lbg);
		
		grid = [];
		gmax = (size * 2 + 1);
		for( x in 0...gmax ) {
			grid[x] = [];
			for( y in 0...gmax ) grid[x][y] = x==0 || y ==0;
		}

		
		// GRID
		var dir = [[1, 0], [0, 1], [1, 1]];
		for( px in 0...size ) {
			for( py in 0...size ) {
				var room = lab.getRoom(px, py);
				var wall = false;
				for( di in 0...3 ) {
					var d = dir[di];
					var x = 1 + px * 2 + d[0];
					var y = 1 + py * 2 + d[1];
					if( di < 2 && room.walls[di] ) {
						wall = true;
						grid[x][y] = true;
					}
					if( di == 2 ) {
						if(!wall) {
							for( ddi in 0...2 ) {
								var dd = Cs.DIR[ddi];
								var nei = lab.getRoom(px + dd[0], py + dd[1]);
								if( nei == null || nei.walls[1-ddi] ) {
									wall = true;
									break;
								}
							}
						}
						if( wall ) grid[x][y] = true;
					}
				}
			}
		}
		
		// OPEN SIDES
		var sides = [];
		var ma = 1;
		var max = gmax - ma * 2;
		for( x in ma...max ) {
			sides.push( { x:x, y:0 });
			sides.push( { x:x, y:gmax-1 });
		}
		for( y in ma...max ) {
			sides.push( { x:0, y:y });
			sides.push( { x:gmax-1, y:y });
		}
		
		Arr.shuffle(sides);
		var max = Std.int(sides.length * (1 - Math.pow(dif, 1.3)));
		var lim = 2;
		if( dif > 1.1 ) lim = 1;
		if( max < lim ) max = lim;

		var bx = 0;
		var by = 1+Std.random(size)*2;
		for( p in sides ) {
			if( p.x == bx && p.y == by ) {
				sides.remove(p);
				break;
			}
		}
		sides.push( {x:bx,y:by } );
		
		
		for( i in 0...max ) {
			var p = sides.pop();
			grid[p.x][p.y] = false;
		}
		
	}


	override function update(){
		
	
		// MOVE MAP
		var mp = getMousePos();
		var c = (mp.x / Cs.mcw ) * 2 - 1;
		map.rotation += c * 10;
		/*
		var da = Math.atan2(map.mouseY, map.mouseX);
		var lim = 0.2;
		da = Num.mm( -lim, da * 0.5, lim);
		map.rotation +=  da/0.0174;
		*/
		
		
		
		
		// GRAVITY
		var a = (90-map.rotation) * 0.0174;
		var dx = Math.cos(a) * GRAV;
		var dy = Math.sin(a) * GRAV;
		world.gravity.set(dx,dy);
		world.step(1,5);
		
		// BALL
		var a = balls.copy();
		var perfect = true;
		for( b in a) {
			b.root.rotation = - map.rotation;
			


			
			
			// CHECK OUT
			var out =  gmax* Q * 0.5;
			if( Math.abs(b.x) > out || Math.abs(b.y) > out|| b.scale < 1 || b.root.tabIndex > 5) {
				
				b.setScale(b.scale * 0.9);
				Col.setPercentColor(b.root, (1-b.scale* 0.01) , 0xFFFFFF);
				
				var pos = new flash.geom.Point(b.x, b.y);
				pos = map.localToGlobal(pos);
				
		
				var a = Math.random() * 6.28;
				var speed =  0.1 + Math.random();
				var p = new pix.Part();
				p.setAnim(Gfx.fx.getAnim("spark_grow"));
				p.xx = pos.x;
				p.yy = pos.y;
				p.updatePos();
				p.weight = - (0.1 + Math.random() * 0.1);
				//p.vx = (Math.random() * 2 - 1) * 0.15;
				p.vx = Math.cos(a) * speed;
				p.vy = Math.sin(a) * speed;
				p.vy += 0.5 + Math.random() * 1.5;
				dm.add(p, 2);
				p.timer = 10 + Std.random(40);
				p.anim.gotoRandom();
				p.frict = 0.99;
			
				if( b.scale < 0.2 ){
					b.kill();
					balls.remove(b);
				}

			}else {
				perfect = false;
				
				// CHECK PHYSIC BUG COLLIDE
				var gp = getGPos(b.root.x, b.root.y);
				if( isIn(gp.x, gp.y) && grid[gp.x][gp.y] ) 	b.root.tabIndex++;
			}
		}
		
		if( perfect ) setWin(true, 20);
		
		
		// SCROLL
		/*
		var pos = new flash.geom.Point(ball.phx.x, ball.phx.y);
		pos = map.localToGlobal(pos);
		pos = box.globalToLocal(pos);
		pos.x -= Cs.mcw * 0.25;
		pos.y -= Cs.mch * 0.25;
		var c = 0.75;
		map.x -= pos.x * c;
		map.y -= pos.y * c;
		*/
		
		
		super.update();
		
		for( b in balls) {

			

			
			//
			b.root.x = Std.int(b.root.x);
			b.root.y = Std.int(b.root.y);
			
		}
		
	}
	
	function isIn(x,y) {
		return x >= 0 && x < gmax && y >= 0 && y < gmax ;
	}





//{
}

