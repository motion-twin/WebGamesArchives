package mt.ui;

using mt.flash.Lib;

class HSlice3 implements mt.signal.Signaler2
{
	@:signal public var onResize:Void->Void;
	
	public var left(default, null):DisplayObject;
	public var center(default, null):DisplayObject;
	public var right(default, null):DisplayObject;
	
	public var height(get, set):Float;
	public var width(get, set):Float;
	
	var lastHeight: Float;
	var lastWidth:Float;
	var originalElementWidth:Array<Float>;
	var originOffsets:Array<Float>;
	var originWidth:Float;
	var originHeight:Float;
	var isResized:Bool;
	var anchors:List<{root:DisplayObject, x:Float, y:Float, width:Float, height:Float}>;
	var disposed:Bool = false;
	public function new( p_leftSkin:DisplayObject, p_centerSkin:DisplayObject, p_rightSkin:DisplayObject) 
	{
		left = p_leftSkin;
		center = p_centerSkin;
		right = p_rightSkin;
		originalElementWidth = [left.width, center.width, right.width];		
		originOffsets = [0, center.x - (left.x + left.width), right.x - (center.x + center.width)];
		
		lastWidth = originWidth = left.width +center.width + right.width;
		lastHeight = originHeight = left.height;
		anchors = new List();
		isResized = false;
	}
	
	public function reset()
	{
		if ( disposed ) return;
		width = originWidth;
		height = originHeight;
	}
	
	public function dispose()
	{
		if ( disposed ) return;
		onResize.dispose();
		anchors = null;
		originalElementWidth = null;
		originOffsets = null;
		left = center = right = null;
		disposed = true;
	}
	
	function set_width(value:Float):Float
	{
		if ( disposed ) return value;
		if( value <= 0 ) return 0.;
		var w = value - left.width - right.width - originOffsets[0] - originOffsets[1] - originOffsets[2];
		if ( w <= 0 ) 
			return 0;
		
		isResized = true;
		//
		left.x = originOffsets[0];
		center.x = left.x + left.width + originOffsets[1] #if cpp - 1.0#end;
		center.width = w #if cpp + 2.0 #end;
		right.x = center.x + center.width + originOffsets[2];
		//
		lastWidth = value;
		updateAnchors();
		onResize.dispatch();
		//
		return value;
	}
	
	function get_width():Float 
	{
		return lastWidth;
	}
	
	function set_height(value:Float):Float
	{
		if ( disposed ) return value;
		if( lastHeight == value ) return value;
		isResized = true;
		
		lastHeight = value;
		center.height = value;
		
		var leftRatioH = value / left.height;
		left.height = value;		
		var rightRatioH = value / right.height;
		right.height = value;
		#if cpp
		//https://github.com/openfl/openfl/issues/226
		left.height;
		center.height;
		right.height;
		#end
		//
		left.width *= leftRatioH;
		right.width *= rightRatioH;
		//
		this.width = lastWidth;
		return value;
	}
	
	function get_height():Float 
	{
		return lastHeight;
	}
	
	public function addAnchor(p_root:DisplayObject, p_x:Float, p_y:Float, p_width:Float, p_height:Float)
	{
		if( disposed || isResized ) throw "Impossible to add anchor once the slice3 has been distorted";
		anchors.add( { root:p_root, x:p_root.x, y:p_root.y, width:p_width, height:p_height } );
	}
	
	function updateAnchors()
	{
		var rh = height / originHeight;
		for( anchor in anchors )
		{	
			var rw:Float = 1.0;
			//point d'ancrage dans le top
			if( anchor.x < (originOffsets[0]+originalElementWidth[0]) )
			{
				rw = left.width / originalElementWidth[0];
				anchor.root.x = originOffsets[0] + anchor.x * rw;
			}
			//point d'ancrage dans le center
			else if( anchor.x < (originOffsets[0]+originalElementWidth[0]+originOffsets[1]+originalElementWidth[1]) )
			{
				var ax = anchor.x - originalElementWidth[0] - originOffsets[0] - originOffsets[1];
				rw = center.width / originalElementWidth[1];
				anchor.root.x = originOffsets[0] + originOffsets[1] + left.x + left.width + ax * rw;
			}
			else
			{
				var ax = anchor.x - originalElementWidth[0] - originalElementWidth[1];
				rw = right.width / originalElementWidth[2];
				anchor.root.x = originOffsets[0] + originOffsets[1] + originOffsets[2] + center.x + center.width + ax * rw;
			}
			
			anchor.root.width = anchor.width * rw;
			anchor.root.height = anchor.height * rh;
			anchor.root.y = anchor.y * rh;
		}
	}
}
