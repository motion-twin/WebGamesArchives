package ui;

import mt.MLib;
import mt.deepnight.Color;
import mt.device.Cash;

#if !connected
#error "Should not be compiled"
#end

class Cash extends H2dProcess {
	public static var CURRENT : Cash;

	public var ctrap		: h2d.Interactive;
	public var wrapper		: h2d.Sprite;
	public var desc			: Null<h2d.Text>;
	var productId			: String;
	var wid					: Int;
	var hei					: Int;

	var products			: Array<Product>;

	public function new(productId:String) {
		CURRENT = this;

		super();
		Main.ME.uiWrapper.add(root, Const.DP_POP_UP);

		if( productId=="gold" )
			Assets.SBANK.gold(1);
		else
			Assets.SBANK.gem(1);

		Game.ME.uiFx.clearAll();
		ui.Notification.NotificationManager.clearAll();
		onNextUpdate = Game.ME.pause;

		this.productId = productId;
		name = 'Cash';
		products = [];

		ctrap = new h2d.Interactive(8,8,root);
		ctrap.backgroundColor = alpha(0x0,0.85);
		ctrap.onClick = function(_) onCancel();

		wrapper = new h2d.Sprite(root);

		var win = Assets.tiles1.getH2dBitmap("uiShop", wrapper);
		wid = Std.int( win.width );
		hei = Std.int( win.height );

		var winCtrap = new h2d.Interactive(wid, hei, wrapper);
		winCtrap.cursor = Default;

		var tf = Assets.createText(28, 0x37843b, productId=="gold"?Lang.t._("Buy gold"):Lang.t._("Buy gems"), wrapper);
		tf.maxWidth = 290/tf.scaleX;
		tf.lineSpacing = -8;
		tf.textAlign = Center;
		tf.x = Std.int( 10 + win.width*0.5 - tf.maxWidth*tf.scaleX*0.5 );
		tf.y = 3 + 64*0.5 - tf.height*tf.scaleY*0.5;

		// First buy bonus
		//var bg = Assets.tiles.getColoredH2dBitmap("white", Const.BLUE, 0.2, false, wrapper);
		//desc = Assets.createText(21, Const.TEXT_GOLD, Lang.t._("On your first buy, you will unlock a special and unique room: the BANK! Each time you earn money from any source, the bank will add a 5% bonus to your benefits! This bonus can even be doubled using Boosters!"), wrapper);
		//desc.maxWidth = (wid-50)/desc.scaleX;
		//desc.x = Std.int( wid*0.5 - desc.width*desc.scaleX*0.5 );
		//desc.y = 85 - desc.height*desc.scaleY*0.5;
		//var p = 10;
		//bg.setPos(desc.x-p, desc.y-p);
		//bg.setSize(desc.textWidth*desc.scaleX + p*2, desc.textHeight*desc.scaleY + p*2);

		// Close button
		var close = new h2d.Interactive(55,55, wrapper);
		close.onClick = function(_) onCancel();
		close.x = win.width-30;
		close.y = 20;
		var b = Assets.tiles.getH2dBitmap("iconRemove", true, close);
		b.width = close.width;
		b.height = close.height;

		// Loading
		var tf = Assets.createText(64, Lang.t._("Loading..."), wrapper);
		tf.x = Std.int( win.width*0.5 - tf.width*tf.scaleX*0.5 );
		tf.y = Std.int( win.height*0.5 - tf.height*tf.scaleY*0.5 );
		createChildProcess( function(p) {
			tf.y = Std.int( win.height*0.5 - tf.height*tf.scaleY*0.5 + Math.cos(ftime*0.2)*7 );
			if( products.length>0 ) {
				tf.dispose();
				p.destroy();
			}
		});

		wrapper.y = h();
		onResize();
		cd.set("fx", Const.seconds(0.3));

		mt.device.Cash.listProducts(Main.ME.hdata.cashProducts.get(productId), onProductsLoaded);
	}

	function onProductsLoaded(d:ProductsData) {
		if( destroyed )
			return;

		if( products.length>0 )
			return;

		// More payment means
		if( d.otherPayment!=null ) {
			var i = new h2d.Interactive(200,55, wrapper);
			i.onClick = function(_) {
				d.otherPayment(onBuyResponse);
				Assets.SBANK.happy(0.6);
				destroy();
			}
			i.x = wid*0.5 - i.width*0.5;
			i.y = hei-i.height-25;
			var b = Assets.tiles1.getH2dBitmap("goldBtnShop", true, i);
			var tf = Assets.createText(14, 0x0, Lang.t._("Other payment methods"), i);
			tf.textAlign = Center;
			tf.maxWidth = (i.width-20)/tf.scaleX;
			tf.x = i.width*0.5 - tf.maxWidth*tf.scaleX*0.5;
			tf.y = i.height*0.35 - tf.height*tf.scaleY*0.5;
		}

		products = d.list.copy();

		var x = 0;
		var y = 0;
		var bwid = 200;
		var bhei = 200;
		var idx = 0;

		for( p in products ) {
			var big = idx==1;

			var i = new h2d.Interactive(0, bhei, wrapper);
			var bg = Assets.tiles1.getH2dBitmap(big?"shopBigBtn":"shopBtn", true, i);
			bg.alpha = 0.7;

			var w = bg.width;
			i.width = bg.width;
			i.x = 40 + x*(bwid+15);
			i.y = (desc!=null?140:100) + y*bhei;

			#if !mobile
			var shine1 = Assets.tiles.getH2dBitmap("fxSunshine", 0.5,0.5, true, i);
			shine1.blendMode = Add;
			shine1.scale( 0.1 );
			shine1.setPos(w*0.5, bhei*0.5);
			shine1.alpha = 0.7;
			var shine2 = Assets.tiles.getH2dBitmap("fxSunshine", 0.5,0.5, true,i);
			shine2.blendMode = Add;
			shine2.scale( 0.1 );
			shine2.setPos(w*0.5, bhei*0.5);
			shine1.alpha = 0.8;
			#end

			var icon = Assets.tiles1.getH2dBitmap(productId=="gold"?"shopGold":"shopGem", idx, 0.5, 0.5,true, i);
			icon.setPos(w*0.5, bhei*0.4);

			// Money quantity
			var qty = new h2d.Sprite(i);

			var tf = Assets.createText(productId=="gold"?25:34, productId=="gold"?Const.TEXT_GOLD:Const.TEXT_GEM, Game.ME.prettyNumber(p._moneyA._quantity), qty);

			var micon = Assets.tiles.getH2dBitmap(productId=="gold"?"moneyGold":"moneyGem",0, 0,0.5, true, qty);
			micon.scale(0.4);
			micon.x = tf.width*tf.scaleX+4;
			micon.y = tf.height*tf.scaleY*0.5;

			qty.x = 10;
			qty.y = bhei-16-qty.height;

			// Euro price
			var price = Assets.createText(16, 0xFFFFBB, Std.string(p._price), i);
			price.x = Std.int( w - price.width*price.scaleX - 10 );
			price.y = bhei - 20 - price.height*price.scaleY;

			// Actions
			i.onClick = function(_) {
				p._buy(onBuyResponse);
				Assets.SBANK.happy(0.6);
				destroy();
			}
			#if !mobile
			var over = false;
			createChildProcess( function(_) {
				if( over ) {
					icon.setScale( 0.8 + Math.cos(ftime*0.3)*0.02 );
					icon.rotation += ( Math.cos(ftime*0.15) * 0.08 - icon.rotation ) * 0.5 ;
					shine1.scaleX += (1.9-shine1.scaleX)*0.2;
					shine2.scaleX += (1.7-shine2.scaleX)*0.2;
				}
				else {
					icon.scaleX += (0.8-icon.scaleX)*0.1;
					icon.scaleY = icon.scaleX;
					icon.rotation += ( Math.cos(ftime*0.05) * 0.04 - icon.rotation ) * 0.5 ;
					shine1.scaleX += (0.01-shine1.scaleX)*0.3;
					shine2.scaleX += (0.01-shine2.scaleX)*0.3;
				}
				shine1.scaleY = shine1.scaleX;
				shine1.rotate(0.01);
				shine2.scaleY = shine1.scaleX;
				shine2.rotate(-0.017);
			});
			i.onOver = function(_) {
				bg.alpha = 1;
				over = true;
			}
			i.onOut = function(_) {
				bg.alpha = 0.7;
				over = false;
			}
			#end

			// Banner
			if( idx==1 || idx==products.length-1 ) {
				var blue = idx==1;
				var bg = Assets.tiles1.getH2dBitmap(blue?"bannerBlue":"bannerGreen", true, i);
				bg.setPos(4,6);
				var s = new h2d.Sprite(i);
				s.rotate(-0.785);
				s.x = 49;
				s.y = 49;
				var tf = Assets.createText(18, blue?0x005279:0x006624, blue?Lang.t._("Popular!"):Lang.t._("Best offer"), s);
				tf.maxWidth = 200/tf.scaleX;
				tf.x = Std.int( -tf.textWidth*tf.scaleX*0.5 );
				tf.y = Std.int( -tf.textHeight*tf.scaleY*0.5 );
			}

			// Fx
			var xx = 0.;
			var yy = 0.;
			var rx = 35;
			var ry = 25;
			switch( idx ) {
				case 0 :
				case 1 : ry = 15; yy-=20;
				case 2 : ry = 20; yy-=30;
				case 3 : rx = 55; ry = 20; yy-=20;
				case 4 : rx = 70; ry = 20; yy-=10;
				default :
			}
			createChildProcess( function(_) {
				if( itime%3==0 && !cd.has("fx") ) {
					var xx = wrapper.x + (xx + i.x + icon.x)*wrapper.scaleX;
					var yy = wrapper.y + (yy + i.y + icon.y)*wrapper.scaleY;
					if( productId=="gems" )
						Game.ME.uiFx.shopGem(xx + rnd(0,rx*wrapper.scaleX,true), yy + rnd(0,ry*wrapper.scaleY,true), wrapper.scaleX);
					else
						Game.ME.uiFx.shopGold(xx + rnd(0,rx*wrapper.scaleX,true), yy + rnd(0,ry*wrapper.scaleY,true), wrapper.scaleX);
				}
			});

			x += big?2:1;
			if( x>2 ) {
				x = 0;
				y++;
			}
			idx++;
		}
		rebuild();
	}

	function onBuyResponse( d : mt.device.Cash.Transaction ) {
		Game.ME.bankSync();

		if( destroyed )
			return;

		destroy();
	}

	public function onBack() {
		onCancel();
	}

	function onCancel() {
		if( destroyed )
			return;

		destroy();
		Assets.SBANK.click1(1);
	}

	function rebuild() {
		onResize();
	}


	override function onResize() {
		super.onResize();

		if( wrapper!=null ) {
			//var s = Main.getScale(wid,6);
			//if( hei>=h() )
				//s = h()/hei;
			//wrapper.setScale(s);
			wrapper.setScale( MLib.fmin( w()*0.9/wid, h()*0.9/hei ) );
			wrapper.x = Std.int( w()*0.5 - wrapper.width*0.5 );
			tw.create(wrapper.y, Std.int( h()*0.5 - wrapper.height*0.5 ), 350 );
			//wrapper.y = Std.int( h()*0.5 - wrapper.height*0.5 );

			ctrap.width = w();
			ctrap.height = h();
		}
	}


	override function onDispose() {
		super.onDispose();

		if( Game.ME!=null )
			Game.ME.resume();

		Game.ME.uiFx.clearAll();

		desc = null;
		products = null;
		ctrap = null;
		wrapper = null;

		if( CURRENT==this )
			CURRENT = null;
	}


	override function update() {
		super.update();

		Game.ME.uiFx.update();
	}
}
