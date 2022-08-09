package fx;
import Protocole;
import mt.bumdum9.Lib;

class Medusa extends mt.fx.Fx{//}

	var art:pix.Sprite;
	var player:Player;

	
	public function new(player:Player) {
		this.player = player;
		super();
		
		art = new pix.Sprite();
		art.setAlign(0, 0);
		art.setAnim(Gfx.illus.getAnim("medusa"),false);
		Main.root.addChild(art);
		art.scaleX = art.scaleY = 8;
		
		coef = 0;

	}
	

	override function update() {
		super.update();
		
		coef = Math.min(coef + 0.05, 1);
		var c = Math.pow(coef, 2);
		Col.setColor(art,0,Std.int(c*255));
	
		if( coef == 1 ) {
			art.kill();
			kill();
			World.me.backIn();
			var fx = new mt.fx.Flash(World.me.screen, 0.05);
			fx.curveIn(2);
			fx.maj();
		}
	
		
	}


	
	
	
//{
}








