package handler;

import db.Zone;
import db.Explo;
import db.ZoneAction;
import db.ZoneItem;
import db.User;
import db.Tool;
import db.CityLog;
import db.ExploItem;
import Common;
import tools.Utils;
import ExploCommon;
import data.Explo;

using Lambda;
class ExploActions extends Handler<Void> {

	public function new() {
		super();
		outside( "default",	"explo/base.mtt",	doExplo);
		outside( "move",						doMove );
		outside( "quit",  						doQuit );
		outside( "refresh",						doRefresh );
		outside( "enterRoom",					doEnterRoom );
		outside( "leaveRoom",  					doLeaveRoom );
		outside( "unlockDoor",					doUnlockDoor );
		outside( "blankKey",					doBlankKey );
		outside( "flee", 						doFlee );
		outside( "heroKillsZombie",				doHeroKillsZombie );
		outside( "searchRoom",					doSearchRoom );
	}

	function doExplo() {
		var user = App.user;
		
		if( db.User.manager.countSquad(user) > 0 ) {
			notify(Text.get.ExploCantEnter);
			appendNotify( Text.get.ExploCantEnterInGroup);
			App.goto("outside");
			return;
		}
		
		if( user.hasLeader() || user.isWaitingLeader ) {
			notify(Text.get.ExploCantEnter);
			appendNotify( Text.get.ExploCantEnterInEscort);
			App.goto("outside");
			return;
		}
		// si la zone a explorer est déjà visitée
		var zone = user.zone;
		var explo = Explo.manager.get(zone.id);
		updateOxygen(explo, true);
		// on veut pas bloquer le joueur qui était déjà dans l'exploration
		if( explo.user != user && zone.zombies > zone.humans && !user.hasTool("camoVest") ) {
			notify(Text.get.ExploCantEnter);
			appendNotify(Text.get.OutsideLostControl);
			App.goto("outside");
			return;
		}
		// on autorise
		if( explo.user != user && (user.isTerrorized || user.isWounded || user.isCamping()) ) {
			notify(Text.get.ExploCantEnter);
			if( user.isTerrorized )
				appendNotify( Text.get.ExploCantEnterTerrorized);
			if( user.isWounded )
				appendNotify( Text.get.ExploCantEnterWounded);
			if( user.isCamping() )
				appendNotify( Text.get.ExploCantEnterCamping );
			App.goto("outside");
			return;
		}
		// si la zone du joueur ne possède pas d'exploration
		if( explo == null ) {
			notify(Text.get.ExploNothing);
			App.reboot();
			return;
		}
		var visited = explo.isVisited() && !explo.isOver();
		if( visited && explo.uid != user.id ) {
			notify(Text.get.ExploCurrentlyVisited);
			App.goto("outside");
			return;
		} else if( !visited && ZoneAction.manager.hasDoneActionZone(user, "dungeon" ) ) {
			notify(Text.get.ExploAlreadyVisited);
			App.goto("outside");
			return;
		} else if( !visited ) {
			// plus de PAs ?
			if( !user.hasPaToMove() ) {
				notify(Text.get.NoMoveLeft);
				App.goto("outside");
				return;
			}
			user.losePa(1);
			user.endGather = null;
			user.isBrave = false;
			user.update();
			//
			db.GhostReward.gain(GR.get.ruine, user);
			//
			explo.user = user;
			explo.x = db.Explo.START_X;
			explo.y = db.Explo.START_Y;
			explo.inRoom = false;
			
			var oxygen = Explo.DEFAULT_OXYGEN * ((App.user.job.key == "collec") ? 1.5 : 1);
			if ( user.map.isHardcore() ) oxygen = Std.int(oxygen * 0.70);
			
			explo.oxygen = oxygen;
			explo.lastUpdate = Date.now();
			explo.update();
			ZoneAction.addDirectly(user, "dungeon");
		}
		//
		addExploDataToContext( encodeExploData( getExploData(user) ) );
		App.load( "explo/refresh" );
	}

	function doQuit() {
		var user = App.user;
		var zone = App.user.zone;
		var explo = zone.explo;
		if( (explo.x != Explo.START_X || explo.y != Explo.START_Y) ) {
			notify(Text.get.ExploCantDoAction);
			doRefresh();
			return;
		}
		if( explo.user == user ) {
			var explo = db.Explo.manager.get(zone.id);
			explo.user = null;
			explo.update();
		}
		//Pas de notify, car cela provoque une erreur puisque au réaffichage du flash, il n'y a pas de contexte possible !
		App.goto("outside");
	}
	
	static function canMove(explo : Explo) {
		return explo.oxygen > 0 && (explo.getZombies() == 0 || App.user.isBrave );
	}
	
	function getFleeOxygenCost() {
		return 	if ( App.user.map.isHardcore() ) 1000 * 25;
				else 1000 * 20;
	}
	
	public function doHeroKillsZombie() {
		var user = User.manager.get( App.user.id );
		if( !user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			App.goto("hero");
			return;
		}
		if( user.isCamping() )
			return;
		if( !App.user.isOutside ) {
			notify(Text.get.OutsideHeroAction);
			App.goto( "home");
			return;
		}
		var zone = user.zone;
		var explo = Explo.manager.get(zone.id);
		var cell = explo.getCurrentCell();
		if( explo.getZombies() <= 0 ){
			notify(Text.get.NoZombiesToKill);
			doRefresh();
			return;
		}
		if( user.usedHeroKill ){
			notify(Text.get.HeroAlreadyKilledAZombie);
			doRefresh();
			return;
		}
		if( user.hasDoneDailyHeroAction ){
			notify(Text.get.HeroTired);
			doRefresh();
			return;
		}
		var kills = Std.int( Math.min(explo.getZombies(), Const.get.HeroKickPower) );
		cell.zombies -= kills;
		cell.kills += kills;

		explo.update();

		user.usedHeroKill = true;
		user.hasDoneDailyHeroAction = true;
		user.update();

		db.GhostReward.gain(GR.get.killz, kills);
		db.GhostReward.gain(GR.get.heroac);

		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.HeroKilledZombies({u:user.print(), n:kills}), user.getMapForDisplay(), user.zone );
		notify( Text.fmt.HeroKillsZombies({n:kills}) );
		doRefresh();
	}
	
	function doFlee() {
		var fleeOxygenCost = getFleeOxygenCost();
		var user 	= App.user;
		var zone	= App.user.zone;
		var explo 	= Explo.manager.get(zone.id);
		updateOxygen(explo, false);
		
		if( explo.oxygen < fleeOxygenCost ) {
			notify(Text.get.ExploOutOfOxygen);
			doRefresh();
			return;
		}
		explo.oxygen  -= fleeOxygenCost;
		explo.update();
		
		user.isBrave = true;
		user.update();

		doRefresh();
	}
	
	function doUnlockDoor() {
		var user = App.user;
		var zone = App.user.zone;
		var explo = zone.explo;
		if( !canMove(explo) ) {
			notify(Text.get.ExploCantMoveZombie);
			doRefresh();
			return;
		}
		var cell = explo.getCurrentCell();
		if( cell.room == null ) {
			notify(Text.get.ExploCantDoAction);
		} else {
			var explo = db.Explo.manager.get(zone.id);
			var toolKey : Null<String> = switch(cell.room.doorKind) {
				case Normal 	: null;
				case BumpKey 	: "bumpKey";
				case ClassicKey : "classicKey";
				case MagneticKey: "magneticKey";
			}
			if( toolKey != null ) {
				var tool = XmlData.getToolByKey(toolKey);
				var t = App.user.findTool(toolKey, true);
				if( t == null ) {
					notify( Text.fmt.ExploNeedToolUnlockDoor({key:tool.name, icon:tool.icon}) );
				} else {
					explo.getCurrentCell().room.locked = false;
					t.delete();
					notify( Text.fmt.ExploUnlockDoor( { key:tool.name, icon:t.icon } ));
					db.GhostReward.gain( GR.get.door, user );
				}
			} else {
				explo.getCurrentCell().room.locked = false;
			}
			updateOxygen(explo);
		}
		doRefresh();
	}
	
	function doBlankKey() {
		var user = App.user;
		var zone = App.user.zone;
		var explo = zone.explo;
		if( !canMove(explo) ) {
			notify(Text.get.ExploCantMoveZombie);
			doRefresh();
			return;
		}
		if( user.job.key != "tech") {
			notify(Text.get.ExploNotTechnician);
			doRefresh();
			return;
		}
		if( ZoneAction.manager.hasDoneActionZone(user, "blankKey_"+explo.zoneId+"_"+explo.getCurrentCellId() ) ) {
			notify(Text.get.ExploCantDoBlankKeyTwice);
			doRefresh();
			return;
		}
		
		var cell = explo.getCurrentCell();
		if( cell.room == null ) {
			notify(Text.get.ExploCantDoAction);
		} else if( !cell.room.locked ) {
			notify(Text.get.ExploCantDoAction);
		} else {
			var toolKey : Null<String> = switch(cell.room.doorKind) {
				case Normal 	: throw Text.get.ExploCantDoAction;
				case BumpKey 	: "bumpKey_blank";
				case ClassicKey : "classicKey_blank";
				case MagneticKey: "magneticKey_blank";
			}
			if( user.hasCapacity(1) && toolKey != null ) {
				Tool.addByKey( toolKey, user, true );
				ZoneAction.addDirectly(user, "blankKey_"+explo.zoneId+"_"+explo.getCurrentCellId() );
			} else {
				notify(Text.get.NoMoreRoomInBag);
			}
		}
		doRefresh();
	}
	
	function doSearchRoom() {
		var user = App.user;
		var zone = App.user.zone;
		var explo = zone.explo;
		//
		if( !explo.inRoom ) {
			throw Text.get.ExploNotInRoom;
		}
		if( ZoneAction.manager.hasDoneActionZone(user, "gatherExplo_"+explo.zoneId+"_"+explo.getCurrentCellId() ) ) {
			notify(Text.get.ExploCantGatherTooMuch);
			doRefresh();
			return;
		}
		ZoneAction.addDirectly(user, "gatherExplo_" + explo.zoneId + "_" + explo.getCurrentCellId() );
		//
		var chanceMod = (App.user.job.key == "collec") ? Const.get.GathererBonus : 0;
		if( App.user.isDrunk )
			chanceMod -= 20;
		
		var tinfo = explo.getRandomItem( chanceMod );
		if( tinfo == null ) {
			notify( Text.get.NothingFound );
			if ( user.isDrunk ) appendNotify(Text.get.DrunkPenalty);
			doRefresh();
			return;
		}
		if( App.user.hasCapacity() && ToolActions.canTakeObject(tinfo, true) ) {
			var t = Tool.add( tinfo.toolId, App.user, true );
			explo = Explo.manager.get(explo.zoneId);
			explo.getCurrentCell().room.drops.remove(tinfo.key);
			explo.update();
			//TODO add notification
			notify( Text.fmt.ExploFindToolInRoom({name:tinfo.name}) );
		} else {
			//CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDropped( {name:user.print(),tool:tinfo.print()} ), map, zone );
			ExploItem.create( explo, tinfo.toolId );
			appendNotify(Text.get.NoRoomDrop);
		}
		//Ghost reward?
		doRefresh();
	}
	
	public function doEnterRoom() {
		// on ne peut pas fouiller un bâtiment qui n'est pas encore déterré
		var user = App.user;
		var zone = App.user.zone;
		var explo = zone.explo;
		//
		if( !canMove(explo) ) {
			notify(Text.get.ExploCantMoveZombie);
			doRefresh();
			return;
		}
		var cell = explo.getCurrentCell();
		if ( cell.room == null ) {
			notify(Text.get.ExploNoRoom);
		} else if ( explo.inRoom ) {
			notify(Text.get.ExploAlreadyInRoom);
		} else if ( cell.room.locked ) {
			notify(Text.get.ExploDoorLocked);
		} else {
			var explo = db.Explo.manager.get(zone.id);
			explo.inRoom = true;
			updateOxygen(explo);
		}

		doRefresh();
	}
	
	function doLeaveRoom() {
		var user = App.user;
		var zone = App.user.zone;
		var explo = db.Explo.manager.get(zone.id);
		var cell = explo.getCurrentCell();
		if( cell.room == null ) {
			notify(Text.get.ExploNoRoom);
		} else if ( !explo.inRoom ) {
			notify(Text.get.ExploCantDoAction);
		} else {
			explo.inRoom = false;
			updateOxygen(explo);
		}
		doRefresh();
	}

	public function doMove() {
		var user = App.user;
		var zone = user.zone;
		var explo = Explo.manager.get(zone.id);
		if( explo.user != user && (user.isTerrorized || user.isWounded) ) {
			notify(Text.get.ExploCantEnter);
			if( user.isTerrorized )
				appendNotify(Text.get.ExploCantEnterTerrorized);
			if( user.isWounded )
				appendNotify(Text.get.ExploCantEnterWounded);
			//
			onUserFailsExplo( explo );
			App.reboot();
			return;
		}
		
		var dx = App.request.getInt("x");
		var dy = App.request.getInt("y");
		var currentZoneId = App.request.getInt("z");
		var zone = user.zone;
		if( zone.id != currentZoneId ) {
			if (currentZoneId == null)
				db.Error.create("explo send no zoneId", "user: "+user.name+" #"+user.id+" dx="+dx+" dy="+dy, user);
			App.reboot();
			return;
		}
		moveUser(user, dx, dy);
		doRefresh();
	}
	
	//TODO : make titles for exploration
	function makeTitle(explo:Explo) {
		var str  = switch( explo.kind ) {
			case Bunker :  Text.get.ExploTitle_Bunker;
			case Hotel	: Text.get.ExploTitle_Hotel;
			case Hospital : Text.get.ExploTitle_Hospital;
		}
		return str;
	}
	
	public function doRefresh() {
		if( !App.user.inExplo() ) {
			App.reboot();
		}
		var user = App.user;
		var zone = App.user.zone; // lockée
		var explo = db.Explo.manager.get(zone.id);
		updateOxygen(explo);
		prepareTemplate("explo/main.mtt");
		App.context.title = makeTitle(explo);
		App.context.canExit = explo.x == Explo.START_X && explo.y == Explo.START_Y;
		App.context.currentCell = explo.getCurrentCell();
		App.context.user = user;
		App.context.explo = explo;
		App.context.fleeCost = getFleeOxygenCost();
		var zitems = db.ExploItem.manager._getExploCellItems(explo, false );
		App.context.items = sortExploItems( zitems );
		App.context.canGather = !ZoneAction.manager.hasDoneActionZone(user, "gatherExplo_" + explo.zoneId + "_" + explo.getCurrentCellId() );
		addExploDataToContext(encodeExploData(getExploResponse(explo)));
	}

	function sortExploItems(ziList:List<ExploItem>) {
		var arr = ziList.array();
		arr.sort( function(a, b) {
			var ta = XmlData.getTool(a.toolId);
			var tb = XmlData.getTool(b.toolId);
			if( ta.name.toLowerCase() < tb.name.toLowerCase() ) return -1;
			if( ta.name.toLowerCase() > tb.name.toLowerCase() ) return  1;
			return Std.random(3) - 1; // randomisation pour cacher les items empoisonnés
		} );
		return arr.list();
	}
	
	public static function updateOxygen(explo : db.Explo, ?fl_update = true) {
		var now = Date.now();
		if( explo.isVisited() ) {
			var u = explo.user;
			var dt = now.getTime() - explo.lastUpdate.getTime();
			if( explo.oxygen <= dt ) {
				onUserFailsExplo( explo );
				if( u.id == App.user.id ) {
					App.reboot();
					App.notification = (Text.get.ExploOutOfOxygen);
				}
			} else {
				explo.oxygen -= dt;
				explo.lastUpdate = now;
			}
		}
		if( fl_update ) explo.update();
	}
	
	// User must be locked
	public static function onUserFailsExplo( explo : Explo ) {
		// injured user since he didn't get out at correct time
		if( explo.user != null ) {
			var u = User.manager.get(explo.user.id);
			u.wound(true);
			u.update();
			//empty user bag
			var cell = explo.getCurrentCell();
			var tools = u.getInBagTools(true);
			for( tool in tools ) {
				if( tool.canBeLaunched(u) ) {
					ExploItem.create(explo, tool.toolId, 1 );
					tool.delete();
				}
			}
		}
		// update exploration object
		explo.user 	 = null;
		explo.oxygen = 0.0;
		explo.inRoom = false;
	}
	
	function moveUser( u : db.User, dx, dy ) {
		var zone = u.zone;
		var explo = zone.explo;
		//
		if ( u.id != explo.uid ) {
			App.reboot();
			return;
		}
		if ( !checkUserBeforeMove(u, explo, dx, dy) ) {
			return;
		}
		// update user position
		var explo = db.Explo.manager.get(zone.id);
		explo.x += dx;
		explo.y += dy;
		updateOxygen(explo);
		u.isBrave = false;
		u.update();
	}
	
	function checkUserBeforeMove(user:User, explo:Explo, dx:Int, dy:Int) {
		if ( !canMove( explo ) ) {
			notify(Text.get.ExploCantMoveZombie);
			return false;
		}
		//
		if ( Math.abs(dx) > 1 || Math.abs(dy) > 1 || ( dx == 0 && dy == 0 ) || ( dx != 0 && dy != 0 ) ) {
			return false;
		}
		// target position
		var tX = explo.x + dx;
		var tY = explo.y + dy;
		var targetCell = explo.getCurrentCell();
		if( targetCell == null || !targetCell.walkable) {
			notify( Text.get.ExploCantDoAction );
			App.reboot();
			return false;
		}
		return true;
	}

	/*----------------------------- GESTION DE LA CARTE SWF -----------------------------------*/
	// Mise à jour de la description de la map plus adaptée aux sous-sections qu'au chargement initial de la carte
	// En effet, c'est l'objet resp qui nous intéresse en premier lieu ici
	function getExploResponse(explo : Explo) {
		var canExit = explo.y == Explo.START_Y && explo.x == Explo.START_X;
		// map client
		var resp	=	{
			_x : explo.x, // arrival coordinate
			_y : explo.y,
			_o :explo.oxygen, // remaining oxygen
			_r : explo.inRoom,
			_d : convertCell( explo.getCurrentCell(), canExit ),
			_dirs : getDirs( explo ),
			_move : canMove( explo ),
		};
		return	{
			response	: resp,
			exploInit	: null,
		}
	}

	// Initialisation de départ de la carte
	public static function getExploData(user : User) {
		var zone 	= user.zone;
		var explo	= zone.explo;
		var canExit = explo.y == Explo.START_Y && explo.x == Explo.START_X;
		// map client
		var resp	= 	{
			_x : explo.x, // arrival coordinate
			_y : explo.y,
			_o : explo.oxygen, // remaining oxygen
			_r : explo.inRoom,
			_d : convertCell( explo.getCurrentCell(), canExit ),
			_dirs : getDirs(explo),
			_move : canMove( explo ),
		};
		var init	= 	{
			_zid: zone.id,
			_mid: zone.mapId,
			_k	: Type.enumIndex(explo.kind),
			_w 	: explo.width,
			_h 	: explo.height,
			_r 	: resp,
			_d  : user.job != null && user.job.key == "tamer",
		};
		return	{
			response	: resp,
			exploInit	: init,
		}
	}
	
	inline static function getDirs( explo : db.Explo ) {
		var x = explo.x;
		var y = explo.y;
		var cells = explo.data;
		var dirs = [false, false, false, false];
		if ( x < explo.width - 1 ) dirs[0] = cells[y][x + 1].walkable;
		if ( y > 0 ) dirs[1] = cells[y - 1][x].walkable;
		if ( x > 0 ) dirs[2] = cells[y][x - 1].walkable;
		if ( y < explo.height - 1 ) dirs[3] = cells[y + 1][x].walkable;
		return dirs;
	}
	
	static function convertCell(c : data.Explo.ExploCell, isExit:Bool=false) {
		return { _w:c.walkable, _z:c.zombies, _k:c.kills, _room: convertRoom(c.room), _seed:c.details, _exit:isExit};
	}
	
	static function convertRoom(r : data.Explo.ExploRoom) {
		if ( r == null ) return null;
		return { _locked : r.locked, _doorKind : Type.enumIndex(r.doorKind) };
	}

	public static function encodeExploData(data) {
		return	{
			rawResponse		: data.response,
			response		: ExploCommon.encode( haxe.Serializer.run(data.response) ),
			exploInit		: ExploCommon.encode( haxe.Serializer.run(data.exploInit) ),
		}
	}

	public static function addExploDataToContext(data) {
		App.context.response 	= data.response;
		App.context.rawResponse = data.rawResponse;
		App.context.exploInit 	= data.exploInit;
	}
}
