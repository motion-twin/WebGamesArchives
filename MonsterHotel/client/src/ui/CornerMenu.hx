package ui;

import mt.MLib;
import Game;
import com.Protocol;
import mt.deepnight.Lib;
import mt.deepnight.slb.*;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

class CornerMenu extends H2dProcess {
	public static var CURRENT : CornerMenu;

	var bwid = 64;
	var shotel(get,null)	: com.SHotel;
	public var settingsBt	: h2d.Interactive;
	var icon				: HSpriteBE;

	public function new() {
		CURRENT = this;

		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		name = "CornerMenu";
		root.name = name;

		// Settings
		settingsBt = new h2d.Interactive(bwid,bwid, root);
		settingsBt.onClick = function(_) {
			if( Game.ME.tuto.isRunning() )
				Game.ME.followTheInstructions("settings");
			else
				new ui.Settings();
		}
		icon = Assets.tiles.hbe_get(Main.ME.uiTilesSb, "iconUse",0, 0.5,0.5);
		icon.scaleX = icon.scaleY = bwid/icon.width;

		onResize();
	}


	inline function get_shotel() return Game.ME.shotel;

	override function onDispose() {
		super.onDispose();

		settingsBt.dispose();
		settingsBt = null;

		icon.dispose();
		icon = null;

		if( CURRENT==this )
			CURRENT = null;
	}


	override function onResize() {
		super.onResize();

		root.setScale( Main.getScale(bwid, 0.7) );
		root.x = w() - (bwid+5)*root.scaleX;
		root.y = 5*root.scaleY;

		icon.setPos( root.x + bwid*root.scaleX*0.5, root.y + bwid*root.scaleY*0.5 );
		icon.setScale(root.scaleX);
	}

	public function getBottomY() {
		return root.y + icon.height;
	}

	override function update() {
		super.update();

		root.visible = !Game.ME.isVisitMode() && !Game.ME.tuto.isRunning();
		icon.visible = root.visible;
	}
}
