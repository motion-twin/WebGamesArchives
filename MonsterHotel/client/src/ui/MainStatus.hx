package ui;

import mt.MLib;
import Game;
import com.Protocol;
import mt.deepnight.Lib;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

typedef StatusField = {
	var wid		: Float;
	var g		: BatchGroup;
	var tf		: TextBatchElement;
	var moreIcon: Null<BatchElement>;
	var moreInt	: Null<h2d.Interactive>;
}

class MainStatus extends H2dProcess {
	public static var CURRENT : MainStatus;

	var shotel(get,null)	: com.SHotel;
	var money				: StatusField;
	var gems				: StatusField;
	var love				: StatusField;
	//var fame				: StatusField;
	var loveFull			: TextBatchElement;

	public var sb			: SpriteBatch;
	var tsb					: SpriteBatch;

	var isVisible			: Bool;
	var margin = 90;
	var baseY = 30;

	#if( debug || !prod )
	var debug				: TextBatchElement;
	#end

	public function new() {
		CURRENT = this;

		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		isVisible = true;
		name = "MainStatus";
		root.name = name;
		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;
		sb.name = "MainStatus.sb";
		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, root);
		tsb.name = "MainStatus.tsb";
		tsb.filter = true;

		#if( debug || !prod )
		// Debug infos
		debug = Assets.createBatchText(tsb, Assets.fontHuge, 16, "");
		debug.x = 10;
		debug.y = 60;
		debug.dropShadow = { dx:0, dy:2, color:0x0, alpha:0.8 }
		#end

		// Gold
		money = createField(0,baseY, 230, "moneyGold", 0xFFCC00, 0x510C00, onMoreGold);

		// Gems
		gems = createField(money.wid+margin, baseY, 170, "moneyGem", 0x0DBEF2, 0x0C2749, onMoreGems);

		// Love
		love = createField(gems.g.x+gems.wid+margin, baseY, 170, "moneyLove", 0xD89FF0, 0x5C1248, onMoreLove.bind("loveButton"));
		loveFull = Assets.createBatchText(tsb, Assets.fontHuge, 20, 0xD89FF0, Lang.t._("(Full)"));

		// Fame
		//fame = createField(840,baseY, 170, "moneyFame", 0xFFCC00, 0x510C00);

		updateInfos();
		onResize();

		root.visible = !Game.ME.isVisitFromUrl();
	}

	public function getGoldCoords(?center=true) {
		return {
			x	: root.x + (money.g.x + 60 + (center?120:0))*root.scaleX,
			y	: root.y + money.g.y * root.scaleY,
		}
	}
	public function getGemsCoords(?center=true) {
		return {
			x	: root.x + (gems.g.x + 60 + (center?120:0))*root.scaleX,
			y	: root.y + gems.g.y * root.scaleY,
		}
	}
	public function getLoveCoords(?center=true) {
		return {
			x	: root.x + (love.g.x + 60 + (center?120:0))*root.scaleX,
			y	: root.y + love.g.y * root.scaleY,
		}
	}


	function onMoreGold() {
		#if connected
		mt.device.EventTracker.track("ui", "goldButton");
		#end
		if( Game.ME.tuto.isRunning() )
			Game.ME.followTheInstructions("buyGold");
		else
			Game.ME.openBuyGold();
	}

	function onMoreGems() {
		#if connected
		mt.device.EventTracker.track("ui", "gemsButton");
		#end
		if( Game.ME.tuto.isRunning() )
			Game.ME.followTheInstructions("buyGems");
		else
			Game.ME.openBuyGems();
	}

	function onMoreLove(trackerId:String) {
		if( Game.ME.tuto.isRunning() && !Game.ME.tuto.isRunning("askLove") )
			Game.ME.followTheInstructions("askLove");
		else {
			if( Game.ME.tuto.isRunning("askLove") )
				Game.ME.tuto.cm.persistantSignal("friends");
			Assets.SBANK.click1(1);
			ui.side.Contacts.CURRENT.open();
			//new ui.Friends( HFR_AskLove, Lang.t._("Ask your friends for love!") );
			//#if connected
			//mt.device.EventTracker.track("ui", trackerId);
			//#end
		}
	}

	function createField(x:Float, y:Float, width:Int, icon:String, col:Int, dark:Int, ?moreCb:Void->Void) : StatusField {
		var g = new BatchGroup(sb,tsb);

		var bg = Assets.tiles.addBatchElement(sb, "white", 0, 0,0.5);
		bg.color = h3d.Vector.fromColor(alpha(dark,0.9), 1);
		bg.x = 20;
		bg.width = width;
		bg.height = 42;
		g.add(bg);

		var i = Assets.tiles.addBatchElement(sb, icon, 0, 0.5, 0.5);
		i.setScale( MLib.fmin(55/i.width, 55/i.height) );
		g.add(i);
		i.x = 20;

		var t = Assets.createBatchText(tsb, Assets.fontHuge, 38, col, "???");
		t.dropShadow = { color:dark, alpha:0.8, dx:1, dy:3 }
		t.x = 60;
		t.y = Std.int(-t.textHeight*t.scaleY*0.5);
		g.add(t);

		var f : StatusField = {
			wid		: width,
			g		: g,
			tf		: t,
			moreIcon: null,
			moreInt	: null,
		}

		if( moreCb!=null ) {
			var w = 50;
			var i = new h2d.Interactive(width+w, w, root);
			f.moreInt = i;
			i.x = bg.x - w*0.5;// + width - w*0.5;
			i.y = -w*0.5;
			var locked = false;
			i.onClick = function(_) {
				if( Game.ME.isVisitMode() )
					return;

				if( locked || destroyed )
					return;

				var blink = Assets.tiles.getH2dBitmap("fxNovaYellow", i);
				blink.x = i.width-w;
				blink.width = w;
				blink.height = w;
				blink.filter = true;
				blink.blendMode = Add;
				locked = true;
				tw.create(blink.alpha, 0, 150).onEnd = function() {
					blink.dispose();
					blink = null;
					locked = false;
					ui.SideMenu.closeAll();
					moreCb();
				}
			}
			g.add(i);

			var icon = Assets.tiles.addBatchElement(sb, "btnPlus",3);
			f.moreIcon = icon;
			icon.width = w;
			icon.height = w;
			icon.x = bg.x + width - w*0.5;
			icon.y = -w*0.5;
			g.add(icon);

		}

		g.x = x;
		g.y = y;

		return f;
	}

	public function createButton(iconId:String, x:Float, y:Float, w:Float, cb:Void->Void) {
		var g = new BatchGroup(sb,tsb);
		g.x = x;
		g.y = y;

		var bg = Assets.tiles.addBatchElement(sb,"btnBlankBig",1);
		var scale = w/bg.width;
		bg.setScale(scale);
		g.add(bg);

		var icon = Assets.tiles.addBatchElement(sb, iconId,0, 0.5,0.5);
		icon.setScale(scale);
		icon.x = Std.int(w*0.5);
		icon.y = Std.int(w*0.5);
		g.add(icon);

		var i = new h2d.Interactive(w,w, root);
		i.onPush = Game.ME.onMouseDown;
		i.onRelease = function(e:hxd.Event) {
			if( !Game.ME.isDragging() && !Game.ME.tuto.commandLocked("click") ) {
				ui.SideMenu.closeAll();
				cb();
				Game.ME.cancelClick();
			}
			else
				Game.ME.onMouseUp(e);
		}
		i.onWheel = Game.ME.onWheel;
		g.add(i);

		return g;
	}


	inline function get_shotel() return Game.ME.shotel;

	override function onDispose() {
		super.onDispose();

		money.g.dispose();
		gems.g.dispose();
		love.g.dispose();
		//fame.g.dispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		money = null;
		love = null;
		gems = null;
		//fame = null;
		#if( debug || !prod )
		debug.dispose();
		debug = null;
		#end

		if( CURRENT==this )
			CURRENT = null;
	}

	public function updateInfos() {
		money.tf.text = Game.ME.prettyNumber(shotel.money);
		//money.moreInt.visible = money.moreIcon.visible = !Game.ME.isVisitMode();

		gems.tf.text = Game.ME.prettyNumber(shotel.gems);
		gems.g.visible = shotel.featureUnlocked("gems");
		//gems.moreInt.visible = gems.moreIcon.visible = shotel.featureUnlocked("gems") && !Game.ME.isVisitMode();

		var hasLove = shotel.featureUnlocked("love");
		love.tf.text = Game.ME.prettyNumber(shotel.love);
		love.g.visible = hasLove;
		loveFull.visible = hasLove && shotel.love>=shotel.getMaxLove();
		loveFull.x = love.tf.x + love.tf.textWidth*love.tf.scaleX + 5;
		loveFull.y = love.tf.y + love.tf.textHeight*love.tf.scaleY*0.5 - loveFull.textHeight*loveFull.scaleY*0.5;
		//love.moreInt.visible = love.moreIcon.visible = hasLove && !Game.ME.isVisitMode();

		//fame.tf.text = Game.ME.prettyNumber(shotel.fame);

		#if( (debug || !prod) && !trailer )
		var d = com.GameData.getClientStayDuration( C_Liker, shotel );
		var d = DateTools.parse(d);
		var duration = Lib.leadingZeros(d.hours)+"h "+Lib.leadingZeros(d.minutes)+"m "+Lib.leadingZeros(d.seconds)+"s";
		var bt = shotel.getTask(InternalSetFlag("bossLock",false));
		var vt = shotel.getTask(InternalSetFlag("vipCd",false));
		debug.text =
			"level="+shotel.level
			+" duration="+duration
			+" boss=[cd="+shotel.bossCd+",t="+(bt==null?Lang.untranslated("--"):Game.ME.prettyTime(bt.end))+"]"
			+" hosted="+shotel.countHostedClients()
			+" installed="+shotel.getStat("install")
			+" vipLock=[cd="+shotel.getStat("vipLock")+",t="+(vt==null?Lang.untranslated("--"):Game.ME.prettyTime(vt.end))+"]";
		#end

		onResize();
	}

	override function onResize() {
		super.onResize();

		var wid =
			money.wid + margin +
			(!gems.g.visible ? 0 : gems.wid+margin) +
			(!love.g.visible ? 0 : love.wid+margin);
		wid-=margin;

		var max = w()*0.6;
		if( wid<max )
			root.setScale( Main.getScale(55, hcm()>=10 ? 0.8 : 0.48) );
		else
			root.setScale( max/wid );
		root.x = w()*0.5 - wid*root.scaleX*0.5;
	}


	public function shakeGold(?d) shake( money, "yellow", d );
	public function shakeGem(?d) shake( gems, "blue", d );
	public function shakeLove(?d) shake( love, "red", d );

	function shake(e:StatusField, col:String, ?duration=1.0) {
		if( Game.ME.isVisitMode() )
			return;

		var pow = 1.0;
		createChildProcess(
			function(p) {
				e.g.y = baseY + rnd(4,8)*(itime%2==0?1:-1)*pow;
				pow-=0.03/duration;
				if( pow<=0.05 )
					p.destroy();
			},
			function(p) {
				e.g.y = baseY;
			}
		);

		//Game.ME.uiFx.mainStatusCounter(col, s.x, s.y-s.height*0.5, s.width, s.height); // TODO
	}

	override function update() {
		super.update();

		if( hcm()<9 ) {
			if( isVisible && ui.Tip.CURRENT!=null ) {
				isVisible = false;
				tw.create(root.y, -65*root.scaleX, 200);
			}
			if( !isVisible && ui.Tip.CURRENT==null ) {
				isVisible = true;
				tw.create(root.y, 0, 150);
			}
		}
	}
}
