package ui.side;

import mt.MLib;
import mt.data.GetText;
import com.Protocol;
import com.GameData;
import Data;

class Quests extends ui.SideMenu {
	public static var CURRENT : Quests;
	var qidx	: Int;

	public function new() {
		CURRENT = this;

		super();

		left = true;

		name = "Quests";
		qidx = 0;
		bhei = 100;

		onResize();
	}

	override public function open() {
		super.open();
		invalidate();
		ui.HudMenuTip.clear("quest_all");
	}

	override function refresh() {
		super.refresh();

		clearContent();

		qidx = 0;

		// Open lunch box
		//var n = shotel.countInventoryItem(I_LunchBoxAll) + shotel.countInventoryItem(I_LunchBoxCusto);
		//if( n>0 ) {
			//addTitle(Lang.t._("My rewards"), Const.TEXT_GOLD);
			//addButton("gift", Lang.t._("Open 1 mysterious box"), Lang.t._("You have ::n::", {n:n}), Const.TEXT_GOLD, true, function() {
				//if( shotel.hasInventoryItem(I_LunchBoxAll) )
					//Game.ME.runSolverCommand( DoUseItem(I_LunchBoxAll) );
				//else
					//Game.ME.runSolverCommand( DoUseItem(I_LunchBoxCusto) );
			//});
		//}

		addTitle(Lang.t._("Regular contracts"));

		// Main quests
		var all = shotel.curQuests.filter( function(q) return !DataTools.isDaily(q.id) );
		if( all.length>0 )
			for(q in all)
				addQuest(q);

		if( shotel.canHaveDailyQuests() ) {
			// Daily quests
			var all = shotel.curQuests.filter( function(q) return DataTools.isDaily(q.id) );
			for(q in all)
				addQuest(q);

			// Skip buttons
			var t = shotel.getTask(InternalQuestRegen);
			for(i in 0...shotel.getMaxDailyQuests()-all.length) {
				var sub = t!=null && i==0 ? Lang.t._("Or wait: ::time::", {time:Game.ME.prettyTime(t.end)}) : null;
				addButton("moneyGem", Lang.t._("New quest (1 GEM)"), sub, Const.TEXT_GEM, function() {
					if( Main.ME.settings.confirmGems ) {
						var q = new ui.Question();
						q.addButton(Lang.t._("Generate a new quest?"), "moneyGem", Game.ME.runSolverCommand.bind(DoNewQuest));
						q.addCancel();
					}
					else
						Game.ME.runSolverCommand(DoNewQuest);
				});
			}
		}
	}


	function addButton(icon:String, label:LocaleString, ?sub:LocaleString, col:Int, ?important=false, cb:Void->Void) {
		var b = createButton(cb, qidx);
		b.enableRollover();
		b.autoHide = false;

		var iwid = 64;

		if( important ) {
			var bg = b.addElement("bg", "white");
			bg.color = h3d.Vector.fromColor(alpha(0x8A2D00));
			bg.width = wid;
			bg.height = bhei;
			var e = b.addElement("top", "popUpTop");
			e.width = wid;
			var e = b.addElement("bottom", "popUpBottom");
			e.width = wid;
			e.y = bhei-e.height;
		}

		var icon = b.addElement("icon", icon);
		icon.setScale( iwid/icon.height );
		icon.x = 10 + iwid*0.5 - icon.width*0.5;
		icon.y = Std.int( bhei*0.5 - icon.height*0.5 );

		var th = 0.;

		// Label
		var label = b.addText("name", label, 21);
		label.x = icon.x + iwid + 10;
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
		qidx++;
	}


	function addQuest(q:QuestState) {
		var data = DataTools.getQuest(q.id);
		if( data==null )
			return;

		var allTexts = [];

		var b = createButton(qidx);
		b.autoHide = true;

		var iwid = bhei-10;
		var bg = b.addElement("bg", "sideIconOff");
		bg.setScale( iwid/bg.height );
		bg.x = 10 + iwid*0.5 - bg.width*0.5;
		bg.y = Std.int( bhei*0.5 - bg.height*0.5 );

		if( Game.ME.cd.has("recent_"+q.id) ) {
			Game.ME.cd.set("recent_"+q.id, Const.seconds(3));
			var e = b.addElement("newBg", "white");
			e.color = h3d.Vector.fromColor(alpha(0x223568));
			e.width = wid;
			e.height = bhei;
			//createTinyProcess(function(p) {
				//if( !isOpen )
					//p.destroy();
				//else
					//e.alpha = 0.9 + Math.cos(time*0.2)*0.2;
			//},true);
			var e = b.addElement("top", "fxBlueLight");
			e.tile.setCenterRatio(0, 0.5);
			e.width = wid;
			e.scaleY = 0.5;
			var e = b.addElement("bottom", "fxBlueLight");
			e.tile.setCenterRatio(0, 0.5);
			e.width = wid;
			e.y = bhei;
			e.scaleY = 0.5;
		}

		var k = switch( data.objectiveId ) {
			case Data.QObjectiveKind.InstallClient: "clientLuggage";
			case Data.QObjectiveKind.Beer: "itemBeer";
			case Data.QObjectiveKind.Soap: "iconSoap";
			case Data.QObjectiveKind.Paper: "iconPq";
			case Data.QObjectiveKind.Love: "moneyLove";
			case Data.QObjectiveKind.Theft: "moneyGold";
			case Data.QObjectiveKind.Trash: "iconKick";
			case Data.QObjectiveKind.Bedroom: "iconBuild";
			case Data.QObjectiveKind.Laundry: "laundryBasket";
			case Data.QObjectiveKind.UseItem: "iconInv";
			case Data.QObjectiveKind.Boost: "iconBattery";
			case Data.QObjectiveKind.CompleteDailyQuestBugged: "iconQuest";
			case Data.QObjectiveKind.MaxedHappiness: "emote";
			case Data.QObjectiveKind.ExactHappiness: "emote";
			case Data.QObjectiveKind.HappinessCombo: "questCombo";
			case Data.QObjectiveKind.MinHappiness: "emote";
			case Data.QObjectiveKind.HappinessColumn: "questColumn";
			case Data.QObjectiveKind.HappinessLine: "questRow";
			case Data.QObjectiveKind.Vip: "iconVip";
		}
		if( k!=null ) {
			var s = 0.4;
			var icon = b.addElement("icon", k);
			icon.tile.setCenterRatio(0.5,0.5);
			icon.setScale( MLib.fmin( iwid*s/icon.width, iwid*s/icon.height ) );
			icon.x = 10 + iwid*0.35;
			icon.y = bhei*0.5;
			icon.alpha = 0.5;
		}

		// Counter
		var n = q.ocount;
		var tf = b.addTextHuge("counter", cast "x"+q.ocount, 30);
		tf.textColor =
			n>10 ? Const.TEXT_GRAY :
			n>1 ? 0xffffff :
			0xCEFF09;
		tf.x = bg.x + iwid*0.65 - tf.textWidth*tf.scaleX*0.5;
		tf.y = bg.y + iwid*0.5 - tf.textHeight*tf.scaleY*0.5;

		var x = bg.x + iwid + 10;
		var y = 0.;
		var canCancel = DataTools.isDaily(q.id);
		var cancelSize = 30;

		// Objective
		var desc = Lang.getQuestObjective(data.objectiveId, q.oparam, q.ocount, shotel);
		var tf = b.addText("obj", desc, 18);
		tf.x = x;
		tf.y = y;
		tf.maxWidth = (wid-x-20-(canCancel?cancelSize+10:0)) / tf.scaleX;
		tf.textColor = 0xFFFFFF;
		allTexts.push(tf);
		y+=tf.textHeight*tf.scaleY;

		// Rewards
		var rewards = data.rewards.toArrayCopy().filter( function(r) return r.rewardId!=Data.QRewardKind.EnableDailyQuests );
		var rlist = rewards.map( function(r) return Lang.getQuestReward(r.rewardId, r.count) );
		if( rlist.length==0 )
			rlist.push( Lang.getQuestReward(Data.QRewardKind.LunchBoxAll, 1) );
		var r = rlist.length<=1 ? Lang.t._("Reward: ::r::", {r:rlist[0]}) : Lang.t._("Rewards: ::r::", {r:rlist.join(", ")});
		var tf = b.addText("reward", r, 16);
		tf.x = x;
		tf.y = y;
		tf.maxWidth = (wid-x-20-(canCancel?cancelSize+10:0)) / tf.scaleX;
		tf.textColor = Const.TEXT_GOLD;
		allTexts.push(tf);
		y+=tf.textHeight*tf.scaleY;

		// Vertical align
		var th = y;
		for(tf in allTexts)
			tf.y += bhei*0.5 - th*0.5;

		// Cancel
		if( canCancel )
			b.addSubButton("iconRemove", wid-cancelSize*0.5-10, bhei*0.5, cancelSize, function() {
				var quest = q;
				var q = new ui.Question();
				q.addText( Lang.t._("You are about to cancel the following quest and replace it by a new one:") );
				q.addText( Lang.untranslated("\""+desc+"\""), Const.TEXT_GRAY, true, 0.7);
				q.addButton(Lang.t._("Yes, replace it"), "moneyGem", function() {
					Game.ME.runSolverCommand( DoCancelQuest(quest.id) );
				});
				q.addCancel();
			});

		b.position();
		qidx++;
	}

	override function onStartDrag(i) {
		super.onStartDrag(i);
	}

	override function onDragOnScene(i:Item,cx,cy,?r) {
		super.onDragOnScene(i,cx,cy,r);
	}

	override function canDrag(value:Dynamic) {
		return false;
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