package mt.deepnight.mui;

import flash.display.Sprite;
import flash.display.DisplayObjectContainer;

private abstract UnifiedParent({display:DisplayObjectContainer, comp:Component}) {

	inline function new(p:{display:DisplayObjectContainer, comp:Component}) {
		this = p;
	}

	@:from static inline function fromDisplay(o:DisplayObjectContainer) {
		return new UnifiedParent({ display:o, comp:null });
	}

	@:from static inline function fromComponent(c:Component) {
		return new UnifiedParent({ display:c.wrapper, comp:c });
	}

	public inline function getComponent() : Component {
		return this.comp;
	}

	public inline function getDisplayObject() : DisplayObjectContainer {
		return this.display;
	}

	public inline function addChild(o:UnifiedParent) {
		if( this.comp!=null && o.getComponent()!=null )
			this.comp.addChild( o.getComponent() );

		if( this.display!=null && o.getDisplayObject()!=null )
			this.display.addChild( o.getDisplayObject() );
	}

}



class Component {
	public static 	var BG_COLOR = 0x53608A;
	static			var UID = 0;
	static 			var ALL : Array<Component> = [];
	static 			var TO_RENDER : Array<Component> = [];

	var uid									: Int;

	public var wrapper						: Sprite;
	public var bg							: Sprite;
	public var content						: Sprite;

	public var destroyed(default,null)		: Bool;
	var children							: Array<Component>;
	var states								: Map<String, Bool>;
	var renderAsked							: Bool;
	var textFields							: Array<flash.text.TextField>;
	var textFieldSettings					: { font:String, size:Int, color:UInt, embed:Bool, italic:Bool, bold:Bool, sharpen:Bool };

	public var parent(default,null)			: Null<Component>;
	public var color(default,set)			: Int;
	public var hasBackground(default,set)	: Bool;
	public var bgAlpha(default,set)			: Float;
	var visible								: Bool;
	public var mouseOverable(default,set)	: Bool;

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

	// Variable watching mechanic
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
		color = BG_COLOR;
		hasBackground = true;
		states = new Map();
		lastWatchedValue = "__watch__";
		bgAlpha = 1;

		textFieldSettings = { font:"Arial", size:12, color:0xFFFFFF, embed:false, italic:false, bold:false, sharpen:false }

		//setSkin( new Skin(this, 0x7589B9) );

		wrapper = new Sprite();
		wrapper.visible = false;
		mouseOverable = true;

		bg = new Sprite();
		wrapper.addChild(bg);

		content = new Sprite();
		wrapper.addChild(content);

		if( p!=null ) {
			p.addChild(this);
			askRender(true);
		}
	}

	function onMouseOver(_) {
		if( mouseOverable )
			addState("over");
	}

	function onMouseOut(_) {
		removeState("over");
	}

	function set_mouseOverable(v) {
		if( !mouseOverable && v ) {
			wrapper.addEventListener( flash.events.MouseEvent.MOUSE_OVER, onMouseOver );
			wrapper.addEventListener( flash.events.MouseEvent.MOUSE_OUT, onMouseOut );
		}

		if( mouseOverable && !v ) {
			wrapper.removeEventListener( flash.events.MouseEvent.MOUSE_OVER, onMouseOver );
			wrapper.removeEventListener( flash.events.MouseEvent.MOUSE_OUT, onMouseOut );
		}

		return mouseOverable = v;
	}

	//gosh i hate this naming. => Seb: fixed :)
	public inline function countChildren() 		return children.length;
	public inline function getChildren() 		return children;
	public inline function getChildAt(i:Int) 	return children[i];
	public inline function lastChild() 			return children[children.length-1];

	function set_color(v) {
		askRender(false);
		return color = v;
	}

	function set_bgAlpha(v) {
		askRender(false);
		return bgAlpha = v;
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

	function set_hasBackground(v) {
		if( hasBackground!=v ) {
			hasBackground = v;
			if( !hasBackground )
				bg.graphics.clear();
			askRender(true);
		}
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

	public function setFont(embedId:String, size:Int, ?color=-1) {
		textFieldSettings.font = embedId;
		textFieldSettings.size = size;
		if( color!=-1 )
			textFieldSettings.color = color;
		textFieldSettings.embed = true;

		updateAllTextFields();
	}

	public function setBold(v:Bool) {
		textFieldSettings.bold = v;
		updateAllTextFields();
	}

	public function setItalic(v:Bool) {
		textFieldSettings.italic = v;
		updateAllTextFields();
	}

	public function setFontSize(size:Int) {
		textFieldSettings.size = size;
		updateAllTextFields();
	}

	public function setFontColor(col:UInt) {
		textFieldSettings.color = col;
		updateAllTextFields();
	}

	function updateAllTextFields() {
		for(tf in textFields) {
			var f = tf.getTextFormat();
			f.font = textFieldSettings.font;
			f.size = textFieldSettings.size;
			f.color = textFieldSettings.color;
			f.italic = textFieldSettings.italic;
			f.bold = textFieldSettings.bold;

			tf.setTextFormat(f);
			tf.defaultTextFormat = f;
			tf.embedFonts = textFieldSettings.embed;
			//if( textFieldSettings.sharpen ) {
				//tf.sharpness = 1200;
				//tf.antiAliasType = flash.text.AntiAliasType.ADVANCED;
			//}
		}

		askRender(true);
	}

	function createField(txt:Dynamic) : flash.text.TextField {
		var f = new flash.text.TextFormat(textFieldSettings.font, textFieldSettings.size, textFieldSettings.color);
		f.italic = textFieldSettings.italic;
		f.bold = textFieldSettings.bold;

		var tf = new flash.text.TextField();
		tf.setTextFormat(f);
		tf.defaultTextFormat = f;
		tf.mouseEnabled = tf.selectable = tf.wordWrap = tf.multiline = false;
		tf.text = Std.string(txt);
		tf.embedFonts = textFieldSettings.embed;

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

	//public function setSkin(s:Skin) {
		//if( skin!=null )
			//skin.destroy();
		//
		//skin = s;
		//skin.onChange = askRender;
	//}

	public function addState(k:String) {
		if( !hasState(k) ) {
			states[k] = true;
			onStateChange2(k, true);
			askRender(false);
		}
	}

	public function removeState(k:String) {
		if( hasState(k) ) {
			states[k] = false;
			onStateChange2(k, false);
			askRender(false);
		}
	}

	function toggleState(k:String) {
		if( hasState(k) )
			removeState(k);
		else
			addState(k);
	}

	//function onStateChange(k:String, newVal:Bool) {
	//}

	inline function hasState(k:String) {
		return states[k]==true;
	}

	function hasAnyState(stateIds:Array<String>) {
		for(k in stateIds)
			if( hasState(k) )
				return true;
		return false;
	}

	function onStateChange2(k:String, newVal:Bool) {}
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
		return mt.MLib.fmin( maxWidth, mt.MLib.fmax( base, minWidth ) );
	}

	public inline function getHeight() : Float {
		if( !isVisible() )
			return 0;

		var base = forcedHeight!=null ? forcedHeight: getContentHeight();
		return mt.MLib.fmin( maxHeight, mt.MLib.fmax( base, minHeight ) );
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



	function askRender(structureChanged:Bool) {
		if( renderAsked )
			return;

		renderAsked = true;
		TO_RENDER.push(this);

		if( structureChanged && parent!=null )
			parent.askRender(structureChanged);
	}

	function prepareRender() {
		if( visible )
			for( c in children )
				c.prepareRender();
	}

	function render(w:Float, h:Float) {
		wrapper.visible = visible;
		wrapper.x = Std.int(x);
		wrapper.y = Std.int(y);

		renderContent(w,h);

		if( hasBackground )
			renderBackground(w,h);
	}


	function renderContent(w:Float, h:Float) {
	}


	function renderBackground(w:Float, h:Float) {
		bg.graphics.clear();
		bg.graphics.lineStyle(1, mt.deepnight.Color.brightnessInt(color, 0.1), bgAlpha);
		bg.graphics.beginFill(color, bgAlpha);
		bg.graphics.drawRect(0,0, w,h);
	}



	public function destroy() {
		destroyed = true;
		ALL.remove(this);
		removeAllChildren();

		wrapper.removeEventListener( flash.events.MouseEvent.MOUSE_OVER, onMouseOver );
		wrapper.removeEventListener( flash.events.MouseEvent.MOUSE_OUT, onMouseOut );

		if( parent!=null )
			parent.removeChild(this);
		else if( wrapper.parent!=null )
			wrapper.parent.removeChild(wrapper);

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

	//TODO QUERY support
	//TODO #id .classe
	//public function query();

	public inline function asLabel() : Label {
		return Std.is(this,Label) ? (cast this): null;
	}

	public inline function asGroup() : Group {
		return Std.is(this,Group) ? (cast this): null;
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

	public function disableMouse() {
		wrapper.mouseChildren = wrapper.mouseEnabled = false;
	}

	public function enableMouse() {
		wrapper.mouseChildren = wrapper.mouseEnabled = true;
	}


	public function disableMouseOnChildren() {
		for(c in children) {
			c.disableMouse();
			c.disableMouseOnChildren();
		}
	}

	public function enableMouseOnChildren() {
		for(c in children) {
			c.enableMouse();
			c.enableMouseOnChildren();
		}
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
		}
	}

}

