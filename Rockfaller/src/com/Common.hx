package ;

enum TypeRock {
	TRClassic(?id:String);
	TRMagma;
	TRBubble;
	TRFreeze(v:Int);
	TRLoot(?id:String);
	TRCog(?v:Int);			// 0: A, 1: B, 2: C	=> UNUSED
	TRBlock;				//					=> UNUSED
	TRBonus(tb:TypeBonus);
	TRBlockBreakable(v:Int);
	TRHole(v:Int);
	TRBombCiv(n:Int);		// n turn before exploding
}

enum TypeBonus {
	TBBombHor;
	TBBombVert;
	TBBombPlus;
	TBBombCross;
	TBColor(?tr:TypeRock);
	TBBombMini;
}

enum TypeGP {
	TGWater;
	TGFreeze(v:Int);
	TGMagma;
	TGBombCiv(n:Int);
	TGPattern(ar:Array<{cX:Int, cY:Int, z:Int}>);
	TGGeyser(ar:Array<{y:Int, isLeft:Bool}>);
}

enum TypeGoal {
	TGScoring(v:Int);
	TGCollect(ar:Array<{tr:TypeRock, num:Int}>);
	TGGelatin(ar:Array<{cX:Int, cY:Int}>);
	#if version2_1
	TGMercury(numReq:Int, ar:Array<{cX:Int, cY:Int}>);
	#end
}

enum TypeBiome {
	TBClassic;
	TBMagma;
	TBFreeze;
	TBWater;
	TBCiv;
	TBCentEarth;
	TBNightmare;
	TBLimbo;
}

enum UserFlags {
	UFMusic;
	UFSFX;
	UFFirstPurchase;
	UFIgnoreNotif;
	UFFirstCommandSent;
	UFUseAllLives;
	UFBuyMoves;
	UFBuyLives;
	UFPlayMobile;
	UFEndLevel120;
	UFStartTwinoid;
	UFStartMobile;
	UFStartFacebook;
	UFHint;
	UFLootsSynced;
	UFEndLevel150;
}

typedef FriendData = {
	id					: Int,
	name 				: String,
	avatar				: Null<String>,
	levelMax			: Int,
	?highscore			: Array<Null<Int>>,
};

typedef InitData = {
	now					: Float,
	userData 			: UserData,
	levels				: Array<LevelInfo>,
	friends 			: Array<FriendData>,
	?mobileId			: Null<Int>,
	avatar				: Null<String>,
};

typedef UserData = {
	levelMax			: Int,
	life				: Int,
	lastGivingLife		: Float,
	gold				: Int,
	arHighScore			: Array<Null<Int>>,
	arAssets			: Array<{tr:TypeRock, num:Int}>,
	arLoots				: Array<{id:String, num:Int}>,
	pickaxe				: Int,
	tutoDone			: Array<Int>,
	flags				: haxe.EnumFlags<UserFlags>,
	requestsCount 		: Int,
}

typedef LevelInfo = {
	level				: Int,
	version				: Int,
	numMoves			: Int,
	arStepScore			: Array<Int>,
	type				: TypeGoal,
	arGrip				: Array<Int>,		// No more than 6
	arManualRocks		: Array<{tr:TypeRock, x:Int, y:Int}>,
	arGP				: Array<TypeGP>,
	arDeck				: Array<{t:TypeRock, v:Int}>,
	biome				: TypeBiome
}

enum TypeEndGame {
	TEGDefeat;
	TEGVictory;
	TEGGiveUp;
}

typedef GameData = {
	mobileID			: Null<Int>,
	level				: Int,
	version				: Int,
	date				: Null<Date>,
	success				: TypeEndGame,
	score				: Int,
	boosterUsed			: Int,
	addMovesUsed		: Int,
	movesUsed			: Int,
	arAssets			: Array<{tr:TypeRock, num:Int}>,
	arLoots				: Array<{id:String, num:Int}>
}

#if mBase
typedef UserLocalData = {
	mobileID			: Null<Int>,
	numGames			: Int,
	
	life				: Int,
	lastGivingLife		: Float,
	nextFullLife		: Null<Float>,
	
	userData			: UserData, // update locally
	gamesBuffer			: Array<GameData>
};
#end

typedef DataJSON = {
	var levels:Array<LevelInfo>;
}

class Common {
	public static var AR_ID_CLASSIC			: Array<String>		= ["crystal", "ground", "roc", "sand", "vegeta"];
	public static var AR_ID_COG				: Array<String>		= ["addMoveA", "addMoveB", "addMoveC"];
	
	public static var LENGTH_TOTAL_DECK		= 500;
	
	public static function VALIDATE_LEVEL(levelInfo:LevelInfo):Bool {
		if (levelInfo.numMoves <= 0)
			return false;
			
		for (i in 0...levelInfo.arStepScore.length) {
			if (levelInfo.arStepScore[i] <= 0)
				return false;
				
			if (i > 0
			&&	levelInfo.arStepScore[i] < levelInfo.arStepScore[i - 1])
				return false;
		}
		
		switch (levelInfo.type) {
			case TypeGoal.TGScoring(v) :
				if (v <= 0)
					return false;
			case TypeGoal.TGCollect(ar) :
				if (ar.length == 0)
					return false;
			case TypeGoal.TGGelatin(ar) :
				if (ar.length == 0)
					return false;
			#if version2_1
			case TypeGoal.TGMercury(num, ar) :
				if (num <= 0 || ar.length == 0)
					return false;
			#end
		}
		
		if (levelInfo.arDeck == null)
			return false;
		
		var t = 0;
		for (c in levelInfo.arDeck)
			t += c.v;
		
		if (t != Common.LENGTH_TOTAL_DECK)
			return false;
		
		return true;
	}
	
	public static function GET_HSID_FROM_TYPEROCK(tr:TypeRock, tb:TypeBiome):String {
		switch (tr) {
			case TypeRock.TRClassic(id) :
				if (id == null || id == "")
					throw "id of TRClassic is null or \"\" ";
				return id;
			case TypeRock.TRBlock :
				return "blocBreak";
				//switch (tb) {
					//case TypeBiome.TBClassic :	return "blocClassic";
					//case TypeBiome.TBFreeze :	return "blocIce";
					//case TypeBiome.TBMagma :	return "blocMagma";
					//case TypeBiome.TBWater :	return "blocWater";
					//case TypeBiome.TBCiv :		return "blocCiv";
					//case TypeBiome.TBCentEarth :return "blocCore";
				//}
			case TypeRock.TRBlockBreakable(v) :
				return "blocBreak0" + (3 - v);
			case TypeRock.TRHole(v) :
				return "hole" + v;
			case TypeRock.TRBonus(bonus) :
				switch (bonus) {
					case TypeBonus.TBBombMini :		return "bombMini";
					case TypeBonus.TBBombHor :		return "bombHoriz";
					case TypeBonus.TBBombVert :		return "bombVert";
					case TypeBonus.TBBombPlus :		return "bombPlus";
					case TypeBonus.TBBombCross :	return "bombCross";
					case TypeBonus.TBColor :		return "bombColor";
				}
			case TypeRock.TRMagma :
				return "lava";
			case TypeRock.TRBubble :
				return "bubble";
			case TypeRock.TRBombCiv(n) :
				return "bombeCiv/000" + n;
			case TypeRock.TRLoot(id) :
				return id;
			case TypeRock.TRCog(v) :
				return AR_ID_COG[v];
			case TypeRock.TRFreeze(v) :
				return "iceFront" + (2 - v);
		}
		
		throw "ERROR : NO HS ID FOR " + tr;
	}
	
	public static function SORT_AR_LEVEL(ar:Array<LevelInfo>):Array<LevelInfo> {
		var arOut = [];
		
		for (i in 0...ar.length) {
			if (arOut.length == 0)
				arOut.push(ar[i]);
			else {
				for (j in 0...arOut.length) {
					if (ar[i].level < arOut[j].level) {
						arOut.insert(j, ar[i]);
						break;
					}
					else if (j == arOut.length - 1)
						arOut.push(ar[i]);
				}
			}
		}
		
		return arOut;
	}
	
	public static function SET_FLAG(ud:UserData, f:UserFlags, ?set = true) {
		if(set)	ud.flags.set(f);
		else	ud.flags.unset(f);
		
		return ud;
	}
	
	public static function HAS_FLAG(ud:UserData, f:UserFlags):Bool {
		if (ud == null)
			throw "UserData is null";
		return ud.flags.has(f);
	}
}
