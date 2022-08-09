package ui;

import mt.MLib;
import mt.data.GetText;
import com.*;
import com.Protocol;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

#if( prod && connected )
import mt.net.FriendRequest;
#end

class VisitMenu extends H2dProcess {
	public static var CURRENT : VisitMenu;

	var shotel(get,null)	: com.SHotel; inline function get_shotel() return Game.ME.shotel;
	var sb					: SpriteBatch;
	var tsb					: SpriteBatch;
	var iwrapper			: h2d.Sprite;
	var isize = 128;
	var bwid = 700;

	public function new() {
		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		CURRENT = this;
		name = "VisitMenu";
		root.y = h();
		iwrapper = new h2d.Sprite(root);

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;

		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, root);
		tsb.filter = true;

		refresh();
	}


	public function refresh() {
		sb.removeAllElements();
		tsb.removeAllElements();
		iwrapper.removeAllChildren();

		killAllChildrenProcesses();

		#if connected
		var iwid = 128;
		var bwid = 700;

		if( Game.ME.isVisitFromUrl() )
			return;

		if( !shotel.featureUnlocked("love") )
			return;

		if( shotel.canGetLoveFromHotel(Game.ME.hdata.curHotelId) ) {
			//if( shotel.playedRecently(Game.ME.serverTime) ) {
				// Get love button
				var n = Solver.getLoveFromState(shotel.getState());
				if( Main.ME.visitMyHotel!=null ) {
					var myHotel = new com.SHotel(Main.ME.visitMyHotel);
					n += myHotel.getVisitLoveBonus();
				}

				var locked = false;
				createButton(
					Lang.t._("Get ::n:: LOVE from this hotel", {n:n}),
					Lang.t._("The amount of love you get depends on the decorations and the number of stars this hotel has."),
					"moneyLove",
					function() {
						if( locked )
							return;
						locked = true;

						// Send command to server
						Game.ME.sendMiscCommand( MC_GetLove(Game.ME.hdata.curHotelId, Game.ME.serverTime) );

						// Apply getLove locally
						shotel.direct_getLove(Game.ME.serverTime, Game.ME.hdata.curHotelId, n);
						ui.MainStatus.CURRENT.updateInfos();

						var pt = ui.MainStatus.CURRENT.getLoveCoords();
						Game.ME.uiFx.loveCollected( Main.ME.w()*0.5, Main.ME.h()*0.85 );
						Game.ME.uiFx.collectPack("moneyLove", 5, Main.ME.w()*0.5, Main.ME.h()*0.83, pt.x, pt.y); // TODO
						new ui.Notification(Lang.t._("You received love (x::n::)", {n:n}), Const.TEXT_LOVE, "moneyLove");
						Assets.SBANK.love(1);
						Assets.SBANK.cashRegister(0.5);
						Game.ME.delayer.add( ui.MainStatus.CURRENT.shakeLove.bind(1), 400 );

						destroy();
					}
				);
			//}
			//else {
				//// Ask to play again (long absence)
				//createButton(
					//Lang.t._("Ask ::name:: to come back", {name:Game.ME.getUserName()}),
					//Lang.t._("::name:: hasn't been around recently: you can call your friend back if you want to get love from its hotel!", {name:Game.ME.getUserName()}),
					//"iconMail",
					//function() {
						//#if( prod && connected )
						//var r = HFR_ComeBack;
						//var d = ui.side.Inbox.getReqData( Type.enumIndex(r) );
						//var friend : Friend = {
							//net			: -1, // TODO
							//id			: "???", // TODO
							//name		: "",
							//avatar		: "",
							//invitable	: false,
						//}
						//mt.device.FriendRequest.request( r.getIndex(), d.message, [friend], d.data, function() {
							//new ui.Notification( Lang.t._("Your request has been sent!"), "iconMail" );
							//destroy();
						//});
						//#end
					//}
				//);
			//}
		}
		else {
			// Cannot get love
			var tf = createButton(
				Lang.t._("Please wait..."),
				null,
				"iconSkip"
			);
			root.visible = false;

			cd.set("tick", Const.seconds(1));
			createChildProcess(function(p) {
				if( cd.has("tick") )
					return;

				cd.set("tick", Const.seconds(1));

				var t = shotel.getTask( InternalSetFlag("love_"+Game.ME.hdata.curHotelId, false) );
				if( t!=null ) {
					if( ( t.end<=Game.ME.serverTime ) && !cd.hasSet("refresh", 9999) ) {
						new ui.Loading( Game.ME.sendMiscCommand.bind( MC_EndVisit ) );
					}
					else {
						tf.text = Lang.t._( "You already got love from this hotel. You will be able to come back for more in: ::t::", {t:Game.ME.prettyTime(t.end)} );
						tf.y = iwid*0.5 - tf.textHeight*tf.scaleY*0.5;
					}
				}

				root.visible = true;
			});
		}
		#end

		onResize();
	}

	function runFakeCommand(c:GameCommand) {
		var solver = new com.Solver(shotel.getState(), Game.ME.serverTime);
		if( solver.doCommand(c) ) {
			for( e in solver.getLastEffectsCopy() )
				Game.ME.applyEffect(e);
		}
	}

	function createButton(label:String, subLabel:Null<String>, icon:String, ?counter=0, ?cb:Void->Void) {
		// Ask to play again (long absence)
		var dark = Assets.tiles.addBatchElement(sb, "notifBg",0);
		dark.x = isize*0.5;
		dark.y = 10;
		dark.width = bwid-dark.x;
		dark.height = isize-dark.y*2;
		dark.alpha = 0.9;

		if( cb!=null ) {
			var bg = Assets.tiles.addBatchElement(sb, "btnBlankBig",1, 0.5,0.5);
			bg.setScale( isize/bg.width );
			bg.setPos(isize*0.5, isize*0.5);
		}

		var icon = Assets.tiles.addBatchElement(sb, icon,0, 0.5,0.5);
		icon.setScale( isize*(cb==null?1:0.65)/icon.width );
		icon.x = isize*0.5;
		icon.y = isize*0.5 + (cb==null?0:-3);

		if( counter>0 ) {
			var tf = Assets.createBatchText(tsb, Assets.fontHuge, 40, 0xFFFFFF, cast Std.string(counter));
			tf.x = icon.x - tf.textWidth*tf.scaleX*0.5;
			tf.y = icon.y - tf.textHeight*tf.scaleY*0.5;
		}

		var tf = Assets.createBatchText(tsb, Assets.fontHuge, 28, subLabel==null ? Const.TEXT_GRAY : 0xFFFFFF, cast label);
		tf.dropShadow = { color:0x0, alpha:1, dx:2, dy:3 }
		tf.x = isize + 5;
		tf.y = isize*0.5 - tf.textHeight*tf.scaleY * (subLabel==null?0.5:1);
		tf.maxWidth = (bwid - tf.x) / tf.scaleX;
		var tf1 = tf;

		if( subLabel!=null ) {
			var tf = Assets.createBatchText(tsb, Assets.fontHuge, 19, Const.TEXT_GRAY, cast subLabel);
			tf.dropShadow = { color:0x0, alpha:1, dx:2, dy:3 }
			tf.x = isize + 5;
			tf.maxWidth = (bwid - tf.x) / tf.scaleX;
			var h = tf1.textHeight*tf1.scaleY + tf.textHeight*tf.scaleY;
			tf1.y = isize*0.5 - h*0.5;
			tf.y = tf1.y + tf1.textHeight*tf1.scaleY;
		}

		if( cb!=null ) {
			var i = new h2d.Interactive(bwid, isize, iwrapper);
			i.onRelease = function(e) {
				if( Game.ME.isDragging() ) {
					Game.ME.onMouseUp(e);
					return;
				}

				Assets.SBANK.click1(1);
				Game.ME.cancelClick();
				cb();
			}
			i.onPush = function(e) {
				//Game.ME.onMouseDown(e);
				//Game.ME.drag.startedOverUi = true;
			}
			i.onWheel = Game.ME.onWheel;

			createChildProcess(function(_) {
				if( itime%30==0 )
					Game.ME.uiFx.ping(root.x + icon.x*root.scaleX, root.y + icon.y*root.scaleY, "fxNovaBlue", root.scaleX);
			});
		}


		return tf1;
	}


	override function onDispose() {
		super.onDispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		iwrapper = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	override function onResize() {
		super.onResize();

		root.setScale( Main.getScale(50, 0.55) );

		root.x = w()*0.5 - root.width*0.5;
		root.y = h()*0.85 - root.height*0.5;
	}

	override function update() {
		super.update();
	}
}
