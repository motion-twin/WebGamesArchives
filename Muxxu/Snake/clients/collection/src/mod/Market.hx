package mod;
import Protocole;
import mt.bumdum9.Lib;
using mt.deepnight.SuperMovie;

class Market  extends Module{//}
	
	static var DESC_Y = 90;
	static var DESC_H = 80;
	var step:Int;
	var cards:Array<GfxCard>;
	var page:flash.display.Sprite;
	var fieldDesc:flash.text.TextField;
	
	public function new() {
		super();
		
		//
		step = 0;
		displayShop();
				
		
	}
	
	
	// SHOP
	function displayShop() {
		
		newPage();
		
		// BG
		var green = Gfx.col("green_0");
		var light = Gfx.col("green_0", -10);
		var g = page.graphics;
		g.beginFill(green);
		g.drawRect(0, 0, mcw, mch);
		
		g.beginFill(light);
		g.drawRect(0, 0, mcw, 24);
		
		g.beginFill(light);
		g.drawRect(0, DESC_Y, mcw, DESC_H);
		
		// TITLE
		var field =  Snk.getField(Gfx.col("green_0", 50), 20, -1, "upheaval");
		field.text = Lang.COLLECTION_TITLE_SHOP;
		field.width = field.textWidth+4;
		field.x = Std.int((mcw - field.width) * 0.5);
		page.addChild(field);
		
		
		// SLOTS

		var b = [Main.data._priceCard, Main.data._pricePack, Main.data._priceTicket ];

		for( id in 0...3 ) {
			var f = Snk.getField(0xFFFFFF, 8, -1, "nokia");
			f.text = Lang.SHOP_ITEMS[id];
			f.width = 240;
			
			f.x = 40;
			f.y = 30 + id * 20;
			
			var price = Snk.getField(0xFFFFFF, 8, -1, "nokia");
			price.text = Std.string(b[id]);
			price.width = price.textWidth+3;
			price.x = f.x+130;
			price.y = f.y;
			//price.filters = [ new flash.filters.GlowFilter(0x662200,1,4,4,400)];
			
			var icon = new pix.Element();
			icon.drawFrame(Gfx.main.get("token"));
			icon.x = price.x + price.width + 4;
			icon.y = price.y + 6;
			icon.alpha = 0.8;
			
			var but = new But( Lang.BUY, callback(buy, id), "icon_play");
			but.x = price.x + 70;
			but.y = price.y;
			but.actionOver = callback( displayHint, Lang.SHOP_DESC[id] );
						
			page.addChild(f);
			page.addChild(price);
			page.addChild(icon);
			page.addChild(but);
		}
		
		// DESC
		fieldDesc = Snk.getField(Gfx.col("green_0",50), 8, -1, "nokia");
		//fieldDesc = Snk.getField(0xFFFFFF, 8, -1, "nokia");
		fieldDesc.x = 50;
		fieldDesc.y = DESC_Y;
		fieldDesc.width = 400;
		fieldDesc.height = 100;
		page.addChild(fieldDesc);
		
		// SERPENTIN
		var el = new pix.Element();
		el.drawFrame( Gfx.collection.get(0, "perso"), 1, 1);
		el.x = mcw;
		el.y = mch;
		page.addChild(el);
		
		
	}
	function displayHint(str) {
		fieldDesc.width = 180;
		fieldDesc.text = str;
		fieldDesc.width = fieldDesc.textWidth + 3;
		fieldDesc.height = fieldDesc.textHeight + 5;
		fieldDesc.x = Std.int((mcw - fieldDesc.width) * 0.5) - 50;
		fieldDesc.y = DESC_Y + Std.int((DESC_H - fieldDesc.height) * 0.5);
		//fieldDesc.filters = [ new flash.filters.GlowFilter(Gfx.col("green_1"),1,4,4,400)];
	}
		
	//
	function buy(id) {
	
		removeChild(page);
		displayLoading();
		

		if( Main.domain != null ) {
			var type = switch(id) {
				case 0 : CRT_SINGLE ;
				case 1 : CRT_PACK ;
				case 2 : CRT_TICKET ;
			}
			
			Codec.load(Main.domain + "/buyCard", {_type : type}, receive) ;
		}else{
			var me = this;
			var f = function() {
				var o:_ShopItem = { _a:[] };
				var max = 0;
				if( id == 0 ) max = 1;
				if( id == 1 ) max = 10;
				for( i in 0...max) o._a.push( Snk.getEnum(_CardType, Std.random(80)) );
				me.receive(o);
			}
			//f = noMoney;
			haxe.Timer.delay( f, 1000);
		}
		
	}
	function receive(data:_ShopItem) {
		if (data._a == null) {
			flash.Lib.getURL( new flash.net.URLRequest(Main.domain + "/card"), "_self");
			return ;
		}
		
		var cost = switch(data._a.length) {
					case 0 : Main.data._priceTicket ;
					case 1 : Main.data._priceCard ;
					default : Main.data._pricePack ;
				} ;
		flash.external.ExternalInterface.call("_ut", Std.string(-1 * cost)) ;
		
		removeChild(page);
		if( data._a.length == 0 ) {
			Main.data._tickets++;
			Main.data._totalTickets++;
			Collection.me.buts[2].select(null);
			return;
		}
		displayCards(data._a);
	}
	
	//
	var timer:Int;
	function displayCards(a:Array<_CardType>) {
		newPage();
		
		var hh = 40;
		page.graphics.beginFill(Gfx.col("green_0", -10));
		page.graphics.drawRect(0, mch - hh, mcw, hh);
		
		cards = [];
		if( a.length == 1 ) {
			var card = getCard(a[0]);
			card.x = mcw * 0.5;
			card.y = mch * 0.5;
		}else {
			var id = 0;
			var ec = 3;
			for( y in 0...2 ) {
				for( x in 0...5 ) {
					var card = getCard(a[id]);
					card.x = 74 + x * (GfxCard.WIDTH + ec);
					card.y = 50 + y * (GfxCard.HEIGHT + ec);

					id++;
					
				}
			}
		}
				
		//
		fieldDesc = Snk.getField(Gfx.col("green_0",50), 8, -1, "nokia");
		fieldDesc.x = 50;
		fieldDesc.y = 5 + mch - hh;
		fieldDesc.width = 400;
		fieldDesc.height = hh;
		fieldDesc.multiline = true;
		fieldDesc.wordWrap = true;
		fieldDesc.visible = false;
		page.addChild(fieldDesc);
		
		
		step = 1;
		timer = 0;
	}
	function getCard(t) {
		var mc = new GfxCard(2);
		mc.setType(t);
		page.addChild(mc);
		cards.push(mc);

		mc.onOver(callback(displayDesc, Data.TEXT[Type.enumIndex(t)].desc));
		mc.onOut(callback(displayDesc,""));
		
		return mc;
	}
	override function update() {
		super.update();
		switch(step) {
			case 0 :
			case 1 :
				timer++;
				var id = 0;
				var ok  = true;
				for( ca in cards ) {
					var c = Num.mm(0, (timer - (id + 3) * 16) / 20 , 1);
					if( c < 1 ) ok = false;
					ca.coef = 0.75 - c * 0.5;
					ca.majSprite();
					id++;
					
				}
				if( ok ) {
					step++;
					timer = 0;
					fieldDesc.visible = true;
					for( ca in cards ) {
						var me = this;
						ca.onClick( function() { me.step++; });
					}
				}
			case 2 :
				/*
				if( timer++ == 80 ) {
					step++;
					timer = 0;
				}
				*/
			case 3 :
				if( timer++ > 3 && cards.length>0) {
					timer = 0;
					var card = cards.shift();
					var fx = new mt.fx.Tween(card, -42, 35);
					fx.curveInOut();
					fx.onFinish = callback(eatCard, card);

				}
				if( timer > 20 ) {
					removeChild(page);
					displayShop();
					step = 0;
				}
		}
				
	}
	function eatCard(card:GfxCard) {
		page.removeChild(card);
		Main.addCard(card.type);
		new mt.fx.Flash(Collection.me.buts[0].icon,0.2);
	}
	
	//
	function displayDesc(str:String) {
		
		fieldDesc.width = 260;
		fieldDesc.text = str;
		fieldDesc.width = fieldDesc.textWidth + 5;
		fieldDesc.height = fieldDesc.textHeight + 5;
		fieldDesc.x = Std.int((mcw - fieldDesc.width) * 0.5);
		fieldDesc.y = (mch-20) - Std.int(fieldDesc.height*0.5);
	}
	
	//
	function newPage() {
		page = new flash.display.Sprite();
		addChild(page);
	}
	
	
	
	//
	function displayLoading() {
		newPage();
		var g = page.graphics;
		g.beginFill(Gfx.col("green_1"));
		g.drawRect(0, 0, mcw, mch);
		
		var box = Main.getLoadingBox();
		box.x = mcw * 0.5;
		box.y = mch * 0.5;
		page.addChild(box);
	}

	


	


	
//{
}








