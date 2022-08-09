package mt.ui.layout;

import mt.Metrics.Px;

/**
 * Configuration of the element
 */
typedef ElementConfig = {

	var width:String;
	var height:String;
	
	var paddingLeft:String;
	var paddingRight:String;
	var paddingTop:String;
	var paddingBottom:String;
	
	@:optional var minWidth:Null<String>;
	@:optional var minHeight:Null<String>;
	@:optional var maxWidth:Null<String>;
	@:optional var maxHeight:Null<String>;
}

/**
 * Position behaviour of the element node inside the layout
 */
enum VLayoutKind {
	MIDDLE;
	TOP;
	BOTTOM;	
	INHERITED;
}

enum HLayoutKind {
	CENTER;
	LEFT;
	RIGHT;
	INHERITED;
}

/**
 * Aspect of the element when it is resized.
 */
enum AspectKind {
	FIXED;
	MATCH_PARENT;
	KEEP_IN( ratio:Float );
	KEEP_OUT( ratio:Float );	
}

typedef Bounds = { 
	x:Float, 
	y:Float, 
	width:Float, 
	height:Float,
}

class Element implements mt.signal.Signaler2
{
	@:signal public var onUpdate:Element->Void;
	@:signal public var onDisabled:Element->Void;
	
	public var name:String;
	public var config:ElementConfig;
	public var hLayout:HLayoutKind;
	public var vLayout:VLayoutKind;
	public var aspect:AspectKind;
	
	public var paddingLeft(default, null):Float;
	public var paddingRight(default, null):Float;
	public var paddingTop(default, null):Float;
	public var paddingBottom(default, null):Float;
	
	public var x(default, null):Float;
	public var y(default, null):Float;
	
	public var globalX(get, null):Float;
	public var globalY(get, null):Float;
	
	public var width(default, null):Float;
	public var height(default, null):Float;
	public var bounds(default, null): Bounds;
	
	public var disabled(default, set):Bool;
	inline function set_disabled(value:Bool):Bool {
		if( value != disabled ) {
			disabled = value;
			onDisabled.dispatch(this);
		}
		return disabled;
	}
	
	var contentX(get, set):Float;
	function get_contentX():Float { return x; }
	function set_contentX(v:Float) {
		x = v;
		bounds.x = v - paddingLeft; 
		return v; 
	};
	
	var contentY(get, set):Float;
	function get_contentY():Float { return y; }
	function set_contentY(v:Float) { 
		y = v;
		bounds.y = v - paddingTop; 
		return v; 
	};
	
	var contentWidth(get, set):Float;
	function get_contentWidth():Float { return width; }
	function set_contentWidth(v:Float) {
		width = v;
		bounds.width = v + paddingLeft + paddingRight; 
		return v; 
	};
	
	var contentHeight(get, set):Float;
	function get_contentHeight():Float { return height; }
	function set_contentHeight(v:Float) {
		height = v;
		bounds.height = v + paddingTop + paddingBottom;
		return v;
	};
	
	
	public function relativeX( p_ref:Element ):Float
	{
		var lparent:Element = cast parent;
		var lx = x;
		while ( lparent != null && lparent != p_ref )
		{
			lx += lparent.x;
			lparent = cast lparent.parent;
		}
		if ( lparent != p_ref ) throw "invalid reference";
		return lx;
	}
	
	public function relativeY( p_ref:Element ):Float
	{
		var lparent:Element = cast parent;
		var ly = y;
		while ( lparent != null && lparent != p_ref )
		{
			ly += lparent.y;
			lparent = cast lparent.parent;
		}
		if ( lparent != p_ref ) throw "invalid reference";
		return ly;
	}
	
	public var parent(default, null):Null<IElementContainer>;
	
	inline function get_globalX() {
		var v = x;
		if( parent != null )
			v += parent.globalX;
		return v;
	}
	
	inline function get_globalY() {
		var v = y;
		if ( parent != null )
			v += parent.globalY;
		return v;
	}
	
	inline static public function toPixels(v:String, p:Float=0.0):Float 
	{
		var c = v.charAt(v.length - 1);
		return 		if ( c >= '0' && c <= '9') Std.parseFloat(v)
					else if ( c == "%" ) Std.parseFloat(v) * 0.01 * p
					else { var tmp : Px = v; tmp; }
	}
	
	inline public function px(v:String, p:Float=0.0):Float 
	{
		var c = v.charAt(v.length - 1);
		return 		if ( c >= '0' && c <= '9') Std.parseFloat(v)
					else if ( c == "%" ) Std.parseFloat(v) * 0.01 * p
					else { var tmp : Px = v; tmp; }
	}
	
	public function new( pWidth:String, pHeight:String, ?pHorizontalLayout:HLayoutKind=null, ?pVerticalLayout:VLayoutKind=null, ?pAspect:AspectKind=null ) 
	{
		//var u = onUpdate;
		//var d = onDisabled;
		
		this.hLayout = pHorizontalLayout == null ? HLayoutKind.INHERITED : pHorizontalLayout;
		this.vLayout = pVerticalLayout == null ? VLayoutKind.INHERITED : pVerticalLayout;
		this.aspect = pAspect == null ? AspectKind.MATCH_PARENT : pAspect;
		this.bounds = { x:0, y:0, width:0, height:0 };
		this.paddingTop = this.paddingRight = this.paddingLeft = this.paddingBottom = 0;
		this.contentHeight = this.contentWidth = 0;
		this.contentX = this.contentY = 0;
		this.disabled = false;
		parent = null;
		config = { paddingLeft:"0", paddingRight:"0", paddingTop:"0", paddingBottom:"0", width:StringTools.trim(pWidth), height:StringTools.trim(pHeight) };
	}
	
	public function clone():Element
	{
		var e = new Element("1", "1");
		e.name = this.name;
		e.config = { paddingLeft:config.paddingLeft, paddingRight:config.paddingRight, paddingTop:config.paddingTop, paddingBottom:config.paddingBottom, width:config.width, height:config.height };
		e.vLayout = this.vLayout;
		e.hLayout = this.hLayout;
		e.aspect = this.aspect;
		e.disabled = this.disabled;
		e.parent = this.parent;
		
		//var u = e.onUpdate;
		//var d = e.onDisabled;
		
		return e;
	}
	
	public function getElementByName( pName:String ):Null<Element>
	{
		return name == pName ? this : null;
	}
	
	public function clean()
	{
		onUpdate.dispose();
		onDisabled.dispose();
	}
	
	public function notify()
	{
		onUpdate.dispatch(this);
	}
	
	public function resize( pWidth:Float, pHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float>, ?p_silent:Bool=false )
	{
		updateSize( pWidth, pHeight, pForceWidth, pForceHeight );
		updatePosition( pWidth, pHeight );
		//
		if( !p_silent )
			notify();
	}
	
	function updatePosition( pContainerWidth:Float, pContainerHeight:Float )
	{
		var left 	= paddingLeft;
		var right 	= paddingRight;
		var top 	= paddingTop;
		var bottom 	= paddingBottom;
		
		var layout = if ( hLayout == INHERITED ) parent.hLayout else hLayout;
		switch( layout )
		{
			case LEFT:		contentX = left;
			case RIGHT: 	contentX = pContainerWidth - contentWidth - right;
			case CENTER: 	contentX = ((pContainerWidth - contentWidth) / 2) + ((left - right) / 2);
			case INHERITED:	
		}
		
		var layout = if ( vLayout == INHERITED ) parent.vLayout else vLayout;
		switch( layout )
		{
			case TOP: 		contentY = top;
			case BOTTOM:	contentY = pContainerHeight - contentHeight - bottom;
			case MIDDLE: 	contentY = ((pContainerHeight - contentHeight) / 2) + ((top - bottom) / 2);
			case INHERITED:	
		}
	}
	
	function updateSize( pContainerWidth:Float, pContainerHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float> ):Void 
	{
		paddingLeft 	= px(config.paddingLeft, 	(pForceWidth==null	? pContainerWidth 	: pForceWidth));
		paddingRight 	= px(config.paddingRight, 	(pForceWidth==null	? pContainerWidth	: pForceWidth));
		paddingTop 		= px(config.paddingTop, 	(pForceHeight==null	? pContainerHeight	: pForceHeight));
		paddingBottom 	= px(config.paddingBottom, 	(pForceHeight==null	? pContainerHeight	: pForceHeight));
		
		var elementWidth 	= px(config.width, pContainerWidth);
		var elementHeight 	= px(config.height, pContainerHeight);
		
		var screenWidth 	= 	(pForceWidth==null ? elementWidth:pForceWidth) - paddingLeft - paddingRight;
		var screenHeight 	= 	(pForceHeight==null? elementHeight:pForceHeight) - paddingTop - paddingBottom;
		
		if( config.minWidth != null && screenWidth < px(config.minWidth, pContainerWidth) ) 	screenWidth 	= px(config.minWidth, pContainerWidth);
		if( config.maxWidth != null && screenWidth > px(config.maxWidth, pContainerWidth) ) 	screenWidth 	= px(config.maxWidth, pContainerWidth);
		if( config.minHeight != null && screenHeight < px(config.minHeight, pContainerHeight) ) screenHeight 	= px(config.minHeight, pContainerHeight);
		if( config.maxHeight != null && screenHeight > px(config.maxHeight, pContainerHeight) ) screenHeight 	= px(config.maxHeight, pContainerHeight);
		
		switch( aspect )
		{
			case KEEP_IN(ratioValue):
				if(screenWidth / ratioValue > screenHeight) 
				{
					contentWidth = screenHeight * ratioValue;
					contentHeight = screenHeight;
				}
				else 
				{
					contentWidth = screenWidth;
					contentHeight = screenWidth / ratioValue;
				}
				
			case KEEP_OUT(ratioValue):
				if(screenWidth / ratioValue < screenHeight) 
				{
					contentWidth = screenHeight * ratioValue;
					contentHeight = screenHeight;
				}
				else
				{
					contentWidth = screenWidth;
					contentHeight = screenWidth / ratioValue;
				}
				
			case MATCH_PARENT:
				contentWidth = screenWidth;
				contentHeight = screenHeight;
				
			case FIXED:
				contentWidth = screenWidth;
				contentHeight = screenHeight;
		}
		
		if( Math.isNaN(contentWidth) )
		{
			trace("oups");
		}
		if( Math.isNaN(contentHeight) )
		{
			trace("oups");
		}
		if(contentWidth < 0) contentWidth = 0;
		if(contentHeight < 0) contentHeight = 0;
	}
	
}
