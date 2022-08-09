package ui;

import com.GameData;
import com.Protocol;
import com.*;
import Data;
import mt.deepnight.Lib;
import mt.MLib;
#if mBase
import mt.device.GameCenter;
#end

class Settings extends ui.Question {
	var section			: String;
	var singlePage		: Bool;

	public function new(?p:String) {
		super(true);

		autoClose = false;
		singlePage = p!=null;

		#if connected
		mt.device.EventTracker.view("ui.Settings");
		#end

		showSection(p);
	}


	override function onCancel() {
		if( section=="options" )
			saveSettings();

		if( section!="home" && !singlePage )
			showSection();
		else
			destroy();
	}

	function saveSettings() {
		if( !Game.ME.isVisitMode() ) {
			#if connected
			Game.ME.sendServerCommand( CS_Settings(Main.ME.settings) );
			Game.ME.flushNetworkBuffer();
			#else
			mt.deepnight.Lib.setCookie("cm2", "settings", Main.ME.settings);
			#end
			for(r in Game.ME.hotelRender.rooms)
				r.clearRoomButtons();
		}
	}


	function showSection(?id="home") {
		clearContent();
		section = id;

		switch( id ) {
			case "home" :
				// ADMIN / DEBUG features
				#if !connected
					addText(Lang.untranslated("Admin"));
					#if debug
					addButton(Lang.untranslated("Fill rooms with random decorations"), function() {
						Game.ME.runSolverCommand( DoCheat(CC_FillCustom) );
						for(r in shotel.rooms)
							Game.ME.hotelRender.attachRoom(r);
						destroy();
					});
					addButton(cast "Unlock all decorations", function() {
						var h = Game.ME.shotel;
						var n = 0;
						for(f in 0...Data.Bed.all.length)		h.addAndUnlockCustom( I_Bed(f), n );
						for(f in 0...Data.Bath.all.length)		h.addAndUnlockCustom( I_Bath(f), n );
						for(f in 0...Data.Ceil.all.length)		h.addAndUnlockCustom( I_Ceil(f), n );
						for(f in 0...Data.Furn.all.length)		h.addAndUnlockCustom( I_Furn(f), n );
						for(f in 0...Data.WallFurn.all.length)	h.addAndUnlockCustom( I_Wall(f), n );
						for(f in 0...Data.WallPaper.all.length)	h.addAndUnlockCustom( I_Texture(f), n );
						for(e in Data.WallColor.all)			h.addAndUnlockCustom( I_Color(e.id.toString()), n );
						new ui.Notification(cast "Done!", Const.TEXT_GOLD);
						destroy();
					});
					#end
					addButton(cast "Stats", function() {
						var q = new ui.Question();
						for(k in shotel.stats.keys())
							q.addText( Lang.untranslated(k+" => "+Game.ME.prettyNumber(shotel.getStat(k))), false );
						destroy();
					});
					addButton(cast "Hotel flags", function() {
						var q = new ui.Question();
						var showFlags : Void->Void = null;
						showFlags = function() {
							q.clearContent();
							var flags = [];
							for(k in shotel.flags.keys())
								flags.push(k);
							flags.sort(function(a,b) return Reflect.compare(a,b));
							for(k in flags) {
								q.addCheck(Lang.untranslated(k), shotel.flags.get(k), function(v) {
									shotel.flags.set(k,v);
								});
							}
							addSeparator();
							var v = "";
							q.addInput(v, function(s) v = s, function() {});
							q.addButton(Lang.untranslated("Add this flag"), function() {
								shotel.flags.set(v, true);
								new ui.Notification(Lang.untranslated("Added "+v));
								destroy();
							});
						}
						showFlags();
						destroy();
					});


					addButton(cast "Level list", function() {
						var q = new ui.Question();
						for(i in 1...25) {
							var all = [];

							// Clients
							for(k in Type.getEnumConstructs(ClientType)) {
								var e = Type.createEnum(ClientType, k);
								if( GameData.clientUnlocked(i, e) && !GameData.clientUnlocked(i-1, e) )
									all.push(k);
							}

							// Rooms
							for(k in Type.getEnumConstructs(RoomType)) {
								var e = Type.createEnum(RoomType, k);
								if( GameData.roomUnlocked(shotel, i, e) && !GameData.roomUnlocked(shotel, i-1, e) )
									all.push(k);
							}

							// Features
							for(k in GameData.FEATURES.keys())
								if( GameData.FEATURES.get(k)==i )
									all.push("F_"+k);


							q.addText(0, cast i+": "+all.join(", "), false);
						}
						destroy();
					});
					addButton(Lang.untranslated("Save/Load state"), showSection.bind("stateSlots"));
					addButton(Lang.untranslated("Exit to menu"), function() {
						page.GameTitle.show( M_ClickToPlay );
					});
					addSeparator();
				#end

				addButton(Lang.t._("Customize my hotel"), "iconPaint", showSection.bind("hotel"));
				addButton(Lang.t._("Settings"), "iconUse", showSection.bind("options"));
				addButton(Lang.t._("Language"), "iconUse", showSection.bind("lang"));
				addButton(Lang.t._("Hotel statistics"), showSection.bind("stats"));
				addSeparator();

				#if mBase
				if( GameCenter.isAvailable() )
					if( !GameCenter.isLogged() ) {
						// Game center login
						var icon = switch( mt.device.GameCenter.service() ) {
							case GooglePlayGames : "google_play";
							case AppleGameCenter : null;
						}
						addButton(cast mt.device.GameCenter.name(), icon, function() {
							mt.device.GameCenter.connect( function(ok) showSection() );
						});
					}
					else {
						// Game center achievements
						var icon = switch( mt.device.GameCenter.service() ) {
							case GooglePlayGames : "google_achievements";
							case AppleGameCenter : null;
						}
						addButton(cast mt.device.GameCenter.name(), icon, function() {
							destroy();
							mt.device.GameCenter.showAchievements();
						});
					}

				if( mt.device.User.isLogged() ){
					// Twinoid links
					addButton(Lang.t._("Community forum"), function() {
						new ui.WebView( Main.ME.hdata.forumUrl );
						destroy();
					});

					#if debug
					addButton(Lang.t._("Twinoid stats"), function() {
						new ui.WebView( "/stats" );
						destroy();
					});
					#end
				}
				else {
					// Login (general)
					addButton(Lang.t._("Sign in"), mt.device.User.login);
				}

				addSeparator();
				#end

				addButton( Lang.t._("Close") );
				#if mBase
				addText(Lang.untranslated("App version: "+AppVersion.get("../application.xml")+", Build: "+Const.BUILD+" ("+com.Protocol.DATA_VERSION+")"), Const.TEXT_GRAY, false, 0.4);
				#else
				addText(Lang.untranslated("Build version: "+Const.BUILD+" ("+com.Protocol.DATA_VERSION+")"), Const.TEXT_GRAY, false, 0.5);
				#end



			case "lang" :
				function setLang(id:String) {
					Lang.setLang(id);
					Main.ME.settings.forcedLang = id;
					saveSettings();
					Game.ME.reboot();
				}
				addButton(Lang.untranslated("English"), setLang.bind("en"));
				addButton(Lang.untranslated("Français"), setLang.bind("fr"));
				addButton(Lang.untranslated("Español"), setLang.bind("es"));
				addButton(Lang.untranslated("Deutsch"), setLang.bind("de"));
				addButton(Lang.untranslated("Português"), setLang.bind("pt"));
				addButton(Lang.untranslated("Italiano"), setLang.bind("it"));
				addCancel();

			case "options" :
				addText( Lang.t._("Graphic settings"), false );
				addCheck(Lang.t._("High quality graphics"), !Main.ME.settings.lowq, function(v) {
					Main.ME.settings.lowq = !v;
					Main.ME.applyQuality();
				});

				addSeparator();

				addText( Lang.t._("Sound settings"), false );
				addCheck(Lang.t._("Sounds"), Main.ME.settings.sfx, function(v) {
					Main.ME.settings.sfx = v;
				});
				addCheck(Lang.t._("Music"), Main.ME.settings.music, function(v) {
					Main.ME.settings.music = v;
				});

				addSeparator();

				addCheck(Lang.t._("Confirm gem expenses"), Main.ME.settings.confirmGems, function(v) {
					Main.ME.settings.confirmGems = v;
				});
				addCheck(Lang.t._("Show stocks"), Main.ME.settings.showStocks, function(v) {
					Main.ME.settings.showStocks = v;
					ui.Stocks.CURRENT.refresh();
				});
				addCheck(Lang.t._("Show stay durations"), Main.ME.settings.showStay, function(v) {
					Main.ME.settings.showStay = v;
				});
				addCheck(Lang.t._("Notifications"), !Main.ME.settings.hideNotifs, function(v) {
					Main.ME.settings.hideNotifs = !v;
				});

				addSeparator();

				// Disconnect
				if( mt.device.User.isLogged() ) {
					addButton(Lang.t._("Disconnect"), function() {
						var q = new ui.Question();
						q.addText( Lang.t._("You are logged as ::name::.", {name: mt.device.User.getName()}) );
						q.addButton(Lang.t._("Disconnect? Really?"), function() {
							new ui.Loading( mt.device.User.logout );
						});
						q.addCancel();
						q.onCancel = function() {
							new ui.Settings();
						}
					});
				}
				addButton(Lang.t._("Confirm"), function() {
					saveSettings();
					onCancel();
				});


			case "stats" :
				addValue( Lang.t._("Hosted clients"), shotel.getStat("client"), false );
				addValue( Lang.t._("Visits from friends"), shotel.getStat("visit"), false );
				addValue( Lang.t._("Clients totally satisfied"), shotel.getStat("maxed"), false );
				addValue( Lang.t._("VIP satisfied"), shotel.getStat("vip"), false );
				addValue( Lang.t._("Clients killed"), shotel.getStat("kill"), false );
				addValue( Lang.t._("Clients stolen"), shotel.getStat("theft"), false );
				addValue( Lang.t._("Treasures found"), shotel.getStat("treas"), false );
				addValue( Lang.t._("Love given to clients"), shotel.getStat("love"), false );
				addValue( Lang.t._("Sodas served"), shotel.getStat("beer"), false );
				addValue( Lang.t._("Laundries"), shotel.getStat("laundry"), false );
				addValue( Lang.t._("Soap used"), shotel.getStat("soap"), false );
				addValue( Lang.t._("Paper used"), shotel.getStat("paper"), false );
				addValue( Lang.t._("Rooms boosted"), shotel.getStat("boost"), false );
				if( Main.ME.isAdmin() ) {
					addSeparator();
					var d = com.GameData.getClientStayDuration( C_Liker, shotel );
					var duration = Lib.prettyFloat(d/DateTools.hours(1))+"h ("+Lib.prettyFloat(d/DateTools.minutes(1), 1)+"min)";
					addText(Lang.untranslated("Stay duration: "+duration), 0xffffff, false);

					var t = shotel.getTask( InternalSetFlag("bossLock",false) );
					if( t!=null )
						addText(Lang.untranslated("Inspector cooldown: "+Game.ME.prettyTime(t.end)), 0xffffff, false);

					addValue( Lang.untranslated("Gold incomes"), shotel.getStat("income"), false );
					addValue( Lang.untranslated("Client incomes"), shotel.getStat("cincome"), false );
					if( shotel.getStat("client")>0 )
						addValue( Lang.untranslated("Client avg incomes"), MLib.round(shotel.getStat("cincome")/shotel.getStat("client")), false );
					addValue( Lang.untranslated("Gems used"), shotel.getStat("gem"), false );
					addValue( Lang.untranslated("Gems used on booster"), shotel.getStat("brefill"), false );
					addValue( Lang.untranslated("Items bought"), shotel.getStat("buyItem"), false );
					addValue( Lang.untranslated("Decoration bought"), shotel.getStat("buyCust"), false );
					addValue( Lang.untranslated("Clients skipped"), shotel.getStat("cskip"), false );
					addValue( Lang.untranslated("Custom buy failures"), shotel.getStat("custFail"), false );
				}

				addButton(Lang.t._("Back"), onCancel);



			#if !connected
			case "stateSlots" :
				addText( Lang.untranslated("Save:") );
				for(i in 0...3) {
					addButton(Lang.untranslated("Save #"+i), function() {
						Lib.setCookie("cm2", "slot"+i, haxe.Serializer.run(shotel.getState()));
						Lib.setCookie("cm2", "slotv"+i, Protocol.DATA_VERSION);
						new ui.Notification( Lang.untranslated("Done on slot "+i) );
						showSection(id);
					});
				}

				addSeparator();
				for(i in 0...3) {
					var c = Lib.getCookie("cm2", "slot"+i);
					addButton(Lang.untranslated("Load #"+i), c!=null, function() {
						var s : String = Lib.getCookie("cm2", "slot"+i);
						var v = Lib.getCookie("cm2", "slotv"+i);
						try {
							var s : HotelState = haxe.Unserializer.run(s);
							Lib.setCookie("cm2","version",v);
							Game.ME.resetSave(false, true, s);
						} catch(e:Dynamic) {
							new ui.Notification(Lang.untranslated("Failed!"), 0xFF0000);
						}
					});
				}

				addSeparator();
				for(i in 0...3) {
					addButton(Lang.untranslated("Delete #"+i), function() {
						Lib.removeCookie("cm2", "slot"+i);
						Lib.removeCookie("cm2", "slotv"+i);
						showSection(id);
					});
				}

				addSeparator();
				addButton(Lang.t._("Reset"), function() {
					Game.ME.resetSave(true,true);
				});

				addSeparator();
				addButton(Lang.t._("Back"), onCancel);
			#end


			case "hotel" :
				addText(Lang.t._("Enter your hotel name:"), false);
				var name = shotel.name;

				function submit() {
					shotel.name = com.SHotel.cleanUpName(name);
					#if connected
					Game.ME.sendServerCommand( CS_HotelOptions({ name:shotel.name }) );
					#end
					Game.ME.hotelRender.renderSurroundings();
					onCancel();
				}

				addInput( name, function(s) name = s);
				addText(Lang.t._("Only A-Z characters, numbers or spaces are allowed."), Const.TEXT_GRAY, true, 0.5);
				addButton(Lang.t._("Confirm"), submit);

			default :
				addText( Lang.untranslated("Not available yet!") );
				addSeparator();
				addButton(Lang.t._("Back"), onCancel);
		}
	}


	//function onStats() {
		//var q = new ui.Question();
		//q.addCenteredSprite( Assets.tiles.getH2dBitmap("iconUse") );
		//q.addText(Lang.t._("Soon!"));
		//q.addCancel(Lang.t._("Close"));
	//}
}
