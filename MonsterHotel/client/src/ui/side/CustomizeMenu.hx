package ui.side;

import mt.MLib;
import com.Protocol;
import com.GameData;
import com.*;
import mt.data.GetText;
import h2d.SpriteBatch;
import Data;

class CustomizeMenu extends ui.SideMenu {
	public static var CURRENT : CustomizeMenu;
	public var cat			: Null<Item>;
	var csb					: h2d.SpriteBatch;
	var frontSb				: h2d.SpriteBatch;

	public function new() {
		CURRENT = this;

		super();

		name = "CustomizeMenu";
		csb = new h2d.SpriteBatch(Assets.custo0.tile, wrapper);
		csb.filter = true;
		csb.name = name+".csb";

		frontSb = new h2d.SpriteBatch(Assets.tiles.tile, wrapper);
		frontSb.filter = true;
		frontSb.name = name+".frontSb";

		cat = null;
		bhei = 80;

		refresh();
		onResize();
	}

	override public function onBack() {
		if( cat!=null )
			openCategory(null);
		else
			super.onBack();
	}

	override function clearContent() {
		super.clearContent();

		csb.removeAllElements();
		frontSb.removeAllElements();

		csb.disposeAllChildren();
		frontSb.removeAllChildren();
	}

	//override public function toggle() {
		//if( isOpen && cat!=null )
			//openCategory(null);
		//else
			//super.toggle();
//
		//return isOpen;
	//}


	override function refresh() {
		super.refresh();

		clearContent();

		if( cat==null ) {
			addTitle(Lang.t._("Decorations"));

			if( !Game.ME.tuto.isRunning() ) {
				addButton("moneyGem", Lang.t._("Get a random item!"), Lang.t._("You always get NEW decorations!"), Const.TEXT_GEM, function() {
					var q = new ui.Question();
					q.addText( Lang.t._("You are guaranteed to obtain NEW items every time : you cannot get a decoration you already have :)") );
					q.addButton(Lang.t._("Get a random item (::n:: GEMS)",{n:GameData.RANDOM_CUSTOM_COST_ANY}), "moneyGem", function() {
						Game.ME.runSolverCommand( DoBuyRandomCustom );
					});
					q.addCancel();
				});
			}


			addCategory(I_Color(null), Lang.t._("Wall colors"));
			addCategory(I_Texture(-1), Lang.t._("Wallpapers"), "wallPaper");
			addCategory(I_Bath(-1), Lang.t._("Bathrooms"));
			addCategory(I_Bed(-1), Lang.t._("Beds"), "bed");
			addCategory(I_Ceil(-1), Lang.t._("Ceilings"));
			addCategory(I_Furn(-1), Lang.t._("Middle furnitures"));
			addCategory(I_Wall(-1), Lang.t._("Wall elements"));
		}
		else {
			addBack();

			var avail = 0;
			var locked = 0;
			var all = [];
			var map = new Map();
			for(i in shotel.customs)
				if( isInCategory(i) && !map.exists(i) ) {
					map.set(i,true);
					if( shotel.hasInventoryItem(i) )
						avail++;
					else
						locked++;
					all.push(i);
				}
			all.reverse();

			if( avail>0 )
				addText(Lang.t._("Drag a decoration item on your hotel to install it."), Const.TEXT_GRAY);

			for( i in all )
				switch( i ) {
					case I_Color(id) :
						if( DataTools.getWallColor(id)!=null )
							addItem(i);

					case I_Texture(f) :
						if( DataTools.getWallTexture(f)!=null )
							addItem(i);

					default :
						addItem(i);
				}

			// Fillers
			var max = switch( cat ) {
				case I_Bath(_) : Data.Bath.all.length;
				case I_Bed(_) : Data.Bed.all.length;
				case I_Color(_) : Data.WallColor.all.length-1;
				case I_Ceil(_) : Data.Ceil.all.length;
				case I_Furn(_) : Data.Furn.all.length;
				case I_Texture(_) : Data.WallPaper.all.length;
				case I_Wall(_) : Data.WallFurn.all.length;
				default : 0;
			}
			for(i in all.length...max)
				addUnknownItem();

			addBack();
		}
	}

	inline function isInCategory(i:Item) {
		return i.getIndex()==cat.getIndex() && switch( i ) {
			case I_Color(id) : id!="raw";
			default : true;
		}
	}

	override public function close() {
		super.close();

		cat = null;
		invalidate();
	}


	function openCategory(c:Null<Item>) {
		if( c==null && Game.ME.tuto.commandLocked("customBack") )
			return;

		if( c!=null && Game.ME.tuto.commandLocked("customOnlyBed") && c.getIndex()!=I_Bed(-1).getIndex() )
			return;

		if( c!=null && Game.ME.tuto.commandLocked("customOnlyTexture") && c.getIndex()!=I_Texture(-1).getIndex() )
			return;

		if( c==null )
			Assets.SBANK.slide2().play(0.25, 0.5);
		else
			Assets.SBANK.slide1().play(0.35, 0.5);
		cat = c;
		wrapper.y = hcm()>9 ? h()*0.25 : 0;
		refresh();
	}

	public function isCat(i:Item) {
		return cat!=null && cat.getIndex()==i.getIndex();
	}


	function addBack() {
		var b = createButton(function() {
			Assets.SBANK.click1(1);
			openCategory(null);
		});
		b.enableRollover();

		var iwid = 64;
		var icon = b.addElement("icon", "tutoArrow");
		icon.tile.setCenterRatio(0.5,0.5);
		icon.setScale( iwid/icon.height );
		icon.scaleX*=-1;
		icon.x = 10 + iwid*0.5;
		icon.y = bhei*0.5;

		var label = b.addText("label", Lang.t._("Back"), 24);
		label.textColor = Const.TEXT_GRAY;
		label.x = iwid + 20;
		label.y = bhei*0.5 - label.textHeight*label.scaleY*0.5;

		b.position();
	}


	function addButton(icon:String, label:LocaleString, ?sub:LocaleString, col:Int, cb:Void->Void) {
		var b = createButton(function() {
			Assets.SBANK.click1(1);
			if( !Game.ME.tuto.commandLocked("side") )
				cb();
		});
		b.enableRollover();
		b.autoHide = false;

		var iwid = 64;

		var icon = b.addElement("icon", icon);
		icon.setScale( iwid/icon.height );
		icon.tile.setCenterRatio(0.5,0.5);
		icon.x = 10 + iwid*0.5;
		icon.y = bhei*0.5;

		var th = 0.;

		// Label
		var label = b.addText("name", label, 21);
		label.x = icon.x + iwid*0.5 + 10;
		label.maxWidth = (wid - label.x - 10 ) / label.scaleX;
		label.textColor = col;
		th += label.textHeight*label.scaleY;

		// Sub
		if( sub!=null ) {
			var tf = b.addText("sub", sub, 17);
			tf.x = label.x;
			tf.maxWidth = (wid - tf.x - 10 ) / tf.scaleX;
			tf.y = label.y + label.textHeight*label.scaleY;
			tf.textColor = Const.TEXT_GRAY;
			th += tf.textHeight*tf.scaleY;

			tf.y += bhei*0.5 - th*0.5;
		}

		label.y += bhei*0.5 - th*0.5;

		b.position();
	}



	function addCategory(c:Item, label:LocaleString, ?id:String) {
		var b = createButton(function() {
			Assets.SBANK.click1(1);
			openCategory(c);
		}, id);
		b.enableRollover();

		//var iwid = 64;
		//var icon = b.addElement("icon", "iconTodoRed");
		//icon.setScale( iwid/icon.height );
		//icon.x = 10 + iwid*0.5 - icon.width*0.5;
		//icon.y = Std.int( bhei*0.5 - icon.height*0.5 );

		var count = 0;
		for(i in shotel.inventory)
			if( i.getIndex()==c.getIndex() )
				count++;

		var label = b.addTextHuge("label", cast label + (count==0 ? "" : " ("+count+")"), 28);
		label.x = 20;
		label.textColor = count==0 ? Const.TEXT_GRAY : Const.TEXT_GOLD;
		label.y = bhei*0.5 - label.textHeight*label.scaleY*0.5;

		//var desc = b.addText("desc", Lang.t._("Click to view category"), 14);
		//desc.x = 20;
		//desc.textColor = count==0 ? Const.TEXT_GRAY : 0xFFFFFF;
//
		//var th = label.textHeight*label.scaleY + desc.textHeight*desc.scaleY;
		//label.y = bhei*0.5 - th*0.5;
		//desc.y = label.y + 35;

		b.position();
	}

	function onBuy(i:Item, ?next:GameCommand) {
		var q = new ui.Question();
		var inf = GameData.getItemCost(i);
		var name = Lang.getItem(i).name;
		q.addText( Lang.t._("Do you want to buy more of this decoration?") );
		for(n in [1,2,5]) {
			var label = Lang.t._("Buy ::n:: for ::cost::", { n:n, cost:Game.ME.prettyMoney(inf.cost*n) });
			q.addButton(label, "moneyGold", function() {
				if( next==null )
					Game.ME.runSolverCommand( DoBuyItem(i, n) );
				else
					Game.ME.chainCommands([ DoBuyItem(i, n), next ]);
			});
		}
		q.addCancel();
	}

	function addItem(i:Item) {
		var count = shotel.countInventoryItem(i);
		var cost = GameData.getItemCost(i).cost;
		var toBuy = cost>0 && count==0;

		var b = createButton(function() {
			//if( !Game.ME.shotel.hasInventoryItem(i) )
			if( !Game.ME.tuto.isRunning() )
				onBuy(i);
		}, toBuy ? null : i);
		b.enableRollover();

		var iwid = 64;
		var icon : BatchElement = null;
		switch( i ) {
			case I_Color(id) :
				// Color icon
				var c = DataTools.getWallColorCode(id,true);
				icon = b.addElement("icon", "white", 0);
				icon.width = icon.height = iwid;
				icon.color = h3d.Vector.fromColor(c);
				icon.setPos(10, Std.int( bhei*0.5 - icon.height*0.5 ) );

				//var front = b.addElement("front", count>0?"sideIconOff":"sideIcon", 0);
				//front.width = front.height = iwid;
				//front.setPos(icon.x, icon.y);

			case I_Texture(f) :
				// Texture icon
				icon = b.addElement("bg", "white", 0);
				icon.width = icon.height = iwid;
				icon.color = h3d.Vector.fromColor(alpha(0x757A93));
				icon.setPos(10, Std.int( bhei*0.5 - icon.height*0.5 ) );

				if( f<0 ) {
					var e = b.addElement("none", "iconRemove", 0);
					e.changePriority(-1);
					e.width = e.height = iwid;
					e.setPos(icon.x, icon.y);
				}

				//var e = b.addElement("front", count>0?"sideIconOff":"sideIcon", 0);
				//e.changePriority(-1);
				//e.width = e.height = iwid;
				//e.setPos(icon.x, icon.y);

			default :
				// Generic icon
				var k = "iconTodoRed";
				var f = 0;
				switch( i ) {
					case I_Bath(ff)	: k="bath"; f=ff;
					case I_Bed(ff)	: k="bed"; f=ff;
					case I_Ceil(ff)	: k="ceil"; f=ff;
					case I_Furn(ff)	: k="furn"; f=ff;
					case I_Wall(ff)	: k="wall"; f=ff;
					default :
				}
				icon = Assets.custo0.addBatchElement(csb, k, f);
				b.registerElementFree("icon", icon);
				icon.tile.setCenterRatio(0.5,0.5);
				icon.setScale( MLib.fmin( iwid/icon.width, iwid/icon.height ) );
				icon.x = 10 + iwid*0.5;
				icon.y = bhei*0.5;
		}

		// Name
		//var name = b.addText("name", Lang.getItem(i).name, 22);
		//name.x = iwid + 20;
		//name.textColor = toBuy ? Const.TEXT_GOLD : 0xffffff;

		// Desc
		var label = Lang.t._("::n:: in stock", {n:count});
		var r = DataTools.getCustomItemRarity(i);
		switch( r ) {
			case Data.RarityKind.Uncommon, Data.RarityKind.Rare, Data.RarityKind.Never :
				label += cast " ("+Lang.getRarity(r)+")";

			default :
		}

		if( count==0 ) {
			if( Main.TOUCH )
				label = Lang.t._("Tap to buy for ::cost::", {cost:Game.ME.prettyMoney(cost)});
			else
				label = Lang.t._("Click to buy for ::cost::", {cost:Game.ME.prettyMoney(cost)});
		}
		var p = GameData.getItemCost(i);
		var desc = b.addText("desc", label, count==0 ? 16 : 20);
		desc.maxWidth = (wid-iwid-10) / desc.scaleX;
		desc.x = iwid+20;
		desc.y = bhei*0.5 - desc.textHeight*desc.scaleY*0.5;
		desc.textColor = count==0 ? Const.TEXT_GOLD : 0xffffff;

		// More
		//if( count==0 ) {
			var more = b.addElement("more", "btnPlus",1, 1, 0.5);
			more.alpha = 0.6;
			more.setScale(0.7);
			more.x = wid - 20;
			more.y = bhei*0.5;
		//}

		// Vertical align
		//var th = name.textHeight*name.scaleY + desc.textHeight*desc.scaleY;
		//name.y = bhei*0.5 - th*0.5;
		//desc.y = name.y + 25;

		b.position();

		// Texture
		switch( i ) {
			case I_Texture(f) :
				if( f>=0 ) {
					var t = new TiledTexture(csb, Assets.custo0, icon.x, icon.y, iwid, iwid);
					t.fill("wallPaper", f, 0.2, 0.6);
				}

				var e = Assets.tiles.addBatchElement(frontSb, -1, count>0?"sideIconOff":"sideIcon", 0);
				e.width = e.height = iwid;
				e.setPos(icon.x, icon.y);

			case I_Color(_) :
				var e = Assets.tiles.addBatchElement(frontSb, -1, count>0?"sideIconOff":"sideIcon", 0);
				e.width = e.height = iwid;
				e.setPos(icon.x, icon.y);

			default :
		}
	}

	function addUnknownItem() {
		var b = createButton();
		b.disableRollover();

		var iwid = 64;
		var icon = b.addElement("icon", "unknown", 0);
		icon.setScale( MLib.fmin(iwid/icon.width, iwid/icon.height) );
		icon.setPos(10 + iwid*0.5-icon.width*0.5, Std.int( bhei*0.5 - icon.height*0.5 ) );

		// Name
		//var name = b.addText("name", Lang.getItem(i).name, 22);
		//name.x = iwid + 20;
		//name.textColor = toBuy ? Const.TEXT_GOLD : 0xffffff;

		// Desc
		var label = Lang.t._("Not unlocked yet");
		var desc = b.addText("desc", label, 16);
		desc.maxWidth = (wid-iwid-10) / desc.scaleX;
		desc.x = iwid+20;
		desc.y = bhei*0.5 - desc.textHeight*desc.scaleY*0.5;
		desc.textColor = Const.TEXT_GRAY;

		b.position();
	}

	override function canDrag(value:Dynamic) {
		return value!=null && switch( Type.typeof(value) ) {
			case Type.ValueType.TEnum(_) : true;
			default : false;
		}
	}

	override function onStartDrag(v:Dynamic) {
		super.onStartDrag(v);

		var i : Item = cast v;

		g.clearHudLayer();
		for(r in g.hotelRender.rooms)
			switch( i ) {
				case I_Cold, I_Heat, I_Noise, I_Odor :
					if( r.is(R_Bedroom) ) {
						var c = r.getClientInside();
						if( c!=null && !c.isDone() && ( c.sclient.hasLike(com.Solver.getEquipmentAffect(i)) || c.sclient.type==C_Emitter && c.sclient.emit==null ) )
							g.hudRoom(r.rx, r.ry, "iconUseItem");
						else
							g.hudRoom(r.rx, r.ry, "iconForbidden");
					}

				case I_Light :
					if( r.is(R_Bedroom) ) {
						var c = r.getClientInside();
						if( c!=null && !c.isDone() )
							g.hudRoom(r.rx, r.ry, "iconUseItem");
						else
							g.hudRoom(r.rx, r.ry, "iconForbidden");
					}

				case I_Bath(_), I_Bed(_), I_Ceil(_), I_Furn(_), I_Wall(_), I_Color(_), I_Texture(_) :
					if( r.sroom.canReceivedItem(i) )
						g.hudRoom(r.rx, r.ry, "iconPaint");

				default :
			}

		Assets.tiles.getH2dBitmap( Assets.getItemIcon(i), 0.5,0.5, cursor );
	}

	override function onDragOnScene(i:Item,cx,cy,?r) {
		super.onDragOnScene(i,cx,cy,r);

		if( r!=null )
			if( shotel.countInventoryItem(i)==0 )
				onBuy(i, DoUseItemOnRoom(cx,cy,i));
			else
				Game.ME.runSolverCommand( DoUseItemOnRoom(cx,cy,i) );
	}

	override function onResize() {
		super.onResize();
	}


	override function onDispose() {
		super.onDispose();

		csb.dispose();
		csb = null;

		frontSb.dispose();
		frontSb = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	override function update() {
		super.update();

		if( isOpen && (ui.side.BuildMenu.CURRENT.isOpen ||
			ui.side.Contacts.CURRENT.isOpen ||
			ui.side.Inbox.CURRENT.isOpen ||
			ui.side.ItemMenu.CURRENT.isOpen ||
			ui.side.Quests.CURRENT.isOpen) )
				close();
	}
}