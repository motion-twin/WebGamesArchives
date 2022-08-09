package mt.ui;

using mt.flash.Lib;

class VSlice3 implements mt.signal.Signaler2
{
	@:signal public var onResize:Void->Void;
	
	public var top(default, null):DisplayObject;
	public var center(default, null):DisplayObject;
	public var bottom(default, null):DisplayObject;
	
	public var height(get, set):Float;
	public var width(get, set):Float;
	
	var lastHeight: Float;
	var lastWidth:Float;
	var originHeight:Array<Float>;
	var originOffsets:Array<Float>;
	var originWidth:Float;
	var isResized:Bool;
	var anchors:List<{root:DisplayObject, x:Float, y:Float, width:Float, height:Float}>;
	
	public function new( p_topSkin:DisplayObject, p_centerSkin:DisplayObject, p_bottomSkin:DisplayObject) 
	{
		top = p_topSkin;
		center = p_centerSkin;
		bottom = p_bottomSkin;
		
		originHeight = [top.height, center.height, bottom.height];
		originOffsets = [top.y, center.y - (top.y + top.height), bottom.y - (center.y + center.height)];
		
		lastHeight = originHeight[0] + originHeight[1] + originHeight[2];
		lastWidth = originWidth = top.width;
		anchors = new List();
		isResized = false;
	}
	
	public function reset()
	{
		top.y = originOffsets[0];
		center.y = originOffsets[1];
		bottom.y = originOffsets[2];
		
		top.height = originHeight[0];
		center.height = originHeight[1];
		bottom.height = originHeight[2];
		
		top.width = originWidth;
		center.width = originWidth;
		bottom.width = originWidth;
	}
	
	public function dispose()
	{
		onResize.dispose();
		anchors = null;
		originHeight = null;
		originOffsets = null;
	}
	
	function set_height(value:Float):Float
	{
		if( value <= 0 ) return 0.;
		var h = value - top.height - bottom.height;
		if( h <= 0 ) h = 0.;
		isResized = true;
		//
		top.y = originOffsets[0];
		center.y = top.y + top.height + originOffsets[1] #if cpp- 1.0#end;
		center.height = h #if cpp + 2.0#end;
		bottom.y = center.y + center.height + originOffsets[2];
		//
		lastHeight = value;
		//
		updateAnchors();
		onResize.dispatch();
		return value;
	}
	
	function get_height():Float 
	{
		return lastHeight;
	}
	
	function set_width(value:Float):Float
	{
		if( lastWidth == value ) return value;
		isResized = true;
		
		lastWidth = value;
		top.width = value;		
		center.width = value;
		bottom.width = value;
		#if cpp
		//https://github.com/openfl/openfl/issues/226
		top.width;
		center.width;
		bottom.width;
		#end
		//
		top.scaleY = top.scaleX;
		bottom.scaleY = bottom.scaleX;
		//
		this.height = lastHeight;
		//
		return value;
	}
	
	function get_width():Float 
	{
		return lastWidth;
	}
	
	public function addAnchor(p_root:DisplayObject, p_x:Float, p_y:Float, p_width:Float, p_height:Float)
	{
		if( isResized ) throw "Impossible to add anchor once the slice3 has been distorted";
		anchors.add( { root:p_root, x:p_x, y:p_y, width:p_width, height:p_height } );
	}
	
	function updateAnchors()
	{
		var rw = width / originWidth;
		var rh = height / (originHeight[0] + originHeight[1] + originHeight[2]);
		for( anchor in anchors )
		{			
			var tw = anchor.width * rw;
			var th = anchor.height * rh;
			anchor.root.fitIn( tw, th );
			anchor.root.x = anchor.x * rw;
			anchor.root.x += (tw - anchor.root.width) / 2;
			//point d'ancrage dans le top
			if( anchor.y < originHeight[0] )
			{
				var rh = top.height / originHeight[0];
				anchor.root.y = anchor.y * rh;
			}
			//point d'ancrage dans le center
			else if( anchor.y < originHeight[0]+originHeight[1] )
			{
				var ay = anchor.y - originHeight[0];
				anchor.root.y = top.height + ay * rh;
			}
			else
			{
				var ay = anchor.y - originHeight[0] - originHeight[1];
				anchor.root.y = top.height + center.height + ay * rh;
			}
		}
	}
}
