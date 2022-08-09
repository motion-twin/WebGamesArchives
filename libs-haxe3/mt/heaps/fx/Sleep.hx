package mt.heaps.fx;
import h2d.Sprite;

class Sleep extends mt.fx.Fx 
{
	var f: mt.fx.Fx;
	var count:Int;
	var onWakeUp:Void->Void;
	
	public function new(?f,?onWakeUp,count=10) {
		this.f = f;
		this.onWakeUp = onWakeUp;
		this.count = count;
		mt.fx.Fx.DEFAULT_MANAGER.remove(f);
		super();
	}
	
	override function update() {
		super.update();
		if( count-- <= 0 ) {
			if( f!= null ){
				mt.fx.Fx.DEFAULT_MANAGER.add(f);
				f.update();
			}
			if( onWakeUp != null ) onWakeUp();
			kill();
		}
	}
	
	public function hide(mc:h2d.Sprite,play=false) {
		mc.visible = false;
		onWakeUp = function() {
			mc.visible = true;
		}
	}
}
