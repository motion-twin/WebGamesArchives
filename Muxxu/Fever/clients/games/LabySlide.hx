
import mt.bumdum9.Lib;

private typedef Block = { el:pix.Element, walls:Array<Bool>, ball:pix.Element, x:Int, y:Int, tag:Int };

class LabySlide extends Game{//}

	
	var side:Int;
	var mx:Int;
	var my:Int;
	var blocks:Array<Block>;
	var grid:Array<Array<Block>>;
	
	var first:Block;
	var last:Block;
	
	var snapshot:BMP;
	var strip:SP;
	var slide:SP;
	var sdir:Int;
	var coef:Float;
	var pivot:Block;
	var base:{x:Float,y:Float};
	
	var path:Array<Block>;
	var balls:Array<{el:pix.Element,bl:Block,next:Int}>;
	

	override function init(dif:Float){
		gameTime =  600;
		super.init(dif);
		
		side = 5;// 3 + Std.int(dif * 5);
		
		//
		box.scaleX = box.scaleY = 2;
		
		//
		mx = Std.int((Cs.mcw * 0.5 - side * 16) * 0.5);
		my = Std.int((Cs.mch * 0.5 - side * 16) * 0.5);
		
		//
		var lbg = new proc.LabyGen(side, side, Std.random(400));
		lbg.snakeCoef = 0;
		lbg.run();
		var laby = new proc.Laby(lbg);

		
		// BG
		var g = box.graphics;
		g.beginFill(0x442211);
		g.drawRect(0, 0, Cs.mcw >> 1, Cs.mch >> 1);
		g.endFill();
		
		g.beginFill(0x331100);
		g.drawRect(mx, my, (Cs.mcw >> 1) - 2 * mx, (Cs.mch >> 1) - 2 * my);
		g.endFill();
		
		// GRID
		grid = [];
		blocks = [];
		for( x in 0...side ) {
			grid[x] = [];
			for( y in 0...side ) {
				var data = laby.getRoom(x, y);
				var el = new pix.Element();
				var pos = getPos(x, y);
				el.x = pos.x;
				el.y = pos.y;
				//var id = 0;
				//for( i in 0...4 ) if( !data.walls[i] ) id += Std.int( Math.pow(2, i) );
				//el.drawFrame(Gfx.games.get(id, "laby_slide_tiles"),0,0);
				dm.add(el, 1);
				var bl = { el:el, walls:data.walls, ball:null, x:x, y:y, tag:0 };
				grid[x][y] = bl;
				blocks.push(bl);
				el.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, callback(startSlide, bl));
			}
		}
		
		// OPEN
		var open = Std.int((1-dif)*24);
		while(open>0) {
			var bl = blocks[Std.random(blocks.length)];
			var dirs = [0, 1, 2, 4];
			Arr.shuffle(dirs);
			for( di in dirs ) {
				if( bl.walls[di] ) {
					bl.walls[di] = false;
					open--;
					break;
				}
			}
		}
		
		// DRAW ALL
		for( bl in blocks ) drawBlock(bl);
		
		// BALLS
		first = setBall(0, 0);
		last = setBall(side-1, side-1);
		
		// SHUFFLE
		//var shuffle = 1 + (dif * 10);
		var shuffle = 10;
		while( shuffle>0 ) {
			pivot = blocks[Std.random(blocks.length)];
			var di = Std.random(2);
			if( getDirBall(di) == null ) {
				slideAll(di, Std.random(side));
				shuffle--;
			}
			if( checkEnd() ) shuffle++;
		}
		
		
	}
	function drawBlock(bl:Block) {
		var id = 0;
		for( i in 0...4 ) if( !bl.walls[i] ) id += Std.int( Math.pow(2, i) );
		bl.el.drawFrame(Gfx.games.get(id, "laby_slide_tiles"), 0, 0);
	}
	

	override function update(){
		super.update();
		
		switch(step) {
			case 1 :	// WAIT
			
			case 2 :	// START_SLIDE
				var mp = getMousePos();
				var dx = mp.x - base.x;
				var dy = mp.y - base.y;
				if( Math.sqrt(dx * dx + dy * dy) > 2 ) {
					sdir = Cs.getAngleDir(Math.atan2(dy, dx))%2;
					initStrip();
				}
				if( !click ) step = 1;

			case 3 : 	updateSlide();
			case 4 : 	updateEndSequence();
					
			
		}
		
		
	}
	
	// STRIPS
	function startSlide(bl:Block, ?e) {
		if( step != 1 ) return;
		pivot = bl;
		base = getMousePos();
		//var mp = getMousePos();
		//base = new Point(mp.x, mp.y);
		step++;
	}
	function initStrip() {
		
		var bl = getDirBall(sdir);
		if( bl != null ) {
			new mt.fx.Flash(bl.el,0.1,0xFF0000);
			step = 1;
			return;
		}
		/*
		var a = getLine(sdir);
		for( bl in a ) {
			if( bl.ball != null ) {
				new mt.fx.Flash(bl.el,0.1,0xFF0000);
				step = 1;
				return;
			}
		}
		*/
		
		//
		step++;
		strip = new SP();
		slide = new SP();
		if( sdir == 0 ){
			snapshot = new BMP( side * 16, 16, false, 0xFF0000 );
			for( i in 0...2 ) {
				var b = new flash.display.Bitmap(snapshot);
				b.x = -i * side * 16;
				slide.addChild(b);
			}
			strip.x = mx;
			strip.y = pivot.el.y;

		}else{
			snapshot = new BMP( 16, side*16, false, 0xFF0000 );
			for( i in 0...2 ) {
				var b = new flash.display.Bitmap(snapshot);
				b.y = -i * side * 16;
				slide.addChild(b);
			}
			strip.x = pivot.el.x;
			strip.y = my;

		}
		
		// SNAPSHOT
		var m = new MX();
		m.translate( -strip.x, -strip.y);
		snapshot.draw( box, m );
		
		// MASK
		var mask = new SP();
		slide.mask = mask;
		mask.graphics.beginFill(0x0000FF);
		mask.graphics.drawRect(0, 0, snapshot.width, snapshot.height);
		strip.addChild(mask);
		
		// ADD
		dm.add(strip, 2);
		strip.addChild(slide);
	}
	function updateSlide() {
		var mp = getMousePos();
		var tot = side * 16;
		
		var tx = slide.x;
		var ty = slide.y;
		
		var dc = 0;
		if( sdir == 0 ) {
			var dx = mp.x - base.x;
			dc = Math.round(dx / 16);
			tx = dc * 16;
		}else {
			var dy = mp.y - base.y;
			dc = Math.round(dy / 16);
			ty = dc * 16;
			
		}
	
		var dx = Num.hMod(tx - slide.x, tot * 0.5);
		var dy = Num.hMod(ty - slide.y, tot * 0.5);
		slide.x += dx*0.5;
		slide.y += dy*0.5;
		slide.x = Num.sMod(slide.x, tot);
		slide.y = Num.sMod(slide.y, tot);
		
		if( !click ) {
			
			strip.parent.removeChild(strip);
			snapshot.dispose();
			
			slideAll(sdir,dc);
			
			if( checkEnd() ) 	initEndSequence();
			else				step = 1;
			
		}
	}
	
	function slideAll(di,dc) {
		
		if( di == 0 ) {
			for( x in 0...side ) {
				var bl = grid[x][pivot.y];
				bl.x = Std.int( Num.sMod( (bl.x +dc), side ) );
			}
		}else {
			for( y in 0...side ) {
				var bl = grid[pivot.x][y];
				bl.y = Std.int( Num.sMod( (bl.y +dc), side) );
			}
		}
		
		for( bl in blocks ) {
			grid[bl.x][bl.y] = bl;
			var pos = getPos(bl.x, bl.y);
			bl.el.x = pos.x;
			bl.el.y = pos.y;
		}
		
		
	}
	function getLine(di) {
		var a = [];
		if( di == 0 ) 	for( x in 0...side ) a.push(grid[x][pivot.y]);
		else 			for( y in 0...side ) a.push(grid[pivot.x][y]);
		return a;
	}
	
	// BALLS
	function setBall(x, y){
		var bl = grid[x][y];
		bl.ball = new pix.Element();
		bl.ball.drawFrame(Gfx.games.get("laby_slide_ball"));
		bl.ball.x = bl.ball.y = 8;
		bl.el.addChild(bl.ball);
	
		return bl;
	}
	
	
	// CHECKEND
	function checkEnd() {
		step = 1;
		for( bl in blocks ) bl.tag = -1;
		first.tag = 0;
		paint(first);
		return last.tag >= 0;
	}
	function paint(bl:Block) {
		var a = getNeighbours(bl);
		for( nbl in a ) if( nbl.tag == -1 ) {
			nbl.tag = bl.tag + 1;
			paint(nbl);
		}
	}
	
	// END SEQUENCE
	function initEndSequence() {
		
		// PATH
		path = [];
		step = 4;
		var bl = last;
		while(true) {
			path.push(bl);
			var a = getNeighbours(bl);
			for( nbl in a ) if( nbl.tag < bl.tag ) bl = nbl;
			if( bl.tag == 0 ) {
				path.push(bl);
				break;
			}
		}
	
		
		balls = [];
		var a = [last, first];
		for( i in 0...2 ) {
			var bl = a[i];
			var ball = bl.ball;
			dm.add(ball, 2);
			ball.x = bl.el.x + 8;
			ball.y = bl.el.y + 8;
			balls.push( { el:ball, bl:bl, next:i * (path.length - 1) } );
		}
		
		coef = 1.0;
		timeProof = true;
	}
	function updateEndSequence() {
		
		coef = Math.min(coef+0.1, 1);
		var sens = 1;
		var ttx = 0;
		var tty = 0;
		for( b in balls ) {
			var next = path[b.next];
			var pos = getPos( b.bl.x + ( next.x - b.bl.x) * coef, b.bl.y + ( next.y - b.bl.y) * coef );
			b.el.x = pos.x+ 8;
			b.el.y = pos.y+ 8;
			b.el.pxx();
			if( coef == 1 ) {
				b.bl = next;
				b.next = b.next + sens;
			}
			ttx += Std.int(b.el.x*sens);
			tty += Std.int(b.el.y*sens);
			sens *= -1;
			
		}
		
		if( coef == 1 ) {
			coef  = 0;
		}
		
		if( Math.abs(ttx)+Math.abs(tty)==0) {
			step++;
			var ba = balls[1].el;
			setWin(true, 20);
			//new mt.fx.Flash(box,0.5).maj();
			new mt.fx.Flash(ba, 0.05 );
			var p = new mt.fx.ShockWave(8, 24,0.05);
			dm.add(p.root, 4);
			p.setPos( ba.x, ba.y );
		}
		
		
	}
	function getNeighbours(bl:Block) {
		var a = [];
		for( di in 0...4 ) {
			if( bl.walls[di] ) continue;
			var d = Cs.DIR[di];
			var nx = bl.x + d[0];
			var ny = bl.y + d[1];
			if( !isIn(nx, ny) )continue;
			var nbl = grid[nx][ny];
			if( !nbl.walls[(di + 2) % 4]) a.push(nbl);
		}
		return a;
	}
	

	
	
	
	// TOOLS
	function getPos (x:Float,y:Float) {
		return {
			x:mx+ x * 16,
			y:my+y * 16,
		}
	}
	function isIn(x, y) {
		return x >= 0 && x < side && y >= 0 && y < side;
	}
		
	function getDirBall(di) {
		var a = getLine(di);
		for( bl in a )	if( bl.ball != null ) return bl;
		return null;
	}

//{
}


















