import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.text.TextField;
import mt.Metrics;
import mt.MLib;
import mt.data.GetText;
import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import mt.deepnight.slb.assets.*;

class Preloader extends NMEPreloader {
	var bwid	: Int;
	var bhei	: Int;

	public static var wrapper	: Sprite;
	public static var tiles		: mt.deepnight.slb.BLib;
	var bg		: Sprite;
	var saying	: Null<TextField>;
	var logo	: BSprite;
	var cat		: BSprite;
	var hoover	: BSprite;
	var carpet	: BSprite;
	var time	: Float;
	var cd		: mt.Cooldown;
	var walking	: Bool;
	var cleanB	: Bool;
	var dx		: Float;
	var dy		: Float;
	var quotes	: Array<LocaleString>;

	public function new() {
		super();

		destroy();

		flash.Lib.current.stage.color = 0x0;
		bwid = 500;
		bhei = 5;
		time = 0;
		dx = 0;
		dy = 0;
		cleanB = false;
		walking = false;
		cd = new mt.Cooldown();

		Lang.init();
		quotes = [
			Lang.t._("I'm preparing your hotel!"),
			Lang.t._("Initializing duvets..."),
			Lang.t._("Initializing brooms..."),
			Lang.t._("Initializing red carpet..."),
			Lang.t._("Downloading towels..."),
			Lang.t._("Sweeping floors..."),
			Lang.t._("Loading pillows..."),
			Lang.t._("Loading lobby bell..."),
			Lang.t._("Loading the loading bar..."),
			Lang.t._("Folding bed linen..."),
			Lang.t._("Cleaning up bedrooms..."),
			Lang.t._("Vacuuming corridors..."),
			Lang.t._("Seriously, it's taking ages..."),
		];

		removeChildren();

		bg = new Sprite();
		addChildAt(bg,0);
		bg.graphics.beginFill(0x0,1);
		bg.graphics.drawRect(0,0,100,100);

		wrapper = new Sprite();
		addChild(wrapper);

		tiles = TexturePacker.importXml("assets/preloader.xml");

		// Logo
		logo = tiles.get("motionTwin");
		wrapper.addChild(logo);
		logo.setScale( bwid / logo.getBitmapDataReadOnly().width );

		// Bar bg
		outline = new Sprite();
		wrapper.addChild(outline);
		var g = outline.graphics;
		g.clear();
		g.beginFill(0x26264A,1);
		g.drawRect(0,0,bwid,bhei);
		outline.y = logo.height + 30;

		progress = new Sprite();
		wrapper.addChild(progress);
		progress.y = outline.y;
		var g = progress.graphics;
		g.clear();
		g.beginFill(#if debug 0xD93022 #else 0xD93022 #end,1);
		g.drawRect(0, 0, bwid, bhei);
		progress.scaleX = 0;

		//progress.filters = [
			//new flash.filters.DropShadowFilter(2,0, 0x0,0.8, 8,0),
			//new flash.filters.GlowFilter(0xD93022,0.4, 16,16, 2, 2),
			//new flash.filters.GlowFilter(0x503287,0.75, 32,32, 1, 2),
		//];

		// Hoover
		hoover = tiles.get("groomCatHoover");
		wrapper.addChild(hoover);
		hoover.setCenterRatio(0.5,1);
		hoover.alpha = 0;
		//hoover.setScale(1/0.75);

		// Carpet
		carpet = tiles.get("tapis");
		wrapper.addChild(carpet);
		carpet.setCenterRatio(0.5,0.5);
		carpet.filter = true;

		// Cat
		cat = tiles.get("groomCatCleaning");
		wrapper.addChild(cat);
		cat.a.registerStateAnim("groomCatWalk", 2, function() return walking);
		cat.a.registerStateAnim("groomCatCleaningB", 1, function() return cleanB);
		cat.a.registerStateAnim("groomCatCleaning", 0);
		cat.a.applyStateAnims();
		cat.setCenterRatio(0.5, 1);
		//cat.setScale(1/0.75);
		cat.x = progress.x;
		cat.alpha = 0;
		cat.filter = true;
		cd.set("catFade", Const.seconds(1));

		addEventListener(flash.events.Event.ENTER_FRAME, update);
		addEventListener(flash.events.Event.ADDED_TO_STAGE, onAdded);
		addEventListener(flash.events.Event.REMOVED_FROM_STAGE, onRemoved);
		onResize(null);

		cd.set("firstText", 999999);
		cd.set("text", Const.seconds(2));
		update(null);
	}

	function onAdded(_) {
		stage.addEventListener( flash.events.Event.RESIZE, onResize );
		flash.Lib.current.stage.quality = flash.display.StageQuality.BEST;
		onResize(null);
	}

	function onRemoved(_) {
		flash.Lib.current.stage.quality = flash.display.StageQuality.MEDIUM;
		removeEventListener(flash.events.Event.ENTER_FRAME, update);
		removeEventListener(flash.events.Event.ADDED_TO_STAGE, onAdded);
		removeEventListener(flash.events.Event.REMOVED_FROM_STAGE, onRemoved);

		removeChildren();
		removeSaying();

		cd.destroy();
		cd = null;

		cat.dispose();
		cat = null;

		bg = null;

		flash.Lib.current.addChild(wrapper);
	}

	public static function destroy() {
		if( tiles==null )
			return;

		tiles.destroy();
		tiles = null;

		wrapper.parent.removeChild(wrapper);
		wrapper = null;
	}

	var start : {loaded: Int, total: Int, t: Float} = null;
	public override function onUpdate(bytesLoaded:Int, bytesTotal:Int){
		if( start == null ){
			start = {
				loaded: bytesLoaded,
				total: bytesTotal,
				t: haxe.Timer.stamp()
			};
		}
		super.onUpdate(bytesLoaded, bytesTotal);
	}

	public override function onLoaded(){
		if( start != null ){
			var t = haxe.Timer.stamp();
			var tdiff:Float = t-start.t;
			var bdiff:Int = start.total-start.loaded;
			var o = {};
			Reflect.setField(o,"seconds",tdiff);
			Reflect.setField(o,"bytes",bdiff);
			#if connected
			mt.device.EventTracker.twTrack("clientDownloadStats",o);
			#end
		}
		super.onLoaded();
	}

	function onResize(_) {
		if( stage==null )
			return;

		var w = Metrics.w();
		var h = Metrics.h();

		wrapper.x = Std.int( w*0.5 - bwid*0.5 );
		wrapper.y = Std.int( h*0.5 - 50 );

		bg.width = w;
		bg.height = h;
	}

	function removeSaying() {
		if( saying!=null ) {
			saying.parent.removeChild(saying);
			saying = null;
		}
	}

	function say() {
		removeSaying();

		var str = null;
		if( !cd.has("lastText") && progress.scaleX>=0.75 ) {
			str = Lang.t._("Almost there!");
			cd.set("lastText", 999999);
		}

		if( quotes.length==0 && str==null )
			return;

		if( str==null ) {
			str = quotes.splice( cd.has("firstText") ? 0 : Std.random(quotes.length), 1)[0];
			cd.unset("firstText");
		}

		var tf = new flash.text.TextField();
		wrapper.addChild(tf);
		var f = new flash.text.TextFormat("Arial", 14, 0xFFEDA4);
		tf.setTextFormat(f);
		tf.defaultTextFormat = f;
		tf.mouseEnabled = tf.selectable = false;
		tf.width = 150;
		tf.height = 100;
		tf.multiline = tf.wordWrap = true;
		tf.text = str;
		tf.alpha = 0;

		saying = tf;
		cd.set("textAlive", Const.seconds(Lib.rnd(2.2, 3)));
		updateSaying();
	}

	function updateSaying() {
		if( saying!=null && !cd.has("textAlive") ) {
			saying.alpha-=0.05;
			if( saying.alpha<=0 ) {
				cd.set("text", Const.seconds( Lib.rnd(0.6,1.8) ) );
				removeSaying();
			}
		}
		if( saying!=null && cd.has("textAlive") ) {
			saying.alpha+=0.07;
			if( saying.alpha>1 )
				saying.alpha = 1;
		}
		if( saying==null && !cd.has("text") )
			say();

		if( saying!=null ) {
			saying.x = Std.int( cat.x - saying.textWidth*0.5 );
			saying.y = Std.int( cat.y-100 + Math.cos(time*0.1)*6 - saying.textHeight );
		}
	}


	function update(_) {
		if( cat==null || cat.destroyed )
			return;

		cd.update();
		tiles.updateChildren();

		// Text
		updateSaying();

		// Cat
		cat.rotation = Math.cos(time*0.1)*(walking?4:5);
		if( !cd.has("catFade") )
			cat.alpha = MLib.fmin(1, cat.alpha+0.05);

		// X
		var tx = MLib.fmax( 20, progress.x + progress.width - 30 );
		if( !walking && cat.x<tx-150 )
			cd.unset("wait");

		if( !walking && !cd.has("wait") && cat.x<tx-20 ) {
			if( !cd.has("swapClean") ) {
				cd.set("swapClean", Const.seconds(2.5));
				cleanB = !cleanB;
			}
			walking = true;
		}

		if( walking && cat.x>=tx-20 ) {
			walking = false;
			cd.set("wait", Const.seconds( progress.scaleX<0.85 ? Lib.rnd(0.6,3) : Lib.rnd(0.4, 0.8) ));
		}

		if( walking )
			dx+=0.4;
		else
			dx*=0.8;
		cat.x+=dx;
		dx*=0.95;

		// Y
		var ty = progress.y + 1;
		if( cat.y>=ty ) {
			cat.y = ty;
			dy = 0;
		}
		else
			dy+=0.7;
		if( walking && cat.y==ty )
			dy = -3;
		cat.y+=dy;

		// Hoover
		hoover.x += MLib.fmax(0, (cat.x-40-hoover.x)*0.05 );
		hoover.y = progress.y - (progress.y - cat.y)*0.3;
		hoover.alpha = cat.alpha;
		hoover.rotation = Math.cos(time*0.12)*4;

		// Carpet ball
		var r = progress.width/bwid;
		carpet.setScale(1-r*0.85);
		carpet.rotation = r*360*5;
		carpet.x = progress.x + progress.width;
		carpet.y = progress.y - carpet.getBitmapDataReadOnly().height*carpet.scaleY*0.5 + bhei-0.5;

		time++;
	}
}
