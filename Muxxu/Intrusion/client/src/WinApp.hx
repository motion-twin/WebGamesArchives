import Types;
import flash.Key;

typedef WindowMC = {
	> flash.MovieClip,
	field	: flash.TextField,
	close	: flash.MovieClip,
	mask	: flash.MovieClip,
}

class WinApp {
	static var SCROLL_SPEED = 10;

	var term		: UserTerminal;
	var dm			: mt.DepthManager;
	var sdm			: mt.DepthManager;

	var win			: WindowMC;
	var bg			: flash.MovieClip;
	var scroller	: flash.MovieClip;
	var scrollUp	: flash.MovieClip;
	var scrollDown	: flash.MovieClip;

	var wid			: Int;
	var hei			: Int;
	var scrollX		: Int;
	var scrollY		: Int;

	var ml			: Dynamic; // mouse listener
	var kl			: Dynamic; // key listener

	public var title		: String;

	public function new(t:UserTerminal) {
		term = t;
		scrollX = 0;
		scrollY = 0;
		setTitle("foo");
		ml = {};
		kl = {};
	}

	public function setTitle(?t:String) {
		if ( t!=null )
			title = t;
		if ( win.field!=null )
			win.field.text = title.toUpperCase()+".PRG";
	}

	public function start() {
		term.playSound("bleep_07");
		bg = Manager.DM.attach("mask", Data.DP_APP);
		bg._alpha = 70;
		bg.onRelease = function() {};
		bg.useHandCursor = false;

		win = cast Manager.DM.attach("window", Data.DP_APP);
		win._x = Math.round( Data.WID*0.5 - win._width*0.5 );
		win._y = Math.round( Data.HEI*0.5 - win._height*0.5 );
		setTitle();
		win.close.onRelease = onClose;
		win.close.onRollOver = callback(onOver, win.close);
		win.close.onRollOut = callback(onOut, win.close);

		wid = Std.int( win.mask._width );
		hei = Std.int( win.mask._height );

		dm = new mt.DepthManager( win );

		scrollUp = dm.attach("windowScroll", Data.DP_APP);
		scrollUp._x = win._width - scrollUp._width;
		scrollUp._y = 35;
		scrollUp._yscale *= -1;
		scrollUp.onPress = onScrollUp;
		scrollUp.onRelease = onStopScroll;
		scrollUp.onReleaseOutside = onStopScroll;
		scrollUp.onRollOver = callback(onOver,scrollUp);
		scrollUp.onRollOut = callback(onOut,scrollUp);

		scrollDown = dm.attach("windowScroll", Data.DP_APP);
		scrollDown._x = win._width - scrollDown._width;
		scrollDown._y = win._height - scrollDown._height;
		scrollDown.onPress = onScrollDown;
		scrollDown.onRelease = onStopScroll;
		scrollDown.onReleaseOutside = onStopScroll;
		scrollDown.onRollOver = callback(onOver,scrollDown);
		scrollDown.onRollOut = callback(onOut,scrollDown);

		scroller = dm.empty(Data.DP_ITEM);
		scroller.setMask(win.mask);
		scroller._x = win.mask._x;
		scroller._y = win.mask._y;
		sdm = new mt.DepthManager( scroller );

		term.registerApp(this);
		if ( term.fs!=null ) {
			term.fs.lock();
			term.dock.lock();
		}
		term.dock.hide();
		term.hideLog();

		if ( !term.fl_lowq )
			term.startAnim( A_FadeIn, win ).spd*=2;

		Reflect.setField(ml, "onMouseWheel", onMouseWheel);
		flash.Mouse.addListener(ml);
		Reflect.setField(kl, "onKeyDown", onKeyEvent);
		Key.addListener(kl);
	}

	public function stop() {
		win.removeMovieClip();
		bg.removeMovieClip();
		sdm.destroy();
		dm.destroy();
		term.unregisterApp(this);
		if ( term.fs!=null ) {
			term.fs.unlock();
			term.dock.unlock();
		}
		term.dock.show();
		term.showLog();
		Key.removeListener(kl);
		flash.Mouse.removeListener(ml);
	}

	function separator(x) {
		var mc = dm.attach("windowLine", Data.DP_TOP);
		mc._x = Math.round( x + win.mask._x );
		mc._y = Math.round( win.mask._y - 5 );
		mc._alpha = 50;
		return mc;
	}

	function addField( ?fdm:mt.DepthManager, x:Int,y:Int, s, ?fl_anim=true, ?animDelay=0.0) : MCField {
		if ( fdm==null )
			fdm = dm;
		var mc : MCField = cast fdm.attach("logLine",Data.DP_TOP);
		mc.field.text = s;
		mc.field._width = mc.field.textWidth + 10;
		mc._x = x;
		mc._y = y;
		if ( fl_anim )
			term.startAnim( A_Text, mc, s, animDelay );
		return mc;
	}


	function addButton( ?fdm:mt.DepthManager, x:Int,y:Int, label:String, cb:Void->Void, ?fl_resize=true ) {
		if ( fdm==null )
			fdm = dm;
		var mc : MCField = cast fdm.attach("menuButton", Data.DP_TOP);
		mc._x = x;
		mc._y = y;
		mc.field.text = label;
		mc.field._width = mc.field.textWidth + 10;
		if ( fl_resize )
			mc.smc._width = mc.field.textWidth+10;
		var me = this;
		mc.onRelease = function() {
			me.term.playSound("single_01");
			cb();
		}
		mc.onRollOver = callback(onOver,mc);
		mc.onRollOut = callback(onOut,mc);
		mc.onReleaseOutside = mc.onRollOut;
		return mc;
	}


	function onScrollDown() {
		scrollY = Std.int(SCROLL_SPEED * mt.Timer.tmod);
	}
	function onScrollUp() {
		scrollY = Std.int(-SCROLL_SPEED * mt.Timer.tmod);
	}

	function onStopScroll() {
		scrollX = 0;
		scrollY = 0;
	}

	function onKeyEvent() {
		onKey( Key.getCode() );
	}

	function onKey(c) {
		switch (c) {
			case Key.ESCAPE :
				onClose();
		}
	}

	function onMouseWheel(delta) {
		scroll( 0, Std.int( -delta * SCROLL_SPEED * mt.Timer.tmod ) );
	}

	function onOver(mc:flash.MovieClip) {
		mc.filters = [ new flash.filters.GlowFilter(Data.GREEN,0.8, 4,4) ];
	}

	function onOut(mc:flash.MovieClip) {
		mc.filters = [];
	}

	function scroll(dx,dy) {
		if ( scroller._width < win.mask._width )
			dx = 0;
		if ( scroller._height < win.mask._height )
			dy = 0;

		if ( dx!=0 ) {
			scroller._x -= dx;
			scroller._x = Math.min( win.mask._x, scroller._x );
			scroller._x = Math.max( -scroller._width + wid, scroller._x );
		}
		if ( dy!=0 ) {
			scroller._y -= dy;
			scroller._y = Math.min( win.mask._y, scroller._y );
			scroller._y = Math.max( -scroller._height + hei, scroller._y );
		}

		scroller._x = Math.round(scroller._x);
		scroller._y = Math.round(scroller._y);
	}

	function onClose() {
		term.playSound("bleep_07");
		stop();
	}

	public function update() {
		if ( scrollX!=0 || scrollY!=0 )
			scroll(scrollX, scrollY);
//		scrollUp._visible = inner._height>=hei;
//		scrollDown._visible = inner._height>=hei;
	}
}