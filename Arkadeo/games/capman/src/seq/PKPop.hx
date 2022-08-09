package seq;
import mt.bumdum9.Lib;
import Protocol;
import api.AKApi;
import api.AKProtocol;

/**
 * makes PK pop during the game
 */
using mt.Std;
class PKPop  extends mt.fx.Sequence {
	
	var pkPopped : api.AKConst;
	var pkToPop : api.AKConst;
	var pkArray:Array<SecureInGamePrizeTokens>; //"grappes" de PK a distribuer
	var pkArrayLength:Int;
	
	public function new() {
		super();
		
		pkPopped = AKApi.const(0);
		pkToPop = AKApi.const(0);
		pkArray = AKApi.getInGamePrizeTokens();
		pkArrayLength =  pkArray.length;
		
		for( x in pkArray ) {
			pkToPop.add( x.amount );
		}
	}

	override function update() {
		super.update();
		switch(AKApi.getGameMode()) {
			case GM_PROGRESSION :
				// repartition linéaire des PK au fil de la progression.
				var prog = 1 - (Game.me.coins / Game.me.coinMax);
				var popped = (pkPopped.get() / pkToPop.get());
				if( popped < prog ) {
					doPop();
				}
				if( popped == 1 ) kill();
			case GM_LEAGUE :
				if( pkArray.length > 0 && AKApi.getScore() > pkArray.first().score.get() ) {
					doPop();
				}
			default:
		}
	}
	
	function doPop() {
		if( pkPopped.get() >= pkToPop.get() ) return;
		//
		var igpk = pkArray.removeFirst();
		var pk = new ent.PK(igpk);
		pkPopped.add( igpk.amount );
	}
}
