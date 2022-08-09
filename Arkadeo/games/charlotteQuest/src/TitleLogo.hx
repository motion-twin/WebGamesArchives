class TitleLogo extends flash.display.Sprite {
	public function new() {
		super();
		var mc = new lib.Title();
		//mc.x = Game.WID*0.5;
		//mc.y = Game.HEI*0.5;
		addChild(mc);
	}
}
