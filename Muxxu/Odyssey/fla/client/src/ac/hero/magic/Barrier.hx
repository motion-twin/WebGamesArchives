package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;



class Barrier extends ac.hero.MagicAttack {//}
	

	var bar:fx.MagicBarrier;
	
	override function start() {
		super.start();

		bar = new fx.MagicBarrier();
		Filt.glow(bar, 10, 1, 0x00FFFF);
		bar.blendMode = flash.display.BlendMode.ADD;
		Scene.me.dm.add(bar, Scene.DP_FX);
	
		var pos = agg.folk.getCenter();
		bar.x = pos.x;
		bar.y = pos.y+6;
		bar.rotation = -45;
		bar.scaleX = bar.scaleY = 1.5;

		//kill();
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		if ( timer == 10 ) {
			var  p = new mt.fx.ShockWave(100, 140, 0.15);
			p.setPos(bar.x, bar.y);
			Scene.me.dm.add(p.root, Scene.DP_FX);
			
			var pow = 3;
			if ( agg.have(MAGIC_HEALING) ) {
				agg.removeAllNegativeStatus();
				add( new ac.hero.Regeneration(agg, 1) );
			}
			if ( agg.have(DARKNESS) )			Game.me.monster.addStatus(STA_BLIND);
			if ( agg.have(MECHA_ARMOR) )		pow++;
			
			var a = [agg];
			if ( agg.have(MAGIC_SHIELD) ) a = Game.me.heroes;
			for( h in a ) h.incArmor(pow);
			
		}
		
		for( i in 0...2 ) {
			var pos = Tools.getMcPos(bar,20);
			if ( pos == null ) continue;
			var mc = new FxDustTwinkle();
			var p = Scene.me.getPart(mc);
			p.setPos(pos.x, pos.y);
			p.timer = 10 + Std.random(30);
			p.weight = 0.05 + Math.random() * 0.05;
			p.frict = 0.98;
			p.vx = -Math.random();
			Filt.glow(p.root, 6, 1, 0x00FFFF);
			p.root.blendMode = flash.display.BlendMode.ADD;
			
		}
		if ( timer == 30 ) {
			kill();
		}
		
		
	}
	
	//


	
//{
}


























