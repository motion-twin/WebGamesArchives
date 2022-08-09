import mt.deepnight.Lib;
import mt.MLib;
import mt.data.GetText;
import com.*;
import com.Protocol;
import mt.flash.Key;
import b.Hotel;
import b.r.Bedroom;
import b.r.Lobby;
import b.Room;
import h2d.SpriteBatch;
import mt.deepnight.Tweenie;
import mt.deepnight.slb.*;
import Data;

enum Selection {
	S_None;
	S_Client(c:en.Client);
	S_Room(r:b.Room);
	//S_EmptySpace(rx:Int, ry:Int);
}

class Game extends H2dProcess {
	public static var ME : Game;

	var t					: mt.data.GetText;
	public var shotel		: com.SHotel;
	public var hotelRender	: b.Hotel;
	public var serverTime	: Float;
	var sTimeOffset			: Float;
	var nextTick			: Float;

	#if connected
	public var hdata(get,never)		: HotelData;
	public var pendingCmds			: Array<ClientServerRequest>;
	public var lastMsgId			: Int;
	#if dprot
	public var blockSend			: Bool;
	public var blockReceive			: Bool;
	#end
	public var debugProtocol		: Bool;
	#end
	public var debugEffects		: Bool;

	public var hideUI(default,null)	: Bool;

	var interactive			: h2d.Interactive;
	public var scroller		: h2d.Layers;
	public var monstersSb0	: h2d.SpriteBatch;
	public var monstersSb1	: h2d.SpriteBatch;
	public var monstersSb2	: h2d.SpriteBatch;
	public var tilesSb		: h2d.SpriteBatch;
	public var customsSb	: h2d.SpriteBatch;
	public var roomsSb		: h2d.SpriteBatch;
	public var roomsAddSb	: h2d.SpriteBatch;
	public var addSb		: h2d.SpriteBatch;
	public var bgSb			: h2d.SpriteBatch;
	public var textSbTiny	: h2d.SpriteBatch;
	public var textSbHuge	: h2d.SpriteBatch;
	public var textSbRoof	: h2d.SpriteBatch;
	public var tilesFrontSb	: h2d.SpriteBatch;
	public var hotelName	: Null<h2d.Sprite>;
	public var dark			: Null<h2d.Bitmap>;
	#if trailer
	public var trailerCursor: HSprite;
	#end

	public var drag			: Null<{ sx:Float, sy:Float, x:Float, y:Float, active:Bool, t:Float, c:Null<en.Client>, cox:Float, coy:Float, startedOverUi:Bool }>;
	public var pinching		: Bool;
	#if mobile
	var touchViewport 		: mt.flash.MultiTouchViewport;
	#end
	public var viewport		: Viewport;
	public var followCursor(default,set)	: Bool;
	public var baseScale	: Float;
	public var totalScale	: Float;
	public var isPlayingLogs: Bool;
	var commandChain		: Array<GameCommand>;
	var autoLvlUp			: Int;
	var happyCombo			: Int;
	public var turbo		: Bool;
	public var totalMoney	: Int;
	public var typing		: Bool;

	public var selection	: Selection;
	var hudLayer			: h2d.SpriteBatch;
	public var validRooms	: Map<String,Bool>;
	var rcorners			: Array<BatchElement>;
	var longPressBe			: Array<BatchElement>;

	public var shake		: Float;
	public var fx			: Fx;
	public var uiFx			: Fx;
	public var cm			: mt.deepnight.Cinematic;
	public var tuto			: ui.Tutorial;
	//var cursor				: Null<h2d.Bitmap>;

	var lastMouse			: { gx:Float, gy:Float, a:Null<Float> };

	public function new() {
		super(Main.ME.gameWrapper);

		#if cpp
		haxe.Timer.delay( function() cpp.vm.Gc.run(true), 30 );
		#end

		t = Lang.t;

		#if connected
			#if dprot
			debugProtocol = true;
			#else
			debugProtocol = false;
			#end
		#end
		typing = false;
		debugEffects = false;
		//#if debug
		//debugEffects = true;
		//#end
		name = "Game";
		ME = this;
		baseScale = totalScale = 1;
		totalMoney = -1;
		isPlayingLogs = false;
		selection = S_None;
		commandChain = [];
		shake = 0;
		happyCombo = 0;
		autoLvlUp = 0;
		rcorners = [];
		longPressBe = [];
		validRooms = new Map();
		nextTick = Date.now().getTime() + Solver.TICK_MS;
		#if connected
		pendingCmds = [];
		lastMsgId = -1;
		#end
		#if dprot
		blockReceive= false;
		blockSend = false;
		#end

		interactive = new h2d.Interactive(8, 8);
		Main.ME.uiWrapper.add(interactive, Const.DP_GAME_INTERACTIVE);
		interactive.enableRightButton = true;
		interactive.cursor = Default;
		interactive.onPush = onMouseDown;
		interactive.onRelease = onMouseUp;
		interactive.onWheel = onWheel;

		pinching = false;
		#if mobile
		touchViewport = new mt.flash.MultiTouchViewport();
		touchViewport.onStateChanged = onTouchStateChanged;
		touchViewport.doMove = onTouchMove;
		touchViewport.doZoom = onTouchZoom;
		#end

		cm = new mt.deepnight.Cinematic(Const.FPS);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_SCROLLER);
		#if debug scroller.name = "scroller"; #end
		viewport = new Viewport();

		textSbRoof = new h2d.SpriteBatch(Assets.fontRoof.tile);
		scroller.add(textSbRoof, Const.DP_GAME_FX);
		textSbRoof.filter = true;

		addSb = new h2d.SpriteBatch(Assets.tiles.tile);
		#if debug addSb.name = "addSb"; #end
		scroller.add(addSb, Const.DP_GAME_FX);
		addSb.blendMode = Add;

		monstersSb0 = new h2d.SpriteBatch(Assets.monsters0.tile);
		scroller.add(monstersSb0, Const.DP_CLIENT);
		monstersSb0.filter = true;
		#if debug monstersSb0.name = "monstersSb0"; #end

		monstersSb1 = new h2d.SpriteBatch(Assets.monsters1.tile);
		scroller.add(monstersSb1, Const.DP_CLIENT);
		monstersSb1.filter = true;
		#if debug monstersSb1.name = "monstersSb1"; #end

		monstersSb2 = new h2d.SpriteBatch(Assets.monsters2.tile);
		scroller.add(monstersSb2, Const.DP_CLIENT);
		monstersSb2.filter = true;
		#if debug monstersSb2.name = "monstersSb2"; #end

		bgSb = new h2d.SpriteBatch(Assets.bg.tile);
		scroller.add(bgSb, Const.DP_ROOM_BATCH);
		bgSb.filter = true;
		bgSb.name = "bgSb";

		roomsSb = new h2d.SpriteBatch(Assets.rooms.tile);
		scroller.add(roomsSb, Const.DP_ROOM_BATCH);
		roomsSb.filter = true;
		roomsSb.name = "roomsSb";

		tilesSb = new h2d.SpriteBatch(Assets.tiles.tile);
		scroller.add(tilesSb, Const.DP_ROOM_BATCH);
		tilesSb.filter = true;
		tilesSb.name = "tilesSb";

		customsSb = new h2d.SpriteBatch(Assets.custo0.tile);
		scroller.add(customsSb, Const.DP_ROOM_BATCH);
		customsSb.filter = true;
		customsSb.name = "customsSb";

		roomsAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		scroller.add(roomsAddSb, Const.DP_ROOM_BATCH);
		roomsAddSb.name = "roomsAddSb";
		roomsAddSb.blendMode = Add;

		tilesFrontSb = new h2d.SpriteBatch(Assets.tiles.tile);
		scroller.add(tilesFrontSb, Const.DP_ROOM_BATCH_FRONT);
		tilesFrontSb.filter = true;
		#if debug tilesFrontSb.name = "tilesFrontSb"; #end

		textSbTiny = new h2d.SpriteBatch(Assets.fontTiny.tile);
		scroller.add(textSbTiny, Const.DP_CTX_UI);
		textSbTiny.filter = true;

		textSbHuge = new h2d.SpriteBatch(Assets.fontHuge.tile);
		scroller.add(textSbHuge, Const.DP_CTX_UI);
		textSbHuge.filter = true;

		#if trailer
		trailerCursor = Assets.tiles.h_get("tutoHand");
		Main.ME.uiWrapper.add(trailerCursor, Const.DP_MASK);
		trailerCursor.setPivotCoord(30,30);
		trailerCursor.setScale(1.25);
		trailerCursor.visible = false;
		trailerCursor.filter = true;
		#end

		//var w = new h2d.Sprite();
		//root.add(w, Const.DP_POP_UP);

		// Load previous state
		#if connected
		lastMsgId = hdata.lastMsgId;
		netLog("Game started: clientId="+Main.ME.clientId+" lastMsgId="+lastMsgId);
		shotel = new com.SHotel(hdata.state);
		setServerTime(hdata.serverTime);
		if( !isVisitMode() ) {
			loadPendingCommands();
			#if android
			sendServerCommand( CS_BecomeMainClient(DT_Android), true );
			#elseif ios
			sendServerCommand( CS_BecomeMainClient(DT_Ios), true );
			#else
			sendServerCommand( CS_BecomeMainClient(DT_Web), true );
			#end
			netLog("Cookie pending commands: "+pendingCmds.length);
			if( pendingCmds.length>0 ) {
				// Re-do all pending commands
				try {
					var ok = 0;
					for( pc in pendingCmds.copy() )
						if( runClientServerRequestSilently(pc) )
							ok++;
					lastMsgId+=ok;
					netLog("lastMsgId="+lastMsgId, 0xC0C0C0);
				} catch(e:Dynamic) {
					clearPendingCommands();
					sendMiscCommand( MC_AskSync );
				}
			}
		}
		#else
		setServerTime( Date.now().getTime() );
		var s = loadCookieState();
		try {
			if( s==null )
				resetSave(false,false);
			else
				shotel = new com.SHotel(s);
		}
		catch(e:Dynamic) {
			resetSave(false,false);
		}
		#end

		hotelRender = new b.Hotel();

		hudLayer = new h2d.SpriteBatch(Assets.tiles.tile);
		scroller.add(hudLayer, Const.DP_CTX_UI);
		hudLayer.filter = true;

		tuto = new ui.Tutorial();
		new ui.MainStatus();
		new ui.CornerMenu();
		//new ui.XpBar();
		new ui.HudMenu();
		#if connected
		new ui.NetworkStatus();
		#end
		new ui.MassMenu();
		new ui.side.Quests();
		new ui.QuestLog();
		new ui.Stocks();
		new ui.LunchBoxMenu();
		new ui.Notification.NotificationManager();
		#if (connected && !mBase)
		if( !mt.device.User.isLogged() )
			new ui.UnloggedMenu();
		#end
		#if dprot
		if( !isVisitMode() )
			new ui.NetworkDebug();
		#end

		var fxWrapper = new h2d.Layers();
		scroller.add(fxWrapper, Const.DP_GAME_FX);
		fx = new Fx(this, fxWrapper);

		var fxWrapper = new h2d.Layers();
		Main.ME.uiWrapper.add(fxWrapper, Const.DP_UI_FX);
		uiFx = new Fx(this, fxWrapper);

		mt.Process.resizeAll();
		attach();


		// Center view
		var lobby = hotelRender.getRooms(R_Lobby)[0];
		viewport.x = lobby.globalCenterX;
		viewport.y = lobby.globalCenterY-Const.ROOM_HEI;

		#if debug
		onNextUpdate = function() {
			var g = new h2d.Graphics(scroller);
			g.beginFill(0xFF0000, 0.6);
			g.drawCircle(0,0,10);
			g.endFill();
		}
		#end

		if( !isVisitMode() ) {
			runSolverCommand(DoClientReady);

			//#if debug
			//var d = Date.now().getTime() - DateTools.hours(17) - DateTools.minutes(44);
			//var d = Date.fromTime(d);
			//runSolverCommand( DoLoginPopUps(d.toString()) ); // HACK (fake timezone)
			//#else
			runSolverCommand( DoLoginPopUps(Date.now().toString()) );
			//#end

		}


		for(c in en.Client.ALL)
			if( !c.destroyAsked )
				c.updateHappiness();

		ui.MainStatus.CURRENT.updateInfos();

		SoundMan.ME.enableRadioLoops();
		SoundMan.ME.startAmbiant();

		new ui.side.PremiumShop();
		new ui.side.BuildMenu();
		new ui.side.ItemMenu();
		new ui.side.CustomizeMenu();
		new ui.side.Inbox();
		new ui.side.Contacts();

		ui.MassMenu.CURRENT.refresh();
		ui.QuestLog.CURRENT.refresh();

		// Track FPS
		#if connected
		for(d in [6,60]){
			delayer.add( function(){
				var o = {};
				Reflect.setField(o,"fps",MLib.round(Main.ME.avgFps));
				Reflect.setField(o,"delay",d);
				Reflect.setField(o,"w",mt.Metrics.w());
				Reflect.setField(o,"h",mt.Metrics.h());
				#if flash
				Reflect.setField(o,"soft",!h3d.Engine.getCurrent().driver.isHardware());
				Reflect.setField(o,"caps",haxe.Json.parse(mt.Lib.getNativeCaps()));
				#end
				mt.device.EventTracker.twTrack("fps+", o);
			}, d*1000.0 );
		}
		#end

		var m = getMouse();
		lastMouse = { gx:m.ux, gy:m.uy, a:0 }
		followCursor = false;

		// Hotel owner
		if( isVisitMode() ) {
			hotelName = new h2d.Sprite();
			Main.ME.uiWrapper.add(hotelName, Const.DP_BARS);

			var bg = Assets.tiles.getColoredH2dBitmap("popUpBg",Const.BLUE, true, hotelName);
			bg.tile.setCenterRatio(0.5, 0);

			Assets.tiles.getH2dBitmap("popUpTop",0, 0.5, 0.5, true, hotelName);

			var name = Assets.createText(48, Const.TEXT_GOLD, getUserName(), hotelName);
			name.x = Std.int( -name.textWidth*name.scaleX*0.5 );

			var score = Assets.createText(34, 0xFFE3B0, Lang.t._("::n:: points", {n:prettyNumber( getHotelScore() )}), hotelName);
			score.x = Std.int( -score.textWidth*score.scaleX*0.5 );
			score.y = name.textHeight*name.scaleY;
			bg.height = name.textHeight*name.scaleY + score.textHeight*score.scaleY;

			var e = Assets.tiles.getH2dBitmap("popUpBottom",0, 0.5, 0.5, true, hotelName);
			e.y = bg.height;


			hotelName.x = Main.ME.w()*0.5;
			hotelName.y = 70;

			viewport.setUserZoom(0.7);

			new ui.VisitMenu();
		}

		// Visit mode global teint
		if( isVisitMode() ) {
			var m = new h3d.Matrix();
			Main.ME.gameWrapper.colorMatrix = m;
			m.colorSaturation(0.65);

			dark = Assets.tiles.getH2dBitmap("roomVignetage", true);
			root.add(dark, Const.DP_FRONT);
			dark.width = this.w();
			dark.height = this.h();
		}
		else
			Main.ME.gameWrapper.colorMatrix = null;


		#if debug
		delayer.add(function() {
		},1000);
		#end

		#if connected
		flushNetworkBuffer();
		#end

		hotelRender.getLobby().updateClientCache();
		if( !isVisitMode() && !shotel.isPrepared() )
			new page.IntroCinematic();

		#if( mBase && demo )
		new ui.Notification(Lang.untranslated("Connected to DEMO server."), "iconUse");
		#end
	}

	public inline function getUserName() {
		return #if connected hdata.owner #else "deepnight" #end;
	}

	public function getHotelScore() {
		return Solver.getHotelScore( shotel.getState() );
	}


	#if connected
	inline function get_hdata() return Main.ME.hdata;
	#end

	public inline function isVisitMode() {
		#if connected
		return Main.ME.hdata.visitMode != VM_None;
		#else
		return false;
		#end
	}

	public inline function isVisitFromUrl() {
		#if connected
		return Main.ME.hdata.visitMode==VM_VisitUrl;
		#else
		return false;
		#end
	}



	function setUiVisibility(v) {
		hideUI = !v;
		for(r in hotelRender.rooms)
			if( v )
				r.showHud();
			else
				r.hideHud();

		Main.ME.uiWrapper.visible = !hideUI;
		ui.HudMenu.CURRENT.root.visible = !hideUI;

		for( c in en.Client.ALL )
			c.updateHappiness( hideUI ? -1 : null );
	}


	public function reboot() {
		if( destroyed )
			return;

		netLog("REBOOT ASKED!", 0xFF00FF);
		Main.ME.transition( function() return new Game() );
	}


	public function hasAnyPopUp() {
		return ui.Question.CURRENT!=null || ui.Consortium.CURRENT!=null #if connected || ui.Cash.CURRENT!=null #end;
	}


	#if !connected
	public function saveCookieState() {
		var s = shotel.getState();
		var raw = haxe.Serializer.run(s);
		Lib.setCookie("cm2", "hotel", raw);
		Lib.setCookie("cm2", "version", Protocol.DATA_VERSION);
	}

	public function loadCookieState() : HotelState {
		var raw : String = Lib.getCookie("cm2", "hotel", null);

		if( raw!=null ) {
			var s : HotelState = try { haxe.Unserializer.run(raw); } catch(e:Dynamic) null;
			var v = Lib.getCookie("cm2", "version", 0);
			if( s!=null ) {
				Solver.patchState(v, s);
				return s;
			}
			else
				return null;
		}
		else
			return null;
	}

	public function resetSave(confirm:Bool, restart:Bool, ?s:HotelState) {
		function _r() {
			shotel = new com.SHotel( s!=null ? s : SHotel.makeNewHotelState(serverTime) );
			saveCookieState();
			if( restart )
				reboot();
		}
		if( confirm ) {
			var q = new ui.Question();
			q.addButton(cast "Reset save!", _r);
			q.addCancel();
		}
		else
			_r();
	}
	#end


	public inline function netLog(msg:String, ?col) {
		#if( !mobile && connected )
		if( debugProtocol )
			#if console
			Main.ME.console.log(msg, col);
			#else
			trace(msg);
			#end
		#end
	}

	public inline function debug(msg:String, ?col) {
		#if( debug && console )
		Main.ME.console.log(msg, col);
		#end
	}


	#if connected
	public function flushNetworkBuffer() {
		if( isVisitMode() )
			return;

		if( isClientInvalid() )
			return;

		var cmds = pendingCmds.copy();
		ui.NetworkStatus.CURRENT.onCommandsSent();

		#if dprot
		if( blockSend )
			return;

		for( sc in cmds )
			netLog("Sending: #"+sc.msgId+"  "+sc.c, 0x97DDFF);
		#end

		cd.set("netFlush", Const.seconds(Const.NET_BUFFER_DURATION_SEC));
		mt.net.Codec.requestUrl("/v/"+com.Protocol.DATA_VERSION+"/cmd/" + hdata.realHotelId, cmds, onServerData, onServerError );
	}


	inline function sortPendingCommands() {
		pendingCmds.sort( function(a,b) return Reflect.compare(a.msgId, b.msgId) );
	}

	function loadPendingCommands() {
		if( isVisitMode() )
			return;

		var raw = mt.deepnight.Lib.getCookie("cm2", "release_"+hdata.realHotelId);
		if( raw!=null ) {
			pendingCmds = try{ haxe.Unserializer.run(raw); } catch(e:Dynamic) { []; }
			for(pc in pendingCmds) {
				pc.cid = Main.ME.clientId;
				pc.v = Main.ME.getClientVersion();
			}
			sortPendingCommands();
		}
	}

	function savePendingCommands() {
		if( isVisitMode() )
			return;

		sortPendingCommands();
		var raw = haxe.Serializer.run(pendingCmds);

		#if flash
		if( !Lib.setCookie("cm2", "release_"+hdata.realHotelId, raw) && fx!=null ) {
			if( !hasAnyPopUp() && !cd.hasSet("cookieError", 999999) ) {
				var q = new ui.Question(true);
				q.addText( Lang.t._("Something prevented your game data from being saved: your progress could be lost :(") );
				q.addText( Lang.t._("1- Enable the flash cookies in the Flash Player settings (right click the game, choose Settings, click the yellow folder icon, uncheck \"Never\", allow at least 100kb)") );
				q.addText( Lang.t._("2- Try to disable any AD-BLOCKER extension or software for this website") );
				q.addText( Lang.t._("3- Check your FIREWALL: the game and the browser should not be blocked") );
				q.addCancel( Lang.t._("Ok") );
			}
		}
		#else
		Lib.setCookie("cm2", "release_"+hdata.realHotelId, raw);
		#end
		//Lib.setCookie("cm2", "release_"+hdata.realHotelId, raw);
	}

	function clearPendingCommands() {
		if( isVisitMode() )
			return;

		pendingCmds = [];
		savePendingCommands();
	}

	function removePendingCommandsBelow(id:Int, incl:Bool) {
		for(c in pendingCmds)
			if( incl && c.msgId<=id || !incl && c.msgId<id )
				pendingCmds.remove(c);
		savePendingCommands();
	}

	public function renumberPendingCommands(fromId:Int) {
		sortPendingCommands();
		for(c in pendingCmds)
			c.msgId = fromId++;
		savePendingCommands();

		netLog("Renumbered pending commands ("+pendingCmds.length+"):", 0xFF0000);
		for(c in pendingCmds)
			netLog("    #"+c.msgId+" "+Std.string(c.c).substr(0,30), 0xB4B9CD);
	}

	function removePendingCommand(msgId:Int) {
		if( isVisitMode() )
			return;

		var i = 0;
		while( i < pendingCmds.length )
			if( pendingCmds[i].msgId == msgId )
				pendingCmds.splice(i,1);
			else
				i++;

		savePendingCommands();
	}


	function addPendingCommand(r:ClientServerRequest) {
		pendingCmds.push(r);
		savePendingCommands();
	}

	function prependPendingCommand(r:ClientServerRequest) {
		pendingCmds.insert(0,r);
		savePendingCommands();
	}



	public function sendMiscCommand(c:MiscCommand) {
		#if dprot
		netLog("Sending (MiscCommand): "+Std.string(c).substr(0,60), 0xE097FF);
		#end
		mt.net.Codec.requestUrl("/v/"+com.Protocol.DATA_VERSION+"/miscCmd/" + hdata.realHotelId, c, onServerData, onServerError);
	}

	public function sendServerCommand( cs:ClientServerCommand, ?prepend=false ) {
		if( isVisitMode() )
			return;

		var inc = Protocol.commandNeedsMsgIdInc(cs);
		var r : ClientServerRequest = {
			v		: Main.ME.getClientVersion(),
			msgId	: inc ? ++lastMsgId : lastMsgId,
			cid		: Main.ME.clientId,
			c		: cs,
		}

		if( prepend )
			prependPendingCommand(r);
		else
			addPendingCommand(r);

		if( !cd.has("netFlush") )
			cd.set("netFlush", Const.seconds(Const.NET_BUFFER_DURATION_SEC), true);
	}

	public inline function isClientInvalid() {
		return cd.has("invalidClient");
	}

	function onServerData( responses:ServerResponses ) {
		#if dprot
		if( blockReceive )
			return;
		#end

		if( destroyed )
			return;

		for(r in responses) {
			if( r.getIndex()!=SR_Print(null).getIndex() )
				netLog(Std.string(r).substr(0,50), 0x80FF00);

			switch( r ) {
				case SR_ClientIdMismatch :
					if( !cd.hasSet("invalidClient", 999999) ) {
						var q = new ui.Question(false);
						q.addText( Lang.t._("It looks like the game is already opened on another device or browser.") );
						q.addText( Lang.t._("You should not run Monster Hotel on different devices at the same time :)") );
						q.addButton( Lang.t._("Disconnect the other one"), "iconRecycle", function() {
							if( !cd.hasSet("rebootCid", 99999) ) {
								new ui.Loading( sendMiscCommand.bind( MC_AskSync ) );
							}
						});
					}

				case SR_ClientOutdated(old,v) :
					if( !cd.hasSet("invalidClient", 999999) ) {
						var q = new ui.Question(false);
						q.addText( Lang.t._("Great news!") );
						q.addText( Lang.t._("A new version of the game is available! Please reload the page to update it :)") );
						#if mobile
						q.addText( Lang.t._("You should update the game now to continue playing. We apologize for any inconvenience!"), Const.TEXT_GRAY );
						q.addButton( Lang.t._("Update Monster Hotel"), "iconRecycle", function() {
							// TODO: appstore
						});
						#else
						q.addButton( Lang.t._("Update the game"), "iconRecycle", function() {
							SoundMan.ME.stopEverything();
							Game.ME.destroy();
							flash.external.ExternalInterface.call("reload");
						});
						#end
					}

				case SR_Time(t) :
					setServerTime(t);
					if( cd.has("manualSync") ) {
						runSolverCommand(DoPing);
						cd.unset("manualSync");
					}
					nextTick = Date.now().getTime() + Solver.TICK_MS;

				case SR_Resync(last,s) :
					Main.ME.currentVisit = null;
					Main.ME.visitMyHotel = null;
					Main.ME.hdata.visitMode = VM_None;
					rebootWithState(last, s);

				case SR_Print(s) :
					#if console
					Main.ME.console.log(s, 0xFFCC00);
					#else
					new ui.Notification(s, 0xFFCC00, "iconClean");
					#end

				case SR_FriendsHotels(arr) :
					if( ui.side.Contacts.CURRENT != null )
						ui.side.Contacts.CURRENT.onFriendsLoaded( arr );

				case SR_Visit(fh, s) :
					if( fh==null || s==null ) {
						var q = new ui.Question();
						q.addText( Lang.t._("This hotel cannot be visited right now: its owner is playing on a different version of the game.") );
						q.addCancel();
						if( ui.Loading.exists() )
							ui.Loading.cancel();
					}
					else if( ui.Loading.exists() ) {
						if( Main.ME.visitMyHotel==null )
							Main.ME.visitMyHotel = shotel.getState();
						Main.ME.currentVisit = fh;
						Main.ME.hdata.visitMode = VM_VisitInGame;
						Main.ME.hdata.owner = fh.owner.name;
						Main.ME.hdata.curHotelId = fh.hotel.id;
						rebootWithState(lastMsgId, s);
					}

				case SR_AlreadyProcessed(rid) :
					netLog("Server already processed #"+rid, 0xFF8000);
					removePendingCommand(rid);
					//removePendingCommandsBelow(rid, true);


				case SR_MissedCommand(eid, s) :
					sortPendingCommands();
					removePendingCommandsBelow(eid, false);

					// Server missed a command and I still have it
					if( pendingCmds.length>0 && pendingCmds[0].msgId==eid ) {
						netLog("Server missed command "+eid+", resending...", 0xFF8000);
						flushNetworkBuffer();
						//sendToServer(pendingCmds);
					}
					else {
						netLog("Server missed command "+eid+", and I don't have it",0xFF0000);
						//var q = new ui.Question(false);
						//q.addCenteredSprite( Assets.tiles.getH2dBitmap("iconMail") );
						//q.addText( Lang.untranslated("COMMAND MISSED") );
						//q.addText( Lang.untranslated("Missed command ID="+eid) );
						//q.addText( Lang.untranslated("Pendings="+pendingCmds.length) );
						//if( pendingCmds.length>0 )
							//q.addText( Lang.untranslated("FirstPending="+pendingCmds[0].msgId) );
						//q.addButton( Lang.t._("Reload"), "iconRecycle", function() {
							renumberPendingCommands(eid);
							rebootWithState(eid-1, s);
						//});
					}


				case SR_CommandResults(oks, noks, lastMid, s) :
					#if mobile
					if( pendingCmds.length>Protocol.REFUSALS_FOR_CLOUD_SAVE && noks.length>Protocol.REFUSALS_FOR_CLOUD_SAVE ) {
						// Lots is about to be lost, try a brutal cloud save
						clearPendingCommands();
						sendMiscCommand( MC_CloudSave(com.Protocol.DATA_VERSION, shotel.getState()) );
						new ui.Loading();
						oks = [];
						noks = [];
					}
					#end


					if( oks.length>0 ) {
						// Is this a command I sent?
						for(id in oks) {
							var found = false;
							for(pc in pendingCmds)
								if( pc.msgId==id ) {
									removePendingCommand(id);
									found = true;
								}

							if( !found )
								netLog("Unknown server Msg#"+id, 0xFF0000);
						}
					}

					if( noks.length>0 ) {
						// Server-side solver refused some commands
						netLog("Server refused "+noks.length+" command(s): "+noks.join(", "), 0xFF0000);
						for(eid in noks)
							removePendingCommand(eid);

						renumberPendingCommands(lastMid+1);
						rebootWithState(lastMid, s);
					}


				case SR_BankSync(gems,gold,t):
					runAfterPlayback(function() {
						if( shotel.gems!=gems ) {
							ui.MainStatus.CURRENT.shakeGem();
							shotel.gems = gems;
						}

						if( shotel.money!=gold ) {
							ui.MainStatus.CURRENT.shakeGold();
							shotel.money = gold;
						}

						ui.MainStatus.CURRENT.updateInfos();

						if( t!=null && t.value>0 )
							switch( t.type ) {
								case "gems" :
									var r = new ui.Reward();
									r.addItem(I_Gem, t.value);

								case "gold" :
									var r = new ui.Reward();
									r.addItem( I_Money(t.value), 1 );
							}
					});

				case SR_InboxSync(unread):
					if( unread>Main.ME.hdata.inboxCount )
						Assets.SBANK.inbox().play(1, 0.5);
					Main.ME.hdata.inboxCount = unread;
					ui.HudMenu.CURRENT.setCounter("inbox", Main.ME.hdata.inboxCount);

				case SR_HotelMessages(a) :
					shotel.messages = a;
					ui.side.Inbox.CURRENT.onHotelMessagesLoaded();
			}
		}

		ui.NetworkStatus.CURRENT.onServerResponse();
	}



	function onServerError( e ) {
		if( destroyed )
			return;

		#if dprot
		if( blockReceive )
			return;
		#end

		netLog("Server fatal: "+e, 0xFF0000);
	}

	function rebootWithState(lastMsgId, stateOverride:HotelState) {
		if( destroyed )
			return;

		hdata.state = stateOverride;
		hdata.lastMsgId = lastMsgId;
		hdata.serverTime = serverTime;
		reboot();
	}

	public function bankSync(){
		mt.net.Codec.requestUrl("/bankSync/" + hdata.realHotelId, null, onServerData, onServerError );
	}

	public function inboxSync(){
		mt.net.Codec.requestUrl("/inboxSync", null, onServerData, onServerError );
	}
	#end



	public function onBack() {
		if( tuto.isRunning() )
			return false;

		#if mBase
		if( ui.WebView.CURRENT!=null ) {
			ui.WebView.CURRENT.onBack();
			return false;
		}
		#end

		if( ui.Question.CURRENT!=null ) {
			ui.Question.CURRENT.onBack();
			return false;
		}

		var e = ui.SideMenu.getOpened();
		if( e!=null ) {
			e.onBack();
			return false;
		}

		if( ui.Loading.exists() && ui.Loading.isCancellable() ) {
			ui.Loading.cancel();
			return false;
		}

		#if mBase
		if( ui.Cash.CURRENT!=null ) {
			ui.Cash.CURRENT.onBack();
			return false;
		}
		#end

		#if connected
		flushNetworkBuffer();
		#end

		#if ios
		return false;
		#elseif (android && mBase)
		var q = new ui.Question();
		q.addText(Lang.t._("Exit game?"));
		q.addButton( Lang.t._("Yes, see you later!"), App.current.leaveApp );
		q.addButton( Lang.t._("Cancel") );
		return false;
		#else
		return true;
		#end
	}


	function setServerTime(t:Float) {
		serverTime = t;
		sTimeOffset = serverTime-Date.now().getTime();
		netLog("serverTime="+Lib.prettyTime(serverTime)+" offset="+sTimeOffset+" ("+Lib.prettyTime(sTimeOffset)+")", 0x00FFFF);
	}


	override function onResize() {
		super.onResize();

		interactive.width = mt.Metrics.w();
		interactive.height = mt.Metrics.h();

		updateScale();
		updateScroller();
		hotelRender.update();
	}

	public function updateScale() {
		var rw = mt.Metrics.wcm()>=14 ? 5 : 3;
		var rh = rw+1;
		var iwid = Std.int(Const.ROOM_WID*rw);
		var ihei = Std.int(Const.ROOM_HEI*rh);

		baseScale = MLib.fmin( mt.Metrics.w()/iwid, mt.Metrics.h()/ihei );
		//if( time%15==0 ) debug("base="+baseScale+" total="+totalScale+" ideal="+iwid+"x"+ihei+" screen="+mt.Metrics.w()+"x"+mt.Metrics.h());

		totalScale = baseScale * viewport.getZoom();
		root.scaleX = root.scaleY = totalScale;
	}


	public override function w() return MLib.ceil( super.w()/totalScale );
	public override function h() return MLib.ceil( super.h()/totalScale );



	override function onDispose() {
		//flash.Lib.current.stage.removeEventListener(flash.events.KeyboardEvent.KEY_UP, onKeyUp);

		for( e in Entity.ALL )
			e.destroy();
		Entity.garbageCollector();

		for( e in MinorEntity.ALL )
			e.destroy();
		MinorEntity.garbageCollector();

		if( hotelName!=null ) {
			hotelName.dispose();
			hotelName = null;
		}

		#if mBase
		if( ui.WebView.CURRENT!=null )
			ui.WebView.CURRENT.destroy();
		#end

		if( ui.Friends.CURRENT!=null )
			ui.Friends.CURRENT.destroy();

		#if connected
		if( ui.Cash.CURRENT!=null )
			ui.Cash.CURRENT.destroy();
		#end

		drag = null;
		commandChain = null;
		validRooms = null;

		hudLayer.dispose();
		hudLayer = null;

		monstersSb0.dispose();
		monstersSb0 = null;

		monstersSb1.dispose();
		monstersSb1 = null;

		monstersSb2.dispose();
		monstersSb2 = null;

		roomsSb.dispose();
		roomsSb = null;

		roomsAddSb.dispose();
		roomsAddSb = null;

		customsSb.dispose();
		customsSb = null;

		tilesSb.dispose();
		tilesSb = null;

		tilesFrontSb.dispose();
		tilesFrontSb = null;

		addSb.dispose();
		addSb = null;

		textSbTiny.dispose();
		textSbTiny = null;

		textSbHuge.dispose();
		textSbHuge = null;

		textSbRoof.dispose();
		textSbRoof = null;

		fx.destroy();
		fx = null;

		uiFx.destroy();
		uiFx = null;

		hotelRender.destroy();
		hotelRender = null;

		scroller.dispose();
		scroller = null;

		interactive.dispose();
		interactive = null;

		shotel.destroy();
		shotel = null;

		viewport.destroy();
		viewport = null;

		selection = null;
		rcorners = null;
		longPressBe = null;

		#if mobile
		touchViewport.unregister();
		touchViewport = null;
		#end

		super.onDispose();

		if( ME==this )
			ME = null;
	}



	public function attach() {
		// Clean up
		unselect();
		hotelRender.detach();

		for(e in en.Client.ALL)
			e.destroy();

		for(e in en.Groom.ALL)
			e.destroy();

		// Hotel + rooms
		hotelRender.attach();

		// Clients
		for( sc in shotel.clients )
			attachClient(sc);

		// Finalize
		for( r in hotelRender.rooms )
			r.finalize();

		//ui.Queue.CURRENT.updateContent();
	}


	function attachClient(sc:SClient) {
		var r = sc.room==null ? b.r.Lobby.CURRENT : hotelRender.getRoomAt(sc.room.cx, sc.room.cy);
		var e : en.Client = switch( sc.type ) {
			case C_Liker : new en.c.Liker(sc.id, r);
			case C_Neighbour : new en.c.Neighbour(sc.id, r);
			case C_Disliker : new en.c.Disliker(sc.id, r);
			case C_MobSpawner : new en.c.MobSpawner(sc.id, r);
			case C_Spawnling : new en.c.Spawnling(sc.id, r);
			case C_Custom : new en.c.Custom(sc.id, r);
			case C_Vampire : new en.c.Vampire(sc.id, r);
			case C_Bomb : new en.c.Bomb(sc.id, r);
			case C_Repairer : new en.c.Repairer(sc.id, r);
			case C_Plant : new en.c.Plant(sc.id, r);
			case C_HappyLine : new en.c.HappyLine(sc.id, r);
			case C_HappyColumn : new en.c.HappyColumn(sc.id, r);
			case C_Inspector : new en.c.Inspector(sc.id, r);
			case C_Gifter : new en.c.Gifter(sc.id, r);
			case C_Gem : new en.c.GemSpawner(sc.id, r);
			case C_Rich : new en.c.Rich(sc.id, r);
			case C_JoyBomb : new en.c.JoyBomb(sc.id, r);
			case C_Dragon : new en.c.Dragon(sc.id, r);
			case C_Emitter : new en.c.Emitter(sc.id, r);
			case C_MoneyGiver : new en.c.MoneyGiver(sc.id, r);
			case C_Halloween : new en.c.Halloween(sc.id, r);
			case C_Christmas: new en.c.Christmas(sc.id, r);
		}
		//e.updateCoords();
		return e;
	}



	public inline function prettyMoney(sum:Int) : LocaleString {
		return t._("::n:: GOLD", {n:prettyNumber(sum)});
	}

	public function prettyNumber(total:Int) : LocaleString {
		var a = Std.string(total).split("");
		var i = a.length-1;
		var n = 0;
		while( i>=0 ) {
			n++;
			if( n>=3 && i>0 ) {
				n = 0;
				a.insert(i," ");
			}
			i--;
		}
		return cast a.join("");
	}

	public function prettyTime(?label="%time%", end:Float) : LocaleString {
		var t = MLib.fmax( -1000, end-serverTime );
		var r = DateTools.parse(t);

		function out(str:String) : LocaleString {
			return cast StringTools.replace(label, "%time%", str);
		}

		return if( t<0 ) this.t._("Loading...");
		else if( r.hours==0 && r.minutes==0 && r.seconds==0 ) this.t._("Imminent!");
		else if( r.days>10 ) 					this.t._("One year");
		else if( r.days>=2 ) 					this.t._("::n:: days", {n:r.days});
		else if( r.days==1 ) 					this.t._("1 day");
		else if( r.hours>0 && r.minutes==0)		out(r.hours+"h");
		else if( r.hours>0 )					out(r.hours+"h" + Lib.leadingZeros(r.minutes));
		else if( r.minutes>=10 || r.seconds==0 )out(r.minutes+"min");
		else if( r.minutes>0 )					out(r.minutes+"min " + Lib.leadingZeros(r.seconds)+"s");
		else if( r.seconds>0 )					out(r.seconds+"sec");
		else this.t._("Loading...");
	}

	#if mobile
	function onTouchStateChanged(state:mt.flash.MultiTouchViewport.ViewportState ){
		pinching = state==V_Scaling;
		if( pinching ){
			viewport.zoomLocked = false;
			cancelDrag();
		}
	}

	function onTouchMove(dx:Float,dy:Float){
		if( !pinching ) return;
		viewport.x -= dx / totalScale;
		viewport.y -= dy / totalScale;
		updateScroller();
	}

	function onTouchZoom(delta:Float,cx:Float,cy:Float){
		if( !pinching ) return;

		var lx = (cx-scroller.x*totalScale) / totalScale;
		var ly = (cy-scroller.y*totalScale) / totalScale;

		viewport.deltaZoomRatio( delta );
		updateScale();
		updateScroller();

		var ncx = lx*totalScale + scroller.x*totalScale;
		var ncy = ly*totalScale + scroller.y*totalScale;

		viewport.x += (ncx-cx) / totalScale;
		viewport.y += (ncy-cy) / totalScale;
		updateScroller();
	}
	#end

	public function onWheel(e:hxd.Event) {
		viewport.deltaZoom( -e.wheelDelta*0.05 );
		updateScale();
		updateScroller();
		//onResize();
	}

	public function onMouseDown(e:hxd.Event) {
		if( destroyed || pinching )
			return;

		var m = getMouse();
		drag = { sx:m.sx, sy:m.sy, x:m.x, y:m.y, active:false, t:ftime, c:null, cox:0, coy:0, startedOverUi:false }
		viewport.zoomLocked = true;
		var c = getClosestClient(drag.sx, drag.sy);
		if( c!=null )
			c.cd.set("wait", Const.seconds(1.2));
	}



	public function setCinematicLock(d:Float) cd.set("cinematicLock", d);
	public inline function hasCinematicLock() return cd.has("cinematicLock");

	public function onMouseUp(e:hxd.Event) {
		if( destroyed )
			return;

		viewport.zoomLocked = false;

		if( !hasCinematicLock() && !pinching ) {
			if( drag!=null && !drag.active && !tuto.commandLocked("click") )
				onLeftClick();

			if( !isVisitMode() && drag!=null && drag.active && drag.c!=null )
				onDragClient(drag.c);
		}

		clearLongPress(false);
		tuto.updateLockedSelection();
		cancelDrag();
	}

	public function moveDraggedClientBack() {
		if( drag!=null && drag.c!=null && !drag.c.destroyAsked ) {
			var c = drag.c;

			var m = getMouse();
			if( Lib.distanceSqr(m.sx, m.sy, drag.cox, drag.coy)>=300*300 ) {
				// Ghost moves back into position
				var s = new h2d.Bitmap(c.spr.tile.clone());
				scroller.add(s, Const.DP_GAME_FX);
				s.setPos(c.spr.x, c.spr.y);
				s.scaleX = c.spr.scaleX;
				s.scaleY = c.spr.scaleY;
				s.blendMode = Add;
				var d = 300;
				tw.create(s.x, drag.cox, d);
				tw.create(s.y, drag.coy, d);
				tw.create(s.alpha, 0, d).onEnd = function() {
					s.dispose();
				}

				fx.cancelFeedback(m.sx, m.sy);
				viewport.focus(drag.cox, drag.coy + (c.isWaiting() ? -viewport.hei*0.25 : 0));
			}

			c.setPos(drag.cox, drag.coy);
		}
	}

	inline function set_followCursor(v) {
		followCursor = v;
		if( followCursor )
			lastMouse.a = null;
		return followCursor;
	}

	public function cancelDrag() {
		if( destroyed )
			return;

		if( drag!=null && drag.c!=null && !drag.c.destroyAsked )
			drag.c.cd.unset("dragged");

		clearHudLayer();
		followCursor = false;
		viewport.resetForcedZoom();
		drag = null;
	}

	function startClientDrag(c:en.Client) {
		if( tuto.commandLocked("click") )
			return;

		if( isVisitMode() )
			return;

		viewport.zoomLocked = false;
		drag.c = c;
		drag.cox = c.xx;
		drag.coy = c.yy;
		fx.clientDragStarted(c);
		followCursor = true;

		viewport.forceZoomOut();
		Assets.SBANK.drag(1);
		ui.SideMenu.closeAll();

		clearHudLayer();

		if( c.isWaiting() ) {
			// Install to a bedroom
			for(r in hotelRender.rooms) {
				if( r.isWorking() || r.isUnderConstruction() )
					continue;

				switch( r.sroom.type ) {
					case R_Bedroom :
						if( r.countClients()==0 )
							hudRoom(r.rx, r.ry);

					case R_Trash : hudRoom(r.rx, r.ry, "iconKick");
					case R_ClientRecycler : hudRoom(r.rx, r.ry, "iconRecycle");

					default :
				}
			}
		}
		else {
			// Send to utility
			for( r in hotelRender.rooms ) {
				if( r.isUnderConstruction() || r.isWorking() )
					continue;

				var k = switch( r.sroom.type ) {
					case R_Bar : c.sclient.money<=0 ? "iconForbidden" : "moneyBill";

					//case R_AffectCold : c.sclient.money<=0 || !c.sclient.hasLike(Cold) ? "iconForbidden" : "iconCold";
					//case R_AffectHeat : c.sclient.money<=0 || !c.sclient.hasLike(Heat) ? "iconForbidden" : "iconHeat";
					//case R_AffectNoise : c.sclient.money<=0 || !c.sclient.hasLike(Noise) ? "iconForbidden" : "iconNoise";
					//case R_AffectOdor : c.sclient.money<=0 || !c.sclient.hasLike(Odor) ? "iconForbidden" : "iconOdor";

					//case R_Trash, R_ClientRecycler : "iconForbidden";

					default : null;
				}

				if( k!=null )
					hudRoom(r.rx, r.ry, k);
			}
		}
		unselect();
	}

	public function isDragging() return drag!=null && drag.active;
	public function isDraggingClient() return drag!=null && drag.active && drag.c!=null;

	public function cancelClick() {
		moveDraggedClientBack();
		cancelDrag();
		onMouseUp(null);
	}


	public function useGemsBeforeCommand(label:LocaleString, buyLabel:LocaleString, n:Int, cmds:Array<GameCommand>) {
		var q = new ui.Question();
		q.addText(label);
		if( shotel.gems>=n )
			q.addButton( buyLabel, "moneyGem", function() {
				chainCommands(cmds);
			});
		else
			q.addButton( t._("Ok, let's buy a few gems!"), function() {
				openBuyGems();
				unselect();
			});
		q.addCancel();
	}


	public function useBoosterBeforeCommand(label:LocaleString, buyLabel:LocaleString, cmds:Array<GameCommand>) {
		var q = new ui.Question();
		q.addText(label);
		q.addButton( buyLabel, "iconBattery", function() {
			chainCommands(cmds);
		});
		q.addCancel();
	}


	#if connected
	function onBuy( d : mt.device.Cash.Transaction ){
		bankSync();
	}
	#end

	public function openBuyGems(?label:LocaleString) {
		#if connected
		mt.device.EventTracker.view("openBuyGems");
		#end

		#if !connected
		var q = new ui.Question();
		if( label!=null )
			q.addText(label);
		for(n in [50,150,500])
			q.addButton( Lang.untranslated("Add "+n), function() {
				runSolverCommand( DoCheat( CC_Item(I_Gem,n) ) );
			});
		q.addCancel();
		#elseif (standalone || mBase)
		new ui.Cash("gems");
		#end
	}


	public function openBuyGold(?label:LocaleString) {
		#if connected
		mt.device.EventTracker.view("openBuyGold");
		#end


		#if !connected
		var q = new ui.Question();
		if( label!=null )
			q.addText(label);
		for(n in [25000, 50000, 250000, 750000, 5000000])
			q.addButton( cast "Add "+prettyMoney(n), function() {
				runSolverCommand( DoCheat( CC_Item(I_Money(n), 1) ) );
			});
		q.addCancel();
		#elseif (standalone || mBase)
		new ui.Cash("gold");
		#end
	}



	function openRoomMenu(r:b.Room, ?fast=false) {
		if( isVisitMode() )
			return;

		var m = new ui.Menu(r, fast);

		// Cancel construction
		if( r.isUnderConstruction() )
			return;

		var c = r.getClientInside();
		if( r.is(R_Bedroom) && ( c==null || !c.isDone() ) ) {

			// Bedroom upgrade
			//var p = GameData.getRoomUpgradeCost(r.sroom.type, r.sroom.level);
			//if( p>=0 ) {
				//if( tuto.featureUnlocked("upgradeRoom") )
					//m.addButton(t._("Upgrade"), "iconLvlUp", r.sroom.level<3, function() {
						//var q = new ui.Question();
						//q.addText( t._("Upgrading this bedroom will give +1 happiness to any client hosted in it, but cleaning it will take much longer.") );
						//q.addButton( t._("Upgrade to level ::l:: for ::cost::", {l:r.sroom.level+2, cost:prettyMoney(p)}), function() {
							//runSolverCommand( DoLevelUpRoom(r.rx, r.ry) );
							//unselect();
						//} );
						//q.addCancel();
					//});
			//}


			// Bedroom extend (suites)
			//if( r.sroom.wid==1 ) {
				//var p = 1000;
				//if( tuto.featureUnlocked("upgradeRoom") )
					//m.addButton(t._("Extend"), "iconLvlUp", function() {
						//var q = new ui.Question();
						//q.addText( t._("Extending this bedroom will DOUBLE the amount of money payed by clients staying there.") );
						//q.addButton( t._("Extend to the LEFT for ::cost::", {cost:prettyMoney(p)}), function() {
							//runSolverCommand( DoCreateSuite(r.rx, r.ry, -1) );
							//unselect();
						//} );
						//q.addButton( t._("Extend to the RIGHT for ::cost::", {cost:prettyMoney(p)}), function() {
							//runSolverCommand( DoCreateSuite(r.rx, r.ry, 1) );
							//unselect();
						//} );
						//q.addCancel();
					//});
			//}
		}


		// Bedroom actions
		if( r.is(R_Bedroom) ) {
			// Love
			if( shotel.featureUnlocked("love") )
				m.addButton(t._("Love"), "moneyLove", c!=null && !c.isDone() && !c.sclient.hasHappinessMod(HM_Love), function() {
					runSolverCommand( DoGiveLove(c.id) );
				});

			// Beer
			if( shotel.hasRoomType(R_Bar) )
				m.addButton(t._("Soda"), "itemBeer", c!=null && !c.isDone() && c.sclient.money>0, function() {
					var tr = shotel.getBestUtilityRoom(R_Bar);
					if( tr!=null )
						runSolverCommand( DoSendClientToUtilityRoom(c.id, tr.cx, tr.cy, 0) );
				});

			#if debug
			m.addButton(cast "Happy", "gift", c!=null && !c.isDone(), function() {
				runSolverCommand( DoCheat(CC_Max(c.id)) );
			});
			#end

			//var types = [R_Bar, R_Xp];
			//types = types.filter( function(t) return shotel.hasRoomType(t) );
			//if( types.length>0 ) {
				//m.addButton(t._("Send to"), "moneyBill", c!=null && !c.isDone() && c.sclient.money>0, function() {
					//var q = new ui.Question();
					//q.addText(Lang.t._("Send this client to an utility room:"));
					//for(t in types) {
						//var icon = switch( t ) {
							//case R_Bar : "itemBeer";
							//case R_Xp : "moneyXp";
							//default : null;
						//}
						//var tr = shotel.getBestUtilityRoom(t);
						//if( tr!=null && tr.working )
							//icon = "moneyGem";
						//q.addButton( Lang.getRoom(t).name, icon, function() {
							//var tr = shotel.getBestUtilityRoom(t);
							//if( tr!=null )
								//runSolverCommand( DoSendClientToUtilityRoom(c.id, tr.cx, tr.cy, 0) );
						//});
					//}
					//q.addCancel();
				//});
			//}
		}

		// Advanced
		if( !r.is(R_Lobby) ) {
			if( r.is(R_Bedroom) && ( shotel.featureUnlocked("destroy") || shotel.featureUnlocked("custom") ) ) {
				m.addButton(t._("Advanced||As in Advanced options"), "iconUse", function() {
					var q = new ui.Question();

					// Happiness stack
					if( c!=null ) {
						q.addValue(Lang.t._("Happiness total"), c.sclient.getHappiness());
						q.addValue( Lang.t._("Base"), c.sclient.baseHappiness, false, 20 );
						for(hm in c.sclient.happinessMods)
							q.addValue( Lang.getHappinessModifier(hm.type), (hm.value>0?"+":"")+hm.value, hm.value>0?null:Const.TEXT_BAD, false, 20 );
						q.addSeparator();
					}

					// Remove custo element
					if( shotel.featureUnlocked("custom") ) {
						q.addButton(Lang.t._("Remove a decoration element"), "iconPaint", c==null && r.sroom.countCustomizations()>0, function() {
							var q = new ui.Question();
							q.addText(Lang.t._("Which element do you want to remove?"));
							if( r.sroom.custom.bath>=0 )	q.addButton( Lang.getItem(I_Bath(-1)).name, runSolverCommand.bind( DoClearCustomizations(r.rx, r.ry, I_Bath(-1)) ) );
							if( r.sroom.custom.bed>=0 )		q.addButton( Lang.getItem(I_Bed(-1)).name, runSolverCommand.bind( DoClearCustomizations(r.rx, r.ry, I_Bed(-1)) ) );
							if( r.sroom.custom.ceil>=0 )	q.addButton( Lang.getItem(I_Ceil(-1)).name, runSolverCommand.bind( DoClearCustomizations(r.rx, r.ry, I_Ceil(-1)) ) );
							if( r.sroom.custom.furn>=0 )	q.addButton( Lang.getItem(I_Furn(-1)).name, runSolverCommand.bind( DoClearCustomizations(r.rx, r.ry, I_Furn(-1)) ) );
							if( r.sroom.custom.wall>=0 )	q.addButton( Lang.getItem(I_Wall(-1)).name, runSolverCommand.bind( DoClearCustomizations(r.rx, r.ry, I_Wall(-1)) ) );
							if( r.sroom.custom.color!="raw" )q.addButton( Lang.getItem(I_Color(null)).name, runSolverCommand.bind( DoClearCustomizations(r.rx, r.ry, I_Color(null)) ) );
							if( r.sroom.custom.texture>=0 )	q.addButton( Lang.getItem(I_Texture(-1)).name, runSolverCommand.bind( DoClearCustomizations(r.rx, r.ry, I_Texture(-1)) ) );
							if( q.countElements()>2 )
								q.addButton( t._("Remove every elements!"), runSolverCommand.bind( DoClearCustomizations(r.rx, r.ry) ) );
							q.addSeparator();
							q.addCancel();
						});
					}

					// Trash a client
					if( shotel.hasRoomType(R_Trash) ) {
						var r = shotel.getAvailableRoom(R_Trash);
						if( r!=null ) {
							// Trash it
							q.addButton( t._("Send this client to the Trash"), "iconKick", c!=null, function() {
								runSolverCommand( DoSendClientToUtilityRoom(c.id, r.cx, r.cy, 0) );
							});
						}
						else if( shotel.hasRoomType(R_Trash) ) {
							// Free a trash before
							var r = shotel.getRoomsByType(R_Trash)[0];
							q.addButton( t._("Send this client to the Trash"), "iconKick", c!=null && r!=null, function() {
								var q = new ui.Question();
								q.addText(Lang.t._("The trash is not available yet."));
								q.addButton( Lang.t._("Free it immediatly?"), "moneyGem", function() {
									chainCommands([ DoSkipWork(r.cx,r.cy), DoSendClientToUtilityRoom(c.id, r.cx, r.cy, 0) ]);
								});
								q.addCancel();
							});
						}
					}

					// Recycle a client
					if( shotel.hasRoomType(R_ClientRecycler) ) {
						var r = shotel.getAvailableRoom(R_ClientRecycler);
						q.addButton( t._("Send this client to the Blender"), "iconKick", c!=null && r!=null, function() {
							runSolverCommand( DoSendClientToUtilityRoom(c.id, r.cx, r.cy, 0) );
						} );
					}

					// Sell bedroom
					if( shotel.featureUnlocked("destroy") && r.sroom.canBeDestroyed() ) {
						var canDo = c==null;
						var v = GameData.getRoomResellValue(r.sroom, shotel.countRooms(r.sroom.type), false);
						if( v<=0 )
							q.addButton( t._("Remove this room (free)"), "iconDestroy", canDo, runSolverCommand.bind( DoDestroyRoom(r.rx, r.ry) ) );
						else
							q.addButton( t._("Sell room for ::money::", {money:prettyMoney(v)} ), "iconDestroy", canDo, runSolverCommand.bind( DoDestroyRoom(r.rx, r.ry) ) );
					}

					q.addCancel();
				});
			}
		}

		// Remove customizations
		//if( !r.is(R_Lobby) && tuto.featureUnlocked("custom") ) {
			//if( r.is(R_Bedroom) ) {
				//m.addButton(t._("Remove||Action that removes all decoration elements"), "iconPaint", r.sroom.countCustomizations()>0 && r.countClients()==0, function() {
					//var q = new ui.Question();
					//q.addButton( t._("Remove all room decorations"), runSolverCommand.bind( DoClearCustomizations(r.rx, r.ry) ) );
					//q.addCancel();
				//});
			//}
		//}

		// Sell room (misc)
		if( !r.is(R_Bedroom) && shotel.featureUnlocked("build") && r.sroom.canBeDestroyed() ) {
			var v = GameData.getRoomResellValue(r.sroom, shotel.countRooms(r.sroom.type), false);
			m.addButton(v<=0?t._("Remove"):t._("Sell"), "iconDestroy", r.countClients()==0 && r.sroom.canBeEdited(), function() {
				var q = new ui.Question();
				if( v<=0 )
					q.addButton( t._("Remove this room (free)"), runSolverCommand.bind( DoDestroyRoom(r.rx, r.ry) ) );
				else
					q.addButton( t._("Sell room for ::money::", {money:prettyMoney(v)} ), runSolverCommand.bind( DoDestroyRoom(r.rx, r.ry) ) );
				q.addCancel();
			});
		}
	}



	public function unselect() {
		ui.ClientInfos.clear();
		ui.Menu.close();
		ui.Tip.clear();

		for(e in rcorners)
			e.remove();
		rcorners = [];

		//if( cursor!=null ) {
			//cursor.dispose();
			//cursor = null;
		//}

		switch( selection ) {
			case S_None :

			case S_Client(c) :
				c.onUnselect();

			case S_Room(r) :
				r.onUnselect();
		}

		selection = S_None;
	}


	public function getSelectedClient() {
		return switch( selection ) {
			case S_Client(c) : return c;
			default : return null;
		}
	}


	public function getSelectedRoom() {
		return switch( selection ) {
			case S_Room(r) : return r;
			default : return null;
		}
	}

	public function clearHudLayer() {
		hudLayer.removeAllElements();
		hudLayer.disposeAllChildren();
		validRooms = new Map();
	}

	function clearLongPress(success:Bool) {
		var d = 500;
		for(e in longPressBe) {
			if( success ) {
				tw.create(e.x, e.x+Math.cos(e.rotation-1.57)*100, d, TEaseOut);
				tw.create(e.y, e.y+Math.sin(e.rotation-1.57)*100, d, TEaseOut);
				tw.create(e.scaleX, e.scaleX+0.7, d, TEaseOut);
				tw.create(e.scaleY, e.scaleY+0.7, d, TEaseOut);
				tw.create(e.alpha, 0, d, TEaseOut).end(e.remove);
			}
			else
				tw.create(e.alpha, 0, d, TEaseOut).end(e.remove);
		}
		longPressBe = [];
	}

	public function hudRoom(cx,cy, ?icon:String, ?opaque=true) {
		var r = hotelRender.getRoomAt(cx,cy);
		var w = Const.ROOM_WID * (r!=null?r.sroom.wid:1);
		var h = Const.ROOM_HEI;
		var ok = icon!="iconForbidden";

		if( ok && r!=null )
			validRooms.set(r.rx+","+r.ry, true);

		var p = 10;
		var pt = b.Hotel.gridToPixels(cx, cy);
		var x = pt.x;
		var y = pt.y;

		if( opaque ) {
			var e = Assets.tiles.addBatchElement(hudLayer, "hudSquare"+(ok?"Ok":"No"), 0, 0.5,0.5);
			e.x = x + w*0.5;
			e.y = y - h*0.5;
			e.width = w-p*2 - 40;
			e.height = h-p*2 - 40;
		}

		var e = Assets.tiles.addBatchElement(hudLayer, "squareOrange", 0, 0.5,0.5);
		e.x = x + w*0.5;
		e.y = y - h*0.5;
		e.width = w-p*2 - 40;
		e.height = h-p*2 - 40;

		var e = Assets.tiles.addBatchElement(hudLayer, "enluminure", 0);
		e.x = x+p;
		e.y = y-h+p;

		var e = Assets.tiles.addBatchElement(hudLayer, "enluminure", 0);
		e.x = x+w-p;
		e.y = y-h+p;
		e.rotation = MLib.PI*0.5;

		var e = Assets.tiles.addBatchElement(hudLayer, "enluminure", 0);
		e.x = x+w-p;
		e.y = y-p;
		e.rotation = MLib.PI;

		var e = Assets.tiles.addBatchElement(hudLayer, "enluminure", 0);
		e.x = x+p;
		e.y = y-p;
		e.rotation = -MLib.PI*0.5;

		if( icon!=null ) {
			//var e = Assets.tiles.addBatchElement(hudLayer, "hudButton", 0, 0.5,0.5);
			//e.x = x + w*0.5;
			//e.y = y - h*0.5;
			//e.scaleX = e.scaleY = 3.5;
			//e.alpha = 0.6;

			var e = Assets.tiles.addBatchElement(hudLayer, icon, 0, 0.5,0.5);
			e.x = x + w*0.5;
			e.y = y - h*0.5;
			e.scaleX = e.scaleY = 1.8;
		}
		else {
			var e = Assets.tiles.addBatchElement(hudLayer, "btnAction", 0, 0.5,0.5);
			e.x = x + w*0.5;
			e.y = y - h*0.5;
			e.width = w-p*2;
			e.height = h-p*2;
			e.alpha = 0.4;
		}
	}



	public function select(?c:en.Client, ?r:b.Room) {
		var oldSel = selection;

		unselect();

		switch( oldSel ) {
			case S_None :

			case S_Room(sr) :
				if( r!=null && r.rx==sr.rx && r.ry==sr.ry )
					return;

			case S_Client(sc) :
				if( c!=null && c.id==sc.id )
					return;
		}


		if( c!=null ) {
			// Client selection
			selection = S_Client(c);
			c.onSelect();
			if( c.room!=null && !c.room.is(R_Bedroom) )
				openRoomMenu( c.room );
			if( c.isWaiting() )
				new ui.ClientInfos(c);
			fx.clientSelected(c);
			viewport.focusIfNotInSight(c.centerX, c.centerY, 0.4);
			Assets.SBANK.click1(1);
			ui.Tip.fromClient(c);
		}
		else if( r!=null ) {
			// Room selection
			selection = S_Room(r);
			r.onSelect();
			openRoomMenu(r);
			viewport.focusIfNotInSight(r.globalCenterX, r.globalCenterY, 0.4);
			switch( r.sroom.type ) {
				case R_Bedroom :
					var c = r.getClientInside();
					if( c!=null ) {
						// Client tip
						ui.Tip.fromClient(c);
					}
					else {
						// Bedroom tip
						var lines = [];

						var n = r.sroom.getCustomizationBonus();
						if( n>0 ) lines.push( Lang.t._("Decorations: +::n::", {n:n}) );

						var n = r.sroom.getIsolation()*GameData.ISOLATION_POWER;
						if( n>0 ) lines.push( Lang.t._("Isolation: +::n:: (empty spaces around)", {n:n}) );

						var n = r.sroom.getSunlight();
						switch( n ) {
							case 1 : lines.push( Lang.t._("Has one window") );
							case 2 : lines.push( Lang.t._("Has two windows") );
						}

						var name = r.getName();
						var col = DataTools.getWallColorCode(r.sroom.custom.color);
						var e = new ui.Tip(
							mt.deepnight.Color.clampBrightnessInt(col, 0.8, 1),
							name,
							cast lines.join("\n")
						);
						e.addTimer(r);
					}

				default :
					var inf = Lang.getRoom(r.sroom.type);
					var p = r.getProblem();
					if( p!=null )
						new ui.Tip(0xDF2033, inf.name, p.desc);
					else if( inf.role!=null ) {
						var e = new ui.Tip(inf.name, inf.role);
						e.addTimer(r);
					}
			}

			//if( r.countClients()==1 )
				//new ui.ClientInfos( r.getClientInside() );


			// Selection rectangle
			cd.unset("selBlink");
			var x = r.globalLeft;
			var y = r.globalBottom;
			var w = r.wid;
			var h = r.hei;
			var p = -20;
			var e = Assets.tiles.addBatchElement(tilesFrontSb, -100, "enluminure", 0);
			rcorners.push(e);
			e.x = x+p;
			e.y = y-h+p;

			var e = Assets.tiles.addBatchElement(tilesFrontSb, -100, "enluminure", 0);
			rcorners.push(e);
			e.x = x+w-p;
			e.y = y-h+p;
			e.rotation = MLib.PI*0.5;

			var e = Assets.tiles.addBatchElement(tilesFrontSb, -100, "enluminure", 0);
			rcorners.push(e);
			e.x = x+w-p;
			e.y = y-p;
			e.rotation = MLib.PI;

			var e = Assets.tiles.addBatchElement(tilesFrontSb, -100, "enluminure", 0);
			rcorners.push(e);
			e.x = x+p;
			e.y = y-p;
			e.rotation = -MLib.PI*0.5;

			var e = Assets.tiles.addBatchElement(tilesFrontSb, -100, "squareOrange", 0);
			rcorners.push(e);
			e.x = x;
			e.y = y-h;
			e.width = w;
			e.height = h;

			for(e in rcorners)
				e.alpha = 0; // fix blink bug

			Assets.SBANK.click1(1);
		}
	}


	public function getClient(cid) : Null<en.Client> {
		for(c in en.Client.ALL)
			if( c.id==cid )
				return c;
		return null;
	}


	//function onLongPress() {
		//if( isPlayingLogs )
			//return;
//
		//var m = getMouse();
		//var rx = m.rx;
		//var ry = m.ry;
//
//
		//var r = hotelRender.getRoomAt(rx,ry);
		//if( r==null ) {
			//cancelClick();
			//confirmCommand( DoCreateRoom(rx,ry), "Build a new room ($"+Solver.getRoomCost(R_Empty)+")?" );
		//}
	//}


	function getClosestClient(x,y) : Null<en.Client> {
		var d2 = 120*120;
		var closes = en.Client.ALL.filter(function(e) return Lib.distanceSqr(e.centerX, e.centerY, x, y)<d2);
		if( closes.length==0 )
			return null;
		else {
			closes.sort( function(a,b) {
				return Reflect.compare(Lib.distanceSqr(a.centerX, a.centerY, x, y), Lib.distanceSqr(b.centerX, b.centerY, x, y));
			});
			return closes[0];
		}
	}


	function onDragClient(c:en.Client) {
		var m = getMouse();
		var r = hotelRender.getRoomAt(m.rx, m.ry);

		if( r!=null )
			switch( r.sroom.type ) {
				case R_Bedroom :
					if( r.countClients()==0 && c.isWaiting() ) {
						runSolverCommand( DoInstallClient(c.id, r.rx, r.ry) );
						return;
					}

				case R_Bar :
					runSolverCommand( DoSendClientToUtilityRoom(c.id, r.rx, r.ry, -1) );
					return;

				case R_ClientRecycler, R_Trash :
					if( r.isWorking() ) {
						useGemsBeforeCommand(
							this.t._("This room is not available yet."),
							this.t._("Free it immediatly"),
							1,
							[DoSkipWork(r.rx, r.ry), DoSendClientToUtilityRoom(c.id, r.rx, r.ry, -1)]
						);
						return;
					}
					else {
						var q = new ui.Question();
						var s = c.spr.createBitmap();
						q.addCenteredSprite(s);
						q.addButton(Lang.t._("Get rid of this client?"), "iconKick", function() {
							runSolverCommand( DoSendClientToUtilityRoom(c.id, r.rx, r.ry, -1) );
						});
						q.addCancel();
						return;
					}

				default :
			}

		if( !c.destroyAsked && drag!=null ) {
			if( c.isWaiting() && Lib.distanceSqr(c.centerX, c.centerY, drag.cox, drag.coy)<=100*100 )
				select(c);

			if( !c.isWaiting() && Lib.distanceSqr(c.centerX, c.centerY, drag.cox, drag.coy)<=100*100 )
				select(c.room);
		}

		moveDraggedClientBack();
	}


	//function onKeyUp(e:flash.events.KeyboardEvent) {
		//if( e.keyCode==27 ) {
			//e.preventDefault();
			//e.stopImmediatePropagation();
			//e.stopPropagation();
		//}
	//}


	function onLeftClick() {
		var m = getMouse();
		var rx = m.rx;
		var ry = m.ry;

		if( ui.SideMenu.closeAll() )
			return;

		if( isVisitMode() )
			return;

		var r = hotelRender.getRoomAt(rx,ry);
		var closest = getClosestClient(m.sx, m.sy);

		//new ui.HudMenuTip("custom", 0x0080FF, cast "test", cast "blabla", "moneyGem", true); // HACK
		//if( r!=null ) { // HACK (test)
			//ui.SceneNotification.onRoom(r, cast "Hello world!", "iconTodoRed");
			//return;
		//}

		#if !prod // Tests
		//if( r!=null )
			//new ui.SceneNotification( r, Std.string( shotel.checkConsistency(rx,ry) ) );
		//fx.gemPickedUp(m.sx, m.sy);
		//fx.roomSkipped(r);
		//if( closest!=null )
			//closest.say("Hello everyone! You want to see my tralala?");
		#end

		if( closest!=null && closest.isSleeping() && shotel.featureUnlocked("miniGame") && !closest.room.cd.has("theft") ) {
			unselect();
			runSolverCommand( DoMiniGame(closest.id) );
			return;
		}

		// Flip context panel
		if( ui.ClientInfos.CURRENT!=null && ui.ClientInfos.CURRENT.isOverMore(m.ux, m.uy) ) {
			Assets.SBANK.click1(1);
			Assets.SBANK.slide1(0.1);
			ui.ClientInfos.CURRENT.flipPanel();
			return;
		}

		if( r!=null ) {
			// Big room buttons
			if( !tuto.isRunning("superHappy") ) {
				if( r.is(R_Lobby) && closest==null && r.clickRoomButton(m.sx, m.sy) )
					return;
				if( !r.is(R_Lobby) && r.clickRoomButton(m.sx, m.sy) )
					return;
			}

			// Service
			if( r.is(R_Bedroom) && r.countClients()==1 && r.getClientInside().hasServiceRequest() ) {
				if( r.getClientInside().isOverServiceReq(m.sx, m.sy) ) {
					var c = r.getClientInside();
					if( !cd.hasSet("service"+c.id, Const.seconds(2)) ) {
						runSolverCommand( DoService(c.id) );
						unselect();
					}
					return;
				}
			}

			// Pick gifts
			if( r.hasGifts() && ( !tuto.isRunning() || tuto.isRunning("superHappy") ) ) {
				runSolverCommand( DoPickGift(r.rx, r.ry) );
				unselect();
				return;
			}
		}

		if( r!=null && r.is(R_Bedroom) && r.countClients()==1 ) {
			select(r);
			return;
		}




		var c = getSelectedClient();
		if( r!=null && c!=null && !isVisitMode() ) {
			// Recycler
			if( r.is(R_ClientRecycler) && !r.isWorking() ) {
				var q = new ui.Question();
				q.addText(Lang.t._("Are you sure you want to recycle this client?"));
				q.addButton(Lang.t._("Throw him in the mixer!"), function() {
					runSolverCommand( DoSendClientToUtilityRoom(c.id, rx, ry, -1) );
					unselect();
				});
				q.addCancel();
				return;
			}

			// Bedroom
			if( r.is(R_Bedroom) && r.countClients()==0 && c.isWaiting() && !r.isWorking() && !r.isUnderConstruction() ) {
				// Install a client to a bedroom
				runSolverCommand( DoInstallClient(c.id, r.rx, r.ry) );
				return;
			}
		}


		if( closest!=null && closest.isWaiting() && ( r==null || r!=null && closest.room==r ) ) {
			// Pick a client
			select(closest);
			return;
		}

		if( r!=null && !r.is(R_Lobby) && !r.is(R_LevelUp) ) {
			// Pick a room
			select(r);
			return;
		}

		unselect();
	}


	public function runAfterPlayback(cb:Void->Void) {
		if( !isPlayingLogs && paused )
			cb();
		else
			createChildProcess( function(p) {
				if( !isPlayingLogs && !paused ) {
					cb();
					p.destroy();
				}
			});
	}



	#if connected
	function runClientServerRequestSilently(cs:ClientServerRequest) {
		netLog("Silent run: #"+cs.msgId+" "+cs.c, 0x8600FF);
		switch( cs.c ) {
			case CS_GameCommand(c, t) :
				var solver = new Solver(shotel.getState(), serverTime);
				if( solver.doCommand(c) ) {
					shotel.loadState( solver.getHotelState() );
					//lastMsgId = MLib.max( lastMsgId, cs.msgId );
					return true;
				}
				else {
					netLog("  Failed locally: "+solver.lastError, 0xFF0000);
					removePendingCommand(cs.msgId);
					return false;
				}

			case CS_Settings(s) :
				Main.ME.hdata.settings = s;
				removePendingCommand(cs.msgId);
				return true;

			case CS_HotelOptions(o) :
				shotel.name = o.name;
				removePendingCommand(cs.msgId);
				return true;

			case CS_AskTime :
				return true;

			case CS_BecomeMainClient(d) :
				switch( d ) {
					case DT_Web :
					case DT_Android, DT_Ios :
						Main.ME.hdata.playedOnMobile = true;
				}
				return false;
		}
	}
	#end

	public inline function followTheInstructions(?reason:Dynamic) {
		tuto.askRefocus();
	}


	public function runSolverCommand(c:GameCommand) {
		if( isVisitMode() )
			return;

		if( isPlayingLogs ) {
			chainCommands([c]);
			return;
		}

		// Tutorial
		if( !tuto.allowCommand(c) || tuto.commandLocked("send") && c!=DoPing ) {
			followTheInstructions(c);
			return;
		}

		// Run command
		//var longAbsence = !isVisitMode() && serverTime-shotel.lastRealTime >= DateTools.minutes(20);
		turbo = false;
		totalMoney = -1;

		if( debugEffects )
			debug("RunSolverCmd: "+Std.string(c).substr(0,50));

		var solver = new com.Solver( shotel.getState(), serverTime );
		if( solver.doCommand(c) ) {
			if( c != DoPing )
				cd.set("autoLevelUp", Const.seconds(1.5));

			ui.SceneTip.clear();

			if( tuto.isWaitingCommand(c) ) {
				commandChain.push( DoCompleteTutorial(tuto.id) );
				tuto.complete(false);
			}

			// Send to server
			#if connected
			sendServerCommand( CS_GameCommand(c, serverTime) );
			#end
		}
		else {
			// Command failed
			hotelRender.getLobby().updateClientCache();
			if( !cd.hasSet("err_"+solver.lastError, Const.seconds(2)) ) {
				var err : Null<LocaleString> = switch( solver.lastError ) {
					case NeedGems(n) :
						openBuyGems( this.t._("You need ::n:: GEM(s) to do that, buy more?", {n:n}) );
						null;

					case NeedMoney(n) :
						#if !connected
						openBuyGold( this.t._("You need ::n:: GOLD to do that, buy more?", {n:n}) );
						null;
						#else
						openBuyGold( this.t._("You need ::n:: GOLD to do that, buy more?", {n:n}) );
						null;
						#end

					case NeedLove(n) :
						var q = new ui.Question();
						q.addText( Lang.t._("You can get LOVE by simply visiting your friends hotels.") );
						q.addButton(Lang.t._("Get more love"), "moneyLove", function() {
							ui.side.Contacts.CURRENT.open();
						});
						q.addCancel();
						null;

					case NeedStock(t,n) :
						if( t==R_StockBoost ) {
							var br = shotel.getRoomsByType(R_StockBoost)[0];
							if( br!=null ) {
								useGemsBeforeCommand(
									Lang.t._("You don't have BOOSTER left."),
									this.t._("Refill BOOSTERS and use one"),
									1,
									[ DoActivateRoom(br.cx, br.cy), c ]
								);
							}
							null;
						}
						else {
							var found = false;
							for(r in shotel.rooms) {
								if( r.type==t && !r.hasBoost() ) {
									if( shotel.countStock(R_StockBoost)==0 ) {
										var br = shotel.getRoomsByType(R_StockBoost)[0];
										if( br!=null ) {
											found = true;
											useGemsBeforeCommand(
												Lang.t._("You need to boost a room (::name::), but you don't have any booster left.", {name:Lang.getRoom(t).name}),
												this.t._("Refill BOOSTERS and use one"),
												1,
												[ DoActivateRoom(br.cx, br.cy), DoBoostRoom(r.cx, r.cy), c ]
											);
										}
									}
									else {
										found =true;
										useBoosterBeforeCommand(
											Lang.getSolverError(solver.lastError),
											this.t._("Use a BOOSTER on storage"),
											[DoBoostRoom(r.cx, r.cy), c]
										);
									}
									break;
								}
							}
							if( !found )
								if( !shotel.hasRoomType(t) )
									new ui.Notification(Lang.t._("You must build: ::r::",{r:Lang.getRoom(t).name}), 0xFF9300, Assets.getStockIconId(t));
								else
									new ui.Notification(Lang.getSolverError(solver.lastError), 0xFF9300, Assets.getStockIconId(t));
							null;
						}

					case NeedItem(i) :
						var inf = GameData.getItemCost(i);
						if( inf.n>0 ) {
							var name = Lang.getItem(i).name;
							useGemsBeforeCommand(
								Lang.t._("You don't have any \"::item::\" left.", { item:name }),
								Lang.t._("Buy ::n::x \"::item::\" for ::cost:: GEMS", { n:inf.n, cost:inf.cost, item:name }),
								inf.cost, [DoBuyItem(i, 1), c]
							);
						}
						else
							new ui.Notification(Lang.t._("You don't have any \"::item::\" left.", { item:name }));
						null;

					case NoLaundryAvailable :
						var r = shotel.getBestUtilityRoom(R_Laundry);
						if( r!=null ) {
							useBoosterBeforeCommand(
								this.t._("All your laundries are working."),
								this.t._("Use a BOOSTER on one laundry"),
								[DoBoostRoom(r.cx, r.cy), c]
							);
							null;
						}
						else
							Lang.t._("You need at least one laundry.");

					case IllegalAction, IllegalTarget, UnknownTarget, UnknownClient :
						#if debug
						cast solver.lastError+" ("+c+")";
						#else
						null;
						#end

					default :
						Lang.getSolverError(solver.lastError);
				}

				if( err!=null )
					new ui.Notification(err, 0xFF9300);
			}

			hotelRender.getLobby().updateClientCache();
			refreshSelectionUi();
		}

		var finalState = solver.getHotelState();

		// Playback process
		var effects = solver.getLastEffectsCopy();
		var initialEffects = solver.getLastEffectsCopy();
		if( effects.length==0 ) {
			// Nothing to do
			onEffectsPlaybackComplete(c, finalState, initialEffects);
		}
		else if( effects.length>300 ) {
			// Fast forward
			onEffectsPlaybackComplete(c, finalState, initialEffects);
			attach();
		}
		else {
			isPlayingLogs = true;
			createChildProcess( function(p) {
				if( !p.cd.has("play") ) {
					var delay = 0;
					do {
						if( effects.length==0 ) {
							// Done
							onEffectsPlaybackComplete(c, finalState, initialEffects);
							p.destroy();
							break;
						}
						else {
							// Next
							var e = effects.shift();
							delay = applyEffect(e);
							if( effects.length==0 )
								delay = 0;
							else
								p.cd.set("play", delay);
						}
					} while( delay==0 );
				}
			}, true);
		}

		solver.destroy();

	}

	function onEffectsPlaybackComplete(c:GameCommand, finalState:HotelState, effects:Array<GameEffect>) {
		isPlayingLogs = false;

		shotel.loadState(finalState);
		#if connected
		hdata.state = finalState;
		hdata.lastMsgId = lastMsgId;
		#end

		#if( !connected && autoSave )
		saveCookieState();
		#end

		ui.MassMenu.CURRENT.refresh();
		ui.Stocks.CURRENT.refresh();

		cd.unset("happyCombo");

		if( totalMoney>0 )
			new ui.Notification( Lang.t._("Total: ::n::", {n:prettyMoney(totalMoney)}), Const.TEXT_GOLD, "moneyGold" );

		if( commandChain.length>0 )
			runSolverCommand( commandChain.shift() );
		else {
			#if !trailer
			// "Build a Bedroom" tip
			delayer.cancelById("bedroomTip");
			delayer.add("bedroomTip", function() {
				var n = shotel.countRooms(R_Bedroom);
				if( !tuto.isRunning() && tuto.noRecentTuto() && n>=5 && n<=8 && shotel.money>=GameData.getRoomCost(R_Bedroom, n) && shotel.featureUnlocked("buildTip") )
					if( !cd.hasSet("bedroomTip"+shotel.level, 999999) )
						new ui.HudMenuTip("build", Lang.t._("Bedroom available"), Lang.t._("You have enough money to build another bedroom!"), "roomBedroom", true);
			}, 400);
			#end
		}
	}

	public function chainCommands( all:Array<GameCommand> ) {
		if( isVisitMode() )
			return;

		// Tutorial lock
		var c = all[0];
		if( !tuto.allowCommand(c) || tuto.commandLocked("send") && c!=DoPing ) {
			followTheInstructions(c);
			return;
		}

		commandChain = commandChain.concat(all);
		if( !isPlayingLogs )
			runSolverCommand( commandChain.shift() );
	}


	public function refreshSelectionUi() {
		switch( selection ) {
			case S_None :

			case S_Client(c) :
				//ui.Tip.fromClient(c);
				ui.ClientInfos.refresh();

			case S_Room(r) :
				if( r.is(R_Bedroom) && r.countClients()==1 )
					ui.Tip.fromClient( r.getClientInside(), false );
				//ui.ClientInfos.refresh();
				openRoomMenu(r, true);
				//if( ui.Menu.CURRENT!=null )
					//ui.Menu.CURRENT.tw.completeAll();
		}
	}



	inline function sign(v:Int) return v>0 ? '+$v' : Std.string(v);


	public function applyEffect(ge:GameEffect) : Int {
		var d : Float = 0;

		shotel.applyEffect(ge, true);

		if( Type.enumIndex(ge)!=Type.enumIndex(Ok(null)) && debugEffects )
			debug("applyEffect: "+ge);

		switch( ge ) {
			case AddStat(_) :

			case Rated(_) :

			case ShowRating :
				#if( ios || android )
				new ui.Rate();
				d = Const.seconds(0.5);
				#end

			case ShowFriendRequest(r) :
				delayer.add(function() {
					if( tuto.isRunning() )
						return;

					new ui.Friends(r);
				}, 500);
				d = Const.seconds(0.7);

			case Ok(c) :
				switch( c ) {
					case DoValidateAll :
						turbo = true;
						totalMoney = 0;
						Assets.SBANK.validate(1);
						d = Const.seconds(0.5);

					case DoSkipAllClients :
						turbo = true;
						totalMoney = 0;
						Assets.SBANK.happy(1);
						d = Const.seconds(0.5);

					case DoCreateRoom(_) :
						ui.side.BuildMenu.CURRENT.close();

					default :
				}

			case Cheated(c) :
				#if !connected
				switch( c ) {
					case CC_AddDay(n) :
						saveCookieState();
						runSolverCommand( DoPing );

					default :
				}
				#end

			case Print(s) :
				#if console
				Main.ME.console.log(s, 0xFFCC00);
				#else
				new ui.Notification(s, 0xFFCC00);
				#end

			case SyncLastEventTime(_) :

			case MessageDiscarded(_) :

			case PremiumBought(id) :
				Assets.SBANK.item(1);

				pause();
				var e = new ui.Reward();
				e.addText( Lang.t._("Permanent upgrade unlocked"), Lang.getPremium(id).name, Const.TEXT_GOLD );

				ui.side.BuildMenu.CURRENT.invalidate();
				ui.side.PremiumShop.CURRENT.invalidate();
				d = Const.seconds(0.2);


			case PremiumOnRoom(id, cx,cy) :
				var r = hotelRender.getRoomAt(cx,cy);
				viewport.focusRoom(r, 500);
				delayer.add( fx.roomUpgrade.bind(r), 500 );
				ui.SceneNotification.onRoom(r, Lang.getPremium(id).name, "moneyGem");
				d = Const.seconds(0.4);


			case BossResult(win) :
				if( !win ) {
					var e = new ui.Consortium();
					e.addLine( Lang.t._("The inspector left and he wasn't completely satisfied."), 0x9C071E );
					e.addLine( Lang.t._("We will send you another one very soon. BE PREPARED.") );
					d = Const.seconds(0.2);
				}

			case BossDied:
				var e = new ui.Consortium();
				e.addLine( Lang.t._("The inspector had an \"accident\" during its stay in your hotel."), 0x9C071E );
				e.addLine( Lang.t._("We will send you another one very soon. STOP KILLING OUR FELLOW EMPLOYEES.") );
				e.addLine( Lang.t._("Best regards.") );
				d = Const.seconds(0.2);

			case BossArrived :
				createChildProcess( function(p) {
					if( !hasAnyPopUp() ) {
						var e = new ui.Consortium(true);
						if( shotel.level==0 ) {
							//e.addLine( Lang.t._("SUBJECT: Official Consortium Notice") );
							e.addLine( Lang.t._("We sent you an Inspector to check your work. Please take care of him.") );
							e.addLine( Lang.t._("Best regards."), 0.7 );
						}
						else {
							e.addLine( Lang.t._("A consortium INSPECTOR has been sent to your hotel. He must leave with a happiness of ::n::.", {n:shotel.getMaxHappiness()}) );

							var c = en.Client.ALL.filter( function(c) return !c.isDone() && c.type==C_Inspector && c.isWaiting() )[0];
							if( c!=null )
								for( p in c.sclient.getPerks() )
									e.addLine( Lang.t._("Special effect: ::e::", {e:Lang.getPerk(p)}), 0x8400CA );

							e.addLine( Lang.t._("Best regards."), 0.7 );
						}
						p.destroy();
					}
				}, true);

				d = Const.seconds(0.1);

			case BossCooldownDec :

			case BossCooldownReset(_) :

			case EventRewardReceived(eid) :
				var q = new ui.Question(false);
				var e = Data.Event.resolve(eid);
				var inf = Lang.getEvent( e.id );
				q.addTitle(inf.title);
				for( line in inf.desc.split("\n") )
					q.addText( Lang.untranslated(line) );
				q.addOk( Lang.t._("Cool!") );

			case SpecialRewardReceived(id, items) :
				ui.side.Inbox.CURRENT.invalidate();
				Assets.SBANK.happy(1);

				var q = new ui.Question(false);
				q.addTitle(Lang.t._("Special reward!"));
				//q.addText( Lang.t._("You received the following items:") );
				q.addSeparator();
				for(i in items) {
					var icon = Assets.getItemHSprite(i.i, 100, 0.5,0.5);
					var label : LocaleString = cast ( Lang.getItem(i.i).name + (i.n>1 ? " (x"+i.n+")" : "") );
					if( icon!=null )
						q.addTextAndSprite( icon, label, Const.TEXT_GOLD, false );
					else
						q.addText( label, Const.TEXT_GOLD, false );
					q.addSeparator();
				}
				q.addCancel( Lang.t._("Thanks!") );
				d = Const.seconds(0.3);


			case CheckMiniGame :

			case FeatureUnlocked(id) :
				#if debug
				new ui.Notification(cast "Feature unlocked: "+id, "iconUse");
				#end
				ui.HudMenu.CURRENT.refresh();
				ui.MainStatus.CURRENT.updateInfos();
				for(r in Game.ME.hotelRender.rooms)
					r.clearRoomButtons();

				switch( id ) {
					case "cold" : ui.side.ItemMenu.CURRENT.invalidate();
					default :
				}

			case QuestStarted(id) :
				//debug("Quest "+id+" STARTED.", 0x00FFFF);
				cd.set("recent_"+id, 999999);
				if( !ui.side.Quests.CURRENT.isOpen )
					new ui.HudMenuTip("quest_all", 0x0080FF, Lang.t._("You got 1 new quest!"), true);
				ui.side.Quests.CURRENT.invalidate();
				ui.QuestLog.CURRENT.refresh();

			case QuestCancelled(id) :
				//debug("Quest "+id+" CANCELED.", 0xFF0000);
				ui.side.Quests.CURRENT.invalidate();
				ui.QuestLog.CURRENT.refresh();

			case QuestAdvanced(id,n) :
				//debug("Quest "+id+": remain="+n, 0xFF80C0);
				Assets.SBANK.quest(0.2);
				ui.side.Quests.CURRENT.invalidate();
				var qdata = DataTools.getQuest(id);
				var q = shotel.getQuestState(id);
				if( qdata!=null )
					new ui.HudMenuTip( "quest_"+id, Lang.getQuestProgress(qdata.objectiveId, q.oparam, q.ocount, shotel) );
				ui.QuestLog.CURRENT.refresh();

			case QuestDone(id, param) :
				//debug("Quest "+id+" COMPLETE", 0x80FF00);
				Assets.SBANK.questComplete1(1);
				var q = DataTools.getQuest(id);
				if( q!=null && q.id!=Data.QuestKind.first )
					new ui.HudMenuTip("quest_all", 0x80FF00, Lang.t._("Quest complete!"), Lang.getQuestObjective(q.objectiveId, param, q.ocount, shotel), Assets.getItemIcon(I_LunchBoxAll), true);
				ui.side.Quests.CURRENT.invalidate();
				ui.QuestLog.CURRENT.refresh();
				d = Const.seconds(0.6);

			case QuestBought :
				Assets.SBANK.gemUsed(0.8);
				uiFx.questBought();

			case TutorialCompleted(_) :

			case TrackMoneyEvent(_), TrackGameplayEvent(_) :

			case HotelFlagSet(k,v) :
				if( k=="dailies" )
					ui.QuestLog.CURRENT.refresh();

				if( k.indexOf("sp_")>=0 )
					ui.side.CustomizeMenu.CURRENT.invalidate();


			case RoomBoosted(x,y) :
				var r = hotelRender.getRoomAt(x,y);
				Assets.SBANK.boost1(0.7);


			case LongAbsence :
				if( !Game.ME.isVisitMode() ) {
					var q = new ui.Question(false);
					q.addTitle( Lang.t._("It's been a long time!") );
					q.addText( Lang.t._("As a gift for your fidelity:") );
					q.addSeparator();
					q.addText( Lang.t._("You received ::n:: gems", {n:GameData.ABSENCE_GEMS}), "moneyGem", Const.TEXT_GEM, false );
					q.addSeparator();
					q.addText( Lang.t._("You received ::n:: gold", {n:GameData.ABSENCE_GOLD}), "moneyGold", Const.TEXT_GOLD, false );
					q.addSeparator();
					q.addText( Lang.t._("We refilled your client queue"), "clientLuggage", Const.TEXT_GRAY, false );
					q.addSeparator();
					q.addText( Lang.t._("We repaired all your rooms"), "iconClean", Const.TEXT_GRAY, true );
					q.addCancel( Lang.t._("Cool, thanks!") );
					#if connected
					mt.device.EventTracker.view("ui.LongAbsence");
					#end
				}

			case DailyLevelProgress(ok) :
				#if debug
				new ui.Notification( Lang.untranslated("Daily level: "+ok+", level="+shotel.dailyLevel), "iconUse");
				#end

			case NewDay :
				if( !Game.ME.isVisitMode() ) {
					var q = new ui.Question(false);

					//var e = shotel.getCurrentEvent();
					//if( e!=null ) {
						//var inf = Lang.getEvent(e.id);
						//q.addTitle( inf.title );
						//q.addText( inf.desc, "calendar", false, 0.85 );
						//q.addSeparator();
					//}
					//else
					q.addTitle( Lang.t._("You reached day ::n::!", {n:shotel.dailyLevel}) );

					var iwid = 130;
					var ihei = 128;
					var s = q.addEmptyFrame(ihei*2);
					var cols = 5;
					var x = 0;
					var y = 0;
					var current : HSprite = null;
					var currentLabel : HSprite = null;
					for(j in 0...Data.DailyReward.all.length) {
						var dr = Data.DailyReward.all[j];
						var old = dr.day < shotel.dailyLevel;
						var active = shotel.dailyLevel>=dr.day;
						var m = Assets.tiles.h_get(active?"dailyMarkerOn":"dailyMarkerOff",0, 0.5,0.5, true, s);
						m.setPos( q.maxWid*0.5 - iwid*(cols-1)*0.5 + iwid*x, ihei*0.5 + y*ihei );

						if( x<cols-1 ) {
							var a = Assets.tiles.h_get("dailyNext",0, 0.5,0.5, s);
							a.setPos( m.x+iwid*0.5, m.y );
						}

						if( old ) {
							var chk = Assets.tiles.h_get("dailyCheck",0, 0.5,0.5, true, s);
							chk.setPos(m.x, m.y);
						}
						else {
							var bg = Assets.tiles.h_get(active?"dailyLabelOn":"dailyLabelOff",0, 0.5,0.5, true, s);
							bg.setPos(m.x, m.y-ihei*0.2);

							var tf = Assets.createText(20, active ? Const.BLUE: 0x8383E0, Lang.t._("Day ::n::", {n:dr.day}), s);
							tf.x = m.x - tf.textWidth*tf.scaleX*0.5;
							tf.y = bg.y - tf.textHeight*tf.scaleY*0.5 - 2;

							// Rewards icons
							var n = dr.gems + dr.lunchBoxes + (dr.gold?1:0);
							var gems = dr.gems;
							var boxes = dr.lunchBoxes;
							var gold = dr.gold;
							var gsize = boxes>0 || active ? 45 : 30;
							var spacing = 0.35;
							for(i in 0...n) {
								var e : HSprite = null;
								if( gold ) {
									gold = false;
									e = Assets.tiles1.h_get("shopGold",1, 0.5,0.7);
									e.constraintSize(gsize*2);
								}
								else if( gems>0 ) {
									gems--;
									e = Assets.tiles.h_get("moneyGem", 0.5,0.5);
									e.constraintSize(gsize);
									e.rotation = -0.1;
								}
								else if( boxes>0 ) {
									boxes--;
									e = Assets.tiles.h_get("gift", 0.5, 0.5);
									e.constraintSize(gsize);
									e.rotation = -0.1;
								}

								if( e==null )
									continue;

								s.addChild(e);
								e.filter = true;
								if( !active )
									e.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(Const.BLUE, 0.7,0.3);
								e.x = m.x - (n-1)*gsize*0.5*spacing + i*gsize*spacing;
								e.y = m.y + ihei*0.1 + i*3;
							}

							// Current
							if( shotel.dailyLevel==dr.day ) {
								current = m;
								currentLabel = bg;
							}
						}

						x++;
						if( x>=cols ) {
							x = 0;
							y++;
						}
					}

					q.addSeparator();

					var idx = q.elements.length;
					var dr = DataTools.getDailyReward(shotel.dailyLevel);

					if( dr.lunchBoxes>0 )
						q.addText( Lang.t._("You received ::n:: Mysterious Boxes!!", {n:dr.lunchBoxes}), "gift", Const.TEXT_GOLD );

					if( dr.gold )
						q.addText( Lang.t._("You received ::n:: gold!", {n:GameData.DAILY_GOLD}), "moneyGold", Const.TEXT_GOLD );

					if( dr.gems>0 )
						if( dr.gems>1 )
							q.addText( Lang.t._("You received ::n:: gems!", {n:dr.gems}), "moneyGem", Const.TEXT_GEM );
						else
							q.addText( Lang.t._("You received 1 gem!"), "moneyGem", Const.TEXT_GEM );

					q.addText( Lang.t._("You received ::n:: love!", {n:GameData.DAILY_LOVE}), "moneyLove", Const.TEXT_LOVE, false );

					q.addCancel( Lang.t._("Cool, thanks!") );

					for(i in idx...q.elements.length)
						q.elements[i].s.visible = false;

					function showButtons() {
						if( destroyed || q.destroyed )
							return;

						//Assets.SBANK.pop(0.6);
						var j = 0;
						for(i in idx...q.elements.length) {
							var e = q.elements[i];
							var fx = Assets.tiles.h_get("blueLineGlow",0, 0.5,0.5, e.s);
							fx.setPos(e.wid*0.5, e.hei*0.5);
							fx.setSize(e.wid*1.7, e.hei*3);
							tw.create(fx.scaleX, j*120|fx.scaleX*0.3, 800);
							tw.create(fx.alpha, j*120|0, 800)
								.start( function() {
									e.s.visible = true;
									Assets.SBANK.pop(0.2);
								})
								.end( fx.dispose );
							j++;
						}
					}


					if( current!=null ) {
						var sparks = false;
						function getX() {
							return current.destroyed ? 0 : (current.x + current.parent.x)*q.getScale() + q.wrapper.x;
						}
						function getY() {
							return current.destroyed ? 0 : (current.y + current.parent.y)*q.getScale() + q.wrapper.y;
						}
						q.createChildProcess( function(p) {
							if( q.destroyed ) {
								p.destroy();
								return;
							}

							if( !sparks )
								return;

							if( itime%15==0 )
								uiFx.newDayShine(getX(), getY(), q.getScale());
							uiFx.newDaySparks(getX(), getY(), q.getScale());
						});
						cm.create({
							current.set("dailyMarkerOff");
							currentLabel.set("dailyLabelOff");
							400;
							tw.create(current.rotation, 6.28, TEaseIn, 800).end( cm.signal.bind() );
							end;
							Assets.SBANK.explode(0.3);
							400>>Assets.SBANK.happy(0.5);
							uiFx.newDayMarker(getX(), getY(), q.getScale());
							sparks = true;
							current.set("dailyMarkerOn");
							currentLabel.set("dailyLabelOn");
							current.rotation = 0;
							current.scaleY = 1.7;
							tw.create(current.scaleX, 1.7>1, 500).update( function() current.scaleY = current.scaleX );
							900;
							showButtons();
						});
					}

					/*
					#if( connected && !mobile )
					if( !Main.ME.hdata.playedOnMobile ) {
						q.addSeparator();
						q.addText( Lang.t._("Special offer! If you play Monster Hotel on your mobile device or tablet, you will earn unique decorations!"), Const.TEXT_GOLD, 0.8 );
					}
					#end
					*/

					#if connected
					mt.device.EventTracker.view("ui.NewDay");
					#end

					d = Const.seconds(1.5);
				}

			case StartTask(_), RemoveTask(_) :

			//case HappinessUpdate :

			case LevelUp :
				#if connected
				mt.device.EventTracker.levelAchieved( shotel.level-1 );
				#end

				unselect();
				var dl = Const.seconds(3.5);
				setCinematicLock(dl);
				function _lvlUp() {
					new ui.LevelUp(shotel.level);
				}
				var base = hotelRender.getNameBase();
				cm.create({
					viewport.focus(base.globalCenterX, base.globalTop-Const.ROOM_HEI);
					fx.newStarBefore(base.globalLeft, base.globalTop-170);
					1000;
					hotelRender.renderSurroundings();
					fx.newStar(base.globalLeft, base.globalTop-170);
					Assets.SBANK.levelUp(1);
					2500;
					_lvlUp();
					ui.HudMenu.CURRENT.refresh();
					ui.side.BuildMenu.CURRENT.invalidate();
				});
				d = dl;



			case AddGems(n, notif) :
				Assets.SBANK.gem(1);
				if( notif ) {
					var r = new ui.Reward();
					r.addItem(I_Gem, n);
				}
				else
					new ui.Notification(cast "+"+n, Const.TEXT_GEM, "moneyGem");
				ui.MainStatus.CURRENT.shakeGem();
				d = Const.seconds(0.5);

			case AddLove(n) :
				ui.MainStatus.CURRENT.shakeLove();

			case RemoveLoveFromRoom(cx,cy, n) :
				var r = hotelRender.getRoomAt(cx,cy);
				ui.MainStatus.CURRENT.updateInfos();
				ui.MainStatus.CURRENT.shakeLove();
				d = Const.seconds(0.3);

			case RemoveGem(n) :
				//new ui.Notification(cast '-$n', Const.TEXT_GEM, "moneyGem");
				ui.MainStatus.CURRENT.shakeGem();
				d = Const.seconds(0.25);

			case RegenClientDeck :

			case ClientLoved(cid) :
				fx.love( getClient(cid) );
				Assets.SBANK.love(0.2);
				d = Const.seconds(0.2);

			case ClientPerk(cid, k, i) :
				var c = getClient(cid);
				var p = Data.ClientPerk.resolve(k);
				if( c!=null && !c.destroyAsked && p!=null ) {
					switch( p.id ) {
						case Data.ClientPerkKind.Cannibal :
							var t = getClient(i);
							var tr = t.room;
							c.goToRoomTemporarily(t.room);
							c.setPos(tr.globalLeft+110, tr.globalBottom);
							c.dir = 1;
							delayer.add( tr.openDoor.bind(false), 800 );
							tr.openDoor(true);

							new ui.Notification( Lang.t._("The SERIAL KILLER from room ::n:: decided to eat one of its neighbour!", {n:c.getRealRoom().getNumber()}), Const.TEXT_BAD, "iconVip" );
							d = Const.seconds(0.5);

						case Data.ClientPerkKind.BeerMaster :
							var f = c.room;
							var t = hotelRender.getRoom(R_StockBeer, false);
							fx.lightning(f.globalCenterX, f.globalCenterY, t.globalRight-90, t.globalCenterY-30);
							d = Const.seconds(0.3);

						case Data.ClientPerkKind.LaundryMaster :
							var f = c.room;
							var t = hotelRender.getRoom(R_Laundry, false);
							fx.lightning(f.globalCenterX, f.globalCenterY, t.globalRight-90, t.globalCenterY-30);
							d = Const.seconds(0.3);

						case Data.ClientPerkKind.PaperMaster :
							var f = c.room;
							var t = hotelRender.getRoom(R_StockPaper, false);
							fx.lightning(f.globalCenterX, f.globalCenterY, t.globalRight-90, t.globalCenterY-30);
							d = Const.seconds(0.3);

						case Data.ClientPerkKind.RobinHood :
							new ui.Notification( Lang.t._("The client from room ::n:: stole everyone's savings and turned it into ::v::!", {n:c.room.getNumber(), v:prettyMoney(i)}), Const.TEXT_GOLD, "moneyBill" );

						default :
					}
				}

			case ClientSpecial(cid) :
				var c = getClient(cid);
				c.goBackToRealRoom();
				c.onSpecialAction();

				switch( c.sclient.type ) {
					case C_Gem :
						Assets.SBANK.chicken(0.15);
						d = Const.seconds(2);

					case C_Bomb :

					default :
						Assets.SBANK.happy(1);
						fx.clientSpecialTrigger(c);
						d = Const.seconds(0.25);
				}

			case ClientMaxHappiness(cid) :
				var c = getClient(cid);
				c.clearBubbles();
				delayer.cancelById("say"+c.id);
				delayer.add("say"+c.id, function() {
					c.giveFeedback();
				}, 500);
				fx.happinessMaxed(c);
				Assets.SBANK.cashRegister(0.5);
				//var r = new ui.Reward();
				//r.maxHappiness(c);
				d = Const.seconds(0.8);

			case AddClientSaving(cid,n) :
				var c = getClient(cid);
				ui.SceneNotification.onRoom(c.room, cast "+"+n, Const.TEXT_SAVING, "moneyBill");
				c.getRealRoom().updateHud();
				refreshSelectionUi();
				Assets.SBANK.cashRegister(0.25);
				d = Const.seconds(0.25);

			case RemoveClientSaving(cid,n) :
				var c = getClient(cid);
				if( c.room.is(R_Bedroom) )
					ui.SceneNotification.onRoom(c.room, cast "-"+n, Const.TEXT_BAD, "moneyBill");
				else
					ui.SceneNotification.onEntity(c, cast "-"+n, Const.TEXT_BAD, "moneyBill");
				c.getRealRoom().updateHud();
				refreshSelectionUi();

			case ClientFlagSet(cid,k) :
				getClient(cid).forceHandIconRefresh();
				switch( k ) {
					case "hand_beer", "hand_souvenir" :
						Assets.SBANK.cashRegister(0.3);

					default :
				}


			case MiniGame(cid, m, l) :
				var c = getClient(cid);
				var r : b.r.Bedroom = cast c.room;
				r.onTheft();
				switch( l ) {
					case 0 :
						var all = [
							Lang.t._("Tissue"),
							Lang.t._("Smelly sock"),
							Lang.t._("Underpant"),
							Lang.t._("Tooth"),
							Lang.t._("Stamp"),
							Lang.t._("Rusty screwdriver"),
							Lang.t._("Old DVD"),
							Lang.t._("Plush"),
							Lang.t._("A crushed candy"),
							Lang.t._("A ball of lint"),
						];
						ui.SceneNotification.onEntity(c, Lang.t._("Found: ::item::", {item:all[Std.random(all.length)]}), Const.TEXT_GOLD, "moneyGold" );

					case 1 :
						var q = new ui.Question(false);
						q.addCenteredSprite( Assets.tiles1.getH2dBitmap("shopGold",1) );
						var all = [
							Lang.t._("Gold necklace"),
							Lang.t._("Silver watch"),
							Lang.t._("Gold watch"),
							Lang.t._("Small opale"),
							Lang.t._("Small diamond"),
							Lang.t._("Gold ring"),
							Lang.t._("False teeth"),
							Lang.t._("Lucky rock"),
							Lang.t._("Smartphone"),
						];
						q.addText( Lang.t._("You found: ::item::!\n\nYou earned ::n:: by selling this nice loot found inside this client's pocket!",
							{ item:all[Std.random(all.length)], n:prettyMoney(m) }) );
						q.addCancel( Lang.t._("Cool!") );

					case 2 :
						var q = new ui.Question(false);
						q.addCenteredSprite( Assets.tiles1.getH2dBitmap("shopGold",4) );
						var all = [
							Lang.t._("Ming vase"),
							Lang.t._("One Ring"),
							Lang.t._("Golden Tipyx"),
							Lang.t._("Bag of magic beans"),
							Lang.t._("Harry Potter 8th book"),
							Lang.t._("Lightsaber"),
							Lang.t._("Lich crown"),
							Lang.t._("Crystal skull"),
							Lang.t._("Fabergé Egg"),
							Lang.t._("Yoda plush"),
							Lang.t._("Treasure map"),
							Lang.t._("Gold Chest"),
							Lang.t._("Uranium ore"),
							Lang.t._("Firefly season 2"),
							Lang.t._("Menhir"),
							Lang.t._("Indian chanvre"),
							Lang.t._("Cute kitten"),
							Lang.t._("Dragon sack"),
							Lang.t._("Platinium ring"),
							Lang.t._("Antique Master Sword"),
							Lang.t._("Sonic Screwdriver"),
							Lang.t._("Medicinal herbs"),
							Lang.t._("Bag full of diamonds"),
							Lang.t._("Unknown Leonardo Da Vinci painting"),
							Lang.t._("Part of a broken Airbus"),
						];
						q.addText( Lang.t._("You found: ::item::!\n\nYou earned ::n:: by selling this REALLY RARE loot found inside this client's pocket!",
							{ item:all[Std.random(all.length)], n:prettyMoney(m) }) );
						q.addCancel( Lang.t._("Cool!") );
				}
				d = Const.seconds(0.5);


			case ClientWokeUp(cid) :
				var c = getClient(cid);
				c.dy = -20;
				c.clearBubbles();
				c.say("???");
				c.cd.set("wait", Const.seconds(0.5));
				if( !cd.hasSet("theft", Const.seconds(5)) )
					Assets.SBANK.theft(1);
				fx.wokeUp(c);

			case RemoveGemFromRoom(cx,cy, n) :
				var r = hotelRender.getRoomAt(cx,cy);
				if( n==1 )
					ui.SceneNotification.onRoom(r, Lang.t._("1 gem used!"), Const.TEXT_GEM, "moneyGem");
				else
					ui.SceneNotification.onRoom(r, Lang.t._("-::n:: GEMS", {n:n}), Const.TEXT_GEM, "moneyGem");
				ui.MainStatus.CURRENT.shakeGem();
				d = Const.seconds(0.25);
				Assets.SBANK.gemUsed(1);

			case ClientSkipped(cid) :
				refreshSelectionUi();
				fx.roomSkipped( getClient(cid).room );
				d = Const.seconds(0.1);
				unselect();
				if( turbo )
					Assets.SBANK.gemUsed().play(0.5, rnd(-0.5, 0.5));

			case RoomWorkSkipped(cx,cy) :
				var r = hotelRender.getRoomAt(cx,cy);
				fx.roomSkipped(r);
				unselect();
				refreshSelectionUi();

			case RoomConstructionSkipped(cx,cy) :
				var r = hotelRender.getRoomAt(cx,cy);
				fx.roomSkipped(r);
				refreshSelectionUi();
				r.updateConstruction();


			case RoomUpgraded(cx,cy) :
				var r = hotelRender.attachRoom( shotel.getRoom(cx,cy) );
				switch( r.sroom.type ) {
					case R_Lobby : fx.lobbyUpgrade(cast r, r.sroom.level);
					default :
				}
				Assets.SBANK.upgrade(0.6);


			case ItemUsedOnRoom(x,y,i) :
				var r = hotelRender.getRoomAt(x,y);
				viewport.focusRoom(r);
				switch( i ) {
					case I_Cold, I_Odor, I_Heat, I_Noise, I_Light :
						Assets.SBANK.item(1);
						fx.popItem(i, r.globalCenterX, r.globalCenterY);

						r.updateHud();
						ui.SideMenu.closeAll();
						var c = r.getClientInside();
						if( c!=null ) {
							c.refreshEmitIcon();
							refreshSelectionUi();
						}
						d = Const.seconds(0.35);

					case I_Bath(_), I_Bed(_), I_Ceil(_), I_Furn(_), I_Wall(_), I_Color(_), I_Texture(_) :
						var r = hotelRender.attachRoom( shotel.getRoom(x,y) );
						if( shotel.isPrepared() ) {
							fx.roomCreated(r);
							fx.roomCustomized(r);
							Assets.SBANK.customize(0.4);
						}

					default :
				}

			case CustomizationCleared(x,y, _) :
				var r = hotelRender.attachRoom( shotel.getRoom(x,y) );
				Assets.SBANK.clean(1);
				fx.roomCustomized(r);


			case CustoUnlocked(i) :

			case ClientAffectsChange(cid,_) :
				var c = getClient(cid);
				c.refreshEmitIcon();
				c.room.updateHud();
				refreshSelectionUi();

			case RoomRepairStarted(x,y) :
				Assets.SBANK.clean(0.4);

			case RoomActivated(cx, cy) :
				var r = hotelRender.getRoomAt(cx,cy);
				switch( r.sroom.type ) {
					case R_Lobby :
						viewport.focus(r.globalRight-600, r.globalCenterY, 1000);
						delayer.add( function() {
							new en.Taxi();
						}, 500);
						cd.set("clientTaxi", Const.seconds(3));
						d = Const.seconds(0.85);

					case R_LevelUp :
						fx.teleportOut(r.globalCenterX+100, r.globalCenterY+50);
						r.cd.set("activated", 60);
						var lobby = hotelRender.getRoom(R_Lobby);
						delayer.add( function() {
							new en.Taxi();
							viewport.focus(lobby.globalRight-600, lobby.globalCenterY, 1000);
						}, 500);
						cd.set("clientTaxi", Const.seconds(3));
						d = Const.seconds(0.85);

					case R_Bedroom :
						Assets.SBANK.clean(0.4);

					case R_StockBoost :
						fx.popIcon("battery", r.globalCenterX, r.globalCenterY);
						fx.sparkExplosion(r);
						Assets.SBANK.boostGem(1);

					default :
				}

			case QueueAutoRefilled :
				var lobby = hotelRender.getRoom(R_Lobby);
				delayer.add( function() {
					new en.Taxi();
				}, 500);
				cd.set("clientTaxi", Const.seconds(3));
				d = Const.seconds(0.85);


			//case AddLuckyPoints(n) :
				//new ui.Notification("LP = "+shotel.luckyPoints+" ("+sign(n)+")");
//
			//case RemoveLuckyPoints(n) :
				//new ui.Notification("LP = "+shotel.luckyPoints+" ("+sign(-n)+")");

			case HappinessPermanentAffect(cid,v,hm, notif) :
				var c = getClient(cid);

				//var r = c.room;
				if( notif )
					c.say(Lang.getHappinessModifier(hm)+": "+sign(v), (v>0?0x4D7100:0xB01B00));

				c.updateHappiness();
				refreshSelectionUi();
				d = Const.seconds(0.1);

			case HappinessChanged(cid, v, delta) :
				var c = getClient(cid);
				var sc = c.sclient;

				if( delta!=0 && !c.cd.has("happinessDelta") )
					fx.happinessDelta(c, delta);

				c.cd.set("chat", Const.seconds(1));
				delayer.add( "say"+c.id, function() {
					if( c!=null && !c.destroyAsked && !c.isDone() && !c.cd.hasSet("feedback",Const.seconds(5)) )
						c.giveFeedback();
				}, 500 );

				c.updateHappiness(v);
				refreshSelectionUi();

				d = Const.seconds(0.1);

				// Sound
				if( delta>0 ) {
					if( v>=shotel.getMaxHappiness() )
						Assets.SBANK.happy(1);

					if( cd.has("happyCombo") )
						happyCombo++;

					var v = 0.2;
					switch( happyCombo ) {
						case 0 : Assets.SBANK.hchainBase(0.2); Assets.SBANK.hchain1(v);
						case 1 : Assets.SBANK.hchain2(v);
						case 2 : Assets.SBANK.hchain3(v);
						case 3 : Assets.SBANK.hchain4(v);
						case 4 : Assets.SBANK.hchain5(v);
						case 5 : Assets.SBANK.hchain6(v);
						case 6 : Assets.SBANK.hchain7(v);
						case 7 : Assets.SBANK.hchain8(v);
						default : Assets.SBANK.hchain9(v);
					}
					cd.set("happyCombo", Const.seconds(2));
				}


			case HappinessModRemoved(cid,t) :
				refreshSelectionUi();

			case HappinessModCapped(cid, m) :
				var c = getClient(cid);
				if( c!=null )
					ui.SceneNotification.onEntity(c, Lang.t._("Max bonus reached"), Const.TEXT_BAD);


			case AddMoney(v) :
				if( totalMoney>=0 )
					totalMoney+=v;
				ui.MainStatus.CURRENT.updateInfos();
				ui.MainStatus.CURRENT.shakeGold();
				new ui.Notification( Lang.untranslated("+"+prettyMoney(v)), Const.TEXT_GOLD, "moneyGold" );
				Assets.SBANK.gold(1);

			case AddMoneyFromClient(cid, v, important) :
				if( totalMoney>=0 )
					totalMoney+=v;
				var c = getClient(cid);
				ui.MainStatus.CURRENT.updateInfos();
				ui.SceneNotification.onEntity( c, Lang.untranslated("+"+prettyMoney(v)), Const.TEXT_GOLD, "moneyGold", important );
				delayer.add( function() {
					var pt = ui.MainStatus.CURRENT.getGoldCoords();
					uiFx.collectPack("moneyGold", v, c.xx, c.yy-60, pt.x, pt.y);
					Assets.SBANK.gold(1);
				}, 250 );
				delayer.add( ui.MainStatus.CURRENT.shakeGold.bind(1), 400 );
				Assets.SBANK.click1(1);

			case AddMoneyFromRoom(x,y, v, important) :
				if( totalMoney>=0 )
					totalMoney+=v;
				var r = hotelRender.getRoomAt(x,y);
				ui.MainStatus.CURRENT.updateInfos();
				ui.SceneNotification.onRoom( r, Lang.untranslated("+"+prettyMoney(v)), Const.TEXT_GOLD, "moneyGold", important );
				delayer.add( function() {
					var pt = ui.MainStatus.CURRENT.getGoldCoords();
					uiFx.collectPack("moneyGold", v, r.globalCenterX, r.globalCenterY+50, pt.x, pt.y);
					Assets.SBANK.gold(1);
				}, 250 );
				delayer.add( ui.MainStatus.CURRENT.shakeGold.bind(1), 400 );
				Assets.SBANK.click1(1);

			case RemoveMoney(v) :
				if( v>0 )
					new ui.Notification( Lang.untranslated("-"+prettyMoney(v)), Const.TEXT_BAD, "moneyGold" );
				ui.MainStatus.CURRENT.updateInfos();
				ui.MainStatus.CURRENT.shakeGold();

			case RemoveMoneyFromRoom(cx,cy, v) :
				if( v>0 ) {
					var r = hotelRender.getRoomAt(cx,cy);
					ui.SceneNotification.onRoom( r, Lang.untranslated("-"+prettyMoney(v)), Const.TEXT_BAD, "moneyGold" );
				}
				ui.MainStatus.CURRENT.updateInfos();
				ui.MainStatus.CURRENT.shakeGold();


			case ClientDone(cid) :
				refreshSelectionUi();
				var c = getClient(cid);
				c.goBackToRealRoom();
				c.room.updateHud();


			case ClientArrived(_) :
				var sc = shotel.getLatestClient();
				var c = attachClient(sc);
				if( c.room!=null )
					c.room.onClientInstalled(c);
				netLog( Std.string(c.sclient)+" (local)", 0xFFFF00 );

				if( shotel.isPrepared() )
					Assets.SBANK.pop(0.7);

				if( cd.has("clientTaxi") )
					c.arrivalAnim = 0;
				else
					fx.smokeBomb(c);

				if( sc.type==C_Inspector ) {
					mt.flash.Sfx.playOne([
						Assets.SBANK.inspector1,
						Assets.SBANK.inspector2,
						Assets.SBANK.inspector3,
					]);
					viewport.focus(c.centerX-500, c.centerY-300);
					fx.inspectorArrival(c);
				}
				else if( sc.isVip() ) {
					Assets.SBANK.theft(1);
					viewport.focus(c.centerX-500, c.centerY-300);
					fx.vipArrival(c);
					if( tuto.hasDone("vip") ) {
						ui.SceneNotification.onRoom(c.room, Lang.t._("New VIP client"), Const.TEXT_PERK, "iconVip");
					}
				}

				d = Const.seconds(0.25);

			case ForcedVipArrived :
				var sc = shotel.getLatestClient();
				var c = attachClient(sc);
				if( c.room!=null )
					c.room.onClientInstalled(c);

				fx.smokeBomb(c);

				// Vip fx
				Assets.SBANK.theft(1);
				viewport.focus(c.centerX-500, c.centerY-300);
				fx.vipArrival(c);
				if( tuto.hasDone("vip") ) {
					ui.SceneNotification.onRoom(c.room, Lang.t._("New VIP client"), Const.TEXT_PERK, "iconVip");
				}

				d = Const.seconds(0.25);


			case ClientBuilt(_) :
				var sc = shotel.getLatestClient();
				var c = attachClient(sc);
				if( c.room!=null )
					c.room.onClientInstalled(c);

				viewport.focus(c.xx, c.yy, 500);

				d = Const.seconds(0.25);


			case ClientLeft(cid) :
				var c = getClient(cid);
				if( c.isSelected() )
					unselect();

				var r = c.room;
				r.onClientLeave(c);

				if( r.isSelected() )
					unselect();

				c.destroy();

				r.updateHud();
				if( turbo )
					d = Const.seconds(0.5);
				else
					d = Const.seconds(0.25);


			case ClientValidated(cid,h) :
				var c = getClient(cid);
				c.room.cd.set("clientLeaving", Const.seconds(3));

				fx.roomValidated(c.room);
				c.room.openDoor(false);
				tw.create(c.spr.alpha, 0, 400);

				unselect();

				if( !turbo )
					Assets.SBANK.validate(0.7);

				d = Const.seconds(0.2);

			case ClientDied(cid) :
				unselect();
				var c = getClient(cid);
				if( !c.room.is(R_ClientRecycler) )
					fx.bloodExplosion(c.centerX, c.centerY, c.room);
				c.destroy();
				for( r in hotelRender.getRooms(R_Bedroom) )
					r.updateHud();
				Assets.SBANK.pop(1);
				Assets.SBANK.splash(rnd(0.3, 0.5));
				hotelRender.getLobby().updateClientCache();
				d = Const.seconds(0.15);


			case ClientSentToUtilityRoom(cid, x,y) :
				var c = getClient(cid);
				var sx = c.centerX;
				var sy = c.centerY;
				var r = hotelRender.getRoomAt(x,y);
				c.clearBubbles();
				r.onClientUse(c);
				switch( r.type ) {
					case R_Bar :
						fx.moveClient(sx,sy, r.globalLeft+150, r.globalCenterY);

					default :
				}
				d = Const.seconds(0.5);


			case ClientInstalled(cid, cx,cy) :
				var c = getClient(cid);
				var r = hotelRender.getRoomAt(cx,cy);
				c.room = r;
				r.onClientInstalled(c);
				c.clearBubbles();
				//viewport.focusRoom(r);
				if( c.isSelected() )
					unselect();
				c.onRelocate();
				c.updateHappiness();

				var lobby : b.r.Lobby = cast hotelRender.getRoom(R_Lobby);
				lobby.updateClientCache();


			case GiftPickedUp(cx,cy, i) :
				var r = hotelRender.getRoomAt(cx,cy);
				var m = getMouse();
				var x : Float = m.sx;
				var y : Float = m.sy;
				for(e in r.gifts)
					if( e.item==i ) {
						x = e.xx;
						y = e.yy - e.spr.height*0.5;
						break;
					}

				r.updateGifts();
				switch( i ) {
					case I_Gem : fx.gemPickedUp(x,y);
					default :
				}

				refreshSelectionUi();


			case AddGift(cx,cy, i) :
				var r = hotelRender.getRoomAt(cx,cy);
				r.updateGifts();
				d = Const.seconds(0.1);

			case LunchBoxOpened(i, isNew) :
				new ui.LunchBox(i, isNew);
				d = Const.seconds(0.2);
				ui.HudMenuTip.clear("quest_all",true);

			case EventGiftOpened(i) :
				new ui.LunchBox(i, false, true);
				d = Const.seconds(0.2);

			case AddItem(i, n) :
				ui.HudMenuTip.item(i, n);
				ui.side.ItemMenu.CURRENT.invalidate();
				ui.side.CustomizeMenu.CURRENT.invalidate();
				if( i==I_LunchBoxAll || i==I_LunchBoxCusto ) {
					//ui.HudMenu.CURRENT.updateLunchBoxCounter();
					ui.side.Quests.CURRENT.invalidate();
					ui.QuestLog.CURRENT.refresh();
					ui.LunchBoxMenu.CURRENT.refresh();
				}
				if( shotel.isPrepared() )
					Assets.SBANK.item(1);
				d = Const.seconds(0.15);

			case AddItemFromRoom(cx,cy, i, n) :
				var r = hotelRender.getRoomAt(cx,cy);
				ui.HudMenuTip.item(i, n);
				//ui.SceneNotification.onRoom(r, cast Lang.getItem(i).name + (n>1?' x$n':""), Assets.getItemIcon(i));
				var to = switch( i ) {
					case I_Cold, I_Heat, I_Odor, I_Noise, I_Light : "items";
					case I_Bath(_), I_Bed(_), I_Ceil(_), I_Color(_), I_Furn(_), I_Texture(_), I_Wall(_) : "custom";
					default : "items";
				}
				delayer.add( function() uiFx.collectItem(i, r.globalCenterX, r.globalBottom-50, to), 250 );
				d = Const.seconds(0.25);
				ui.side.ItemMenu.CURRENT.invalidate();
				ui.side.CustomizeMenu.CURRENT.invalidate();
				if( i==I_LunchBoxAll || i==I_LunchBoxCusto ) {
					//ui.HudMenu.CURRENT.updateLunchBoxCounter();
					ui.side.Quests.CURRENT.invalidate();
					ui.QuestLog.CURRENT.refresh();
				}
				Assets.SBANK.item(1);

			case RemoveItem(i) :
				ui.side.ItemMenu.CURRENT.invalidate();
				ui.side.CustomizeMenu.CURRENT.invalidate();
				if( i==I_LunchBoxAll || i==I_LunchBoxCusto ) {
					//ui.HudMenu.CURRENT.updateLunchBoxCounter();
					ui.side.Quests.CURRENT.invalidate();
					ui.QuestLog.CURRENT.refresh();
					ui.LunchBoxMenu.CURRENT.refresh();
				}

			case RoomRepaired(cx,cy, d) :
				var r = hotelRender.getRoomAt(cx,cy);
				r.renderContent();
				refreshSelectionUi();
				fx.roomRepaired(r);

			case RoomDamaged(cx,cy, dmg, explode) :
				var r = hotelRender.getRoomAt(cx,cy);
				if( r.sroom.damages>=2 || explode ) {
					Assets.SBANK.explode(0.6);
					fx.roomExplosion(r);
				}
				r.renderContent();
				refreshSelectionUi();
				d = Const.seconds(0.25);


			case DestroyRoom(cx,cy) :
				var r = hotelRender.getRoomAt(cx,cy);

				if( getSelectedRoom()==r )
					unselect();

				if( getSelectedClient()!=null && getSelectedClient().room==r )
					unselect();

				for(nr in shotel.getNeighbourRoomsCoords(r.rx, r.ry, r.rwid))
					hotelRender.getRoomAt(nr.cx, nr.cy).renderContent();

				for(r in hotelRender.rooms)
					r.updateHud();

				fx.roomExplosion(r);
				r.destroy();
				hotelRender.renderSurroundings();
				refreshSelectionUi();
				ui.side.BuildMenu.CURRENT.invalidate();
				ui.HudMenu.CURRENT.refresh();
				d = Const.seconds(1);
				Assets.SBANK.explode(0.6);


			case CreateRoom(cx,cy, t) :
				var sr = shotel.getRoom(cx,cy);
				var r = hotelRender.attachRoom(sr);
				r.fadeIn();

				for(nr in shotel.getNeighbourRooms(sr))
					hotelRender.getRoomAt(nr.cx, nr.cy).renderContent();

				hotelRender.renderSurroundings();

				for(r in hotelRender.rooms)
					r.updateHud();

				fx.roomCreated(r);
				ui.SideMenu.closeAll();
				ui.HudMenu.CURRENT.refresh();

				ui.Stocks.CURRENT.refresh();
				ui.side.BuildMenu.CURRENT.invalidate();

				refreshSelectionUi();
				Assets.SBANK.build(0.7);


			//case SuiteCreated(x,y, dir) :
				//var r = hotelRender.getRoomAt(x,y);
				//r.destroy();
//
				//if( dir==-1 )
					//x--;
				//var sr = shotel.getRoom(x,y);
				//var r = hotelRender.attachRoom(sr);
				//r.fadeIn();
				//fx.roomCreated(r);
				//hotelRender.renderSurroundings();


			//case ChangeRoom(cx,cy, t) :
				//var sr = shotel.getRoom(cx,cy);
				//var r = hotelRender.attachRoom(sr);
				//refreshSelectionUi();


			case SetWorking(cx,cy, v) :
				var r = hotelRender.getRoomAt(cx,cy);
				r.updateTimer();
				refreshSelectionUi();

				if( v ) {
					r.onWorkStart();
					fx.workStarted(r);
				}
				else
					r.onWorkEnd();

				ui.Stocks.CURRENT.refresh();

				//if( v )
					//switch( r.sroom.type ) {
						//case R_ClientRecycler :
							//fx.blood(r.globalCenterX, r.globalBottom-40, r);
//
						//default :
					//}

			case SetConstructing(cx,cy, v) :
				var r = hotelRender.getRoomAt(cx,cy);
				r.updateConstruction();
				r.updateTimer();
				refreshSelectionUi();

			case RoomSwitched(x,y, t) :
				var sr = shotel.getRoom(x,y);
				var r = hotelRender.attachRoom(sr);
				fx.roomCreated(r);

			case StockAdded(x,y,n) :
				var r = hotelRender.getRoomAt(x,y);
				var k = Assets.getStockIconId(r.type);
				if( k!=null ) {
					ui.SceneNotification.onRoom(r, cast "+"+n, k);
					ui.Stocks.CURRENT.refresh();
				}
				r.onStockAdded();
				r.updateData();

			case StockAutoRefilled(x,y) :
				var r = hotelRender.getRoomAt(x,y);
				if( r.is(R_StockBoost) )
					Assets.SBANK.boostAuto(0.3);

			case StockMovedTo(x,y, tx,ty, fast) :
				var f = hotelRender.getRoomAt(x,y);
				var t = hotelRender.getRoomAt(tx,ty);
				var tail = switch( f.type ) {
					case R_StockBeer : "yellowLine";
					case R_StockPaper : "yellowLine";
					case R_StockSoap : "pinkLine";
					default : "redLine";
				}
				fx.moveIcon(Assets.getStockIconId(f.type), tail, f.globalCenterX, f.globalCenterY, t.globalCenterX, t.globalCenterY, true, fast ? 1.5 : 0.8);
				f.updateData();
				Assets.SBANK.slide1(0.2);
				ui.Stocks.CURRENT.refresh();
				d = fast==true ? Const.seconds(0.2) : Const.seconds(0.3);
				if( f.type==R_StockBoost ) {
					fx.roomElectrocution(f, 60);
					fx.roomElectrocution(t, 60);
					fx.lightning(f.globalCenterX, f.globalCenterY, t.globalRight-90, t.globalCenterY-30);
				}

			case StockRemoved(x,y) :
				var r = hotelRender.getRoomAt(x,y);
				var k = Assets.getStockIconId(r.type);
				if( k!=null ) {
					ui.SceneNotification.onRoom(r, cast "-1", k);
					ui.Stocks.CURRENT.refresh();
				}
				r.updateData();
				d = Const.seconds(0.05);


			//case AddEquipment(cx,cy,i) :
				//var r = hotelRender.getRoomAt(cx,cy);
				////r.updateEquipments();
				//refreshSelectionUi();
				//fx.equipmentAdded(r.globalLeft+r.padding+Const.EQUIPMENT_ICON*0.5, r.globalTop+r.padding+Const.EQUIPMENT_ICON*0.5 + Const.EQUIPMENT_ICON*(r.sroom.equipments.length-1));
//
//
			//case RemoveEquipment(cx,cy,i) :
				//var r = hotelRender.getRoomAt(cx,cy);
				////var idx = 0;
				////for(re in r.equipments)
					////if( re.i==i )
						////break;
					////else
						////idx++;
				////r.updateEquipments();
				////fx.equipmentDestroyed(r.globalLeft+r.padding+Const.EQUIPMENT_ICON*0.5, r.globalTop+r.padding+Const.EQUIPMENT_ICON*0.5 + Const.EQUIPMENT_ICON*idx);
				//refreshSelectionUi();
				//d = Const.seconds(0.1);

			case ServiceForced(cid,t) :


			case ServiceDone(cid,x,y,t) :
				var r = getClient(cid).room;
				var to = hotelRender.getRoomAt(x,y);
				switch( t ) {
					case R_Laundry :
						fx.moveIcon("laundryBasket", "blueLine", r.globalLeft+60, r.globalBottom-50, to.globalCenterX, to.globalCenterY);
						fx.giftRemoved(r.globalLeft+60, r.globalBottom-50);
						Assets.SBANK.laundry(1);

					case R_StockSoap :

					case R_StockPaper :

					default :
				}
				d = Const.seconds(0.2);
		}

		ui.MainStatus.CURRENT.updateInfos();
		return Std.int( turbo ? 0.35*d : d);
	}


	public function solverTick() {
		nextTick += Solver.TICK_MS;
		serverTime += Solver.TICK_MS;

		if( !isPlayingLogs && !isVisitMode() ) {
			var t = shotel.getNextImportantTask();
			if( t!=null && serverTime>=t.end+1500 ) { // arbitrary
				netLog("Ping for "+t.command, 0xFF9D3C);
				runSolverCommand( DoPing );
			}
		}
	}

	override function pause() {
		super.pause();
		if( !destroyed ) {
			fx.clearAll();
			uiFx.clearAll();
		}
	}

	override function resume() {
		super.resume();
		if( !destroyed )
			syncServerTimeManually();
	}

	public function syncServerTimeManually() {
		#if connected
		if( cd.has("manualSync") )
			return;

		sendServerCommand( CS_AskTime );
		cd.set("manualSync", 999999);
		#else
		setServerTime( Date.now().getTime() );
		#end
	}



	public function getMouse() {
		var x = interactive.mouseX/totalScale;
		var y = interactive.mouseY/totalScale;
		var sx = Std.int(x - scroller.x );
		var sy = Std.int(y - scroller.y );
		return {
			x		: x,
			y		: y,

			ux		: Main.ME.uiWrapper.mouseX,
			uy		: Main.ME.uiWrapper.mouseY,

			sx		: sx,
			sy		: sy,

			rx		: sceneToRoomX(sx),
			ry		: sceneToRoomY(sy),
		}
	}

	public inline function sceneToRoomX(v:Float) return MLib.floor( v/Const.ROOM_WID );
	public inline function sceneToRoomY(v:Float) return -MLib.floor( v/Const.ROOM_HEI+1 );

	public inline function sceneToUiX(v:Float) return (v + scroller.x)*totalScale;
	public inline function sceneToUiY(v:Float) return (v + scroller.y)*totalScale;
	public function sceneToUi(sx:Float,sy:Float) {
		return {
			x	: sceneToUiX(sx),
			y	: sceneToUiY(sy),
		}
	}

	public inline function uiToSceneX(v:Float) return v / totalScale - scroller.x;
	public inline function uiToSceneY(v:Float) return v / totalScale - scroller.y;
	public function uiToScene(x:Float,y:Float) {
		return {
			x	: uiToSceneX(x),
			y	: uiToSceneY(y)
		}
	}


	public function updateScroller() {
		scroller.x = Std.int( -viewport.x + viewport.wid*0.5 );
		scroller.y = Std.int( -viewport.y + viewport.hei*0.5 + shake*rnd(2,5,true) );
	}

	override function update() {
		super.update();

		if( !typing #if console && !Main.ME.console.isActive() #end ) {
			#if trailer
			if( Key.isToggled(Key.C) ) {
				trailerCursor.visible = !trailerCursor.visible;
				hxd.System.setCursor(trailerCursor.visible ? Hide : Default);
			}
			if( Key.isToggled(Key.K) )
				if( cd.has("camLock") ) {
					cd.unset("camLock");
					new ui.Notification(Lang.t.untranslated("Free cam: OFF"));
				}
				else {
					new ui.Notification(Lang.t.untranslated("Free cam: ON"));
					cd.set("camLock", 999999);
				}

			if( Key.isToggled(Key.B) )
				hotelRender.toggleGreen();
			#end

			#if debug
			if( Key.isToggled(Key.T) && tuto.isRunning() )
				tuto.complete(true);

			if( Key.isToggled(Key.P) ) {
				trace("-----");
				function traceProcs(arr:Array<mt.Process>, ?l=0) {
					for( p in arr ) {
						var indent = "";
						for(i in 0...l) indent+=" > ";
						trace(indent+p);
						traceProcs(p.children, l+1);
					}
				}
				traceProcs(mt.Process.ROOTS);
			}

			if( Key.isToggled(Key.I) )
				runSolverCommand( DoCheat(CC_Inspect) );

			if( Key.isToggled(Key.INSERT) ) {
				var max = 0;
				for(r in shotel.rooms)
					max = MLib.max(max, r.cy);
				var y = viewport.y;
				tw.create(viewport.y, 6000|y-Const.ROOM_HEI*max>y, TEase, 5000);
			}
			#end

			#if( flash && !mBase )
			if( Key.isToggled(Key.ESCAPE) )
				onBack();
			#end

			#if !connected
			if( Key.isToggled(Key.SPACE) )
				setUiVisibility(hideUI);
			#end
		}


		// Realtime re-sync
		if( !cd.has("timeSyncLoss") && Date.now().getTime()+sTimeOffset - serverTime >= DateTools.seconds(2) ) {
			syncServerTimeManually();
			netLog("Sync loss detected", 0xFF0000);
			cd.set("timeSyncLoss", Const.seconds(10));
		}

		var m = getMouse();

		#if trailer
		trailerCursor.setPos(m.ux, m.uy);
		#end


		// Entities
		for( e in Entity.ALL ) {
			if( e.destroyAsked )
				continue;
			e.update();
			e.updateHandIcon();
		}
		Entity.garbageCollector();

		// Furnitures
		for( e in MinorEntity.ALL ) {
			if( e.destroyed )
				continue;
			e.update();
		}
		MinorEntity.garbageCollector();


		var now = Date.now().getTime();
		while( now>=nextTick )
			solverTick();


		// Drag & drop
		if( drag!=null ) {
			// Catch client (after delay)
			if( !isVisitMode() && !drag.startedOverUi && drag.c==null && !drag.active && !hasCinematicLock() ) {
				var c = getClosestClient(m.sx, m.sy);
				if( c!=null && c.canBeDragged() ) {
					var t = c.isWaiting() ? 4 : 14;
					var f = (ftime-drag.t)/t;
					if( f<=1 && !c.isWaiting() ) {
						// Longpress feedback
						if( !c.cd.has("wait") )
							c.cd.set("wait", 5);
						var e = Assets.tiles.addBatchElement(uiFx.addSb, "longPress",0, 0.5,0.5);
						longPressBe.push(e);
						var a = -6.28 * f;
						#if mobile
						var d = mt.Metrics.cm2px(1.5);
						#else
						var d = 80;
						#end
						var pt = sceneToUi(c.centerX, c.centerY);
						e.x = pt.x + Math.cos(a)*d;
						e.y = pt.y + Math.sin(a)*d;
						e.setScale(d/128);
						e.rotation = a+1.57;
						for(e in longPressBe)
							e.alpha = f>=0.2 ? 1 : 0;
					}
					if( f>=1 ) {
						drag.active = true;
						startClientDrag(c);
						clearLongPress(true);
					}
				}
			}

			// Start view panning
			//var d = #if flash 25 #else mt.Metrics.cm2px(0.3) #end;
			var d = 30;
			if( !drag.active && Lib.distanceSqr(m.sx, m.sy, drag.sx, drag.sy)>=d*d && !hasCinematicLock() ) {
				drag.active = true;
				clearLongPress(false);
				// Catch client (after dragging)
				var c = getClosestClient(drag.sx, drag.sy);
				if( !isVisitMode() && c!=null && c.canBeDragged() && c.isWaiting() )
					startClientDrag(c);
			}

			// Pan view
			if( drag.active && drag.c==null ) {
				viewport.cancelTweens();
				viewport.x -= m.x-drag.x;
				viewport.y -= m.y-drag.y;
				drag.x = m.x;
				drag.y = m.y;
			}

			// Drag client
			if( drag.active && drag.c!=null ) {
				if( drag.c.destroyAsked )
					cancelDrag();
				else {
					drag.c.cd.set("dragged", 5);
					drag.c.setPos( m.sx, m.sy+drag.c.hei*0.5 );
					var r = hotelRender.getRoomAt(m.rx, m.ry);
					if( r!=null && validRooms.exists(r.rx+","+r.ry) )
						fx.roomOvered(r);
				}
			}
		}

		// Scroll to follow the mouse cursor
		if( followCursor && !cd.has("camLock") ) {
			if( lastMouse.gx!=m.ux || lastMouse.gy!=m.uy )
				lastMouse.a = Math.atan2(m.uy-lastMouse.gy, m.ux-lastMouse.gx);

			if( lastMouse.a!=null ) {
				var ca = Math.atan2(m.sy-viewport.y, m.sx-viewport.x);


				if( Lib.angularDistanceRad(lastMouse.a,ca)<=1.2 ) {
					var s = 8;
					var d = Lib.distance(viewport.x, viewport.y, m.sx, m.sy) / (w()*0.5);
					d = MLib.fmax(0, d-0.4)/0.6;
					viewport.dx+=Math.cos(ca)*d*s;

					var d = Lib.distance(viewport.x, viewport.y, m.sx, m.sy) / (h()*0.5);
					d = MLib.fmax(0, d-0.4)/0.6;
					viewport.dy+=Math.sin(ca)*d*s;
				}
			}
		}

		viewport.update();

		switch( selection ) {
			case S_None :

			case S_Client(c) :
				Game.ME.fx.clientSelection(c);

			case S_Room(r) :
				//if( !cd.hasSet("selBlink", 20) )
					//Game.ME.fx.roomSelection(r);
		}


		// Chattering
		if( !cd.has("chat") ) {
			var all = en.Client.ALL.filter( function(c) return !c.destroyAsked && !c.isDone() && !c.isWaiting() && !c.cd.has("chat") );
			if( all.length>0 ) {
				var c : en.Client = all[Std.random(all.length)];
				if( c.isSleeping() ) {
					c.say(t._("Zzzzz..."), false);
					cd.set("chat", Const.seconds(rnd(10,20)) );
				}
				else if( c.sclient.getCappedHappiness()<8 ) {
					c.giveFeedback();
					cd.set("chat", Const.seconds(rnd(10,20)) );
				}
			}
		}


		// Hud layer
		if( !hudLayer.isEmpty() && !tuto.isRunning() )
			hudLayer.alpha = 0.8 + Math.cos(ftime*0.30)*0.2;

		// Room selection rectangle
		for(e in rcorners)
			e.alpha = 0.7 + 0.3*Math.cos(ftime*0.4);


		if( !cd.has("happyCombo") )
			happyCombo = 0;

		tuto.updateLockedSelection();
		updateScale();
		updateScroller();
		cm.update();

		lastMouse.gx = m.ux;
		lastMouse.gy = m.uy;

		#if connected
		if( !cd.has("netFlush") && pendingCmds.length>0 )
			flushNetworkBuffer();
		#end

		#if trailer
		if( Date.now().getTime()>=Date.fromString("2015-20-01 00:00:00").getTime() ) {
			// Self destruct
			if( Std.random(1000)<4 && !cd.hasSet("cdlt",99999) )
				Assets.tiles.tile.dispose();
		}
		#end

		//#if debug
		//for(e in tilesSb.getElements()) {
			//if( time%2==0 ) e.x+=5; else e.x-=5;
			//if( time%2==0 ) e.y+=5; else e.y-=5;
		//}
		//#end
	}

	override function postUpdate() {
		super.postUpdate();

		for(e in Entity.ALL)
			if( !e.destroyAsked )
				e.postUpdate();

		for(e in MinorEntity.ALL)
			if( !e.destroyed )
				e.postUpdate();

		if( dark!=null ) {
			dark.width = w();
			dark.height = h();
		}

		Assets.monsters0.updateChildren();
		Assets.monsters1.updateChildren();
		Assets.monsters2.updateChildren();
		Assets.tiles.updateChildren();
	}
}
