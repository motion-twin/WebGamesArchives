package ui;

import mt.deepnight.Tweenie;
import mt.deepnight.slb.*;
import mt.MLib;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

import com.*;
import Data;
import com.Protocol;

class ClientInfos extends H2dProcess {
	public static var CURRENT : ClientInfos;

	var client				: en.Client;
	var shotel(get,never)	: SHotel; inline function get_shotel() return Game.ME.shotel;

	var sb					: SpriteBatch;
	var tsb					: SpriteBatch;
	public var moreButton	: BatchElement;
	public var bg			: BatchElement;
	public var ctxWid		: Int;
	public var ctxPadding	: Int;
	var ctxLastHei			: Float;
	var ctxFlipped			: Bool;
	public var scale		: Float;
	var scaleAnim			: Float;
	public var likeY		: Float; // for tutorial :)
	public var moneyY		: Float; // for tutorial :)


	public function new(c:en.Client) {
		clear();

		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		ctxWid = 300;
		ctxLastHei = 0;
		ctxPadding = 10;
		ctxFlipped = false;
		scale = 1;
		scaleAnim = 1;
		client = c;
		likeY = 0;
		moneyY = 0;
		var inf = client.sclient;

		CURRENT = this;
		name = "ClientInfos:"+c;
		root.name = name;

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;
		sb.name = "ClientInfos.sb";

		tsb = new h2d.SpriteBatch(Assets.fontTiny.tile, root);
		tsb.filter = true;
		tsb.name = "ClientInfos.tsb";

		scaleAnim = 0.1;
		tw.create(scaleAnim, 1, 180);

		updateInfos();
		updateCoords();
		onResize();
	}


	public function updateInfos() {
		if( moreButton!=null )
			moreButton.remove();
		bg = null;

		sb.removeAllElements();
		tsb.removeAllElements();
		updateCoords();

		if( !ctxFlipped )
			showFrontContextPanel();
		else
			showBackContextPanel();

		// Flip button
		var isWaiting = !client.sclient.isWaiting();
		if( isWaiting ) {
			ctxLastHei+=50;
			bg.height+=50;
		}
		moreButton = Assets.tiles.addBatchElement(sb, "btnAction",0, 0.5,0.5);
		moreButton.width = ctxWid-ctxPadding*2;
		moreButton.height = 40;
		moreButton.x = ctxWid*0.5;
		moreButton.y = ctxLastHei-moreButton.height;
		moreButton.visible = isWaiting;
		var tf = Assets.createBatchText(tsb, Assets.fontTiny, 24);
		tf.text = ctxFlipped ? Lang.t._("Back") : Lang.t._("More details...");
		tf.textColor = Const.BLUE;
		tf.x = Std.int( moreButton.x - tf.textWidth*tf.scaleX*0.5 );
		tf.y = Std.int( moreButton.y - tf.textHeight*tf.scaleY*0.5 );
		tf.visible = moreButton.visible;


		var k = client.sclient.hasAnyPerk() ? "enluminure" : "enluminureSlim";

		var p = 5;
		var c = Assets.tiles.addBatchElement(sb, k,0);
		c.tile.setCenter(3,3);
		c.x = -p;
		c.y = -p;

		var c = Assets.tiles.addBatchElement(sb, k,0);
		c.tile.setCenter(3,3);
		c.scaleX = -1;
		c.x = ctxWid+p;
		c.y = -p;

		var c = Assets.tiles.addBatchElement(sb, k,0);
		c.tile.setCenter(3,3);
		c.scaleY = -1;
		c.x = -p;
		c.y = ctxLastHei+p;

		var c = Assets.tiles.addBatchElement(sb, k,0);
		c.tile.setCenter(3,3);
		c.scaleX = -1;
		c.scaleY = -1;
		c.x = ctxWid+p;
		c.y = ctxLastHei+p;
	}


	function showFrontContextPanel() {
		var sclient = client.sclient;
		var y : Float = ctxPadding + 5;
		var lineHei = 37;

		bg = Assets.tiles.addColoredBatchElement(sb, "white", sclient.hasAnyPerk() ? 0x710E00 : 0x2f1b41, 0.92);
		bg.width = ctxWid;

		// Savings
		if( !sclient.done && sclient.money>0 && shotel.featureUnlocked("savings") ) {
			moneyY = y;
			var tf = Assets.createBatchText(tsb, Assets.fontTiny, 28);
			tf.text = Lang.t._("Savings:");
			tf.textColor = 0xFFB300;
			tf.x = Std.int( ctxPadding );
			tf.y = y;

			if( sclient.money==0 ) {
				var max = Assets.createBatchText(tsb, Assets.fontTiny, 24);
				max.text = Lang.t._("none ||Appears if a client has no savings. Ex: 'Savings: none'");
				max.textColor = 0xFF8000;
				max.x = ctxWid-ctxPadding-max.textWidth*max.scaleX;
				max.y = y;
			}
			else {
				for( i in 0...sclient.money ) {
					var ic = Assets.tiles.addBatchElement(sb,"moneyBill",0, 1,0);
					ic.x = ctxWid - ctxPadding - i*15;
					ic.y = 16;
					ic.setScale(0.5);
				}
			}
			y+=lineHei + 10;
		}


		if( sclient.done ) {
			var t = Assets.createBatchText(tsb, Assets.fontTiny, 24);
			t.text = Lang.t._("This client is about to leave. Its mood cannot be affected by anything anymore.");
			t.textColor = 0x98A2C9;
			t.dropShadow = { color:0x0, alpha:1, dx:1, dy:3 };
			t.maxWidth = (ctxWid - ctxPadding*2)/t.scaleX;
			t.x = ctxPadding;
			t.y = y;
			y+=t.textHeight*t.scaleY + 20;
		}
		else {
			// Likes
			likeY = y;
			for( a in sclient.likes ) {
				createTaste(Lang.t._("I need:"), y, 0xD3ED87, a);
				y+=lineHei;
			}

			// Dislikes
			for( a in sclient.dislikes ) {
				createTaste(Lang.t._("I hate:"), y, 0xFF926C, a);
				y+=lineHei;
			}

			// Emit icon
			if( sclient.emit!=null ) {
				createTaste(Lang.t._("I generate:"), y, 0xFFFFFF, sclient.emit);
				y+=lineHei+15;
			}

			// Likes/dislikes/emits nothing!
			if( sclient.likes.length==0 && sclient.dislikes.length==0 && sclient.emit==null ) {
				var t = Assets.createBatchText(tsb, Assets.fontTiny, 20, 0x98A2C9);
				t.text = Lang.t._("NEUTRAL - Doesn't like, dislike or generate anything right now");
				t.dropShadow = { color:0x0, alpha:1, dx:1, dy:3 };
				t.maxWidth = (ctxWid - ctxPadding*2)/t.scaleX;
				t.x = ctxPadding;
				t.y = y;
				y+=t.textHeight*t.scaleY + 20;
			}
		}

		// Stay duration
		if( Main.ME.settings.showStay && client.isWaiting() ) {
			var t = Assets.createBatchText(tsb, Assets.fontTiny, 25, 0xFFFFFF);
			t.text = Lang.t._("Stay duration:");
			t.x = ctxPadding;
			t.y = y;

			var td = Assets.createBatchText(tsb, Assets.fontTiny, 22, Const.TEXT_GOLD);
			var d = sclient.stayDuration;
			td.text =
				d<DateTools.seconds(60) ? Lang.t._("::n:: seconds", {n:MLib.ceil(d/1000)}) :
				d<DateTools.minutes(2) ? Lang.t._("1 minute") :
				d<DateTools.minutes(60) ? Lang.t._("::n:: minutes", {n:Std.int(d/60000)}) :
				d<DateTools.minutes(120) ? Lang.t._("1 hour") :
				Lang.t._("A long time||Keep this text very short please!");
			td.x = ctxWid-td.textWidth*td.scaleX-ctxPadding;
			td.y = t.y + t.textHeight*t.scaleY*0.5 - td.textHeight*td.scaleY*0.5;

			y+=t.textHeight*t.scaleY + 10;
		}


		#if( !trailer && debug )
		var t = Assets.createBatchText(tsb, Assets.fontTiny, 24);
		var flags = [];
		for(k in sclient.flags.keys()) flags.push(k);
		t.text = cast "ID#"+sclient.id+" ("+flags.join(", ")+")";
		t.dropShadow = { color:0x0, alpha:1, dx:1, dy:3 };
		t.x = ctxPadding;
		t.y = -t.textHeight*t.scaleY;
		#end

		y+=15;
		ctxLastHei = y;
		bg.height = ctxLastHei;
	}



	function showBackContextPanel() {
		var sclient = client.sclient;
		var y = 20.;

		bg = Assets.tiles.addBatchElement(sb, "uiGuestBox",0);
		bg.width = ctxWid;
		bg.alpha = 0.92;


		// Name
		var name = Lang.getClient(sclient.type, shotel).name;
		var t = Assets.createBatchText(tsb, Assets.fontTiny, 30, name);
		t.x = ctxPadding;
		t.y = y;
		y+=t.textHeight*t.scaleY+15;

		// Description
		//var desc = Lang.getClient(sclient.type).desc;
		//if( desc!=null ) {
			//var t = Assets.createBatchText(tsb, Assets.fontTiny, 20, desc);
			//t.textColor = 0x9CB1D8;
			//t.x = ctxPadding;
			//t.y = y;
			//t.maxWidth = (ctxWid-ctxPadding*2)/t.scaleX;
			//y+=t.textHeight*t.scaleY+15;
		//}

		if( !sclient.isWaiting() ) {
			// Happiness Total
			var tf = Assets.createBatchText(tsb, Assets.fontTiny, 22);
			tf.text = Lang.t._("HAPPINESS TOTAL");
			tf.x = ctxPadding;
			tf.y = y+5;
			tf.dropShadow = { color:0x0, alpha:1, dx:1, dy:3 }

			var tf = Assets.createBatchText(tsb, Assets.fontTiny, 22);
			tf.text = Std.string( sclient.getHappiness() );
			tf.x = ctxWid - ctxPadding - tf.textWidth*tf.scaleX;
			tf.y = y;

			y+=35;

			// Happiness stack
			createAffectLabel(sclient.baseHappiness, null, y, false);
			y+=22;
			for(m in sclient.happinessMods) {
				createAffectLabel(m.value, m.type, y);
				y+=22;
			}
		}

		y+=30;
		ctxLastHei = y;
		bg.height = ctxLastHei;
	}


	public function flipPanel() {
		if( cd.has("flip") )
			return;

		tw.terminateWithoutCallbacks( scaleAnim );

		cd.set("flip", Const.seconds(0.1));
		tw.create(scaleAnim, 0.1, TEaseIn, 90).onEnd = function() {
			ctxFlipped = !ctxFlipped;
			updateInfos();
			tw.create( scaleAnim, 1, TEaseOut, 150 );
		}
	}

	function createTaste(label:String, y:Float, col:UInt, a:Affect) {
		var t = Assets.createBatchText(tsb, Assets.fontTiny, 28);
		t.text = label;
		t.textColor = col;
		t.x = ctxPadding;
		t.y = y;

		var icon = Assets.tiles.addBatchElement(sb, Assets.getAffectIcon(a),0);
		icon.setScale(0.7);
		icon.x = ctxWid-icon.width-ctxPadding;
		icon.y = Std.int( y + t.textHeight*t.scaleY*0.5 - icon.height*0.5 );
	}


	function getAffectColor(a:Affect) {
		return switch( a ) {
			case Cold	: 0x57CFF7;
			case Odor	: 0x33EE62;
			case Heat	: 0xFFB70F;
			case Noise	: 0xC45BBC;
			case SunLight: 0xFFFF80;
		}
	}


	function createAffectLabel(val:Int, type:HappinessMod, y:Float, sign=true) {
		var col = val>0 ? 0xDDEC8A : 0xE86265;

		var t = Lang.t;

		var tf = Assets.createBatchText(tsb, Assets.fontTiny, 22);
		tf.text = type==null ? t._("Base") : Lang.getHappinessModifier(type);
		tf.textColor = col;
		tf.x = ctxPadding;
		tf.y = y+2;

		var tf = Assets.createBatchText(tsb, Assets.fontTiny, 22);
		tf.text = sign && val>0 ? '+$val' : Std.string(val);
		tf.textColor = col;
		tf.x = ctxWid - ctxPadding - tf.textWidth*tf.scaleX;
		tf.y = y;
	}

	override function onDispose() {
		super.onDispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		moreButton = null;
		client = null;

		if( CURRENT==this )
			CURRENT = null;
	}


	public static function refresh() {
		if( CURRENT!=null )
			CURRENT.updateInfos();
	}

	public static function clear() {
		if( CURRENT!=null )
			CURRENT.destroy();
	}

	//public function hide() {
		//tw.create(mainWrapper.x, -200, 200).onEnd = destroy;
		//ctxMain.visible = false;
		//if( CURRENT==this )
			//CURRENT = null;
	//}


	override function onResize() {
		super.onResize();
		updateCoords();
	}

	public function getWid() return ctxWid*scale;

	public function isOverMore(ux, uy) {
		if( !moreButton.visible )
			return false;

		var x = root.x + moreButton.x*scale;
		var y = root.y + moreButton.y*scale;
		return
			ux>=root.x && ux<root.x+ctxWid*scale &&
			uy>=y-moreButton.height*0.6*scale && uy<y+moreButton.height*0.6*scale;
	}

	function updateCoords() {
		#if responsive
		scale = Main.getScale(ctxWid, 2.1);
		#else
		scale = 0.6;
		#end
		root.scaleX = scale*scaleAnim;
		root.scaleY = scale;

		var r = client.room;
		//var pt = r.is(R_Lobby) ? Game.ME.sceneToUi(client.xx, client.yy) : Game.ME.sceneToUi(r.globalCenterX, r.globalBottom);
		//ctxMain.x = Std.int(pt.x - ctxWid*scale*0.5);
		//ctxMain.y = Std.int(pt.y - ctxLastHei*scale - 240*Game.ME.totalScale);

		if( r.is(R_Lobby) ) {
			var pt = Game.ME.sceneToUi(client.xx, client.yy);
			root.x = Std.int(pt.x - ctxWid*scale*0.5);
			root.y = Std.int(pt.y + 10);
		}
		else {
			var pt = Game.ME.sceneToUi(r.globalLeft, r.globalCenterY);
			root.x = Std.int(pt.x - ctxWid*scale);
			root.y = Std.int(pt.y - ctxLastHei*0.5*scale);
		}

		root.x += ctxWid*scale*0.5 * (1-scaleAnim);
	}

	override function update() {
		if( client==null || client.sclient==null ) {
			destroy();
			return;
		}

		super.update();

		//if( time%30==0 )
			//updateDuration();

		updateCoords();
	}
}