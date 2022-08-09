package mt.fx;

class Queue<T:flash.display.Sprite> extends Fx {

	var root:flash.display.DisplayObject;
	var tclass:Class<T>;
	var oldPos: { x:Float, y:Float };
	var mod:Int;
	var timer:Int;
	var color:Int;
	var blendMode:flash.display.BlendMode;
	
	public function new(mc:flash.display.Sprite , t:Class<T>, mod = 1, col=0xFFFFFF, ?blendMode ) {
		color = col;
		root = mc;
		tclass = t;
		this.mod = mod;
		super();
		timer = 0;
		if( blendMode == null ) blendMode = flash.display.BlendMode.NORMAL;
		this.blendMode = blendMode;
		
	}
	
	override function update() {
		
		if( root.parent == null  ) {
			kill();
			return;
		}
		
		timer++;
		if( timer % mod != 0 ) return;
		
		if( oldPos != null ) {
			var mc = Type.createInstance(tclass, []);
			mc.blendMode = blendMode;
			var dx = root.x - oldPos.x;
			var dy = root.y - oldPos.y;
			mc.rotation = Math.atan2(dy, dx)/0.0174;
			mc.scaleX = Math.sqrt(dx * dx + dy * dy) * 0.01;
			mc.x = oldPos.x;
			mc.y = oldPos.y;
			var n = root.parent.getChildIndex(root);
			root.parent.addChildAt( mc, n);
			mt.flash.Color.setColor(mc, color);
		}
		oldPos = { x:root.x, y:root.y };
		
	}
}
