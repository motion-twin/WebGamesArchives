package ac;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;



class Victory extends Action {//}


	override function init() {
		super.init();

		var inc = Math.ceil( Game.me.xpsum/Game.me.heroes.length );
		for ( h in Game.me.heroes ) {
			var mc = new SP();
			Scene.me.dm.add(mc, Scene.DP_FX);
			var field = TField.get(0xAAFF00, 12, "verdana");
			field.text = "+" + inc + " xp";
			field.x -= field.textWidth * 0.5;
			field.height = 20;
			mc.addChild(field);
			var p = new mt.fx.Part(mc);
			p.setPos(h.folk.x, 20);
			p.vy = -4;
			p.frict = 0.75;
			p.timer = 50;
			p.fadeType = 1;
			mc.blendMode = flash.display.BlendMode.LAYER;
			Filt.glow(mc, 2, 40, 0);
		}
	}

	// UPDATE
	override function update() {
		super.update();
		if ( timer == 50 ) game.end(true);
	}




//{
}