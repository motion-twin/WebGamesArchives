import mt.bumdum9.Lib;
import Protocole;



class Browser {//}
	
	public static var DP_BG = 			0;
	public static var DP_FG = 			1;
	public static var DP_BG_INTER = 		2;
	public static var DP_CARDS = 		3;
	public static var DP_INTER = 		4;
	
	public static var TOP_BAR = 0; //14
	public static var DESC_BAR = 11;
	public static var TUTO_PLAY = 16;
	
	public var params:Array<Bool>;
	
	public var hand:Array<browser.HandCard>;
	public var handCards:Array<browser.HandCard>;
	var data:_DataBrowser;
	var screen:pix.Screen;
	public var nav:browser.Nav;
	public var fieldMojo:flash.text.TextField;
		
	public var mojoTotal:Int;
	public var mojoMin:Int;
	public var mojoMax:Int;
	public var mojoBox:browser.MojoBox;
	public var action:Void->Void;
	
	public var bg:pix.Element;
	public var bgf:pix.Element;
	public var bgf2:pix.Element;
	
	public var root:flash.display.Sprite;
	public var dm:mt.DepthManager;
	public var fxm:mt.fx.Manager;
	public static var me:Browser;
	
	public static var TEST = 0;
	
	public function new(data:_DataBrowser) {
		me = this;
		root = new flash.display.Sprite();
		dm = new mt.DepthManager(root);
		fxm = new mt.fx.Manager();
				
		mojoTotal = 0;
		mojoMin = Data.MOJO_PLAY;
		mojoMax = Data.MOJO_PLAY;
		hand = [];
		handCards = [];
		
		//
		this.data = data;
		initBg();
		
		// MOJOBOX
		mojoBox = new browser.MojoBox();
		buts = [];

		// FORMAT PARAMS
		var so = flash.net.SharedObject.getLocal("snake");
		if( so.data.controlType == null ) {
			so.data.controlType = 0;
			so.data.gore = data._age == null || data._age >= 12;
		}
		
		// SCREEN
		var sc = 2;
		screen = new pix.Screen(root, Cs.mcw*sc, Cs.mch*sc, sc) ;
		Main.dm.add(screen, 1);
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.CLICK, click );
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);
		//
		
	}
	
	function initNav() {
		nav = new browser.Nav();
		nav.root.y = TOP_BAR;
		nav.set( data._cards );
	}
	function initBg() {
		
		bg = new pix.Element();
		bg.drawFrame( Gfx.browser.get(0),0,0 );
		dm.add(bg, DP_BG);
		
		bgf = new pix.Element();
		bgf.drawFrame( Gfx.browserFront.get(0),0,0 );
		dm.add(bgf, DP_INTER);
		
		bgf2 = new pix.Element();
		bgf2.drawFrame( Gfx.browserFront.get(1), 0, 0 );
		bgf2.y = browser.Nav.HEIGHT;
		dm.add(bgf2, DP_FG);
		
	}
	
	var fieldTuto:flash.text.TextField;
	public function majInter() {
		majTuto();
		mojoBox.setValue( mojoMax - mojoTotal );
		
	}
	public function majTuto() {
		if( data._plays >= TUTO_PLAY ) return;
		
		if( fieldTuto == null ) {
			fieldTuto = Cs.getField(0xFFFFFF, 8, -1, "nokia");
			dm.add(fieldTuto, DP_INTER);
			fieldTuto.y = mojoBox.y + 65;
			fieldTuto.visible = false;
		}
		var str = "";
		var sum = 0;
		for( hc in hand ) {
			if(hc.leave) continue;
			var n = hc.card.data.mojo;
			sum += n;
			if( str.length > 0 && n >= 0 )	str += "+";
			if( str.length > 0 && n < 0 ) {
				str += "-";
				n = Std.int(Math.abs(n));
			}
			str += n;
		}
		if(str.length == 0) str = "0";
		var max = Cs.MAX_MOJO;

		if( sum < max ) 		str = Lang.CARD_LEFT+str+" < " + max;
		else if( sum > max ) 	str = Lang.CARD_FULL+str+" > " + max;
		else str =  Lang.START_GAME;
		
		fieldTuto.text = str;
		fieldTuto.width = fieldTuto.textWidth + 3;
		fieldTuto.x = Std.int((Cs.mcw - fieldTuto.width) * 0.5);
		
	}
	
	// UPDATE
	public function update(e) {
		if(action != null) action();
		
		var a = pix.Sprite.all.copy();
		for( sp in a ) sp.update();

		for( b in buts ) b.checkOut();
		for( b in buts ) b.checkIn();

		
		fxm.update();
		updateScroller();
		screen.update();
	}
	function updateSelection() {
		nav.update();
		updateHand();
	}
	function updateMojoBox() {
		if( mojoBox == null || fieldTuto == null ) return;
		fieldTuto.visible =  mojoBox.over;
	}
	
	// ACTIONS
	function updateBrowser() {
		updateSelection();
	}
	
	
	// HAND
	var selection:browser.HandCard;
	public function updateHand() {
		
		var xm = root.mouseX * 0.5;
		var ym = root.mouseY * 0.5;
		
		var sel = null;
		for( hc in hand ) {
			hc.update();
			if( hc.tween == null && Math.abs( hc.x - xm) < Card.WIDTH*0.5 && Math.abs( hc.y - ym) < Card.HEIGHT*0.5 ) 	sel = hc;
		}
		if( sel != selection ) {
			unselect();
			if( sel != null ) select(sel);
		}
		
		// MOJO BOX
		mojoBox.update();
		
	}
	public function select(hc:browser.HandCard) {
		selection = hc;
		selection.card.fxOver();
		displayHint(selection.card.getDesc());
	}
	public function unselect() {
		if( selection == null ) return;
		selection.card.fxOut();
		selection = null;
		removeHint();
	}
	
	public function click(e) {
		if( nav!=null && nav.active ) {
			nav.click();
			return;
		}
		
		if( selection != null ) removeCard(selection);
		
		if(mojoBox.isAction() ) {
			initFade();
			
			#if dev
			var str = "";
			var a = Type.getEnumConstructs(_CardType);
			for( n in a ) str += n + ";";
			flash.system.System.setClipboard(str);
			#end
		}
	}
	
	public function addCard(hc:browser.HandCard) {
		
		for( hc in Browser.me.hand ) if( !hc.leave ) hc.moveToHand();
		testHandMax();
		mojoBox.majPos();
		incMojoTotal( hc.card.mojo);
		
		
	}
	public function removeCard(hc:browser.HandCard) {
		var pos = nav.getSlotPos(hc.data);
		var lim = 60;
		pos.x = Num.mm( -lim, pos.x, Cs.mcw + lim);
		hc.moveTo( pos.x, pos.y );
		hc.onDest = hc.insertInPool;
		hc.leave = true;
		dm.over(hc);
		var id = 0;
		for( hc in hand ) {
			if( !hc.leave ){
				hc.id = id;
				hc.moveToHand();
				id++;
			}
		}
		mojoBox.majPos();
		
		incMojoTotal( -hc.card.mojo);
	
	}
		
	public function getHandY() {
		return TOP_BAR + browser.Nav.HEIGHT + DESC_BAR + 26;
	}
	public function getHandTotal() {
		var max = 0;
		for( hc in hand ) if(!hc.leave) max++;
		return max;
	}
	public function getStaticHand() {
		var h = [];
		for( hc in hand ) if(!hc.leave) h.push(hc);
		return h;
	}
	public function incMojoTotal(inc) {
		mojoTotal += inc;
		mojoBox.setReady( mojoTotal >= mojoMin && mojoTotal <= mojoMax );
		majInter();
	}
	public function getHandMax() {
		var max = Cs.MAX_HAND;
		var a = [];
		for( hc in hand ) a.push( hc.card.type);
		for( type in a ) {
			if( type == PICK_AXE )	max = 3;
			if( type == BOUNTY ) 	max = 3;
			if ( type == TRAINING ) 	return 1;
		}
		return max;
	}
	function testHandMax() {
		while( getHandMax() < getStaticHand().length ) {
			removeCard(getStaticHand()[0]);
		}
		
	}
	
	// FADE
	var coef:Float;
	function initFade() {
		
		action = updateFade;
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.CLICK, click );
		coef = 0;
		
		if( fieldTuto != null ) fieldTuto.alpha = 0;
		
		// HAND
		for( hc in hand ) hc.moveToGamePos();
	
	}
	function updateFade() {
		
		coef = Math.min(coef + 0.05, 1);
		for( hc in hand ) hc.update();
	
		nav.root.y -= Std.int(coef * 32);
		mojoBox.alpha = 1-coef*2;
		
		Col.setPercentColor(bg, coef, Gfx.col("green_1"));
		
		var late = Num.mm(0, coef * 2 - 1, 1);
		bgf.y -= late* 20;
		bgf2.y += late* 20;

		
		if(coef == 1) {
			initLoading();
		}
		
	}
	
	// LOADING
	function initLoading() {
		action = null;
		var box = Cs.getLoadingBox();
		
		dm.add(box.base, DP_BG_INTER);
		
		var cards = [];
		for( hc in hand ) cards.push(hc.card.type);
		var data:_GStartSend = { _cards:cards };

		#if dev
			var me = this;
			haxe.Timer.delay( function() { me.launch( { _id:Std.random(9999), _gid:Std.random(9999), _cards:[] } ); }, 1000 );
		#else
			Codec.load(Main.domain + "/start", data, launch) ;
		#end
		
	}
	function launch(data:_GStartReceive) {
		switch( data._id ) {
			case null :	displayError( "invalid GStartSend" );
			case -1 : 		displayError( "no selected cards" );
			case -2 : 		displayError( "invalid actions points check" );
			case -3 : 		displayError( "selected cards cant be used" );
			case -4 :		displayError("it's too late for play in tournament") ;
		}
		if( data._id == null || data._id < 0 ) return;
		
		//var cards = [];
		//for( hc in hand ) cards.push(hc.card.type);
		kill();
		Main.launchGame(data._id, data._cards, data._gid /*Std.random(999)*/) ;
	}
	function displayError(str) {
		trace(str);
	}
	
	// HINT
	var mcHint:flash.display.Sprite;
	public function displayHint(str:String,alpha=1.0,warning=false) {
		
		//str = Lang.killLatin(str.toUpperCase());
		//str = Lang.killLatin(str);
		
		if( mcHint != null ) removeHint();
		mcHint = new flash.display.Sprite();
		dm.add(mcHint, DP_BG_INTER);
		
		var y = TOP_BAR +  browser.Nav.HEIGHT;
		
		// DESCRIPTION
		var color = warning?0xFF0000:0xFFFFFF;
		var tf = Cs.getField(color, 8, -1, "nokia");
		tf.multiline = tf.wordWrap = true;
		mcHint.addChild(tf);
		tf.width = Cs.mcw;	
		tf.htmlText = str;
		tf.width = tf.textWidth + 6;	
		tf.height = tf.textHeight + 8;
		tf.x = Std.int((Cs.mcw-tf.width)*0.5);
		//tf.x = 4;
		tf.y = 9+y-Std.int(tf.textHeight*0.5);
		
		
		tf.filters = [];
		tf.alpha = alpha;
		
		
		if( alpha < 1 ) tf.blendMode = flash.display.BlendMode.ADD;
		else tf.filters = [ new flash.filters.DropShadowFilter(1, 90, Gfx.col("green_1"), 1, 0, 0, 100)];
		
		//
		if(warning) new mt.fx.Blink(tf,40,4,4);
		
	}
	public function removeHint() {
		if( mcHint == null ) return;
		mcHint.parent.removeChild(mcHint);
		mcHint = null;
	}

	// SCROLLER
	var gt:Int;
	var scrollMod:Int;
	var scroll:flash.display.Sprite;
	function initScroller(str) {
		scroll = new flash.display.Sprite();
		scroll.y = Cs.mch - 12;
		dm.add(scroll, DP_BG_INTER);
		gt = 0;
		scrollMod = 0;
		for( i in 0...3 ) {
			var f = Snk.getField(0xFFFFFF, 8, -1, "nokia");
			f.text = str;
			f.width = f.textWidth + 3;
			if( scrollMod == 0 ) scrollMod = Std.int(f.width);
			f.x = scrollMod * i;
			scroll.addChild(f);
			//f.blendMode = flash.display.BlendMode.OVERLAY;
			//f.filters = [ new flash.filters.GlowFilter(0,1,2,2,4)];
		}
		//scroll.alpha = 20;
		//Filt.glow(scroll, 2, 4, Gfx.col("green_2"));
		//scroll.blendMode = flash.display.BlendMode.OVERLAY;
		
	}
	function updateScroller() {
		if(scroll == null || gt++%2 != 0) return;
		scroll.x -= 1;
		if( scroll.x <= -scrollMod ) scroll.x += scrollMod;
	}
	
	// TOOLS
	var buts:Array<But>;
	var centralField:flash.text.TextField;
	function displayCentralText(str,align=-1) {
		if( centralField != null ) 	centralField.parent.removeChild(centralField);
		
		var f = Snk.getField(0xE0FFCC, 8, align, "nokia");
		f.multiline = true;
		f.wordWrap = true;
		
		f.x = 100;
		f.y = 94+6;
		f.width = 200;
		f.htmlText = str;
		f.height = f.textHeight + 4;
		dm.add(f, DP_BG_INTER);
		
		f.filters = [ new flash.filters.DropShadowFilter(1,90,Gfx.col("green_2"),1,0,0,40) ];
		centralField = f;

		return f;
	}
	function addBut(str,ac) {
		var f = centralField;
		var but = new But(str,ac,[Gfx.col("green_2"),Col.brighten(Gfx.col("green_2"),-50)]);
		but.x = Cs.mcw*0.5;
		but.y = f.y + f.height + 8;
		dm.add(but, DP_BG_INTER);
		Filt.glow(but.box, 2, 40, Gfx.col("green_0"));
		buts.push(but);
		return but;
	}
	function cleanButs() {
		while(buts.length > 0) buts.pop().kill();
	}
		
	// WARNING ( NOT ENOUGH CARDS )
	function displayWarning(str) {
		
		var f = displayCentralText(str);
		
		//
		addBut(Lang.BUY_CARD,buyCard);
		/*
		butBuy = new But(Lang.BUY_CARD,buyCard,[Gfx.col("green_2"),Col.brighten(Gfx.col("green_2"),-50)]);
		butBuy.x = Cs.mcw*0.5;
		butBuy.y = f.y + f.height + 8;
		dm.add(butBuy, 2);
		Filt.glow(butBuy, 2, 40, Gfx.col("green_0"));
		*/
		
		//
		mojoBox.visible = false;
		
		//
		//action = butBuy.update;
	}
	function buyCard() {
		var url = new flash.net.URLRequest(Main.domain+"/card");
		flash.Lib.getURL(url,"_self");
	}

	//
	public function displayNotAvailable() {
		displayHint(Lang.BROWSER_MIDNIGHT, 0.2);
	}
	
	// CHACK HAND
	function checkHand() {
		var a = [];
		for( o in data._cards ) if( o._available ) a.push(Data.CARDS[Type.enumIndex(o._type)]);
		return getPerfectHand(a,0, 0);
	}
	function  getPerfectHand(a:Array<DataCard>,hand:Int, sum:Int) {
		TEST++;
		if( sum == Cs.MAX_MOJO ) return true;
		if( hand == Cs.MAX_HAND || sum > 9 || a.length == 0 ) 	return false;
		
		var b = a.copy();
		if( sum > Cs.MAX_MOJO ) for( o in a ) if(o.mojo > 0) b.remove(o);
		
		while( b.length > 0 ) {
			var card = b.pop();
			if( card.multi == null ) while( b.remove(card) ) { };
			if( getPerfectHand( b, hand + 1,  sum + card.mojo ) ) return true;
		}
		return false;
	}

	
	
	// KILL
	function kill() {
		
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, update);
		
		if(screen.parent!=null)screen.parent.removeChild(screen);
	}
	
	



//{
}





