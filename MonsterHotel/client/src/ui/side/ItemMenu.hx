package ui.side;

import mt.MLib;
import com.Protocol;
import com.GameData;

class ItemMenu extends ui.SideMenu {
	public static var CURRENT : ItemMenu;

	public function new() {
		CURRENT = this;

		super();

		name = "ItemMenu";
		bhei = 80;

		refresh();
		onResize();
	}

	function addItem(i:Item, count:Int) {
		var showBuy = count==0;

		var b = createButton(function() {
			if( !Game.ME.shotel.hasInventoryItem(i) ) {
				var q = new ui.Question();
				var inf = GameData.getItemCost(i);
				var name = Lang.getItem(i).name;
				q.addCenteredSprite( Assets.tiles.h_get(Assets.getItemIcon(i)) );
				q.addText( Lang.t._("You don't have any \"::item::\" left.", { item:name }) );
				var label =
					if( inf.cost>1 )
						Lang.t._("Buy ::n::x \"::item::\" for ::cost:: GEMS", { n:inf.n, cost:inf.cost, item:name });
					else
						Lang.t._("Buy ::n::x \"::item::\" for 1 GEM", { n:inf.n, item:name });
				q.addButton( label, "moneyGem", function() {
					Game.ME.runSolverCommand( DoBuyItem(i, 1) );
				});
				q.addCancel();
			}
		}, i);
		b.enableRollover();
		b.autoHide = false;

		var iwid = 64;
		var icon = b.addElement("icon", Assets.getItemIcon(i));
		icon.setScale( iwid/icon.height );
		icon.x = 10 + iwid*0.5 - icon.width*0.5;
		icon.y = Std.int( bhei*0.5 - icon.height*0.5 );


		// Gem
		if( showBuy ) {
			var gem = b.addElement("gem", "moneyGem");
			gem.tile.setCenterRatio(0.5,0.5);
			gem.setScale(0.5);
			gem.x = icon.x + icon.width*0.5;
			gem.y = icon.y + icon.height*0.85;
		}

		// Count
		if( !showBuy ) {
			var cbg = b.addElement("cbg", "squareBlue");
			var tf = b.addText("count", cast Std.string(count), 20);
			tf.x = icon.x + Std.int( icon.width*0.5-tf.textWidth*tf.scaleX*0.5 );
			tf.y = icon.y + icon.height-20;
			cbg.x = tf.x - 4;
			cbg.y = tf.y - 2;
			cbg.width = tf.textWidth*tf.scaleX + 8;
			cbg.height = tf.textHeight*tf.scaleY + 4;
			cbg.alpha = 0.7;
		}

		// Name
		var name = b.addText("name", Lang.getItem(i).name, 24);
		name.x = iwid + 20;

		// Desc
		var desc = b.addText("desc", Lang.getItem(i).role, 16);
		desc.x = name.x;
		desc.maxWidth = (wid-desc.x-20) / desc.scaleX;
		desc.textColor = Const.TEXT_GRAY;
		desc.visible = !showBuy;

		// Buy desc
		var p = GameData.getItemCost(i);
		var label =
			if( Main.TOUCH ) {
				if( p.cost>1 ) Lang.t._("Tap to buy ::n:: for ::cost:: GEMS", {n:p.n, cost:p.cost});
				else Lang.t._("Tap to buy ::n:: for 1 GEM", {n:p.n});
			}
			else {
				if( p.cost>1 ) Lang.t._("Click to buy ::n:: for ::cost:: GEMS", {n:p.n, cost:p.cost});
				else Lang.t._("Click to buy ::n:: for 1 GEM", {n:p.n});
			}

		var buy = b.addText("buy", label, 16);
		buy.x = name.x;
		buy.maxWidth = (wid-iwid-10) / buy.scaleX;
		buy.textColor = Const.TEXT_GOLD;
		buy.visible = showBuy;

		// Vertical align
		var th = name.textHeight*name.scaleY + desc.textHeight*desc.scaleY;
		name.y = bhei*0.5 - th*0.5;
		desc.y = name.y + 30;
		buy.y = name.y + 30;

		b.position();
	}

	override function onStartDrag(i) {
		super.onStartDrag(i);

		g.clearHudLayer();
		for(r in g.hotelRender.rooms)
			switch( i ) {
				case I_Cold, I_Heat, I_Noise, I_Odor :
					if( r.is(R_Bedroom) ) {
						var c = r.getClientInside();
						if( c!=null && !c.isDone() && ( c.sclient.hasLike(com.Solver.getEquipmentAffect(i)) || c.sclient.type==C_Emitter ) )
							g.hudRoom(r.rx, r.ry, "iconUseItem");
						else
							g.hudRoom(r.rx, r.ry, "iconForbidden");
					}

				case I_Light :
					if( r.is(R_Bedroom) ) {
						var c = r.getClientInside();
						if( c!=null && !c.isDone() && (c.sclient.hasLike(SunLight) || c.type==C_Emitter) )
							g.hudRoom(r.rx, r.ry, "iconUseItem");
						else
							g.hudRoom(r.rx, r.ry, "iconForbidden");
					}

				//case I_Repair :
					//if( r.is(R_Bedroom) && r.countClients()==0 && r.sroom.isDamaged() && !r.isWorking() )
						//g.hudRoom(r.rx, r.ry, Assets.getItemIcon(i));

				default :
			}

		Assets.tiles.getH2dBitmap( Assets.getItemIcon(i), 0.5,0.5, cursor );
	}

	override function onDragOnScene(i:Item,cx,cy,?r) {
		super.onDragOnScene(i,cx,cy,r);

		if( r!=null )
			if( !Main.ME.settings.confirmGems && shotel.countInventoryItem(i)==0 )
				new ui.Notification(Lang.t._("You don't have any ::item:: left.", {item:Lang.getItem(i).name}), Const.TEXT_BAD, Assets.getItemIcon(i));
			else
				Game.ME.runSolverCommand( DoUseItemOnRoom(cx,cy,i) );
	}

	override function refresh() {
		super.refresh();

		clearContent();

		addTitle(Lang.t._("Presents for clients"));
		addText(Lang.t._("Use these presents to make your clients happy!"));
		var all = [I_Heat, I_Noise, I_Odor, I_Light];
		if( shotel.featureUnlocked("cold") )
			all.insert(0, I_Cold);

		for(i in all)
			addItem(i, Game.ME.shotel.countInventoryItem(i));

		//for(i in [I_Cold, I_Heat, I_Noise, I_Odor, I_Light]) {
			//var n = Game.ME.shotel.countInventoryItem(i);
			//var b = getButton(i);
			//var showBuy = n==0;
			//b.getElement("gem").visible = showBuy;
			//b.getElement("cbg").visible = !showBuy;
			//b.getText("count").text = Std.string(n);
			//b.getText("count").visible = !showBuy;
			//b.getText("buy").visible = showBuy;
			//b.getText("desc").visible = !showBuy;
			////b.getElement("icon").alpha = n>0 ? 1 : 0.4;
		//}
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