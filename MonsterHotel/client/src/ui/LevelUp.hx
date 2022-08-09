package ui;

import mt.MLib;
import com.Protocol;
import com.*;
import com.GameData;
import mt.deepnight.Tweenie;

class LevelUp extends H2dProcess {
	public var ctrap		: h2d.Interactive;
	public var wrapper		: h2d.Sprite;
	public var elements		: Array<h2d.Sprite>;

	var wid					: Int;
	var iWid				: Int;
	var shotel(get,never)	: SHotel; inline function get_shotel() return Game.ME.shotel;

	public function new(lvl:Int) {
		super();
		Game.ME.pause();

		Main.ME.uiWrapper.add(root, Const.DP_POP_UP);

		elements = [];
		name = 'LevelUp';
		iWid = 90;
		wid = 650;

		ctrap = new h2d.Interactive(8,8,root);
		ctrap.backgroundColor = alpha(Const.BLUE, 0.93);
		ctrap.onClick = onClose;
		ctrap.alpha = 0;
		tw.create(ctrap.alpha, 1, 700);

		wrapper = new h2d.Sprite(root);

		//var s = new h2d.Sprite(wrapper);
		//elements.push(s);
		//var tf = new h2d.Text(Assets.fontNormal, s);
		//tf.text = Lang.t._("Congratulations!");
		//tf.textColor = 0xFF9B06;
		//tf.scale(0.75);
		//tf.filter = true;
		//tf.maxWidth = maxWid;
		//tf.x = Std.int( maxWid*0.5 - tf.width*0.5*tf.scaleX );

		// Title
		//var s = new h2d.Sprite(wrapper);
		//elements.push(s);
		//var tf = new h2d.Text(Assets.fontHuge, s);
		//tf.text = Lang.t._("You reached level ::n::!!", {n:lvl});
		//tf.filter = true;
		//tf.scale( (maxWid-20) / (tf.width*tf.scaleX) );

		addSeparator();

		var n = 0;
		// New rooms
		for(e in Type.getEnumConstructs(RoomType).map(function(k) return Type.createEnum(RoomType,k)) )
			if( !GameData.roomUnlocked(shotel, lvl-1, e) && GameData.roomUnlocked(shotel, lvl, e) ) {
				addRoom(e);
				n++;
			}

		// New clients
		for(e in Type.getEnumConstructs(ClientType).map(function(k) return Type.createEnum(ClientType,k)) )
			if( !GameData.clientUnlocked(lvl-1, e) && GameData.clientUnlocked(lvl, e) ) {
				addClient(e);
				n++;
			}


		// New feature
		for(id in GameData.FEATURES.keys())
			if( GameData.FEATURES.get(id)==shotel.level ) {
				switch( id ) {
					case "custom" :
						addFeature( "iconPaint", Lang.t._("Customization"), Lang.t._("You can now customize your bedrooms!") );

					case "miniGame" :
						addFeature( "moneyGold", Lang.t._("Theft"), Lang.t._("You can now steal money from your clients!") );

					//case "upgradeLobby" :
						//addFeature( "iconLvlUp", Lang.t._("Lobby upgrade"), Lang.t._("You can now upgrade your Lobby!") );

					case "love" :
						addFeature( "moneyLove", Lang.t._("The power of love"), Lang.t._("You can now use the terrific power of Love!") );

					default :
				}
			}

		// Gems
		//var n = GameData.getLevelUpGems(lvl);
		//if( n>0 ) {
			//var s = new h2d.Sprite(wrapper);
			//elements.push(s);
			//var tf = new h2d.Text(Assets.fontHuge, s);
			//tf.text = "+"+n;
			//tf.textColor = Const.TEXT_GEM;
			//tf.scale(0.7);
			//tf.filter = true;
			//tf.y = -4;
			//var i = Assets.tiles.getH2dBitmap("moneyGem", true, s);
			//i.scale(1);
			//i.x = tf.width*tf.scaleX + 10;
			//s.x = Std.int( maxWid*0.5 - s.width*0.5 );
		//}

		addSeparator();

		SoundMan.ME.lowerMusic();

		cd.set("click", Const.seconds(2));
		rebuild();
		onResize();
	}

	function onClose(e:hxd.Event) {
		if( destroyed || cd.has("click") )
			return;

		destroy();
		Game.ME.resume();
	}

	function addSeparator() {
		var s = Assets.tiles.getH2dBitmap("popUpTop", wrapper);
		elements.push(s);
		s.width = wid+60;
		s.tile.setCenter(30, 0);
	}

	function addRoom(t:RoomType) {
		var s = new h2d.Sprite(wrapper);
		elements.push(s);

		var icon = Assets.tiles.getH2dBitmap(Assets.getRoomIconId(t));
		s.addChild(icon);
		icon.setScale( MLib.fmin(iWid/icon.width, iWid/icon.height) );
		icon.x = iWid*0.5 - icon.width*0.5;
		icon.y = iWid*0.5 - icon.height*0.5;
		halo(s);

		var tw = new h2d.Sprite(s);

		var tf = Assets.createText(18, tw);
		tf.text = Lang.t._("New room unlocked!");
		tf.x = Std.int( iWid+20 );
		tf.textColor = 0xFFC600;

		var tf = Assets.createText(50, tw);
		tf.text = mt.Utf8.uppercase( mt.Utf8.removeAccents(Lang.getRoom(t).name) );
		tf.x = Std.int( iWid+20 );
		tf.y = 20;
		tf.textColor = 0xFFFFFF;

		var tf = Assets.createText(24, tw);
		tf.text = Lang.getRoom(t).role;
		tf.x = Std.int( iWid+20 );
		tf.y = 70;
		tf.maxWidth = (wid-tf.x)/tf.scaleX;
		tf.textColor = 0xA29ED6;

		tw.y = Std.int(iWid*0.5 - tw.height*0.5);
	}

	function addClient(t:ClientType) {
		var s = new h2d.Sprite(wrapper);
		elements.push(s);

		var icon = Assets.getClientIcon(t,s);
		icon.setScale( MLib.fmin(iWid/icon.width, iWid/icon.height) );
		icon.x = iWid*0.5 - icon.width*0.5;
		icon.y = iWid*0.5 - icon.height*0.5;
		halo(s);

		var tw = new h2d.Sprite(s);
		tw.x = Std.int( iWid + 20 );

		var tf = Assets.createText(18, name, tw);
		tf.text = Lang.t._("New client unlocked!");
		tf.textColor = 0xFFC600;

		var cinf = Lang.getClient(t, shotel);
		var tf = Assets.createText(50, tw);
		tf.text = mt.Utf8.uppercase( mt.Utf8.removeAccents(cinf.name) );
		tf.y = 20;
		tf.textColor = 0xFFFFFF;

		var d = cinf.desc;
		if( d!=null ) {
			var tf = Assets.createText(24, d, tw);
			tf.y = 70;
			tf.maxWidth = (wid-tw.x)/tf.scaleX;
			tf.textColor = 0xA29ED6;
		}

		tw.y = Std.int(iWid*0.5 - tw.height*0.5);
	}


	function addFeature(iconId:String, name:String, desc:String) {
		var s = new h2d.Sprite(wrapper);
		elements.push(s);

		var icon = Assets.tiles.getH2dBitmap(iconId,0, true, s);
		icon.setScale( MLib.fmin(iWid/icon.width, iWid/icon.height) );
		icon.x = iWid*0.5 - icon.width*0.5;
		icon.y = iWid*0.5 - icon.height*0.5;
		halo(s);

		var tw = new h2d.Sprite(s);
		tw.x = Std.int( iWid + 20 );

		var tf = Assets.createText(18, Lang.t._("New skill unlocked!"), tw);
		tf.textColor = 0xFFC600;

		var tf = Assets.createText(50, name, tw);
		tf.textColor = 0xFFFFFF;
		tf.y = 20;

		var tf = Assets.createText(24, desc, tw);
		tf.y = 70;
		tf.maxWidth = (wid-tw.x)/tf.scaleX;
		tf.textColor = 0xA29ED6;

		tw.y = Std.int(iWid*0.5 - tw.height*0.5);
	}


	function halo(parent:h2d.Sprite, ?scale=0.8) {
		var x = iWid*0.5;
		var y = iWid*0.5;
		var off = rnd(0,60);
		delayer.add( function() {
			var s1 = Assets.tiles.getH2dBitmap("fxSunshine",0, 0.5,0.5, true);
			parent.addChildAt(s1,0);
			s1.blendMode = Add;
			s1.setPos(x,y);
			s1.alpha = 0;
			tw.create(s1.alpha, 0.6, 400);

			var s2 = Assets.tiles.getH2dBitmap("fxSunshine",0, 0.5,0.5, true);
			parent.addChildAt(s2,0);
			s2.blendMode = Add;
			s2.setPos(x,y);
			s2.alpha = 0;
			tw.create(s2.alpha, 0.6, 400);

			createChildProcess(
				function(_) {
					s1.rotate(0.006);
					s1.scaleX = s1.scaleY = scale*1.4 + Math.sin((off+ftime)*0.1)*0.15;

					s2.rotate(-0.004);
					s2.scaleX = s2.scaleY = scale*1.5 + Math.cos((off+ftime)*0.08)*0.15;
				},
				function (_) {
					s1.dispose();
					s2.dispose();
				},
				true
			);
		}, 200);
	}


	function rebuild() {
		var y = 0.;
		var i = 0;
		for(e in elements) {
			e.x = w();
			var j = i;
			delayer.add( function() {
				tw.create(e.x, 0, 500).end( function() {
					if( j!=0 && j!=elements.length-1 )
						Assets.SBANK.happy(1);
				});
			}, i*300);
			e.y = y;
			y+=e.height+60;
			i++;
		}

		onResize();

		var y = wrapper.y;
		wrapper.y = h();
		tw.create(wrapper.y, y, 200);
	}


	override function onResize() {
		super.onResize();

		if( wrapper!=null ) {
			wrapper.setScale( Main.getScale(wid,6) );
			wrapper.x = Std.int( w()*0.5 - wid*wrapper.scaleX*0.5 );
			wrapper.y = Std.int( h()*0.5 - wrapper.height*0.5 );

			ctrap.width = w();
			ctrap.height = h();
		}
	}


	override function onDispose() {
		super.onDispose();

		ctrap.dispose();
		ctrap = null;

		wrapper.dispose();
		wrapper = null;

		for(e in elements)
			e.dispose();
		elements = null;

		SoundMan.ME.restoreMusic();
	}
}