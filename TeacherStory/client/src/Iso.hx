import mt.deepnight.SpriteLib;
import mt.deepnight.Tweenie;
import mt.deepnight.Color;
import flash.display.Sprite;

typedef Point = {x:Int,y:Int}
typedef LinkedSprite = {k:String, spr:Sprite, dx:Float, dy:Float, center:Bool}

class Iso {
	static var CENTER_X	= 185;
	static var CENTER_Y	= 30;
	static var UNIQ = 0;
	static var HEIGHT_MAP :Array<Array<Int>>;
	
	public var man		: Manager;
	public var cd		: mt.deepnight.Cooldown;
	public var uid		: Int;
	public var speed	: Float;
	public var cx		: Int;
	public var cy		: Int;
	public var ch		: Float; // altitude
	public var xr		: Float;
	public var yr		: Float;
	var tmp_xr			: Float;
	var tmp_yr			: Float;
	var dh				: Float;
	
	public var depth		: Float;
	public var layer		: Int;
	public var sprite		: DSprite;
	public var furnMc		: Null<flash.display.MovieClip>;
	public var shadow		: Null<DSprite>;
	public var fl_static	: Bool;
	public var tmpSpeedMul	: Float;
	public var accel		: Float;
	public var accelMul		: Float;
	public var minSpeed		: Float;
	var yOffset				: Int;
	public var headY		: Int;
	public var shakeX		: Float;
	public var filterTarget	: flash.display.DisplayObject;
	var button				: Null<Sprite>;
	public var zpriority	: Float;
	public var collides		: Bool;
	public var autoRun		: Float;
	
	var standPoint			: Null<{dx:Int, dy:Int}>;
	
	public var fl_visible(default, setVisible)	: Bool;
	public var alpha(default, setAlpha)			: Float;
	
	var hole			: Null<flash.display.Bitmap>;
	
	var path			: Array<{x:Int,y:Int}>;
	var move			: Null<{x:Int,y:Int}>;
	var bubbles			: Array<Sprite>;
	
	//public var emote		: Null<Sprite>;
	public var speechColor	: Int;
	public var clickZone	: Null< {x:Float, y:Float, radius:Float, cb:Void->Void, desc:String} >;
	public var linkedAction	: Null<Common.TAction>;
	public var allowClick	: Bool;
	public var glowClick	: Bool;
	public var glowOver		: Bool;
	var overed				: Bool;
	//var wasOver				: Bool;
	var linkedSprites		: Array<LinkedSprite>;
	
	public function new(?s:DSprite, ?x:Int, ?y:Int) {
		man = Manager.ME;
		uid = UNIQ++;
		sprite = s==null ? new DSprite() : s;
		cd = new mt.deepnight.Cooldown();
		
		overed = false;
		accel = 0.08;
		accelMul = 0;
		fl_static = true;
		path = new Array();
		bubbles = new Array();
		zpriority = 0;
		allowClick = true;
		glowClick = true;
		glowOver = true;
		cx = 0;
		cy = 0;
		ch = 0;
		dh = 0;
		alpha = 1;
		shakeX = 0;
		headY = 0;
		layer = 0;
		xr = 0.5;
		yr = 0.5;
		minSpeed = 0.13;
		tmp_xr = tmp_yr = 0;
		yOffset = 0;
		speed = 0.2;
		tmpSpeedMul = 1;
		//speed += 0.1;
		filterTarget = sprite;
		speechColor = 0xffffff;
		linkedSprites = new Array();
		collides = false;
		//wasOver = false;
		autoRun = 0;
		
		fl_visible = true;
		
		if( x!=null && y!=null )
			setPos(x,y);
			
		calcDepth();
		register();
	}
	
	public function setShadow(b:Bool) {
		if( shadow!=null ) {
			shadow.parent.removeChild(shadow);
			shadow = null;
		}
		if( b ) {
			shadow = man.tiles.getSprite("shadow");
			sprite.addChildAt(shadow, 0);
			shadow.y = 22;
			shadow.alpha = 0.4;
			shadow.setCenter(0.5, 0.5);
		}
	}
	
	public static function initHeightMap() {
		HEIGHT_MAP = new Array();
		for(x in 0...Const.RWID) {
			HEIGHT_MAP[x] = new Array();
			for(y in 0...Const.RHEI)
				HEIGHT_MAP[x][y] = 0;
		}
	}
	
	public static inline function setHeightMap(cx,cy, h) {
		if( cx>=0 && cx<Const.RWID && cy>=0 && cy<Const.RHEI )
			HEIGHT_MAP[cx][cy] = h;
	}
	
	inline function getHeightMap(cx,cy) {
		return
			if( cx<0 || cx>=Const.RWID || cy<0 || cy>=Const.RHEI )
				0;
			else
				return HEIGHT_MAP[cx][cy];
	}
	
	
	
	public function removeLinkedSprite(k:String) {
		for(ls in linkedSprites)
			if( ls.k==k ) {
				ls.spr.parent.removeChild(ls.spr);
				linkedSprites.remove(ls);
				return;
			}
	}
	public function addLinkedSprite(k:String, s:Sprite, ?dx=0., ?dy=0., ?center=false) {
		removeLinkedSprite(k);
		man.gscroller.addChild(s);
		linkedSprites.push({
			k : k,
			spr : s,
			dx : dx,
			dy : dy,
			center : center
		});
		updateLinkedSprites();
	}
	
	function updateLinkedSprites() {
		var pt = getInScrollCoords();
		for( ls in linkedSprites ) {
			ls.spr.x = Std.int( pt.x + ls.dx + (ls.center ? -ls.spr.width*0.5 : 0 ) );
			ls.spr.y = Std.int( pt.y + ls.dy );
		}
		
		if( shadow!=null )
			shadow.y = 22+ch;
	}
	
	
	public function setStandPoint(dx,dy) {
		standPoint = {dx:dx, dy:dy}
	}
	
	public function addFurnMc(mc:flash.display.MovieClip, ?id:String, ?flip=false, ?dx=0, ?dy=0) {
		if( furnMc!=null )
			furnMc.parent.removeChild(furnMc);
		furnMc = mc;
		sprite.addChild(mc);
		if( flip )
			mc.scaleX = -1;
		mc.x = Std.int(mc.x + dx);
		mc.y = Std.int(mc.y + 29 + dy);
		collides = true;
		if( id!=null )
			man.furns.set(id, this);
	}
	
	public function getDirTo(?e:Iso, ?tcx:Int, ?tcy:Int) {
		if( e!=null ) {
			tcx = e.cx;
			tcy = e.cy;
		}
		var a = mt.deepnight.Lib.deg(Math.atan2(tcy-cy, tcx-cx));
		return
			if( a>=45 && a<135 )
				2;
			else if( a>=135 || a<-135 )
				3;
			else if( a>=-135 && a<-45 )
				0;
			else
				1;
	}
	
	public function setAmbiantDesc(x:Float,y:Float,radius:Float, name:String, ?desc:String) {
		if( man.sick )
			name = man.tg.m_deliriumNameReplacement();
		setClick(x,y,radius, name, function() {
			if( desc!=null ) {
				var t = man.teacher;
				Manager.SBANK.bip01().play(0.5);
				if( !man.sick )
					t.setDir( t.getDirTo(this) );
					
				man.tip.hide();
				if( man.sick ) {
					t.say(man.tg.m_deliriumDescReplacement());
					t.cd.set("agony", 30*8);
				}
				else
					t.say(desc);
			}
		});
		glowOver = false;
		glowClick = false;
	}
	
	public function setClick(x:Float,y:Float,radius:Float, desc:String, cb:Void->Void) {
		if( man.photoMode )
			return;
		clickZone = {
			//r	: new flash.geom.Rectangle(x-w*0.5,y-h*0.5, w,h),
			x		: x,
			y		: y,
			radius	: radius,
			cb		: cb,
			desc	: "<font color='#86A4B5'>"+desc+"</font>",
		}
		#if debug
		var s = new Sprite(); sprite.addChild(s); s.graphics.lineStyle(1, 0xFFFF00, 0.5); s.graphics.drawCircle(clickZone.x, clickZone.y, clickZone.radius);
		#end
	}
	
	public function setClickAction(x,y,radius, a:Common.TAction) {
		var data = Common.getTActionData(a);
		setClick(x,y,radius, man.formatTip(data.name+"|"+data.desc), callback(man.useEquipment, this, a));
		linkedAction = a;
	}
	
	public inline function onClick() {
		if( allowClick )
			clickZone.cb();
	}
	
	public inline function hasClick() {
		return clickZone!=null;
	}
	
	public inline function over(pt) {
		return
			if( clickZone==null || man.interfaceLocked() )
				false;
			else {
				var cx = clickZone.x + sprite.x;
				var cy = clickZone.y + sprite.y;
				if( Math.abs(pt.x-cx)>clickZone.radius || Math.abs(pt.y-cy)>clickZone.radius )
					return false;
				else {
					var d = mt.deepnight.Lib.distanceSqr(pt.x, pt.y, cx, cy);
					if( d<=clickZone.radius*clickZone.radius )
						return Math.sqrt(d)<=clickZone.radius;
					else
						return false;
				}
				//var r = clickZone.r.clone();
				//r.x+=sprite.x;
				//r.y+=sprite.y;
				//r.contains(pt.x, pt.y);
			}
	}
	
	public function enableHole() {
		if( Const.LOWQ )
			return;

		var r = 40;
		var s = new Sprite();
		
		s.graphics.beginFill(0xFF0000, 0.5);
		s.graphics.drawCircle(r,r,r);
		
		s.graphics.beginFill(0xFF0000, 1);
		s.graphics.drawCircle(r, r, r*0.85);
		
		s.alpha = 0.8;
		
		hole = mt.deepnight.Lib.flatten(s, "hole#"+uid);
		sprite.addChild(hole);
		hole.blendMode = flash.display.BlendMode.ERASE;
		sprite.blendMode = flash.display.BlendMode.LAYER;
		sprite.cacheAsBitmap = true;
	}
	
	function setAlpha(v) {
		man.tw.terminate(sprite,"alpha");
		alpha = v;
		sprite.alpha = v;
		return v;
	}
	
	function setVisible(v:Bool) {
		fl_visible = v;
		applyVisibility( man.ready ? 250 : 0 );
		return v;
	}
	
	public function pull(dx:Float,dy:Float, ?duration=0) {
		man.tw.terminate(this, "tmp_xr");
		if( duration<=0 )
			tmp_xr = dx;
		else
			man.tw.create(this, "tmp_xr", dx, TBurnIn, duration);
		
		man.tw.terminate(this, "tmp_yr");
		if( duration<=0 )
			tmp_yr = dy;
		else
			man.tw.create(this, "tmp_yr", dy, TBurnIn, duration);
	}
	
	function applyVisibility(d:Int) { // NOTE: penser à updater dans Student car pas d'héritage !
		if( fl_static )
			sprite.visible = fl_visible;
		else
			if( fl_visible ) {
				// apparition
				sprite.visible = fl_visible;
				man.tw.create(sprite,"alpha", alpha, TEaseOut, d);
			}
			else {
				// disparition
				man.tw.create(sprite,"alpha", 0, TLinear, d).onEnd = function() {
					sprite.visible = fl_visible;
				}
			}
			
		if( shadow!=null )
			shadow.visible = fl_visible;
			
		for(ls in linkedSprites)
			ls.spr.visible = fl_visible;
	}
	
	public function changeDepth(dp:Int) {
		sprite.parent.removeChild(sprite);
		man.sdm.add(sprite, dp);
	}
	
	function register() {
		man.sdm.add(sprite, Const.DP_ITEMS);
		man.isos.push(this);
	}
	
	public function destroy() {
		sprite.parent.removeChild(sprite);
		if( hole!=null ) {
			hole.bitmapData.dispose();
			hole = null;
		}
		removeButton();
		while( linkedSprites.length>0 )
			removeLinkedSprite( linkedSprites[0].k );
		man.isos.remove(this);
	}
	
	public function shake(pow,duration) {
		shakeX = pow;
		man.tw.terminate(this, "shakeX");
		man.tw.create(this,"shakeX", 0, TEaseOut, duration);
	}
	
	public function setPos(?pt:Point, ?x:Int,?y:Int) {
		if( pt==null )
			pt = {x:x,y:y};
		cx = pt.x;
		cy = pt.y;
		var pt = getInCasePos();
		xr = pt.xr;
		yr = pt.yr;
	}
	
	public inline function calcDepth() {
		return depth = zpriority*10000 + uid + 1000*(5*layer + Std.int(100 + (cx-0.5+xr)*7 + (cy-0.5+yr)*7));
	}
	
	public static inline function globalToIso(buffer:mt.deepnight.Buffer, sx:Float,sy:Float) : Point {
		var pt = Manager.ME.globalToBuffer(sx,sy);
		var a = (pt.x-CENTER_X)/14/2 + (pt.y-CENTER_Y-16)/7/2;
		var b = -(pt.x-CENTER_X)/14/2 + (pt.y-CENTER_Y-16)/7/2;
		return {
			x	: Std.int(a),
			y	: Std.int(b),
		}
	}
	
	public static inline function isoToScreenStatic(cx:Float,cy:Float) : Point {
		return {
			x	: Std.int(CENTER_X + cx*14 - cy*14),
			y	: Std.int(CENTER_Y + cx*7 + cy*7),
		}
	}
	
	public inline function isoToScreen() {
		return isoToScreenStatic(cx - 0.5+xr + tmp_xr, cy - 0.5+yr + tmp_yr);
	}
	
	public function cancelPath() {
		path = new Array();
		move = null;
	}
	
	public function getPath(from:Point, to:Point) {
		return man.getStudentPath(from,to);
	}
	
	public function getPathLength() {
		return path.length;
	}
	
	public function leaveRoomCinematic(goDown:Bool, ?spd=1.0) {
		man.cm.create({
			goto( Const.EXIT, spd );
			end;
			man.openDoor();
			setVisible(false);
			400;
			setPos(Const.EXIT.x-2, Const.EXIT.y);
			setVisible(true);
			200;
			man.closeDoor();
			gotoXY(cx, goDown ? Const.RHEI + 6 : -8, spd*1.1);
			end;
			man.cm.signal("left");
		});
	}
	
	public function enterRoomCinematic(fromDown:Bool, ?spd=1.0) {
		man.cm.create({
			setPos(Const.EXIT.x-2, fromDown ? Const.RHEI+6 : -8);
			gotoXY( cx, Const.EXIT.y, spd );
			end;
			man.openDoor();
			setVisible(false);
			400;
			gotoXY(Const.EXIT.x, Const.EXIT.y);
			setVisible(true);
			200;
			man.closeDoor();
			man.cm.signal("enter");
		});
	}
	
	public inline function gotoXY(x,y, ?s:Float) {
		goto({x:x, y:y}, s);
	}
	public function goto(pt:Point, ?speedMul=1.0) {
		if (fl_static)
			throw "Cannot move static object!";
			
		var tmp = getPath(getPoint(), pt);
		if( tmp==null )
			return;
			
		var p = tmp.copy();
		if( p==null )
			return;
			
		fl_visible = true;
		if( autoRun>0 && p.length>6 ) {
			tmpSpeedMul = autoRun;
		}
		else
			tmpSpeedMul = speedMul;
			
		if ( p.length==0 || man.cm.turbo ) {
			cancelPath();
			setPos(pt.x, pt.y);
			var pt = getInCasePos();
			xr = pt.xr;
			yr = pt.yr;
			onArrive();
		}
		else
			followPath(p);
	}
	
	public function jump(d) {
		if( !fl_visible || ch>0 || man.cm.turbo )
			return;
		dh = d;
		ch = 0.1;
	}
	
	function followPath(p:Array<Point>) {
		path = p;
		move = null;
	}
	
	public inline function getPoint() : Point {
		return { x:cx, y:cy };
	}
	public inline function getFloatPoint() : {x:Float, y:Float} {
		return { x:cx+xr, y:cy+yr };
	}
	public inline function getHead(): Point {
		return { x:Std.int(sprite.x), y:Std.int(sprite.y+headY) }
	}
	public inline function getFeet() : Point {
		return {x:Std.int(sprite.x), y:Std.int(sprite.y+24)}
	}
	public inline function getBodyCenter(): Point {
		var h = getHead();
		var f = getFeet();
		return { x : Std.int(h.x+(f.x-h.x)/2), y : Std.int(h.y+(f.y-h.y)/2) }
	}
	public inline function getStandPoint() {
		return standPoint==null ? getPoint() : {x:cx+standPoint.dx, y:cy+standPoint.dy};
	}
	public inline function getStandDir() {
		return
			if( standPoint==null ) -1
			else if( standPoint.dx<0 ) 1
			else if( standPoint.dx>0 ) 3
			else if( standPoint.dy<0 ) 2
			else if( standPoint.dy>0 ) 0
			else -1;
	}

	public function getInScrollCoords() {
		if( man.cm.turbo )
			updateSprite();
		return man.buffer.localToGlobal(sprite.x, sprite.y);
	}
	
	public function getGlobalCoords() {
		if( man.cm.turbo )
			updateSprite();
		var pt = man.buffer.localToGlobal(sprite.x, sprite.y);
		pt.x += Std.int(man.gscroller.x);
		pt.y += Std.int(man.gscroller.y);
		return pt;
	}
	
	public function addSideButton(content:flash.display.DisplayObject) {
		removeButton();
		var wrapper = new Sprite();
		man.gscroller.addChild(wrapper);
		
		var bgCol = 0xC8C8C8;
		
		var bt = new Sprite();
		wrapper.addChild(bt);
		bt.graphics.beginFill(bgCol, 1);
		//bt.graphics.drawCircle(0,0,10);
		bt.graphics.drawRoundRect(-10,-10,20,20, 5,5);
		bt.graphics.beginFill(bgCol, 1);
		//bt.graphics.moveTo(10,-4);
		//bt.graphics.lineTo(15,-1);
		//bt.graphics.lineTo(10,2);
		bt.x = -25;
		bt.y = 25;
		bt.buttonMode = bt.useHandCursor = true;
		bt.filters = [
			new flash.filters.GlowFilter(0x0,1, 2,2, 4),
			new flash.filters.GlowFilter(0xffffff,1, 2,2, 4),
			new flash.filters.DropShadowFilter(8,90, 0xffffff,0.2, 2,2,1, 1,true)
		];
		
		bt.addChild(content);

		wrapper.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) {
			wrapper.filters = [
				new flash.filters.GlowFilter(0xFFEBAE,1, 2,2, 3),
				new flash.filters.GlowFilter(0xFFB36C,1, 16,16, 2, 2)
			];
		});
		wrapper.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) {
			wrapper.filters = [];
		});
		
		this.button = wrapper;
		updateButton();
		return wrapper;
	}
	
	public function removeButton() {
		if( button==null )
			return;
		var b = button;
		button = null;
		b.mouseChildren = b.mouseEnabled = false;
		man.tw.create(b, "alpha", 0, TEaseOut, 500).onEnd = function() {
			b.parent.removeChild(b);
		}
	}
	
	function updateButton() {
		if( button==null )
			return;
		var pt = getInScrollCoords();
		button.x = pt.x;
		button.y = pt.y + Math.abs( Math.sin(uid+man.time*3.14*0.05)*3 );
	}
	
	function getInCasePos() {
		return { xr:0.5, yr:0.5 };
	}
	
	function onArrive() {
	}
	
	public function toString() {
		return "Iso("+fl_static+")@"+cx+","+cy;
	}
	
	public inline function waitingAt(?pt:Point, ?x:Int, ?y:Int) {
		return move==null && inCase(pt,x,y);
	}
	
	public inline function inCase(?pt:Point, ?x:Int, ?y:Int) {
		return pt!=null && cx==pt.x && cy==pt.y || pt==null && cx==x && cy==y;
	}
	
	function distortSpeech(str:String) {
		return str;
	}
	
	public function event(str:String, ?col=0x219EE2, ?sendSignal=false) {
		for( spr in bubbles )
			spr.parent.removeChild(spr);
		bubbles = new Array();
		
		var col = mt.deepnight.Color.capBrightnessInt(col, 0.5);
		
		var spr = new Sprite();
		spr.mouseChildren = spr.mouseEnabled = false;
		
		var wrapper = new Sprite();
		man.gscroller.addChild(wrapper);
		wrapper.addChild(spr);

		var tf = man.createField(str, FBig);
		tf.x = 5;
		tf.width = 300;
		tf.textColor = 0xffffff;
		tf.filters = [ new flash.filters.DropShadowFilter(2,90, 0x0,0.5, 0,0) ];
		spr.addChild(tf);
		
		spr.graphics.beginFill(col, 1);
		var w = Std.int( Math.max(25, tf.textWidth+15) );
		var h = Std.int(tf.textHeight+5);
		spr.graphics.drawRect(0,0, w, h);
		var x = Std.int(w*0.5);
		spr.graphics.moveTo(x, h);
		spr.graphics.lineTo(x+8, h);
		spr.graphics.lineTo(x+4, h+4);
		spr.graphics.endFill();
		spr.filters = [
			new flash.filters.GlowFilter(0xffffff,1, 2,2,10, 1,true),
			new flash.filters.GlowFilter(0x0,0.8, 2,2,10),
		];
		
		spr.x = Std.int(-w*0.5);
		spr.y = headY-40-10;
		
		spr.alpha = 0;
		man.tw.create(spr, "alpha", 1, TEaseOut, 300);
		man.tw.create(spr, "y", spr.y+10, TEaseOut, 300).fl_pixel = true;
		man.delayer.add(function() {
			man.tw.create(spr, "alpha", 0, TEaseIn, 500).onEnd = function() {
				if( spr.parent!=null )
					spr.parent.removeChild(spr);
				bubbles.remove(wrapper);
				if( sendSignal )
					man.cm.signal("event");
			}
		}, 1200+str.length*50);
		
		bubbles.push(wrapper);
		var pt = man.buffer.localToGlobal(sprite.x, sprite.y);
		wrapper.filters = [ new flash.filters.GlowFilter(0x323C5A,0.8, 2,2, 2) ];
		wrapper.mouseChildren = wrapper.mouseEnabled = false;
		updateBubbles();
		return wrapper;
	}
	
	public function say(?str:String, ?bgColor:Null<Int>, ?persist=false) {
		for( spr in bubbles )
			spr.parent.removeChild(spr);
		bubbles = new Array();

		var textColor = mt.deepnight.Color.brightnessInt(speechColor, -0.8);
		if( bgColor==null ) {
			bgColor = speechColor;
		}
		else
			textColor = Color.autoContrast(bgColor, 0x0, 0xffffff);
	
		if( str==null ) {
			cd.unset("talking");
			return null;
		}
			
		str = distortSpeech(str);
			
		cd.set("talking", str.length*0.8);
		
		var spr = new Sprite();
		spr.mouseChildren = spr.mouseEnabled = false;
		
		var wrapper = new Sprite();
		man.gscroller.addChild(wrapper);
		wrapper.addChild(spr);

		var stf = new mt.deepnight.SuperText();
		spr.addChild(stf.wrapper);
		stf.setFont(textColor, "big", 16);
		stf.setSize(250,300);
		stf.wrapper.x = 1;
		stf.wrapper.y = 2;
		stf.wrapper.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.4, 2,0) ];
		stf.setText(str);
		stf.autoResize();
		
		spr.graphics.beginFill(bgColor, 1);
		var w = Math.max(25, stf.textWidth+7);
		var h = stf.textHeight+7;
		spr.graphics.drawRoundRect(0,0, w, h, 3,3);
		var x = Std.int(w*0.5);
		spr.graphics.moveTo(x, h);
		spr.graphics.lineTo(x+8, h);
		spr.graphics.lineTo(x+4, h+4);
		spr.graphics.endFill();
		
		spr.x = Std.int(-w*0.5);
		spr.y = headY - stf.textHeight - 30;
		
		spr.alpha = 0;
		man.tw.create(spr, "alpha", 1, TEaseOut, 300);
		man.tw.create(spr, "y", spr.y+3, TEaseOut, 300).fl_pixel = true;
		
		if( !persist )
			man.delayer.add(function() {
				man.tw.create(spr, "alpha", 0, TEaseIn, 500).onEnd = function() {
					if( spr.parent!=null )
						spr.parent.removeChild(spr);
					bubbles.remove(wrapper);
				}
			}, 800+str.length*50);
		
		bubbles.push(wrapper);
		var pt = man.buffer.localToGlobal(sprite.x, sprite.y);
		wrapper.filters = [ new flash.filters.GlowFilter(0x323C5A,0.8, 2,2, 2) ];
		wrapper.mouseChildren = wrapper.mouseEnabled = false;
		updateBubbles();
		return wrapper;
	}
	
	
	public function ambiant(?str:String, ?left=true) {
		for( spr in bubbles )
			spr.parent.removeChild(spr);
		bubbles = new Array();

		if( str==null ) {
			cd.unset("talking");
			return null;
		}
			
		str = distortSpeech(str);
		
		cd.set("talking", str.length*0.8);
		
		var spr = new Sprite();
		spr.mouseChildren = spr.mouseEnabled = false;
		
		var wrapper = new Sprite();
		man.gscroller.addChild(wrapper);
		wrapper.addChild(spr);
		
		var stf = new mt.deepnight.SuperText();
		spr.addChild(stf.wrapper);
		stf.setFont(0x474E5C, "big", 16);
		stf.setSize(man.at(Class) ? 130 : 180,200);
		stf.wrapper.x = 5;
		stf.wrapper.y = 4;
		stf.wrapper.filters = [ new flash.filters.DropShadowFilter(1,90, 0x474E5C, 0.4, 0,0) ];
		stf.setText(str);
		
		var offset = stf.textHeight>60 ? 30 : 0;
		
		spr.graphics.beginFill(0xC8CCD5, 1);
		var w = Math.max(25, stf.textWidth+15);
		var h = stf.textHeight+14;
		spr.graphics.drawRoundRect(0,0, w, h, 3,3);
		var ay = Std.int(h-10 - offset);
		if( left ) {
			spr.graphics.moveTo(w, ay-4);
			spr.graphics.lineTo(w+4, ay);
			spr.graphics.lineTo(w, ay+4);
			spr.graphics.endFill();
		}
		else {
			spr.graphics.moveTo(0, ay-4);
			spr.graphics.lineTo(-4, ay);
			spr.graphics.lineTo(0, ay+4);
			spr.graphics.endFill();
		}
		//spr.filters = [ new flash.filters.DropShadowFilter(12,90, 0xffffff,0.2, 0,0,1, 1,true) ];
		
		//spr.x = Std.int(-w*0.5);
		//spr.y = headY-spr.height+10;
		spr.x = left ? Std.int( -w-20 ) : Std.int( 35 );
		spr.y = Std.int( headY- ay );
		
		spr.alpha = 0;
		man.tw.create(spr, "alpha", 1, TEaseOut, 300);
		man.tw.create(spr, "y", spr.y+3, TEaseOut, 300).fl_pixel = true;
		
		man.delayer.add(function() {
			man.tw.create(spr, "alpha", 0, TEaseIn, 500).onEnd = function() {
				if( spr.parent!=null )
					spr.parent.removeChild(spr);
				bubbles.remove(wrapper);
			}
		}, 900 + str.length*40);
		
		bubbles.push(wrapper);
		//var pt = man.buffer.localToGlobal(sprite.x, sprite.y);
		wrapper.filters = [ new flash.filters.GlowFilter(0x323C5A,0.8, 2,2, 2) ];
		wrapper.mouseChildren = wrapper.mouseEnabled = false;
		updateBubbles();
		return wrapper;
	}
	
	
	public function updateDir(dx,dy) {
		if (dx<0 || dy>0)
			sprite.scaleX = 1;
		else if (dx>0 || dy<0)
			sprite.scaleX = -1;
	}
	
	function updateBubbles() {
		var pt = man.buffer.localToGlobal(sprite.x, sprite.y);
		for(s in bubbles) {
			s.x = Std.int(pt.x);
			s.y = Std.int(pt.y);
		}
	}
	
	inline function getScreenSpeed() {
		return move==null ? 0 : getSpeed();
	}
	
	inline function getSpeed() {
		var spd = speed * tmpSpeedMul * accelMul;
		if( spd<minSpeed )
			spd = minSpeed;
		return spd;
	}
	
	inline function updateSprite() {
		var pt = isoToScreen();
		sprite.x = Std.int( pt.x + shakeX*(Std.random(2)+1)*(Std.random(2)*2-1) );
		sprite.y = Std.int( pt.y + yOffset - ch - getHeightMap(cx,cy) );
	}
	
	public function onMouseOver() {
		man.tip.show( man.formatTip(clickZone.desc) );
		overed = true;
		if( glowOver )
			sprite.filters = [
				new flash.filters.GlowFilter(0xffffff,1, 2,2, 10),
				new flash.filters.GlowFilter(Const.ACTIVE_COLOR,1, 2,2, 10),
			];
	}
	
	public function onMouseOut() {
		overed = false;
		if( glowClick ) {
			var r = Math.abs( Math.sin(man.time*0.2) );
			sprite.filters = [
				new flash.filters.GlowFilter(Const.OVER_COLOR, 0.2+0.8*r, 2,2,10),
			];
		}
		else
			sprite.filters = [];
	}
	
	public function update() {
		cd.update();
		if (!fl_static) {
			var old = { x:sprite.x, y:sprite.y };
			
			// début de chemin
			if (move==null && path.length>0)
				move = path.shift();
				
			if( move!=null && accelMul<1 ) {
				accelMul+=accel;
				if( accelMul>1 )
					accelMul = 1;
			}
			if( move==null )
				accelMul = 0;
				
			// déplacement vers la case cible
			var spd = getSpeed();
			if (move != null) {
				if (cx==move.x && cy==move.y && path.length>0)
					move = path.shift();
				if (cx>move.x)		xr-=spd;
				else if (cx<move.x)	xr+=spd;
				else if (cy>move.y)	yr-=spd;
				else if (cy<move.y)	yr+=spd;
				updateDir(move.x-cx, move.y-cy);

				if( spd>=0.18 ) {
					var pt = getFeet();
					var n = spd>=0.26 ? 4 : 1+Std.random(3);
					man.fx.dustGround(pt.x, pt.y, n);
				}
			}
			
			// recal dans la case
			var casePos = getInCasePos();
			var recalSpd = spd*0.6;
			if (move==null || cx==move.x) {
				if (xr<casePos.xr)	xr+=recalSpd;
				if (xr>casePos.xr)	xr-=recalSpd;
				if ( Math.abs(casePos.xr-xr)<=recalSpd )
					xr = casePos.xr;
			}
			if (move==null || cy==move.y) {
				if (yr<casePos.yr)	yr+=recalSpd;
				if (yr>casePos.yr)	yr-=recalSpd;
				if ( Math.abs(casePos.yr-yr)<=recalSpd )
					yr = casePos.yr;
			}
			
			// case atteinte !
			if (move!=null && cx==move.x && cy==move.y && xr==casePos.xr && yr==casePos.yr) {
				move = null;
				onArrive();
			}
			
			// sauts
			if( ch>0 )
				dh-=0.7; // gravité
			ch+=dh;
			if( ch<=0 )
				ch = dh = 0;
			
			// mouvement effectif
			while (xr>=1) {	xr--;	cx++; }
			while (xr<0) {	xr++;	cx--; }
			while (yr>=1) {	yr--;	cy++; }
			while (yr<0) {	yr++;	cy--; }
		}
		
		// placement
		updateSprite();
		
		// masque "trou"
		if( hole!=null && man.time%2==0 )
			if( Const.LOWQ || man.teacher.cx>=Const.RWID )
				hole.visible = false;
			else {
				hole.visible = true;
				var pt = man.bmouse;
				hole.x = man.teacher.sprite.x-sprite.x - hole.width*0.5;
				hole.y = man.teacher.sprite.y-sprite.y - hole.height*0.5;
			}
		
		// rollover
		if( hasClick() ) {
			man.allOveredIsos.remove(this);
			if( !allowClick || man.lockActions )
				sprite.filters = [];
			else {
				if( over(man.bmouse) )
					man.allOveredIsos.push(this);
			}
		}
		
		if( hasClick() && !overed )
			if( glowClick && allowClick && !man.lockActions ) {
				var r = Math.abs( Math.sin(man.time*0.2) );
				sprite.filters = [
					new flash.filters.GlowFilter(Const.OVER_COLOR, 0.2+0.8*r, 2,2,10),
				];
			}
			else
				sprite.filters = [];
			
		//if( hasClick() )
			//if( !allowClick || man.lockActions )
				//sprite.filters = [];
			//else {
				//man.overedIsos.remove(this);
				//if( over(man.bmouse) ) {
					//man.overedIsos.push(this);
					//if( man.lastOverIso!=this )
						//man.tip.show( man.formatTip(clickZone.desc) );
					//man.lastOverIso = this;
					//if( glowOver )
						//sprite.filters = [
							//new flash.filters.GlowFilter(0xffffff,1, 2,2, 10),
							//new flash.filters.GlowFilter(Const.ACTIVE_COLOR,1, 2,2, 10),
						//];
				//}
				//else {
					//if( man.lastOverIso==this ) {
						//man.lastOverIso = null;
						//man.tip.hide();
					//}
					//if( glowClick ) {
						//var r = Math.abs( Math.sin(man.time*0.2) );
						//sprite.filters = [
							//new flash.filters.GlowFilter(Const.OVER_COLOR, 0.2+0.8*r, 2,2,10),
						//];
					//}
					//else
						//sprite.filters = [];
				//}
			//}
				
		updateButton();
		updateLinkedSprites();
		updateBubbles();
	}
}