package ui;

import mt.MLib;
import mt.deepnight.Tweenie;
import mt.deepnight.slb.*;
import mt.deepnight.Lib;
import b.Hotel;
import b.Room;
import en.Client;
import com.Protocol;
import com.*;
import Game;
import Data;

class Tutorial extends H2dProcess {
	public static var ME : Tutorial;

	public var id(default,null)		: Null<String>;

	var shotel(get,null)	: SHotel;
	var hotel(get,null)		: b.Hotel;
	var game(get,null)		: Game;

	public var cm			: mt.deepnight.Cinematic;
	var requiredCommand		: Null<GameCommand>;
	var ctrap				: h2d.Interactive;
	var dark				: h2d.Bitmap;
	var maxWid				: Int;
	var wrapper				: h2d.Layers;

	var commandLocks		: Map<String,Bool>;
	var cancelCondition		: Null<Void->Bool>;
	var onComplete			: Null<Void->Void>;
	var lockedSelection		: Null<Selection>;

	var topBar				: h2d.Bitmap;
	var bottomBar			: h2d.Bitmap;
	var barHei				: Int;
	var waitingClick		: Bool;
	var lastTutoTime		: Float;

	var lastText			: Null<h2d.Sprite>;
	var lastGlobalText		: Null<h2d.Sprite>;

	public function new() {
		ME = this;

		lastTutoTime = -9999;

		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_TUTORIAL);

		commandLocks = new Map();
		waitingClick = false;
		name = 'Tutorial';
		maxWid = 800;
		id = null;
		barHei = 10;
		cancelCondition = null;
		lockedSelection = null;
		onComplete = null;

		cm = new mt.deepnight.Cinematic(Const.FPS);

		ctrap = new h2d.Interactive(8,8,root);
		ctrap.onPush = function(_) onCTrap();

		dark = Assets.tiles.getH2dBitmap("darkMask", 0.5,0.5, root);
		wrapper = new h2d.Layers(root);
		dark.visible = false;

		topBar = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0x0)) );
		Main.ME.uiWrapper.add(topBar, Const.DP_BARS);
		topBar.alpha = 0.85;
		topBar.visible = false;

		bottomBar = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0x0)) );
		Main.ME.uiWrapper.add(bottomBar, Const.DP_BARS);
		bottomBar.tile.setCenterRatio(0,1);
		bottomBar.alpha = topBar.alpha;
		bottomBar.visible = false;

		clear();
		onResize();

		topBar.y = -barHei;
		bottomBar.y = h()+barHei;
	}

	function get_shotel() return Game.ME.shotel;
	function get_hotel() return Game.ME.hotelRender;
	function get_game() return Game.ME;

	function onCTrap() {
		//if( cd.has("click") || !waitingClick )
			//return;
//
		//onClickNext();
	}

	public function askRefocus() {
		cd.set("refocus", 2);
	}

	function onClickNext() {
		cm.signal("wait");
		waitingClick = false;
	}

	public inline function isRunning(?i:String) {
		return id!=null && (i==null || i==id);
	}

	public inline function isRunningAnythingExcept(i:String) {
		return id!=null && id!=i;
	}

	public function hasDone(id:String) return shotel.hasDoneTutorial(id);

	function unlockFeature(id:String) {
		if( !shotel.featureUnlocked(id) )
			game.runSolverCommand( DoUnlockFeature(id) );
		ui.HudMenu.CURRENT.refresh();
	}

	public inline function commandLocked(id:String) return commandLocks.get(id)==true;
	function lockCommand(id:String) commandLocks.set(id,true);
	function unlockCommand(id:String) commandLocks.remove(id);
	function unlockAllCommands() commandLocks = new Map();


	function showBars() {
		tw.terminateWithoutCallbacks(topBar.y);
		topBar.visible = true;
		tw.create(topBar.y, 0, 1000);

		tw.terminateWithoutCallbacks(bottomBar.y);
		bottomBar.visible = true;
		tw.create(bottomBar.y, h(), 1000);
	}

	function hideBars() {
		tw.terminateWithoutCallbacks(topBar.y);
		tw.create(topBar.y, -barHei, 700).onEnd = function() {
			topBar.visible = false;
		}

		tw.terminateWithoutCallbacks(bottomBar.y);
		tw.create(bottomBar.y, h()+barHei, 700).onEnd = function() {
			bottomBar.visible = false;
		}
	}

	public function tryToStart(id:String, ?rcmd:GameCommand) : Bool {
		#if disableTutorial
		return false;
		#end

		if( game.isVisitMode() )
			return false;

		if( game.hasAnyPopUp() )
			return false;

		if( !isRunning() && !hasDone(id) && this.id!=id && !cd.has(id) ) {
			this.id = id;
			cm.cancelEverything();
			clear();
			if( game.isDragging() )
				game.cancelDrag();
			unlockSelection();
			requiredCommand = rcmd;
			cancelCondition = null;
			onComplete = null;
			showBars();
			game.unselect();
			ui.SideMenu.closeAll();
			ui.Question.clear();
			for(c in en.Client.ALL)
				c.clearBubbles();

			if( ui.Friends.CURRENT!=null )
				ui.Friends.CURRENT.destroy();

			game.runSolverCommand( DoBeginTutorial(id) );

			#if connected
			mt.device.EventTracker.tutorialPresented(id);
			#end

			return true;
		}
		else
			return false;
	}

	public function clear() {
		ctrap.visible = false;
		wrapper.disposeAllChildren();
		waitingClick = false;
		lastText = null;
		lastGlobalText = null;

		tw.terminateWithoutCallbacks(dark.alpha);
		if( dark.visible )
			tw.create(dark.alpha, 0, 300).onEnd = function() dark.visible = false;

		killAllChildrenProcesses();
	}

	public function noRecentTuto() {
		return (ftime-lastTutoTime) >= Const.seconds(20);
	}

	public function tryToSkipTutorial(id:String) {
		tryToStart(id);
		if( isRunning(id) ) {
			#if !prod
			new ui.Notification(cast "Skipped tutorial "+id, 0xFFFF00);
			#end
			complete(true);
		}
	}

	public function complete(sendCommand:Bool) {
		cd.set(id, Const.seconds(5));
		cm.cancelEverything();
		clear();
		unlockSelection();
		requiredCommand = null;
		cancelCondition = null;
		var cb = onComplete;
		onComplete = null;
		hideBars();
		unlockAllCommands();
		lastTutoTime = ftime;

		if( sendCommand )
			game.chainCommands([ DoCompleteTutorial(id) ]);

		#if connected
		mt.device.EventTracker.tutorialCompleted(id,1);
		#end

		id = null;

		if( cb!=null )
			cb();
	}

	override function onResize() {
		super.onResize();

		if( ctrap!=null ) {
			ctrap.width = w();
			ctrap.height = h();

			dark.width = w() + MLib.fabs( w()*0.5-dark.x )*2;
			dark.height = h() + MLib.fabs( h()*0.5-dark.y )*2;

			barHei = Std.int( h()*0.1 );

			topBar.width = w();
			topBar.height = barHei;
			tw.create(topBar.y, topBar.visible?0:-barHei, 400);

			bottomBar.width = w();
			bottomBar.height = barHei;
			tw.create(bottomBar.y, bottomBar.visible?h():h()+barHei, 400);
		}
	}


	function commandMatches(c:GameCommand) {
		if( requiredCommand==null )
			return true;

		if( c.getIndex()!=requiredCommand.getIndex() )
			return false;

		var cp = c.getParameters();
		var rp = requiredCommand.getParameters();
		for(i in 0...rp.length) {
			var p : Dynamic = rp[i];
			if( p==null || p==-99 )
				continue;

			switch( Type.typeof(p) ) {
				case TEnum(_) :
					var p : EnumValue = cast p;
					if( !p.equals(cp[i]) ) return false;
				default : if( p!=cp[i] ) return false;
			}
		}

		return true;
	}

	public function allowCommand(c:GameCommand) : Bool {
		return switch( c ) {
			case DoPing : true;
			case DoUnlockFeature(_) : true;
			case DoBeginTutorial(_): true;
			default : commandMatches(c);
		}
			//c==DoPing ||
			//c.getIndex()==DoUnlockFeature(null).getIndex() ||
			//c.getIndex()==DoBeginTutorial(null).getIndex() ||
			//commandMatches(c);
	}

	public inline function isWaitingCommand(c:GameCommand) return requiredCommand!=null && commandMatches(c);

	public function requireCommand(c:GameCommand) {
		requiredCommand = c;
	}

	public function textFree(getX:Void->Null<Float>, getY:Void->Null<Float>, str:String, ?offsetScale=1.0, ?centered=false) {
		var thei = Std.int( h()*0.2 );
		var wid = 300;

		var parts = str.split("|");
		var iconId = parts.length>1 ? StringTools.trim(parts[1]) : null;
		if( parts.length>1 )
			str = parts[0];

		var sh = hxd.impl.ShaderLibrary.get(false, false, false, true, 1);

		var w = new h2d.Sprite();
		wrapper.add(w, 1);
		lastText = w;
		lastGlobalText = null;
		var p = 10;

		var t = h2d.Tools.getWhiteTile();
		var outline = new h2d.Bitmap( t, w );
		outline.color = h3d.Vector.fromColor(alpha(0x421100));
		var bg = new h2d.Bitmap( t, w );
		bg.color = h3d.Vector.fromColor(alpha(0x421100));

		var left = true;
		if( str.charAt(0)==">" ) {
			str = str.substr(1);
			left = false;
		}

		var iwid = 64;
		if( iconId!=null && Assets.tiles.exists(iconId) ) {
			var i = Assets.tiles.getH2dBitmap(iconId, 0.5,0, true, w);
			i.x = wid*0.5;
			i.setScale( iwid/i.height );
		}

		var tf = new h2d.Text(Assets.fontNormal, w);
		tf.text = Lang.addNbsps(str);
		tf.scale(0.7);
		tf.maxWidth = wid/tf.scaleX;
		tf.filter = true;
		tf.textColor = 0xFFFF9D;
		tf.dropShadow = { color:0x882200, alpha:1, dx:0, dy:2 }
		if( iconId!=null )
			tf.y+=iwid+5;

		bg.x = -p;
		bg.y = -p;
		bg.width = wid + p*2;
		bg.height = tf.y + tf.height*tf.scaleY + p*2;

		outline.setPos(bg.x-2, bg.y-2);
		outline.width = bg.width+4;
		outline.height = bg.height+4;

		// Corners
		var p = 5;
		var c = Assets.tiles.getH2dBitmap("enluminure", true, w, sh);
		c.tile.setCenter(10,10);
		c.setPos(bg.x, bg.y);

		var c = Assets.tiles.getH2dBitmap("enluminure", true, w, sh);
		c.tile.setCenter(10,10);
		c.scaleX = -1;
		c.setPos(bg.x+bg.width, bg.y);

		var c = Assets.tiles.getH2dBitmap("enluminure", true, w, sh);
		c.tile.setCenter(10,10);
		c.scaleY = -1;
		c.setPos(bg.x, bg.y+bg.height);

		var c = Assets.tiles.getH2dBitmap("enluminure", true, w, sh);
		c.tile.setCenter(10,10);
		c.scaleX = -1;
		c.scaleY = -1;
		c.setPos(bg.x+bg.width, bg.y+bg.height);


		w.scaleY = 0.1;
		var dx = rnd(10,30,true);
		var dy = rnd(10,30,true);
		createChildProcess( function(_) {
			var s = Main.getScale(wid, wcm()>=12 ? 4 : 3);
			w.scaleX = s;
			w.scaleY += (s-w.scaleY)*0.2;
			if( centered ) {
				w.x = getX() - w.width*0.5 + dx;
				w.y = getY() - w.height*0.5 + dy;
			}
			else {
				w.x = getX() + ( left ? -40*offsetScale*s-w.width : 40*offsetScale*s );
				w.y = getY() - w.height*0.5;
			}
			w.x = MLib.fclamp(w.x, 20*w.scaleX, this.w()-w.width-5);
			w.y = MLib.fclamp(w.y, 20*w.scaleY, this.h()-w.height-30*w.scaleY);
		});
	}

	public function textScene(?e:Entity, ?r:Room, str:String) {
		function getPt() return e!=null ? Game.ME.sceneToUi(e.centerX,e.centerY) : Game.ME.sceneToUi(r.globalCenterX,r.globalCenterY);

		textFree(
			function() return getPt().x,
			function() return getPt().y,
			str
		);
	}

	public function textGlobal(str:String) {
		var s = new h2d.Sprite();
		wrapper.add(s, 2);
		lastGlobalText = s;
		lastText = null;
		s.y = h();

		var bg = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0x9F2800, 0.95)), s );

		var tf = Assets.createText(32, 0xFFFF9D, Lang.fixMissingFontChars(str), s);
		tf.dropShadow = { color:0x9D1700, alpha:1, dx:0, dy:2 }

		createChildProcess(function(_) {
			var scale = Main.getScale(100,1);
			s.y += (scale*5-s.y)*0.15;
			var th = tf.height*tf.scaleY + 40*scale;
			tf.setScale(scale);
			tf.maxWidth = ( w()*0.75 ) / tf.scaleX;
			tf.x = Std.int( w()*0.5 - tf.width*tf.scaleX*0.5 );
			tf.y = th*0.5 - tf.height*tf.scaleY*0.5;
			bg.height = th;
			bg.width = w();
		}, true);
	}

	public function textCenter(str:String) {
		textFree(
			function() return w()*0.5,
			function() return h()*0.5,
			str, true
		);
	}


	function addContinueButton() {
		var wid = 300 + 20;
		var hei = 45;

		var i = new h2d.Interactive(10, 10);
		wrapper.add(i, 2);
		i.onClick = function(_) {
			onClickNext();
			Assets.SBANK.click1(1);
		}
		i.width = wid;
		i.height = hei;

		var bg = Assets.tiles.getH2dBitmap("btnAction",i);
		bg.width = wid;
		bg.height = hei;

		var tf = Assets.createText(24, Const.BLUE, Main.TOUCH ? Lang.t._("Tap to continue...") : Lang.t._("Click to continue..."), i);
		tf.x = Std.int( wid*0.5 - tf.width*tf.scaleX*0.5 );
		tf.y = Std.int( hei*0.5 - tf.height*tf.scaleY*0.5 );

		var f = 0.;
		bg.colorMatrix = new h3d.Matrix();
		cd.set("blink", Const.seconds(2));

		var t = 0;
		i.visible = false;
		createChildProcess( function(p) {
			i.visible = t>15 || i.x>0; // fix to avoid flickering in the corner
			i.setScale( lastText!=null ? lastText.scaleX : Main.getScale(hei,0.75) );

			if( !cd.hasSet("blink",Const.seconds(1)) )
				f = 0.7;

			if( f>0 )
				f-=0.06;

			bg.colorMatrix.identity();
			bg.colorMatrix.colorBrightness(f);

			if( lastText!=null )
				i.setPos(lastText.x-10*i.scaleX, lastText.y + lastText.height - i.height*i.scaleY*0.5);

			if( lastGlobalText!=null ) {
				i.setPos( w()*0.5-i.width*i.scaleX*0.5, 150 );
				i.y = lastGlobalText.y + lastGlobalText.height - 5;
			}

		}, true);

	}


	function _focus(getX:Void->Null<Float>, getY:Void->Null<Float>, ?scale=1.0, ?showTap=false, ?txt:String) {
		scale*=2.5; // dirty fix
		var focus = Assets.tiles.getH2dBitmap(showTap ? "focus" : "focusNoClick", 0.5,0.5);
		wrapper.add(focus, 0);
		focus.filter = true;
		focus.setScale( scale*game.totalScale*4 );
		if( !showTap )
			focus.rotate( rnd(0,0.2,true) );
		focus.visible = false;

		var pt = game.uiToScene(getX(), getY());
		game.viewport.focus(pt.x, pt.y);

		var tap = showTap ? Assets.tiles.h_getAndPlay("tutoHand") : null;
		if( tap!=null ) {
			wrapper.add(tap, 0);
			tap.visible = false;
		}

		if( txt!=null )
			textFree( getX, getY, txt, scale );

		createChildProcess( function(p) {
			var x = getX();
			var y = getY();
			if( x!=null && y!=null ) {
				if( cd.has("refocus") )
					Game.ME.uiFx.tutoRefocus(getX,getY);
				focus.visible = true;
				focus.x = x;
				focus.y = y;
				focus.scaleX += ((scale * game.totalScale)-focus.scaleX)*0.2 + Math.cos(ftime*0.25)*0.01;
				focus.scaleY = focus.scaleX;
				if( showTap )
					focus.rotate(0.02);
				if( tap!=null ) {
					tap.visible = true;
					tap.x = x;
					tap.y = y;
					tap.scaleX = tap.x>=w()*0.9?-1:1;
					tap.scaleY = tap.y>=h()*0.9?-1:1;
				}
			}
		});
	}


	function arrowScene(?e:Entity, ?r:Room, ?dx=0., ?dy=0., ?scale=1.0) {
		if( e!=null )
			_arrow(
				function() return e.centerX + dx,
				function() return e.centerY + dy,
				scale, true
			);

		if( r!=null )
			_arrow(
				function() return r.globalCenterX + dx,
				function() return r.globalCenterY + dy,
				scale, true
			);
	}

	function arrowSideButton(menu:ui.SideMenu, value:Dynamic, ?scale=1.0) {
		function getX() return menu==null || menu.isCollapsed() || menu.destroyed ? null : menu.getButtonCenter(value).x;
		function getY() return menu==null || menu.isCollapsed() || menu.destroyed ? null : menu.getButtonCenter(value).y;
		if( menu!=null )
			menu.focus(value);
		_arrow(getX, getY, scale);
	}


	function _arrow(gx:Void->Null<Float>, gy:Void->Null<Float>, ?fxScale=1.0, ?ang=-99., ?onScene=false) {
		var getX = gx;
		var getY = gy;
		if( onScene ) {
			getX = function() return Game.ME.sceneToUiX(gx());
			getY = function() return Game.ME.sceneToUiY(gy());
		}

		var e = Assets.tiles.getH2dBitmap("tutoArrow",0, 1,0.5);
		wrapper.add(e, 0);
		e.filter = true;
		e.rotate( ang==-99 ? -0.4 + rnd(0,0.2,true) : ang );
		e.visible = false;

		if( onScene )
			game.viewport.focus(gx(), gy());

		var baseDist = 40.;

		createChildProcess(function(_) {
			var x = getX();
			var y = getY();
			if( x!=null && y!=null ) {
				var s = Main.getScale(130, 1);
				e.setScale(1*s);
				e.visible = true;
				var d = baseDist + 10 + MLib.fabs(Math.cos(ftime*0.20)*16);
				e.x = x - Math.cos(e.rotation) * d;
				e.y = y - Math.sin(e.rotation) * d;
				e.scaleX += (s-e.scaleX)*0.2;
				e.scaleY = e.scaleX;
				baseDist*=0.8;

				if( itime%5==0 )
					game.uiFx.tutoArrowMarker(getX,getY, 4*s*fxScale);
			}
			else
				e.visible = false;
		}, true);
	}


	function focusViewportAt(cx:Float, cy:Float) {
		var pt = b.Hotel.gridToPixels(cx,cy);
		pt.x += Std.int(Const.ROOM_WID*0.5);
		pt.y -= Std.int(Const.ROOM_HEI*0.5);
		game.viewport.focus(pt.x, pt.y);
	}


	function focusRoomCoord(cx:Int, cy:Int, ?scale=1.0, ?dx=0., ?dy=0., ?showTap=false, ?txt:String) {
		var pt = b.Hotel.gridToPixels(cx,cy);
		pt.x += Std.int(Const.ROOM_WID*0.5);
		pt.y -= Std.int(Const.ROOM_HEI*0.5);
		game.viewport.focus(pt.x, pt.y);

		function getPt() return game.sceneToUi(pt.x, pt.y);
		_focus(
			function() return getPt().x,
			function() return getPt().y,
			scale,
			showTap,
			txt
		);
	}

	function focusSideButton(menu:ui.SideMenu, value:Dynamic, ?scale=1.0, ?showTap=false, ?txt:String, ?sideCenter=false) {
		function getX() return menu==null || menu.isCollapsed() || menu.destroyed ? null : menu.getButtonCenter(value, sideCenter).x;
		function getY() return menu==null || menu.isCollapsed() || menu.destroyed ? null : menu.getButtonCenter(value, sideCenter).y;
		if( menu!=null )
			menu.focus(value);
		_focus(getX, getY, scale, showTap, txt);
		game.viewport.cancelTweens();
	}

	function textSideButton(menu:ui.SideMenu, value:Dynamic, ?txt:String) {
		function getX() return menu==null || menu.isCollapsed() || menu.destroyed ? null : menu.getButtonCenter(value).x;
		function getY() return menu==null || menu.isCollapsed() || menu.destroyed ? null : menu.getButtonCenter(value).y;
		if( menu!=null )
			menu.focus(value);
		textFree(getX, getY, (menu.left?">":"")+txt);
	}

	function focusMainStatus(x:Float, y:Float, ?scale=1.0, ?showTap=false, ?txt:String) {
		var m = ui.MainStatus.CURRENT;
		function getX() return ( x + m.root.x ) * m.root.scaleX;
		function getY() return ( y + m.root.y ) * m.root.scaleY;
		_focus(getX, getY, scale, showTap, txt);
		game.viewport.cancelTweens();
	}

	function focusHudMenu(id:String, ?scale=1.0, ?showTap=false, ?txt:String) {
		function getX() return ui.HudMenu.CURRENT.getButtonCoord(id).x;
		function getY() return ui.HudMenu.CURRENT.getButtonCoord(id).y;
		_focus(getX, getY, scale, showTap, txt);
		game.viewport.cancelTweens();
	}

	function focusContextMenuButton(id:Int, ?scale=1.0, ?dx=0., ?dy=0., ?showTap=false, ?txt:String) {
		function getX() return ui.Menu.CURRENT==null ? null : ui.Menu.CURRENT.getButtonUiCoord(id).x;
		function getY() return ui.Menu.CURRENT==null ? null : ui.Menu.CURRENT.getButtonUiCoord(id).y;
		_focus(getX, getY, scale, showTap, txt);

		if( ui.Menu.CURRENT!=null && ui.Menu.CURRENT.sideMode )
			game.viewport.cancelTweens();
	}


	function focusScene(?e:Entity, ?r:b.Room, ?scale=1.0, ?dx=0., ?dy=0., ?showTap=false, ?txt:String) {

		if( r!=null )
			Game.ME.viewport.focusRoom(r);

		if( e!=null )
			game.viewport.focus(e.centerX, e.centerY);

		function getPt() {
			return e!=null ? game.sceneToUi(e.centerX+dx, e.centerY+dy) : game.sceneToUi(r.globalCenterX+dx, r.globalCenterY+dy);
		}

		_focus(
			function() return getPt()==null ? null : getPt().x,
			function() return getPt()==null ? null : getPt().y,
			scale,
			showTap,
			txt
		);
	}

	function focusClientInfos(getX:ui.ClientInfos->Float, getY:ui.ClientInfos->Float, ?txt:String) {
		var getCiX = function() {
			var ci = ui.ClientInfos.CURRENT;
			return ci==null ? null : ci.root.x + getX(ci)*ci.scale;
		}
		var getCiY = function() {
			var ci = ui.ClientInfos.CURRENT;
			return ci==null ? null : ci.root.y + getY(ci)*ci.scale;
		}
		textFree(getCiX, getCiY, ">"+txt);
		_arrow(getCiX, getCiY, 0.4);
	}


	function focusRoomHud(c:Client, type:String, ?txt:String, ?ang=3.3) {
		var getCiX = function() {
			return game.sceneToUiX(c.room.globalLeft + 50);
		}
		var isize = 50;
		var dy = switch( type ) {
			case "like" : 0;
			case "dislike" : isize * c.sclient.likes.length;
			case "money" : isize * (c.sclient.likes.length + c.sclient.dislikes.length);
			default : 0;
		}
		var getCiY = function() {
			return game.sceneToUiY(c.room.globalTop + 50+ dy);
		}
		textFree(getCiX, getCiY, txt);
		_arrow(getCiX, getCiY, 0.5, ang);
	}


	public function _drag(getX:Void->Null<Float>, getY:Void->Null<Float>, getTX:Void->Null<Float>, getTY:Void->Null<Float>, ?fromIsNotOnScene=false, ?fadeAway=false) {
		var ts = #if responsive 1.5 #else 1 #end;

		var hand = Assets.tiles.h_get("tutoHand");
		wrapper.add(hand, 0);
		hand.setPivotCoord(20,20);
		hand.filter = true;
		hand.scale(ts);

		var ratio = 0.0;
		var spd = 0.;
		var phase = 0;

		game.viewport.focus( getX() + (getTX()-getX())*0.5, getY() + (getTY()-getY())*0.5 );

		createChildProcess(
			function(p) {
				if( getX()==null || getTX()==null )
					return;


				var from = fromIsNotOnScene ? { x:getX(), y:getY() } : Game.ME.sceneToUi(getX(), getY());
				var to = Game.ME.sceneToUi(getTX(), getTY());
				var a = Math.atan2(to.y-from.y, to.x-from.x);
				var d = Lib.distance(from.x, from.y, to.x, to.y);

				if( itime%15==0 && !game.isDragging() && !ui.SideMenu.isDragging() )
					game.uiFx.tapDrag(from.x, from.y);

				if( phase==0 ) {
					var a = tw.create(hand.scaleX, 0.7*ts, 350);
					a.onUpdate = function() hand.scaleY = hand.scaleX;
					a.onEnd = function() phase = 2;
					phase = 1;
				}

				if( phase==2 ) {
					ratio+=spd;
					if( ratio<=0.2 )
						spd+=0.005;
					if( ratio>=0.8 && spd>=0.01 )
						spd*=0.85;
					if( ratio>=1 ) {
						phase = 3;
						var a = tw.create(hand.scaleX, 1.1*ts, 200);
						a.onUpdate = function() hand.scaleY = hand.scaleX;
						a.onEnd = function() {
							phase = 0;
							ratio = 0;
						}
					}
					if( !fadeAway )
						Game.ME.uiFx.dragDust(a, hand.x, hand.y);
				}
				if( fadeAway )
					hand.alpha = MLib.fmax(0, 1-ratio*1.6);
				hand.x = from.x + Math.cos(a)*ratio*d;
				hand.y = from.y + Math.sin(a)*ratio*d;
			},
			function(p) {
				tw.terminateWithoutCallbacks(hand.scaleX);
				hand.dispose();
			},
			true
		);
	}

	function dragEntity(e:Entity, r:Room) {
		_drag(
			function() return e.destroyAsked ? null : e.centerX,
			function() return e.destroyAsked ? null : e.centerY,
			function() return r.destroyed ? null : r.globalCenterX,
			function() return r.destroyed ? null : r.globalCenterY
		);
	}

	//function showGroom() {
		//var e = Assets.monsters2.h_getAndPlay("groomCatIdle", root);
		//e.filter = true;
		//e.setCenterRatio(0.5,1);
		//e.setPos(60, h()+50);
		//e.rotation = 0.1;
		//e.setScale(3);
		//tw.create(e.x, -100>e.x, 500);
	//}

	function dragSide(menu:ui.SideMenu, value:Dynamic, cx:Int, cy:Int, ?fadeAway=false) {
		function getPt() return b.Hotel.gridToPixels(cx,cy);

		_drag(
			function() return menu==null || menu.destroyed ? null : menu.getButtonCenter(value).x,
			function() return menu==null || menu.destroyed ? null : menu.getButtonCenter(value).y,
			function() return getPt().x + Const.ROOM_WID*0.5,
			function() return getPt().y - Const.ROOM_HEI*0.5,
			true, fadeAway
		);
		game.viewport.cancelTweens();
	}


	override function onDispose() {
		tw.terminateWithoutCallbacks(dark.alpha);
		cm.destroy();

		super.onDispose();

		requiredCommand = null;

		lastGlobalText = null;
		lastText = null;
		ctrap = null;
		wrapper = null;
		dark = null;

		topBar.dispose();
		topBar = null;

		bottomBar.dispose();
		bottomBar = null;

		if( ME==this )
			ME = null;
	}


	function wait(cb:Void->Bool) {
		createChildProcess(function(p) {
			if( cb() ) {
				cm.persistantSignal("wait");
				p.destroy();
			}
		});
	}


	function waitSelection(s:Selection) {
		createChildProcess(function(p) {
			if( game.selection.equals(s) ) {
				cm.persistantSignal("wait");
				p.destroy();
			}
		});
	}


	function lockSelection() {
		lockedSelection = game.selection;
	}

	function unlockSelection() {
		lockedSelection = null;
	}

	public function updateLockedSelection() {
		if( isRunning() && lockedSelection!=null && !lockedSelection.equals(game.selection) )
			switch( lockedSelection ) {
				case S_Room(r) : game.select(r);
				case S_Client(c) : game.select(c);
				case S_None : game.unselect();
			}
	}


	function allowClicks() {
		ctrap.visible = false;
	}

	function blockClicks() {
		ctrap.visible = true;
	}

	function getClientIf(cond:Client->Bool, ?minDuration=20) : en.Client {
		for(c in en.Client.ALL)
			if( !c.destroyAsked && c.room!=null && c.sclient.getRemainingDuration(Game.ME.serverTime)>=DateTools.seconds(minDuration) && cond(c) )
				return c;
		return null;
	}

	function getRoomIf(cond:Room->Bool) : Room {
		for(r in game.hotelRender.rooms)
			if( !r.destroyed && cond(r) )
				return r;
		return null;
	}


	function waitClick(?x=-1., ?y=-1.) {
		if( x==-1 )
			dark.setPos(w()*0.5, h()*0.5);
		else {
			//x-=w()*0.5;
			//y-=h()*0.5;
			dark.x = x;
			dark.y = y;
		}
		cd.set("click", Const.seconds(0.25));
		ctrap.visible = true;
		dark.alpha = 0;
		dark.visible = true;
		tw.create(dark.alpha, 0.75, 400);

		waitingClick = true;
		addContinueButton();

		onResize();
	}



	override function update() {
		super.update();

		if( game.destroyed || game.isVisitMode() )
			return;

		cm.update();

		if( !game.isPlayingLogs && !isRunning() && !game.hasAnyPopUp() ) {
			var t = Lang.t;
			var lobby = hotel.getRoomAt(0,0);
			var installed = shotel.getStat("install");

			// Fast access
			var clientMap = new Map();
			for( c in en.Client.ALL )
				clientMap.set(c.id, c);


			// Place first client!
			var e = clientMap.get(0);
			var r = hotel.getRoomAt(0,2);
			if( e!=null && r!=null && tryToStart("client1", DoInstallClient(e.id, r.rx, r.ry)) ) {
				var x = (lobby.globalLeft + 400 + r.globalCenterX)*0.5;
				var y = (lobby.globalCenterY + r.globalCenterY)*0.5;
				function taxi() {
					new en.Taxi(900);
				}
				cm.create({
					blockClicks();
					game.viewport.focusAndZoom(lobby.globalRight+200, lobby.globalCenterY, 2, 50);
					2000;
					taxi();
					2500;
					game.viewport.focusAndZoom(x,y, 0.7, 1500);
					2000;
					textScene( hotel.getRoomAt(0,1), Lang.t._("Welcome to your hotel!") );
					waitClick() > end("wait");

					clear();
					textScene( hotel.getRoomAt(0,1), Lang.t._("As a hotel manager, you will first have to assign bedrooms to your clients.") );
					waitClick() > end("wait");

					clear();
					game.viewport.focusAndZoom(x,y, 1, 2000);
					1000;
					focusScene(e);
					game.viewport.cancelTweens();
					600;
					textScene(e, t._("Hey look! This client is waiting for a bedroom..."));
					800;
					focusScene(r);
					game.viewport.cancelTweens();
					300;
					textScene(r, t._("...and THIS is a bedroom."));
					600;
					dragEntity(e, r);
					game.viewport.cancelTweens();
					allowClicks();
				});
			}


			// Place second one
			if( hasDone("client1") && !hasDone("client2") && shotel.countClientsInRooms()==1 ) {
				var c1 = hotel.getRoomAt(0,2).getClientInside();
				var c2 = getClientIf( function(c) return c.isWaiting() && c.sclient.emit==c1.sclient.likes[0] );
				var r = hotel.getRoomAt(1,2);
				var x = (c2.centerX + r.globalCenterX)*0.5 + 100;
				var y = (c2.centerY + r.globalCenterY)*0.5;
				if( c2!=null && tryToStart("client2", DoInstallClient(c2.id, r.rx, r.ry)) ) {
					cm.create({
						blockClicks();
						game.unselect();
						textScene( c1, t._("Its HAPPINESS factor is only ::n::/::max::.", {n:e.sclient.getCappedHappiness(), max:shotel.getMaxHappiness()}) );
						400;
						focusScene(c1.room, 2);
						waitClick() > end("wait");

						lockSelection();
						lockCommand("click");
						clear();
						game.viewport.cancelTweens();
						500;
						focusRoomHud(c1, "like", ">"+t._("He likes horrible smells so he needs a NEIGHBOUR that smells like old cheese.") + "|iconOdor", 0.15);
						game.viewport.cancelTweens();
						waitClick() > end("wait");

						clear();
						blockClicks();
						unlockSelection();
						game.unselect();
						arrowScene(c2, 0, -c2.hei, 0.4);
						game.viewport.focus(x,y,600);
						600;
						focusScene(c2, 1, 0, -65, ">"+t._("This one generates bad smells!") + "|iconOdor");
						game.viewport.cancelTweens();
						waitClick(w()*0.3, h()*0.8) > end("wait");

						clear();
						focusScene(r, 1);
						game.viewport.cancelTweens();
						400;
						dragEntity(c2,r);
						game.viewport.cancelTweens();
						unlockAllCommands();
					});
				}
			}

			// Elements explanation
			if( hasDone("client2") && tryToStart("elements") ) {
				var e = getClientIf( function(c) return c.isWaiting() );
				if( e!=null ) {
					cm.create({
						lockCommand("send");
						blockClicks();
						game.unselect();
						1000;
						textGlobal( t._("Good job! Now everyone is happier :)") );
						400;
						for(e in en.Client.ALL)
							if( !e.isWaiting() ) {
								e.clearBubbles();
								focusScene(e, 0.6, -65, -35);
								game.viewport.cancelTweens();
								300;
							}
						//focusViewportAt(0.5,2);
						waitClick()>end("wait");

						clear();
						#if mobile
						focusScene(e, true, t._("Tap on this client."));
						#else
						focusScene(e, true, t._("Click on this client."));
						#end
						waitSelection( S_Client(e) ) > end("wait");

						clear();
						lockSelection();
						lockCommand("click");
						500;
						game.viewport.focus(e.centerX+200, e.centerY);
						focusClientInfos(
							function(ci) return ci.ctxWid-ci.ctxPadding-20,
							function(ci) return ci.likeY+10,
							t._("This one likes the affect \"::affect::\", so he needs a NEIGHBOUR that generates it.", {affect:Lang.getAffect(e.sclient.likes[0])})+ "|"+Assets.getAffectIcon(e.sclient.likes[0])
						);
						waitClick(w()*0.6, h()*0.65) > end("wait");

						clear();
						focusClientInfos(
							function(ci) return ci.ctxWid-ci.ctxPadding-20,
							function(ci) return ci.likeY+55,
							t._("And he will generate the affect \"::affect::\" in all nearby bedrooms.", {affect:Lang.getAffect(e.sclient.emit)})+ "|"+Assets.getAffectIcon(e.sclient.emit)
						);
						game.viewport.cancelTweens();
						waitClick(w()*0.6, h()*0.65) > end("wait");

						complete(true);
					});
				}
			}



			// Gems
			if( hasDone("client2") && !hasDone("gems") ) {
				var c = getClientIf( function(c) return !c.isDone() && !c.isWaiting() && c.sclient.baseHappiness<=-10 && c.sclient.canBeSkipped(game.serverTime) );
				if( c!=null && tryToStart("gems", DoSkipClient(c.id)) ) {
					cancelCondition = function() return c.destroyAsked || c.isDone();
					cm.create({
						game.unselect();
						600;

						focusScene(c, Lang.t._("::n:: happiness? Seriously? Awww... Some clients, like this one, can be SUPER annoying.", {n:c.sclient.getHappiness()}));
						waitClick() > end("wait");

						clear();
						unlockFeature("gems");
						textScene(c, Lang.t._("Fortunately, we can get rid of any client using GEMS.")+"|moneyGem");
						waitClick() > end("wait");

						clear();
						focusScene(c.room, 1, Const.ROOM_WID*0.5-80, -Const.ROOM_HEI*0.5+40, true, Lang.t._("You will still get the FULL PAYMENT and the client will LEAVE immediatly. Kind of useful if you ask me.")+"|moneyGem");
						game.viewport.cancelTweens();
					});
				}
			}
			if( hasDone("gems") && tryToStart("postGems") ) {
				var pt = ui.MainStatus.CURRENT.getGemsCoords(false);
				pt.x += 50;
				cm.create({
					clear();
					_focus( function() return pt.x-50, function() return pt.y, 1.3 );
					game.viewport.cancelTweens();
					textFree( function() return w()*0.5, function() return 150, Lang.t._("You gems stock can be seen here.") );
					400>>ui.MainStatus.CURRENT.shakeGem();
					waitClick(w()*0.6, h()*0.1) > end("wait");

					complete(true);
				});
			}



			// Unlock room building
			if( hasDone("gems") && installed>=9 ) {
				var full = true;
				for(r in shotel.rooms)
					if( r.type==R_Bedroom && !r.hasClient() ) {
						full = false;
						break;
					}
				if( full && tryToStart("bedroom", DoCreateRoom(-99,-99,R_Bedroom)) ) {
					unlockFeature("build");
					unlockFeature("inspect");
					cm.create({
						textGlobal( t._("Your hotel is full: it's time to build more bedrooms!") );
						waitClick() > end("wait");

						clear();
						focusHudMenu("build", 1, true, t._("Open the new Workshop menu.")+"|iconBuild");
						game.viewport.cancelTweens();
						wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

						clear();
						blockClicks();
						lockCommand("side");
						game.viewport.cancelTweens();
						500;
						arrowSideButton(ui.side.BuildMenu.CURRENT, R_Bedroom);
						textGlobal( Lang.t._("DRAG the bedroom icon on a free spot near your hotel.") );
						//textGlobal( Lang.t._("Click and DRAG a bedroom near your hotel. If you place it in an isolated spot, clients inside will have extra bonuses. But they will lack the potential affects generated by other nearby clients. The choice is yours.") );
						allowClicks();
					});
				}
			}

			// Inspector
			if( !hasDone("inspect") ) {
				var c = getClientIf(function(c) return c.type==C_Inspector);
				var base = hotel.getNameBase();
				if( c!=null && base!=null && tryToStart("inspect") ) {
					cm.create({
						textScene(c, Lang.t._("INSPECTION!!"));
						game.viewport.focusRoom(lobby);
						waitClick() > end("wait");

						clear();
						focusScene(c, Lang.t._("This guy here is a Consortium Inspector. We HAVE to make him happy (::n:: happiness)!", {n:shotel.getMaxHappiness()}));
						game.viewport.cancelTweens();
						waitClick() > end("wait");

						clear();
						focusScene(base, 2.5, 0,-Const.ROOM_HEI, ">"+Lang.t._("If he is satisfied, he will grant us a new HOTEL STAR, right under our name! And this will also unlock new game content.")+"|star");
						waitClick() > end("wait");

						game.viewport.focus(c.centerX, c.centerY-200);
						complete(true);
					});
				}
			}


			// Bar
			if( hasDone("bedroom") && shotel.roomUnlocked(R_Bar) ) {
				if( shotel.hasRoomType(R_Bar) )
					tryToSkipTutorial("bar");
				else {
					var c = getClientIf(function(c) return c.sclient.money>0 && !c.isDone() && c.isWaiting());
					if( c!=null && tryToStart("bar", DoCreateRoom(-99,-99,R_Bar)) ) {
						cm.create({
							focusHudMenu("build", true, Lang.t._("You earned a STAR and unlocked the BAR: let's build it!")+"|itemBeer");
							game.viewport.focusRoom(lobby);
							wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

							clear();
							blockClicks();
							lockCommand("side");
							game.viewport.cancelTweens();
							500;
							arrowSideButton(ui.side.BuildMenu.CURRENT, R_Bar);
							textGlobal( Lang.t._("DRAG the Bar icon on a free spot near your hotel. It DOESN'T have to be near a bedroom.") );
							allowClicks();
						});
					}
				}
			}

			// Bar stock
			if( !hasDone("barStock") && shotel.hasRoomType(R_Bar) && !shotel.hasRoomType(R_StockBeer) ) {
				var r = hotel.getRoom(R_Bar, false);
				if( r!=null && tryToStart("barStock", DoCreateRoom(-99,-99,R_StockBeer)) ) {
					cm.create({
						focusHudMenu("build", true, Lang.t._("Your new Bar won't work without a Soda Storage.")+"|box_beer");
						wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

						clear();
						blockClicks();
						lockCommand("side");
						game.viewport.cancelTweens();
						500;
						arrowSideButton(ui.side.BuildMenu.CURRENT, R_StockBeer);
						textGlobal( Lang.t._("DRAG the Soda Storage icon on a free spot near your hotel. You can place it underground for example.") );
						allowClicks();
					});
				}
			}


			// Have a beer
			if( hasDone("barStock") && !hasDone("beer") && shotel.hasRoomType(R_Bar) && shotel.hasRoomType(R_StockBeer) && shotel.countStock(R_StockBeer)>0 ) {
				var c = getClientIf(function(c) return !c.isDone() && !c.isWaiting() && c.sclient.money>0);
				if( c!=null && tryToStart("beer", DoSendClientToUtilityRoom(c.id, -99,-99, 0)) ) {
					cancelCondition = function() return c==null || c.destroyAsked || c.isDone();
					unlockFeature("savings");
					for(r in hotel.rooms)
						r.updateHud();
					cm.create({
						focusRoomHud(c, "money", ">"+t._("To use your Bar, your clients have SAVINGS.")+"|moneyBill");
						waitClick() > end("wait");

						clear();
						focusScene(c, true, Lang.t._("Select this one."));
						waitSelection(S_Room(c.room)) > end("wait");

						clear();
						lockSelection();
						focusContextMenuButton(0, true, Lang.t._("Soda time! Send him to the bar!"));
					});
				}
			}
			if( hasDone("beer") && !hasDone("beerPost") && tryToStart("beerPost") ) {
				var r = hotel.getRoom(R_Bar);
				cm.create({
					focusScene(r, Lang.t._("The client used 1 SAVING and became happier! That's the power of sugar (as well as diabetes).")+"|moneyBill");
					waitClick() > end("wait");

					unlockFeature("buildTip");
					complete(true);
				});
			}


			// Laundry
			if( !hasDone("laundry") && shotel.roomUnlocked(R_Laundry) && !shotel.hasRoomType(R_Laundry) ) {
				if( tryToStart("laundry", DoCreateRoom(-99,-99,R_Laundry)) ) {
					cm.create({
						focusHudMenu("build", true, Lang.t._("We can build LAUNDRIES to extort money from our clients."));
						game.viewport.focusRoom(lobby);
						wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

						clear();
						blockClicks();
						lockCommand("side");
						arrowSideButton(ui.side.BuildMenu.CURRENT, R_Laundry);
						textGlobal( Lang.t._("We suggest you build this room underground.") );
						allowClicks();
					});
				}
			}
			// Laundry post
			if( hasDone("laundry") && !hasDone("laundryPost") ) {
				var r = hotel.getRoom(R_Laundry, false);
				if( r!=null && r.isWorking() && tryToStart("laundryPost") )
					cm.create({
						focusScene(r, Lang.t._("Note that a laundry takes some time to complete. It might be a good idea to build extra laundries or use TURBOS."));
						waitClick() > end("wait");
						complete(true);
					});
			}



			// Damaged room
			if( !hasDone("buildSoap") && shotel.hasRoomType(R_StockSoap) )
				tryToSkipTutorial("buildSoap");

			if( !hasDone("buildSoap") && shotel.roomUnlocked(R_StockSoap) ) {
				var r = hotel.rooms.filter( function(r) return r.is(R_Bedroom) && r.sroom.damages>0 && !r.sroom.hasClient() )[0];
				if( r!=null && tryToStart("buildSoap", DoCreateRoom(-99,-99,R_StockSoap)) ) {
					cm.create({
						focusScene(r, Lang.t._("This room was damaged by a client!"));
						waitClick() > end("wait");

						clear();
						focusHudMenu("build", true, Lang.t._("We need a Soap Storage to clean this mess.")+ "|iconSoap");
						wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

						clear();
						lockCommand("side");
						arrowSideButton(ui.side.BuildMenu.CURRENT, R_StockSoap);
						textGlobal( Lang.t._("We suggest you build this room underground.") );
						allowClicks();
					});
				}
			}


			// Toilet paper
			if( !hasDone("paper") && shotel.roomUnlocked(R_StockPaper) && !shotel.hasRoomType(R_StockPaper) ) {
				if( tryToStart("paper", DoCreateRoom(-99,-99,R_StockPaper)) ) {
					cm.create({
						game.viewport.focusRoom(lobby);
						textGlobal(Lang.t._("Clients have some... well... you see. Essential needs. Like you and me..."));
						waitClick() > end("wait");

						clear();
						focusHudMenu("build", true, Lang.t._("To fulfil their needs, we need to build a Toilet Paper storage.")+"|iconPq");
						wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

						clear();
						blockClicks();
						lockCommand("side");
						arrowSideButton(ui.side.BuildMenu.CURRENT, R_StockPaper);
						textGlobal( Lang.t._("We suggest you build this room underground.") );
						allowClicks();
					});
				}
			}



			// Items
			if( shotel.featureUnlocked("items") && !hasDone("items") ) {
				var itemMap = new Map();
				for(i in shotel.inventory) {
					var a = Solver.getEquipmentAffect(i);
					if( a!=null )
						itemMap.set(a, true);
				}

				var e = getClientIf( function(c) return !c.isDone() && !c.isWaiting() && !c.room.hasGifts() && c.sclient.getHappiness()<=shotel.getMaxHappiness()*0.6 && c.sclient.likes.length>0 && itemMap.exists(c.sclient.likes[0]) );
				if( e!=null ) {
					var i = switch( e.sclient.likes[0] ) {
						case Heat : I_Heat;
						case Odor : I_Odor;
						case Cold : I_Cold;
						case Noise : I_Noise;
						default : null;
					}
					if( i!=null && tryToStart("items", DoUseItemOnRoom(e.room.rx, e.room.ry, i)) ) {
						cancelCondition = function() return e.destroyAsked || e.isDone();
						unlockFeature("items");
						cm.create({
							blockClicks();
							game.unselect();
							lockCommand("side");
							600;
							textScene(e, t._("We can give PRESENTS to our clients. Select this one."));
							400;
							focusScene(e, true);
							allowClicks();
							waitSelection( S_Room(e.room) )>end("wait");

							clear();
							300;
							focusRoomHud( e, "like", t._("He likes ::affect::.", {affect:Lang.getAffect(e.sclient.likes[0])}) );
							//focusClientInfos(
								//function(ci) return ci.ctxWid-ci.ctxPadding-20,
								//function(ci) return ci.likeY+10,
								//t._("He likes ::affect::.", {affect:Lang.getAffect(e.sclient.likes[0])})
							//);
							waitClick()>end("wait");

							clear();
							300;
							ui.HudMenu.CURRENT.refresh();
							focusHudMenu("items", 2, true,
								t._("Let's send the present \"::item::\" to its room!", { item:mt.Utf8.uppercase(Lang.getItem(i).name) })
							);
							unlockCommand("side");
							wait( function() return ui.side.ItemMenu.CURRENT.isOpen ) > end("wait");

							clear();
							lockCommand("side");
							300;
							focusScene(e.room);
							game.viewport.cancelTweens();
							200;
							dragSide(ui.side.ItemMenu.CURRENT, i, e.room.rx, e.room.ry);
							focusViewportAt(e.room.rx+1, e.room.ry);
						});
						onComplete = function() {
							game.unselect();
						}
					}
				}
			}
			if( hasDone("items") && tryToStart("itemsPost") )
				cm.create({
					focusHudMenu("items", Lang.t._("You can use as many present as you wish."));
					waitClick(w()*0.8, h()*0.6) > end("wait");
					complete(true);
				});


			// Customization
			if( !hasDone("custom") && shotel.featureUnlocked("custom") ) {
				var i = I_Texture(0);
				if( !shotel.hasInventoryItem(i) )
					tryToSkipTutorial("custom");

				var bedroom = hotel.getRoom(R_Bedroom, false);

				if( bedroom!=null && tryToStart("custom", DoUseItemOnRoom(-99,-99, i)) ) {
					cm.create({
						focusHudMenu("custom", true, Lang.t._("It's time to customize your Bedrooms to your own taste."));
						wait( function() return ui.side.CustomizeMenu.CURRENT.isOpen ) > end("wait");

						lockCommand("side");
						clear();
						textFree(
							function() return w()*0.92,
							function() return h()*0.5,
							Lang.t._("We can customize our Bedrooms in a lot of ways: colors, wallpapers, furnitures...")+"|iconPaint"
						);
						waitClick(w()*0.9, h()*0.5) > end("wait");

						clear();
						lockCommand("customBack");
						lockCommand("customOnlyTexture");
						focusSideButton(ui.side.CustomizeMenu.CURRENT, "wallPaper", true, Lang.t._("Let's add a wallpaper..."));
						wait( function() return ui.side.CustomizeMenu.CURRENT.isCat(I_Texture(-1)) ) > end("wait");

						clear();
						300;
						dragSide(ui.side.CustomizeMenu.CURRENT, i, bedroom.rx, bedroom.ry, true);
						200;
						textGlobal(Lang.t._("Place this wallpaper in one of your bedrooms."));
					});
				}
			}
			if( hasDone("custom") && !hasDone("custom2") ) {
				var i = I_Bed(0);
				if( !shotel.hasInventoryItem(i) )
					tryToSkipTutorial("custom2");

				var bedroom = hotel.getRoom(R_Bedroom, false);

				if( bedroom!=null && tryToStart("custom2", DoUseItemOnRoom(-99,-99, i)) )
					cm.create({
						focusHudMenu("custom", true, Lang.t._("Each decoration element gives +::n:: happiness to clients in this room. Let's add another one.", {n:GameData.CUSTOMIZATION_POWER}));
						wait( function() return ui.side.CustomizeMenu.CURRENT.isOpen ) > end("wait");

						clear();
						lockCommand("side");
						lockCommand("customBack");
						lockCommand("customOnlyBed");
						focusSideButton(ui.side.CustomizeMenu.CURRENT, "bed", true, Lang.t._("Now let's pick a Bed..."));
						wait( function() return ui.side.CustomizeMenu.CURRENT.isCat(I_Bed(-1)) ) > end("wait");

						clear();
						300;
						dragSide(ui.side.CustomizeMenu.CURRENT, i, bedroom.rx, bedroom.ry, true);
						200;
						textGlobal(Lang.t._("Place this bed in one of your bedrooms."));
					});
			}
			if( hasDone("custom2") && tryToStart("customPost") ) {
				cm.create({
					ui.side.CustomizeMenu.CURRENT.open();
					textFree(
						function() return w()*0.8,
						function() return h()*0.5,
						Lang.t._("You can get new customization items from VIPs or Inspectors!")+"|gift"
					);
					waitClick(w()*0.9, h()*0.5) > end("wait");

					complete(true);
				});
			}


			// Quests (build library)
			if( !hasDone("questBuild") && shotel.roomUnlocked(R_Library) ) {
				if( shotel.hasRoomType(R_Library) )
					tryToSkipTutorial("questBuild");
				else if( tryToStart("questBuild", DoCreateRoom(-99,-99, R_Library)) ) {
					cm.create({
						focusHudMenu("build", true, Lang.t._("We have unlocked the Great Library!") + "|iconQuest");
						wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

						clear();
						lockCommand("side");
						arrowSideButton(ui.side.BuildMenu.CURRENT, R_Library);
						textGlobal( Lang.t._("We suggest you build this room underground.") );
					});
				}
			}


			// Quests
			if( hasDone("questBuild") && !hasDone("quests") ) {
				var r = hotel.getRoom(R_Library);
				if( r!=null && !r.isUnderConstruction() && tryToStart("quests") )
					cm.create({
						focusScene(r, Lang.t._("The Great Library unlocked the CONTRACTS!"));
						waitClick() > end("wait");

						clear();
						textFree(
							function() return 100,
							function() return 150,
							">"+Lang.t._("Contracts are a great mean to earn special rewards, like decorations or gems!")+"|gift"
						);
						500;
						unlockFeature("quests");
						500;
						_focus(
							function() return 100,
							function() return 50,
							1.8
						);
						game.viewport.cancelTweens();
						waitClick(w()*0.1, 150) > end("wait");

						clear();
						lockCommand("side");
						_focus(
							function() return 75,
							function() return 50,
							2, true,
							">"+Lang.t._("Click on the scroll to examine your current contract.")
						);
						game.viewport.cancelTweens();
						wait( function() return ui.side.Quests.CURRENT.isOpen ) > end("wait");

						clear();
						textSideButton(ui.side.Quests.CURRENT,0, Lang.t._("Complete this objective to get your reward!"));
						waitClick(w()*0.1, h()*0.5) > end("wait");

						complete(true);
					});
			}

			if( hasDone("quests") && shotel.hasInventoryItem(I_LunchBoxAll) && tryToStart("questLoot", DoUseItem(I_LunchBoxAll)) ) {
				var pt = ui.LunchBoxMenu.CURRENT.getCoords();
				cm.create({
					lockCommand("side");
					_focus(
						function() return pt.x,
						function() return pt.y,
						2,true,
						">"+Lang.t._("Well done! You succesfully completed a Contract! Pick your loot here.")+"|iconQuest"
					);
					game.viewport.cancelTweens();
				});
			}

			if( hasDone("questLoot") && shotel.countDailyQuests()==0 ) {
				if( tryToStart("questRefill") ) {
					var pt = ui.LunchBoxMenu.CURRENT.getCoords();
					cm.create({
						lockCommand("side");
						_focus(
							function() return 75,
							function() return 50,
							2, true,
							">"+Lang.t._("When you don't have any contract, you can easily get new ones!")
						);
						game.viewport.cancelTweens();
						wait( function() return ui.side.Quests.CURRENT.isOpen ) > end("wait");

						clear();
						focusSideButton(ui.side.Quests.CURRENT,0, 2, ">"+Lang.t._("GEMS can be used to start extra contracts.")+"|moneyGem", true);
						waitClick(w()*0.1, h()*0.5) > end("wait");

						complete(true);
					});
				}
			}


			if( shotel.featureUnlocked("cold") && tryToStart("cold") ) {
				cm.create({
					textCenter( Lang.t._("Your hotel is known from everywhere around the world, including some REALLY far places, like Antarctic...") );
					waitClick() > end("wait");

					clear();
					textCenter( Lang.t._("Some clients will now like, dislike or emit a new effect: COLD!")+"|iconCold" );
					waitClick() > end("wait");

					clear();
					focusHudMenu("items", true);
					wait( function() return ui.side.ItemMenu.CURRENT.isOpen ) > end("wait");

					clear();
					focusSideButton( ui.side.ItemMenu.CURRENT, I_Cold, Lang.t._("You also have a new item to help you satisfy them: ::name::", {name:Lang.getItem(I_Cold).name}) );
					waitClick(w()*0.8, h()*0.5) > end("wait");

					complete(true);
				});
			}


			if( shotel.featureUnlocked("happy35") && tryToStart("happy35") ) {
				var base = hotel.getNameBase();
				var c = getClientIf( function(c) return c.isWaiting() );
				cm.create({
					focusScene(base, 2.5, 0,-Const.ROOM_HEI, Lang.t._("You are now known as one the most prestigious hotel in the world!") );
					waitClick() > end("wait");

					clear();
					textFree(
						function() return w()*0.65,
						function() return h()*0.5,
						Lang.t._("All your clients are now RICHER: they will pay you more if they are happy!")+"|moneyGold"
					);
					waitClick() > end("wait");

					clear();
					focusScene(c, Lang.t._("They are also a little more demanding. Their maximum Happiness is now ::max:: instead of ::n::!", {max:shotel.getMaxHappiness(), n:30}));
					waitClick() > end("wait");

					complete(true);
				});
			}



			if( shotel.featureUnlocked("happy40") && tryToStart("happy40") ) {
				var base = hotel.getNameBase();
				var c = getClientIf( function(c) return c.isWaiting() );
				cm.create({
					focusScene(base, 2.5, 0,-Const.ROOM_HEI, Lang.t._("Your prestige brings you more demanding clients!") );
					waitClick() > end("wait");

					clear();
					focusScene(c, Lang.t._("Their maximum Happiness is now ::max:: instead of ::n::!", {max:shotel.getMaxHappiness(), n:35}));
					waitClick() > end("wait");

					complete(true);
				});
			}


			if( shotel.featureUnlocked("happy45") && tryToStart("happy45") ) {
				var base = hotel.getNameBase();
				var c = getClientIf( function(c) return c.isWaiting() );
				cm.create({
					focusScene(base, 2.5, 0,-Const.ROOM_HEI, Lang.t._("Your prestige brings you more demanding clients!") );
					waitClick() > end("wait");

					clear();
					focusScene(c, Lang.t._("Their maximum Happiness is now ::max:: instead of ::n::!", {max:shotel.getMaxHappiness(), n:40}));
					waitClick() > end("wait");

					complete(true);
				});
			}


			if( shotel.featureUnlocked("miniGame") ) {
				var c = getClientIf( function(c) return c.isSleeping() );
				if( c!=null && tryToStart("miniGame", DoMiniGame(c.id)) ) {
					cancelCondition = function() return c.destroyAsked || c.isDone();
					cm.create({
						focusScene(c, Lang.t._("This client is asleep!") );
						waitClick() > end("wait");

						clear();
						focusScene(c, true, Lang.t._("We can take this opportunity to STEAL some money from him! :)")+"|moneyGold");
					});
				}
			}

			if( hasDone("miniGame") && tryToStart("miniGamePost") ) {
				cm.create({
					1500;
					textCenter(Lang.t._("Sometime, you will get small rewards, but sometimes, it will be A LOT MORE!")+"|moneyGold");
					waitClick() > end("wait");
					complete(true);
				});
			}

			// Premium shop
			if( !hasDone("premium") ) {
				var boost = hotel.getRoom(R_StockBoost);
				var beer = hotel.getRoom(R_StockBeer);
				var eid = Data.PremiumKind.Booster1.toString();
				if( shotel.hasPremiumUpgrade(eid) )
					tryToSkipTutorial("premium");
				else {
					var upgrade = Data.Premium.resolve(eid);
					if( boost!=null && beer!=null && shotel.gems>=upgrade.price && boost.sroom.data==0 && beer.sroom.data==0 && !beer.sroom.hasBoost() && tryToStart("premium", DoBuyPremium(eid)) ) {
						cm.create({
							focusScene(boost, Lang.t._("Your generator contains only 1 booster, so it's already empty...")+"|batteryEmpty");
							waitClick() > end("wait");

							clear();
							unlockFeature("premium");
							focusHudMenu("premium", true, Lang.t._("Let's upgrade it!"));
							wait( function() return ui.side.PremiumShop.CURRENT.isOpen ) > end("wait");

							clear();
							blockClicks();
							lockCommand("side");
							game.viewport.cancelTweens();
							500;
							textSideButton(ui.side.PremiumShop.CURRENT, eid, Lang.t._("We added 1 gem to your stock.")+"|moneyGem");
							300>>ui.MainStatus.CURRENT.shakeGem();
							waitClick() > end("wait");

							clear();
							lockCommand("side");
							arrowSideButton(ui.side.PremiumShop.CURRENT, eid);
							textGlobal( Lang.t._("Build the Generator upgrade.") );
							allowClicks();
						});
					}
				}
			}
			if( hasDone("premium") && !hasDone("premiumPost") ) {
				var boost = hotel.getRoom(R_StockBoost);
				if( boost!=null && tryToStart("premiumPost") )
					cm.create({
						700;
						focusScene(boost, Lang.t._("Your generator room now has 2 boosters instead of 1 and this upgrade will be PERMANENT."));
						waitClick() > end("wait");

						clear();
						focusHudMenu("premium", true, Lang.t._("You can buy many other permanent upgrades from this menu!"));
						waitClick(w()*0.8, h()*0.4) > end("wait");

						complete(true);
					});
			}


			//if( shotel.featureUnlocked("upgradeLobby") && tryToStart("upgradeLobby", DoUpgradeRoom(lobby.rx, lobby.ry)) ) {
				//cm.create({
					//blockClicks();
					//lockCommand("side");
					//game.viewport.focusRoom(lobby);
					//500;
					////textGlobal(Lang.t._("Upgrading your Lobby will expand the WAITING LINE, giving you more strategic choices when installing your clients."));
					//textGlobal(Lang.t._("You can now upgrade your Lobby to expand your WAITING LINE."));
					//waitClick() > end("wait");
//
					//clear();
					//focusScene(lobby, 1, lobby.wid*0.5-140, -lobby.hei*0.5+40, true, Lang.t._("The first upgrade is free!"));
					//wait( function() return Game.ME.cd.has("lobbyLevelUpOpen") ) > end("wait");
//
					//clear();
				//});
			//}

			// TEST
			#if debug
			//if( tryToStart("test") ) {
				//var c = getClientIf(function(c) return true);
				//cm.create({
					//textFree(function() return -9999, function() return 9999, "Cum sociis natoque penatibus et magnis dis parturient montes volutpat.");
					//waitClick() > end("wait");
//
					//clear();
					//focusScene(c, "Pellentesque diam purus; consequat sed dolor non, aliquet aliquet diam. Vivamus consequat libero nec pharetra sagittis. Aliquam erat nullam.");
					//wait(function() return false) > end("wait");
//
					//clear();
					//textCenter("Pellentesque diam purus; consequat sed dolor non, aliquet aliquet diam. Vivamus consequat libero nec pharetra sagittis. Aliquam erat nullam.");
					//waitClick() > end("wait");
				//});
			//}
			#end




			// Build Bank (contextual)
			if( !hasDone("buildBank") && shotel.roomUnlocked(R_Bank) && !shotel.hasRoomType(R_Bank) && tryToStart("buildBank", DoCreateRoom(-99,-99,R_Bank)) ) {
				cm.create({
					focusHudMenu("build", 1, true, t._("You have unlocked a special room: the Bank!"));
					game.viewport.cancelTweens();
					wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

					clear();
					blockClicks();
					lockCommand("side");
					game.viewport.cancelTweens();
					500;
					arrowSideButton(ui.side.BuildMenu.CURRENT, R_Bank);
					textGlobal( Lang.t._("DRAG the room icon on a free spot near your hotel.") );
					allowClicks();
				});
			}
			if( hasDone("buildBank") && shotel.hasRoomType(R_Bank) && tryToStart("bankPost") ) {
				var inf = Lang.getRoom(R_Bank);
				cm.create({
					textGlobal(inf.role);
					game.viewport.focusRoom( hotel.getRoom(R_Bank) );
					waitClick() > end("wait");

					complete(true);
				});
			}


			// Build Custo Recycler (contextual)
			if( !hasDone("buildCustoRecycler") && shotel.roomUnlocked(R_CustoRecycler) && !shotel.hasRoomType(R_CustoRecycler) && tryToStart("buildCustoRecycler", DoCreateRoom(-99,-99,R_CustoRecycler)) ) {
				cm.create({
					focusHudMenu("build", 1, true, t._("You have unlocked a special room: the Decoration Recycler!"));
					game.viewport.cancelTweens();
					wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

					clear();
					blockClicks();
					lockCommand("side");
					game.viewport.cancelTweens();
					500;
					arrowSideButton(ui.side.BuildMenu.CURRENT, R_CustoRecycler);
					textGlobal( Lang.t._("DRAG the room icon on a free spot near your hotel.") );
					allowClicks();
				});
			}
			if( hasDone("buildCustoRecycler") && shotel.hasRoomType(R_Bank) && tryToStart("buildCustoRecyclerPost") ) {
				var inf = Lang.getRoom(R_CustoRecycler);
				cm.create({
					textGlobal(inf.role);
					game.viewport.focusRoom( hotel.getRoom(R_CustoRecycler) );
					waitClick() > end("wait");

					complete(true);
				});
			}


			// Build VipCall (contextual)
			if( !hasDone("buildVipCall") && shotel.roomUnlocked(R_VipCall) && !shotel.hasRoomType(R_VipCall) && tryToStart("buildVipCall", DoCreateRoom(-99,-99,R_VipCall)) ) {
				cm.create({
					focusHudMenu("build", 1, true, t._("You have unlocked a special room: the Marketing Service!"));
					game.viewport.cancelTweens();
					wait( function() return ui.side.BuildMenu.CURRENT.isOpen ) > end("wait");

					clear();
					blockClicks();
					lockCommand("side");
					game.viewport.cancelTweens();
					500;
					arrowSideButton(ui.side.BuildMenu.CURRENT, R_VipCall);
					textGlobal( Lang.t._("DRAG the room icon on a free spot near your hotel.") );
					allowClicks();
				});
			}


			// VIP (contextual)
			if( !hasDone("vip") && shotel.featureUnlocked("vip") ) {
				var e = getClientIf( function(c) return !c.isDone() && c.isVip(), 0 );
				if( e!=null && tryToStart("vip") ) {
					cancelCondition = function() return e.destroyAsked;
					cm.create({
						blockClicks();
						lockCommand("send");
						game.unselect();
						500;
						game.viewport.focus(e.centerX, e.centerY);
						textScene(e, Lang.t._("Your reputation brings you new important clients!"));
						waitClick() > end("wait");

						clear();
						focusScene(e, true, Lang.t._("This client is a VIP: click on him")+"|iconVip");
						waitSelection(!e.isWaiting() ? S_Room(e.room) : S_Client(e)) > end("wait");

						clear();
						600;
						_arrow(
							function() return w()*0.5,
							function() return 200,
							0, -1.57
						);
						textFree(
							function() return w()*0.30,
							function() return 150,
							Lang.t._("He has some special effects, as you can see here... Bring him to ::n:: happiness and he will pay you a lot of money!", {n:shotel.getMaxHappiness()})
						);
						waitClick(w()*0.3, 150) > end("wait");

						complete(true);
					});
				}
			}


			// Sunlight (contextual)
			if( !hasDone("sunlight") ) {
				var e = getClientIf( function(c) return !c.isDone() && c.sclient.hasDislike(SunLight), 0 );
				var r = getRoomIf( function(r) return r.is(R_Bedroom) && r.sroom.getSunlight()>0 );
				if( r!=null && e!=null && tryToStart("sunlight") ) {
					cancelCondition = function() return e.destroyAsked || e.isDone();
					var side = shotel.hasRoomExceptFiller(r.sroom.cx-1, r.sroom.cy) ? 1 : -1;
					cm.create({
						blockClicks();
						focusScene(e, Lang.t._("Some clients don't like SUNLIGHT.")+"|iconLight");
						waitClick() > end("wait");

						clear();
						focusScene(r, 1.6, Lang.t._("All the bedrooms that are close to the SIDES of your hotel have sunlight (thanks to windows)."));
						waitClick() > end("wait");

						clear();
						r.setCustomsAlpha(0.1);
						focusScene(r, 1, Const.ROOM_WID*0.4*side, 50, Lang.t._("This ray of light indicates the presence of sunlight."));
						waitClick() > end("wait");

						clear();
						r.setCustomsAlpha(1);
						focusScene(e, Lang.t._("Basically, don't install a client that hates sunlight in a room that has it.")+"|iconLight");
						waitClick() > end("wait");

						complete(true);
					});
				}
			}


			// Maxed happiness (contextual)
			if( !hasDone("maxed") ) {
				var e = getClientIf( function(c) return c.type!=C_Inspector && c.sclient.happinessMaxed(), 0 );
				if( e!=null && tryToStart("maxed") ) {
					cancelCondition = function() return e.destroyAsked;
					cm.create({
						blockClicks();
						lockCommand("side");
						game.unselect();
						arrowScene(e, -60, -e.hei+40, 0.7);
						300;
						textScene(e, ">" + t._("This client was so satisfied (::n:: happiness) that he decided to free its room IMMEDIATLY and pay the FULL PRICE!", {n:shotel.getMaxHappiness()})+"|moneyGold");
						500;
						waitClick() > end("wait");
						complete(true);
					});
				}
			}


			// Beer booster (contextual)
			if( !hasDone("booster") && shotel.hasRoomType(R_StockBeer) && shotel.countStock(R_StockBeer)==0 && shotel.countStock(R_StockBoost)>0 ) {
				var beer = hotel.getRoom(R_StockBeer);
				var boost = hotel.getRoom(R_StockBoost);
				if( boost!=null && tryToStart("booster", DoBoostRoom(beer.rx, beer.ry)) ) {
					cancelCondition = function() return shotel.countStock(R_StockBeer)>0;
					unlockFeature("booster");
					cm.create({
						game.unselect();
						focusScene(beer, Lang.t._("Your soda storage is depleted. We can refill it with a TURBO."));
						waitClick() > end("wait");

						clear();
						focusScene(boost, Lang.t._("TURBOS are free and they regen over time, but you have a limited number of them."));
						waitClick() > end("wait");

						clear();
						focusScene(beer, 1, beer.wid*0.5-80, -beer.hei*0.5+40, true);
					});
				}
			}


			// Generator refill (contextual)
			//if( noRecentTuto() && hasDone("gems") && shotel.countStock(R_StockBoost)==0 && shotel.gems>0 ) {
				//var r = hotel.getRoom(R_StockBoost);
				//if( r!=null && tryToStart("boosterRefill", DoActivateRoom(r.rx, r.ry)) ) {
					//cancelCondition = function() return shotel.countStock(R_StockBoost)>0;
					//cm.create({
						//game.unselect();
						//focusScene(r, 1, r.wid*0.5-80, -r.hei*0.5+40, true, Lang.t._("Your turbo generator is empty. Let's use a GEM to refill it completely!"));
					//});
				//}
			//}



			// Love
			if( !hasDone("love") && shotel.featureUnlocked("love") ) {
				var c = getClientIf( function(c) return !c.isWaiting() && !c.isDone() && !c.sclient.hasHappinessMod(HM_Love) );
				if( c!=null && tryToStart("love", DoGiveLove(c.id)) ) {
					unlockFeature("love");
					cm.create({
						lockCommand("side");
						focusScene(c, true, Lang.t._("You can now give LOVE to make your clients even happier!")+"|moneyLove");
						waitSelection(S_Room(c.room)) > end("wait");

						clear();
						lockSelection();
						focusContextMenuButton(0, true, Lang.t._("Give this client a nice and warm hug :)"));
					});
				}
			}

			// Love refill
			if( hasDone("love") && tryToStart("loveRefill") ) {
				var pt = ui.MainStatus.CURRENT.getLoveCoords(false);
				pt.x += 50;
				unlockFeature("premium");
				cm.create({
					blockClicks();

					textGlobal(Lang.t._("The client is now a little happier :)"));
					waitClick() > end("wait");

					clear();
					_focus( function() return pt.x-50, function() return pt.y, 1.3 );
					game.viewport.cancelTweens();
					textFree( function() return w()*0.5, function() return 150, Lang.t._("You love counter can be seen here.") );
					400>>ui.MainStatus.CURRENT.shakeLove();
					waitClick(w()*0.7, h()*0.1) > end("wait");

					clear();
					focusHudMenu("contacts", Lang.t._("You can get more love by VISITING your friends hotels."));
					waitClick(w()*0.8, h()*0.4) > end("wait");

					clear();
					focusHudMenu("premium", Lang.t._("You can also buy new permanent upgrades that will boost the Love power!"));
					waitClick(w()*0.8, h()*0.5) > end("wait");

					complete(true);
				});
			}




			// Inbox
			#if connected
			if( shotel.featureUnlocked("inbox") && noRecentTuto() && !hasDone("inbox") && game.hdata.inboxCount>0 && tryToStart("inbox") ) {
				cm.create({
					focusHudMenu("inbox", true, game.hdata.inboxCount>1 ? Lang.t._("You have multiple unread messages!") : Lang.t._("You have an unread message!"));
					wait( function() {
						return ui.side.Inbox.CURRENT.isOpen;
					}) > end("wait");

					complete(true);
				});
			}
			#end

		}

		// Something went wrong, cancel!
		if( cancelCondition!=null && cancelCondition() )
			complete(false);
	}
}

