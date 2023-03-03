package db;
import Common;
import mt.db.Types;
import db.User;

class GhostReward extends neko.db.Object {

	static var RELATIONS = function(){
		return [
			{ key : "userId",	prop : "user",	manager : User.manager, lock : false }
		];
	}

	static var TABLE_IDS = ["rewardKey","userId","day"];

	public static var manager = new GhostRewardsManager();

	public var rewardKey	: SEncoded;
	public var value		: SInt;
	public var day			: SInt;
	
	public var userId(default, null)	: SInt;
	public var user(dynamic, dynamic)	: User;

	public function new() {
		super();
		rewardKey = 0;
		value = 0;
		day = -1;
		/*
			-1	= déjà gagnées
			0	= critical (toujours gagnée)
			1+	= daily
		*/
	}
	
	public static function gainByUser( r:GhostRewardData, user:User, ?nb=1 ) {
		var map = user.getMapForDisplay();
		if( map == null )
			throw "Can't win rewards when user is dead !"; // TODO : attention, à tester !!

		var day = if( r.critical ) 0 else map.days;
		var gr = manager.getWithKeys( {rewardKey:r.ikey, userId:user.id, day:day} );
		if( gr == null ) {
			gr = new GhostReward();
			gr.user = user;
			gr.rewardKey = r.ikey;
			gr.value = nb;
			gr.day = day;
			gr.insert();
		} else {
			gr.value += nb;
			gr.day = day;
			gr.update();
		}
		return gr;
	}

	public static function specialGain( r:GhostRewardData, u:User, ?nb = 1 ) { // peut être gagné à tout moment (même à la mort)
		mt.db.Twinoid.goals.increment(u, r.key, nb);
		/*
		var gr = manager.getWithKeys( {rewardKey:r.ikey, userId:u.id, day:-1} );
		if( gr == null ) {
			gr = new GhostReward();
			gr.user = u;
			gr.rewardKey = r.ikey;
			gr.value = nb;
			gr.day = -1;
			gr.insert();
		} else {
			gr.value += nb;
			gr.update();
		}
		return gr;
		*/
	}
	
	public static function gain( r:GhostRewardData, ?u:User, ?nb:Int ) {
		if( u == null ) u = App.user;
		return gainByUser(r, u, nb);
	}

	public static function lose( r:GhostRewardData, ?u:User ) {
		if( u == null )
			u = App.user;
		
		var gr = manager.getWithKeys( {rewardKey:r.ikey, userId:u.id, day:0} );
		if( gr != null )
			gr.delete();
	}
	
	public function getInfo() {
		return GR.LIST.get( mt.db.Id.decode(rewardKey) );
	}

	public static function filterCustomMapRewards(rlist:Array<GhostReward>, seed:Int, lossRatio:Float) {
		var rseed = new mt.Rand(0);
		rseed.initSeed(seed);
		var won = new Array();
		var lost = new Array();
		for( r in rlist ) {
			if( r.getInfo().rare )
				lost.push(r);
			else
				won.push(r);
		}
		var max = Math.floor(won.length * lossRatio);
		while( won.length > max ) {
			var r = won.splice(rseed.random(won.length), 1)[0];
			lost.push(r);
		}
		return { won : won, lost : lost };
	}
}

class GhostRewardsManager extends neko.db.Manager<GhostReward> {

	public function new() {
		super( GhostReward );
	}
	
	private function sortList(list:List<GhostReward>) {
		var a = Lambda.array( list );
		// fusion des values dupliquées
		var n = 0;
		while( n < a.length ) {
			var j = n + 1;
			while( j < a.length ) {
				if( a[j].rewardKey == a[n].rewardKey ) {
					a[n].value += a[j].value;
					a.splice(j,1);
					j--;
				}
				j++;
			}
			n++;
		}
		// hash des rewards rares
		var rareHash = new IntHash();
		for( gr in a )
			rareHash.set(gr.rewardKey, gr.getInfo().rare);
		// tri
		a.sort( function(a,b) {
			if( a.day > b.day ) return -1;
			if( a.day < b.day ) return 1;
			if( rareHash.get(a.rewardKey) && !rareHash.get(b.rewardKey) ) return -1;
			if( !rareHash.get(a.rewardKey) && rareHash.get(b.rewardKey) ) return 1;
			if( a.value > b.value ) return -1;
			if( a.value < b.value ) return 1;
			return 0;
		});
		return a;
	}

	public function getDistinctByUser(user:User) {
		return objects( selectReadOnly("userId="+user.id+" ORDER BY rewardKey ASC, day ASC"), false );
	}

	public function getNewRewardsByUser(u:User, cadaver:db.Cadaver/*day:Int*/) {
		var sql : String;
		var day = cadaver.mapDay;
		var userPoints = u.survivalPoints - cadaver.getSurvivalPoints();
		if( u.map != null && !u.map.isBig() && u.map.hasMod("RNE_REWARD_RESTRICTED") &&  userPoints >= Version.getVar('minXp') && day < Const.get.MinSurvivalReward ) {
			day = 1;
		} else if( day >= Const.get.RewardsDailyRuleLimit ) day = 99999;
		return sortList( objects( selectReadOnly("userId="+u.id+" AND value>0 AND day>=0 AND day < "+day), false ) );
	}
	
	public function getMissedRewardsByUser(u:User, cadaver:db.Cadaver/*day:Int*/) {
		var userPoints = u.survivalPoints - cadaver.getSurvivalPoints();
		var day = cadaver.mapDay;
		if( u.map != null && !u.map.isBig() && u.map.hasMod("RNE_REWARD_RESTRICTED") && userPoints >= Version.getVar('minXp') && day < Const.get.MinSurvivalReward ) {
			return sortList( objects( selectReadOnly("userId=" + u.id + " AND value>0 AND day>0"), false ) );//TODO tester
		} else {
			if( day >= Const.get.RewardsDailyRuleLimit ) day = 99999;
			return sortList( objects( selectReadOnly("userId=" + u.id + " AND value>0 AND day=" + day), false ) );
		}
	}
	
	/**
	 * Fonction appelée lorsque le cadavre est validé par le joueur après sa mort.
	 */
	public function validateGame(u:User, cadaver:Cadaver, ?rewardDay = -1) {
		if( cadaver.custom && !cadaver.mapFlag("fullReward") ) { // villes privées
			var rlist = getNewRewardsByUser(u, cadaver);
			var filter = GhostReward.filterCustomMapRewards(rlist, cadaver.id, 0.5);
			var lostKeys = new List();
			for( r in filter.lost )
				lostKeys.add( r.rewardKey );
			
			if( lostKeys.length > 0 )
				execute("DELETE FROM GhostReward WHERE day > -1 AND userId=" + u.id + " AND rewardKey IN (" + lostKeys.join(",") + ")");
		}
		//
		var userPoints = u.survivalPoints - cadaver.getSurvivalPoints();
		var isRNE = cadaver.mapFlag("RNE");
		var day = cadaver.mapDay;
		if( db.GameMod.hasMod("RNE_REWARD_RESTRICTED") && isRNE && userPoints >= Version.getVar('minXp') && day < Const.get.MinSurvivalReward ) {
			day = 1;
		} else if ( day >= Const.get.RewardsDailyRuleLimit ) {
			day = 99999;
		}
		
		var sums = results("SELECT rewardKey, SUM(value) AS total FROM GhostReward WHERE userId="+u.id+" AND day > -1 AND day < "+day+" GROUP BY rewardKey");
		var sqlValues = new List();
		for( s in sums ) {
			try mt.db.Twinoid.goals.increment(u, GR.getById( s.rewardKey ).key, s.total) catch(e:Dynamic) {}
			sqlValues.add( "(" + s.rewardKey + ", " + u.id + ", " + rewardDay + ", " + s.total + ")" );
		}
		
		if( sqlValues.length > 0 ) {
			execute("INSERT INTO GhostReward (rewardKey, userId, day, value) VALUES " + sqlValues.join(",") + " ON DUPLICATE KEY UPDATE value=value+VALUES(value)" );
			clearGame(u);
		}
	}

	public function clearGame(u:User) {
		execute("DELETE FROM GhostReward WHERE day > -1 AND userId="+u.id);
	}

	public function countInThisGame( userId:Int, r:GhostRewardData ) {
		var rkey = Std.string(r.ikey);
		return execute("SELECT SUM(value) FROM GhostReward WHERE userId="+userId+" AND rewardKey="+quote(rkey)+" AND day>=0 AND value>0").getIntResult(0);
	}

	public function gainForAll(map:db.Map, r:GhostRewardData) {
		execute("INSERT INTO GhostReward (rewardKey,userId,value,day) SELECT "+quote(Std.string(r.ikey))+",id,1,"+map.days+" FROM User WHERE mapId="+map.id+" AND dead=0 ON DUPLICATE KEY UPDATE value=value+1, day=VALUES(day);");
	}

	public function gainForList(uids:List<Int>, r:GhostRewardData, increment:Int=1) {
		for( uid in uids ) {
			var u = User.manager.get(uid, false);
			if( u == null ) continue;
			mt.db.Twinoid.goals.increment(u, r.key, increment);
			
			var operator = if ( increment > 0 ) "+" + increment else "-" + increment;
			execute("INSERT INTO GhostReward (rewardKey,userId,value,day) VALUES ("+quote(Std.string(r.ikey))+","+uid+","+increment+",-1) ON DUPLICATE KEY UPDATE value=value"+operator);
		}
	}

	public function updateCleanReward(user:User, survDays:Int) {
		var gr = GR.get.nodrug;
		var value = Math.floor(Math.pow(survDays, 1.5));
		if( survDays <= 3 )
			execute("DELETE FROM GhostReward WHERE rewardKey="+quote(Std.string(gr.ikey))+" AND userId="+user.id+" AND day>=0");
		else
			execute("UPDATE GhostReward SET value="+value+" WHERE rewardKey="+quote(Std.string(gr.ikey))+" AND userId="+user.id+" AND day=0");
	}
}
