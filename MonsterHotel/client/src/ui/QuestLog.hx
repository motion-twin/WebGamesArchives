package ui;

import mt.MLib;
import Game;
import com.Protocol;
import com.*;
import Data;
import mt.deepnight.Lib;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

class QuestLog extends H2dProcess {
	public static var CURRENT : QuestLog;

	var shotel(get,null)	: com.SHotel;
	var sb					: h2d.SpriteBatch;
	var tsb					: h2d.SpriteBatch;
	var utsb				: h2d.SpriteBatch;
	var ctrap				: h2d.Interactive;

	var qy					: Map<String,Float>;

	public function new() {
		CURRENT = this;

		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		name = "QuestLog";
		root.name = name;
		qy = new Map();

		ctrap = new h2d.Interactive(4,4,root);
		ctrap.onClick = function(_) {
			Assets.SBANK.click1(1);
			if( !Game.ME.tuto.isRunning("quests") && !Game.ME.tuto.isRunning("questRefill") && ( Game.ME.tuto.commandLocked("click") || Game.ME.tuto.commandLocked("side") ) )
				Game.ME.followTheInstructions("hudMenu");
			else if( !cd.hasSet("click",Const.seconds(0.25)) )
				ui.side.Quests.CURRENT.toggle();
		}

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;
		sb.name = name+".sb";

		tsb = new h2d.SpriteBatch(Assets.fontTiny.tile, root);
		tsb.filter = true;
		tsb.name = name+".tsb";

		utsb = new h2d.SpriteBatch(Assets.fontHuge.tile, root);
		utsb.filter = true;
		utsb.name = name+".utsb";

		refresh();
		root.visible = !Game.ME.isVisitMode();
	}


	inline function get_shotel() return Game.ME.shotel;

	public function getQuestCoord(id:String) : {x: Float, y: Float} {
		return
			!qy.exists(id) ? {
				x	: root.x + 40*root.scaleX,
				y	: root.y + 10*root.scaleY,
			} :
			{
				x	: root.x + 40*root.scaleX,
				y	: root.y + MLib.fmax(5, qy.get(id))*root.scaleY,
			}
	}

	public function refresh() {
		qy = new Map();
		sb.removeAllElements();
		tsb.removeAllElements();
		utsb.removeAllElements();

		var all = shotel.curQuests.copy();
		all.sort( function(a,b) {
			var da = DataTools.isDaily(a.id);
			var db = DataTools.isDaily(b.id);
			if( da && !db ) return 1;
			else if( !da && db ) return -1;
			else return 0;
		});
		root.visible = shotel.featureUnlocked("quests") && !Game.ME.isVisitMode();

		if( Game.ME.isVisitMode() )
			return;

		var y = 10.;

		var bg = Assets.tiles.addBatchElement(sb, "questLog",0, 0,1);
		bg.x = 0;
		var margin = 70;
		var size = 43;

		for(q in all) {
			var data = DataTools.getQuest(q.id);
			if( data==null )
				continue;

			qy.set(q.id, y + size*0.5);

			var k : String = switch( data.objectiveId ) {
				case Data.QObjectiveKind.InstallClient: "clientLuggage";
				case Data.QObjectiveKind.Beer: "itemBeer";
				case Data.QObjectiveKind.Soap: "iconSoap";
				case Data.QObjectiveKind.Paper: "iconPq";
				case Data.QObjectiveKind.Love: "moneyLove";
				case Data.QObjectiveKind.Theft: "moneyGold";
				case Data.QObjectiveKind.Trash: "iconKick";
				case Data.QObjectiveKind.Bedroom: "iconBuild";
				case Data.QObjectiveKind.Laundry: "laundryBasket";
				case Data.QObjectiveKind.UseItem:
					switch( Type.createEnumIndex(Item, q.oparam) ) {
						case I_Heat : "iconHeat";
						case I_Cold : "iconCold";
						case I_Odor : "iconOdor";
						case I_Noise : "iconNoise";
						default : "iconTodoRed";
					}
				case Data.QObjectiveKind.CompleteDailyQuestBugged: "iconQuest";
				case Data.QObjectiveKind.MaxedHappiness: "emote";
				case Data.QObjectiveKind.ExactHappiness: "emote";
				case Data.QObjectiveKind.HappinessCombo: "questCombo";
				case Data.QObjectiveKind.Boost: "iconBattery";
				case Data.QObjectiveKind.MinHappiness: "emote";
				case Data.QObjectiveKind.HappinessLine: "questRow";
				case Data.QObjectiveKind.HappinessColumn: "questColumn";
				case Data.QObjectiveKind.Vip: "iconVip";
			}

			var icon = Assets.tiles.addBatchElement(sb, k, 0, 0.5,0.5);
			icon.setScale( MLib.fmin(size/icon.width, size/icon.height) );
			icon.x = margin + size*0.5;
			icon.y = y + size*0.5;

			var tf = Assets.createBatchText(tsb, Assets.fontTiny, 18, Const.BLUE, cast q.oparam);
			var dx = 0;
			switch( data.objectiveId ) {
				case Data.QObjectiveKind.ExactHappiness:

				case Data.QObjectiveKind.MaxedHappiness:
					tf.text = "MAX";

				case Data.QObjectiveKind.HappinessLine :

				case Data.QObjectiveKind.HappinessColumn :
					dx = 2;

				case Data.QObjectiveKind.MinHappiness:
					tf.text+="+";

				default :
					tf.visible = false;
			}
			tf.x = icon.x - tf.textWidth*tf.scaleX*0.5 + dx;
			tf.y = y + size*0.5 - tf.textHeight*tf.scaleY*0.5;

			var tf = Assets.createBatchText(utsb, Assets.fontHuge, 20, 0x482512, cast "x");
			tf.x = size + margin + 6;
			tf.y = y + size*0.5 - tf.textHeight*tf.scaleY*0.5;
			tf.alpha = 0.6;

			var tf = Assets.createBatchText(utsb, Assets.fontHuge, 30, 0x482512, cast q.ocount);
			tf.x = size + margin + 17;
			tf.y = y + size*0.5 - tf.textHeight*tf.scaleY*0.5;

			y+=size;
		}

		// Placeholders
		if( shotel.canHaveDailyQuests() )
			for(i in 0...shotel.getMaxDailyQuests()-shotel.countDailyQuests()) {
				var e = Assets.tiles.addBatchElement(sb, "questEmpty", 0, 0.5,0.5);
				e.x = bg.width*0.5;
				e.y = y + size*0.5;
				e.alpha = 0.5;

				y+=size+5;
			}

		bg.y = MLib.fmax(100, y+50);

		ctrap.width = bg.width;
		ctrap.height = bg.y;

		onResize();
	}

	override function onDispose() {
		super.onDispose();

		qy = null;

		ctrap.dispose();
		ctrap = null;

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		utsb.dispose();
		utsb = null;

		if( CURRENT==this )
			CURRENT = null;
	}


	override function onResize() {
		super.onResize();

		root.setScale( Main.getScale(220, 1.7) );
		root.x = -5;
		root.y = 0;

		if( ui.Stocks.CURRENT!=null )
			ui.Stocks.CURRENT.onResize();
	}

	public function getBottomY() {
		return (ctrap.height+20)*root.scaleY;
	}
}
