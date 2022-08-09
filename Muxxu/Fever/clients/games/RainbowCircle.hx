import mt.bumdum9.Lib;
//using mt.deepnight.SuperMovie;

class RCBall extends flash.display.Sprite {
	
	
	
	public static var CX = 200;
	public static var CY = 200;
	
	public var a:Float;
	public var sa:Float;
	public var ta:Float;
	public var h:Float;
	public var swap:Bool;
	public var cid:Int;
	public var color:Int;
	public var skin:McRainBall;
	var ox:Null<Float>;
	var oy:Float;
	
	public function new(cid) {
		super();
		this.cid = cid;
		a = 0;
		h = 0;
		swap = false;
		skin = new McRainBall();
		addChild(skin);
		color = Col.getRainbow2(cid / RainbowCircle.gme.ballMax );
		Col.setColor( skin.skin, color );
	}
	
	public function setPos(an,ray,?gfx:flash.display.Graphics) {
		ray += h;
		x = CX + Math.cos(an) * ray;
		y = CY + Math.sin(an) * ray;
		
		if( gfx != null && ox!= null && ( swap || RainbowCircle.gme.win ) ){
			gfx.lineStyle(38, color);
			gfx.moveTo(ox,oy);
			gfx.lineTo(x,y);
		}
		
		ox = x;
		oy = y;
		
	}
	
	public function light() {
		Filt.glow(this, 4, 4, 0xFFFFFF,true);
		Filt.glow(this, 4, 8, 0xFFFFFF);
		Filt.glow(this, 12, 1, 0xFFFFFF);
	}
	public function unlight() {
		filters = [];
	}
}


class RainbowCircle extends Game{//}

	public static var BALL_SPACE = 20;
	public static var SWAP_SPEED = 0.1;
	public static var PLASMA_SCALE = 0.2;
	public static var gme:RainbowCircle;
	
	var balls:Array<RCBall>;
	var dec:Float;
	var coef:Float;
	public var ballMax:Int;
	public var baseRay:Float;
	
	var swap:Array<RCBall>;
	var swapSpeed:Float;
	var turn:Float;

	var plasmaModel:flash.display.Sprite;
	var plasma:flash.display.BitmapData;

	override function init(dif:Float){
		gameTime =  400;
		gme = this;
		super.init(dif);
		ballMax = 5 + Math.round(Math.pow(dif,1.5) * 8);
		baseRay = 120;
		
		turn = 0.2;
		
		var ballDiam = 38+BALL_SPACE;
		var circ = ballDiam * ballMax;
		baseRay = circ / 6.28;
		
		// BG
		var bg = new RainbowCircleBg();
		dm.add(bg,0);
		
		// CIRCLES
		balls = [];
		var a = [];
		for( id in 0...ballMax ) a.push((id / ballMax) * 6.28);
		Arr.shuffle(a);
		for( id in 0...ballMax ) {
			var mc = new RCBall(id);
			dm.add(mc,1);
			mc.a = a[id];
			balls.push(mc);
			//mc.onClick = callback(clickBall, mc);
			var me = this;
			mc.mouseChildren = false;
			mc.mouseEnabled = true;
			mc.addEventListener( flash.events.MouseEvent.CLICK, function(e) { me.clickBall(mc); } );
		}
		
		// PLASMA
		plasma = new flash.display.BitmapData(Std.int(Cs.mcw * PLASMA_SCALE), Std.int(Cs.mch * PLASMA_SCALE), true, 0);
		var bmp = new flash.display.Bitmap(plasma);
		bmp.scaleX = bmp.scaleY = 1 / PLASMA_SCALE;
		dm.add(bmp, 0);
		plasmaModel = new flash.display.Sprite();
		
		
		
		//
		dec = 0;
		swap  = [];
		balls.sort(orderBalls);
		for( b in balls ) b.setPos(b.a,baseRay);
		

	}
	
	override function update(){


		dec = (dec + turn ) % 628;
		//SWAP
		if( swap.length == 2 ) {
			coef = Math.min(coef + swapSpeed, 1);
			var c = 0.5 - Math.cos(coef*3.14) * 0.5 ;
			
			var sens = 1;
			for( b in swap ) {
				var height = 3 / swapSpeed;
				
				var da = Num.hMod(b.ta - b.sa, 3.14);
				b.a = b.sa + da * c;
				b.h = Math.sin(c* 3.14) * sens * height;
				sens = -sens;
			}
			if( coef == 1 ) {
				for(b in swap  ) {
					b.swap = false;
					b.unlight();
				}
				swap  = [];
				checkEnd();
			}
		}
	

		if( win ) {
			turn += 0.025;
			turn *= 1.15;
			baseRay += 2;
			baseRay *= 1.03;
		}
		
		// POS
		plasmaModel.graphics.clear();
		for( b in balls ) b.setPos(b.a + dec * 0.01, baseRay, plasmaModel.graphics);
		
		var m = new flash.geom.Matrix();
		m.scale(PLASMA_SCALE, PLASMA_SCALE);
		plasma.draw(plasmaModel, m);
		plasma.colorTransform(plasma.rect,new flash.geom.ColorTransform(1,1,1,1,0,0,0,-10));
		
		//SPARKS
		for( ball in balls ) {
			for( nei in balls ) {
				if( Math.abs(Num.hMod(nei.cid - ball.cid,balls.length*0.5)) != 1 && win == null ) continue;
				var dx = ball.x - nei.x;
				var dy = ball.y - nei.y;
				if( Math.sqrt(dx*dx+dy*dy) < 64 ) spark(ball, nei);
			}
		}
		
		
		//
		super.update();
		
	}
		
	// CHECK END
	function checkEnd() {
		for( b in balls ) b.a = Num.hMod(b.a, Math.PI);
		balls.sort(orderBalls);
		for( i in 0...2 ) if( checkBallRange(i * 2 - 1) ) {
			for( b in balls) {
				new mt.fx.Flash(b);
			}
			
			setWin(true, 32);
		}

		
	}
	function checkBallRange(sens) {
		var ref = balls[balls.length - 1].cid;
		for( b in balls ) {
			var dif = b.cid - ref;
			if( dif != sens && Num.sMod(dif, ballMax-1) != 0 ) return false;
			ref = b.cid;
		}
		return true;
	}
	
	
	function spark(a:RCBall,b:RCBall ) {
		var p = new mt.fx.Part( new FxRainbowSpark() );
		dm.add(p.root, 0);
		p.setPos(a.x,a.y);
		p.timer = 10;
		var color = Std.int((a.color + b.color) * 0.5);
		Col.overlay(p.root, a.color);
		
		p.root.mouseChildren = false;
		p.root.mouseEnabled = false;
		
		
		var ec = 9;
		p.x += (Math.random() * 2 - 1) * ec;
		p.y += (Math.random() * 2 - 1) * ec;
		
		var dx = b.x - a.x;
		var dy = b.y - a.y;
		
		p.vx = dx / p.timer;
		p.vy = dy / p.timer;
		//p.root.blendMode = flash.display.BlendMode.ADD;
	}
	
	
	//
	function orderBalls(a:RCBall,b:RCBall) {
		if( a.a < b.a ) return -1;
		return 1;
	}
	function clickBall(b:RCBall) {
		if( b.swap || swap.length == 2 || win != null ) return;
		swap.push(b);
		b.light();
		if( swap.length == 2 ) {
			coef = 0;
			swap[0].ta = swap[1].a;
			swap[1].ta = swap[0].a;
			swap[0].sa = swap[0].a;
			swap[1].sa = swap[1].a;
			for( b in swap ) b.swap  = true;
			var da = Num.hMod(swap[0].a - swap[1].a, 3.14);
			swapSpeed = (SWAP_SPEED * (1 + dif * 0.5)) / Math.abs(da);
			swapSpeed = Math.min(0.15,swapSpeed);
		}
		

		
		
		
	}



//{
}

