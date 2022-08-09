@:bind
class OptShotRate extends Option {
	public function new(){
		super();
		time = 15000;
	}
	override public function activate(){
		super.activate();
		Game.instance.shotRate /= 2;
	}
	override public function inactivate(){
		Game.instance.shotRate *= 2;
	}
}