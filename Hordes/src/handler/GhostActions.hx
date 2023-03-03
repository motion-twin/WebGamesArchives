package handler;
import db.ZoneAction;
import Common;
import db.User;
import db.Map;
import db.Complaint;
import db.Team;
import db.TeamInvitation;
import db.TeamLog;

class GhostActions extends Handler<Void> {

	public function new() {
		super();

		ghost( "default",				"ghost/main_outgame.mtt",	doDefault );
		loggedUnsafe( "city",			"ghost/main_ingame.mtt",	doGhostMenu );
		ghost( "joinMap",				doJoinMap );

		logged( "info",					"ghost/info.mtt" );
		ghost( "maps",					"ghost/maps.mtt",		doMaps );
		ghost( "customMap",				"ghost/customMap.mtt",	doCustomMap );
		
		logged( "options",				doOptions );
		logged( "invitation",			doInvitation );
		logged( "ingame",				"ghost/ingame.mtt",		doIngame );
		logged( "ranking",				"ghost/ranking.mtt",	doRanking );
		logged( "chooseJob",			doChooseJob );
		loggedUnsafe( "user",			"ghost/user.mtt",		doUser );
		
		logged( "books",				doBooks );
		logged( "underDev",				"ghost/underdev.mtt",	doUnderDev );
		logged( "banReason",			"ghost/banReason.mtt",	doBanReason );
		logged( "saveMapComment",		doSaveMapComment );
		logged( "search",				doSearch );
		logged( "news",					"ghost/news.mtt" );
		logged( "refer",				"ghost/refer.mtt",			doRefer );
		logged( "heroUpgrades",			"ghost/heroUpgrades.mtt",	doHeroUpgrades );

		job( "saveJobs",				doSaveJobs);
		logged( "setAvatar",			doSetAvatar );
		logged( "changeSettings",		doChangeSettings );
		logged( "regenApiKey",			doRegenApiKey );
		logged( "changeTexts",			doChangeTexts );

		logged( "team",					"ghost/team.mtt",		doTeam );
		logged( "joinTeam",				doJoinTeam );
		logged( "toggleAutoJoin",		"ghost/team.mtt",		doToggleAutoJoin );
		logged( "leaveTeam",			doLeaveTeam );
		logged( "shoutTeam",			"ghost/team.mtt",		doShoutTeam );
		logged( "rejectTeamInvitation",	doRejectInvitation );
		logged( "inviteInTeam",			doInviteInTeam );
		logged( "kickTeamPlayer",		"ghost/team.mtt",		doKickTeamPlayer );
		logged( "cancelInvitation",		"ghost/team.mtt",		doCancelInvitation );
		logged( "createTeam",			doCreateTeam );

		var user = App.user;
		App.context.guser = user;
		App.context.hasTeamInvitation = App.user.hasTeamInvitation();
		App.context.hasUnreadTeamPosts = App.user.hasUnreadTeamPosts(); // TODO : à optimiser ?

		App.context.staticSites = db.Site.manager.getAllSitesSplitted(7);
		App.context.staticMySites = db.Site.manager.getMySites(user);
		App.context.hasRelease = XmlData.getLatestRelease()!=null;
	}

	// Mise en place du template de base puis chargement éventuel d'une sous-section
	function doDefault() {
		App.context.go = App.request.get("go");
		if( App.request.exists("go" ) ) {
			App.load( App.request.get("go") );
		}
	}

	function doRefer() {
		if( !db.GameMod.hasMod("REFER") )
			return;

		var clist = Lambda.array( db.User.manager.getByRef(App.user.id) );
		clist.sort( function(a,b) { return -Reflect.compare(a.refDays, b.refDays); } );
		App.context.inviteHash = db.TeamInvitation.manager.getByUsers(clist);
		App.context.clist = clist;
		var t = App.user.team;
		App.context.hasTeam = t!=null;
		App.context.teamFull = t!=null && db.Team.manager.countMembers(t)>=Const.get.TeamMaxPlayers;
		var all = tools.Utils.getListFrom( Text.get.RefererStupidReward );
		App.context.stupidReward = all[Std.random(all.length)];
	}

	/* ----------------------- PETITES COALITIONS -------------------*/

	function doToggleAutoJoin() {
		var user = App.user;
		user.autoJoin = !user.autoJoin;
		user.update();
		doTeam();
		return;
	}

	function doKickTeamPlayer() {
		var user = App.user;
		if( user.team == null ) {
			error( Text.get.notTeamOwner );
			doTeam();
			return;
		}
		if( user.team.creator != user ) {
			error( Text.get.notTeamOwner );
			doTeam();
			return;
		}
		var u = User.manager.get( App.request.getInt( "uid") );
		if( u == null || u.teamId == null || u.team != user.team) {
			error( Text.get.UnknownUser );
			doTeam();
			return;
		}
		TeamLog.shout( user.team, Text.fmt.KickTeamSpeech( {name:u.print()} ) );

		var team = db.Team.manager.get ( u.team.id );
		team.countP--;
		team.update();

		u.team = null;
		u.update();
		notify( Text.get.ejectedFromteam );
		doTeam();
		return;
	}

	function doTeam() {
		var team = db.Team.manager.get( App.user.teamId, false );
		App.context.team = team;

		if( team != null ) {
			var all = team.getPlayers();
			var readyList = team.getFreePlayers();
			var afkList = new Array();
			for (u in all) {
				var fl_found = false;
				for(u2 in readyList)
					if (u==u2)
						fl_found = true;
				if (!fl_found)
					afkList.push(u);
			}
			afkList.sort( function( u1, u2 ) { if( u1.mapId==null ) return -1 else return 1;});
			App.context.readyList = readyList;
			App.context.afkList = afkList;
			App.context.members = all.length;
			App.context.limitation = Const.get.TeamMaxPlayers-all.length;
			App.context.maxMembers = Const.get.TeamMaxPlayers;
			App.context.isTeamCreator = (team.creator == App.user);
			App.context.lastReadDate = App.user.lastTeamPost;
			if( App.user.hasUnreadTeamPosts() ) { // TODO : à optimiser ?
				App.user.lastTeamPost = team.lastPost;
				App.user.update();
			}
			var ids = Db.results("SELECT userId as id FROM TeamInvitation WHERE teamId=" + App.user.teamId );
			if( ids.length > 0 )
				App.context.invitations = Db.results("SELECT avatar, name, twinId, id FROM User WHERE id IN( "+ Lambda.map(ids, function(i){ return i.id;} ).join(",") + ")" );
			App.context.messages = TeamLog.manager.getLastTeamMessages( team );
		} else {
			App.context.invitations = TeamInvitation.manager.getForUser( App.user );
		}

		var pm = db.Cadaver.manager.getPlayedMapsIds( App.user );
		if( pm.length > 0 ) {
			var h = new IntHash();
			for( p in pm ) {
				h.set( p.mapId, true );
			}
			App.context.pMaps = h;
		}

		if( team != null ) {
			var tids = Db.results(" SELECT DISTINCT( mapId ) FROM User WHERE teamId="+App.user.teamId+" AND mapId IS NOT NULL" );
			if( tids.length > 0 ) {
				var ids = Lambda.map( tids, function( info : { mapId:Int} ) { return info.mapId; } );
				var maps = Db.results(" SELECT id, name, countP, days FROM Map WHERE id IN ( "+ids.join(",") + " )");
				if( maps.length > 0 ) {
					var h = new IntHash();
					for( m in maps ) {
						h.set( m.id, {name:m.name, info :{countP:m.countP,days:m.days}} );
					}
					App.context.kmaps = h;
				}
			}
			// Liste des joueurs connectés :)
			var ids = Lambda.map( Db.results("SELECT id From User where teamId="+ App.user.teamId ), function(i){return i.id;});
			if( ids.length > 0 ) {
				var now = DateTools.delta( Date.now(), -DateTools.minutes(Const.get.OnlineStatusMinutes) );
				var minTime = DateTools.format( now, "%Y-%m-%d %H:%M" );
				var times = Db.results("SELECT uid, count(*) as c FROM Session WHERE uid IN ("+ids.join(",")+") AND mtime>='"+minTime+"' GROUP BY uid HAVING c > 0");
				if( times.length > 0 ) {
					var h = new IntHash();
					for( t in times )
						h.set( t.uid, t.c );
					App.context.isOnline = h.exists;
				}
			}
		}
	}

	function doInviteInTeam() {
		var user = App.user;
		if( user.team == null ) {
			error( Text.get.noTeam );
			App.goto("ghost/team");
			return;
		}
		var i = User.manager.search( {twinId : App.request.getInt("to", 0)}, false ).first();
		if( i == null || i == user ) {
			error( Text.get.UnknownUser );
			App.goto("ghost/team");
			return;
		}
		if( i.team != null ) {
			error( Text.fmt.playerAlreadyInATeam( { n:i.name} ) );
			App.goto("ghost/team");
			return;
		}
		var invit = TeamInvitation.manager.getByUserAndTeam(i, user.team);
		if( invit != null ) {
			error( Text.get.alreadyHaveAnInvit );
			App.goto("ghost/team");
			return;
		}
		TeamInvitation.create( i, user.team );
		TeamLog.shout( user.team, Text.fmt.InviteTeamSpeech( {name:user.print(), target:i.print()} ) );
		if( App.request.getInt("fromRef",0) == 1 )
			App.goto("ghost/refer");
		else
			App.goto("ghost/team");
	}

	function doRejectInvitation() {
		var user = App.user;
		var id = App.request.getInt( "tid" );
		if( id == null || id == 0 ) {
			App.goto("ghost/team");
			return;
		}
		var i = TeamInvitation.manager.getWithKeys( {teamId:id, userId:user.id} );
		if( i == null ) {
			error( Text.get.InvitationDoesNotExist );
			App.goto("ghost/team");
			return;
		}
		i.delete();
		App.goto("ghost/team");
	}

	function doCancelInvitation() {
		var user = App.user;
		if( user.team == null ) {
			error( Text.get.notTeamOwner );
			doTeam();
			return;
		}
		var id = App.request.getInt( "uid" );
		if( id == null || id == 0 ) {
			doTeam();
			return;
		}
		var i = TeamInvitation.manager.getWithKeys( {teamId:user.teamId, userId:id} );
		if( i == null ) {
			error( Text.get.InvitationDoesNotExist );
			doTeam();
			return;
		}
		var invited = db.User.manager.get(id,false);
		TeamLog.shout( user.team, Text.fmt.CancelInvitTeamSpeech( {name:user.print(), target:invited.print()} ) );
		i.delete();
		doTeam();
	}

	function doJoinTeam() {
		var user = App.user;
		var id = App.request.getInt( "tid" );
		if( id == null || id == 0 ) {
			App.goto("ghost/team");
			return;
		}
		if( user.team != null ) {
			App.goto("ghost/team");
			return;
		}
		var i = TeamInvitation.manager.getWithKeys( {teamId:id, userId:user.id} );
		if( i == null ) {
			error( Text.get.InvitationDoesNotExist );
			App.goto("ghost/team");
			return;
		}
		// fix pour éviter le décompte foireux ?
		db.Team.manager.get(i.teamId,true).recount();
		// équipe pleine
		if( i.team.countP >= Const.get.TeamMaxPlayers ) {
			i.delete();
			error( Text.get.TeamFull );
			App.goto("ghost/team");
			return;
		}
		user.lastTeamPost = null;
		user.team = i.team;
		user.update();
		i.delete();

		var team = db.Team.manager.get( user.team.id );
		team.countP++;
		team.update();

		TeamInvitation.manager.deleteByUser( user );
		TeamLog.shout( user.team, Text.fmt.JoinTeamSpeech( {name:user.print()} ) );
		notify( Text.get.teamJoined );
		if( i.team.count() == Const.get.TeamMaxPlayers )
			TeamInvitation.manager.deleteByTeam( user.team );
		App.goto("ghost/team");
	}

	function doLeaveTeam() {
		var user = App.user;
		var team = user.team;
		if( team == null)
			return;
			
		user.leaveTeam();
		if( user == team.creator )
			notify( Text.get.leaveTeamDeleted );
		else
			notify( Text.get.teamLeft );
		App.goto("ghost/team");
	}

	function doShoutTeam() {
		var user = App.user;
		if( App.user.team == null) {
			doTeam();
			return;
		}
		var msg = tools.Utils.sanitize( App.request.get("message"), 255 );
		if( msg != "" && msg != null ) {
			msg = tools.Utils.formatPost(msg);
			TeamLog.shout( user.team, Text.fmt.TeamSpeech( {name : user.print(), msg : msg} ) );
		}
		doTeam();
	}

	function doCreateTeam() {
		var user = App.user;
		if( user.team != null ) {
			error( Text.fmt.alreadyInATeam({n:user.team.name}) );
			return;
		}
		if( !db.GameMod.hasMod("REFER") && !user.hero ) {
			error( Text.get.HeroOnly );
			return;
		}
		var t = Team.create(user);
		user.team = t;
		user.update();
		t.countP++;
		t.update();

		TeamInvitation.manager.deleteByUser( user );
		notify( Text.get.teamCreated );
		if( App.request.getInt("fromRef",0) == 1 )
			App.goto("ghost/refer");
		else
			App.goto("ghost/team");
	}

	function doInvitation() {
		if( !db.GameMod.hasMod("REFER") )
			return;
		if( !App.request.exists("email") ) {
			App.goto("ghost/user" );
			return;
		}
		if( !App.request.exists( "submit" ) ) {
			App.goto("ghost/user" );
			return;
		}
		var email = App.request.get("email", "");
		if( StringTools.trim( email ) == "" ) {
			notify( Text.get.UEmailFormat );
			App.goto( "ghost/user");
			return;
		}
		if( !tools.SubscribeValidator.isValidEmail(  email ) ) {
			notify( Text.get.UEmailFormat );
			App.goto( "ghost/user");
			return;
		}
		var ufake = { id : null, email : email, isDeleted : false, name : Text.get.TAMTAM_AFriendOf + App.user.name  };
		tools.Mail.send(ufake, "mail/invitation.mtt", {refererId : App.user.name, url: App.URL});
		notify( Text.get.TAMTAM_InvitationSent );
		App.goto( "ghost/refer");
	}

	function doSearch() {
		if( !App.request.exists("name") ) {
			App.goto("ghost/user");
			notify( Text.get.Forbidden );
			return;
		}
		var name = App.request.getInt("name", 0);
		var user = db.User.manager.search( {twinId:name}, false ).first();
		if( user == null ) {
			notify( Text.get.UserNameNotFound );
			App.goto("ghost/user");
			return;
		}
		App.goto("ghost/user?uid="+user.id+";from=ghost/user");
	}

	function doUser() {
		var user = null;
		if( App.request.exists("uid") )
			user = db.User.manager.get( App.request.getInt("uid"), false );

		var from = App.request.get("from");
		if( from == null || from == "" || from == "null" )
			App.context.fromURL = "ghost/user";
		else
			App.context.fromURL = App.request.get("from");

		if( user == null )
			user = App.user;
		var fl_mine = (user.id == App.user.id);
		App.context.guser = user;
		App.context.mine = fl_mine;
		App.context.maxRewards = Lambda.count(GR.LIST);
		App.context.sixMonthsTool = XmlData.getToolByKey("photo_3");

		// villes passées
		var seasonFilter = App.request.getInt("seasonFilter", App.getDbVar("season"));
		App.context.seasonFilter = seasonFilter;
		var fl_limit = if(App.request.exists("changeFilter")) App.request.getInt("limitTowns")==1 else App.request.getInt("limitTowns",1)==1;
		App.context.limitTowns = fl_limit;
		var limit = if(fl_limit) 10 else 9999;
		App.context.bestMaps = db.Cadaver.manager.getBestMaps(user, seasonFilter, 0, limit);
		App.context.hasWarnings = false;

		if( fl_mine ) {
			var t = App.user.customTitle;
			if( t != null && StringTools.trim( t ) != "" )
				App.context.rawTitle = t.substr( t.indexOf("/> ")+3 );
			else
				App.context.rawTitle = "";

			App.context.heroUpProgress = XmlData.getHeroUpProgress(App.user);
		}
		if( db.GameMod.hasMod("BETA_KEY") && fl_mine )
			App.context.codes = db.BetaAccess.manager.mine(user);
			
		//On met à jour les compteurs Twinoid en cas d'échec lors de la mort (assez fréquent sur hordes du fait de connexions massives apres l'attaque)
		if( fl_mine )
			mt.db.Twinoid.goals.checkUserRetry(user);
	}

	function doSaveMapComment() {
		if( !App.request.exists("cid") )
			return;
		var cadaver = db.Cadaver.manager.get( App.request.getInt( "cid") );
		if( cadaver == null )
			return;
		if( cadaver.userId != App.user.id )
			return;
		if( cadaver.survivalDays < 1 )
			return;
		if( App.user.muted ) {
			notify( Text.get.Muted );
			App.goto( "ghost/ingame");
			return;
		}

		var comment = App.request.get("comment","");
		cadaver.comment = tools.Utils.sanitize(comment,100);
		cadaver.update();
		notify( Text.get.UCommentSaved );
		App.goto( "ghost/ingame");
	}

	function doChangeSettings() {
		if( App.session == null ) {
			App.reboot();
			return;
		}
		if(!App.request.exists("l") ) {
			doOptions();
			return;
		}
		if( App.request.get("l") != App.session.sid ) {
			doOptions();
			return;
		}
		var slowMode = (App.request.get("slowMode")=="1");
		App.user.slowMode = slowMode;
		if( App.request.get("allowExtern")=="1" && db.GameMod.hasMod("XML") ) {
			if( App.user.apiKey==null )
				App.user.apiKey = User.generateApiKey(App.user);
		}
		else
			App.user.apiKey = null;
		App.user.update();
		notify( Text.get.USettingsChanged);
		doOptions();
	}

	function doRegenApiKey() {
		if( App.user.apiKey == null ) return;
		App.user.apiKey = User.generateApiKey(App.user);
		doOptions();
	}

	function doChangeTexts() {
		if( App.session == null ) {
			App.reboot();
			return;
		}
		if( !App.request.exists("l") ) {
			doOptions();
			return;
		}
		if( App.request.get("l") != App.session.sid ) {
			doOptions();
			return;
		}
		if( !App.request.exists("ghostMsg") ) {
			doOptions();
			return;
		}
		if( App.user.muted ) {
			notify( Text.get.Muted );
			doOptions();
			return;
		}

		var ghostMsg = tools.Utils.sanitize( App.request.get("ghostMsg"), 200);
		db.UserLog.insert( App.user, KGhostMessageChanged, App.user.ghostMsg + ">" + ghostMsg );
		App.user.ghostMsg = if(ghostMsg!="") ghostMsg else null;
		App.user.update();
		notify( Text.get.GhostTextsChanged );
		doOptions();
	}
	
	function doRanking() {
		if( !db.GameMod.hasMod("SEASON_RANKINGS") )
			return;
		//
		var maxSeason = App.getDbVar("season");
		var defCat = if( db.GameMod.hasMod("HARDCORE") ) "hardcore" else "normal";
		var cat = App.request.get("cat", defCat).toLowerCase();
		var subcat = App.request.get("subcat", "n").toLowerCase();
		var season = App.request.getInt( "season", maxSeason );
		if( season <= 0 || season > maxSeason )
			return;
		
		if( cat == "soul" ) {
			var soulSeason = App.request.getInt( "soulSeason", -1 );
			var seasonRestricted = soulSeason > -1;
			App.context.soulSeason = soulSeason;
			//Classement d'ame complet et par saison
			if( db.GameMod.hasMod("SOUL_SEASON_RANKING") ) {
				var cbCount = if( seasonRestricted ) callback(User.manager.countSeasonRankings, soulSeason) else db.User.manager.countRankings;
				var browser = new tools.ResultBrowser(	if( App.request.exists("page") ) App.request.getInt("page") else 1,
														cbCount(),
														Const.get.GhostRankingMaxResultsPerPage
													);
				var cbRanking = if( seasonRestricted ) callback(User.manager.seasonRankings, soulSeason, browser.start, browser.limit) else callback(User.manager.rankings, browser.start, browser.limit);
				App.context.soulRanking = cbRanking();
				App.context.browser = browser;
			} else {
				// POINTS D'ÂME
				App.context.soulRanking = db.User.manager.getTopPlayers(100, 30);
			}
		} else if(cat == "rewards") {
			// DISTINCTIONS
		} else {
			// VILLES
			var topMaps = if( subcat != "p" ) App.getTopMaps( season, cat == "hardcore" ) else App.getTopCustomMaps( cat == "hardcore" );
			if( topMaps.length == 0 ) {
				// ranking vide
				App.context.citizens = new Array();
				App.context.detailedMapId = null;
			} else {
				// on récupère les meilleurs joueurs de cette ville
				var topMap = topMaps.first();
				var detailedMapId = App.request.getInt("dmid", topMap.oldMapId);
				var citizens = Lambda.array(db.Cadaver.manager.getHistoryList(detailedMapId));
				if( !App.request.exists("dmid") ) {
					App.context.compactDetails = true;
					var n = 0;
					for( c in citizens )
						if( cast(c).survivalDays == topMap.survivalDays )
							n++;
					citizens = citizens.splice(0, n);
				} else {
					App.context.compactDetails = false;
				}
				App.context.citizens = citizens;
				App.context.detailedMapId = detailedMapId;
			}
			App.context.myMapsHash = db.Cadaver.manager.getSeasonMapIds(App.user, season);
			App.context.topMaps = topMaps;
		}
		// noms des saisons
		var allSeasons = new Array();
		for( n in 0...maxSeason+1 )
			allSeasons[n] = XmlData.getSeasonName(n);
		App.context.allSeasons = allSeasons;
		// site pour classement des distinctions
		var siteId = db.Version.getVar("rewardRankingSite");
		if( siteId != null && siteId > 0 )
			App.context.rewardSite = db.Site.manager.get(siteId, false);
		App.context.curSeason = season;
		App.context.cat = cat;
		App.context.subcat = subcat;
	}
	
	function doIngame() {
		if( !App.request.exists("id") ) {
			// all maps
			if( App.user.isPlaying() ) {
				App.context.mainURL = "city";
			}
			App.context.playedMaps = db.Cadaver.manager.getPlayedMaps( App.user );
		} else {
			// map details
			var id = App.request.getInt("id");
			var cadaver = db.Cadaver.manager.get(id);
			if( cadaver == null ) {
				App.goto("ghost/ingame");
				return;
			}
			App.context.mine = (cadaver.userId == App.user.id);
			App.context.guser = cadaver.user;
			App.context.cadaver = cadaver;
			App.context.bestMap = App.request.exists("best");
			App.context.cadavers = Lambda.array( db.Cadaver.manager.getHistoryList( cadaver.oldMapId ) );
			App.context.getShortDeathReason = db.Cadaver.getShortDeathReasonStatic;
			App.context.getSurvivalPoints = db.Cadaver.getSurvivalPointsStatic;
			App.context.lastDead = db.UserLog.manager.getLastDeadByMapId( cadaver.oldMapId );
			var d = 0;
			for( r in Common.REWARDS ) {
				if( r > 0 )
					break;
				d++;
			}
			App.context.lastDeadMinDay = d - 1;
		}
	}

	function doGhostMenu() {
		if( App.request.exists("uid") ) {
			App.load( "ghost/user?uid="+App.request.get("uid")+";from="+App.request.get("from") );
		} else {
			App.context.go = App.request.get("go");
			if( App.request.exists("go" ) ) {
				App.load( App.request.get("go") );
			} else {
				App.load( "ghost/user" );
			}
		}
	}

	public function doSaveJobs() {
		var user = App.user;
		if( user.hasJob() && !user.hasThisJob("basic") ) {
			App.reboot();
			return;
		}
		if( !App.request.exists( "keys" ) ) {
			App.goto("ghost/chooseJob");
			return;
		}
		// Le moteur de base permet d'avoir plusieurs jobs.
		var keys = Lambda.list( App.request.get("keys").split("|") );
		if( keys == null ) {
			error( Text.get.JobChoiceNeeded );
			return;
		}
		var jobId = keys.pop();
		var job = XmlData.getJob( Std.parseInt( jobId ) );
		if( job == null ) {
			error( Text.get.UnknownJob );
			return;
		}
		if( !canSeeJob(job.key) ) {
			error( Text.get.UnknownJob );
			return;
		}
		if( job.hero && !user.hero ) {
			notify( Text.fmt.HeroJob({job:job.print()}) );
			App.goto("ghost/chooseJob?hwanted=1");
			return;
		}
		if( job.hero == null && user.hero ) {
			notify( Text.get.HeroCantBeNoob );
			App.goto("ghost/chooseJob");
			return;
		}
		var lastJobId = db.UserVar.getValue(user, "lastJobId", -1);
		if( lastJobId>0 && lastJobId!=1 && job.key!="basic" && job.id!=lastJobId) {
			notify( Text.fmt.PickSameJob({j:XmlData.getJob(lastJobId).print()}) );
			App.goto("ghost/chooseJob");
			return;
		}
		// On teste si le joueur était en train de jouer
		var alreadyInGame = user.hasTool("suit") || user.hasTool("suit_dirt");
		var oldControl = user.getControlScore();
		user.jobId = job.id;
		user.job = XmlData.getJob( job.id );
		if( job.key != "basic" )
			db.UserVar.setValue(user, "lastJobId", job.id);
		user.update();
		
		// On supprime les anciens objets
		db.Tool.manager.deleteJobTools(user);
		// donne l'objet de métier, sauf au citoyen de base qui n'en n'a pas
		if( job.key!="basic" )
			db.Tool.add( job.tool, user, true );
		
		
		var map = user.getMapForDisplay();
		// donne les actions de métier pour les chantiers
		if( job.key == "tech" && map.hasMod("JOB_TECH") ) {
			db.UserVar.setValue( user, "buildingActions", Const.get.TechnicianBuildingActions );
		}
		
		if( alreadyInGame ) {
			// CAS 1 : le joueur est déjà dans une partie,
			if( user.isOutside ) {
				// Le changement de métier peut influer sur le control de la zone
				var newControl = user.getControlScore();
				
				if( user.hero )
					db.CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideNewHero( {name:user.print(),job:user.job.print()} ), map, user.getZoneForDisplay() );
				if( newControl!=oldControl )
					OutsideActions.updateZoneControl( user.zone, newControl-oldControl, user.map );
				App.goto("outside");
				return;
			} else {
				App.goto("city/enter");
				return;
			}
		} else {
			// CAS 2 : le joueur vient de rejoindre une partie
			user.finalizeJoinGame();
			App.goto("news");
		}
	}
	
	public function doMaps() {
		var user = App.user;
		if( user.isPlaying() || user.dead ) {
			App.reboot();
			return;
		}
		
		var minXp = db.Version.getVar("minXp");
//@TODO S14  make this value applied only if user not an hero
		var requiredXp = db.Version.getVar("pandeXp", minXp);
		// villes ouvertes aux inscriptions
		var sortedMaps = Lambda.array( user.getAvailableMaps(false) );
		sortedMaps.sort(function(m1,m2) { if( m2.countP > m1.countP ) return 1; if (m1.countP > m2.countP) return -1; return 0; });
		App.context.maps = sortedMaps;
		// villes privées
		var sortedMaps = Lambda.array( user.getAvailableMaps(true) );
		sortedMaps.sort(function(m1,m2) { if( m2.countP > m1.countP ) return 1; if (m1.countP > m2.countP) return -1; return 0; });
		App.context.privateMaps = sortedMaps;
		App.context.goldenHello = App.user.getGoldenHello();
		App.context.farCitiesXp = minXp;
		App.context.pandeCitiesXp = requiredXp;
		App.context.canJoinFar = App.user.survivalPoints >= minXp;
		App.context.canJoinPande = App.user.survivalPoints >= requiredXp;
		App.context.canJoinSmall = App.user.survivalPoints < minXp || App.user.survivalPoints >= requiredXp;
		// invitation
		var invitMap = Map.manager.get(db.UserVar.getValue(App.user, "mapInvit", 0), false);
		if( invitMap != null && invitMap.status == Type.enumIndex(GameIsOpened) )
			App.context.invitMap = invitMap;
		// Description de la map en cours
		if( App.request.exists("mapId") ) {
			var id = App.request.getInt("mapId");
			var map = Map.manager.get(id,false);
			if( map == null ) return;
			if( map.status == Type.enumIndex(GameIsClosed) || map.status==Type.enumIndex(EndGame) ) return;
			App.context.users = map.getUsers(false);
			App.context.mapId = map.id;
		}
		
//@TODO S14  make sure jumpers are in the correct experience range
		var jumpers = new List();
		if( App.user.team != null && App.user.autoJoin )
			for( u in App.user.team.getFreePlayers() )
				if( u != App.user )
					jumpers.add(u.print());
		App.context.jumpers = jumpers;
	}
	
	public function doCustomMap() {
		if( !db.GameMod.hasMod("CUSTOM_MAP") )
			throw "unknown page";
			
		var request = App.request;
		var user = App.user;
		
		var mapMods = ["EXPLORATION", "SHAMAN_SOULS", "FOLLOW", "BANNED", "NIGHTMODS", "CAMP", "GHOULS", "BUILDING_DAMAGE", "GUARDIAN", "IMPROVED_DUMP"];
		App.context.mapMods = mapMods;
		
		var pass = StringTools.trim(request.get("pass", ""));
		var ghoul = request.get("ghoul", "normal");
		var type = request.get("type", "small");
		var water = request.getInt("water", 150);
		var rules = neko.Web.getParamValues("rules");
		
		App.context.pass = pass;
		App.context.ghoul = ghoul;
		App.context.type = type;
		App.context.water = water;
		App.context.rule = rules;
		App.context.cityName = XmlData.getRandomCityName();
		
		var fl_hasSpecificWater = request.exists("water") && water != 150;
		var fl_canCreateEvent = user.isAdmin || user.isModerator;
		var fl_canCreateCustom = fl_canCreateEvent || (user.hero && user.hasHeroUpgrade("customMaps"));
		//on clamp malgré tout pour éviter les abus
		if( !fl_canCreateEvent ) water = mt.MLib.min(500, water);
		
		var cost = if(fl_canCreateEvent) 0 else Const.get.CustomMapCost;
		App.context.cost = cost;
		App.context.canCreateCustom = fl_canCreateCustom;
		App.context.canCreateEvent = fl_canCreateEvent;
		
		if( request.getInt("create") == 1 ) {
			if( !fl_canCreateCustom )
				return;
			// liste d'invités
			var invit = new IntHash();
			var invitRaw = request.get("invit", null);
			var rawInvits = null;
			if( invitRaw != null ) {
				invitRaw = StringTools.replace(invitRaw, "\n", "");
				rawInvits = invitRaw.split(",");
			}
			
			App.context.invit = invitRaw;
			if( rawInvits != null && rawInvits.length > 0 ) {
				for( raw in  rawInvits ) {
					var twinoidId = Std.parseInt(StringTools.trim(raw));
					if( twinoidId == null || twinoidId < 0 )
						continue;
					
					var u = db.User.manager.search( {twinId:twinoidId}, false).first();
					if( u == null || invit.exists(u.id) || u.isDeleted ) {
						var name = u == null ? Text.get.UnknownUser : u.name;
						notify(Text.fmt.CustMapInvalidInvit( { u : name } ));
						return;
					}
					
					if( u == user ) {
						notify(Text.get.CustMapInvalidInvitSelf);
						return;
					}
					invit.set(u.id, u);
				}
				var n = Lambda.count(invit);
				if( n > 0 && n < 39 ) {
					notify(Text.fmt.CustMapNotEnoughInvit( { n:n } ));
					return;
				}
			} else if( pass == null || pass == "" ) {
				notify(Text.get.CustMapNeedInfo);
				return;
			}
			
			if( pass.length < 6 || pass.length > 16 ) {
				notify(Text.get.CustMapInvalidPass);
				return;
			}
			
			//TODO : make a try catch ?
			mt.db.Twinoid.verifyToken(user.twinId);
			
			var flags = new List();
			switch( ghoul ) {
				case "normal"	:
				case "none"		: flags.add("noGhoul");
				case "violent"	: flags.add("violentGhoul");
				default : return;
			}
			
			if( fl_canCreateCustom ) {
				for( rule in rules ) {
					switch( rule ) {
						case ""				:
						case "infect"		: flags.add("infected");
						case "noBuilding"	: flags.add("noBuilding");
						default : return;
					}
				}
				
				switch( request.get("attack", "") ) {
					case ""				:
					case "smoothAttack" : flags.add("smoothAttack");
					case "bigAttack"	: flags.add("bigAttack");
				}
				
				if( request.exists("option_noAPI") )
					flags.add("noAPI");
					
				if( fl_canCreateEvent ) {
					if( request.exists("option_fullReward") )
						flags.add("fullReward");
					
					if( request.exists("option_fullXP") )
						flags.add("fullXP");
							
					for( job in XmlData.getAllJobs() ) {
						if( request.exists("job_" + job.key + "_disabled") ) {
							flags.add("noJob_" + job.key);
						} else {
							switch( job.key.toLowerCase() ) {
								case "tech": 	request.set("JOB_TECH", "1");
								case "hunter": 	request.set("JOB_HUNTER", "1");
								case "tamer": 	request.set("JOB_TAMER", "1");
								default:
							}
						}
					}
				}
			}
			
			var fl_far = switch( type ) {
				case "small"	: false;
				case "far"		: true;
				case "hardcore"	: true;
				default			:
			}
			
			// paiement
			if( cost > 0 && !user.payDays(cost) ) {
				notify(Text.fmt.NeedHeroDays( { n:cost } ));
				return;
			}
			
			var random = new neko.Random();
			if( fl_canCreateEvent ) {
				var mapSeed = request.getInt("mapSeed", -1);
				if( mapSeed > 0 )
					random.setSeed( mapSeed );
			}
			
			// création
			var map = Cron.createGame(fl_far, random, function(p_map:db.Map) {
				if( fl_canCreateEvent ) {
					p_map.name = request.get("option_cityName", p_map.name);
				}
				
				for( mapMod in mapMods )
					db.MapVar.setValue(p_map, "MOD_" + mapMod, request.getInt("MOD_" + mapMod, 0));
					
				//linked MODS
				if ( request.getInt("MOD_GHOULS", 0) == 1 )
					db.MapVar.setValue(p_map, "MOD_GHOUL_VACCINE", 1);
			});
			
			map.password = pass;
			map.availableForJoin = true;
			if( type == "hardcore" ) {
				map.hardcore = true;
			}
			
			if( fl_hasSpecificWater ) {
				map.water = water;
			}
			map.update();
			
			db.MapVar.setValue(map, "custom", 1);
			db.MapVar.setValue(map, "creator", user.id);
			db.MapVar.setValue(map, "creationCost", cost);
			
			for( f in flags )
				db.MapVar.setValue(map, f, 1);
			
			if( request.exists("option_goal") && request.get("option_goal", "") != "" )
				db.MapVar.setValue(map, "officialMapGoal", GR.getByKey(request.get("option_goal")).ikey);
			
			// distribution des invitations
			if( Lambda.count(invit) > 0 ) {
				for( u in invit ) {
					db.UserVar.setValue(u, "mapInvit", map.id, true);
					var u = User.manager.get(u.id, true);
					u.setAdminMsg(Text.fmt.CustMapInvitMsg( { map:map.name } )); //updated automatically
				}
				db.MapVar.setValue(map, "invitOnly", 1);
			}
			
			// jump auto
			if( !user.isAdmin ) {
				map.addUser(user);
				if( user.team != null )
					TeamLog.shout( user.team, Text.fmt.BuddyJoinedGame( {u:user.print(), m:map.name} ), true );
			}
			App.reboot();
		}
	}

	public function doOptions() {
		prepareTemplate("ghost/options.mtt");
		var editor = new tools.Editor( "ed_avatar");
		editor.setUploadData( {url: App.IMGUP_URL , site:"hordes", uid:App.user.id, error:Text.get.UploadError} );
		App.context.editor = editor;
		App.context.allowExtern = App.user.apiKey != null;
		App.context.apiKey = App.user.apiKey;
		if( App.user.isPlaying() ) {
			App.context.complained = Complaint.manager.countComplaints(App.user)>0;
		}
	}

	public function doChooseJob() {
		if( App.user.mapId == null ) {
			App.reboot();
			return;
		}
		if( App.user.hasJob() && !App.user.hasThisJob("basic") ) {
			App.reboot();
			return;
		}
		
		prepareTemplate("ghost/choose_job.mtt");
		var umap = Map.manager.get( App.user.mapId, false ); // NO LOCK
		var list = User.manager.getMapJobs(umap);
		var jobs = new List();
		if( list != null && list.length > 0 )
			for( j in list )
				jobs.push( { name:j.name, icon:XmlData.jobs[j.id].icon, count:j.count } );
		
		App.context.umap = umap;
		App.context.jList = jobs;
		App.context.canSeeJob = canSeeJob;
	}

	private function canSeeJob(jkey:String) {
		var map = App.user.map;
		if( db.MapVar.getBool( map, "noJob_" + jkey ) )
			return false;
		if( jkey == "hunter" && !map.hasMod("JOB_HUNTER") )
			return false;
		if( jkey == "tamer" && !map.hasMod("JOB_TAMER") )
			return false;
		if( jkey == "tech" && !map.hasMod("JOB_TECH") )
			return false;
		return true;
	}

	public function doBooks() {
		if( App.request.exists("bkey") ) {
			var book = db.Book.get( App.user, App.request.get("bkey") );
			if( book == null ) {
				if( App.user.isAdmin ) {
					var bdata = XmlData.getBookData(App.request.get("bkey"));
					book = new db.Book(App.user,bdata);
				} else {
					notify(Text.get.Forbidden);
					App.goto("ghost/books");
					return;
				}
			}
			var page = App.request.getInt("page", 0);
			if( page == null ) {
				App.goto("ghost/books");
				return;
			}
			prepareTemplate( "ghost/books.mtt" );
			if( page < book.countPages() ) {
				App.context.maxPage = book.countPages();
				App.context.book = book;
				App.context.page = page;
				App.context.author = book.getAuthor();
				return;
			}
		}
		// default
		prepareTemplate( "ghost/books.mtt" );
		if( App.user.isAdmin ) {
			var full = Lambda.array(XmlData.books);
			full.sort( function(a,b) {
				if( a.name < b.name ) return -1;
				if( a.name > b.name ) return 1;
				return 0;
			});
			App.context.fullList = full;
		}
		var list = db.Book.manager.getByUser(App.user);
		var books = Lambda.array(list);
		books.sort( function(a, b) {
			if (a.data.name<b.data.name) return -1;
			if (a.data.name>b.data.name) return 1;
			return 0;
		});
		App.context.books = books;
	}

	public function doUnderDev() {
		var latest = XmlData.getLatestRelease();
		var url = App.request.get("oldUrl");
		if( url != null && url != latest.url ) {
			var r = XmlData.getRelease(url);
			if(r != null)
				App.context.release = r;
		} else
			App.context.release = latest;
		if( App.request.exists("section") ) {
			var sid = App.request.getInt("section");
			App.context.section = sid;
			if( sid >= 0 ) {
				// un élément en particulier
				for(r in XmlData.futureReleases)
					if(r.id == sid)
						App.context.futureDetails = r;
			} else {
				// le chaos
				var flist = Lambda.filter( XmlData.futureReleases, function(r) {
					return !r.fl_major;
				});
				App.context.futureMisc = flist;
			}
		}
		App.context.isLatest = App.context.release==latest;
		App.context.releases = XmlData.releases;
		App.context.future = XmlData.futureReleases;
	}

	function doBanReason() {
		var warnings = new List();// db.CrowReport.manager.getWarnings(App.user);
		var banReasons = new List();// db.CrowReport.manager.getBanReasons(App.user);
		var rlist = warnings;
		var rcount = 0;// somme des plaintes
		var now = Date.now().getTime();
		var banTime = now;
		var days = Math.ceil( (banTime - now) / DateTools.days(1) );
		App.context.banDays = days;
		App.context.reports = rlist;
		App.context.warningList = warnings;
		App.context.banReasonList = banReasons;
		App.context.rcount = rcount;
	}

	public function doHeroUpgrades() {
		var list = new List();
		var next = new List();
		for( up in XmlData.heroUpgrades ) {
			if( up.days <= App.user.spentHeroDays ) {
				list.add(up);
			} else {
				next.add(up);
			}
		}
		App.context.heroUpProgress = XmlData.getHeroUpProgress(App.user);
		App.context.wonList = list;
		App.context.nextList = next;
		App.context.total = XmlData.heroUpgrades.length;
	}

	/* ------------------------ JOIN MAP ---------------------*/

	public function doJoinMap() {
		var map : Map = null;
		var user = App.user;
		var fl_volunteer = false;
		if( user.isPlaying() || user.dead ) {
			App.reboot();
			return;
		}
		
		// Cette fonction est là pour punir les joueurs inactifs à répétition, ou qui cherchent les pictos pour le fun...
		function isUnlockedUser(u) {
			if ( db.UserVar.getValue(u, "inactiveLocked", 0 ) > 0 ) {
				var cadaver = db.Cadaver.manager.getLastUserCadaver( u, false );
				var timeSinceLastCadaver = DateTools.delta(Date.now(), -cadaver.createDate.getTime()).getTime();
				if ( cadaver != null && timeSinceLastCadaver < DateTools.days(4) ) {
					return false;
				} else {
					db.UserVar.delete(u, "inactiveLocked");
					return true;
				}
			}
			return true;
		}
		
		try {
			if( user.debt > 0 ) // il nous doit des sous !
				throw Text.get.DebtForbidden;
				
			if ( !isUnlockedUser(user) )
				throw Text.get.CantJoinGameUserLocked;
			
			// liste des citoyens rejoignant cette ville
			var jumpers = new List();
			jumpers.add(user);
			if( App.request.exists("f") ) {
				// cas du joueur qui rejoint une partie d'un de ses coéquipiers (via la page Coalition)
				fl_volunteer = true;
				var friend = db.User.manager.get( App.request.getInt("f"), false );
				if( friend != null && friend.teamId == user.teamId && friend.mapId != null ) {
					var fmap = db.Map.manager.get( friend.mapId, false );
					if( !fmap.hasRoomForVolunteers(1) )
						throw Text.get.GameHasTooManyVolunteers;
					checkMapAccessibility(user, fmap);
					// on lock uniquement dans ce cas
					map = db.Map.manager.get( fmap.id );
				}
			} else {
				// on embarque tous les joueurs de la coalition qui sont disponibles (sauf villes privées, voir plus bas)
				if( user.team != null && user.autoJoin ) {
					for( u in user.team.getFreePlayers() ) {
						if ( u != user )
							if ( isUnlockedUser(u) )
								jumpers.add(u);
					}
				}
				
				if( !user.hero && App.request.exists("mid") ) {
					// Non-héros rejoignant une ville privée
					map = db.Map.manager.get( App.request.getInt("mid", 0) );
					if( !map.isCustom() )
						throw Text.get.Forbidden;
					checkMapAccessibility(user, map);
				} else if( !user.hero ) {
					// Non-héros : tirage aléatoire
					fl_volunteer = false;
					if( App.request.exists("mid") )
						return;
					var mapId = getTeamRandomMapId(user, jumpers, App.request.getInt("randhard", 0) == 1, App.request.getInt("randsmall", 0) == 1);
					if( mapId != null )
						map = db.Map.manager.get(mapId);
				} else {
				// USER IS AN Héro !
					if( App.request.getInt("forceRand",0) == 1 ) {
						// il veut quand même du random
						fl_volunteer = false;
						var mapId = getTeamRandomMapId(user, jumpers, App.request.getInt("randhard", 0) == 1, App.request.getInt("randsmall", 0) == 1);
						if( mapId != null )
							map = db.Map.manager.get(mapId);
					} else {
						// choix d'une partie
						fl_volunteer = true;
						map = db.Map.manager.get( App.request.getInt("mid",0) );
						if( map == null )
							return;
						checkMapAccessibility(user,map);
						if( !map.hasRoomForVolunteers(1) )
							throw Text.get.GameHasTooManyVolunteers;
					}
				}
			}
			// pas de map valide trouvée pour ce saut ?
			if( map == null )
				throw Text.get.NoGameFound;
			// en ville privée, pas de jump en groupe
			if( map.isCustom() ) {
				jumpers = new List();
				jumpers.add(user);
			} else { //S14
				//TODO detect here an excluded team member and notify that to the user
				//is request confirmed ?
				
				if( App.request.exists("confirm") ) {
					jumpers = Lambda.filter(jumpers, function(u) { 
						return isUserExperiencedForMap(u, map);
					});
				} else {
					var excluded = [];
					for ( ju in jumpers )
						if ( !isUserExperiencedForMap(ju, map) )
							excluded.push(ju);
					if ( excluded.length > 0 ) {
						//Need to display the problem to the user so that he can make a choice by confirming the map join or cancel it
						App.configureTemplo();
						App.request.set("confirm", "1");
						
						var absUrl = App.URL;
						var relUrl = App.makeUrl(App.request.getURI(), App.request.getParamsObject());
						relUrl = relUrl.substr(1);
						
						var template = new templo.Loader("msg/dialog_popup.mtt", Config.defined("cachetpl"));
						var context = {
							text: Text.get.CoaJumpWarning_Message,
							users : excluded,
							url : "#"+relUrl,
							confirm: Text.get.CoaJumpWarning_Confirm,
						}
						var htmlMsg = template.execute(context);
						appendNotify(htmlMsg);
						App.goto(App.request.getURI());
						return;
					}
				}
			}
			// code secret
			if( map.password != null && App.request.get("pass") != map.password )
				throw Text.get.GameNeedPassword;
			// date d'ouverture différée
			if( map.openDate != null && Date.now().getTime() < map.openDate.getTime() )
				throw Text.get.GameNotOpenedYet;
			// un des joueurs a-t-il déjà joué cette map ?
			for( u in jumpers )
				if( db.Cadaver.manager.hasPlayedAMap(u, map) )
					throw Text.get.NoGameFound;
			// vérification des places disponibles
			if( map.countP + jumpers.length > Const.get.MaxPlayers )
				throw Text.get.GameHasNoRoomForTeam;
			// ville privée avec une liste d'invités
			if( db.MapVar.getBool(map, "invitOnly") && db.UserVar.getValue(user, "mapInvit", 0) != map.id )
				throw Text.get.GameRequiresInvit;
			// vérification des slots coalisés disponibles
			if( jumpers.length > 1 && !map.hasRoomForVolunteers(jumpers.length) )
				if( fl_volunteer )
					throw Text.get.GameHasTooManyVolunteersForTeam;
				else
					throw Text.get.NoGameAvailableForTeam;
			// jump !
			for( u in jumpers ) {
				if( jumpers.length > 1 || fl_volunteer ) // saut de groupe ou choix "volontaire" !
					map.volunteers++;
				
				map.addUser(u);
				if( user.team != null )
					TeamLog.shout( u.team, Text.fmt.BuddyJoinedGame( {u:u.print(),m:map.name} ), true );
			}
			map.update();
			// on attribue directement le job Habitant aux noobs non-héros
			if( !user.hero && user.hideCommercials() )
				App.goto("ghost/saveJobs?keys=1");
			else
				App.reboot();
		} catch( e:String ) {
			#if debug
			for( ex in haxe.Stack.exceptionStack() )
				trace(ex);
			#end
			notify(e);
			App.goto("ghost/maps");
		}
	}
	
	public static function getTeamRandomMapId( leader:User, jumpers:List<User>, fl_hardcore:Bool, fl_small:Bool ) : Int {
		var accessibleMaps = new IntHash();
		for( u in jumpers ) {
			var avMaps = u.getAvailableMaps(false);
			for( m in avMaps )
				accessibleMaps.set(m.id, m);
		}
		var accessibleMaps = Lambda.list(accessibleMaps);
		if( accessibleMaps.length <= 0 )
			return null;
		// filtrage villes privées
		accessibleMaps = Lambda.filter( accessibleMaps, function(m) { return !m.isCustom(); });
		// filtrage par niveau d'XP
		var minXp = db.Version.getVar("minXp");
		var hardMinXp = db.Version.getVar("pandeXp", minXp);
		// Pour le jump aléatoire, on reste sur des maps de niveau "normal" pour le joueur.
		accessibleMaps = Lambda.filter( accessibleMaps, function(m) {
			return isUserExperiencedForMap(leader, m);
			//return (leader.survivalPoints >= minXp && m.level >= minXp) 
			//	|| (leader.survivalPoints < minXp && m.level < minXp);
		});
		// filtrage pandémonium
		if( fl_hardcore ) {
			if( !db.GameMod.hasMod("HARDCORE") || leader.survivalPoints < hardMinXp )
				return null;
			accessibleMaps = Lambda.filter(accessibleMaps, function(m) {
				return m.isHardcore();
			});
		} else if ( fl_small ) {
			accessibleMaps = Lambda.filter(accessibleMaps, function(m) {
				return !m.isFar();
			});
		} else {
			accessibleMaps = Lambda.filter(accessibleMaps, function(m) {
				return !m.isHardcore();
			});
		}
		accessibleMaps = Lambda.filter(accessibleMaps, function(m) {
			return m.countP + jumpers.length <= Const.get.MaxPlayers;
		});
		
		if ( jumpers.length > 1 ) {
			//S14
			accessibleMaps = Lambda.filter(accessibleMaps, function(m) {
				if ( !m.hasRoomForVolunteers(jumpers.length) ) 
					return false;
				//TODO detect here an excluded team member and notify that to the user
				for ( u2 in jumpers )
					if( !isUserExperiencedForMap(u2, m) )
						return false;
				return true;
			});
		}
		if( accessibleMaps.length == 0 )
			return null;
		return Lambda.array(accessibleMaps)[ Std.random(accessibleMaps.length) ].id;
	}

//@TODO S14 rajouter les nouvelles conditions de jump
	private function checkMapAccessibility(user:User, map:Map) {
		if( map.status != Type.enumIndex(GameIsOpened) )
			throw Text.get.GameNotAllowed;
			
		if( !map.availableForJoin )
			throw Text.get.GameNotAllowed;
		
		if( map.countP >= Const.get.MaxPlayers )
			throw Text.get.GameNotAllowed;
		
		if( map.days > Const.get.BeginPeriodDays )
			throw Text.get.GameNotAllowed;
		
		var minXp = db.Version.getVar("minXp");
		var hardMinXp = db.Version.getVar("pandeXp", minXp);
		var userXp = user.survivalPoints;
		var isExperienced = userXp >= minXp;
		
// S14
		if ( !map.isCustom() ) {
			if( map.isFar() && !isExperienced )
				throw Text.get.GameNeedXp;
			
			if( !map.isFar() && isExperienced && userXp < hardMinXp )
				throw Text.get.GameOnlyForNoobs;
				
			if ( map.isHardcore() && userXp < hardMinXp )
				throw Text.get.GameNeedXp;
		}
		
		if( db.Cadaver.manager.hasPlayedAMap( user, map ) )
			throw Text.get.GameNotAllowed;
	}
	
// S14  @TODO faire passer des tests sur cette fonction serait plus safe
	private static function isUserExperiencedForMap(user:db.User, map:db.Map):Bool {
		if ( map.isCustom() ) return true;
		
		var minXp = db.Version.getVar("minXp");
		var hardMinXp = db.Version.getVar("pandeXp", minXp);
		
		var userXp = user.survivalPoints;
		var isExperienced = userXp >= minXp;
		
		if( map.isFar() && !isExperienced )
			return false;
			
		if( !map.isFar() && isExperienced && userXp < hardMinXp )
			return false;
			
		if( map.isHardcore() && userXp < hardMinXp )
			return false;
		
		return true;
	}
}
