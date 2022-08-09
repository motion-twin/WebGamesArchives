package ui;

import Data;
import mt.MLib;
import com.Protocol;
import com.GameData;
import h2d.SpriteBatch;

class HudMenu extends H2dProcess {
	public static var CURRENT : HudMenu;

	var sb					: SpriteBatch;
	var tsb					: SpriteBatch;

	var shotel(get,null)	: com.SHotel;
	var buttons				: Array<{ id:String, wid:Float, g:BatchGroup, countBg:Null<h2d.BatchElement>, countTf:Null<h2d.TextBatchElement> }>;
	public var bsize		: Int;
	var highlight			: h2d.Bitmap;

	public function new() {
		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		CURRENT = this;
		name = "HudMenu";
		root.name = name;
		buttons = [];
		bsize = 90;

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;
		sb.name = name+".sb";

		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, root);
		tsb.filter = true;
		tsb.name = name+".tsb";

		highlight = Assets.tiles.getH2dBitmap("fxNovaYellow", 0.5,0.5,true, root);
		highlight.blendMode = Add;
		highlight.name = name+".highlight";

		refresh();
		onResize();
	}

	public function refresh() {
		for(b in buttons)
			b.g.dispose();
		buttons = [];

		setHighlight();

		// Inbox
		if( !Game.ME.isVisitMode() ) {
			if( shotel.featureUnlocked("inbox") ) {
				addButton("inbox", "iconMailSmall", bsize*0.75, function() {
					if( Game.ME.tuto.isRunning() && !Game.ME.tuto.isRunning("inbox") )
						Game.ME.followTheInstructions("inbox");
					else if( ui.side.Inbox.CURRENT.toggle() )
						setHighlight("inbox");
				});
				setCounter("inbox", ui.side.Inbox.getCount());
			}
			else
				addOffButton("inbox", "iconMailSmall", bsize*0.75);
		}

		// Contacts
		if( !Game.ME.isVisitFromUrl() ) {
			if( shotel.featureUnlocked("love") )
				addButton("contacts", "iconFriend", bsize*0.75, function() {
					#if !connected
					if( !Main.ME.isLogged() )
						return;
					#end

					if( ui.side.Contacts.CURRENT.toggle() )
						setHighlight("contacts");
				});
			else
				addOffButton("contacts", "iconFriend", bsize*0.75);
		}

		if( !Game.ME.isVisitMode() ) {
			// Premium shop
			if( shotel.featureUnlocked("premium") && shotel.featureUnlocked("gems") ) {
				addButton("premium", "moneyGem", bsize, function() {
					if( ui.side.PremiumShop.CURRENT.toggle() )
						setHighlight("premium");
				});
			}
			else
				addOffButton("premium", "moneyGem", bsize);

			// Rooms
			if( shotel.featureUnlocked("build") ) {
				addButton("build", "iconBuild", bsize, function() {
					if( ui.side.BuildMenu.CURRENT.toggle() )
						setHighlight("build");
				});
				//var n = 0;
				//var all = Type.getEnumConstructs(RoomType).map( function(k) return Type.createEnum(RoomType, k) );
				//for( t in all )
					//if( !shotel.hasRoomType(t,true) && GameData.roomUnlocked(shotel.level,t) && GameData.getRoomCost(t, Game.ME.shotel.countRooms(t))>=0 )
						//n++;
				//setCounter("build", n);
			}
			else
				addOffButton("build", "iconBuild", bsize);


			// Items
			if( shotel.featureUnlocked("items") )
				addButton("items", "iconInv", bsize, function() {
					if( ui.side.ItemMenu.CURRENT.toggle() )
						setHighlight("items");
				});
			else
				addOffButton("items", "iconInv", bsize);

			// Customize
			if( shotel.featureUnlocked("custom") )
				addButton("custom", "iconPaint", bsize, function() {
					if( ui.side.CustomizeMenu.CURRENT.toggle() )
						setHighlight("custom");
				});
			else
				addOffButton("custom", "iconPaint", bsize);

			//#if debug
			//addButton("rate", "iconRecycle", 0.75*bsize, function() new ui.Rate());
			//#end

			#if( !connected && !autoSave )
			// Save
			addButton("saveCookie", "iconRecycle", 0.75*bsize, function() {
				Game.ME.saveCookieState();
				new ui.Notification(cast "Game saved.");
			});

			// Reset
			addButton("destroy", "iconDestroy", 0.75*bsize, function() {
				Game.ME.resetSave(true, true);
			});
			#end

			// Test button
			//#if( debug && !trailer )
			//addButton("test", "itemCheese", 0.75*bsize, function() {
				//new ui.HudMenuTip("quest_all", "test blabla bla", true);
				//ui.side.BuildMenu.CURRENT.focus(R_Bedroom);
			//});
			//#end
		}

		#if connected
		if( Game.ME.isVisitMode() ) {
			addButton("stats", "star", 0.75*bsize, function() {
				if( !destroyed )
					new ui.Settings("stats");
			});
			if( !Game.ME.isVisitFromUrl() ){
				addButton("exit", "iconQuit", bsize, function() {
					if( !destroyed && !cd.hasSet("exitLock", 99999) ) {
						Assets.SBANK.click1(1);
						new ui.Loading( Game.ME.sendMiscCommand.bind( MC_EndVisit ) );
					}
				});
			#if mBase
			}else{
				addButton("exit", "iconQuit", bsize, function() {
					if( !cd.hasSet("exitLock", 99999) ) {
						App.current.dispatch("/");
					}
				});
			#end
			}
		}
		#end

		onResize();
	}

	//public function updateLunchBoxCounter() {
		//setCounter("quests", shotel.countInventoryItem(I_LunchBoxAll) + shotel.countInventoryItem(I_LunchBoxCusto));
	//}

	public function setHighlight(?id:String) {
		if( destroyed )
			return;

		var b = getButton(id);
		if( id==null || b==null )
			highlight.visible = false;
		else {
			highlight.visible = true;
			highlight.x = b.g.x + b.wid*0.5;
			highlight.y = b.g.y + b.wid*0.5 + 2;
			highlight.width = b.wid+10;
			highlight.height = b.wid+10;
		}
	}

	public function setCounter(id:String, n:Int) {
		var b = getButton(id);
		if( b == null )
			return;
		if( b.countBg!=null ) {
			b.g.remove(b.countBg);
			b.countBg = null;
			b.g.remove(b.countTf);
			b.countTf = null;
		}

		if( n>0 ) {
			var bg = Assets.tiles.addBatchElement(sb, "portraitCircleHeat",0, 0.5, 0.5);
			var tf = Assets.createBatchText(tsb, Assets.fontHuge, 60, 0xFFFFFF, Std.string(n));
			bg.setScale(0.01);
			bg.x = 10;
			bg.y = b.wid*0.5;

			tf.visible = false;
			bg.visible = false;

			b.g.add(bg);
			b.countBg = bg;
			b.g.add(tf);
			b.countTf = tf;
		}
	}

	function getButton(id:String) {
		if( !destroyed )
			for(b in buttons)
				if( b.id==id )
					return b;

		return null;
	}

	public function getButtonCoord(id:String) {
		var b = getButton(id);
		if( b==null )
			return null;
		else
			return {
				x	: root.x + (b.g.x + b.wid*0.5)*root.scaleX,
				y	: root.y + (b.g.y + b.wid*0.5)*root.scaleY,
			}
	}

	inline function get_shotel() return Game.ME.shotel;

	override function onDispose() {
		super.onDispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		for(b in buttons)
			b.g.dispose();
		buttons = null;
		highlight = null;

		if( CURRENT==this )
			CURRENT = null;
	}



	public function addOffButton(id:String, iconId:String, w:Float) {
		var g = new BatchGroup(sb,tsb);
		var p = 20;
		w = bsize*0.7;
		//w*=0.8;

		var base = Assets.tiles.hbe_get(sb, "whiteCircle",0, 0.5,0.5);
		base.constraintSize(w*0.95);
		base.colorize(0x1B1F34, 1, 1);
		base.setPos(w*0.5, w*0.5);
		base.alpha = 0.9;
		g.add(base);

		var bg = Assets.tiles.hbe_get(sb, "circlet",0, 0.5,0.5);
		bg.constraintSize(w);
		bg.setPos(w*0.5, w*0.5);
		bg.alpha = 1;
		g.add(bg);

		var icon = Assets.tiles.hbe_get(sb, iconId,0, 0.5,0.5);
		icon.constraintSize(w*0.55);
		icon.x = Std.int(w*0.5);
		icon.y = Std.int(w*0.5);
		icon.alpha = 0.3;
		g.add(icon);

		var i = new h2d.Interactive(w+10,w+10, root);
		i.setPos(-5,-5);
		i.onClick = function(_) {
			Assets.SBANK.click1(0.5);
			if( !cd.hasSet("locked"+id, Const.seconds(2)) )
				new ui.HudMenuTip(id, Lang.t._("This option hasn't been unlocked yet!"));
		}
		g.add(i);

		buttons.push({ id:id, wid:w, g:g, countBg:null, countTf:null });
		onResize();
	}


	public function addButton(id:String, iconId:String, w:Float, cb:Void->Void) {
		var g = new BatchGroup(sb,tsb);
		var p = 20;

		var bg = Assets.tiles.addBatchElement(sb, "btnBlankBig",1, 0.5,0.5);
		var scale = w/bg.width;
		bg.setScale(scale);
		bg.setPos(w*0.5, w*0.5);
		g.add(bg);

		var icon = Assets.tiles.hbe_get(sb, iconId,0, 0.5,0.5);
		icon.constraintSize(w*0.7);
		icon.x = Std.int(w*0.5);
		icon.y = Std.int(w*0.5) - 4;
		g.add(icon);

		var i = new h2d.Interactive(w+10,w+10, root);
		i.setPos(-5,-5);
		i.onPush = Game.ME.onMouseDown;
		#if responsive
		var over = true;
		#else
		var over = false;
		i.onOver = function(_) {
			over = true;
			bg.color = h3d.Vector.fromColor(alpha(0xFFFF80), 1.1);
		}
		i.onOut = function(_) {
			over = false;
			bg.color.set(1,1,1,1);
		}
		#end
		var cancel = false;
		i.onClick = function(_) {
			if( !cancel )
				cb();
			cancel = false;
		}
		i.onPush = function(_) {
			cancel = false;
		}
		i.onRelease = function(e:hxd.Event) {
			if( !Game.ME.isDragging() ) {
				if( Game.ME.tuto.commandLocked("click") || Game.ME.tuto.commandLocked("side") ) {
					cancel = true;
					Game.ME.followTheInstructions("hudMenu");
					Game.ME.onMouseUp(e);
				}
				else
					Game.ME.cancelClick();
			}
			else {
				cancel = true;
				Game.ME.onMouseUp(e);
			}
		}
		i.onWheel = Game.ME.onWheel;
		g.add(i);

		buttons.push({ id:id, wid:w, g:g, countBg:null, countTf:null });
		onResize();
	}



	function updatePositions() {
		var y = 0.;
		var max = 0.;
		for(e in buttons)
			max = MLib.fmax(e.wid, max);

		var m = hcm()>=8 ? 15 : 3;
		for(e in buttons) {
			e.g.x = max-e.wid;
			e.g.y = y;
			y+=e.wid + m;
		}
	}

	override function onResize() {
		super.onResize();

		#if standalone
		root.setScale( MLib.fmin(1, (h()-root.y)/(root.height/root.scaleY)) );
		#else
		root.setScale( Main.getScale(bsize, isVerySmallScreen() ? 0.68 : isSmallScreen() ? 0.8 : 1) );
		#end
		updatePositions();
		updateCoords();
	}

	public function isVerySmallScreen() return hcm()<=5.5;
	public function isSmallScreen() return hcm()<=6.5;

	public function updateCoords() {
		root.x = w() - bsize*root.scaleX - ui.SideMenu.getCurrentWidth();

		var minY = ui.CornerMenu.CURRENT.getBottomY() + 10;
		root.y = MLib.fmax( minY, h()*0.5 - buttons.length*bsize*root.scaleY*0.5 );

		ui.HudMenuTip.updateCoords();
	}

	override function update() {
		super.update();

		for(b in buttons)
			if( b.countBg!=null ) {
				b.countBg.setScale( b.countBg.scaleX + ((0.6+Math.sin(ftime*0.2)*0.15) - b.countBg.scaleX) * 0.25 );
				b.countTf.setScale(b.countBg.scaleX);
				//b.countBg.x = 20-Math.cos(time*0.1)*3;
				b.countTf.x = b.countBg.x - b.countTf.textWidth*b.countTf.scaleX*0.5;
				b.countTf.y = b.countBg.y - b.countTf.textHeight*b.countTf.scaleY*0.5;
				b.countBg.visible = true;
				b.countTf.visible = true;
				//if( time%30==0 ) {
					//var pt = getButtonCoord(b.id);
					//Game.ME.uiFx.ping(pt.x, pt.y, "fxNovaYellow", 0.5, 2);
				//}
			}

		if( ui.SideMenu.allClosed() )
			setHighlight();

		updateCoords();
	}
}
