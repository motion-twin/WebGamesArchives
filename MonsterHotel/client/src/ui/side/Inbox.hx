package ui.side;

import Data;
import mt.MLib;
import mt.data.GetText;
import com.Protocol;
import com.GameData;
import h2d.SpriteBatch;
import com.*;

class Inbox extends ui.SideMenu {
	public static var CURRENT : Inbox;

	static function getHardCodedMessages(shotel:SHotel) {
		var all : Array<{id:String, exp:String, title:LocaleString, desc:LocaleString}> = [
			//{ id:"update1.3", exp:"2015-12-31 00:00:00", title:Lang.t._("Game update 1.3 is out!"), desc:Lang.t._("Many bugfixes!") },
		];
		var now = Game.ME.serverTime;
		return all.filter( function(m) {
			return !shotel.hasFlag(m.id) && now < Date.fromString(m.exp).getTime();
		}) ;
	}


	var nbButtons		: Int;

	public function new() {
		CURRENT = this;

		super();

		#if connected
		mt.device.EventTracker.view("ui.Inbox");
		#end

		name = "Inbox";
		nbButtons = 0;
		bhei = 80;

		onResize();
	}

	public static function getCount() {
		var shotel = Game.ME.shotel;
		var n = 0;
		#if connected
			n+=Main.ME.hdata.inboxCount;
			#if( debug || android )
			if( !shotel.hasFlag("sp_android") ) n++;
			#end
			#if( debug || ios )
			if( !shotel.hasFlag("sp_ios") ) n++;
			#end
		#end

		var evts = DataTools.getEvents(Game.ME.serverTime);
		for(e in evts)
			if( !shotel.hasDoneEvent(e.id) )
				n++;

		for( m in getHardCodedMessages(shotel) )
			n++;

		return n;
	}

	function replaceButton(btId:String, label:LocaleString, iconId:String) {
		var b = getButton(btId);
		if( b!=null ) {
			var t = b.getText("label");
			t.text = label;
			t.textColor = 0xB3FF00;
			var icon = b.getElement("icon");
			icon.tile = Assets.tiles.getTile(iconId);
			icon.tile.setCenterRatio(0, 0.5);
			icon.setScale( 60/icon.tile.width );
			b.disableRollover();
		}
	}

	public function addButton(id:String, label:LocaleString, ?iconId:String, ?col=-1, ?cb:Void->Void) {
		nbButtons++;

		var b = createButton(cb,id);
		b.enableRollover();

		var icon : BatchElement = null;
		if( iconId!=null ) {
			icon = b.addElement("icon", iconId);
			icon.tile.setCenterRatio(0, 0.5);
			icon.setScale( 60/icon.tile.width );
			icon.x = 20;
			icon.y = bhei*0.5;
		}

		// Label
		var tf = b.addText("label", label, 24);
		tf.text = Lang.addNbsps( label );
		tf.textColor = col==-1 ? 0xFFFFFF : col;
		if( label.length>22 )
			tf.scale(0.7);
		tf.x = icon==null ? 20 : icon.x + icon.width + 10;
		tf.maxWidth = (wid/cols-tf.x*2) / tf.scaleX;
		tf.y = Std.int( bhei*0.5 - tf.textHeight*tf.scaleY*0.5 );

		b.position();

		return b;
	}


	function addSpecialButton(icon:String, label:LocaleString, ?fontSize=21, cb:Void->Void) {
		nbButtons++;
		var col = Const.TEXT_GOLD;

		var b = createButton(function() {
			Assets.SBANK.click1(1);
			if( !Game.ME.tuto.commandLocked("side") )
				cb();
		}, "s_"+label);
		b.enableRollover();
		b.autoHide = false;

		var iwid = 60;

		var p = 4;
		var bg = b.addElement("bg", "white");
		bg.color = h3d.Vector.fromColor(alpha(0x8A2D00));
		bg.y = p;
		bg.width = wid;
		bg.height = bhei-p*2;
		var e = b.addElement("top", "popUpTop");
		e.y = p;
		e.width = wid;
		var e = b.addElement("bottom", "popUpBottom");
		e.width = wid;
		e.y = bhei-e.height-p;
		createChildProcess(function(p) {
			if( destroyed || b.destroyed )
				p.destroy();
			else if( isOpen ) {
				bg.alpha = 0.7 + 0.3*Math.cos(ftime*0.2);
				Game.ME.uiFx.shineSquare("yellowBigDot", wrapper.x, wrapper.y + b.getY()*wrapper.scaleY, wid*wrapper.scaleX, bhei*wrapper.scaleY, wrapper.scaleX);
			}
		}, true);

		var iconBg = b.addElement("iconBg", "portraitCircleHeat");
		iconBg.setScale( MLib.fmin( 1.5*iwid/iconBg.width, 1.5*iwid/iconBg.height) );
		iconBg.tile.setCenterRatio(0.5,0.5);
		iconBg.x = 10 + iwid*0.5;
		iconBg.y = bhei*0.5;

		var icon = b.addElement("icon", icon);
		icon.setScale( MLib.fmin( 0.8*iwid/icon.width, 0.8*iwid/icon.height) );
		icon.tile.setCenterRatio(0.5,0.5);
		icon.x = 10 + iwid*0.5;
		icon.y = bhei*0.5;

		var th = 0.;

		// Label
		var label = b.addText("name", Lang.addNbsps(label), fontSize);
		label.x = icon.x + iwid*0.75 + 10;
		label.maxWidth = (wid - label.x - 10 ) / label.scaleX;
		label.textColor = col;
		th += label.textHeight*label.scaleY;

		label.y += bhei*0.5 - th*0.5;

		b.position();
	}



	// Request accepted
	function onAcceptDone(result:Array<Dynamic>) {
		var result : Array<FriendRequestResult> = cast result;
		if( result==null || !Std.is(result, Array) || destroyed || !isOpen )
			return;

		// Apply result locally (can be delayed if the game is already doing something)
		var gems = 0;
		var gold = 0;
		for( rs in result )
			switch( rs.type ) {
				case HFR_SendLove, HFR_ReturnLove, HFR_AskLove : // deprecated

				case HFR_ComeBack : // not used. One day maybe?

				case HFR_SendGem : gems+=GameData.SOCIAL_GEMS;

				case HFR_SendGold : gold+=GameData.SOCIAL_GOLD;
			}

		Game.ME.runAfterPlayback( function() {
			if( gems>0 ) {
				Game.ME.shotel.gems += gems;
				new ui.Notification( Lang.t.untranslated("+"+gems), Const.TEXT_GEM, "moneyGem");
				ui.MainStatus.CURRENT.shakeGem();
				Assets.SBANK.gem(1);
			}
			if( gold>0 ) {
				Game.ME.shotel.money += gold;
				new ui.Notification( Lang.t.untranslated("+"+gold), Const.TEXT_GOLD, "moneyGold");
				ui.MainStatus.CURRENT.shakeGold();
				Assets.SBANK.gold(1);
			}
			ui.MainStatus.CURRENT.updateInfos();
		});
	}

	// Request message
	public static function getReqData(reqInt:Int) : { message:String, data:Dynamic } {
		return switch( Type.createEnumIndex(HotelFriendRequest,reqInt) ) {
			case HFR_SendGem :
				{ message: Lang.t._("I offered you a GEM!"), data: null }

			case HFR_SendLove, HFR_ReturnLove :
				{ message: Lang.t._("Here is some love for you :)"), data: null }

			case HFR_SendGold :
				{ message: Lang.t._("Here is ::n:: gold for you :)", {n:GameData.SOCIAL_GOLD}), data: null }

			case HFR_AskLove :
				{ message: Lang.t._("Could you send me some love?"), data: null }

			case HFR_ComeBack :
				{ message: Lang.t._("Come back to Monster Hotel and get free GEMS :)"), data: null }
		}
	}

	function sendAccept(ids:Array<Int>) {
		if( Game.ME.isVisitMode() )
			return;

		for(id in ids)
			replaceButton("req_"+id, Lang.t._("Accepted!"), "check");
		#if connected
		//#if debug return; #end // hack
		mt.device.FriendRequest.accept( ids, getReqData, onAcceptDone );
		#end
	}

	override function close() {
		super.close();
		invalidate();
	}

	override function clearContent() {
		super.clearContent();
		nbButtons = 0;
	}

	override function refresh() {
		super.refresh();

		clearContent();
		addTitle( Lang.t._("Your inbox") );
		addText( Lang.t._("Looking for new messages..."), Const.TEXT_GRAY );

		if( Game.ME.isVisitMode() )
			return;

		#if connected
		Game.ME.sendMiscCommand( MC_GetMessages );
		#end
	}

	public function onHotelMessagesLoaded() {
		if( !isOpen || Game.ME.isVisitMode() )
			return;


		clearContent();
		addTitle( Lang.t._("Your inbox") );
		addText( Lang.t._("Loading..."), Const.TEXT_GRAY );

		#if connected
		mt.device.FriendRequest.list(function(requests){
			if( !isOpen || destroyed )
				return;

			if( requests==null ) {
				new ui.Notification(Lang.t._("Inbox loading failed!"), 0xFF0000);
				close();
				return;
			}

			ui.HudMenu.CURRENT.setCounter("inbox", 0);
			Game.ME.hdata.inboxCount = 0;
			clearContent();

			addTitle( Lang.t._("Your inbox") );

			// Special mobile reward
			#if( debug || android )
			if( !shotel.hasFlag("sp_android") ) {
				addSpecialButton("gift", Lang.t._("Thank you for installing Monster Hotel on this device!"), function() {
					Game.ME.runSolverCommand( DoGetSpecialReward("android") );
				});
			}
			#end

			#if( debug || ios )
			if( !shotel.hasFlag("sp_ios") ) {
				addSpecialButton("gift", Lang.t._("Thank you for installing Monster Hotel on this device!"), function() {
					Game.ME.runSolverCommand( DoGetSpecialReward("ios") );
				});
			}
			#end

			// Hard-coded messages
			for( m in getHardCodedMessages(shotel) )
				addHardCodedMessage(m.id, m.title, m.desc);

			// Events
			var events = DataTools.getEvents( Date.now().getTime() );
			var hasEvent = false;
			for(e in events)
				if( !shotel.hasDoneEvent(e.id) ) {
					var inf = Lang.getEvent(e.id);
					var icon = e.iconId!=null && Assets.tiles.exists(e.iconId) ? e.iconId : "gift";
					addSpecialButton(icon, inf.title, 26, function() {
						Game.ME.runSolverCommand( DoGetEventReward(e.id.toString()) );
						close();
					});
				}

			// Stack base hotel messages
			var allMsgStacked : Array<Array<HotelMessage>> = [];
			var hotelMessages = shotel.messages.copy();
			var i = 0;
			while( i<hotelMessages.length ) {
				var m = hotelMessages[i];
				var j = 0;
				var stack = [];
				while( j<hotelMessages.length ) {
					var m2 = hotelMessages[j];
					if( m.getIndex()==m2.getIndex() ) {
						stack.push(m2);
						hotelMessages.remove(m2);
					}
					else
						j++;
				}
				allMsgStacked.push(stack);
				i++;
			}

			// Friend requests
			for( e in requests )
				allMsgStacked.push([ M_FriendRequest(e.i, e.f, e.t, e.d) ]);

			// Mass accept
			if( requests.length + hotelMessages.length > 0 ) {
				addButton("acceptAll", Lang.t._("Accept all rewards"), "clientLuggage", function() {
					var reqIds = [];
					for(stack in allMsgStacked) {
						var e = stack[0];
						switch( e ) {
							case M_Visit(u) : onActivateHotelMessages("visit", stack);
							case M_FriendRequest(id, _) : reqIds.push(id);
						}
					}

					// Friend requests
					if( reqIds.length>0 )
						sendAccept(reqIds);

					invalidate();
				});
			}

			// Display
			for(stack in allMsgStacked) {
				var e = stack[0];
				switch( e ) {
					case M_Visit(u) :
						if( stack.length==1 )
							addButton(
								"visit", Lang.t._("::name:: visited your hotel", {name:u}),
								"iconLeave", Const.TEXT_GRAY,
								onActivateHotelMessages.bind("visit", stack)
							);
						else {
							var m : Map<String,Bool>= new Map();
							for(e in stack)
								switch( e ) {
									case M_Visit(n) : m.set(n, true);
									default :
								}
							var a = [];
							for(n in m.keys())
								a.push(n);
							var names =
								a.length>3 ? a.slice(0,3).join(", ")+"..." :
								a.length>1 ? a.slice(0,a.length-1).join(", ") + " "+Lang.t._("and")+" " + a[a.length-1] :
								a[0];

							addButton(
								"visit", Lang.t._("Your hotel has received ::n:: new visits (from ::names::)", {n:stack.length, names:names}),
								"iconLeave", Const.TEXT_GRAY,
								onActivateHotelMessages.bind("visit", stack)
							);
						}

					#if !connected
					case M_FriendRequest(_) :
						addButton("test", Lang.untranslated("FriendRequest?"), Const.TEXT_BAD, function() {});

					#else

					case M_FriendRequest(id, f, t, d) :
						var type = Type.createEnumIndex(HotelFriendRequest, t);
						var btId = "req_"+id;
						switch( type ) {
							case HFR_AskLove :
								addButton( btId, Lang.t._("::name:: would like some love.", {name:f.name}), "iconLoveMail", sendAccept.bind([id]) );

							case HFR_ComeBack :

							case HFR_SendLove, HFR_ReturnLove :
								addButton( btId, Lang.t._("::name:: gave you love!", {name:f.name}), "moneyLove", Const.TEXT_LOVE, sendAccept.bind([id]) );

							case HFR_SendGem :
								addButton( btId, Lang.t._("::name:: offered you a GEM!", {name:f.name}), "moneyGem", Const.TEXT_GEM, sendAccept.bind([id]) );

							case HFR_SendGold :
								addButton( btId, Lang.t._("::name:: offered you ::n:: GOLD!", {name:f.name, n:GameData.SOCIAL_GOLD}), "moneyGold", Const.TEXT_GOLD, sendAccept.bind([id]) );
						}
					#end
				}
			}

			// Empty
			if( nbButtons==0 )
				addText(Lang.t._("Your don't have any unread message."));

		});
		#end
	}

	function addHardCodedMessage(id:String, title:LocaleString, desc:LocaleString) {
		addSpecialButton("itemRadio", title, function() {
			var q = new ui.Question(false);
			q.addTitle(title);
			for(line in desc.split("\n"))
				q.addText( Lang.untranslated(line) );
			q.addButton( Lang.t._("Mark as read"), "dailyCheck", function() {
				Game.ME.runSolverCommand( DoHardCodedMessage(id) );
				invalidate();
			} );
			q.addButton( Lang.t._("Keep it for later") );
		});
	}

	function onActivateHotelMessages(btId:String, a:Array<HotelMessage>) {
		replaceButton(btId, Lang.t._("Marked as read."), "check");
		//#if debug return; #end // hack
		Game.ME.runSolverCommand( DoMessagesActions(a) );
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
