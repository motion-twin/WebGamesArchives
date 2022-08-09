package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import mt.deepnight.Color;
import mt.deepnight.mui.Window;
import mt.deepnight.mui.Group;
import mt.deepnight.mui.HGroup;
import mt.deepnight.Lib;
import mt.deepnight.Tweenie;
import mt.deepnight.FParticle;
import mt.deepnight.slb.*;
import mt.flash.Sfx;
import mt.MLib;
import mt.Metrics;
import ui.*;

class MatchEnd extends MenuBase {
	var victory		: Bool;
	var menu		: Group;
	var title		: Bitmap;
	var team		: TeamInfos;
	var darkness	: Null<Bitmap>;
	var boy			: Null<BSprite>;
	var cup			: Null<Bitmap>;
	var cupName		: Null<Bitmap>;
	var loop		: Null<Sfx>;
	var jingle		: Sfx;
	var stars		: Group;
	var starBg		: BSprite;

	public function new(team:TeamInfos, victory, starCount:Int) {
		super();
		this.victory = victory;
		this.team = team;

		//if( playerCookie.data.music )
			//Global.ME.startMusic();

		var v = Global.ME.hasMusic() ? 0.5 : 1;
		if( victory ) {
			Global.SBANK.public_but().playOnChannel(Crowd.CHANNEL, v);
			jingle = Global.SBANK.music_Jingle_victoire_master().playOnChannel(1);
		}
		else {
			loop = Global.SBANK.pluie_loop().playLoop();
			jingle = Global.SBANK.music_Jingle_defaite_master().playOnChannel(1);
		}

		if( !victory ) {
			darkness = new Bitmap( new BitmapData(300,200, true, Color.addAlphaF(0x181D30, 0.7)) );
			wrapper.addChild(darkness);
		}

		if( victory ) {
			// Boy
			boy = tiles.get("fafiBoy");
			wrapper.addChild(boy);
			boy.setCenter(0.5,0.5);
			boy.x = getWidth()*0.7;
			boy.y = getHeight();

			// Cup final
			if( team.isFinal() ) {
				// Cup
				var bd = tiles.getBitmapData("cup", team.getCupId());
				var bd = Lib.scaleBitmap(bd, 2, true);
				cup = new Bitmap(bd);
				wrapper.addChild(cup);


				// Cup name
				var str = StageSelect.getCupName(team.getCupId());
				var tf = Global.ME.createField(str, FBig, true);
				tf.textColor = 0xFFFF00;
				tf.filters = [
					new flash.filters.DropShadowFilter(3,90, 0xFFFF84,1, 0,0,1, 1,true),
					new flash.filters.DropShadowFilter(1,90, 0xE15A00,1, 0,0),
					new flash.filters.GlowFilter(0x420F00,1, 2,2,8),
				];
				cupName = Lib.flatten(tf);
				cupName.bitmapData = Lib.scaleBitmap(cupName.bitmapData, 2, true);
				wrapper.addChild(cupName);
				cupName.x = getWidth();
				delayer.add( function() {
					tw.create(cupName.x, Std.int(getWidth()*0.5-cupName.width*0.5), TEaseIn, 300).onEnd = function() {
						fx.flashBang(0xFFAC00, 0.7, 2000);
					}
				}, 600);
			}
		}

		// Title
		var str = (victory ? (team.isFinal() ? Lang.YouWinFinal : Lang.YouWin) : Lang.YouLose).toUpperCase();
		var tf = Global.ME.createField(str, FBig, true);
		if( team.isFinal() && victory ) {
			tf.textColor = 0xFFFF00;
			tf.filters = [
				new flash.filters.DropShadowFilter(3,90, 0xFFFF84,1, 0,0,1, 1,true),
				new flash.filters.DropShadowFilter(1,90, 0xE15A00,1, 0,0),
				new flash.filters.GlowFilter(0x420F00,1, 2,2,8),
			];
		}
		else if( victory ) {
			tf.textColor = 0xFFFFFF;
			tf.filters = [
				new flash.filters.DropShadowFilter(1,90, 0x5A6F8D,1, 0,0),
				new flash.filters.GlowFilter(0x0,1, 2,2,8),
			];
		}
		else {
			tf.textColor = 0xA6B3C6;
			tf.filters = [
				new flash.filters.DropShadowFilter(1,90, 0x485871,1, 0,0),
				new flash.filters.GlowFilter(0x0,0.6, 2,2,8),
			];
		}
		title = Lib.flatten(tf);
		title.bitmapData = Lib.scaleBitmap(title.bitmapData, 4, true);
		wrapper.addChild(title);


		if( victory ) {
			title.x = -title.width - 100;
			tw.create(title.x, Std.int(getWidth()*0.5-title.width*0.5), TEaseIn, 300).onEnd = function() {
				fx.flashBang(0xFFAC00, 0.7, 2000);
			}
		}
		else {
			title.x = -title.width - 100;
			tw.create(title.x, Std.int(getWidth()*0.5-title.width*0.5), TEaseIn, 300).onEnd = function() {
				fx.flashBang(0xFFAC00, 0.7, 800);
			}
		}


		// Stars
		starBg = tiles.get("starBigBg");
		wrapper.addChild(starBg);
		starBg.alpha = 0.9;
		stars = new HGroup(wrapper);
		stars.removeBorders();
		stars.margin = 1;
		if( victory )
			for(i in 0...Const.MAX_STARS) {
				var s = new Star(stars, this);
				if( i+1<=starCount )
					delayer.add(function() {
						s.activate();
						Global.SBANK.bumper(1);
						//if( i==Const.MAX_STARS-1 )
						if( starCount==Const.MAX_STARS )
							m.Global.SBANK.mine_explose(0.5);
					}, 500 + i*200);
			}
		starBg.visible = victory;


		//root.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, function(_) onContinue() );

		menu = new mt.deepnight.mui.HGroup(wrapper);
		menu.hide();
		delayer.add( function() {
			menu.show();
			onResize();
		}, victory ? 800 : 100 );
		menu.removeBorders();
		menu.margin = 10;
		var mode = switch( Global.ME.variant ) {
			case Normal : Lang.Normal;
			case Hard : Lang.Hard;
			case Epic : Lang.Epic;
		}
		if( victory && !team.isCustom ) {
			if( team.isFinal() ){
				new TwitterButton(menu, Lang.ShareCup({_team:team.name, _mode:mode, _cup:StageSelect.getCupName(team.getCupId())}) );
				new FacebookButton(menu, Lang.ShareMatchFacebook({_team:team.name, _n:team.lid}) );
			}
			else {
				new TwitterButton(menu, Lang.ShareMatch({_team:team.name, _mode:mode}) );
				new FacebookButton(menu, Lang.ShareMatchFacebook({_team:team.name, _n:team.lid}) );
			}
		}
		new SmallMenuButton(menu, Lang.Continue, onContinue);


		cd.set("confettis", Const.seconds(1));
		if( team.isCustom )
			gaPageName = "/app/game/custom";
		else if( victory )
			gaPageName = "/app/game/"+Global.ME.variant+"/"+team.lid+"/win";
		else
			gaPageName = "/app/game/"+Global.ME.variant+"/"+team.lid+"/lose";

		onResize();
	}


	override function unregister() {
		super.unregister();

		title.bitmapData.dispose(); title.bitmapData = null;
		menu.destroy();
		stars.destroy();

		if( boy!=null )
			boy.dispose();

		if( darkness!=null ) {
			darkness.bitmapData.dispose();
			darkness.bitmapData = null;
		}
		if( loop!=null )
			loop.stop();
	}

	override function onActivate() {
		super.onActivate();
		if( loop!=null )
			loop.playLoop();
	}
	override function onDeactivate() {
		super.onDeactivate();
		if( loop!=null )
			loop.stop();
	}

	function onContinue() {
		Global.SBANK.UI_select(1);
		jingle.fade(0,600).onEnd = function() {
			jingle.stop();
		}
		Global.ME.switchMusic_intro();

		if( team.isCustom )
			Global.ME.run(this, function() new CustomMatch(), false);
		else if( victory && team.lid==Const.FINAL_LEVEL )
			Global.ME.run(this, function() new EndGame(), true);
		else {
			if( victory && !playerCookie.data.unlockedHard && team.lid==20 ) {
				playerCookie.data.unlockedHard = true;
				playerCookie.save();
				Global.ME.run(this, function() new Unlocked(Lang.UnlockedHard), false);
			}
			#if !webDemo
			else if( !playerCookie.data.ratedUs && victory && team.lid%Const.MATCHES_BY_CUP==0 )
				Global.ME.run(this, function() new Rate(victory ? team.lid+1 : team.lid, victory), true);
			#end
			else
				Global.ME.run(this, function() new StageSelect(victory ? team.lid+1 : team.lid, victory), true);
		}
	}

	override function onResize() {
		super.onResize();

		if( title==null )
			return;

		var w = getWidth();
		var h = getHeight();

		stars.x = w*0.5-stars.getWidth()*0.5;
		stars.y = 1;
		starBg.x = stars.x-3;
		starBg.y = stars.y+2;

		menu.x = w*0.5-menu.getWidth()*0.5;
		menu.y = h-menu.getHeight()-5;

		if( darkness!=null ) {
			darkness.width = w;
			darkness.height = h;
		}

		if( cup!=null )
			cup.x = Std.int(w*0.35 - cup.width*0.5);
	}

	override function update() {
		super.update();

		// Photo sparks
		if( victory && time>Const.seconds(2) )
			fx.photoSparks(bg);

		// Win fx
		if( victory && !cd.has("confettis") )
			fx.confettis();
		if( !victory )
			fx.rain();

		if( victory )
			if( team.isFinal() )
				title.y = Std.int(getHeight()*0.75-title.height) + Math.cos(time*0.12)*6;
			else
				title.y = Std.int(getHeight()*0.85-title.height) + Math.cos(time*0.12)*6;
		else
			title.y = Std.int(getHeight()*0.5-title.height*0.5) + Math.cos(time*0.09)*5;

		if( cup!=null ) {
			fx.photoSparks(bg);
			fx.godLight();
			fx.blingBling(cup.x+10, cup.y+40, 70, 80);
			cup.y = Std.int(getHeight()*0.45 - cup.height*0.5) + Math.sin(time*0.12)*8;
			cupName.y = Std.int(getHeight()*0.75-25) + Math.cos(time*0.12)*6;
		}

		// Boy
		if( boy!=null ) {
			var s = 0.25;
			if( team.isFinal() )
				boy.x += (getWidth()*0.6-boy.x)*s;
			else
				boy.x += (getWidth()*0.5-boy.x)*s;
			boy.y += (getHeight()*0.46-boy.y)*s;
		}
	}
}