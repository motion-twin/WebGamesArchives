package b.r;

import com.Protocol;
import com.GameData;
import com.SRoom;
import mt.deepnight.Color;
import mt.MLib;
import mt.data.GetText;
import b.Room;
import h2d.TextBatchElement;
import h2d.SpriteBatch;

class Lobby extends b.Room {
	public static var CURRENT : Lobby;

	var desk				: BatchElement;
	var clientsCache		: Array<en.Client>;
	public var slotWid(get,never)	: Int;

	public function new(x,y) {
		super(x,y);
		CURRENT = this;
		cappedRight = false;
		clientsCache = [];
	}

	override function finalize() {
		super.finalize();

		var x = globalLeft + 400.;
		for( c in getAllClientsInside() ) {
			c.xx = x;
			c.dir = -1;
			x+=slotWid;
		}
	}

	inline function get_slotWid() {
		return switch( shotel.getQueueLength() ) {
			case 1,2,3,4,5,6 : 150;
			case 7,8 : 140;
			case 9,10 : 135;
			default : 125;
		}
	}


	override function renderWall() {
		super.renderWall();

		// Left wall
		wall.tile = Assets.rooms.getTile("roomLobby");
		wall.width = wall.tile.width;
		wall.height = hei;


		// Tiled wall
		var e = addBE(99,"lobbyWallTile");
		e.x = wall.width;
		e.width = innerWid-150-e.x;
	}

	override function clearContent() {
		super.clearContent();

		if( desk!=null ) {
			desk.remove();
			desk = null;
		}

	}

	override function renderContent() {
		super.renderContent();

		rightPadding.visible = false;
		topPadding.width = wid+60;

		desk = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, "lobbyDesk",0, 0,1);
		desk.x = globalLeft+55;
		desk.y = globalBottom-padding+1;

		var wwid = innerWid-150-wall.width;
		var whei = Std.int(hei*0.35);
		var wx = wall.x + wall.width;
		var wy = globalBottom-whei;
		dark.width = wwid+wall.width;

		// Paint color
		//if( sroom.custom.color!="raw" ) {
			//var c = Data.DataTools.getWallColorCode( sroom.custom.color, true );
			//var e = addBE(98, "white");
			//e.color = h3d.Vector.fromColor(c);
			//e.setPos(wx,wy);
			//e.width = wwid;
			//e.height = whei;
			//e.alpha = 0.7;
		//}
//
		//// Wallpaper
		//if( sroom.custom.texture>=0 ) {
			//wallTex = new TiledTexture(Game.ME.tilesSb, wx,wy, wwid,whei);
			//wallTex.setPriority(98);
			//wallTex.fill( "wallPaper", sroom.custom.texture, 0.4, 0.2 );
		//}

		// Bevel
		if( sroom.custom.color!="raw" || sroom.custom.texture>=0 ) {
			var e = addBE(98, "white");
			e.setPos(wx,wy);
			e.width = wwid;
			e.height = 4;
			e.alpha = 0.2;

			var e = addBE(98, "squareBlue");
			e.setPos(wx,wy-4);
			e.width = wwid;
			e.height = 4;
			e.alpha = 0.4;
		}

		// Pillars
		var e = addBE("lobbyPillar", 0.5, 1);
		e.setPos(globalLeft+500, globalBottom-padding+1);

		var e = addBE("lobbyPillar", 0.5, 1);
		e.setPos(globalLeft+900, globalBottom-padding+1);

		// Windows
		var e = addBE("lobbyWindow", 0.5, 0);
		e.setPos(globalLeft+700, globalTop+15);
		e.scale(0.8);

		var e = addBE("lobbyWindow", 0.5, 0);
		e.setPos(globalLeft+1100, globalTop+15);
		e.scale(0.8);


		var e = addBE("lobbyEndPillar");
		e.x = globalRight - e.width + 60;
		bottomPadding.width = wid*2.5;

		var queue = shotel.getQueueLength();
		for(i in 0...queue+1) {
			var e = addBE("lobbyWaitingPillar",0, 0.5,1);
			e.x = globalLeft + 400 + (i-0.5)*slotWid;
			e.y = globalBottom-padding;
			if( i<queue ) {
				var e = addBE("lobbyWaitingTile",0, 0,1);
				e.x = globalLeft + 400 + (i-0.5)*slotWid;
				e.y = globalBottom-55-padding;
				e.width = slotWid;
			}
		}
	}


	inline function getSolverWaitingLine() return shotel.getWaitingClients();

	override function onClientInstalled(c) {
		super.onClientInstalled(c);
		c.xx = getQueueEndX();
		//c.updateCoords();
		updateClientCache();
	}

	public inline function getQueueEndX() {
		return globalLeft + 400 + slotWid * shotel.getQueueLength();
	}

	override function getGiftBaseX() {
		return globalLeft + 50;
	}

	override function updateGiftPositions(?m) {
		super.updateGiftPositions(250);
	}

	public inline function updateClientCache() {
		clientsCache = getAllClientsInside();
	}



	override function onDispose() {
		super.onDispose();

		if( CURRENT==this )
			CURRENT = null;

		clientsCache = null;
	}

	//override function updateRoomButton(id:String, iconId:String, idx:Int, ?active=true, cb:Void->Void, ?confirm:LocaleString) {
		//super.updateRoomButton(id,iconId,idx,active,cb,confirm);
//
		//if( roomButtons.exists(id) ) {
			//var b = roomButtons.get(id);
			//b.bg.y = globalTop + 10 + b.bg.height*0.5;
			//b.i.y = b.bg.y;
		//}
	//}


	//function onClickLevelUp() {
		//if( Game.ME.isPlayingLogs )
			//return;
		//else if( Game.ME.tuto.isRunningAnythingExcept("upgradeLobby") ) {
			//Game.ME.followTheInstructions();
			//return;
		//}
		//else {
			//Assets.SBANK.click1(1);
			//Game.ME.cd.set("lobbyLevelUpOpen", Const.seconds(1));
			//var p = com.GameData.getRoomUpgradeCost(sroom.type, sroom.level);
			//var q = new ui.Question(p>0);
			//q.addText( Lang.t._("Upgrading the lobby will increase the number of clients waiting in it. Which is pretty awesome, if you ask me.") );
			//var len = shotel.getQueueLength(shotel.getQueueLevel()+1);
			//var label =
				//if( p>0 )
					//Lang.t._("Upgrade queue length to ::n:: for ::cost::", {n:len, cost:Game.ME.prettyMoney(p)});
				//else
					//Lang.t._("Upgrade queue length to ::n:: (free)", {n:len});
			//q.addButton( label, function() {
				//Game.ME.runSolverCommand( DoUpgradeRoom(rx, ry) );
				//Game.ME.unselect();
			//} );
			//if( p>0 )
				//q.addCancel();
		//}
	//}

	function onClickCall() {
		if( Game.ME.isPlayingLogs )
			return;
		else {
			var q = new ui.Question();
			q.addButton(Lang.t._("Complete the current queue"), "moneyGem", function() {
				Game.ME.runSolverCommand( DoActivateRoom(rx,ry, 0) );
			});
			q.addButton(Lang.t._("Clear the queue and get new clients"), "moneyGem", function() {
				Game.ME.runSolverCommand( DoActivateRoom(rx,ry, 1) );
			});
			q.addCancel();
		}
	}

	override function update() {
		super.update();

		updateRoomButton(
			"call", "btnPlus",
			shotel.featureUnlocked("gems"),
			onClickCall
		);

		//if( shotel.featureUnlocked("upgradeLobby") ) {
			//var p = com.GameData.getRoomUpgradeCost(sroom.type, sroom.level);
			//updateRoomButton(
				//"upgrade", "iconLvlUp",
				//p>=0,
				//onClickLevelUp
			//);
		//}

		// Grooms
		requireGrooms(1, globalLeft+100, false);
		for( e in getGroomsInside() )
			e.dir = 1;

		// Clients
		var x = 400.;
		var invalidate = false;
		for( c in clientsCache ) {
			if( c.destroyAsked ) {
				invalidate = true;
				continue;
			}
			c.iaGoto(x, -1);
			x+=slotWid;
		}
		if( invalidate )
			updateClientCache();
	}
}
