package mt.deepnight.hui;

import h2d.Sprite;
import h2d.Drawable;
import h2d.Bitmap;
import h2d.Text;
import h2d.Interactive;
import mt.deepnight.hui.Style;

private abstract UnifiedParent({spr:Sprite, comp:Component}) {

	inline function new(p:{spr:Sprite, comp:Component}) {
		this = p;
	}

	@:from static inline function fromSprite(o:Sprite) {
		return new UnifiedParent({ spr:o, comp:null });
	}

	@:from static inline function fromComponent(c:Component) {
		return new UnifiedParent({ spr:c.wrapper, comp:c });
	}

	public inline function getComponent() : Component {
		return this.comp;
	}

	public inline function getSprite() : Sprite {
		return this.spr;
	}

	public function addChild(o:UnifiedParent) {
		if( this.comp!=null && o.getComponent()!=null )
			this.comp.addChild( o.getComponent() );
		if( this.spr!=null && o.getSprite()!=null )
			this.spr.addChild( o.getSprite() );
	}

	public function getType() {
		if( this.comp!=null )
			return "Component";

		if( this.spr!=null )
			return "Sprite";

		return "???";
	}

	public function toString() {
		if( this.comp!=null )
			return Std.string(this.comp);

		if( this.spr!=null )
			return Std.string(this.spr);

		return "???";
	}

}



class Component {
	static var UID = 0;
	static var ALL : Array<Component> = [];
	static var TO_RENDER : Array<Component> = [];
	public static var BASE_STYLE : Style = {
		var s = new Style();
		s.bg = Col(0x171627,1);
		s.bgOutline = Lighter;
		s.textColor = 0xFFFFFF;

		s.padding = 5;

		s.contentHAlign = Center;
		s.contentVAlign = Center;

		s.fontName = "Arial";
		s.fontSize = 12;
		s.fontAntiAliasing = true;
		s.fontFiltering = true;
		s.lineSpacing = 0;

		s.clickTrap = None;
		s.checkType = CheckBox;

		s.paddingExpandsBox = true;

		s;
	};

	var uid									: Int;

	public var interactive					: Interactive;
	public var wrapper						: Sprite;
	public var bg							: Bitmap;
	public var content						: Sprite;

	public var parent(default,null)			: Null<Component>;
	public var destroyed(default,null)		: Bool;
	var children							: Array<Component>;
	var states								: Map<String, Bool>;
	var renderAsked							: Bool;
	public var style						: Style;
	var visible								: Bool;

	var textFields							: Array<Text>;

	//public var color(default,set)			: Int;
	//public var hasBackground(default,set)	: Bool;
	//public var bgAlpha(default,set)			: Float;

	// Position
	public var x(default,set)				: Float;
	public var y(default,set)				: Float;

	// Dimensions
	public var minWidth(default,set)		: Float;
	public var minHeight(default,set)		: Float;
	public var maxWidth(default,set)		: Float;
	public var maxHeight(default,set)		: Float;
	var forcedWidth							: Null<Float>;
	var forcedHeight						: Null<Float>;

	// Variable watching mechanism
	var lastWatchedValue					: Dynamic;
	var watchedValue						: Null<Void->Dynamic>;

	// Callbacks
	public dynamic function onDestroy() {}

	private function new(p:UnifiedParent) {
		ALL.push(this);
		uid = UID++;
		children = [];
		textFields = [];
		destroyed = false;
		minWidth = 1;
		minHeight = 1;
		visible = true;
		x = y = 0;
		maxWidth = maxHeight = 9999;
		forcedWidth = forcedHeight = null;
		states = new Map();
		lastWatchedValue = "__watch__";

		style = new Style(BASE_STYLE, this);

		wrapper = new Sprite();
		wrapper.visible = false;

		bg = new Bitmap( h2d.Tile.fromColor(0x0) );
		wrapper.addChild(bg);

		content = new Sprite();
		wrapper.addChild(content);

		interactive = new h2d.Interactive(1,1,wrapper);
		interactive.onOver = function(_) addState("over");
		interactive.onOut = function(_) removeState("over");

		if( p!=null ) {
			//trace(this+" added to => "+p+" as "+p.getType());
			p.addChild(this);
			askRender(true);
		}
	}


	public function setCursor(c:hxd.System.Cursor) {
		interactive.cursor = c;
	}

	//gosh i hate this naming. => Seb: fixed :)
	public inline function countChildren() 		return children.length;
	public inline function getChildren() 		return children;
	public inline function getChildAt(i:Int) 	return children[i];
	public inline function lastChild() 			return children[children.length-1];

	public function enableInteractive() {
		interactive.visible = true;
	}

	public function disableInteractive() {
		interactive.visible = false;
	}

	function set_x(v) {
		if( x!=v )
			askRender(true);
		x = v;
		return v;
	}

	function set_y(v) {
		if( y!=v )
			askRender(true);
		y = v;
		return v;
	}

	function set_minWidth(v) {
		if( minWidth!=v ) {
			minWidth = v;
			askRender(true);
		}
		return v;
	}

	function set_maxWidth(v) {
		if( maxWidth!=v ) {
			maxWidth = v;
			askRender(true);
		}
		return v;
	}

	function set_minHeight(v) {
		if( minHeight!=v) {
			minHeight = v;
			askRender(true);
		}
		return v;
	}

	function set_maxHeight(v) {
		if( maxHeight!=v ) {
			maxHeight = v;
			askRender(true);
		}
		return v;
	}

	public function show() {
		if( isVisible() )
			return;

		visible = true;
		askRender(true);
	}


	function createField(txt:Dynamic) : Text {
		var tf = new Text(style.getFont());
		tf.text = Std.string(txt);
		textFields.push(tf);
		return tf;
	}


	public function hide() {
		if( !isVisible() )
			return;

		visible = false;
		askRender(true);
	}

	public inline function isVisible() {
		return visible;
	}
	
	public inline function setVisible(onOff) {
		onOff?show():hide();
		return onOff;
	}

	public function addState(k:String) {
		if( !hasState(k) ) {
			states[k] = true;
			onStateChange(k, true);
			askRender(false);
		}
	}

	public function removeState(k:String) {
		if( hasState(k) ) {
			states[k] = false;
			onStateChange(k, false);
			askRender(false);
		}
	}

	function toggleState(k:String) {
		if( hasState(k) )
			removeState(k);
		else
			addState(k);
	}

	inline function hasState(k:String) {
		return states[k]==true;
	}

	function hasAnyState(stateIds:Array<String>) {
		for(k in stateIds)
			if( hasState(k) )
				return true;
		return false;
	}

	function onStateChange(k:String, newVal:Bool) {}
	function applyStates() {}


	public function setWidth(w) {
		minWidth = maxWidth = w;
	}

	public function setHeight(h) {
		minHeight = maxHeight = h;
	}

	public function setSize(w,h) {
		setWidth(w);
		setHeight(h);
	}

	function toString() {
		return Type.getClass(this)+'#$uid(${children.length} child.)';
	}


	public inline function getWidth() : Float {
		if( !isVisible() )
			return 0;

		var base = forcedWidth!=null ? forcedWidth : getContentWidth();
		base = MLib.fmin( maxWidth, MLib.fmax( base, minWidth ) );
		base += style.paddingExpandsBox ? style.hpadding*2 : 0;
		return base;
	}


	public function getHeight() : Float {
		if( !isVisible() )
			return 0;

		var base = forcedHeight!=null ? forcedHeight : getContentHeight();
		base = MLib.fmin( maxHeight, MLib.fmax( base, minHeight ) );
		base += style.paddingExpandsBox ? style.vpadding*2 : 0;
		return base;

		//var paddingExpand = style.paddingExpandsBox ? style.vpadding*2 : 0;
		//if( forcedHeight!=null )
			//return forcedHeight + paddingExpand;
		//else
			//return MLib.fmin( maxHeight, MLib.fmax( getContentHeight(), minHeight ) ) + paddingExpand;
	}


	function getContentWidth() : Float {
		return 0;
	}

	function getContentHeight() : Float {
		return 0;
	}

	public function setPos(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}



	@:allow(mt.deepnight.hui.Style) function askRender(structureChanged:Bool) {
		if( renderAsked )
			return;

		renderAsked = true;
		TO_RENDER.push(this);

		if( structureChanged && parent!=null )
			parent.askRender(structureChanged);
	}

	function prepareRender() {
		if( visible ) {
			for( c in children )
				c.prepareRender();

			for(tf in textFields) {
				tf.font = style.getFont();
				tf.textColor = style.textColor;
				tf.filter = style.fontFiltering;
				tf.lineSpacing = style.lineSpacing;
			}

		}

	}

	function render(w:Float, h:Float) {
		wrapper.visible = visible;
		wrapper.x = Std.int(x);
		wrapper.y = Std.int(y);

		interactive.width = w;
		interactive.height = h;

		renderContent(w-style.hpadding*2, h-style.vpadding*2);

		renderBackground(w,h);
	}


	function renderContent(w:Float, h:Float) {
		content.x = style.hpadding;
		content.y = style.vpadding;
	}


	//@:allow(mt.deepnight.hui.Style) function initBg() {
		//switch( style.bg ) {
			//case None :
				//bg.tile = h2d.Tile.fromColor(0x0);
//
			//case Col(c,a) :
				//bg.tile = h2d.Tile.fromColor(Color.addAlphaF(c,a));
//
			//case Texture(t) :
				//bg.tile = t;
		//}
	//}


	function renderBackground(w:Float, h:Float) {
		switch( style.bg ) {
			case None :
				bg.tile = h2d.Tile.fromColor(0x0);

			case Col(c,a) :
				bg.tile = h2d.Tile.fromColor(Color.addAlphaF(c,a));

			case Texture(t) :
				bg.tile = t;
		}

		bg.scaleX = w / bg.tile.width;
		bg.scaleY = h / bg.tile.height;
	}


	public function destroy() {
		destroyed = true;
		ALL.remove(this);
		removeAllChildren();

		style = null;

		if( parent!=null )
			parent.removeChild(this);
		else if( wrapper.parent!=null )
			wrapper.parent.removeChild(wrapper);

		interactive.dispose();
		bg.dispose();
		content.dispose();
		wrapper.dispose();

		renderAsked = false;
		TO_RENDER.remove(this);

		onDestroy();
	}

	public function addChild(c:Component) {
		if( c.parent!=null )
			c.parent.removeChild(c);
		children.push(c);
		c.parent = this;
		askRender(true);
	}


	public function removeChild(c:Component) {
		children.remove(c);
		c.parent = null;
		wrapper.removeChild(c.wrapper);
		askRender(true);
	}

	public function removeAllChildren() {
		while( children.length>0 )
			children[0].destroy();
		askRender(true);
	}


	public function watchValue( getValue:Void->Dynamic ) {
		watchedValue = getValue;
	}

	public function stopWatching() {
		watchedValue = null;
		lastWatchedValue = "__watch__";
	}

	function onWatchChange(v:Dynamic) {
	}

	public function getGlobalCoord() {
		var x = x;
		var y = y;
		var p = parent;
		while( p!=null ) {
			x+=p.x;
			y+=p.y;
			p = p.parent;
		}
		return { x:x, y:y }
	}

	public function update() {
		if( watchedValue!=null && !destroyed ) {
			var v = watchedValue();
			if( v!=lastWatchedValue )
				onWatchChange(v);
			lastWatchedValue = v;
		}
	}

	public static function updateAll() {
		// Real time updates (if needed)
		for ( c in ALL )
			if( !c.destroyed )
				c.update();

		if ( TO_RENDER.length > 0 ) {
			//var t = haxe.Timer.stamp();
			//trace("rendering "+TO_RENDER.length);
			var rlist = TO_RENDER.copy();

			// Prepare components
			while( TO_RENDER.length>0 ) {
				var c = TO_RENDER.shift();
				if( !c.destroyed ) {
					c.prepareRender();
					c.renderAsked = false;
				}
			}

			// Draw them
			for(c in rlist)
				if( !c.destroyed ) {
					c.render(c.getWidth(), c.getHeight());
					c.applyStates();
				}

			//trace("rendering complete "+(haxe.Timer.stamp()-t)+"s");
		}
	}

}

