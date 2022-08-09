class HurtAnim implements Anim {
	var obj : flash.display.DisplayObject;
	var end : Float;
	
	public function new( e:flash.display.DisplayObject, time:Int=100 ){
		obj = e;
		end = Game.instance.now + time;
		obj.transform.colorTransform = new flash.geom.ColorTransform(1.0, 1.0, 1.0, 1.0, 1000.0, 1000.0, 1000.0, 1000.0 );
	}

	public function update() : Bool {
		if (end <= Game.instance.now){
			obj.transform.colorTransform = new flash.geom.ColorTransform(1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 );
			return false;
		}
		return true;
	}
}