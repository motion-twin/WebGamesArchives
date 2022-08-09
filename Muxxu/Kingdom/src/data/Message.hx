package data;

enum CityMessage {
	MCityConsume( food : Int, gold : Int );
	MCityProduce( rid : String, qty : Int );
	MCityRecruit( pid : String );
	MCityMoreActions( n : Int );
	MCityStartBuild( bid : String, level : Int );
	MCityBuildProgress( n : Int );
	MCityBuildWasted;
	MCityCancelBuild( bid : String, level : Int );
	MCityTerminateBuild( bid : String, level : Int );
	MCityGridReset;
	MCityNewPeople;
	MCityNewSoldiers( n : Int );
	MCityStarve( pid : String );
	MCityNoCasern;
	MCityDesert( n : Int );
	MCityGather( general : String, cid : Int, rid : String, qty : Int, taxes : Int );
	MCityConvert( rid : String, rid2 : String, n : Int );
	MCityNoRecruit;
	MCityConvert2( rid : String, n : Int, rid2 : String, n2 : Int );
	MCityLost( rid : String, n : Int );
	MCityDeficit( n : Int );
}

enum MapMessage {
	MMapControlNoFight( uid : Int, cid : Int, general : String );
	MMapBattleWon( uid : Int, cid : Int, general : String );
	MMapRevoltStopped( uid : Int, cid : Int );
	MMapKingdomDestroy( kid : Int, uid : Int, cid : Int );
	MMapUserPromote( uid : Int, tid : String );
	MMapNewPlace( cid : Int, rid : String );
	MMapKingdomDecadent( tid : String, uid : Int, cid : Int );
	MMapKingDied( tid : String, uid : Int, cid : Int, age : Int );
	MMapNewUser( uid : Int, cid : Int );
	MMapRevolt( uid : Int, kid : Int );
	MMapCityName( uid : Int, cid : Int, old : String, name : String );
}

enum UserMessage {
	MUserWelcome( cid : Int );
	MUserKingDefeat( kid : Int, defeatedBy : Int );
	MUserLostKingdom( kid : Int );
	MUserNewKing( kid : Int );
	MUserLostPlace( cid : Int, uid : Int );
	MUserWinPlace( cid : Int, oldId : Int );
	MUserPromote( tid : String );
	MUserDecadent;
	MUserHealth( h : Int );
	MUserAttack( bid : Int, cid : Int, g : String, uid : Int );
	MUserAttacked( bid : Int, cid : Int, g : String, uid : Int );
	MUserAttackedAt( bid : Int, cid : Int, g : String, uid : Int );
	MUserLostGeneral( bid : Int, cid : Int, g : String );
	MUserBattleReport( bid : Int, cid : Int, won : Bool );
	MUserRevolt( uid : Int, cid : Int, bid : Null<Int> );
	MUserStartRevolt( uid : Int, cid : Int, bid : Null<Int> );
	MUserGeneralReput( g : String, delta : Int );
	MDiploCross( uid : Int );
	MDiploNoCross( uid : Int );
	MDiploFriend( uid : Int );
	MDiploEnemy( uid : Int );
	MDiploNeutral( uid : Int );
	MDiploTaxChange( uid : Int );
	MDiploTaxCollect( uid : Int, tl : Array<{ r : String, n : Int, w : Int }> );
	MDiploTaxCollected( uid : Int, tl : Array<{ r : String, n : Int, w : Int }> );
	MDiploRecolt( uid : Int );
	MDiploNoRecolt( uid : Int );
	MUserProvoked( bid : Int, cid : Int, g : String, g2 : String, uid : Int );
	MUserProvoke( bid : Int, cid : Int, g : String, count : Int );
	MUserRevoltCancel( uid : Int, cid : Int );
	MUserVassalNewPlace( cid : Int, uid : Int );
	MUserLostDeficit( cid : Int );
	MUserNewVassal( uid : Int, cid : Int );
	MUserVassalDie( uid : Int, count : Int );
}
