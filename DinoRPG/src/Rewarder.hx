package;
import data.Event;

class Rewarder
{
	static public function printableReward(r:Reward):String
	{
		var out = "";
		
		if( r.collections != null )
			for( obj in r.collections )
				out +="Collec " + obj.name+"(" + obj.id + "), ";
				
		if( r.objects != null )
			for( obj in r.objects )
				out += obj.count + "x Obj " + obj.o.name+"(" + obj.o.id + "), ";
		
		if( r.ingredients != null )
			for ( obj in r.ingredients )
				out += obj.count + "x Ingr " + obj.i.name+"(" + obj.i.id + "), ";
		
		if ( r.gold != null && r.gold > 0 ) 
			out += r.gold + " Gold, ";
			
		return out;
	}
	
	static public function rewardUser( u : db.User, r : Reward, reason:String="", force: Bool ) : Bool
	{
		if( !force && db.UserFlag.exists( reason, u ) )
			return false;
		//
		if( r.objects != null )
			for( obj in r.objects )
				db.Object.add( R_Rewarder, obj.o, obj.count, u, true );
		
		if( r.ingredients != null )
			for( obj in r.ingredients )
				db.Ingredient.add( obj.i, obj.count, u, true );
		
		if( r.collections != null )
			for( obj in r.collections )
				if ( !u.hasCollection(obj) )
					u.addCollection( obj );
		
		if ( r.gold != null && r.gold > 0 ) 
		{
			var u = db.User.manager.get(u.id, true);
			u.winMoney(r.gold, "event");
			u.update();
		}
		// We add a log
		db.UserLog.insert(u, db.UserLogKind.KAdminNote, "Rewarded for " + reason + " : " + printableReward(r));
		// We flag
		if( !force || !db.UserFlag.exists( reason, u ) )
			new db.UserFlag(reason, u).insert();
		//
		return true;
	}
	
	static public function rewardClan( c:db.Clan, r:Reward, reason:String, force:Bool )
	{
		var flagName = reason;
		for ( cu in db.ClanUser.manager.search( { cid : c.id } ) )
		{
			Rewarder.rewardUser(cu.user, r, reason, force);
		}
	}
	
	static public function rewardWar(event:db.GEvent, cfg:WarConfig, force:Bool)
	{
		db.GConfig.resetCache();
		db.ClanWar.manager.updateClans(false, true);
		
		var war = db.ClanRank.manager.currentWar();
		var flagName = "WAR_"+war;
		var maxRewarded = -1;
		for( o in cfg.rewards )
			if( maxRewarded < o.range.end ) 
				maxRewarded = o.range.end;
		
		var rewardedClans = db.Clan.manager.rankingReal( maxRewarded );
		for( c in rewardedClans )
		{
			var cranking = c.ranking;
			for( reward in cfg.rewards )
			{
				if( cranking >= reward.range.start && cranking <= reward.range.end )
				{
					if( reward.reward.collections != null && reward.reward.collections.length > 0 )
					{
						var col = reward.reward.collections.first();
						var index = 1 + col.id.charCodeAt( col.id.length - 1 ) - "a".code;
						var message = Text.getText("clan_hist_win" + index);
						db.ClanHistory.message(c, message, { war : war, item : col.name, pos : c.ranking }, null, c.owner);
					}
					Rewarder.rewardClan(c, reward.reward, flagName, force);
					break;
				}
			}
		}
		
		db.ClanWar.manager.endWar(war, [], new List());
	}
	
	static public function rewardBattle(event:db.GEvent, cfg:BattleConfig)
	{
		var battle = db.ClanBattleRank.manager.currentBattle();
		var leagues = Lambda.array(db.ClanLeague.manager.search({ eid : event.id }));
		leagues.sort(function(l1, l2) return l1.kind - l2.kind);
		
		var idBattleMode = Type.enumIndex(cast db.GConfig.getBattleMode());
		var lid = 0;
		var battlePos = Text.get.clan_battle_pos.split(":");
		for( l in leagues ) 
		{
			if( l.nextBattle != null ) throw "assert";
			var clans = Lambda.array(db.Clan.manager.search({ lid : l.id }));
			clans.sort(function(c1, c2) return c2.points - c1.points);
			for( c in clans ) 
			{
				var r = new db.ClanBattleRank();
				r.battle = battle;
				r.league = l;
				r.clan = c;
				r.name = c.name;
				r.pool = c.seed;
				r.poolPoints = c.reputBonus;
				r.finals = c.reput;
				r.finalPoints = c.points;
				r.battleMode = idBattleMode;
				r.insert();
			}
			
			var leagueInfos = l.get_infos();
			var leagueRewards = leagueInfos.rewards;
			var rewardObject:Reward = null;
			var cur = { points : 0, pos : 0 };
			for( c in clans ) 
			{
				//we make sure to not give to users who have cheated
				//they must have been in the clan for the last battle at least !
				if( cur.points != c.points ) 
				{
					if( c.points < 100 )
					{
						break;
					}
					
					rewardObject = leagueRewards[cur.pos];
					cur.pos++;
					cur.points = c.points;
				}
				
				if( rewardObject == null ) 
				{
					continue;
				}
				
				Rewarder.rewardClan(c, rewardObject, "CDC" + battle+"_" + leagueInfos.name+"_" + cur.pos, false);
				
				var text = Text.format(Text.get.clan_hist_result, { pos : battlePos[cur.pos-1], league : leagueInfos.name });
				if( rewardObject != null ) 
				{
					if( rewardObject.collections != null )
						for( collec in rewardObject.collections )
							text += Text.format(Text.get.clan_hist_result_col, { name : collec.name } );
						
					if( rewardObject.objects != null )
						for( object in rewardObject.objects )
							if( object.count > 0 ) text += Text.format(Text.get.clan_hist_result_item, { count:object.count, name : object.o.name } );
							
					if( rewardObject.ingredients != null  )
						for( ingr in rewardObject.ingredients )
							if( ingr.count > 0 ) text += Text.format(Text.get.clan_hist_result_item, { name : ingr.i.name, count : ingr.count });
				}
				text += (cur.pos == 1) ? Text.get.clan_hist_result_champ : Text.get.clan_hist_result_next;
				db.ClanHistory.message(c, text, null, c.owner);
			}
		}
	}
	
	static public function rewardMonsterHunter(event:db.GEvent, cfg:MHConfig)
	{
		var maxRewarded = -1;
		var rewarded : Array<Bool> = [];
		for( o in cfg.rankingRewards )
		{
			var r = o.reward;
			for( i in o.range.start...o.range.end + 1 )
				rewarded[i] = true;
			if( maxRewarded < o.range.end ) 
				maxRewarded = o.range.end;
		}
		
		var template = new templo.Loader("msg/monsterhunter.mtt", Config.defined("cachetpl"));
		var flagName = "MonsterHunter_" + event.id;
		var rewardedHunters = db.Hunter.manager.rankings(event, 0, maxRewarded );
		var userRanking = 0;
		for( h in rewardedHunters )
		{
			var u = h.user;
			userRanking++;
			for(reward in cfg.rankingRewards)
			{
				if( userRanking >= reward.range.start && userRanking <= reward.range.end )
				{
					var u = db.User.manager.get(h.uid, true);
					if ( Rewarder.rewardUser(u, reward.reward, flagName, false) )
					{
						if( u.twinId != null )
						{
							var result = template.execute( { reward:reward.reward, DATA:Config.get("data") } );
							mt.db.Twinoid.callApi("notifyUser", { user: u.twinId, html: result }, false);
						}
					}
					//
					break;
				}
			}
		}
	}
	
}