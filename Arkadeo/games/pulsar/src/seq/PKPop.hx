package seq;
import mt.bumdum9.Lib;
import Protocol;
import api.AKProtocol;
import api.AKApi;
/**
 * makes PK pop during the game
 */
using mt.Std;
class PKPop  extends mt.fx.Sequence {
	
	var pkPopped:Int;
	var pkToPop:Int;
	var pkList:Array<SecureInGamePrizeTokens>; //"grappes" de PK a distribuer
	
	public function new() {
		super();
		pkPopped = 0;
		pkToPop = 0;
		pkList  = AKApi.getInGamePrizeTokens();
		for(x in pkList) {
			pkToPop += x.amount.get();
		}
	}
	
	function doPop() {
		if(pkPopped >= pkToPop) return;
		
		var x = pkList.removeFirst();//removes first element of the array
		var pk = new fx.PK(x);
		pkPopped += x.amount.get();
	}
	
	override function update() {
		super.update();
		switch(AKApi.getGameMode()) {
			case GM_PROGRESSION:
				//repartition linéaire des PK au fil de la progression.
				var prog = getProgression();
				var popped = (pkPopped / pkToPop);
				if(popped < prog) {
					doPop();
				}
				if(popped == 1) kill();
				
			case GM_LEAGUE:
				if(pkList.length >0 && AKApi.getScore() > pkList.first().score.get()) {
					doPop();
				}
				
			default:	
		}
	}
	
	function getProgression():Float {
		return stykades.Run.me.progression;
	}
}
