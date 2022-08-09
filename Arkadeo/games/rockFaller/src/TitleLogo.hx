class TitleLogo extends flash.display.Sprite {
	public function new() {
		super();
		var mc = new gfx.Typo() ;
		//mc.x = Game.WID*0.5;
		mc.y = 20 ;
		addChild(mc);
	}
}
