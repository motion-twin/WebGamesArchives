import mt.bumdum9.Lib;
import Protocol;
import api.AKApi;
import api.AKProtocol;

/**
 * makes PK pop during the game
 */
using mt.Std;
class PKPop
{	
	var pkPopped:Int;
	var pkToPop:Int;
	var pkList:Array<SecureInGamePrizeTokens>; //"grappes" de PK a distribuer
	var pkListLength:Int;
	
	public function new() 
	{
		pkPopped = 0;
		pkToPop = 0;
		pkList  = AKApi.getInGamePrizeTokens();
		pkListLength =  pkList.length;
		for ( x in pkList ) 
		{
			pkToPop += x.amount.get();
		}
	}
	
	/**
	 * check in we can make pop some pk
	 * repartition linéaire des PK au fil de la progression.
	 */
	public function check(sq) 
	{
		switch(AKApi.getGameMode()) 
		{
			case GM_PROGRESSION:
				var prog = getProgression();
				var popped = pkPopped / pkToPop;
				if ( popped < prog ) 
				{
					doPop(sq);
				}
			case GM_LEAGUE:
				if ( pkList.length > 0 && AKApi.getScore() > pkList.first().score.get() ) 
				{
					doPop(sq);
				}
			default://prout
		}
	}
	
	function doPop(?sq) 
	{
		var igpk = pkList.removeFirst();
		var pk = new fx.PK(igpk, sq);
		pkPopped += igpk.amount.get();
	}
	
	function getProgression():Float
	{
		return AKApi.getScore() / Game.me.scoreObjective.get();
	}
}
