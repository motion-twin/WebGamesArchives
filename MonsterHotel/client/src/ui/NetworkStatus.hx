package ui;

#if !connected
#error "Only in connected version"
#end

import mt.deepnight.Tweenie;
import mt.MLib;
import b.Room;
import h2d.SpriteBatch;

class NetworkStatus extends H2dProcess {
	public static var CURRENT : NetworkStatus;

	var sb				: h2d.SpriteBatch;
	var tsb				: h2d.SpriteBatch;
	var state			: Int;
	var serverWait		: Null<Int>;
	var isize = 30;

	public function new() {
		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_NOTIFICATION);

		state = -1;
		name = "NetworkStatus";
		root.name = name;
		CURRENT = this;
		serverWait = null;

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;
		sb.name = name+".sb";

		tsb = new h2d.SpriteBatch(Assets.fontTiny.tile, root);
		tsb.filter = true;
		tsb.name = name+".tsb";

		var iw = isize*1.5;
		var i = new h2d.Interactive(iw, iw, root);
		i.onClick = onClick;
		//i.backgroundColor = alpha(0xFF00FF,0.5);
		i.x = -isize*0.5-iw*0.5;
		i.y = -iw*0.5;

		setState(0);
	}

	function onClick(_) {
		if( Game.ME.tuto.commandLocked("click") || Game.ME.tuto.commandLocked("side") || Game.ME.tuto.isRunning() )
			return;

		var q = new ui.Question();
		q.addText(Lang.t._("Network status:"), Const.TEXT_GRAY, false, 0.6);
		switch( state ) {
			case 0 : q.addText( Lang.t._("Connected."), Const.TEXT_PERK, false );
			case 1 : q.addText( Lang.t._("Waiting for server..."), Const.TEXT_GOLD, false );
			case 2 : q.addText( Lang.t._("Disconnected!"), Const.TEXT_BAD, false );
		}
		q.addSeparator();
		switch( state ) {
			case 0 :
				q.addText( Lang.t._("Everything is fine, your progress is properly saved online.") );
			case 1 :
				q.addText( Lang.t._("Our servers are taking some time to respond. The reason might be a temporary slow internet connection.") );
				#if flash
					q.addText( Lang.t._("Also, please check that nothing blocks the game (firewall or ad-blockers)!") );
				#else
					q.addText( Lang.t._("Please make sure your game is up-to-date!") );
					#if mBase
					q.addButton( Lang.t._("Check for updates"), function() {
						mtnative.device.Device.showStoreProduct();
					});
					#end
				#end
			case 2 :
				q.addText( Lang.t._("You are disconnected from our servers: your progress is properly saved on your device, but not online.") );
				#if flash
					q.addText( Lang.t._("Also, please check that nothing blocks the game (firewall or ad-blockers)!") );
				#else
					q.addText( Lang.t._("Please make sure your game is up-to-date!") );
					#if mBase
					q.addButton( Lang.t._("Check for updates"), function() {
						mtnative.device.Device.showStoreProduct();
					});
					#end
				#end
		}
		q.addCancel( Lang.t._("Close") );
	}

	public static inline function hide() {
		if( CURRENT!=null )
			CURRENT.setState(0);
	}

	public static inline function show() {
		if( CURRENT!=null )
			CURRENT.setState(1);
	}

	public static inline function showUrgent() {
		if( CURRENT!=null )
			CURRENT.setState(2);
	}

	function setState(s:Int) {
		if( state==s )
			return;

		state = s;
		killAllChildrenProcesses();
		sb.removeAllElements();
		tsb.removeAllElements();
		switch( state ) {
			case 0 :
				#if responsive
				var icon = Assets.tiles.hbe_get(sb, "networkGreen",0, 1,0.5);
				icon.constraintSize(isize);
				//var tf = Assets.createBatchText(tsb, Assets.fontTiny, 24, 0xFFFFFF, Lang.t._("Connected"));
				//tf.dropShadow = { color:0x0, alpha:1, dx:1, dy:3 }
				//tf.x = -icon.width - 10 - tf.textWidth*tf.scaleX;
				//tf.y = -tf.textHeight*tf.scaleY*0.5;
				#end

			case 1,2 :
				var bg = Assets.tiles.hbe_get(sb, "popUpBg");
				bg.setCenterRatio(1,0.5);
				bg.colorize(Const.BLUE);
				bg.height = isize-4;
				var glow = Assets.tiles.hbe_get(sb, state==1?"yellowBigDot":"redBigDot",0, 0.5,0.5);
				glow.constraintSize(isize*(state==1?3:4));
				glow.x = -isize*0.5;
				glow.alpha = 0.8;
				var icon = Assets.tiles.hbe_get(sb, state==1?"networkOrange":"networkRed",0, 0.5,0.5);
				icon.x = -isize*0.5;
				icon.constraintSize(isize);
				var tf = Assets.createBatchText(tsb, Assets.fontTiny, 24, state==1?0xFFFF80:0xFF3535, state==1?Lang.t._("Waiting server..."):Lang.t._("No internet connection!"));
				tf.dropShadow = { color:0x0, alpha:1, dx:1, dy:3 }
				tf.x = -icon.width - 10 - tf.textWidth*tf.scaleX;
				tf.y = -tf.textHeight*tf.scaleY*0.5;
				bg.width = tf.textWidth*tf.scaleX + isize + 40;
				createChildProcess(function(_) {
					if( state==1 && canPing() && !cd.hasSet("ping", 60) )
						Game.ME.uiFx.ping(root.x - icon.width*0.5*root.scaleX, root.y, "fxNovaYellow", 0.5);
					if( state==2 && canPing() && !cd.hasSet("ping", 30) )
						Game.ME.uiFx.ping(root.x - icon.width*0.5*root.scaleX, root.y, "fxNovaRed", 0.5);
				});

			//case 2 :
				//var icon = Assets.tiles.hbe_get(sb, "networkRed",0, 0.5,0.5);
				//icon.constraintSize(isize);
				//icon.x = -isize*0.5;
				//var glow = Assets.tiles.hbe_get(sb, "redBigDot",0, 0.5,0.5);
				//glow.constraintSize(isize*4);
				//glow.x = icon.x;
				//glow.alpha = 0.6;
				//var tf = Assets.createBatchText(tsb, Assets.fontTiny, 24, 0xFF3535, );
				//tf.dropShadow = { color:0x0, alpha:1, dx:1, dy:3 }
				//tf.x = -icon.width - 10 - tf.textWidth*tf.scaleX;
				//tf.y = -tf.textHeight*tf.scaleY*0.5;
				//createTinyProcess(function(_) {
					//if( canPing() && !cd.hasSet("ping", 30) )
						//Game.ME.uiFx.ping(root.x - icon.width*0.5*root.scaleX, root.y, "fxNovaRed", 0.5);
				//});
		}

		onResize();
	}

	function canPing() {
		return ui.SideMenu.allClosed() && !Game.ME.hasAnyPopUp() && !Game.ME.tuto.isRunning();
	}

	override function onDispose() {
		super.onDispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	override function onResize() {
		super.onResize();

		root.setScale( Main.getScale(30, 0.3) );
		//if( ui.HudMenu.CURRENT.isSmallScreen() )
			//root.x = w() - ui.HudMenu.CURRENT.bsize*root.scaleX;
		//else
			root.x = w() - 10*root.scaleX;
		root.y = h() - (isize*0.5 + 10)*root.scaleX;
	}

	public function onCommandsSent() {
		if( serverWait==null )
			serverWait = 0;
	}

	public function onServerResponse() {
		if( Game.ME.pendingCmds.length>0 )
			serverWait = 0;
		else {
			setState(0);
			serverWait = null;
		}
	}

	override function update() {
		super.update();


		root.visible = state!=0 || !ui.HudMenu.CURRENT.isSmallScreen();

		var hasPending = Game.ME.pendingCmds.length>0;
		if( serverWait!=null ) {
			serverWait++;

			if( hasPending )
				if( serverWait>=Const.seconds(#if flash 10 #else 25 #end) )
					setState(2);
				else if( serverWait>=Const.seconds(#if flash 3 #else 5 #end) )
					setState(1);
		}
	}
}


