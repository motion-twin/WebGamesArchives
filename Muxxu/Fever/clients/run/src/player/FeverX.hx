package player;
import Protocole;
import mt.bumdum9.Lib;



class FeverX extends Player {//}
	
	static var DISPLAY_TIME_LIMIT = 160;
	static var CARTRIDGE_HEIGHT = 100;
	
	var carts:Array<_Cartridge>;
	var currentCart:_Cartridge;
	var mcCart : pix.Element;
	
	var console:flash.display.Sprite;
	var ball:pix.Element;
	var step:Int;
	var coef:Float;
	var temp:Int;
	var timer:Int;

	var logo:FeverLogo;
	var page:flash.display.Sprite;
	public var pdm:mt.DepthManager;
	public var buts:Array<FVBut>;
	
	var screen:flash.display.Sprite;
	var sdm:mt.DepthManager;
	var bar: FVBar;
	var faderScreen:flash.display.Bitmap;
	var switchGame:Bool;
	
	var tw:Tween;
	var cid:Int;
	var cartridges:Array< {bg:pix.Element,art:McGameIcon}>;
	var sens:Int;
	var click:Void->Void;
	
	static public var me:FeverX;
	
	public function new(carts) {
		me = this;
		super();
		
		haxe.Log.setColor(0xFF0000);
		this.carts = carts;

		initInter();
		temp = 0;
		initSelector();
	}
	
	// INTERFACE
	var cdm:mt.DepthManager;
	var bg:flash.display.Sprite;
	function initInter() {
	
		// BG
		bg = new flash.display.Sprite();
		bg.graphics.beginFill(0);
		bg.graphics.drawRect(0, 0, Cs.mcw, Cs.mcrh);
		bg.addEventListener( flash.events.MouseEvent.CLICK, clickBg );
		addChild(bg);
		
		// CONSOLE
		console = new flash.display.Sprite();
		console.x = Cs.mcw * 0.5;
		console.y = Cs.mcrh * 0.5;
		addChild(console);
		cdm = new mt.DepthManager(console);
		
		var el = new pix.Element();
		el.drawFrame(Gfx.mod.get("fever_x_back"));
		el.scaleX = el.scaleY = 2;
		el.y -= 168;
		cdm.add(el, 0);
		
		var el = new pix.Element();
		el.drawFrame(Gfx.mod.get("fever_x"));
		el.scaleX = el.scaleY = 2;
		cdm.add(el, 2);
		
		console.y = Cs.mcrh + console.height * 0.5;
		
		//
		ball = new pix.Element();
		ball.drawFrame(Gfx.mod.get("fever_x_click"),0,0);
		ball.scaleX = ball.scaleY = 2;
		cdm.add(ball, 2);
		ball.x = -40;
		ball.y = 72;
		ball.visible = false;
		
		// SCREEN
		screen = new flash.display.Sprite();
		screen.x = -100;
		screen.y = -148;
		screen.scaleX = screen.scaleY = 0.5;
		sdm = new mt.DepthManager(screen);
		cdm.add(screen, 3);
		
		// MASK
		var screenMask = new flash.display.Sprite();
		screenMask.x = screen.x;
		screenMask.y = screen.y;
		screenMask.graphics.beginFill(0xFF0000);
		screenMask.graphics.drawRect(0, 0, 200, 200);
		cdm.add(screenMask, 3);
		screen.mask = screenMask;
		
	}

	// UPDATE
	override function update(?e:Dynamic) {
		/*
		haxe.Log.clear();
		haxe.Log.setColor(0xFFFFFF);
		trace(bg.mouseEnabled);
		*/
		
		super.update(e);
		timer++;
		switch(step) {
			
			case 10 : // SELECTOR
				coef = Math.min(coef + 0.05, 1);
				var c = 0.5 - Math.cos(coef * 3.14) * 0.5;
				var p = tw.getPos(c);
				console.x = p.x;
				console.y = p.y;
				if( coef == 1 ) initCartridges();
				
			case 11 : // SELECTOR - WAIT
			
			case 12 : // SELECTOR - MOVE
				coef = Math.min(coef + 0.15, 1);
				var c = 0.5-Math.cos(coef*3.14)*0.5;
				var id = 0;
				
				if( coef == 1 ) {
					cid = Std.int( Num.sMod(cid - sens, carts.length) );
					paintCarts();
					c = 0;
					step = 11;
				}
				for( o in cartridges ) {
					o.bg.x =getCartPos(id +c * sens);
					id++;
				}
				
			case 13 : // SELECTOR - INSERT
				coef = Math.min(coef + 0.1, 1);
				var c = Math.pow(coef, 2);
				var p = tw.getPos(c);
				
				var cart = cartridges[2];
				cart.bg.x = p.x;
				cart.bg.y = p.y;
				
				// REMOVE SIDE
				for( i in 0...2 ) {
					var cart = cartridges[1 + i * 2];
					var sens = i * 2 - 1;
					cart.bg.x = Cs.mcw * 0.5 + sens * (180 + c * 180);
				}
				if( coef == 1 ) {
					for( ca in cartridges ) {
						if( ca.bg == mcCart ) continue;
						ca.bg.parent.removeChild(ca.bg);
					}
					var fx = new mt.fx.Tween(console, Cs.mcw * 0.5, Cs.mch * 0.5 + 20);
					fx.onFinish = reset;
					fx.curveInOut();
					step = -1;
				}
				
				
			
			case 0 :	// LOADING
				coef = Math.min(coef + 0.025, 1);
				Col.setPercentColor(screen, Math.pow(coef, 2), 0xFFFFFF);
				if( coef == 1 ) {
					step++;
					coef = 0;
					logo = new FeverLogo();
					sdm.add(logo,0);
					logo.x = 200;
					logo.y = 200;
					logo.scaleX = logo.scaleY = 2;
					Col.setColor(screen, 0, 0);
					setScreenBg(0xFFFFFF);
				}
			
			case 1 :
				coef = Math.min(coef + 0.01, 1);
				if( coef == 1 ) {
					coef = 0;
					step++;
				}
			
			case 2 :
				coef = Math.min(coef + 0.09, 1);
				Col.setColor(screen, 0, -Std.int(coef*255));
				if( coef == 1 ) {
					screen.removeChild(logo);
					displayTitleScreen();
				}
				
			case 3 :	// TITLE SCREEN
				
			case 4 : // GAME
				if( game.gameTime < DISPLAY_TIME_LIMIT ) 	bar.displayTimer(game.gameTime);
				ball.visible = game.click;
				game.update();

				/*
				var cx  = ((mouseX / Cs.mcw) * 2 - 1);
				var cy  = ((mouseY / Cs.mcw) * 2 - 1);
				console.rotation = cx * 10;
				console.x = Cs.mcw*0.5 + cx * 30;
				console.y = Cs.mcrh * 0.5 + cy * 30;
				*/
			
			case 5 : updateFader();
				
				
		}
	}

	// CLICK BG
	function clickBg(e) {
		if( click == null ) return;
		click();
	}
	
	// RESET
	function reset() {
		step = 0;
		coef = 0;
		setScreenBg(0x333333);
		click = initSelector;
		
	}
	
	// SELECTOR
	function initSelector() {
		
		click = null;
		
		// clean ALL
		screen.graphics.clear();
		Col.setColor(screen, 0, 0);
		sdm.destroy();
		
		//
		step = -1;
		var fx = new mt.fx.Tween(console, Cs.mcw * 0.5, 364 );
		fx.curveInOut();
		fx.onFinish = initCartridges ;
		
	}
	function initCartridges() {
		
		if( mcCart != null ) {
			removeCartridge();
			return;
		}
		
		click = leave;
		
		step = 11;
		cid = 0;
		for( id in 0...carts.length ) {
			if( carts[id] != currentCart ) continue;
			cid = id;
			break;
		}
		
		cartridges = [];
		var ray = 2;
		for( dd in 0...2*ray + 1) {
			var cart = new pix.Element();
			cart.scaleX = cart.scaleY = 2;
			cart.drawFrame(Gfx.mod.get("cart"));
			cart.x = getCartPos(dd);
			cart.y = CARTRIDGE_HEIGHT;
			var art = new McGameIcon();
			art.alpha = 0.8;
			art.x = -11;
			art.y = -31;
			art.width = 38;
			art.scaleY = art.scaleX;
			addChild(cart);
			cart.addChild(art);
			cartridges.push( { bg:cart, art:art } );
			var me = this;
			switch(dd) {
				case 2 :		cart.addEventListener( flash.events.MouseEvent.CLICK, selectCart );
				case 1,3 :	cart.addEventListener( flash.events.MouseEvent.CLICK, function(e) { me.moveCart(2-dd); } );
				
			}
			
		}
		paintCarts();
	}
	function removeCartridge() {

		var fx = new mt.fx.Tween( mcCart, getCartPos(2)-console.x, CARTRIDGE_HEIGHT-console.y );
		fx.curveInOut();
		var me = this;
		fx.onFinish = function() {
			me.mcCart.parent.removeChild(me.mcCart);
			me.mcCart = null;
			me.initCartridges();
		}
		step = -1;
	}
	
	function getCartPos(dd:Float) {
		return Cs.mcw * 0.5 + (dd -2) * 180;
	}
	function paintCarts() {
		var ray = 2;
		for( dd in 0...2*ray + 1 ) {
			var o = cartridges[dd];
			var id =  Std.int(Num.sMod(cid+dd-2, carts.length));
			o.art.gotoAndStop(carts[id]._id + 1);
		}
	}
	function selectCart(e) {
		if( step != 11 ) return;
		step = 13;
		coef = 0;
		currentCart = carts[cid];
		//
		var cart = cartridges[2];
		cart.bg.parent.removeChild(cart.bg);
		cdm.add(cart.bg, 0);
		cart.bg.x -= console.x;
		cart.bg.y -= console.y;
		tw = new Tween(cart.bg.x, cart.bg.y, 0, -116);
		mcCart = cart.bg;
		//
	}
	function moveCart(sens) {
		if( step != 11 ) return;
		this.sens = sens;
		coef = 0;
		step = 12;
	}

	// PAGE
	public function newPage() {
		step = 3;
		timer =  0;
		if( page != null ) cleanPage();
		buts = [];
		page = new flash.display.Sprite();
		page.scaleX = page.scaleY = 4;
		sdm.add(page,0);
		pdm = new mt.DepthManager(page);
	}
	function cleanPage() {
		if( page.parent == null ) return;
		page.parent.removeChild(page);
		page = null;
		pdm = null;
		while(buts.length > 0) buts.pop().kill();
	}
	
	function displayTitleScreen() {
		
		if( !havePlay() ) {
			leave();
			return;
		}

		click = initSelector;

		Col.setColor(screen, 0, 0);
		setScreenBg(0);
		
		newPage();
		setCartTitle( Data.DATA._games[currentCart._id]._name );
				
		var a = Lang.FEVER_X_LABELS;
		for( i in 0...2 ){
			var but = new FVBut(a[i]);
			but.x = 36;
			but.y = 64 + i * 12;
			but.rollOverType = 1;
			but.setAction( i == 0?launchGame:displayStage );
		}

		
		
				
		
	}
	function setCartTitle(str) {
		
		var bg = new flash.display.Sprite();
		bg.y = 8;
		bg.graphics.beginFill(0);
		bg.graphics.drawRect(0, 0, 100, 16);
		bg.graphics.beginFill(0xFFFFFF);
		bg.graphics.drawRect(0, 1, 100, 1);
		bg.graphics.drawRect(0, 14, 100, 1);
		pdm.add(bg, 1);
		
		var field = Cs.getField(0xFFFFFF, 20, -1, "upheaval");
		pdm.add(field, 1);
		field.y = 4;
		field.text = str;
		field.width =  field.textWidth + 3;
		field.x =  (100 - field.width) * 0.5;
		

		
		/*
		for( i in 0...2 ) {
			var y = 10 + i * 16;
			page.graphics.lineStyle(1, 0xFFFFFF);
			page.graphics.moveTo(0, y);
			page.graphics.lineTo(100, y);
		}
		*/
		
		// GRADIENT
		
		var seed = new mt.Rand(currentCart._id*1000);
		var col = Col.getRainbow(seed.rand());
		for( i in 0...2 ) {
			var color = col;
			if( i == 0 ) color = Col.brighten(color, -100);
			var mc = getGrad(color,30-i*15);
		}
		
		
		
	}
	function getGrad(color,ymax) {
		var grad = new flash.display.Sprite();
		pdm.add(grad,0);
		for( x in 0...25 ) {
			for( y in 0...ymax ) {
				var c = y / ymax;
				var p = new pix.Element();
				var n = Std.int( c * 7 );
				n += Std.random(3) - 1;
				n = Num.clamp(0, n, 6);
				if( n<6 )p.drawFrame(Gfx.mod.get(n, "gradient_blocks"),0,0);
				grad.addChild(p);
				p.x = x * 4;
				p.y = y * 4;
			}
		}

		Col.setColor(grad,color);
	}
	
	function setTitle(str) {
		var field = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		pdm.add(field, 1);
		field.y = 6;
		field.text = str;
		field.width =  field.textWidth + 3;
		field.x =  (100 - field.width) * 0.5;
		return field;

	}
	
	function displayStage() {
		
		newPage();
		
		setTitle(Lang.SELECT_STEP);
		
		// BUTS
		var ec = 5;
		var max = 20;
		for( i in 0...max ) {
			var active = i*ec <= currentCart._lvl;
			var str = Std.string(i * ec);
			while(str.length < 2) str = "0" + str;
			
			var but = new FVBut( str,0,active?0xAAAAAA:0x333333 );
			but.x = 10 + (i % 5)*16;
			but.y = 36 + Std.int(i / 5) * 14;
			if( active ) {
				
				but.setAction( callback(selectLevel,i) );
				but.rollOverColor = 0xFFFFFF ;
				but.rollOverType = -1;
			}
			
		}
	}
	function selectLevel(id) {
		temp = id*5;
		launchGame();
	}

	// GAME
	function launchGame() {
		
		if( World.me != null ){
			World.me.send(_FeverXPlay);
			world.Inter.me.majStatus();
			World.me.screen.update();
			drawWorldBg();
		}
		
		//
		click = null;
		cleanPage();
		
		// INTER
		bar = new FVBar();
		sdm.add(bar, 3);
		
		newGame(currentCart._id);
		step = 4;
		
		
		
	}
	override function newGame(id) {
		//if( game != null ) game.kill();
		dif = temp * 0.01;
		super.newGame(id);
		sdm.add(game,1);
		game.active = true;
	}
	
	function initFader() {
		step = 5;
		coef = 0;
		game.visible  = false;
		faderScreen = new flash.display.Bitmap();
		faderScreen.bitmapData = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0);
		sdm.add(faderScreen,2);
		switchGame = true;
		timer = 0;
		
		updateFader();
	}
	function updateFader() {
		if(timer % 2 != 0) return;
		
		
		coef = Math.min(coef + 0.04, 1);
		
		if( coef > 0.5 && switchGame ) {
			switchGame = false;
			newGame(currentCart._id);
			game.visible = false;
			bar.reset();
			bar.setTemp(temp);
		}
		
		var c =  Math.sin(coef * 3.14);
		c = Math.pow(c, 0.5);
		

		var lim = 0.01;
		var sc = lim + (1 - c) * (1 - lim);
		//var sc = 1 - c;
		//var lim = 0.01;
		//if( sc < lim ) sc = lim;
		

		
		
		var bmp = faderScreen.bitmapData;
		if( sc < 0.1  && bmp.width > Cs.mcw *0.1 ) 	faderScreen.bitmapData = new flash.display.BitmapData(40,40,false,0);
		if( sc >= 0.1  && bmp.width < Cs.mcw ) 		faderScreen.bitmapData = new flash.display.BitmapData(400,400,false,0);

		var m = new flash.geom.Matrix();
		m.scale(sc, sc);
		faderScreen.bitmapData.draw( game, m);
		faderScreen.scaleX = faderScreen.scaleY = 1 / sc;
		
		
		if( coef == 1 ) {
			
			game.visible = true;
			faderScreen.bitmapData.dispose();
			screen.removeChild(faderScreen);
			step  = 4;
			bar.hideTemp();
			
		}
		
	}
	
	override function endGame() {
		
		if( !game.win ) {
			gameOver();
			return;
		}
		
		temp++;
		initFader();
		
		//newGame(currentCart._id);
		//new mt.fx.Flash(game);
	}
			
	function gameOver() {
		game.kill();
		game = null;
		bar.parent.removeChild(bar);
		bar = null;
		
		haxe.Timer.delay(displayTitleScreen, 2000);
		
		newPage();
		var field = setTitle("game over");
		field.y = 42;
		
		var maj = false;
		if( temp > currentCart._lvl ){
			currentCart._lvl = temp;
			maj = true;
		}
		//
		if( World.me == null ||  !maj ) return;
		World.me.send( _MajCartridge( currentCart ) );
	
		
	}
	
	// LEAVE
	function leave() {
		step = -1;
		click = null;
		var fx = new mt.fx.Tween(console, Cs.mcw * 0.5, Cs.mcrh + console.height*0.5,0.05);
		fx.curveInOut();
		fx.onFinish = kill;
		
		for( ca in cartridges ) {
			var fx = new mt.fx.Tween(ca.bg, ca.bg.x, -80);
			fx.curveInOut();
		}
	}
	
	override function kill() {
		super.kill();
		if( World.me == null ) return;
		World.me.leaveFeverX();
		
	}
	
	
	//
	function havePlay() {
		#if dev
		if( World.me == null ) return true;
		#end
		return world.Loader.me.haveFeverXPlay();
		
		//var data =  world.Loader.me.data;
		//return data._plays + data._dailyPlays > 0;
		
	}
	
	// SCREEN TOOLS
	function setScreenBg(color) {
		screen.graphics.clear();
		screen.graphics.beginFill(color);
		screen.graphics.drawRect(0, 0, 400, 400);
	}
	public function drawWorldBg() {
		var bmp = World.me.screen.bitmapData;
		var b = new flash.display.Bitmap(bmp);
		b.scaleX = b.scaleY = 2;
		bg.addChild(b);
		
		var c = 0.2;
		var h = 13;
		var rect = new flash.geom.Rectangle(0, h, Cs.mcw * 0.5, Cs.mcrh * 0.5 - h);
		bmp.colorTransform(rect, new flash.geom.ColorTransform(c, c, c, 1, 0, 0, 0, 0));
		
		//Col.setPercentColor(bg, 0.8, 0);
	}
	

//{
}







class FVBar extends flash.display.Sprite {//}
	var timer:flash.display.Sprite;
	var bricks:Array<pix.Element>;
	var field:flash.text.TextField;
	
	public function new() {
		super();
		scaleX = scaleY = 4;

		// FIELD
		field = new flash.text.TextField();
		field = Cs.getField(0xFFFFFF, 8, 1, "nokia");
		field.background = true;
		field.backgroundColor = 0;
		field.y = -1;
		field.visible = false;
		// TIMER
		bricks = [];
		timer = new flash.display.Sprite();
		for( i in 0...4 ) {
			var el = new pix.Element();
			timer.addChild(el);
			bricks.push(el);
			el.x = i * 7;
		}
		
		// ADD
		addChild(timer);
		addChild(field);
		
	
	}
	
	public function setTemp(n) {
		field.text = Std.string(n);
		field.visible = true;
		field.width = field.textWidth + 3;
		field.x = 100 - field.width;
		field.height = field.textHeight + 2;
	}
	
	public function displayTimer(t:Float) {
		timer.visible = true;
		var max = 4;
		var k = t;
		for( i in 0...max ) {
			var el = bricks[i];
			var fr = 2;
			if( k > 20 ) fr = 1;
			if( k > 40 ) fr = 0;
			k -= [40, 20, 0][fr];
			el.drawFrame(Gfx.mod.get(fr,"timer_brick"),0,0);
		}
		
	}
	
	public function reset() {
		timer.visible = false;
	}
	public function hideTemp() {
		field.visible = false;
	}
	

//{
}




class FVBut extends flash.display.Sprite {//}
	
	static var HH = 10;
	
	var field:flash.text.TextField;
	var box:flash.display.Sprite;
	var color:Int;
	var action:Void->Void;
	
	public var rollOverType:Int;
	public var rollOverColor:Null<Int>;
	public var textColor:Int;
	
	public function new(str,color=0,textColor=0xFFFFFF) {
		super();
		this.textColor = textColor ;
		this.color = color;
		player.FeverX.me.buts.push(this);
		player.FeverX.me.pdm.add(this,1);
		
		rollOverType = 0;
		
		box = new flash.display.Sprite();
		addChild(box);
		
		field = Cs.getField(textColor, 8, -1, "nokia");
		field.y = -2;
		field.text = str;
		field.width = field.textWidth + 3;
		field.height = HH + 4;
		
		addChild(field);
		setBox(field.width, HH);


	}
	public function setAction(ac:Void->Void) {
		action = ac;
		
		addEventListener(flash.events.MouseEvent.ROLL_OVER, rollOver );
		addEventListener(flash.events.MouseEvent.ROLL_OUT, rollOut );
		addEventListener(flash.events.MouseEvent.CLICK, click );
	}
		
	public function setBox(ww,hh) {
		box.graphics.clear();
		box.graphics.beginFill(color);
		box.graphics.drawRect(0, 0, ww, hh);
		
	}
	
	var arrow:pix.Element;
	public function rollOver(e) {
		//action();
		if( rollOverColor != null ) field.textColor = rollOverColor;
		
		switch(rollOverType) {
			case 0 :	alpha = 0.5;
			case 1 :
				if( arrow == null ) {
					arrow = new pix.Element();
					arrow.drawFrame(Gfx.mod.get("arrow"));
					arrow.x = -4;
					arrow.y = 6;
					addChild(arrow);
				}
				arrow.visible = true;
		}
		
	}
	public function rollOut(e) {
		if( rollOverColor != null ) field.textColor = textColor;
		switch(rollOverType) {
			case 0 :	alpha = 1;
			case 1 :	arrow.visible = false;
		}
	}
	public function click(e) {
		
		if(action!=null)action();
	}
	
	
	public function kill() {
		
		if( action != null ){
			removeEventListener(flash.events.MouseEvent.ROLL_OVER, rollOver );
			removeEventListener(flash.events.MouseEvent.ROLL_OUT, rollOut );
			removeEventListener(flash.events.MouseEvent.CLICK, click );
		}
		player.FeverX.me.buts.remove(this);
		
	}

	
	
//{
}







