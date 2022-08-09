package ui.side;

import mt.MLib;
import com.Protocol;
import com.GameData;

class BuildMenu extends ui.SideMenu {
	public static var CURRENT : BuildMenu;
	var isize			: Int;
	var roomLevels		: Map<RoomType, Int>;

	public function new() {
		CURRENT = this;

		super();

		name = "BuildMenu";
		bhei = isSmall() ? 100 : 130;
		isize = 90;

		Game.ME.unselect();

		onResize();
	}


	override function onStartDrag(v) {
		super.onStartDrag(v);

		g.clearHudLayer();

		var shotel = g.shotel;
		var spots = [];
		for(r in g.hotelRender.rooms)
			for(x in r.rx...r.rx+r.sroom.wid) {
				if( !shotel.hasRoom(x, r.ry-1) ) spots.push({ x:x, y:r.ry-1 });
				if( !shotel.hasRoom(x, r.ry+1) ) spots.push({ x:x, y:r.ry+1 });
				if( !shotel.hasRoom(x-1, r.ry) ) spots.push({ x:x-1, y:r.ry });
				if( !shotel.hasRoom(x+r.sroom.wid, r.ry) ) spots.push({ x:x+r.sroom.wid, y:r.ry });
				if( r.sroom.canBeDestroyed() )
					spots.push({ x:r.rx, y:r.ry });
			}

		var done = new Map();
		var w = Const.ROOM_WID;
		var h = Const.ROOM_HEI;
		var lobby = Game.ME.hotelRender.getRoom(R_Lobby);
		for( pt in spots ) {
			if( pt.x>=lobby.rx && pt.y==lobby.ry )
				continue;

			if( v==R_FillerStructs && pt.y<0 )
				continue;

			var id = pt.x + pt.y*10000;
			if( done.exists(id) )
				continue;

			if( shotel.hasRoom(pt.x, pt.y) && !shotel.featureUnlocked("roomReplace") )
				continue;

			done.set(id, true);
			if( shotel.hasRoom(pt.x,pt.y) )
				g.hudRoom(pt.x, pt.y, "iconDestroy");
			else
				g.hudRoom(pt.x, pt.y, "iconBuild");
		}

		var icon = Assets.tiles.getH2dBitmap( Assets.getRoomIconId(v) );
		cursor.addChild(icon);
		icon.x = -icon.width*0.5;
		icon.y = -icon.height*0.5;
	}

	override function open() {
		super.open();

		ui.HudMenuTip.clear("build");

		//g.clearHudLayer();
//
		//var shotel = g.shotel;
		//var spots = [];
		//for(r in g.hotelRender.rooms)
			//for(x in r.rx...r.rx+r.sroom.wid) {
				//if( !shotel.hasRoom(x-1, r.ry) ) spots.push({ x:x-1, y:r.ry });
				//if( !shotel.hasRoom(x+1, r.ry) && r.sroom.type!=R_Lobby ) spots.push({ x:x+1, y:r.ry });
				//if( !shotel.hasRoom(x, r.ry-1) ) spots.push({ x:x, y:r.ry-1 });
				//if( !shotel.hasRoom(x, r.ry+1) ) spots.push({ x:x, y:r.ry+1 });
			//}
//
		//var done = new Map();
		//var w = Const.ROOM_WID;
		//var h = Const.ROOM_HEI;
		//for( pt in spots ) {
			//var id = pt.x + pt.y*10000;
			//if( done.exists(id) )
				//continue;
//
			//done.set(id, true);
			//g.hudRoom(pt.x, pt.y, "iconBuild");
		//}
	}

	override function onDragOnScene(v,cx,cy,?r:b.Room) {
		super.onDragOnScene(v,cx,cy,r);

		if( r==null )
			Game.ME.runSolverCommand( DoCreateRoom(cx,cy,v) );
		else {
			if( !r.sroom.canBeDestroyed() )
				new ui.Notification( Lang.getSolverError(CannotDestroyRoom) );
			else {
				var q = new ui.Question();
				var m = GameData.getRoomResellValue(r.sroom, shotel.countRooms(r.type), false);
				q.addText( Lang.t._("You are about to REPLACE \"::t1::\" by \"::t2::\".", {t1:Lang.getRoom(r.type).name, t2:Lang.getRoom(v).name}) );
				q.addButton(m>0?Lang.t._("Sell \"::r::\" there for ::n::?", {r:Lang.getRoom(r.type).name, n:Game.ME.prettyMoney(m)}) : Lang.t._("Replace the room there (free)?"), function() {
					Game.ME.chainCommands([
						DoCreateRoom(cx,cy,v),
					]);
				});
				q.addCancel();
			}
		}
	}

	inline function getRoomLevel(t:RoomType) {
		return roomLevels.get(t);
	}


	function addRoom(t:RoomType) {
		var small = isSmall();
		var unlocked = Game.ME.shotel.canBuildRoom(t);
		var isNextLocked = !unlocked && !cd.has("isNextLocked");
		var isNew = unlocked && !Game.ME.shotel.hasRoomType(t,true);
		if( isNextLocked )
			cd.set("isNextLocked", 9999);

		var inf = Lang.getRoom(t);
		var cb = !small || !unlocked ? null : function() {
			if( Game.ME.tuto.isRunning() ) {
				Game.ME.followTheInstructions();
				return;
			}
			var q = new ui.Question();
			q.addText(inf.name, Const.TEXT_GOLD, false);
			q.addSeparator();
			q.addText(inf.role);
			q.addText(Lang.t._("Note: drag the room icon to your hotel to build this room."), Const.TEXT_GRAY, 0.6);
			q.addCancel( Lang.t._("Ok") );
		}
		var b = createButton(cb, unlocked ? t : null);
		if( unlocked )
			b.enableRollover();

		// Icon
		var k = Assets.getRoomIconId(t);
		if( !unlocked )
			k = "roomUnknown";
		var icon = b.addElement("icon", k);
		icon.setScale(isize/icon.width);
		icon.x = 10;
		icon.y+=bhei*0.5 - icon.height*0.5;
		icon.alpha = unlocked || isNextLocked ? 1 : 0.5;
		var circle = b.addElement("circle", unlocked && isNew ? "sideIcon":"sideIconOff");
		circle.width = circle.height = isize;
		circle.setPos(icon.x, icon.y);


		// Name
		var name = b.addText("name",  unlocked || isNextLocked ? inf.name : cast "", 24);
		name.x = icon.x + isize+10;
		name.textColor = unlocked ? 0xFFFFFF : 0xA4A8CC;

		// Price
		var price : h2d.TextBatchElement = null;
		if( unlocked ) {
			price = b.addText("price", cast "??", 20);
			var m = com.GameData.getRoomCost(t, Game.ME.shotel.countRooms(t));
			if( m>0 )
				price.text = Game.ME.prettyMoney(m);
			else
				price.text = Lang.t._("Free || As in 'free beer'");
			price.textColor = Const.TEXT_GOLD;
			price.x = name.x;
		}

		// Desc
		var desc : h2d.TextBatchElement = null;
		if( !small ) {
			desc = b.addText("desc",  unlocked ? inf.role : Lang.t._("Need more stars"), 14);
			//var desc = b.addText("desc",  unlocked ? inf.role : Lang.t._("Requires level ::n::", {n:getRoomLevel(t)}), 14);
			desc.x = name.x;
			desc.maxWidth = (wid-desc.x-10)/desc.scaleX;
			desc.textColor = unlocked ? Const.TEXT_GRAY : 0xFF3C3C;
		}

		// Text vertical align
		var th = name.textHeight*name.scaleY + (desc!=null?desc.textHeight*desc.scaleY:0) + (price!=null?price.textHeight*price.scaleY:0);
		name.y = bhei*0.5 - th*0.5;
		if( price!=null )
			price.y = price.visible ? name.y+30 : name.y;
		if( desc!=null )
			desc.y = (price!=null ? price.y : name.y) + 26;

		// New label
		if( isNew ) {
			var bg = b.addElement("newBg", "newBanner");
			bg.width = isize;
			bg.height = 20;
			bg.x = icon.x;
			bg.y = icon.y + icon.height - bg.height -5;

			var n = b.addText("newTxt", Lang.t._("NEW!"), 14);
			n.x = bg.x + isize*0.5 - n.textWidth*n.scaleX*0.5;
			n.y = bg.y+1;
			n.textColor = 0x003A82;
		}

		b.position();
	}


	override function refresh() {
		super.refresh();

		// Compute all room levels
		roomLevels = new Map();
		var all = Type.getEnumConstructs(RoomType);
		for( k in all ) {
			var t = Type.createEnum(RoomType, k);
			var minLevel = 0;
			while( minLevel<100 && !GameData.roomUnlocked(shotel, minLevel,t) )
				minLevel++;
			roomLevels.set(t, minLevel);
		}

		clearContent();

		addTitle(Lang.t._("Workshop"));

		var all = Type.getEnumConstructs(RoomType).map( function(k) return Type.createEnum(RoomType, k) );
		all.sort( function(a,b) return Reflect.compare( getRoomLevel(a), getRoomLevel(b) ) );

		cd.unset("isNextLocked");
		for( t in all )
			if( GameData.getRoomCost(t, Game.ME.shotel.countRooms(t))>=0 )
				addRoom(t);
	}

	override function onResize() {
		super.onResize();
	}


	override function onDispose() {
		super.onDispose();

		if( CURRENT==this )
			CURRENT = null;
	}
}