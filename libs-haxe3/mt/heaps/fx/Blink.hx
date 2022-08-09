package mt.heaps.fx;

class Blink extends mt.fx.Fx {

	var mc:h2d.Sprite;
	var timer:Int;
	var on:Int;
	var off:Int;
	
	public var afterUpdate:Void->Void;
	
	/**
	 * Blink Fx
	 * @param	mc			Target DisplayObject
	 * @param	timer = 10	Duration of the Fx in frames, 0 means infinite duration
	 * @param	on = 2		Duration of 'on' phase in frames
	 * @param	off = 2		Duration of 'off' phase in frames
	 */
	public function new(?pManager: mt.fx.Manager, mc, timer = 10, on = 2, off = 2) {
		super(pManager);
		this.mc = mc;
		this.timer = timer;
		this.on = on;
		this.off = off;
	}
	
	override function update() {
		mc.visible = Math.abs(timer) % (on + off) < on;
		timer--;		
		
		if ( afterUpdate != null ) afterUpdate();
		if(mc.parent == null) kill();
		if( timer == 0 ) kill();
	}
}
