package m;

import flash.display.*;
import mt.deepnight.Color;
import mt.deepnight.mui.Window;
import mt.deepnight.Lib;
import mt.deepnight.FParticle;
import mt.deepnight.slb.*;
import mt.MLib;
import mt.Metrics;
import ui.*;
import TeamInfos;
import Const;

class MatchIntro extends MenuBase {
	var clickTrap	: Sprite;
	var team		: TeamInfos;
	var variant		: GameVariant;
	var teamName	: Bitmap;
	var objective	: Bitmap;
	var face		: Bitmap;
	var cup			: Null<Bitmap>;
	var plist		: Array<Bitmap>;

	public function new(t:TeamInfos, v:GameVariant) {
		super();

		gaPageName = null;
		plist = [];
		team = t;
		variant = v;

		// Team name
		var tf = Global.ME.createField(team.name, FBig, true);
		tf.textColor = 0xFFFF00;
		tf.filters = [
			new flash.filters.DropShadowFilter(3,90, 0xFFFF84,1, 0,0,1, 1,true),
			new flash.filters.DropShadowFilter(1,90, 0xE15A00,1, 0,0),
			new flash.filters.GlowFilter(0x420F00,1, 2,2,8),
		];
		teamName = Lib.flatten(tf);
		teamName.bitmapData = Lib.scaleBitmap(teamName.bitmapData, 4, true);
		wrapper.addChild(teamName);

		// Objective
		var str = team.getScoreTarget()>1 ? Lang.ObjectiveN({_goals:team.getScoreTarget()}) : Lang.Objective1;
		if( team.isFinal() )
			str = Lang.FinalObjective({ _goals:team.getScoreTarget() });
		var tf = Global.ME.createField(str, FBig, true);
		tf.textColor = 0xFFBF00;
		tf.filters = [
			new flash.filters.GlowFilter(0x420F00,1, 2,2,8),
		];
		objective = Lib.flatten(tf);
		objective.bitmapData = Lib.scaleBitmap(objective.bitmapData, 2, true);
		wrapper.addChild(objective);
		objective.alpha = 0;
		tw.create(objective.alpha, 1, 300);

		// Face
		face = new Bitmap( new BitmapData(60,60,true, 0x0) );
		wrapper.addChild(face);
		tiles.drawIntoBitmap(face.bitmapData, 21,23, "bouille");
		tiles.drawIntoBitmap(face.bitmapData, 0,0, "hairCuts", team.hairFrame);
		face.bitmapData.applyFilter(face.bitmapData, face.bitmapData.rect, new flash.geom.Point(), new flash.filters.DropShadowFilter(4,90, 0x0,0.3, 0,0) );
		face.y = -15;
		face.bitmapData = Lib.scaleBitmap(face.bitmapData, 2, true);

		// Perk list
		var perks : Array<{prio:Int, str:String}> = [];
		var phash = new Map();
		for(p in team.getPerks()) {
			var k = Std.string(p).substr(1);
			if( !Lang.ALL.exists(k) )
				continue;

			if( !team.hasPerk(p) ) // variant special case
				continue;

			var str = Lang.ALL.get(k);
			if( phash.exists(str) )
				continue;
			phash.set(str, true);

			var meta = Reflect.field(haxe.rtti.Meta.getFields(Perk), Std.string(p));
			var prio = meta==null ? 0 : Std.parseInt(Reflect.field(meta, "prio")[0]);
			if( Math.isNaN(prio) )
				prio = 0;

			perks.push({ prio:prio, str:str });
		}
		perks.sort( function(a,b) {
			if( a.prio!=b.prio )
				return -Reflect.compare(a.prio, b.prio);
			else
				return Reflect.compare(a.str, b.str);
		});
		perks.splice(4,999);
		var i = 0;
		for(p in perks) {
			var tf = Global.ME.createField(p.str, FBig, true);
			tf.textColor = 0xFFFFFF;
			tf.filters = [
				new flash.filters.GlowFilter(0x2E303D,1, 2,2,8),
			];
			var bmp = Lib.flatten(tf);
			bmp.bitmapData = Lib.scaleBitmap(bmp.bitmapData, 2, true);
			wrapper.addChild(bmp);
			bmp.alpha = 0;
			delayer.add( function() {
				tw.create(bmp.alpha, 1, 300);
			}, (i+1)*300);
			plist.push(bmp);
			i++;
		}


		// Cup final
		if( team.isFinal() && tiles.exists("cup", team.getCupId()) ) {
			var bd = tiles.getBitmapData("cup", team.getCupId());
			//var bd = Lib.upscaleBitmap(bd, 2, true);
			cup = new Bitmap(bd);
			wrapper.addChild(cup);
		}


		// Click trap
		clickTrap = new Sprite();
		wrapper.addChild(clickTrap);
		clickTrap.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, function(_) onContinue() );

		new BackButton(wrapper, onBack);

		onResize();
	}


	override function unregister() {
		super.unregister();

		face.bitmapData.dispose(); face.bitmapData = null;
		objective.bitmapData.dispose(); objective.bitmapData = null;
		teamName.bitmapData.dispose(); teamName.bitmapData = null;
		if( cup!=null ) {
			cup.bitmapData.dispose();
			cup.bitmapData = null;
		}

		for(bmp in plist) {
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
		}
		plist = null;
	}

	function onBack() {
		Global.SBANK.UI_back(1);
		if( team.isCustom )
			Global.ME.run(this, function() new CustomMatch(), false);
		else
			Global.ME.run(this, function() new StageSelect(team.lid), true);
	}

	function onContinue() {
		Global.ME.run(this, function() new Game(team, variant), true);
	}

	override function onResize() {
		super.onResize();

		if( plist==null )
			return;

		var w = getWidth();
		var h = getHeight();

		clickTrap.graphics.clear();
		clickTrap.graphics.beginFill(0x00FF00, 0);
		clickTrap.graphics.drawRect(0,0,w,h);

		teamName.x = Std.int(w*0.5-teamName.width*0.5);
		teamName.y = 60;
		objective.x = Std.int(w*0.5-objective.width*0.5);
		objective.y = Std.int(teamName.y+65);

		face.x = Std.int(w*0.5-face.width*0.5);
		face.y = 55-face.height*0.5;

		if( cup!=null ) {
			face.x-=30;
			cup.x = Std.int(w*0.5-cup.width*0.5+30);
			cup.y = 80-cup.height*0.5;
		}

		var i = 0;
		for(bmp in plist) {
			bmp.x = Std.int(w*0.5-bmp.width*0.5);
			bmp.y = Std.int(teamName.y+110 + i*26);
			i++;
		}
	}

	override function update() {
		super.update();

		if( cup!=null ) {
			fx.photoSparks(bg);
			fx.godLight();
			if( time%2==0 )
				fx.blingBling(cup.x, cup.y, 45, 50);
		}
	}
}