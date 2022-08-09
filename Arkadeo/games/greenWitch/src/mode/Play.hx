package mode;

import api.AKApi;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.ui.Keyboard;

import mt.deepnight.Delayer;
import mt.deepnight.Color;
import mt.deepnight.retro.SpriteLibBitmap;
import mt.deepnight.Sfx;
import mt.flash.Volatile;

import S;
import Const;
import TitleLogo;

@:bitmap("assets/tiles.png") class GfxTiles extends BitmapData {}
@:bitmap("assets/characters.png") class GfxCharacters extends BitmapData {}

class Play extends Mode {
	public static var ME	: Play;
	
	public var buffer		: mt.deepnight.Buffer;
	public var fx			: Fx;
	public var time			: Float;
	var clickStart			: Float;
	var castSuccessful		: Bool;
	var gameEnded			: Bool;
	public var cd			: mt.deepnight.Cooldown;
	var overEntity			: Null<Entity>;
	public var difficulty	: Volatile<Float>;
	public var delayer		: Delayer;
	public var hud			: Hud;
	public var miniMap		: Minimap;
	public var skill(default,null)	: mt.flash.Volatile<Float>;

	public var currentLevel	: Level;
	public var viewPort		: flash.geom.Rectangle;
	public var viewPortCase	: flash.geom.Rectangle;
	
	public var seed			: Int;
	var rseed				: mt.Rand;
	public var hero			: en.Hero;
	public var killList		: Array<Entity>;
	public var mobs			: Array<en.Mob>;
	public var mobCounts	: Hash<Int>;
	
	var scroller			: Sprite;
	public var dm			: mt.DepthManager;
	public var sdm			: mt.DepthManager;
	
	public var tiles		: SpriteLibBitmap;
	public var char			: SpriteLibBitmap;
	
	public var inactivity	: Int;
	
	var kpoints				: Array<List<api.AKProtocol.SecureInGamePrizeTokens>>;
	

	public function new() {
		try { // HACK ------------------------------
		super();
		#if debug
		trace("---");
		#end
		
		var raw = haxe.Resource.getString(api.AKApi.getLang());
		if( raw==null ) raw = haxe.Resource.getString("en");
		Lang.init(raw);

		inactivity = 0;
		mobCounts = new Hash();
		ME = this;
		clickStart = -1;
		difficulty = 0;
		time = 0;
		buffer = Game.ME.buffer;
		root = Game.ME;
		mobs = new Array();
		killList = new Array();
		seed = AKApi.getSeed();
		castSuccessful = false;
		cd = new mt.deepnight.Cooldown();
		delayer = new Delayer();
		skill = 0;
		addSkill(-999); // init à la valeur min
		gameEnded = false;
		kpoints = new Array();

		rseed = new mt.Rand(0);
		rseed.initSeed(seed);
		} catch(e:Dynamic) { throw "ERR1 "+e; } // HACK ------------------------------
	
		try { // HACK ------------------------------
		dm = new mt.DepthManager(root);
		scroller = new Sprite();
		buffer.dm.add(scroller, Const.DP_SCROLLER);
		sdm = new mt.DepthManager(scroller);
		viewPort = new flash.geom.Rectangle(0,0,buffer.width, buffer.height);
		viewPortCase = new flash.geom.Rectangle(0,0, Math.ceil(buffer.width/Const.GRID)+6, Math.ceil(buffer.height/Const.GRID)+5);
		} catch(e:Dynamic) { throw "ERR2 "+e; } // HACK ------------------------------
		
		// Sets de décor
		try { // HACK ------------------------------
		tiles = new SpriteLibBitmap( new GfxTiles(0,0) );
		var g = Const.GRID;
		tiles.setSliceGrid(Const.GRID, Const.GRID);
		tiles.sliceGrid("topWall_1", 0,0, 5);
		tiles.sliceGrid("bottomWall_1", 0,1, 5);
		tiles.sliceGrid("ground_1", 0,2, 9);
		
		tiles.sliceGrid("topWall_2", 0,3, 5);
		tiles.sliceGrid("bottomWall_2", 0,4, 5);
		tiles.sliceGrid("ground_2", 0,5, 9);
		
		tiles.sliceGrid("topWall_3", 0,8, 5);
		tiles.sliceGrid("bottomWall_3", 0,9, 5);
		tiles.sliceGrid("ground_3", 0,10, 9);
		
		tiles.slice("topWall_4", 0,811, g,g, 5);
		tiles.slice("bottomWall_4", 0,831, g,g, 5);
		tiles.slice("ground_4", 0,851, g,g, 9);
		
		tiles.slice("bottomWall_5", 0,1169, g,g, 1);
		tiles.slice("bottomWall_6", 0,1189, g,g, 3);
		
		tiles.slice("wallTexture", 0,120, 40,40);
		tiles.slice("grass", 0,281, 51,50);
		tiles.slice("blueFlower", 0,332, 26,37, 4);
		tiles.slice("dirt", 0,717, 30,30, 5);
		
		tiles.slice("shrine", 0,1119, 22,29);
		tiles.slice("barrel", 0,1148, 21,21, 2);
		
		//var c = 0x9E4E49;
		//var r = 0.7;
		//tiles.applyPermanentFilter("topWall_1", Color.getColorizeMatrixFilter(c, r, 1-r));
		//tiles.applyPermanentFilter("bottomWall_1", Color.getColorizeMatrixFilter(c, r, 1-r));
		
		// Entités..etc.
		char = new SpriteLibBitmap( new GfxCharacters(0,0) );
		char.setDefaultCenter(0.5,1);
		char.createGroup("hero", 32,44);
		char.sliceMore(0,0, 7); // front
		char.sliceMore(0,44, 7); // front up
		char.sliceMore(0,88, 7); // back
		char.sliceMore(0,132, 7); // back up
		char.defineAnim("front",		0-6(3) );
		char.defineAnim("frontUp", 7,	0-6(3) );
		char.defineAnim("back", 14,		0-6(3) );
		char.defineAnim("backUp", 21,	0-6(3) );
		char.slice("heroArms", 0,176, 42,37, 6);
		
		char.slice("grenade", 0,694, 24,24, 8);
		char.defineAnim("throw", 0-7(2) );
		char.slice("bomb", 0,718, 19,29, 2);
		
		char.slice("halo", 0,323, 99,84);
		char.slice("dirt", 0,407, 23,23, 6);
		char.slice("doorH", 0,747, 40,48, 8);
		char.defineAnim("woodOpenH", 1(1) > 3(1));
		char.defineAnim("woodCloseH", 2(1) > 0(1));
		char.defineAnim("metalOpenH", 5(1) > 7(1));
		char.defineAnim("metalCloseH", 6(1) > 4(1));
		char.slice("doorV", 0,795, 18,66, 8);
		char.defineAnim("woodOpenV", 1(1) > 3(1));
		char.defineAnim("woodCloseV", 2(1) > 0(1));
		char.defineAnim("metalOpenV", 5(1) > 7(1));
		char.defineAnim("metalCloseV", 6(1) > 4(1));
		char.slice("wdispenser", 0,861, 22,40, 4);
		char.slice("tdispenser", 0,901, 32,46, 4);
		char.slice("brokenDoorH", 0,947, 40,87, 2);
		char.slice("brokenDoorV", 0,1034, 68,66, 2);
		char.slice("gold", 0,1100, 41,46, 6);
		char.slice("stairDown", 0,1146, 40,40);
		char.slice("stairUp", 0,1186, 45,56);
		char.slice("map", 0,1242, 45,41);
		char.slice("turret", 0,1284, 52,80, 5);
		char.slice("prince", 0,1364, 27,29, 6);
		char.slice("icon", 0,1437, 40,40, 3);
		char.slice("stuffIcon", 0,1630, 20,20, 8);
		
		// Monstres
		char.slice("horde1", 0,213, 32,33, 10);
		char.defineAnim("walk", 0-9(2) );
		char.slice("horde2", 0,661, 32,33, 10);
		char.defineAnim("walk", 0-9(2) );
		
		char.slice("skel1", 0,1702, 22,38, 10);
		char.defineAnim("walk", 0-9(2) );
		char.slice("skel2", 0,1740, 15,48, 8);
		char.defineAnim("walk", 0-7(2) );
		char.slice("skel3", 0,1788, 24,49, 10);
		char.defineAnim("walk", 0-9(2) );
		
		char.slice("kamikaze", 0,246, 38,39, 6);
		char.defineAnim("walk", 0-5(3) );
		
		char.slice("bleuarg", 0,430, 37,43, 8);
		char.defineAnim("walk", 0(5) > 1-7(3) );
		
		char.slice("bat", 0,285, 13,38, 5);
		char.defineAnim("walk", 0(1) > 1-4(3) );
		
		char.slice("bomber", 0,473, 25,50, 6);
		char.defineAnim("walk", 0-5(3) );
		char.sliceMore(0,523, 9);
		var d = 2;
		char.defineAnim("shoot", 6, 0-8(d) );
		char.slice("bomberExplosion", 0,573, 63,88, 9);
		char.defineAnim("explosion", 0-8(d) );
		
		char.slice("unlocker", 0,1393, 34,44, 11);
		char.defineAnim("walk", 0-10(2));
		
		char.slice("ghost", 0,1560, 29,35, 10);
		char.defineAnim("walk", 0-9(2));
		char.slice("ghostFace", 0,1595, 29,35, 5);

		char.slice("rabbit", 0,1650, 18,31, 9);
		char.defineAnim("walk", 0-8(2));
		
		char.slice("kpoint", 0,1837, 19,24, 4);
		} catch(e:Dynamic) { throw "ERR3 "+e; } // HACK ------------------------------

		// Doit être fait avant tout new Entity()
		try { // HACK ------------------------------
		fx = new Fx();
		hud = new Hud();
		
		// Carte
		miniMap = new Minimap();
		dm.add(miniMap.wrapper, Const.DP_INTERF);
		
		// Répartition PK
		var maxFloors = isLeague() ? 1 : Level.countFloors(asProgression().level);
		for(f in 0...maxFloors)
			kpoints[f] = new List();
		for(pk in AKApi.getInGamePrizeTokens()) {
			var f = rseed.random(maxFloors);
			kpoints[f].add(pk);
		}
		} catch(e:Dynamic) { throw "ERR4 "+e; } // HACK ------------------------------
		
		try { // HACK ------------------------------
		hero = new en.Hero();
		generateLevel();
		} catch(e:Dynamic) { throw "ERR5 "+e; } // HACK ------------------------------
		
		try { // HACK ------------------------------
		buffer.render.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
		buffer.render.addEventListener( flash.events.MouseEvent.MOUSE_UP, onMouseUp);
		
		hud.refresh();
		miniMap.update();

		zsort();
		fx.fadeIn();
		Sfx.setChannelVolume(0, 1);
		Sfx.setChannelVolume(1, 0.2);
		S.BANK.music().playLoopOnChannel(1);
		} catch(e:Dynamic) { throw "ERR6 "+e; } // HACK ------------------------------
	}
	
	
	public function addSkill(d:Float) {
		skill+=d;
		if( skill>1 )
			skill = 1;
		if( skill<0.3 )
			skill = 0.3;
	}
	
	
	
	inline function countMobs(c:Class<en.Mob>) {
		return
			if( mobCounts.exists(Std.string(c)) )
				mobCounts.get(Std.string(c));
			else
				0;
	}
	
	function getMobsByClass(c:Class<en.Mob>) {
		if( countMobs(c)==0 )
			return [];
			
		var a = [];
		for(e in mobs)
			if( Type.getClass(e)==c )
				a.push(e);
		return a;
	}
	
	
	public inline function getAllies(?turretFirst=false) {
		var a : Array<Entity> = [hero];
		if( hero.turret!=null )
			if( turretFirst )
				a.insert(0, hero.turret);
			else
				a.push(hero.turret);
		return a;
	}
	
	public function generateLevel() {
	}
	
	public function setLevel(l:Level, armoredDoors:Int) {
		currentLevel = l;
		en.Door.resetFastAccess();
		en.it.Civilian.TOTAL = 0;
		AKApi.setProgression(0);
		
		// Point de départ
		var pt = currentLevel.getMetaOnce("start", rseed);
		if( pt==null ) pt = {cx:1, cy:1, data:null};
		hero.cx = pt.cx;
		hero.cy = pt.cy;
		hero.updateScreenCoords();
		viewPort.x = hero.xx;
		viewPort.y = hero.yy;
		
		// Carte
		miniMap.setLevel(currentLevel);
		miniMap.hide(true);
		fx.onLevelChange();
		
		// Portes
		var doors = mt.deepnight.Lib.shuffle(currentLevel.getAllMetaPoints("doors").copy(), rseed.random);
		for(pt in doors)
			new en.Door(pt.cx, pt.cy, pt.data==true, armoredDoors-->0);
		
		// Props
		var props = currentLevel.getAllMetaPoints("props");
		for(pt in props) {
			var data : Level.PropInfos = pt.data;
			var e = new en.Prop(pt.cx, pt.cy, data.key);
			e.weight = data.weight;
		}
		
		// Points kadeo
		var curFloor = isLeague() ? 0 : asProgression().depth;
		for(pk in kpoints[curFloor]) {
			var pt = currentLevel.getMeta("middle", rseed);
			new en.it.KPoint(pt.cx, pt.cy, pk);
		}
	}
	
	
	public function onHeroDeath() {
		fx.heroDeath();
		cd.set("gameOver", 50);
		cd.onComplete("gameOver", function() {
			endGame(false);
		});
	}
	
	public inline function isProgression() {
		return AKApi.getGameMode()==api.AKProtocol.GameMode.GM_PROGRESSION;
	}
	public inline function isLeague() {
		return AKApi.getGameMode()==api.AKProtocol.GameMode.GM_LEAGUE;
	}
	
	public inline function asProgression() : Progression {
		if( !isProgression() )
			throw "not PROGRESSION mode";
		return cast this;
	}
	
	public inline function asLeague() : League {
		if( !isLeague() )
			throw "not LEAGUE mode";
		return cast this;
	}

	public function addScorePop(x,y, v:api.AKConst) {
		if( !isLeague() )
			return;
		AKApi.addScore(v);
		fx.popScore(x,y, v.get());
	}

	override public function destroy() {
		super.destroy();
		
		for( e in Entity.ALL )
			e.destroy();
	}
	
	function onMouseDown(_) {
		if( paused || gameEnded || hero.dead )
			return;
		AKApi.emitEvent(0);
	}
	
	function onMouseUp(_) {
		if( paused || gameEnded || hero.dead )
			return;
		AKApi.emitEvent(1);
		var m = getMouseInScroll();
		AKApi.emitEvent(2 + Std.int(m.x));
		AKApi.emitEvent(2 + Std.int(m.y));
	}
	

	public inline function warning(msg:Dynamic) {
		notify(msg, 0xFF3900);
	}
	
	public function notify(msg:Dynamic, col:Int) {
		var d = 2.1;
		if( cd.has("notify") ) {
			delayer.add( function() notify(msg,col), d*0.6 );
			return;
		}
		cd.set("notify", 30*d*0.5);
		
		var tf = createField(msg, true);
		tf.textColor = col;
		tf.filters = [ new flash.filters.GlowFilter(col, 0.5, 4,4,2) ];
		
		var bmp = mt.deepnight.Lib.flatten(tf, 4);
		dm.add(bmp, Const.DP_INTERF);
		bmp.scaleX = 5;
		bmp.scaleY = 5;
		bmp.x = Std.int(Const.WID*0.5 - bmp.width*0.5+10);
		bmp.y = 90;
		bmp.blendMode = flash.display.BlendMode.ADD;
		bmp.alpha = 0;
		
		tw.create(bmp, "y", bmp.y+10, TLoop, 450);
		tw.create(bmp, "alpha", 1, 300).onEnd = function() {
			tw.create(bmp, "alpha", 0, TEaseIn, d*1000).onEnd = function() {
				bmp.bitmapData.dispose();
				bmp.parent.removeChild(bmp);
			}
		}
	}
	
	public function placeName(msg:Dynamic, col:Int) {
		var tf = createField("\""+msg+"\"", true);
		tf.textColor = col;
		tf.filters = [ new flash.filters.GlowFilter(0x0, 0.7, 8,8,2) ];
		
		var bmp = mt.deepnight.Lib.flatten(tf, 4);
		dm.add(bmp, Const.DP_INTERF);
		bmp.scaleX = 3;
		bmp.scaleY = 3;
		bmp.x = Std.int(Const.WID*0.5 - bmp.width*0.5+10);
		bmp.y = Std.int(Const.HEI*0.25 - bmp.height*0.5);
		//bmp.blendMode = flash.display.BlendMode.ADD;
		bmp.alpha = 0;
		
		tw.create(bmp, "alpha", 1, 1000).onEnd = function() {
			tw.create(bmp, "alpha", 0, TEaseIn, 3000).onEnd = function() {
				bmp.bitmapData.dispose();
				bmp.parent.removeChild(bmp);
			}
		}
	}
	
	public function onLevelComplete() {
	}
	
	public function onExit() {
	}
		
	public function explosion(targetPlayer:Bool, centerX:Float, centerY:Float, range:Float, dmg:Int, ?repel=1.0) {
		var victims = new Array();
		var targets : Array<Entity> = targetPlayer ? getAllies() : cast mobs;
		
		targets = targets.concat(cast en.Prop.ALL);
		
		for(e in targets) {
			var d = mt.deepnight.Lib.distance(centerX, centerY, e.xx, e.yy);
			if( d<range ) {
				victims.push(e);
				e.hit(dmg);
				e.jump(e.rnd(2,4));
				var a = Math.atan2(e.yy-centerY, e.xx-centerX);
				e.dx = Math.cos(a)*0.5 * repel*(d/range);
				e.dy = Math.sin(a)*0.5 * repel*(d/range);
			}
		}
		return victims;
	}
	
	
	public function createField(str:Dynamic, ?col=0xFFFFFF, ?font:Font, ?adjustSize=false) {
		if( font==null )
			font = F_Small;
		var f = new flash.text.TextFormat();
		switch(font) {
			case F_Small : f.font = "small"; f.size = 16;
		}
		f.color = col;
		
		var tf = new flash.text.TextField();
		tf.width = adjustSize ? 500 : 300;
		tf.height = 50;
		tf.mouseEnabled = tf.selectable = false;
		tf.defaultTextFormat = f;
		tf.embedFonts = true;
		tf.htmlText = Std.string(str);
		tf.multiline = tf.wordWrap = true;
		if( adjustSize ) {
			tf.width = tf.textWidth+5;
			tf.height = tf.textHeight+5;
		}
		
		tf.filters = [
			new flash.filters.GlowFilter(0x0,1, 2,2,5),
		];
		
		return tf;
	}
	
	
	public inline function isClicking() {
		return clickStart>=0;
	}
	
	public inline function getMouse() {
		return {x:root.mouseX, y:root.mouseY}
	}
	public inline function getBufferMouse() {
		return buffer.globalToLocal(buffer.render.mouseX, buffer.render.mouseY);
	}
	public inline function getMouseInScroll() {
		var m = getBufferMouse();
		return {
			x	: m.x-scroller.x,
			y	: m.y-scroller.y,
		}
	}
	
	public function setHandCursor(b:Bool) {
		buffer.setHandCursor(b);
	}
	
	public inline function getMouseCase() {
		var m = getMouseInScroll();
		return {
			cx	: Std.int(m.x/Const.GRID),
			cy	: Std.int(m.y/Const.GRID),
		}
	}
	
	
	function getFarMobSpot(mclass:Class<en.Mob>) {
		var minDist = 10;
		var others = getMobsByClass(mclass);
		
		var spawnDist = Math.ceil( Math.max(3, 15-difficulty*1.5) );
		
		while( minDist>0 ) {
			var tries = 10;
			while( tries-->0 ) {
				var pt = currentLevel.getFarSpot(rseed, hero.cx, hero.cy, spawnDist, spawnDist+10);
				if( pt==null )
					continue;
				var far = true;
				for(e in others)
					if( Math.abs(pt.cx-e.cx)<minDist && Math.abs(pt.cy-e.cy)<minDist ) {
						far = false;
						break;
					}
				if( far )
					if( currentLevel.canBeReached(pt.cx, pt.cy) )
						return pt;
			}
			minDist--;
		}
		return null;
	}
	
	function repopMob(maxCount:Float, absoluteMax:Float, mclass:Class<en.Mob>, frequency:Int, ?packSize=1) {
		if( cd.has("repop_"+mclass) )
			return;
			
		var n = countMobs(mclass);
		if( n>=Std.int(maxCount) || n>=Std.int(absoluteMax) )
			return;
			
		var pt = getFarMobSpot(mclass);
		if( pt!=null ) {
			cd.set("repop_"+mclass, frequency);
			for( i in 0...packSize )
				new en.Spawner(mclass, pt.cx, pt.cy);
		}
	}
	
	
	public inline function zsort() {
		cd.set("zsort", 16);
		var a : Array<Entity> = [];
		for(e in Entity.ALL)
			if( e.onScreen && e.zsortable )
				a.push(e);
		a.sort( function(e1, e2) return Reflect.compare(e1.yy+e1.zpriority, e2.yy+e2.zpriority) );
		for(e in a)
			sdm.over(e.sprite);
	}
	
	public function endGame(win:Bool) {
		gameEnded = true;
		if( win && isProgression() )
			AKApi.saveState( hero.saveState() );
		AKApi.gameOver(win);
	}
	
	public inline function flushKillList() {
		for(e in killList)
			e.detach();
		killList = new Array();
	}
	
	override public function update() {
		super.update();
		
		cd.update();
		BSprite.updateAll();
		
		//if( !cd.has("repop") && mobs.length<=30 ) {
			//cd.set("repop", 30*6);
			//var pt = currentLevel.getFarSpot(rseed, hero.cx, hero.cy);
			//if( pt!=null )
				//for(i in 0...7)
					//new en.mob.Horde(pt.cx, pt.cy);
		//}
		
		#if debug
			// Contrôles clavier
			var s = 0.08;
			// Tests
			if( AKApi.unrecordedIsToggled(Keyboard.SPACE) )
				fx.bones(hero.xx, hero.yy);
			
			if( AKApi.unrecordedIsToggled(Keyboard.NUMBER_1) )
				hero.setWeapon(W_Basic);
			if( AKApi.unrecordedIsToggled(Keyboard.NUMBER_2) )
				hero.setWeapon(W_Lightning);
			if( AKApi.unrecordedIsToggled(Keyboard.NUMBER_3) )
				hero.setWeapon(W_Grenade);
			if( AKApi.unrecordedIsToggled(Keyboard.NUMBER_4) )
				hero.setWeapon(W_Lazer);
				
			// Collisions
			currentLevel.colLayer.visible = AKApi.unrecordedIsDown(Keyboard.C);
				
			// Etage suivant
			if( AKApi.unrecordedIsToggled(Keyboard.N) )
				onExit();
				
			if( AKApi.unrecordedIsToggled(Keyboard.X) )
				Level.estimateXp();
		#end
		
		
		// Gestion des events
		var e = AKApi.getEvent();
		while( e!=null ) {
			if( e==0 ) {
				// Mouse down
				clickStart = time;
			}
			else if( e==1 ) {
				// Mouse up
				if( time-clickStart>=Const.INVOKE )
					castSuccessful = true;
				clickStart = -1;
				hero.cancelInvoke();
			}
			else if( e>=2 ) {
				var tx = e-2;
				var ty = AKApi.getEvent()-2;
				// Coordonnée X,Y
				if( castSuccessful )
					hero.castTurret( Std.int(tx/Const.GRID), Std.int(ty/Const.GRID));
				else {
					// Clic sur un objet ?
					hero.targetEntity = null;
					for(e in Entity.SELECTABLES)
						if( e.isOver(tx,ty) ) {
							hero.targetEntity = e;
							hero.gotoFreeCoord(e.xx, (e.cy+1.1)*Const.GRID);
							if( e.cd.has("activate") )
								fx.blink(e, 0xFF0000);
							else
								fx.blink(e, 0x00FFFF);
							break;
						}
					// Déplacement normal
					if( hero.targetEntity==null ) {
						hero.gotoFreeCoord(tx, ty);
						if( !AKApi.isReplay() )
							fx.moveOrder(tx, ty, 0x80FF00);
					}
				}
				castSuccessful = false;
			}
			e = AKApi.getEvent();
		}
		
		var unrecMouse = getMouseInScroll();
		
		// Clic maintenu
		if( isClicking() && !hero.canCastTurret() )
			clickStart = time;
		if( !hero.dead && !AKApi.isReplay() && isClicking() && time-clickStart>=5 )
			hero.invoke(unrecMouse.x, unrecMouse.y, Math.min(1, (time-clickStart)/Const.INVOKE));
		
		// Rollover entités
		if( !AKApi.isReplay() ) {
			var e : Entity = null;
			for(e2 in Entity.SELECTABLES)
				if( e2.isOver(unrecMouse.x, unrecMouse.y) ) {
					e = e2;
					break;
				}
			if( e==null && overEntity!=null ) {
				overEntity.sprite.filters = [];
				overEntity = null;
				setHandCursor(false);
			}
			if( e!=null ) {
				overEntity = e;
				overEntity.sprite.filters = [ new flash.filters.GlowFilter(0xFFFF00,0.4, 8,8,1) ];
				setHandCursor(true);
			}
		}
		
		//#if debug
		//var mc = getMouseCase();
		//hero.sightCheckCoord(mc.cx, mc.cy);
		//hero.aim(m.x, m.y);
		//#end
		
		// Z-Sort
		if( !cd.has("zsort") )
			zsort();
			
		// Entités
		if( !gameEnded )
			for(e in Entity.ALL) {
				e.preUpdate();
				e.update();
				e.postUpdate();
			}
		flushKillList();
		
		// Hurry-up mob
		if( !gameEnded ) {
			var cap = isProgression() && asProgression().level==1 ? 30*50 : 30*30;
			if( inactivity>=cap ) {
				inactivity = 0;
				var tries = 100;
				while( tries-->0 ) {
					var cx = hero.cx + rseed.irange(2,7,true);
					var cy = hero.cy + rseed.irange(2,7,true);
					if( !currentLevel.getCollision(cx,cy) ) {
						new en.mob.HurryGhost(cx, cy);
						break;
					}
				}
			}
		}
		
		var vx = hero.xx;
		var vy = hero.yy;
		viewPort.x += ((vx-viewPort.width*0.5)-viewPort.x)*0.10;
		viewPort.y += ((vy-viewPort.height*0.5)-viewPort.y)*0.17;
		if( viewPort.x>currentLevel.wid*Const.GRID-viewPort.width )
			viewPort.x = currentLevel.wid*Const.GRID-viewPort.width;
		if( viewPort.x<0 )
			viewPort.x = 0;
		if( viewPort.y<0 )
			viewPort.y = 0;
		if( viewPort.y>currentLevel.hei*Const.GRID-viewPort.height )
			viewPort.y = currentLevel.hei*Const.GRID-viewPort.height;
		scroller.x = Std.int( -viewPort.x );
		scroller.y = Std.int( -viewPort.y );
		viewPortCase.x = Std.int(viewPort.x/Const.GRID-3);
		viewPortCase.y = Std.int(viewPort.y/Const.GRID-2);
		
		if( time%4==0 && miniMap.wrapper.visible )
			miniMap.update();
		hud.update();
		fx.update();
		delayer.update();
		time++;
		inactivity++;
	}
}
