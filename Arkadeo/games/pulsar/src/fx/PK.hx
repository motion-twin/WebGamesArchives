package fx;
import Protocol;
import mt.bumdum9.Lib;
import api.AKProtocol;

/**
 * IN game PK
 * repompé des trucs de fx.Bonux
 */

class PK extends mt.fx.Fx
{
	var amount:Int;
	public var pk :SecureInGamePrizeTokens;
	var root:SP;
	
	public function new(_pk:SecureInGamePrizeTokens)
	{
		super();
		
		root = new SP();
		Game.me.dm.add(root, Game.DP_BADS);
		
		amount = _pk.amount.get();
		pk = _pk;
		
		var mc = new ark.gfx.InGamePK();
		mc.scaleX = mc.scaleY = 0.8;
		mc.gotoAndStop( _pk.frame );
		
		root.addChild( mc );
		
		do randomPos() while(getHeroDist() < 120);
		
		new mt.fx.Flash(root);
		#if sound
		Sfx.play(17, 0.75);
		#end
	}
	
	override function update() {
		super.update();
		/*collision*/
		if( getHeroDist() < 24 ) {
			#if sound
			Sfx.play(18, 2);
			#end
			api.AKApi.takePrizeTokens(pk);
			spawnScore(amount);
			kill();
		}
	}
	
	inline public function getHeroDist() {
		var dx = root.x - Game.me.hero.x;
		var dy = root.y - Game.me.hero.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	public function randomPos() {
		var ma = 36;
		root.x = ma + Game.me.seed.random(Game.WIDTH - 2 * ma);
		root.y = ma + Game.me.seed.random(Game.HEIGHT - 2 * ma);
	}
	
	override function kill() {
		root.parent.removeChild(root);
		super.kill();
	}
	
	/**
	 * repiqué sur le spawnscore des bads
	 * @param	score
	 */
	public function spawnScore(score:Int) {
		var mc = new SP();
		var a = Std.string(score).split("");
		var px = 0;
		for( char in a ) {
			var el = new EL();
			el.goto(char.charCodeAt(0) - 48, "num",0,0);
			el.x = px;
			mc.addChild(el);
			px += char == "1"?2:4;
		}
		
		Game.me.dm.add(mc, Game.DP_SCORE);
		var p = new mt.fx.Part(mc);
		p.vy = -4;
		p.weight = 0.4;
		p.timer = 40;
		p.setPos(root.x, root.y);
		p.fitPix = true;
		p.setGround(p.y, 1.0, 0.5);
		Filt.glow(p.root, 2, 4, 0);
		
		// FX
		var sp = new SP();
		sp.graphics.beginFill(0xFFFFFF);
		sp.graphics.drawCircle(0, 0, 8);
		sp.x = root.x;
		sp.y = root.y-4;
		
		var e = new mt.fx.Vanish(sp, 8, 8, false);
		e.setFadeScale(1, 1);
		Game.me.dm.add(sp, Game.DP_UFX);		
	}
	
}
