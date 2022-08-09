package b;

import com.*;
import com.Protocol;
import mt.MLib;
import mt.data.GetText;
import mt.deepnight.Tweenie;
import mt.deepnight.slb.*;

import h2d.Sprite;
import h2d.SpriteBatch;

class Room extends mt.Process {
	var hotel(get,never)		: Hotel; inline function get_hotel() return Hotel.ME;
	var shotel(get,never)		: com.SHotel; inline function get_shotel() return Game.ME.shotel;
	public var sroom(get,never)	: com.SRoom; inline function get_sroom() return shotel.getRoom(rx,ry);
	var data(get,never)			: Int; inline function get_data() return sroom.data;
	public var type(get,never)	: RoomType; inline function get_type() return sroom.type;

	public var rx(default,null)	: Int;
	public var ry(default,null)	: Int;
	public var rwid(default,null): Int;
	public var xx				: Float;
	public var yy				: Float;
	public var wid				: Int;
	public var hei				: Int;
	public var padding			: Int;
	public var cappedRight		: Bool;

	public var globalLeft(get,null)		: Int;
	public var globalRight(get,null)	: Int;

	public var globalTop(get,null)		: Int;
	public var globalBottom(get,null)	: Int;

	public var globalCenterX(get,null)	: Int;
	public var globalCenterY(get,null)	: Int;

	public var innerLeft(get,null)		: Int;
	public var innerRight(get,null)		: Int;
	public var innerTop(get,null)		: Int;
	public var innerBottom(get,null)	: Int;
	public var innerHei(get,null)		: Int;
	public var innerWid(get,null)		: Int;

	var rseed				: mt.Rand;

	var topPadding			: BatchElement;
	var bottomPadding		: BatchElement;
	var leftPadding			: BatchElement;
	var rightPadding		: BatchElement;
	var dark				: BatchElement;
	var wall				: BatchElement;
	var door				: BatchElement;
	var boostIcon			: Null<BatchElement>;
	var boostBar			: Null<BatchElement>;
	var fadeMask			: Null<BatchElement>;

	var hudElements			: Array<HSpriteBE>;
	public var gifts		: Array<men.Gift>;
	var roomButtons			: Array<{ id:String, bg:BatchElement, i:BatchElement, cb:Void->Void, confirm:LocaleString }>;
	//var roomButtons			: Map<String, { id:String, bg:BatchElement, i:BatchElement, cb:Void->Void, confirm:LocaleString }>;

	var curtain1			: Null<BatchElement>;
	var curtain2			: Null<BatchElement>;

	var timer				: h2d.TextBatchElement;
	var bar					: Null<ui.Progress>;
	var offFilter			: BatchElement;
	var allElements			: Array<h2d.SpriteBatch.BatchElement>;

	var g(get,never)		: Game; inline function get_g() return Game.ME;

	var groomsCache				: Array<en.Groom>;

	private function new(x,y) {
		super(hotel);

		padding = 10;
		groomsCache = [];
		//hotel.root.add(root, Const.DP_BG);

		allElements = [];
		cappedRight = true;
		rx = x;
		ry = y;
		rwid = sroom.wid;
		hotel.rooms.push(this);
		roomButtons = [];
		//equipments = [];
		hudElements = [];

		rseed = new mt.Rand(0);
		initRandom();

		wid = sroom.wid * Const.ROOM_WID;
		hei = Const.ROOM_HEI;
		gifts = [];

		name = switch( sroom.type ) {
			case R_Bedroom : "Room "+getNumber();
			default : Std.string(sroom.type).substr(2);
		}

		// Timer
		timer = Assets.createBatchText(Game.ME.textSbTiny, Assets.fontTiny, 24);
		timer.dropShadow = { color:0x0, alpha:0.6, dx:0, dy:3 }
		timer.text = "";
		timer.visible = false;

		// Door animation
		door = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -1,"door",0, 0,1);
		door.visible = false;
		door.scaleX = 0.1;
	}

	public function init() {
		updateCoords();
		renderContent();
		updateGifts(false);
		updateHud();
		updateConstruction();
	}

	public function fadeIn() {
		fadeMask = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -20, "squareBlue",0);
		fadeMask.x = xx;
		fadeMask.y = yy;
		fadeMask.width = wid;
		fadeMask.height = hei;
		delayer.add( function() {
			tw.create(fadeMask.alpha, 0, 1200).onEnd = function() {
				fadeMask.remove();
				fadeMask = null;
			}
		}, 500);
	}


	function initBar() {
		clearBar();

		bar = new ui.Progress();
		bar.x = Std.int( globalLeft + wid*0.5 - bar.width*0.5 );
		bar.y = Std.int( globalTop + 10 );
	}

	function clearBar() {
		if( bar!=null ) {
			bar.destroy();
			bar = null;
		}
	}

	function setBarWorking() {
		var t = shotel.getWorkCompleteTask(rx,ry);
		if( t!=null )
			setBarDuration(t.start, t.end);
		else
			clearBar();
	}

	//function setBarRatio(r:Float) {
		//if( Game.ME.hideUI ) {
			//clearBar();
			//return;
		//}
//
		//if( bar==null )
			//initBar();
//
		//bar.show();
		//bar.set(r);
	//}

	function setBarDuration(start:Float, end:Float) {
		if( Game.ME.hideUI ) {
			clearBar();
			return;
		}

		if( bar==null )
			initBar();

		bar.show();
		bar.setDuration(start, end);
	}


	override function onDispose() {
		clearContent();

		for(e in roomButtons.copy())
			disposeRoomButton(e.id); // before tw is disposed
		roomButtons = null;

		super.onDispose();

		if( fadeMask!=null ) {
			fadeMask.remove();
			fadeMask = null;
		}

		if( curtain1!=null ) {
			curtain1.remove();
			curtain1 = null;
		}
		if( curtain2!=null ) {
			curtain2.remove();
			curtain2 = null;
		}

		if( boostIcon!=null ) {
			boostIcon.remove();
			boostIcon = null;

			boostBar.remove();
			boostBar = null;
		}

		for( e in hudElements )
			e.remove();
		hudElements = null;

		for( e in allElements )
			e.remove();
		allElements = null;

		for(e in getGroomsInside())
			e.destroy();
		groomsCache = null;

		for(e in MinorEntity.ALL)
			if( e.room==this )
				e.destroy();

		for(e in gifts)
			e.destroy();
		gifts = null;

		onUnselect();

		for( c in getAllClientsInside() )
			c.room = null;

		hotel.rooms.remove(this);

		clearBar();

		door.remove();
		door = null;

		timer.dispose();
		timer = null;

		rseed = null;
	}


	public function getNumber() : String {
		var idx = 1;
		var x = rx-1;
		while( x>=Game.ME.hotelRender.left ) {
			if( shotel.hasRoom(x,ry, R_Bedroom) )
				idx++;
			x--;
		}
		if( ry>=0 )
			return Std.string( ry*100 + idx );
		else {
			var i = -ry-1;
			var letter =
				if( i<26 )
					String.fromCharCode("A".code + i);
				else
					String.fromCharCode("A".code + Std.int(i/26)-1) + "-" + String.fromCharCode("A".code + (i%26));

			return  letter + "-" + mt.deepnight.Lib.leadingZeros(idx,1);
		}
	}

	public function getName() : LocaleString {
		var n = getNumber();
		if( ry>=0 )
			if( sroom.countCustomizations()<5 )
				return Lang.t._("Room ::n::", {n:n});
			else
				return Lang.t._("Luxury Suite ::n:: || As in a 'hotel suite'", {n:n});
		else
			if( sroom.countCustomizations()<5 )
				return Lang.t._("Vault ::n::", {n:n});
			else
				return Lang.t._("Luxury Vault ::n::", {n:n});
	}

	public function isSelected() {
		return switch( Game.ME.selection ) {
			case S_Room(r) : return r==this;
			default : return false;
		}
	}


	public function onUnselect() {
	}

	public function onSelect() {
		onUnselect();
	}

	public function onStockAdded() {
	}

	public function updateData() {
	}


	function addCustomBE(?prio=0, k:String, ?f=0, ?xr:Float, ?yr:Float) {
		var e = Assets.custo0.addBatchElement(Game.ME.customsSb, prio, k, f, xr, yr);
		allElements.push(e);
		e.x = globalLeft;
		e.y = globalTop;
		if( Assets.SCALE != 1 )
			e.scale( Assets.SCALE );
		return e;
	}

	public function setCustomsAlpha(v:Float) {
		for(e in allElements)
			if( e.batch==Game.ME.customsSb )
				e.alpha = v;
	}


	function addBE(?prio=0, k:String, ?f=0, ?xr:Float, ?yr:Float) {
		var e = Assets.tiles.addBatchElement(Game.ME.tilesSb, prio, k, f, xr, yr);
		allElements.push(e);
		e.x = globalLeft;
		e.y = globalTop;
		return e;
	}

	function addFrontBE(?prio=0, k:String, ?f=0, ?xr:Float, ?yr:Float) {
		var e = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, prio, k, f, xr, yr);
		allElements.push(e);
		e.x = globalLeft;
		e.y = globalTop;
		return e;
	}



	function addAdditiveBE(?prio=0, k:String, ?f=0, ?xr:Float, ?yr:Float) {
		var e = Assets.tiles.addBatchElement(Game.ME.roomsAddSb, prio, k, f, xr, yr);
		allElements.push(e);
		e.x = globalLeft;
		e.y = globalTop;
		return e;
	}


	public function clearContent() {
		for(e in allElements)
			e.remove();
		allElements = [];

		if( wall!=null ) {
			wall.remove();
			wall = null;
		}

		if( offFilter!=null ) {
			offFilter.remove();
			offFilter = null;
		}

		dark = null;
		topPadding = null;
		bottomPadding = null;
		leftPadding= null;
		rightPadding= null;
	}

	override function toString() return '${sroom.type}${getNumber()}@$rx,$ry';


	function renderWall() {
		wall = Game.ME.roomsSb.alloc( Assets.rooms.getTile("roomNew") );
		wall.x = globalLeft;
		wall.y = globalTop;
	}

	public function renderContent() {
		clearContent();
		initRandom();

		// Main spritebatch
		//sb = new h2d.SpriteBatch(Assets.tiles.tile);
		//root.add(sb, Const.DP_ROOM_BATCH);
		//sb.filter = true;
		//#if debug sb.name = "Room.sb";#end

		// Front spritebatch
		//frontSb = new h2d.SpriteBatch(Assets.tiles.tile);
		//root.add(frontSb, Const.DP_FRONT);
		//frontSb.filter = true;
		//#if debug frontSb.name = "Room.frontSb";#end

		renderWall();

		// Damages
		if( sroom.isDamaged() ) {
			var be = addFrontBE("roomBurnt");
			if( sroom.damages==1 )
				be.alpha = 0.9;
			else
				be.alpha = rnd(0.5, 0.7);
			be.width = wid;
			be.height = hei;

			if( sroom.damages>=2 ) {
				var e = addFrontBE("roomBroken");
				e.width = wid;
				e.height = hei;
			}
		}


		// Dark glow
		dark = addBE("roomVignetage");
		dark.width = wid;
		dark.height = hei;
		dark.alpha = rseed.range(0.9, 1);

		// Padding bars
		topPadding = addFrontBE(-10, "wallTop");
		topPadding.width = wid;

		bottomPadding = addFrontBE(-10, "squareBlue");
		bottomPadding.tile.setCenterRatio(0,1);
		bottomPadding.y = globalBottom;
		bottomPadding.width = wid;
		bottomPadding.height = padding;

		leftPadding = addFrontBE(-10, "wallLeft");
		leftPadding.height = hei;

		rightPadding = addFrontBE(-10, "wallRight");
		rightPadding.tile.setCenterRatio(1,0);
		rightPadding.x = globalRight;
		rightPadding.height = hei;

		// Working filter
		offFilter = Assets.tiles.addBatchElement(Game.ME.tilesSb, "squareBlue",0);
		offFilter.width = wid;
		offFilter.height = hei;
		offFilter.alpha = 0.65;
		offFilter.visible = false;
		updateOffFilter();
	}


	public function finalize() {
		updateHud();
		updateData();
	}


	function updateOffFilter() {
		offFilter.x = globalLeft;
		offFilter.y = globalTop;
		offFilter.visible = countClients()==0 && isWorking() && !isUnderConstruction();
	}


	function initRandom() rseed.initSeed(rx+ry*1000);

	inline function get_globalLeft() return Std.int( xx );
	inline function get_globalRight() return Std.int( xx + wid );

	inline function get_globalTop() return Std.int( yy );
	inline function get_globalBottom() return Std.int( yy + hei );

	inline function get_globalCenterX() return Std.int( xx+wid*0.5 );
	inline function get_globalCenterY() return Std.int( yy+hei*0.5 );

	inline function get_innerLeft() return Std.int( padding );
	inline function get_innerRight() return Std.int( wid - padding );

	inline function get_innerTop() return padding;
	inline function get_innerBottom() return hei-padding;

	inline function get_innerWid() return wid-padding*2;
	inline function get_innerHei() return hei-padding*2;


	public function countClients() : Int {
		var n = 0;
		for( c in en.Client.ALL )
			if( !c.destroyAsked && c.room==this )
				n++;
		return n;
	}

	public inline function is(t:RoomType) return sroom!=null && sroom.type==t;
	public inline function isUnderConstruction() return sroom!=null && sroom.constructing;
	public inline function isWorking() return sroom!=null && sroom.working;


	public function updateConstruction() {
		if( !isUnderConstruction() && curtain1!=null )
			tw.create(curtain1.scaleX, 0, 1000).onEnd = function() {
				curtain1.remove();
				curtain1 = null;
			}

		if( !isUnderConstruction() && curtain2!=null )
			tw.create(curtain2.scaleX, 0, 1000).onEnd = function() {
				curtain2.remove();
				curtain2 = null;
			}

		if( isUnderConstruction() ) {
			if( curtain1==null ) {
				curtain1 = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -9, "roominProgress", 0, 0,0);
				curtain1.x = globalLeft+3;
				curtain1.y = globalTop+3;
				curtain1.width = wid*0.55;
				curtain1.height = hei - 6;
			}
			if( curtain2==null ) {
				curtain2 = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -9, "roominProgress", 0, 1,0);
				curtain2.x = globalRight-3;
				curtain2.y = globalTop + 3;
				curtain2.width = wid*0.55;
				curtain2.height = hei - 6;
			}
		}
	}

	public inline function getGroomsInside() : Array<en.Groom> {
		return groomsCache;
		//return en.Groom.ALL.filter( function(e) return !e.destroyAsked && e.room==this );
	}

	public inline function countGrooms() return groomsCache.length;

	public function requireGrooms(n:Int, ?x=-1., ?smoke=true) {
		if( isUnderConstruction() )
			n = 0;

		while( groomsCache.length<n ) {
			var e = new en.Groom(this);
			if( x!=-1 )
				e.setPos( x, globalBottom);
			else
				openDoor(true);

			if( smoke )
				Game.ME.fx.smokeBomb(e);

			groomsCache.push(e);
		}

		while( groomsCache.length>n ) {
			var e = groomsCache.shift();
			if( smoke )
				Game.ME.fx.smokeBomb(e);
			e.destroy();
		}
	}

	public function getAllClientsInside() : Array<en.Client> {
		return en.Client.ALL.filter( function(e) return !e.destroyAsked && e.room==this );
	}

	public function getClientInside() : en.Client {
		for( c in en.Client.ALL )
			if( !c.destroyAsked && c.room==this )
				return c;
		return null;
	}

	public function onClientUse(c:en.Client) {
	}

	public function onWorkStart() {
	}

	public function onWorkEnd() {
	}

	public function onClientInstalled(c:en.Client) {
		updateHud();
	}

	public function onClientLeave(c:en.Client) {
		clearBar();
		updateHud();
	}

	//public function updateEquipments() {
		//for( e in equipments )
			//e.be.remove();
		//equipments = [];
//
		//var n = 0;
		//for(i in sroom.equipments) {
			//var be = Assets.tiles.addBatchElement(frontSb, Assets.getItemIcon(i), 0);
			//be.width = Const.EQUIPMENT_ICON;
			//be.height = Const.EQUIPMENT_ICON;
			//be.x = innerLeft;
			//be.y = innerTop + n*Const.EQUIPMENT_ICON;
			//equipments.push({ i:i, be:be });
			//n++;
		//}
	//}


	public function updateHud() {
		for(e in hudElements)
			e.remove();
		hudElements = [];
	}

	public function hideHud() {
		for(e in hudElements)
			e.visible = false;
	}

	public function showHud() {
		for(e in hudElements)
			e.visible = true;
	}


	public function updateGifts(?fx=true) {
		// Add
		var added = [];
		var all = gifts.copy();
		for( i in sroom.gifts ) {
			var found = false;
			for( g in all )
				if( i.equals(g.item) ) {
					found = true;
					all.remove(g);
					break;
				}
			if( !found ) {
				var g = new men.Gift(this, 0,0, i);
				gifts.push(g);
				added.push(g);
			}
		}

		// Remove
		var removed = [];
		var all = sroom.gifts.copy();
		for( g in gifts ) {
			var found = false;
			for( i in all )
				if( i.equals(g.item) ) {
					found = true;
					all.remove(i);
					break;
				}
			if( !found ) {
				gifts.remove(g);
				removed.push(g);
				g.destroy();
			}
		}

		updateGiftPositions();

		if( fx ) {
			for( g in added )
				Game.ME.fx.giftAdded(g.xx, g.yy-20);
			for( g in removed )
				Game.ME.fx.giftRemoved(g.xx, g.yy-20);
		}
	}


	public inline function hasGifts() return sroom.gifts.length>0;
	function getGiftBaseX() return globalLeft + innerWid*0.35;

	public function updateGiftPositions(?maxWid=200) {
		var space = MLib.fmin(120, maxWid/gifts.length);
		var x = gifts.length-1;
		var base = getGiftBaseX();
		var n = 0;
		for( e in gifts ) {
			e.yy = globalBottom-padding;
			if( e.xx==0 )
				e.xx = base;
			e.tx = base + x*space;
			x--;
			n++;
		}
	}




	function updateCoords() {
		var pt = b.Hotel.gridToPixels(sroom.cx, sroom.cy);
		xx = pt.x;
		yy = pt.y-hei;

		door.x = globalLeft;
		door.y = globalBottom;
	}

	public function openDoor(enter:Bool) {
		delayer.cancelById("door");
		door.visible = true;
		tw.create(door.scaleX, 1, 200);
		delayer.add("door", function() {
			tw.create(door.scaleX, 0, 600).onEnd = function() {
				door.visible = false;
			}
		}, 600);

		if( !Game.ME.turbo )
			Assets.SBANK.door( enter ? 0.5 : 0.2 );
	}

	public function getTaskTimer() : { start:Float, end:Float } {
		if( Game.ME.isVisitMode() )
			return null;

		var task = shotel.getRoomFirstTask(rx,ry);
		if( task!=null )
			return { start:task.start, end:task.end };

		if( is(R_Bedroom) && countClients()==1 ) {
			var t = shotel.getClientCompleteTask( getClientInside().id );
			if( t!=null )
				return { start:t.start, end:t.end };
		}

		return null;
	}

	public function updateTimer() {
		if( Game.ME.isVisitMode() )
			return;

		var t = getTaskTimer();
		if( t!=null ) {
			var label = if( is(R_Bedroom) && countClients()==1 )
				Lang.t._("Leave in %time%");
			else
				Lang.t._("Finish in %time%");

			var txt = Game.ME.prettyTime(label, t.end);
			if( txt!=timer.text ) {
				timer.text = txt;
				timer.x = Std.int(globalLeft + wid*0.5-timer.textWidth*timer.scaleX*0.5);
				timer.y = globalTop + 35;
			}
		}
		else
			timer.text = "";
	}

	public function clearRoomButtons() {
		for( e in roomButtons )
			disposeRoomButton(e.id);
		roomButtons = [];
	}

	function getRoomButton(id:String) {
		for(e in roomButtons)
			if( e.id==id )
				return e;
		return null;
	}

	function hasRoomButton(id:String) {
		for(e in roomButtons)
			if( e.id==id )
				return true;
		return false;
	}

	public function updateRoomButton(id:String, iconId:String, ?active=true, cb:Void->Void, ?confirm:LocaleString) {
		if( Game.ME.isVisitMode() )
			return;

		if( Game.ME.hideUI )
			active = false;

		var margin = 10;
		var idx = roomButtons.length;
		var size = 64;

		if( active && !hasRoomButton(id) ) {
			var bg = Assets.tiles.hbe_get(Game.ME.tilesFrontSb, "btnBlankBig",0, 0.5,0.5);
			bg.constraintSize(size);
			var scale = bg.scaleX;
			bg.changePriority(-10);
			bg.x = globalRight - padding - bg.tile.width*scale*0.5 - margin;
			bg.y = globalTop + padding + bg.tile.height*scale*0.5 + margin;
			bg.setScale(0.1);

			bg.x-=idx*(size+margin);

			var i = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -10, iconId,0, 0.5,0.5);
			i.x = bg.x;
			i.y = bg.y;
			i.scaleX = i.scaleY = 0.1;

			tw.create(bg.scaleX, scale, TElasticEnd, 600).onUpdate = function() {
				bg.scaleY = bg.scaleX;
				i.scaleX = i.scaleY = bg.scaleX * MLib.fmin(85/i.tile.width, 85/i.tile.height);
			}

			roomButtons.push({ id:id, bg:bg, i:i, cb:cb, confirm:confirm });
		}

		if( !active && hasRoomButton(id) )
			disposeRoomButton(id);

		if( active && itime%20==0 && !Game.ME.tuto.isRunning() ) {
			var bt = getRoomButton(id);

			if( id=="validate" )
				Game.ME.fx.ping(bt.bg.x, bt.bg.y, "fxNovaBlue");

			if( id=="repair" && shotel.countStock(R_StockSoap)>=sroom.damages )
				Game.ME.fx.ping(bt.bg.x, bt.bg.y, "fxNovaPurple");
		}
	}

	function disposeRoomButton(id:String) {
		var e = getRoomButton(id);
		if( e==null )
			return;
		roomButtons.remove(e);
		tw.terminateWithoutCallbacks(e.bg.scaleX);
		e.bg.remove();
		e.i.remove();
		e.cb = null;

	}

	public function clickRoomButton(sx,sy) {
		var r = 0.7;
		for(bt in roomButtons) {
			var bg = bt.bg;
			var x = bg.x;
			var y = bg.y;
			if( sx>=x-bg.width*r && sx<x+bg.width*r && sy>=y-bg.height*r && sy<y+bg.height*r ) {
				Game.ME.fx.roomButtonFeedback(bg.x, bg.y);
				Assets.SBANK.click1(1);
				if( bt.confirm==null || cd.has("confirm_"+bt.id) )
					bt.cb();
				else {
					cd.set("confirm_"+bt.id, Const.seconds(3));
					new ui.SceneTip(bg.x, bg.y, bt.confirm);
				}
				return true;
			}
		}
		return false;
	}


	//function onClickSkipJob() {
		//if( isWorking() )
			//Game.ME.runSolverCommand( DoSkipWork(rx,ry) );
		//else if( isUnderConstruction() )
			//Game.ME.runSolverCommand( DoSkipConstruction(rx,ry) );
		//return true;
	//}

	function onClickSkipConstruction() {
		if( isUnderConstruction() ) {
			Game.ME.runSolverCommand( DoSkipConstruction(rx,ry) );
			return true;
		}
		else
			return false;
	}

	function onClickSkipRepair() {
		if( isWorking() && sroom.isDamaged() ) {
			Game.ME.runSolverCommand( DoSkipWork(rx,ry) );
			return true;
		}
		else
			return false;
	}

	function onClickRepair() {
		Game.ME.runSolverCommand( DoRepairRoom(rx,ry) );
		return true;
	}

	function onClickCancel() {
		Game.ME.runSolverCommand( DoDestroyRoom(rx, ry) );
		return true;
	}

	function onClickBoost() {
		//var q = new ui.Question();
		//q.addText(Lang.t._("You can boost this room, but there is a slight chance that something goes horribly wrong."));
		//q.addText(Lang.t._("Chance of failure: ::n::%", {n:GameData.BOOST_FAILURE_PCT}));
		//q.addButton( Lang.t._("Boost speed (::cost:: GOLD)", {cost:GameData.BOOST_COST}), "moneyGold", function() {
			Game.ME.runSolverCommand( DoBoostRoom(rx,ry) );
		//});
		//q.addCancel();
	}

	function onClickSkipWork() {
		Game.ME.runSolverCommand( DoSkipWork(rx,ry) );
	}


	function canBeBoostedNow() {
		return isWorking();
	}

	public function getProblem() : Null<{icon:String, desc:LocaleString}> {
		return null;
	}


	//override function render() {
		//super.render();
		//var idx = 0;
		//for(e in roomButtons) {
			//e.bg
			//idx++;
		//}
	//}

	override function update() {
		super.update();

		// Timer
		if( itime%30==0 )
			updateTimer();
		timer.visible = !Game.ME.isVisitMode() && timer.text!="" && !Game.ME.hideUI;

		// Curtain
		if( curtain1!=null )
			curtain1.rotation = Math.cos(ftime*0.1)*0.01;
		if( curtain2!=null )
			curtain2.rotation = -Math.cos(ftime*0.1)*0.01;

		// Progress bar
		var t = getTaskTimer();
		if( !isUnderConstruction() && t!=null )
			setBarDuration(t.start, t.end);

		// Working filter
		updateOffFilter();

		// Fat buttons
		if( !Game.ME.isVisitMode() ) {
			updateRoomButton(
				"repair",
				"iconClean",
				countClients()==0 && sroom.isDamaged() && !isUnderConstruction() && !isWorking(),
				onClickRepair
			);

			updateRoomButton(
				"skipConstruction",
				"moneyGem",
				shotel.featureUnlocked("gems") && isUnderConstruction() && t.end-Game.ME.serverTime>DateTools.seconds(30),
				onClickSkipConstruction,
				Main.ME.settings.confirmGems ? Lang.t._("Finish this room immediatly?") : null
			);

			updateRoomButton(
				"skipRepair",
				"moneyGem",
				shotel.featureUnlocked("gems") && sroom.isDamaged() && isWorking() && t.end-Game.ME.serverTime>DateTools.seconds(15),
				onClickSkipRepair,
				Main.ME.settings.confirmGems ? Lang.t._("Repair this room immediatly?") : null
			);

			updateRoomButton(
				"skipWork",
				"moneyGem",
				sroom.canSkipWork() && shotel.featureUnlocked("gems") && !isUnderConstruction() && !sroom.isDamaged() && sroom.working,
				onClickSkipWork,
				Main.ME.settings.confirmGems ? Lang.t._("Free this room immediatly?") : null
			);

			if( !isUnderConstruction() && sroom.canBeBoosted() ) {
				updateRoomButton(
					"boost",
					"iconBattery",
					!sroom.hasBoost() && shotel.featureUnlocked("booster") && canBeBoostedNow() && !sroom.isDamaged(),
					onClickBoost
				);

			}

			updateRoomButton(
				"cancelBuild",
				"iconRemove",
				shotel.featureUnlocked("destroy") && isUnderConstruction(),
				onClickCancel
			);

			if( !isUnderConstruction() ) {
				var p = getProblem();
				if( p!=null && itime%20==0 )
					Game.ME.fx.roomWarning(this, p.icon);

				if( sroom.hasBoost() ) {
					if( itime%3==0 )
						Game.ME.fx.sparks(globalRight-80, globalCenterY-30, 0.5);
					if( itime%15==0 )
						Game.ME.fx.blinkIcon(globalRight-140, globalCenterY-30, "iconBoost", 0.7);

					if( boostIcon==null ) {
						boostIcon = Assets.tiles.hbe_get(Game.ME.tilesSb, "boostIcon", 0.5,0.5);
						boostIcon.setPos(globalRight-80, globalCenterY-30);
						boostBar = Assets.tiles.hbe_get(Game.ME.tilesSb, "white", 0.5,1);
						boostBar.setPos( boostIcon.x, boostIcon.y + boostIcon.height*0.5-26 );
						boostBar.width = 31;
						boostBar.height = 58;
					}
					if( !cd.hasSet("boostUpdate", Const.seconds(1)) ) {
						var t = sroom.getBoostEndTask();
						if( t!=null )
							boostBar.height = 58 * ( 0.1 + 0.9*(t.end-Game.ME.serverTime)/(t.end-t.start) );
					}
				}
				else {
					if( boostIcon!=null ) {
						boostIcon.remove();
						boostIcon = null;

						boostBar.remove();
						boostBar = null;
					}
				}

			}
		}




		// Hud visibility
		//if( !Game.ME.isVisitMode() ) {
			//var v = Game.ME.selection!=S_None || Game.ME.isDraggingClient() || ui.side.ItemMenu.CURRENT.isOpen;
			//for(e in hudElements)
				//e.visible = v;
		//}
	}
}
