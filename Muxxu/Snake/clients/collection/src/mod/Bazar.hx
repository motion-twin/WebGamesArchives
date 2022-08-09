package mod;
import Protocole;
import mt.bumdum9.Lib;
using mt.deepnight.SuperMovie;

class Bazar  extends Module{//}

	static var DIALOG_Y = 98;
	static var DIALOG_H = 88;
	static var WAIT_STANDARD = 2500;
	
	var step:Int;
	
	var card:GfxCard;
	var buts:Array<But>;
	var bub:SP;
	var bubField:TF;
	var bubBox:SP;

	var mephis:pix.Element;
	
	public function new() {
		super();
		buts = [];

		// BG
		var green = Gfx.col("green_0");
		var light = Gfx.col("green_0", -10);
		var g = graphics;
		g.beginFill(green);
		g.drawRect(0, 0, mcw, mch);
		
		g.beginFill(light);
		g.drawRect(0, 0, mcw, 24);
		
		g.beginFill(light);
		g.drawRect(0, DIALOG_Y, mcw, DIALOG_H);
	
		//
		bubBox = new SP();
		addChild(bubBox);
		
		// TITLE
		var t = getTitle(Lang.COLLECTION_TITLE_BAZAR);
		addChild(t);
		
		//
		var totalCards = 0;
		for( c in Main.data._cards ) totalCards += c._num;
		
		//
		// BAZAR_MIN_CARD
		if( totalCards < 20 )				displayEmptyText(Lang.rep(Lang.BAZAR_NO_ENTER,Std.string(Data.BAZAR_MIN_CARD)));
		else if( Main.data._deal == null ) 	displayEmptyText(Lang.BAZAR_END);
		else 								displayMephis();
		
		
	}
	override function init() {
		if( mephis != null ) initDeal();
	}
	
	function displayMephis() {
		mephis = new pix.Element();
		mephis.drawFrame( Gfx.collection.get(2, "perso"), 1, 1);
		mephis.x = mcw;
		mephis.y = mch;
		addChild(mephis);
	}
	
	function displayEmptyText(txt) {
		var ma = 36;
		var ww = mcw - 2 * ma;
		var f = Snk.getField(Gfx.col("green_0", 50), 8, -1, "nokia");
		f.multiline = true;
		f.wordWrap = true;
		f.width = ww;
		f.htmlText = txt;
		f.width = f.textWidth + 3;
		f.x = Std.int((mcw - f.width) * 0.5);
		addChild( f);
		f.y = DIALOG_Y - 50;
	}


	
	
	function noMoreDeal() {
		
		displayText(Lang.BAZAR_FINISH);
		haxe.Timer.delay( leave, WAIT_STANDARD );
	}
	

	var current:_BazarDeal;
	function initDeal() {
		step = 10;
		current = Main.data._deal;
		
		removeBub();
		
		if( card != null ) cardLeave();
		
		card = new GfxCard(2);
		card.setType(current._card);
		card.x = -42;
		card.y = 35;
		card.coef = 0.25;
		card.majSprite();
		addChild(card);
		
		var e = new mt.fx.Tween(card, Std.int(mcw * 0.5), DIALOG_Y-37, 0.05);
		e.curveInOut();
		e.onFinish = makeOffer;
		
	}

	function makeOffer() {
		
		displayText(Lang.BAZAR_OFFER);
		displayButs();
	
	}
	function getText(?str:String, ?a:Array<String>) {
		
		var colCard = "#55BB00";
		var colCard2 = "#AA8800";
		
		var id = Type.enumIndex(current._card);
		var data = Data.CARDS[id];
		var name = Lang.col(Data.TEXT[id].name,colCard);
		var name2 = Lang.col(Data.TEXT[Std.random(100)].name,colCard2);
		var name3 = Lang.col(Data.TEXT[Std.random(100)].name,colCard2);
		var price = Lang.col(Std.string(current._price),"#FF4444");
		var freqId = switch(data.freq) { case "C" : 0; case "U" : 1; case "R" : 2; };
		var freq = Lang.FREQ[freqId];
		if( a != null ) str = a[Std.random(a.length)];
		str = Lang.rep(str, name, price, freq, name2, name3);
		
		return str;
	}
	
	function displayButs() {

		removeButs();
		var ww:Float = mcw - 98;
		for( i in 0...3 ){
			var but = new But( Lang.BAZAR_CHOICES[i], callback(choose, i), "icon_play");
			//but.actionOver = callback( displayHint, Lang.SHOP_DESC[id] );
			but.y = DIALOG_Y + DIALOG_H + 5;
			addChild(but);
			ww -= but.width;
			buts.push(but);
		}
		
		var ec  = ww / (buts.length + 1);
		var x  = ec;
		for( b in buts ) {
			b.x = Std.int(x+b.width*0.5);
			x += b.width + ec;
		}
	}
	function removeButs() {
		while(buts.length > 0) buts.pop().kill();
	}

	function displayText(?str:String, ?a:Array<String>) {
		
		var str = getText(str, a);
		
		var ma = 12;
		var ma2 = 116;
		var fma = 4;
		var ww = mcw - (ma + ma2);
		var scroll = 20;
		
		if( bub != null ) removeBub();
			
		bub = new SP();
		bub.x = ma;
		bub.y = DIALOG_Y + ma + scroll;
		bub.blendMode = flash.display.BlendMode.LAYER;
		bubBox.addChild(bub);
			
		var f = Snk.getField(0x004400, 8, -1, "nokia");
		f.x = fma;
		f.multiline = true;
		f.wordWrap = true;
		f.width = ww-2*fma;
		f.htmlText = str;
		f.height = f.textHeight + 5;
		bub.addChild(f);
		
		
		var hh = f.height;
		var gfx = bub.graphics;
		gfx.clear();
		gfx.lineStyle(1, 0x004400);
		
		for( i in 0...2 ){
			gfx.beginFill([0xEECCFF, 0xFFFFFF][i]);
			var mm = 3;
			gfx.drawRoundRect(i*mm*0.5, i*mm*0.5, ww-i*mm, hh-i*mm, 8-i*mm, 8-i*mm);
			gfx.endFill();
			gfx.lineStyle();
		}
		
		
		new mt.fx.Tween(bub,bub.x,bub.y-scroll).curveIn(0.5);
		new mt.fx.Spawn(bub,0.1,true).curveIn(0.5);
		
		
	}
	function removeBub() {
		if( bub == null ) return;
		new mt.fx.Vanish(bub, 5, 5, true);
		bub = null;
	}
	
	var cid:Int;
	function choose(id) {
		cid = id;
		step = -1;
		removeButs();
		displayLoading();
		
		if( Main.domain != null ) {
			Codec.load(Main.domain + "/sellCard", Snk.getEnum( _BazarRequest, id ), receive) ;
		}else{
			var me = this;
			var f = function() {
				//var o = { _price:-1, _next: { _card:ARROSOIR, _price:4 }	};
				//var o = { _price:-1, _next:null	};
				var o = { _price:me.current._price, _next:null	};
				//var o = { _price:me.current._price, _next:{ _card:ARROSOIR, _price:4 }	};
				me.receive(o);
			}
			//f = noMoney;
			haxe.Timer.delay( f, 1000);
		}
	}
	function receive(data:_BazarResult) {
		removeChild(box);
		if( data._price == -1 ) {
			if( data._next == null ) {
				displayText(Lang.BAZAR_QUIT);
				//nextDeal(data._next);
				haxe.Timer.delay( leave, WAIT_STANDARD);
				Main.data._deal = null;
				cardLeave();
			}else {
				displayText(Lang.BAZAR_NEXT);
				nextDeal(data._next);
				
			}
		}else if( data._price == current._price ) {
			
			switch(cid ) {
				case 0:
					displayText(Lang.BAZAR_GIVE_UP);
					nextDeal(data._next);
					cardLeave();
				
				case 1: // STAY
				
					displayText(Lang.BAZAR_STAY);
					displayButs();
					
				case 2: // DEAL
					displayText(Lang.BAZAR_DEAL);
					flash.external.ExternalInterface.call("_ut", Std.string(data._price)) ;
					cardToMephis();
					nextDeal(data._next);
					
			}
				
		}else if( data._price > current._price ) {
			current._price = data._price;
			displayText(Lang.BAZAR_RAISE);
			displayButs();
		}
	}
	function nextDeal(d) {
		Main.data._deal = d;
		
		if( d != null ) {
			haxe.Timer.delay( initDeal, WAIT_STANDARD);
		}else {
			haxe.Timer.delay( noMoreDeal, WAIT_STANDARD);
		}
		
	}
	
	function leave() {
		var e = new mt.fx.Tween(mephis, mephis.x + 120, mephis.y);
		e.curveIn(2);
		var me = this;
		e.onFinish = function() { me.displayEmptyText(Lang.BAZAR_END); me.removeBub();  };
	}
	
	//
	function cardLeave() {
		var e = new mt.fx.Tween(card, -38, 35, 0.05);
		e.curveInOut();
		e.onFinish = card.kill;
		card = null;
	}
	function cardToMephis() {
		var e = new mt.fx.Tween(card, mephis.x-mephis.width*0.5, mephis.y-mephis.height*0.5, 0.05);
		e.curveInOut();
		e.onFinish = card.kill;
		card = null;
	}

	//

	var box:SP;
	function displayLoading() {

		box = Main.getLoadingBox();
		box.x = Std.int((mcw-70) * 0.5);
		box.y = DIALOG_Y + DIALOG_H + 16;
		box.alpha = 0.5;
		addChild(box);

	}
	
	
	
	
//{
}








