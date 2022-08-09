package part;
import mt.bumdum9.Lib;

class Fire extends Basic  {//}

	public function new() {
		super(new gfx.Explo());
		weightZ = 0.2+Math.random()*0.3;
		timer = 20;
		this.dropShade(3);
	}
	override function update() {
		
		super.update();
		var m = new MX();
		var sc = Math.min(timer / 200,0.1);
		m.scale(sc, sc);
		m.translate(root.x, root.y);
		Game.me.plasma.draw(root, m,null,flash.display.BlendMode.ADD);
	}

}
