package ent;
import Protocol;
import mt.bumdum9.Lib;
import api.AKProtocol;

/**
 * ...
 */

class PK extends Ent
{
	var igpk : SecureInGamePrizeTokens;
	var amount:Int;
	
	public function new( igpk : SecureInGamePrizeTokens )
	{
		super();
		this.igpk = igpk;
		this.amount = igpk.amount.get();
		var pk = new ark.gfx.InGamePK();
		pk.scaleX = pk.scaleY = 0.5;
		
		pk.gotoAndStop( igpk.frame );
		
		root.addChild( pk );
		var sq = Game.me.getFreeRandomSquare();
		this.setSquare(sq.x, sq.y);
		new mt.fx.Flash(root);
		
	}
	
	override function update() {
		super.update();
		
		/*collision*/
		var h = Game.me.hero;
		if( !h.dead && h.step != JUMPING ){
			var dist = getDistTo(h);
			if( dist < ray + 6 ) {
				/*inc PK counter*/
				api.AKApi.takePrizeTokens(igpk);
				kill();
			}
		}
	}
	
	
	override public function kill() {
		/* small "1 UP" */
		var mc = Cs.getTinyScore(amount);
		Level.me.dm.add(mc, Level.DP_SCORE);
		var p = new mt.fx.Part(mc);

		p.vy = -5;
		p.frict = 0.75;
		p.timer = 50;
		p.fadeLimit = 5;
		p.fadeType = 2;
		p.fitPix = true;
		p.setPos(x, y);
		p.setScale(0.5);
			
		var c = Std.random(200);
		//var c = (n - Cs.SCORE_BALL.get()) / (Cs.SCORE_BALL_MAX.get() - Cs.SCORE_BALL.get());
		//Col.setColor(p.root, Col.hsl2Rgb(c*0.8+0.1,1.0,0.6));
		Filt.glow(p.root, 2, 8, 0);
		
		super.kill();
	}
	
}
