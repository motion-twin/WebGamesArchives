package com;

import mt.MLib;
import com.Protocol;
import Data;

class GameData {
	public static var DEFAULT_HOTEL_NAME = "MONSTERHOTEL";
	public static var HOTEL_NAME_MAX_LENGTH = 24;
	public static var MAX_LOVE_0 = 20;
	public static var MAX_LOVE_1 = 40;
	public static var MAX_LOVE_2 = 70;
	public static var VISIT_LOVE_1 = 5;
	public static var VISIT_LOVE_2 = 10;
	public static var CLIENT_CALL = 2;
	public static var BASE_DAILY_QUESTS = 0;
	public static var LUNCHBOX_GOLD = 5000;
	public static var DAILY_QUEST_REGEN = DateTools.hours(3);
	public static var LOGIN_EVENT_CD = DateTools.minutes(3);

	public static var START_GEMS = 10;
	public static var START_LOVE = 15;

	public static var ISOLATION_POWER = 2;
	public static var LINE_POWER = 2;
	public static var COL_POWER = 2;
	public static var ZONE_EFFECT_LIMIT = 4;
	public static var LOVE_POWER_BASE = 2;
	public static var NEIGHBOUR_POWER = 3;
	public static var CUSTOMIZATION_POWER = 1;
	public static var BAR_POWER = 3;
	public static var RESTAURANT_POWER = 5;
	public static var CANNIBAL_POWER = 5;
	public static var PORING_CANNIBAL_POWER = 10;
	public static var PRESENCE_OF_LIKE = 4;
	public static var PRESENCE_OF_DISLIKE = -5;
	public static var PRESENCE_OF_DIRT = -4;
	public static var ABSENCE_OF_DISLIKE = 2;
	public static var LIKER_POWER = 5; // base happiness for c_likers
	public static var ANNOYING_POWER = 3;
	public static var SOCIABLE_POWER = 2;
	public static var ANTISOCIAL_POWER = -3;
	public static var ALCOHOLIC_POWER = 2;
	public static var AESTHETE_POWER = 3;
	public static var DECOHATER_POWER = -5;
	public static var SPECIAL_REQUEST_BONUS = 10;
	public static var SPECIAL_REQUEST_MALUS = -40;
	public static var BANK_BONUS = 5;

	public static var SOCIAL_GEMS = 1;
	public static var SOCIAL_GOLD = 100;
	public static var SOCIAL_GOLD_PER_VISITOR = 25;
	public static var FRIEND_REQUEST_DELAY_MIN = DateTools.days(0.9);
	public static var FRIEND_REQUEST_DELAY_MAX = DateTools.days(2);

	// Durations/times
	public static var CLIENT_SKIP_MIN_DURATION = DateTools.seconds(10);
	public static var LAUNDRY_DURATION = DateTools.minutes(1.5);
	public static var LAUNDRY_DURATION_BOOSTED = DateTools.seconds(0);
	public static var RECYCLER_DURATION = DateTools.hours(12);
	public static var EXPLOSION_WARNING = DateTools.seconds(6);
	public static var BOOST_DURATION = DateTools.minutes(2);
	public static var VIP_CALL_DURATION = DateTools.hours(1);

	public static var TRASH_DURATION = DateTools.minutes(15);
	public static var TRASH_DURATION_BOOSTED = DateTools.seconds(30);
	public static var BAR_DURATION = DateTools.seconds(0);
	public static var GEM_CLIENT_DELAY = DateTools.hours(12);
	//public static var HALLOWEEN_CLIENT_DELAY = DateTools.hours(1);
	public static var CHRISTMAS_CLIENT_DELAY = DateTools.hours(1);
	public static var VIP_CLIENTS_CD = 17;
	public static var LOVE_CD = DateTools.hours(24);

	public static var LONG_ABSENCE = DateTools.days(5);
	public static var ABSENCE_GOLD = 30000;
	public static var ABSENCE_GEMS = 5;

	public static var DAILY_LOVE = 5;
	public static var DAILY_GOLD = 5000;

	public static function getVipCooldown(h:SHotel) : Float {
		var maxedVips = h.getStat("vip");
		return if( maxedVips<=5 ) DateTools.minutes(5);
			else if( maxedVips<=10 ) DateTools.minutes(15);
			else if( maxedVips<=20 ) DateTools.minutes(30);
			else if( maxedVips<=30 ) DateTools.minutes(45);
			else if( maxedVips<=70 ) DateTools.minutes(3);
			else DateTools.hours(6);
	}

	public static function getRoomConstructionDelay(t:RoomType, nbOfType:Int) {
		#if trailer
		return 0.;
		#end
		var short = DateTools.seconds(5);
		var long = DateTools.minutes(5);
		return switch( t ) {
			case R_Bedroom :
				short;

			case R_Bank, R_VipCall, R_FillerStructs, R_CustoRecycler :
				0;

			case R_Laundry :
				nbOfType==0 ? 0 : short;

			case R_Bar, R_StockBeer, R_StockSoap, R_Library :
				nbOfType==0 ? 0 : long;

			default :
				nbOfType==0 ? short : long;
		}
	}

	//public static function getNextClientDelay(curQueue:Int) {
		//return switch( curQueue ) {
			//case 0 : DateTools.seconds(20);
			//case 1 : DateTools.seconds(30);
			//case 2 : DateTools.seconds(40);
			//case 3 : DateTools.minutes(1);
			//case 4 : DateTools.minutes(5);
			//case 5 : DateTools.minutes(15);
			//case 6 : DateTools.minutes(45);
			//case 7 : DateTools.hours(2);
			//case 8 : DateTools.hours(6);
			//default : DateTools.minutes(60);
		//}
	//}

	public static function getHappinessTrigger(c:ClientType, h:SHotel) : Int {
		return h.getMaxHappiness()-10;
	}

	public static function getClientStayDuration(t:ClientType, shotel:SHotel) : Float {
		if( shotel.level<=0 && t!=C_Inspector )
			return DateTools.seconds(25);

		#if( !connected && debug )
		return DateTools.hours(5);
		#end

		switch( t ) {
			case C_MobSpawner, C_Spawnling :
				return DateTools.seconds(20);

			case C_Inspector :
				var data = DataTools.getBoss(shotel.level);
				return DateTools.minutes( data==null ? 5 : data.duration );

			default :
				var l = MLib.max(shotel.level, switch( shotel.countRooms(R_Bedroom,false) ) {
					case 1,2,3,4 : 1;
					case 5 : 2;
					case 6 : 3;
					case 7 : 4;
					case 8 : 8;
					case 9 : 10;
					case 10,11,12 : 12;
					case 13,14,15,16 : 15;
					case 17,18,19 : 19;
					default : 99;
				});

				var hostedClients = shotel.getStat("client");
				l = MLib.max( l,
					if( hostedClients>=3000 ) 25;
					else if( hostedClients>=2000 ) 20;
					else if( hostedClients>=1750 ) 15;
					else if( hostedClients>=1250 ) 13;
					else if( hostedClients>=800 ) 11;
					else if( hostedClients>=500 ) 10;
					else 0
				);

				return switch( l ) {
					case 1 : DateTools.seconds(50);
					case 2 : DateTools.minutes(1.1);
					case 3 : DateTools.minutes(1.5);
					case 4,5 : DateTools.minutes(1.75);
					case 6,7 : DateTools.minutes(2);
					case 8,9 : DateTools.minutes(4);
					case 10 : DateTools.minutes(10);
					case 11,12 : DateTools.minutes(20);
					case 13,14,15 : DateTools.minutes(30);
					case 17,18 : DateTools.minutes(40);
					case 19,20,21,22 : DateTools.minutes(50);
					default : DateTools.minutes(60);
				}
		}

		//switch( t ) {
			//case C_Spawnling :
				//return DateTools.minutes(1);
//
			//default :
				//var nd =
					//switch( nbBedrooms ) {
						//case 1,2,3,4,5 : DateTools.seconds(40);
						//case 6,7 : DateTools.minutes(1.2);
						//case 8,9 : DateTools.minutes(2.5);
						//case 10,11 : DateTools.minutes(5);
						//case 12,13 : DateTools.minutes(10);
						//case 14,15 : DateTools.minutes(20);
						//case 16,17 : DateTools.minutes(45);
						//case 18,19,20 : DateTools.hours(1);
						//case 21,22,23 : DateTools.hours(2);
						//default : DateTools.hours(3);
					//}
//
				//var ld = switch( level ) {
					//case 1,2,3 : DateTools.seconds(40);
					//case 4,5 : DateTools.minutes(1.2);
					//case 6,7 : DateTools.minutes(2.5);
					//case 8,9,10 : DateTools.minutes(5);
					//case 11,12 : DateTools.minutes(10);
					//case 13,14 : DateTools.minutes(20);
					//case 15,16 : DateTools.minutes(45);
					//case 17,18 : DateTools.hours(1);
					//case 19,20 : DateTools.hours(2);
					//default : DateTools.hours(3);
				//}
//
				//return MLib.fmax(ld,nd);
		//}
	}

	public static function getRepairDuration(dmg:Int, level:Int) {
		return switch( dmg ) {
			case 1 : DateTools.seconds(15);
			default : DateTools.minutes(3);
		}
		//return switch( level ) {
			//case 0 :
				//switch( dmg ) {
					//case 1 : DateTools.seconds(15);
					//case 2 : DateTools.minutes(1);
					//default : 0;
				//}
//
			//case 1 :
				//switch( dmg ) {
					//case 1 : DateTools.seconds(45);
					//case 2 : DateTools.minutes(3);
					//default : 0;
				//}
//
			//case 2 :
				//switch( dmg ) {
					//case 1 : DateTools.minutes(2);
					//case 2 : DateTools.minutes(10);
					//default : 0;
				//}
//
			//case 3 :
				//switch( dmg ) {
					//case 1 : DateTools.minutes(3);
					//case 2 : DateTools.minutes(20);
					//default : 0;
				//}
//
			//default : DateTools.minutes(5);
		//}
	}



	// Money & costs
	public static var START_MONEY = 3500;
	public static var RANDOM_CUSTOM_COST_ANY = 10;
	public static var CUSTO_RECYCLING_COST = 5;
	//public static var RANDOM_CUSTOM_COST_CAT = 8;
	public static var VIP_MONEY = 3000;
	public static var RICH_MONEY = 500;
	public static var SPAWNLING_MONEY = 1000;
	public static var GOLD_EXPLOSION_MONEY = 150;
	//public static var UTILITY_ROOM_TIP = 5;


	public static function getStockMax(t:RoomType, level:Int) : Int {
		return switch( t ) {
			case R_StockBoost: 1+level;
			case R_StockPaper: 4;
			case R_StockBeer: 4;
			case R_StockSoap: 6;
			default : 1;
		}
	}

	public static function getStockRefillDuration(t:RoomType, boosted:Bool) {
		return switch( t ) {
			case R_StockBoost :
				//#if debug
				//DateTools.seconds(5);
				//#else
				DateTools.minutes(45);
				//#end

			default :
				if( boosted )
					DateTools.seconds(10);
				else
					DateTools.minutes(5);
		}
	}

	public static function getRoomUpgradeCost(t:RoomType, currentLevel:Int) {
		return switch( t ) {
			//case R_Lobby :
				//if( currentLevel==0 )
					//0;
				//else if( currentLevel<8 )
					//currentLevel*100000;
				//else
					//-1;

			default : -1;
		}
	}

	public static function isCustomizeItem(i:Item) : Bool {
		return switch( i ) {
			case I_Bath(_), I_Bed(_), I_Ceil(_), I_Furn(_), I_Wall(_), I_Color(_), I_Texture(_) : true;
			case I_Cold, I_Heat, I_Noise, I_Odor, I_Light : false;
			case I_Gem, I_Money(_), I_LunchBoxAll, I_LunchBoxCusto : false;
			case I_EventGift(_) : false;
		}
	}

	public static function getSkipAllCost(nbClients:Int) {
		return nbClients;
	}

	public static function getLaundryPayment(h:Int, maxHappiness:Int) {
		return MLib.round( 100 * MLib.clamp(h, 0, maxHappiness) / maxHappiness);
	}


	public static function getItemCost(i:Item) : {n:Int, cost:Int, isGold:Bool} {
		return switch(i) {
			case I_Cold, I_Heat, I_Noise, I_Odor, I_Light :
				{ n:3, cost:1, isGold:false }

			case I_Money(_), I_Gem, I_LunchBoxAll, I_LunchBoxCusto, I_EventGift(_) :
				{ n:0, cost:0, isGold:false }

			case I_Bed(_), I_Bath(_), I_Ceil(_), I_Furn(_), I_Wall(_), I_Color(_), I_Texture(_) :
				var m = switch( DataTools.getCustomItemRarity(i) ) {
					case Data.RarityKind.Common : 25000;
					case Data.RarityKind.Uncommon : 50000;
					case Data.RarityKind.Rare : 250000;
					case Data.RarityKind.Never : 250000;
				}
				{ n:m>0?1:0, cost:m, isGold:true}
		}
	}

	public static function getRoomCost(t:RoomType, nbOfType:Int) : Int {
		#if trailer
		return 5;
		#end
		return switch( t ) {
			case R_Bedroom :
				var n = MLib.max(0, nbOfType-4);
				var p = 3500 + Math.pow(n, 2.15)*1000;

				p = p>=10000 ? MLib.round(p/5000)*5000 : MLib.round(p/500)*500;
				//p = MLib.fmin(p, 850000);
				Std.int(p);

			case R_Lobby : -1;

			case R_Bank : nbOfType==0 ? 0 : -1;

			case R_VipCall : nbOfType==0 ? 0 : -1;

			case R_Trash :
				switch( nbOfType ) {
					case 0 : 20000;
					case 1 : 150000;
					case 2 : 500000;
					default : -1;
				}

			case R_Bar :
				switch( nbOfType ) {
					case 0 : 0;
					case 1 : 150000;
					case 2 : 350000;
					case 3 : 750000;
					default : -1;
				}


			case R_Laundry :
				switch( nbOfType ) {
					case 0 : 0;
					case 1 : 2500;
					case 2 : 5000;
					case 3 : 20000;
					default : 50000;
				}

			case R_ClientRecycler :
				switch( nbOfType ) {
					case 0 : 125000;
					case 1 : 500000;
					default : -1;
				}

			case R_StockPaper, R_StockSoap, R_StockBeer :
				switch( nbOfType ) {
					case 0 : 0;
					case 1 : 45000;
					case 2 : 250000;
					default : 500000;
				}

			case R_StockBoost :
				switch( nbOfType ) {
					case 0 : 0;
					case 1 : 2000000;
					case 2 : 5000000;
					default : -1;
				}

			case R_LevelUp :
				-1;

			case R_Library :
				switch( nbOfType ) {
					case 0 : 0;
					case 1 : 20000;
					case 2 : 100000;
					case 3 : 300000;
					default : -1;
				}

			case R_FillerStructs :
				nbOfType * 3500;

			case R_CustoRecycler : nbOfType==0 ? 0 : -1;
		}
	}

	public static function getRoomResellValue(r:com.SRoom, nbOfType:Int, fullPrice:Bool) {
		var base = getRoomCost(r.type, nbOfType-1);
		switch( r.type) {
			case R_Bedroom :
				for( l in 1...r.level+1 )
					base += getRoomUpgradeCost(r.type, l-1);

			default :
		}
		return Std.int( base  * (fullPrice?1:0.75) );
	}


	// Level ups
	public static function getLevelUpDuration(currentLevel:Int) {
		return switch( currentLevel ) {
			case 0,1,2,3,4 : DateTools.seconds(10);
			case 5,6,7,8,9,10 : DateTools.minutes(10);
			default : DateTools.hours(8);
		}
	}
	public static function getLevelUpCost(currentLevel:Int) {
		return switch( currentLevel ) {
			case 0 : 0;
			case 1 : 2500;
			case 2 : 5000;
			default : 5000 + (currentLevel-2)*2500;
		}
	}
	//public static function getLevelUpXp(currentLevel:Int) {
		//return switch( currentLevel ) {
			//case 1 : 50;
			////case 1 : 18;
			//case 2 : 80;
			//case 3 : 100;
			//default :
				//var xp = 100 + Math.pow(currentLevel-4, 2.3) * 4;
				//MLib.round(xp/5)*5;
		//}
	//}

	//public static function getLevelUpGems(currentLevel:Int) {
		//return switch( currentLevel ) {
			//case 3 : 1;
			//default : 0;
		//}
	//}


	public static var FEATURES : Map<String,Int> = [
		"inspect" => 0,
		"build" => 0,
		"buildTip" => 0,
		"levelUp" => 0,
		"booster" => 0,
		"quests" => 0,
		"gems" => 0,
		"savings" => 0,
		"premium" => 0,

		"destroy" => 2,
		"vip" => 2,
		"items" => 4,
		"custom" => 5,
		"inbox" => 5,
		"roomReplace" => 5,
		"love" => 6,
		"bigDamages" => 10,
		"miniGame" => 10,
		"happy35" => 10,
		"cold" => 12,
		"happy40" => 15,
		"happy45" => 20,
		"happy50" => 25,
	];

	public static function getFeatureUnlockLevel(k:String) {
		if( FEATURES.exists(k) )
			return FEATURES.get(k);
		else
			return 0;
	}


	public static function clientUnlocked(level:Int, t:ClientType) : Bool {
		return level>=switch( t ) {
			case C_Spawnling : 999;
			case C_Custom : 999;
			case C_Halloween, C_Christmas : 999;

			case C_Liker : 0;
			case C_Neighbour : 0;
			case C_Inspector : 0;

			case C_HappyColumn : 2;
			case C_HappyLine : 3;
			case C_Gifter : 4;
			case C_Gem : 7;
			case C_Emitter : 9;
			case C_Plant : 11;
			case C_Rich : 13;
			case C_Bomb : 14;
			case C_Dragon : 15;
			case C_MoneyGiver : 16;
			case C_Repairer : 17;
			case C_Vampire : 18;
			case C_MobSpawner : 19;
			case C_JoyBomb : 21;
			case C_Disliker : 22;
		}
	}

	public static function roomUnlocked(shotel:SHotel, level:Int, t:RoomType) : Bool {
		return switch( t ) {
			case R_Lobby : false;
			case R_LevelUp : false;

			case R_Bedroom : level>=0;

			case R_Bar, R_StockBeer : level>=1;
			case R_Laundry : level>=2;
			case R_StockSoap : level>=3;
			case R_StockPaper : level>=7;
			case R_Trash : level>=8;

			case R_ClientRecycler : level>=12;
			case R_Library : level>=11;
			case R_StockBoost : level>=20;

			case R_FillerStructs : level>=5;

			case R_CustoRecycler : shotel.hasPremiumUpgrade(Data.PremiumKind.CustoRecycler);
			case R_Bank : shotel.hasPremiumUpgrade(Data.PremiumKind.Bank1);
			case R_VipCall : shotel.hasPremiumUpgrade(Data.PremiumKind.VipRoom1);
		}
	}

}
