import Tank;

@:bind
class OptArmor extends Option {
	public function new(){
		super();
		time = 1000;
	}

	override public function activate(){
		super.activate();
		Game.instance.armor = KKApi.const(Std.int(Math.min(KKApi.val(Game.MAX_ARMOR), KKApi.val(Game.instance.armor)+1)));
		Game.instance.updateArmorBits();
		Game.instance.tank.setState(Heal);
	}
}