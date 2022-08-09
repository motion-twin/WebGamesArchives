package ;
import mt.bumdum9.Lib;
import flash.Lib;
import Manager;


enum GameStep {
	PLAY;
	GAMEOVER;
	TITLE;
	FADE(sens:Int);
}

class Game {//}

	public static var mcw =300;
	public static var mch = 300;
	
	public static var BASE_RAY = 9;
	
	public var elements:Array<Element>;
	public var cells:Array<Cell>;
	public var hero:Cell;
	
	public var lvl:Level;
	public var dif:mt.flash.Volatile<Int>;
	public var timer:mt.flash.Volatile<Int>;
	public var pink:flash.display.Sprite;

	
	public var click:Bool;
	public var step:GameStep;
	
	public var dm:mt.DepthManager;
	public var root:flash.display.MovieClip;

	public static var me:Game;
	
	public function new(mc:flash.display.MovieClip) {
		
		me = this;
		root = mc;
		dm = new mt.DepthManager(root);
		
		initBg();
		
		// BUT
		var but = dm.empty(15);
		but.graphics.beginFill(0, 0);
		but.graphics.drawRect(0, 0, mcw, mch);
		but.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, mouseDown);
		but.addEventListener( flash.events.MouseEvent.MOUSE_UP, mouseUp);
		KKApi.registerButton(but);
		
		// pink
		//*
		pink = new flash.display.Sprite();
		pink.graphics.beginFill(0xFF00FF);
		pink.graphics.drawRect(0, 0, mcw, mch);
		dm.add(pink, 5);
		pink.visible = false;
		pink.alpha = 0;
		pink.blendMode = flash.display.BlendMode.ADD;
		//*/
		
		
		//
		elements = [];
		
		
		dif = 0;
		teq = 0;
		//dif = 6;
	
		setTitle();
		
		//
		//Keyb.init();
		//Keyb.pressAction = finish;
		
	}
	
	var bg :flash.display.Sprite;
	public var bgScroller:flash.display.Sprite;
	public function initBg() {


		
		bg = new flash.display.Sprite();
		//bg.graphics.beginFill(0x1C1D42);
		//bg.graphics.drawRect(0, 0, mcw*2, mch*2);
		
		
		bgScroller = new flash.display.Sprite();
		bgScroller.x = mcw * 0.5;
		bgScroller.y = mch * 0.5;
		bgScroller.addChild(bg);
		
		dm.add(bgScroller, 0);
		//bgScroller.scaleX = 2;
		//bgScroller.scaleY = 2;
		
		var brush = new flash.display.Sprite();
		brush.graphics.beginFill(0x1C1D42);
		brush.graphics.drawRect(0, 0, mcw * 2, mch * 2);
		
		for( x in 0...3 ) {
			for( y in 0...3 ) {
				var bx = 1 - x;
				var by = 1 - y;
				var mc = new McBg();
				brush.addChild(mc);
				mc.x = bx * mcw;
				mc.y = by * mch;
			}
		}
		
		var sc = 2;
		
		var bmc = new flash.display.Bitmap();
		bmc.bitmapData = new flash.display.BitmapData(mcw * 4, mch * 4, false, 0x1C1D42);
		bmc.scaleX = 1/sc;
		bmc.scaleY = 1/sc;
		var m = new flash.geom.Matrix();
		m.scale(sc, sc);
		bmc.bitmapData.draw(brush,m);
		bg.addChild(bmc);
		
		
		// MATRIX
		var m = [
			1,0,0,0,0,
			0,1,0,0,0,
			0,0,1,0,0,
			0,0,0,1,0,
		];
		var m = [
			0,1,0,0,0,
			0,0,1,0,0,
			1,0,0,0,0,
			0,0,0,1,0,
		];
		
		/*
		var fl = new flash.filters.ColorMatrixFilter(m);
		//bmc.bitmapData.applyFilter(bmc.bitmapData, bmc.bitmapData.rect, new flash.geom.Point(0, 0), fl);
		root.filters = [fl];
		*/
		
		var bl = 12;
		//Filt.blur(bgScroller, bl, bl);


	}
	public function updateBg() {
		if( hero == null ) return;
		var c = 0.2;
		bg.x -= hero.vx * c;
		bg.y -= hero.vy * c;
		bg.x = Num.sMod(bg.x+mcw*1.5, mcw)-mcw*1.5;
		bg.y = Num.sMod(bg.y + mch * 1.5, mch) - mch * 1.5;
		
		
	}
	
	function bgCell() {
		//root.graphics.beginFill(0x333344);
		//root.graphics.drawRect(0, 0, mcw,mch);
		
		var color = 0x222255;
		var bmp = new flash.display.BitmapData(mcw, mch, false, color);
		
		
		var brush = new flash.display.Sprite();
		var cell = new McCell();
		brush.addChild(cell);
		
		var max = 500;
		var lastPos:Array<{x:Float,y:Float}> = [];
		for( i in 0...max ) {
			var c = i/max;
			var m = new flash.geom.Matrix();
			var sc = 0.1+c*0.5;
			m.scale(sc, sc);
			var x = 0.0;
			var y = 0.0;
			var ray = sc * 50;
			while(true) {
				x = Math.random() * mcw;
				y = Math.random() * mch;
				var ok = true;
				for( p in lastPos ) {
					var dx = Math.abs(p.x - x);
					var dy = Math.abs(p.y - y);
					if( dx < ray && dy < ray ) {
						ok = false;
						break;
					}
				}
				if( ok ) break;
			}
			
			lastPos.push( { x:x, y:y } );
			if( lastPos.length > 20) lastPos.shift();
			m.translate(x,y);
			
			var n = 10;
			var ct = new flash.geom.ColorTransform(1, 1, 1, 1, Std.random(n), Std.random(2), Std.random(n), 0);
			
			Col.setPercentColor(cell, 0.95- c * 0.3, color);
		
			bmp.draw(brush,m,ct);
		}
		
		var bl = 4;
		var fl = new flash.filters.BlurFilter(bl, bl);
		bmp.applyFilter(bmp, bmp.rect, new flash.geom.Point(0, 0),fl);
		
		
		var bg = new flash.display.Bitmap(bmp);
		dm.add(bg,0);
	}
	
	
	
	public function mouseDown(e) {
		click = true;
	}
	public function mouseUp(e) {
		click = false;
	}
	
	// LEVEL
	public function initPlay() {
		mouseUp(null);
		step = PLAY;
		timer = 0;
		//
		var dd = dif;
		if( dif > 5 ) dd = 5;
		
		// LEVEL
		if( lvl != null ) lvl.kill();
		lvl = new Level();
		dm.add(lvl, 1);
		cells = [];

		// HERO
		hero = new cell.Hero(BASE_RAY);
		//hero = new cell.Hunter(BASE_RAY);
		hero.vx = 0;
		hero.vy = 0;
		lvl.focus = hero;
		
		// HERO GUARDS
		var max = 7 - dd;
		var dst = 70;
		for( i in 0...max ) {
			var a = i / max * 6.28;
			var c = new cell.Neutral(BASE_RAY * 0.7);
			c.x = hero.x+Math.cos(a) * dst;
			c.y = hero.y+Math.sin(a) * dst;
		}
		
		// CELLS
		var max = 150 - dif * 3;
		if( max < 50 ) max = 50;
		
		for ( i in 0...max ) {
			var ray = BASE_RAY * 0.7 + Math.pow( 1-i/max, 10-dd) * (150-dd*10);
			new cell.Neutral(ray);
		}
		

		

		// ALIENS
		for( i in 0...40 )  	new cell.Survivor(BASE_RAY*0.75);
		
		var max = Std.int( Math.pow(2, dd + 1) ) ;
		for( i in 0...max )  	new cell.Hunter(BASE_RAY*0.8);

		
		
	}
	
	var coef:Float;
	var teq:Float;
	public function update() {
		
		teq += mt.Timer.tmod;
		
		var mod = 5;
		teq = Std.int(teq*mod) / mod;
		
		var max = 3;
		while(teq > 0) {
			teq--;
			updateGame();
			if( max-- == 0 ) teq = 0;
		}
		/*
		

		*/
	}
	
	public function updateGame() {
		
		//haxe.Log.clear();
		//haxe.Log.setColor(0xFFFFFF);
		//lvl.tracer.graphics.clear();
		//trace("!");
		
		if( pink.alpha > 0 ) {
			pink.alpha *= 0.95;
			pink.visible = true;
			if( pink.alpha < 0.01 ) {
				pink.alpha = 0;
				pink.visible = false;
			}
			
		}
		
		switch(step) {
			case FADE(sens):
				fader.alpha = Num.mm(0,fader.alpha + sens * 0.1, 1);
				if( fader.alpha == 1 ) {
					fader.visible = false;
					setTitle();
				}
				if( fader.alpha == 0 ) {
					fader.visible = false;
					step = PLAY;
				}
				
				updatePlay();
				
			case TITLE :
				timer++;
				if( timer == 50 ) {
					initPlay();
					title.play();
				}
				
			case PLAY :
				updatePlay();
				if( cells.length == 1 ) finish();
				else if(hero.dead) 		gameover();
				
			case GAMEOVER :
				updatePlay();
		}
		
		// CELLS
		var a = mt.bumdum9.Sprite.spriteList;
		for( sp in a ) sp.update();
		
		// ELEMENTS
		var a = elements.copy();
		for( sp in a ) sp.update();
		
	}
	
	
	function updatePlay() {
		timer++;
		var a = cells.copy();
		for ( c in a ) c.update();
		updateCellCols();
		if(lvl!=null)lvl.scroll();
		updateBg();
	}
	
	// FADE
	var fader:flash.display.Sprite;
	function finish() {
		dif++;
		fade(1);
	}
	function fade(sens) {
		step = FADE(sens);
		if( fader == null ) {
			fader = new flash.display.Sprite();
			fader.graphics.beginFill(0);
			fader.graphics.drawRect(0, 0, mcw, mch);
			dm.add(fader, 9);

		}
		fader.visible = true;
		fader.alpha = 1;
		if( sens == 1 ) fader.alpha = 0;
	}
	
	var title:McTitle;
	function setTitle() {
		step = TITLE;
		title = new McTitle();
		title.phase.field.text = "phase #" + (dif+1);
		title.addFrameScript(36, endTitle );
		dm.add(title, 2);
		timer = 0;
	}
	function endTitle() {
		title.parent.removeChild(title);
		fade( -1);
	}
	
	
	// GAMEOVER
	public function gameover() {
		
		step = GAMEOVER;
		KKApi.gameOver({});
	}
	
	// PLAY
	public function updateCellCols() {
		
		var a = cells.copy();
		for( i in 0...a.length ) {
			var c = a[i];
			for( n in (i+1)...a.length ) c.checkCols( a[n] );
			c.updatePos();
		}
	}
	
	

	static function main() {
		
	}
	
	

	
//{
}