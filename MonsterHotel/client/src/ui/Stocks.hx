package ui;

import mt.MLib;
import mt.data.GetText;
import com.*;
import com.Protocol;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

class Stocks extends H2dProcess {
	public static var CURRENT : Stocks;

	var fields				: Int;
	var shotel(get,null)	: com.SHotel; inline function get_shotel() return Game.ME.shotel;
	var sb					: SpriteBatch;
	var tsb					: SpriteBatch;
	var isize = 32;

	public function new() {
		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		CURRENT = this;
		name = "Stocks";
		root.y = h();

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;

		tsb = new h2d.SpriteBatch(Assets.fontTiny.tile, root);
		tsb.filter = true;

		refresh();
	}

	function getSkipAllCost() {
		return com.GameData.getSkipAllCost( shotel.getSkipAllClients(Game.ME.serverTime).length );
	}


	public function refresh() {
		if( Game.ME.isVisitMode() )
			return;

		sb.removeAllElements();
		tsb.removeAllElements();
		fields = 0;

		if( !Main.ME.settings.showStocks )
			return;

		for(t in [R_StockBoost, R_StockBeer, R_StockSoap, R_StockPaper])
			if( shotel.hasRoomType(t) )
				createField( t, Assets.getStockIconId(t), shotel.countStock(t) );

		if( shotel.hasRoomType(R_Laundry) ) {
			var n = 0;
			for(r in shotel.rooms)
				if( r.type==R_Laundry && !r.working && !r.constructing )
					n++;
			createField( R_Laundry, "laundryMachine", n);
		}

		onResize();
	}

	function createField(t:RoomType, iconId:String, count:Int) {
		var x = 0;
		var y = (fields++) * (isize+5);

		var hasBoost = false;
		for(r in shotel.rooms)
			if( r.type==t && r.hasBoost() ) {
				hasBoost = true;
				break;
			}

		var col = count==0 ? 0x800000 : hasBoost ? 0x0060BF : Const.BLUE;
		var bg = Assets.tiles.addColoredBatchElement(sb,"popUpBg", col, 0.9);
		bg.x = x + isize*0.5;
		bg.y = y+5;
		bg.width = 60;
		bg.height = isize-10;

		var icon = Assets.tiles.addBatchElement(sb, iconId, 0, 0.5,0);
		icon.setScale( MLib.fmin( isize/icon.width, isize/icon.height ) );
		icon.x = x + isize*0.5;
		icon.y = y;

		if( hasBoost ) {
			var boost = Assets.tiles.addBatchElement(sb, "iconBoost", 0, 0.5,0.5);
			boost.setScale( MLib.fmin( isize/boost.width, isize/boost.height ) );
			boost.x = x + isize*0.5 + 60;
			boost.y = y + isize*0.5;
		}

		var tf = Assets.createBatchText(tsb, Assets.fontTiny, 21, Std.string(count));
		tf.dropShadow = { color:0x0, alpha:0.7, dx:2, dy:3 }
		tf.x = x + isize + 10;
		tf.y = y + isize*0.5 - tf.textHeight*tf.scaleY*0.5;
		tf.textColor = count==0 ? Const.TEXT_BAD : 0xffffff;
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

		root.setScale( Main.getScale(50, 0.55) );

		root.x = 10/root.scaleX;
		root.y = ui.QuestLog.CURRENT.getBottomY();
		//root.x = w()*0.5 - root.width*0.5;
		//root.y = ui.MainStatus.CURRENT.root.scaleY*65;
	}
}
