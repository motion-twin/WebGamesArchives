import Level.Block;
import Common;

class Interface {

	public static inline var CBITS = 4;
	
	static inline var PAGE = 12;
	static inline var BWIDTH = 40;
	static inline var BHEIGHT = 45;
	
	var game : Kube;
	var content : Array<{
		mc : flash.display.MovieClip,
		bmp : flash.display.BitmapData,
		count : flash.text.TextField,
		block : Block
	}>;
	var kubePage : Int;
	var msgMC : {> flash.display.MovieClip, tf : flash.text.TextField };
	var errorMC : {> flash.display.MovieClip, tf : flash.text.TextField };
	var current : flash.display.MovieClip;
	var inventory : Array<Null<Int>>;
	var defCountColor : Int;
	var js : haxe.remoting.Connection;
	var glow : flash.filters.BitmapFilter;
	var lockMC : flash.display.Sprite;
	var kubeNames : Array<String>;
	var tipMC : {> flash.display.MovieClip, tf : flash.text.TextField };
	var tipDelay : Float;
	
	public function new(k) {
		game = k;
		content = new Array();
		glow = new flash.filters.GlowFilter(0,0.5,2,2,5);
		js = haxe.remoting.ExternalConnection.jsConnect("cnx").api;
		var texts = game.texts.kube_names;
		tipMC = cast attach("tip");
		tipMC.mouseEnabled = tipMC.mouseChildren = false;
		kubeNames = (texts == null) ? [] : texts.split("\n");
		for( i in 0...kubeNames.length )
			kubeNames[i] = StringTools.trim(kubeNames[i]);
	}

	public function lockButtons(flag) {
		if( flag ) {
			if( lockMC != null ) return;
			lockMC = new flash.display.Sprite();
			lockMC.graphics.beginFill(0,0);
			lockMC.graphics.drawRect(0,0,game.root.stage.stageWidth,game.root.stage.stageHeight);
			game.root.addChild(lockMC);
		} else {
			if( lockMC == null ) return;
			game.root.removeChild(lockMC);
			lockMC = null;
		}
	}

	public function defaultAction() {
		select(null);
		onBlockSelect(null);
	}

	inline function attach(name) {
		return flash.Lib.attach(untyped __unprotect__(name));
	}

	public function clean() {
		for( c in content ) {
			if( c.bmp != null ) c.bmp.dispose();
			game.root.removeChild(c.mc);
			if( current == c.mc ) current = null;
		}
		content = new Array();
	}

	public function init(c) {
		inventory = c;
		for( i in 0...c.length ) {
			var count = c[i];
			if( count == null ) continue;
			addInventory(game.level.blocks[i],count);
		}
		redrawInventory();
	}

	public function inventoryCount( distinct ) {
		var n = 0;
		for( i in 0...inventory.length )
			if( inventory[i] != null )
				n += distinct ? 1 : inventory[i];
		return n;
	}

	function addInventory( block : Block, count : Int ) {
		var me = this;
		var h = Level.TEX_SIZE;
		var tmp = new flash.display.Shape();

		var point = function(x:Float,y:Float,u:Float,v:Float,w:Float) return [x,y,u,v,w];
		var h = Math.sqrt(1 + 0.5 * 0.5);
		var a = point(-1,0,0,0,-0.139);
		var b = point(1,0,1,1,-0.139);
		var b2 = point(1,0,0,0,-0.139);
		var c = point(0,0.5,1,0,-0.170);
		var d = point(0,-0.5,0,1,-0.119);
		var e = point(-1,h,0,1,-0.124);
		var f = point(0,h+0.5,1,1,-0.148);
		var g = point(1,h,0,1,-0.124);

		var coords = new Array();
		var uvs = new Array();
		var add = function(p) { coords.push(p[0]); coords.push(p[1]); uvs.push(p[2]); uvs.push(p[3]); uvs.push(p[4]); };
		var shade = function(s) return ( s >= 1.0 ) ? null : new flash.geom.ColorTransform(s,s,s);

		var smooth = switch( block.k ) {
			case BInvisible, BTeleport: true;
			default: false;
		}

		var bmp = new flash.display.BitmapData(BWIDTH,BHEIGHT,true,0);
		var mat = new flash.geom.Matrix();
		mat.translate(1.025,0.525);
		mat.scale(20,20);

		var E = 0.5;

		var mat2 = mat.clone();
		tmp.graphics.beginFill(0x4C536F);
		add(a); add(b); add(f); add(a); add(f); add(e); add(a); add(d); add(b); add(b); add(f); add(g);
		tmp.graphics.drawTriangles(flash.Vector.ofArray(coords));
		mat2.scale(0.95,0.95);
		mat2.tx += E * 2;
		mat2.ty += E * 2;
		bmp.draw(tmp,mat2);

		coords = new Array();
		uvs = new Array();
		tmp.graphics.clear();
		tmp.graphics.beginBitmapFill(block.tu.bmp,null,false,smooth);
		add(a); add(b); add(c); add(a); add(d); add(b);
		tmp.graphics.drawTriangles(flash.Vector.ofArray(coords),null,flash.Vector.ofArray(uvs));
		mat.ty += E;
		bmp.draw(tmp,mat,shade(block.shadeUp));
		mat.ty -= E;


		coords = new Array();
		uvs = new Array();
		tmp.graphics.clear();
		tmp.graphics.beginBitmapFill(block.tlr.bmp,null,false,smooth);
		add(a); add(c); add(f); add(a); add(f); add(e);
		tmp.graphics.drawTriangles(flash.Vector.ofArray(coords),null,flash.Vector.ofArray(uvs));
		mat.tx += E;
		bmp.draw(tmp,mat,shade(block.shadeX));
		mat.tx -= E;

		coords = new Array();
		uvs = new Array();
		tmp.graphics.clear();
		tmp.graphics.beginBitmapFill(block.tlr.bmp,null,false,smooth);
		add(c); add(b2); add(g); add(c); add(g); add(f);
		tmp.graphics.drawTriangles(flash.Vector.ofArray(coords),null,flash.Vector.ofArray(uvs));
		mat.tx -= E;
		bmp.draw(tmp,mat,shade(block.shadeY));
		mat.tx += E;

		var s = new flash.display.MovieClip();
		s.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(e:flash.events.MouseEvent) { e.stopPropagation();  me.select(s); me.onBlockSelect(block); } );
		s.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(e:flash.events.MouseEvent) e.stopPropagation());
		s.addEventListener(flash.events.MouseEvent.ROLL_OVER,function(_) me.showTip(me.kubeNames[Type.enumIndex(block.k) + 1]));
		s.addEventListener(flash.events.MouseEvent.ROLL_OUT,function(_) me.showTip(null));
		s.buttonMode = true;
		game.root.addChild(s);
		
		var cc : Dynamic = attach("count");
		s.addChild(new flash.display.Bitmap(bmp));
		s.addChild(cc);
		s.filters = [glow];
		var tf : flash.text.TextField = cc.tf;
		tf.x += 4;
		tf.y += 18;
		defCountColor = tf.textColor;
		tf.text = Std.string(count);
		tf.mouseEnabled = false;
		content.push({ mc : s, bmp : bmp, block : block, count : tf });
		updateInventory(block,0);
	}

	function showTip( t : String ) {
		if( t == null ) {
			if( tipMC.parent != null ) tipMC.parent.removeChild(tipMC);
			return;
		}
		tipMC.tf.text = t;
		tipMC.x = game.root.mouseX;
		tipMC.y = game.root.mouseY;
		tipMC.visible = false;
		tipDelay = 1.0;
		game.root.addChild(tipMC);
	}

	public function updateInventory( b : Block, count : Int ) {
		var max = (Kube.DATA == null) ? 999 : Kube.DATA._imax;
		var index = Type.enumIndex(b.k) + 1;
		var k = inventory[index];
		if( k == null ) {
			inventory[index] = k = 0;
			addInventory(b,0);
			redrawInventory();
		}
		if( count < 0 && k <= 0 )
			return false;
		if( count > 0 && k >= max )
			return false;
		k += count;
		inventory[index] = k;
		for( c in content )
			if( c.block == b ) {
				c.count.text = Std.string(k);
				c.count.textColor = (k == 0) ? 0x808080 : ((k >= max) ? 0xFF0000 : defCountColor);
				break;
			}
		return true;
	}

	public function warning( text  ) {
		if( text == null ) return;
		setInfos('<div class="warning">'+text+'</div>');
	}

	public function notice( text  ) {
		if( text == null ) return;
		setInfos('<div class="notice">'+text+'</div>');
	}

	public function setTuto( text : String ) {
		js._setTuto.call([text]);
	}

	function select( cur : flash.display.MovieClip ) {
		if( current != null )
			current.filters = [glow];
		current = cur;
		if( cur != null )
			cur.filters = [glow,new flash.filters.GlowFilter(0xFFFFFF,1,4,4,5)];
	}

	function setInfos( html : String ) {
		try {
			js._setInfos.call([html]);
		} catch( e : Dynamic ) {
		}
		if( game.drag != null && game.drag.active ) {
			var g = game;
			flash.ui.Mouse.hide();
			haxe.Timer.delay(function() {
				if( g.drag != null && g.drag.active ) flash.ui.Mouse.hide();
			},100);
		}
	}

	public function updateInfos() {
		if( tipMC.parent != null ) {
			if( tipDelay > 0 ) {
				tipDelay -= mt.Timer.deltaT;
				if( tipDelay <= 0 ) tipMC.visible = true;
			}
			tipMC.x = game.root.mouseX;
			tipMC.y = game.root.mouseY;
		}
	}

	public function redrawInventory() {
		var py = game.root.stage.stageHeight - (BHEIGHT + 10);
		for( i in 0...content.length ) {
			var s = content[i].mc;
			var i = i - kubePage * PAGE;
			if( i < 0 || i >= PAGE ) {
				s.visible = false;
				continue;
			}
			s.visible = true;
			s.x = 10 + i * (BWIDTH + 4);
			s.y = py;
		}
	}

	public function message( ?msg : String ) {
		if( msg == null ) {
			if( msgMC != null )
				game.root.removeChild(msgMC);
			msgMC = null;
			return;
		}
		if( msgMC == null ) {
			msgMC = cast attach("message");
			msgMC.x = game.root.stage.stageWidth;
			msgMC.y = game.root.stage.stageHeight;
			game.root.addChild(msgMC);
		}
		msgMC.tf.text = msg;
	}

	public function logError( e : Dynamic ) {
		var str;
		try str = Std.string(e) catch( e : Dynamic ) str = "???";
		game.lock = true;
		if( errorMC == null ) {
			errorMC = cast attach("error");
			errorMC.buttonMode = true;
			errorMC.tf.text = "";
			errorMC.tf.mouseEnabled = false;
			errorMC.addEventListener(flash.events.MouseEvent.CLICK,function(_) {
				flash.Lib.getURL(new flash.net.URLRequest("/"),"_self");
			});
			game.root.addChild(errorMC);
		}
		errorMC.tf.appendText("["+Date.now().toString()+"] "+str+"\n");
	}

	public dynamic function onBlockSelect( b : Block ) {
	}

}