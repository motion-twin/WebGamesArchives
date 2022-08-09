package ui.side;

import mt.MLib;
import com.Protocol;
import com.GameData;
import mt.data.GetText;
import mt.deepnight.slb.*;
import h2d.TextBatchElement;
import h2d.SpriteBatch;

class Button {
	var parent					: ui.SideMenu;
	var i						: h2d.Interactive;
	var subI					: Null<h2d.Interactive>;

	public var value			: Dynamic;
	var texts					: Map<String,TextBatchElement>;
	var elems					: Map<String,BatchElement>;
	var cancelClick				: Int;
	var hasRollOver				: Bool;
	var overBg					: BatchElement;
	public var vis(default,null): Bool;
	public var autoHide			: Bool;
	public var destroyed		: Bool;

	public function new(m:ui.SideMenu, ?cb:Void->Void, ?value:Dynamic) {
		parent = m;
		destroyed = false;
		this.value = value;
		texts = new Map();
		elems = new Map();
		vis = true;
		cancelClick = 0;
		autoHide = true;
		hasRollOver = true;

		parent.buttons.push(this);

		i = new h2d.Interactive(parent.wid, parent.bhei, parent.wrapper);

		i.onClick = function(e) {
			if( parent==null || parent.destroyed || parent.locked )
				return;

			if( cancelClick<=0 && !parent.destroyed && !parent.drag.active && cb!=null && parent.isOpen ) {
				Assets.SBANK.click1(1);
				cb();
			}
			cancelClick = 0;
		}
		i.onRelease = function(e:hxd.Event) {
			if( parent==null || parent.destroyed )
				return;

			parent.onRelease(e);
		}
		i.onPush = function(e) {
			if( parent==null || parent.destroyed )
				return;

			parent.onPush(e);
			parent.drag.value = value;
		};
		#if !mobile
		i.onWheel = parent.onWheel;
		#end

		// Rollover
		overBg = addElement("overBg", "roomOver");
		overBg.changePriority(-10);
		overBg.visible = false;
		overBg.alpha = 0;
		overBg.setPos(-10,-5);
		overBg.width = i.width+20;
		overBg.height = i.height+10;
		#if !mobile
		i.onOver = function(_) {
			if( hasRollOver )
				overBg.alpha = 1;
		}
		i.onOut = function(_) {
			overBg.alpha = 0;
		}
		#end
	}

	function toString() {
		return "Button."+value;
	}

	public function disableRollover() {
		#if !mobile
		hasRollOver = false;
		overBg.visible = false;
		overBg.alpha = 0;
		#end
	}
	public function enableRollover() {
		#if !mobile
		hasRollOver = true;
		overBg.visible = true;
		overBg.alpha = 0;
		#end
	}

	function isVisible() {
		var y = ( getY()*parent.wrapper.scaleY ) + parent.wrapper.y;
		return
			y >= -parent.bhei*parent.wrapper.scaleY &&
			y <= parent.h();
	}

	public inline function getX() return i.x;
	public inline function getY() return i.y;

	public function position() {
		var y = parent.bhei*(parent.buttons.length-1);
		i.y = y;
		if( subI!=null )
			subI.y += y;
		for(e in texts) e.y+=y;
		for(e in elems) e.y+=y;
	}

	public function destroy() {
		destroyed = true;

		i.dispose();
		i = null;

		for(e in texts) e.dispose();
		texts = null;

		for(e in elems) e.remove();
		elems = null;

		overBg = null;
		parent = null;
	}

	function setVisible(v:Bool) {
		i.visible = v;
		for(e in texts) e.visible = v;
		for(e in elems) e.visible = v;
		vis = v;
	}

	public inline function getText(id:String) return texts.get(id);
	public inline function getElement(id:String) return elems.get(id);

	public function addText(id:String, str:LocaleString, size:Int, ?x=0., ?y=0.) {
		var t = Assets.createBatchText(parent.tsb, Assets.fontTiny, size, str);
		t.x = x;
		t.y = y;
		texts.set(id, t);
		return t;
	}


	public function addTextHuge(id:String, str:LocaleString, size:Int, ?x=0., ?y=0.) {
		var t = Assets.createBatchText(parent.utsb, Assets.fontHuge, size, str);
		t.x = x;
		t.y = y;
		texts.set(id, t);
		return t;
	}

	public function addElement(id:String, k:String, ?f=0, ?xr=0., ?yr=0.) : HSpriteBE {
		//var e = Assets.tiles.addBatchElement(parent.sb, k, f, xr,yr);
		var e = Assets.tiles.hbe_get(parent.sb, k, f, xr,yr);
		elems.set(id, e);
		return e;
	}

	public function addSubButton(icon:String, x:Float, y:Float, isize:Int, cb:Void->Void) {
		var e = addElement("subIcon", icon,0, 0.5,0.5);
		e.setPos(x,y);
		e.constraintSize(isize);

		subI = new h2d.Interactive(isize*2, isize*2, parent.wrapper);
		subI.setPos(x-subI.width*0.5, y-subI.height*0.5);
		subI.onClick = function(_) cb();
	}

	public inline function registerElementFree(id:String, e:BatchElement) {
		elems.set(id, e);
	}

	public function update() {
		if( parent.drag.active )
			cancelClick = 3;
		else if( cancelClick>0 )
			cancelClick--;

		if( parent.isOpen && autoHide ) {
			if( vis && !isVisible() )
				setVisible(false);

			if( !vis && isVisible() )
				setVisible(true);
		}
	}
}