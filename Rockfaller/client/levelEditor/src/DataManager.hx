package ;

import Protocol;

import Common;
import mod.*;

/**
 * ...
 * @author Tipyx
 */

class DataManager
{
	static var FIRST_INIT				: Bool			= true;
	
	public static var AR_LEVEL			: Array<LevelInfo>;
	
	static var COUNTER					: Int;
	
	public static var ON_UPDATE_JSON 	: Void->Void;
	
	public static function CREATE() {
		mt.net.Codec.requestUrl( "/api", ProtocolCom.DoGetLevelsForEditor(), onFromServer, onError );
	}
	
	public static function GET(numLevel:Int):LevelInfo {
		for (l in AR_LEVEL)
			if (l.level == numLevel)
				return l;
		
		var newLevel = null;
		if (LE.ME.actualLevel == null) {
			newLevel = {
				level				: numLevel,
				version				: 0,
				numMoves			: 0,
				arStepScore			: [0, 0, 0],
				type				: TypeGoal.TGScoring(0),
				arGrip				: [],
				arManualRocks		: [],
				arGP				: [],
				arDeck				: [],
				biome				: TypeBiome.TBClassic
			}
		}
		else {
			newLevel = {
				level				: numLevel,
				version				: 0,
				numMoves			: LE.ME.actualLevel.numMoves,
				arStepScore			: LE.ME.actualLevel.arStepScore.copy(),
				type				: LE.ME.actualLevel.type,
				arGrip				: LE.ME.actualLevel.arGrip.copy(),
				arManualRocks		: LE.ME.actualLevel.arManualRocks.copy(),
				arGP				: LE.ME.actualLevel.arGP.copy(),
				arDeck				: LE.ME.actualLevel.arDeck.copy(),
				biome				: LE.ME.actualLevel.biome
			}
		}
		
		AR_LEVEL.push(newLevel);
		
		return newLevel;
	}
	
	public static function SAVE(li:LevelInfo) {
		if (li != null) {
			mt.net.Codec.requestUrl( "/api", ProtocolCom.DoSaveLevel(li), onFromServer, onError );
			
			COUNTER = 0;
			ON_UPDATE_JSON();
		}
	}
	
	public static function TEST(num:Int) {
		mt.net.Codec.requestUrl( "/clientTest", ProtocolCom.DoTestLevel(num), onFromServer, onError );
	}
	
	public static function DELETE(num:Int, callBack:Void->Void) {
		mt.net.Codec.requestUrl( "/api", ProtocolCom.DoDeleteLevel(num), function(d) { onFromServer(d); callBack(); }, onError );
	}
	
	public static function MOVE(oldNum:Int, newNum:Int, callBack:Void->Void) {
		mt.net.Codec.requestUrl( "/api", ProtocolCom.DoMoveLevel(oldNum, newNum), function(d) { onFromServer(d); callBack(); }, onError );
	}
	
	static function onFromServer(d:ProtocolCom) {
		trace("onFromServer");
		trace(d);
		switch (d) {
			case ProtocolCom.SendLevels(ar) :
				AR_LEVEL = ar;
				if (FIRST_INIT) {
					FIRST_INIT = false;
					Main.ME.init();
				}
			case ProtocolCom.PCDone :
			default : 
				trace("not handled : " + d);
		}
	}
	
	static function onError(d:Dynamic) {
		trace("onError");
		trace(d);
	}
	
	public static function UPDATE() {
	}
}
