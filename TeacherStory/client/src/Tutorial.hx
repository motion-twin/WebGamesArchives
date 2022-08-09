#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#else
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.deepnight.Tweenie;
import mt.deepnight.Lib;
#end

class Tutorial {
	#if !macro
	public static var USE_VAR_NAMES_AS_ID = true;
	static var WID = Std.int(flash.Lib.current.stage.stageWidth);
	static var HEI = Std.int(flash.Lib.current.stage.stageHeight);
	
	public var container: Sprite; // à ajouter à la display list !
	public var useAnims	: Bool;
	
	var tw				: Tweenie;
	var current			: Null<Bitmap>;
	var mask			: Null<Bitmap>;
	
	var recentKeys		: Array<String>;
	var checks			: Hash<Bool>;
	var queue			: List<Void->Void>;
	var paused			: Bool;
	
	public function new() {
		tw = new Tweenie();
		checks = new Hash();
		queue = new List();
		useAnims = true;
		paused = false;
		recentKeys = new Array();

		container = new Sprite();
		container.mouseChildren = container.mouseEnabled = container.buttonMode = container.useHandCursor = true;
		container.addEventListener(flash.events.MouseEvent.CLICK, onClick);
	}
	#end
	
	
	@:macro public function hasShown(ethis:Expr, text:Expr) : Expr {
		var id = makeId(text);
		return macro $ethis.__hasCheck($id);
	}
	
	#if macro
	static function makeId(etext:Expr) {
		var id : Expr = etext;
		switch( etext.expr ) {
			case ECall(fname, p) : // fonction
				switch(fname.expr) {
					case EField(f, name) :
						id = {expr:EConst(CString(name)), pos:Context.currentPos()}
					case EConst(c) :
						switch(c) {
							case CIdent(name) : id = {expr:EConst(CString(name)), pos:Context.currentPos()};
							default :
						}
					default :
				}
			case EField(f, name) : // variable "s.truc"
				id = {expr:EConst(CString(name)), pos:Context.currentPos()}
			case EConst(c) : // variable "s"
				switch(c) {
					case CIdent(name) : id = {expr:EConst(CString(name)), pos:Context.currentPos()};
					default :
				}
			default :
		}
		return id;
	}
	#end
	
	@:macro public function showOnce(ethis:Expr, text:Expr, ?x:Expr, ?y:Expr, ?w:Expr, ?h:Expr) : Expr {
		var id = makeId(text);
		return macro {
			if( Tutorial.USE_VAR_NAMES_AS_ID )
				$ethis.__run($id, $text, $x,$y,$w,$h);
			else
				$ethis.__run($text, $text, $x,$y,$w,$h);
		}
	}
	
	
	#if !macro
	
	public function showAlways(text:String, ?x:Float, ?y:Float, ?w:Float, ?h:Float) {
		if( paused || isVisible() )
			queue.add( callback(showAlways, text, x,y,w,h) );
		else
			message(text, x, y, w, h);
	}
	
	public function __run(id:String, text:String, ?x:Float, ?y:Float, ?w:Float, ?h:Float) {
		if( !checks.exists(id) ) {
			if( paused || isVisible() )
				queue.add( callback(__run, id, text, x,y,w,h) );
			else {
				recentKeys.push(id);
				checks.set(id, true);
				message(text, x, y, w, h);
			}
		}
	}
	
	public inline function __hasCheck(k:String) {
		return checks.exists(k);
	}
	
	public function startQueuing() {
		paused = true;
	}
	public function flushQueue() {
		paused = false;
		next();
	}
	public inline function queueLength() {
		return queue.length;
	}
	
	public function saveState() {
		var a = [];
		for(k in checks.keys())
			a.push(k);
		return a;
	}
	
	public function loadState(a:Array<String>) {
		checks = new Hash();
		if( a!=null )
			for(k in a)
				checks.set(k, true);
	}
	
	
	function next() {
		if( queue.length>0 ) {
			if( current!=null ) {
				current.bitmapData.dispose();
				current.parent.removeChild(current);
				current = null;
			}
			queue.pop()();
			if( current==null )
				hide();
		}
		else {
			hide();
		}
	}
	
	function onClick(e:flash.events.MouseEvent) {
		e.preventDefault();
		e.stopImmediatePropagation();
		e.stopPropagation();
		next();
	}
	
	public inline function isVisible() {
		return current!=null;
	}
	
	public function hide() {
		if( current!=null ) {
			tw.terminate(current);
			if( useAnims ) {
				var bmp = current;
				tw.create(bmp, "alpha", 0, TEaseIn, 300).onEnd = function() {
					bmp.parent.removeChild(bmp);
					bmp.bitmapData.dispose();
				}
			}
			else {
				current.parent.removeChild(current);
				current.bitmapData.dispose();
			}
			current = null;
		}
		
		if( mask!=null ) {
			tw.terminate(mask);
			if( useAnims ) {
				var bmp = mask;
				tw.create(bmp, "alpha", 0, TEaseIn, 300).onEnd = function() {
					bmp.parent.removeChild(bmp);
					bmp.bitmapData.dispose();
				}
			}
			else {
				mask.parent.removeChild(mask);
				mask.bitmapData.dispose();
			}
			mask = null;
		}
	}
	
	public inline function clearRecentKeys() {
		recentKeys = new Array();
	}
	public inline function getRecentKeys() {
		return recentKeys.copy();
	}
	
	
	function message(msg:String, ?x:Float,?y:Float,?w:Float,?h:Float) {
		var d = 900;
		if( container.parent==null )
			throw "Please add Tutorial.container to display list";
			
		var maskAlpha = mask!=null ? mask.alpha : 0;
		if( mask!=null ) {
			tw.terminate(mask);
			mask.parent.removeChild(mask);
			mask.bitmapData.dispose();
		}
		
		// Mask
		var s = new Sprite();
		s.graphics.beginFill(0xFFFFFF, 0.8);
		s.graphics.drawRect(0,0,WID,HEI);
		if( x!=null && y!=null) {
			if( w==null )
				w = 45;
			s.graphics.lineStyle(2, 0xFFFFFF, 0.7);
			if( h==null )
				s.graphics.drawCircle(x,y,w);
			else
				s.graphics.drawRoundRect(x,y,w,h, 6);
		}
		mask = Lib.flatten(s);
		container.addChild(mask);
		mask.alpha = maskAlpha;
		tw.create(mask, "alpha", 1, 300);
		
		// Boîte texte
		var wrapper = new Sprite();
		
		var bg = new Sprite();
		wrapper.addChild(bg);
		bg.graphics.beginFill(0x0, 0.85);
		bg.filters = [
			new flash.filters.DropShadowFilter(4,90, 0x0,0.5, 8,8,1),
		];
		
		var stf = new mt.deepnight.SuperText();
		wrapper.addChild(stf.wrapper);
		stf.setFont(0xADB9CB, "big", 16);
		stf.setBoldTag("<font color='0xFFFFFF'>","</font>");
		stf.wrapper.x = 5;
		stf.wrapper.y = 5;
		stf.setSize(350,300);
		stf.setText(msg);
		stf.autoResize();
		
		bg.graphics.drawRect(0,0, stf.textWidth+15, stf.textHeight+15);
		
		current = Lib.flatten(wrapper, 16);
		container.addChild(current);
		
		if( x==null ) {
			// global
			current.x = Std.int( WID*0.5 - current.width*0.5 );
			current.y = -current.height;
			tw.create(current, "y", 0, d);
		}
		else {
			if( h==null ) {
				// cercle
				current.x = Std.int(x-current.width*0.5);
				current.x = Math.max(0, Math.min(WID-current.width, current.x));
				current.y = Std.int(y-current.height-w-5);
				if( current.y<=0 )
					current.y = y + w + 5;
			}
			else {
				// rectangle
				current.x = Std.int(x+w*0.5-current.width*0.5);
				current.x = Math.max(0, Math.min(WID-current.width, current.x));
				current.y = Std.int(y-current.height-5);
				if( current.y<=0 )
					current.y = y + h + 5;
			}
			current.alpha = 0;
			tw.create(current, "alpha", 1, d*0.5);
			current.y+=10;
			tw.create(current, "y", current.y-10, d*0.25).fl_pixel = true;
		}
	}
	
	public function update() {
		tw.update();
	}
	#end
}
