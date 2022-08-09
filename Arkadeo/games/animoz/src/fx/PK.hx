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
	var root:SP;
	var igpk:SecureInGamePrizeTokens;
	var square:Square;
	
	public function new(_igpk:SecureInGamePrizeTokens, square:Square)
	{
		super();	
		root = new SP();
		this.square = square;
		square.kdo = this;
		igpk = _igpk;
		
		var pos = square.getCenter();
		root.x = pos.x;
		root.y = pos.y;
		
		this.amount = igpk.amount.get();
		var pk = new ark.gfx.InGamePK();
		Game.me.dm.add(root, Game.DP_GROUND);
		pk.gotoAndStop(igpk.frame);
		pk.scaleX = pk.scaleY = 0.7;
		root.addChild( pk );
		new mt.fx.Flash(root);
	}
	
	public function trig() 
	{
		api.AKApi.takePrizeTokens(igpk);
		new fx.Score( root.x, root.y, amount);
		// FX
		fxTrig();
		kill();
	}
	
	public function splash() 
	{
		kill();
		fxVanish();
	}
	
	override function kill() 
	{
		square.kdo = null;
		root.parent.removeChild(root);
		super.kill();
	}
	
	// FX
	function fxVanish()
	{
		var p = new mt.fx.ShockWave(60, 120, 0.1);
		Game.me.dm.add(p.root, Game.DP_FX);
		p.root.blendMode = flash.display.BlendMode.ADD;
		p.setAlpha(0.5);
		p.setPos(root.x, root.y);
		p.curveIn(0.5);
	}
	
	function fxTrig() 
	{
		// COLOR BURST
		var max = 16;
		for ( i in 0...max ) 
		{
			var p = new mt.fx.Spinner( new gfx.Twinkle(), 2+Math.random()*16 );
			p.launch(i * 6.28 / max, Math.random() * 3, Math.random()*8);
			p.setPos(root.x, root.y);
			p.timer = 15 + Std.random(30);
			if( Std.random(8) == 0 ) p.timer += 30;
			p.fadeType = 2;
			p.frict = 0.99;
			Game.me.dm.add(p.root, Game.DP_FX);
			p.root.blendMode = flash.display.BlendMode.ADD;
			Col.setColor(p.root, Col.getRainbow2(Math.random()));
		}
	}
}
