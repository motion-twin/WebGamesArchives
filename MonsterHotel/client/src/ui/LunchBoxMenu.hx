package ui;

import mt.MLib;
import mt.data.GetText;
import mt.deepnight.slb.*;
import com.*;
import com.Protocol;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

#if( prod && connected )
import mt.net.FriendRequest;
#end

class LunchBoxMenu extends H2dProcess {
	public static var CURRENT : LunchBoxMenu;

	var shotel(get,null)	: com.SHotel; inline function get_shotel() return Game.ME.shotel;
	var sb					: SpriteBatch;
	var tsb					: SpriteBatch;

	//var i					: h2d.Interactive;
	//var icon				: HSpriteBE;
	//var bg					: HSpriteBE;
	var count				: TextBatchElement;
	var isize = 128;


	public function new() {
		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		CURRENT = this;
		name = "LunchBoxMenu";

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;
		sb.name = name+".sb";
		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, root);
		tsb.name = name+".tsb";
		tsb.filter = true;

		var bg = Assets.tiles.hbe_get(sb, "btnBlankBig",1, 0.5,0.5);
		bg.setScale( isize/bg.tile.width );

		var icon = Assets.tiles.hbe_getAndPlay(sb, "giftTurn");
		icon.setCenterRatio(0.5, 0.5);
		icon.setScale( 0.6*isize/icon.tile.width );

		var i = new h2d.Interactive(isize, isize, root);
		i.setPos(-isize*0.5, -isize*0.5);
		i.onClick = function(_) {
			//#if debug
			//new ui.LunchBox(I_Color("red1"), true);
			//return;
			//#end
			if( shotel.countInventoryItem(I_LunchBoxAll)>0 )
				Game.ME.runSolverCommand( DoUseItem(I_LunchBoxAll) );
			else
				Game.ME.runSolverCommand( DoUseItem(I_LunchBoxCusto) );
		}

		count = Assets.createBatchText(tsb, Assets.fontHuge, 48, 0xFFF980, "??");

		refresh();
	}


	inline function countLunchBoxes() {
		return shotel.countInventoryItem(I_LunchBoxAll) + shotel.countInventoryItem(I_LunchBoxCusto);
	}

	public function refresh() {
		var n = countLunchBoxes();
		count.text = n>0 ? Std.string(n) : "";
		count.x = -count.textWidth*count.scaleX*0.5;
		count.y = -count.textHeight*count.scaleY*0.5;

		onResize();
		updateVisibility();
	}

	public function getCoords() {
		return { x:root.x, y:root.y }
	}

	override function onResize() {
		super.onResize();

		#if responsive
		var s = Main.getScale(isize,1.5);
		#else
		var s = 1.5;
		#end
		root.setScale(s);
		root.x = w()*0.5;
		root.y = h()-isize*0.6*s;

		//bg.setScale(s);
		//bg.setPos(x,y);
//
		//icon.setPos(x,y);
		//icon.setScale(s*0.6);

		//i.setScale(s);
		//i.setPos(x-i.width*i.scaleX*0.5, y-i.height*i.scaleY*0.5);

		//count.setScale(s*0.8);
		//count.x = x - count.textWidth*count.scaleX*0.5;
		//count.y = y - count.textHeight*count.scaleY*0.5;
	}


	override function onDispose() {
		super.onDispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		//bg.dispose();
		//bg = null;
//
		//icon.dispose();
		//icon = null;

		count.dispose();
		count = null;

		//i.dispose();
		//i = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	inline function updateVisibility() {
		var forceHide = ui.Menu.isOpen(true);
		if( isVisible() && forceHide )
			root.visible = false;

		if( !forceHide )
			root.visible = !Game.ME.isVisitMode() && countLunchBoxes()>0;
	}

	inline function isVisible() return root.visible;

	override function update() {
		super.update();

		updateVisibility();

		if( !Game.ME.hasAnyPopUp() && isVisible() && !cd.hasSet("blink",Const.seconds(0.75)) )
			Game.ME.uiFx.ping(root.x, root.y, "fxNovaBlue",root.scaleX);

	}
}
