import mt.flash.Volatile;
import flash.text.TextField;
import mt.deepnight.Tweenie;

typedef BuildSave = {
	speed	: Int,
	front	: Int,
	back	: Int,
	up		: Int,
	down	: Int,
	capture	: Int,
}
typedef PlayerState = {
	v : Int,
	m : Int,
	b : BuildSave,
}

class PlayerBuild implements haxe.Public {
	public static var WMAX = api.AKApi.const(8);
	public static var SMAX = api.AKApi.const(5);
	//static var P_FRONT = api.AKApi.aconst([20,	30,	50,	50,	50,	50,	50,	50,	]);
	
	var speed		: Volatile<Int>;
	var front		: Volatile<Int>;
	var back		: Volatile<Int>;
	var up			: Volatile<Int>;
	var down		: Volatile<Int>;
	var capture		: Volatile<Int>;
	
	public function new() {
		speed = 0;
		front = 0;
		back = 0;
		up = 0;
		down = 0;
		capture = 0;
	}
	
	public function save() : BuildSave {
		return {
			speed	: speed,
			front	: front,
			back	: back,
			up		: up,
			down	: down,
			capture	: capture,
		}
	}
	
	public function load(d:BuildSave) {
		if( d==null )
			return;
		speed = d.speed;
		front = d.front;
		back = d.back;
		up = d.up;
		down = d.down;
		capture = d.capture;
		check();
	}
	
	public function toString() {
		return
			"front:"+front+", "+
			"back:"+back+", "+
			"up:"+up+", "+
			"down:"+down+", "+
			"capture:"+capture+", "+
			"speed:"+speed;
	}
	
	public function getNextCost() {
		var total = speed + front + back + up + down + capture;
		return total==0 ? 15 : Math.round( (50 + Math.pow(total, 1.5)*5.5) / 10 )*10;
		//return total==0 ? 15 : 50 + (total) * 20;
	}

	public function check() {
		if( speed>SMAX.get() ) speed = SMAX.get();
		
		var m = WMAX.get();
		if( front>m ) front = m;
		if( back>m ) back = m;
		if( up>m ) up = m;
		if( down>m ) down = m;
		if( capture>m ) capture = m;
	}
}

class Player extends Entity {
	static var UBER_DURATION = api.AKApi.const(120);
	
	public var mc			: lib.Charlotte;
	var warning				: flash.display.Bitmap;
	
	public var lifeCont		: flash.display.Sprite;
	var lifeIcons			: Array<flash.display.Sprite>;
	public var money(default,setMoney)	: Volatile<Int>;
	public var moneyCounter	: {wrapper:flash.display.Sprite, field:TextField};
	var scrollDeath			: Int;
	var playerAnim			: String;
	var normalRadius		: Volatile<Float>;
	var ellon				: Null<lib.Ellon>;
	
	var hud					: flash.display.Sprite;
	
	public var build		: PlayerBuild;
	
	public function new() {
		lifeIcons = new Array();
		lifeCont = new flash.display.Sprite();

		super();
		
		hud = new flash.display.Sprite();
		hud.addChild(lifeCont);
		
		applyBuild( new PlayerBuild() );
		game.sdm.add(spr, Game.DP_PLAYER);

		color = 0xD55BFD;
		frictX = frictY = 0.85;
		radius = 20;
		scrollBounce = true;
		followScroll = true;
		collides = true;
		setPos(5, 5);
		pullPower = 0.5;
		speed = 0.02;
		scrollDeath = 0;
		normalRadius = radius;

		//game.addChild(lifeCont);
		//lifeCont.x = Game.WID;
		lifeCont.filters = [
			new flash.filters.DropShadowFilter(3,-120, 0x0,0.5, 8,8,1, 1,true),
			new flash.filters.GlowFilter(0xffffff,0.2, 2,2,5, 1,true),
		];
		
		initLife( game.isProgression() ? 3 : 2 );
		#if (dev && debug)
		initLife(1000);
		//collides = false;
		#end
		
		var wspr = new flash.display.Sprite();
		var m = new flash.geom.Matrix();
		m.createGradientBox(Game.WID, Game.HEI);
		wspr.graphics.beginGradientFill(flash.display.GradientType.RADIAL, [0xC10000, 0xC10000], [0,0.7], [128,255], m);
		wspr.graphics.drawRect(0,0, Game.WID, Game.HEI);
		wspr.width+=200;
		wspr.height+=200;
		wspr.x-=100;
		wspr.y-=100;
		var tf = game.createField(Lang.Danger, true);
		wspr.addChild(tf);
		tf.scaleX = tf.scaleY = 2;
		tf.textColor = 0xC10000;
		tf.alpha = 0.7;
		tf.x = Std.int( Game.WID*0.5 - tf.textWidth*tf.scaleX*0.5 );
		tf.y = Std.int( Game.HEI*0.5 - tf.textHeight*tf.scaleY*0.5 );
		warning = mt.deepnight.Lib.flatten(wspr);
		game.dm.add(warning, Game.DP_FX);
		warning.blendMode = flash.display.BlendMode.ADD;
		warning.alpha = 0;
		warning.visible = false;
		
		mc = new lib.Charlotte();
		mc.scaleX = mc.scaleY = 0.75;
		mc.x = 6*mc.scaleX;
		mc.y = -4*mc.scaleY;
		mc.stop();
		spr.addChild(mc);
		
		// Compteur argent
		if( game.isProgression() ) {
			var wrap = new flash.display.Sprite();
			hud.addChild(wrap);
			wrap.x+=100;
			//game.dm.add(wrap, Game.DP_INTERF);
			var imc = new lib.Gold();
			imc.y = 9;
			imc.scaleX = imc.scaleY = 0.5;
			var icon = mt.deepnight.Lib.flatten( imc, 12, true);
			wrap.addChild(icon);
			icon.bitmapData.applyFilter( icon.bitmapData, icon.bitmapData.rect, new flash.geom.Point(0,0), new flash.filters.GlowFilter(0x641A00,1, 2,2,6) );
			icon.bitmapData.applyFilter( icon.bitmapData, icon.bitmapData.rect, new flash.geom.Point(0,0), new flash.filters.DropShadowFilter(6,90, 0x37164E,0.3, 4,4,1) );
			var tf = game.createField("000000", true);
			wrap.addChild(tf);
			tf.x = 14;
			tf.textColor = 0xFFCD20;
			tf.multiline = tf.wordWrap = false;
			tf.filters = [
				new flash.filters.GlowFilter(0x641A00,1, 4,4,6),
			];
			moneyCounter = {wrapper:wrap, field:tf};
			//api.AKApi.setStatusMC(moneyCounter.wrapper);
		}
		
		#if debug
		var mc = new flash.display.Sprite();
		mc.graphics.beginFill(0xFF0000, 1);
		mc.graphics.drawCircle(10,10,10);
		api.AKApi.setStatusMC(mc);
		mc.graphics.beginFill(0x0080FF, 1);
		mc.graphics.drawCircle(30,10,10);
		haxe.Timer.delay( function() {
			mc.graphics.beginFill(0x80FF00, 1);
			mc.graphics.drawCircle(50,10,10);
		}, 2000);
		Game.TW.create(mc, "y", mc.y+10, TLoop, 3000);
		#end
		
		money = 0;
		#if debug
		//money = 5000;
		#end
		
		setPlayerAnim();
		applyBuild( new PlayerBuild() );
		
		if( game.isProgression() && game.glevel==20 ) {
			ellon = new lib.Ellon();
			spr.addChild(ellon);
			ellon.scaleX = ellon.scaleY = 0.9;
		}
		
		api.AKApi.setStatusMC(hud);
	}
	
	public function setMoney(v:Int) {
		if( game.isLeague() )
			return 0;
		money = v;
		moneyCounter.field.width = 100;
		moneyCounter.field.text = Std.string(v);
		moneyCounter.field.width = moneyCounter.field.textWidth+8;
		//moneyCounter.wrapper.x = Std.int( Game.WID*0.5-moneyCounter.field.textWidth*0.5 + 8 );
		//moneyCounter.wrapper.y = 5;
		return money;
	}
	
	public function changeMoney(v:Volatile<Int>, ?from:Entity) {
		if( game.isLeague() )
			return;
		if( v>0 )
			game.wonMoney+=v;
		money+=v;
		if( from!=null )
			game.pop( from.rx, from.ry, ""+v );
		Game.TW.terminate(moneyCounter.wrapper);
		moneyCounter.wrapper.y += 5;
		Game.TW.create(moneyCounter.wrapper, "y", moneyCounter.wrapper.y-5, TElasticEnd, 300).fl_pixel = true;
	}
	
	public function loadState(s:PlayerState) {
		if( s!=null ) {
			// Mode LEVEL UP
			try {
				money = s.m;
				build.load( s.b );
				applyBuild();
			}
			catch(e:Dynamic) {
				trace("load:"+e);
			}
		}
		else {
			// Mode MISSION
			var r = api.AKApi.getLevel()/20;
			build.front = Math.round( r*PlayerBuild.WMAX.get() );
			var spread = mt.deepnight.Lib.randomSpread( Std.int(r*PlayerBuild.WMAX.get()*1.8), 3, PlayerBuild.WMAX.get() );
			build.up = spread[0];
			build.down = spread[1];
			build.back = spread[2];
			build.capture = Math.round( rseed.rand()*r*PlayerBuild.WMAX.get() );
			build.speed = Math.round( r*PlayerBuild.SMAX.get() );
			applyBuild();
		}
	}
	
	public function saveState() : PlayerState {
		var b = build.save();
		return {
			v : 1,
			m : money,
			b : b,
		}
	}
	
	public function applyBuild(?b:PlayerBuild) {
		if( b!=null )
			build = b;
		
		build.check();

		var v : Int = build.speed;
		switch( v ) {
			case 0 :
				speed = 0.026;
				frictX = frictY = 0.82;
			case 1 :
				speed = 0.031;
				frictX = frictY = 0.83;
			case 2 :
				speed = 0.037;
				frictX = frictY = 0.82;
			case 3 :
				speed = 0.048;
				frictX = frictY = 0.80;
			case 4 :
				speed = 0.058;
				frictX = frictY = 0.73;
			case 5 :
				speed = 0.075;
				frictX = frictY = 0.70;
		}
		
		bullet.Heart.clearCache();
	}
	
	public function shoot() {
		var gap = 2.0;
		var pt = getPoint();
		if( !hasCD("shootFront") ) {
			setCD( "shootFront", 14 );
			var v = build.front;
			var range = 300; // + v*7;
			var n = (v>=8 ? 2 : 1);
			for( i in 0...n ) {
				var b = new bullet.Heart(0, range, v);
				b.yr += gap*i/n - gap*(n-1)*0.25;
			}
		}
			
		if( !hasCD("shootBack") ) {
			setCD( "shootBack", 14 );
			var v = build.back;
			var range = 250 + v*6;
			var n = (v>=4 ? 2 : 1);
			for( i in 0...n ) {
				var b = new bullet.Heart(3.14, range, v);
				b.yr += gap*i/n - gap*(n-1)*0.5;
			}
		}
		
		if( !hasCD("shootUp") && build.up>0 ) {
			setCD( "shootUp", 14 );
			var v = build.up;
			var range = 150 + v*6;
			var n = (v>=6 ? 2 : 1);
			for( i in 0...n ) {
				var b = new bullet.Heart(-1.57, range, v);
				b.xr += gap*i/n - gap*(n-1)*0.5;
			}
		}
		
		if( !hasCD("shootDown") && build.down>0 ) {
			setCD( "shootDown", 14 );
			var v = build.down;
			var range = 200 + v*6;
			var n = (v>=6 ? 2 : 1);
			for( i in 0...n ) {
				var b = new bullet.Heart(1.57, range, v);
				b.xr += gap*i/n - gap*(n-1)*0.5;
			}
		}
	}
	
	public override function toString() { return "Player#"+uid; }
	
	public override function setLife(v) {
		super.setLife(v);
		
		if( lifeIcons.length!=maxLife ) {
			for(icon in lifeIcons)
				icon.parent.removeChild(icon);
			lifeIcons = new Array();
			for(i in 0...Std.int(Math.min(5, maxLife))) {
				var icon = new lib.Life();
				lifeCont.addChild(icon);
				lifeIcons.push(icon);
				icon.x = 10 + i*18;
				icon.y = 11;
				icon.scaleX = icon.scaleY = 0.75;
			}
		}
		
		for(i in 0...lifeIcons.length) {
			if( i+1>life ) {
				lifeIcons[i].filters = [ mt.deepnight.Color.getSaturationFilter(-1) ];
				lifeIcons[i].alpha = 0.5;
			}
			else {
				lifeIcons[i].filters = [];
				lifeIcons[i].alpha = 1;
			}
		}
		//
		//while( lifeIcons.length<v && lifeIcons.length<5 ) {
			//var icon = new lib.Life();
			//lifeCont.addChild(icon);
			//icon.x = - 12 -lifeIcons.length*22;
			//icon.y = 12;
			//lifeIcons.push(icon);
		//}
		//
		//while( lifeIcons.length>v ) {
			//var icon = lifeIcons.splice( lifeIcons.length-1, 1 )[0];
			//icon.parent.removeChild(icon);
		//}
		return life;
	}
	
	public override function onDie() {
		super.onDie();
		fx.playerDeath();
		game.gameOver(false);
	}
	
	public function setPlayerAnim(?k="wait") {
		if( hasCD("uber") )
			return;
		mc.stop();
		playerAnim = k;
		if( k!="wait" && mc.currentFrameLabel=="wait" )
			mc.gotoAndStop(k);
	}
	
	public override function hit(p, ?from) {
		if( game.ended || hasCD("shield") )
			return;
			
		super.hit(p, from);
		
		// Overkill !
		//if( !dead() ) {
			//for( e in game.enemies )
				//if( e.onScreen )
					//e.kill();
					//
			//for( e in game.bullets )
				//e.destroy();
		//}
		
		if( from!=null )
			fx.explodeLight(this, from.color);
		shield();
	}
	
	public function uber() {
		setPlayerAnim("big");
		setCD("uber", 30*20);
		clearCD("shield");
		radius = 65;
	}
	
	public function endUber() {
		setPlayerAnim();
		radius = normalRadius;
		shield();
	}
	
	public inline function shield() {
		setCD("shield", 30*3);
	}
	
	public inline function rainbowTail() {
		//if( hasCD("uber") ) {
			//var pt = getScreenPoint();
			//pt.x = Std.int( pt.x/Game.RAINBOW_SCALE ) + mt.deepnight.Lib.rnd(0,6,true);
			//pt.y = Std.int(pt.y/Game.RAINBOW_SCALE) + mt.deepnight.Lib.rnd(0,3,true);
			//game.rainbow.bitmapData.fillRect( new flash.geom.Rectangle(pt.x, pt.y, 2,2), mt.deepnight.Color.addAlphaChannel(0xFFBF00) );
		//}
		if( game.perf>=0.7 ) {
			var s = build.speed;
			if( hasCD("uber") )
				s = 8;
			var pt = getScreenPoint();
			pt.x = Std.int(pt.x/Game.RAINBOW_SCALE);
			pt.y = Std.int(pt.y/Game.RAINBOW_SCALE);
			if( s>=3 ) {
				var mc = new lib.Rainbow();
				var m = new flash.geom.Matrix();
				if( hasCD("uber") )
					m.scale(1.5/Game.RAINBOW_SCALE, 1.3/Game.RAINBOW_SCALE);
				else
					m.scale(1/Game.RAINBOW_SCALE, 0.7*1/Game.RAINBOW_SCALE);
				m.rotate( Math.atan2(dy, dx) );
				m.translate(pt.x, pt.y);
				var ct = new flash.geom.ColorTransform();
				ct.alphaMultiplier = s/5;
				game.rainbow.bitmapData.draw( mc, m, ct );
			}
			else if( s>=1 ) {
				game.rainbow.bitmapData.fillRect( new flash.geom.Rectangle(pt.x, pt.y, 2,2), s==1 ? 0xffFF80FF : 0xffFFAE40 );
			}
		}
	}
	
	override function onCD(k) {
		super.onCD(k);
		if( k=="shield" )
			spr.alpha = 1;
		if( k=="uber" )
			endUber();
	}
	
	
	override public function update() {
		super.update();
		if( !onScreen ) {
			warning.visible = true;
			warning.alpha-=0.03;
			if( warning.alpha<0.7 )
				warning.alpha = 1;
			if( scrollDeath++ >= 50 )
				kill();
		}
		else {
			if( warning.visible ) {
				warning.alpha -= 0.04;
				if( warning.alpha<=0 )
					warning.visible = false;
			}
			scrollDeath = 0;
		}
		
		// Animation
		if( mc.currentFrameLabel!=playerAnim ) {
			for(i in 0...(playerAnim!="wait" ? 4 : 2))
				mc._smc.prevFrame();
			if( mc._smc.currentFrame==1 ) {
				mc.gotoAndStop(playerAnim);
				mc._smc.stop();
			}
		}
		else
			mc._smc.nextFrame();
			
		// Bouclier
		var shield = hasCD("shield");
		if( shield )
			spr.alpha = game.time%3==0 ? 1 : 0.4;
		if( shield && game.time%2==0 )
			spr.blendMode = flash.display.BlendMode.ADD;
		else
			spr.blendMode = flash.display.BlendMode.NORMAL;
			
		// Boutique
		var r = getRoom();
		if( r!=null && !game.shopping && r.shop!=null ) {
			var pt = r.globalToLocal(cx,cy);
			if( Math.abs(r.shop.cx-pt.cx) <= 1.5 && pt.cy>=r.shop.cy-2 && pt.cy<=r.shop.cy )
				game.enterShop();
		}
		
		// Mode uber
		if( hasCD("uber") ) {
			spr.scaleX = 1 + Math.cos(uid+game.time*0.1*3.14) * 0.03;
			spr.scaleY = 1 + Math.sin(uid+game.time*0.07*3.14) * 0.02;
			if( mc._smc.currentFrame==mc._smc.totalFrames ) {
				var charlotte : flash.display.MovieClip = Reflect.field(mc._smc, "_smc");
				charlotte.rotation+=dy*40;
				charlotte.rotation*=0.8;
			}
			fx.uber();
		}
		
		// Sauvez Ellon !
		if( ellon!=null ) {
			var a = 2.5 + dy*3;
			ellon.x = Math.cos(a)*40 + Math.cos(game.time*0.047*3.14)*2 - dx*100;
			ellon.y = Math.sin(a)*30 + Math.cos(game.time*0.03*3.14)*6;
			ellon.rotation = mt.deepnight.Lib.deg(a)-110;
		}
		
		mc.rotation*=0.9;
		
		if( game.perf>=0.7 && ( dx!=0 || dy!=0 ) )
			rainbowTail();
	}
}