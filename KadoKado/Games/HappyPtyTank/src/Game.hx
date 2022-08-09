import flash.display.Sprite;
import KKApi;
import EnemyShot;
import Scroll;
import Tank;
import GameOver;
import Warning;

@:bind
class IncomingArrow extends flash.display.Sprite {
	public function new(){
		super();
	}
}

// This is an hack for linux / flashplayer keyboard event UP/DOWN bug
class Key {
	static var keys = new List<Key>();
	public static var UP = new Key(flash.ui.Keyboard.UP, "Z".charCodeAt(0), "W".charCodeAt(0));
	public static var DOWN = new Key(flash.ui.Keyboard.DOWN, "S".charCodeAt(0), "S".charCodeAt(0));
	public static var LEFT = new Key(flash.ui.Keyboard.LEFT, "Q".charCodeAt(0), "A".charCodeAt(0));
	public static var RIGHT = new Key(flash.ui.Keyboard.RIGHT, "D".charCodeAt(0), "D".charCodeAt(0));
	#if dev
	public static var MINUS = new Key(flash.ui.Keyboard.NUMPAD_ADD);
	public static var SPACE = new Key(flash.ui.Keyboard.SPACE);
	public static var ENTER = new Key(flash.ui.Keyboard.ENTER);
	public static var DELETE = new Key(flash.ui.Keyboard.DELETE);
	#end

	public var isDown : Bool;
	var code : Int;
	var code1 : Int;
	var code2 : Int;
	var down : Bool;
	var frames : Int;

	function new( c, ?alt1:Null<Int>=null, ?alt2:Null<Int>=null ){
		code = c;
		code1 = if (alt1 == null) code else alt1;
		code2 = if (alt2 == null) code else alt2;
		down = false;
		frames = 0;
		keys.push(this);
	}

	function setDown( d:Bool ){
		if (d){
			isDown = true;
			down = true;
			frames = 0;
		}
		else {
			down = false;
			frames = 1;
		}
	}

	public static function init(){
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, callback(onKey,true));
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, callback(onKey,false));
	}

	static function onKey(down:Bool, evt:flash.events.KeyboardEvent){
		switch (evt.keyCode){
			case UP.code,UP.code1,UP.code2: UP.setDown(down);
			case DOWN.code,DOWN.code1,DOWN.code2: DOWN.setDown(down);
			case LEFT.code,LEFT.code1,LEFT.code2: LEFT.setDown(down);
			case RIGHT.code,RIGHT.code1,RIGHT.code2: RIGHT.setDown(down);
#if dev
			case SPACE.code,SPACE.code1,SPACE.code2: SPACE.setDown(down);
			case ENTER.code,ENTER.code1,ENTER.code2: ENTER.setDown(down);
			case DELETE.code,DELETE.code1,DELETE.code2: DELETE.setDown(down);
			case MINUS.code,MINUS.code1,MINUS.code2: MINUS.setDown(down);
#end
		}
	}

	public static function update(){
		for (k in keys){
			if (k.isDown && !k.down){
				k.frames++;
				if (k.frames > 3)
					k.isDown = false;
			}
		}
	}
}

class Game extends Sprite {
	static var FATAL_MISSILE_TIME : KKConst;
	static var FATAL_MISSILE_LAUNCH : KKConst; // countdown timer start at wave n°X
	static var INIT_CIRCLE : KKConst; // first two circles do not count
	public static var MAX_ARMOR : KKConst;
	public var now : Float;
	public static var color : ColorSet;
	public static var W = 300;
	public static var H = 300;
	public static var mouseDown = false;
	public static var instance : Game;
	public var userInterface : UserInterface; // above all layer for user interface
	public var gameLayer : Sprite; // where sprites live and die
	public var warZone : WarZone; // wall locking user
	public var warning : Warning; // warning message
	var lastZone : Float; // last warzone end time
	public var groundLayer : Sprite; // ground layer
	public var scroll : GroundScroll; // ground
	public var tank : Tank; // player
	public var target : Target; // player's target
	public var activeOption : Option; // player's current active option
	public var shots : List<Shot>; // player's shots
	public var options : List<Option>; // options on ground
	public var spawners : List<Spawner>; // foes spawners
	public var foes : List<Enemy>; // list of foes
	public var foesShots : List<EnemyShot>; // foes' shots
	public var foesMines : List<Mine>; // foes' mines
	public var missiles : List<XMissile>; // falling missiles
	public var fxLayer : Sprite; // play explosions and stuff there
	public var anims : List<Anim>; // things to update each frame
	public var incomingArrows : Array<IncomingArrow>; // small ui arrows pointing at enemies
	public var optTimes : KKConst; // number of time options used during this game
	var quake : { timer:Float, power:Float }; // quake fx time and intensity
	public var endTime : Null<Float>; // end of game time
	var lastShot : Float;
	public var shotRate : Float;
	var gameover : Bool;
	var gameOverAnim : Anim;
	var lastMissile : Float;
	var lastMissileK : Int;
	var kills : Int;
	var started : Bool;
	var waves : KKConst;
	public var armor : KKConst;
	public var score : KKConst;
	public var circle : KKConst;
	var slowFrames : Int;
	public var slowLevel : Int;
	public var tankRecall : { x:Float, y:Float };

	public static var root : flash.display.MovieClip;

	public function new( r:flash.display.MovieClip ){
		FATAL_MISSILE_LAUNCH = KKApi.const(3);
		FATAL_MISSILE_TIME = KKApi.const(120);

		#if dev
		FATAL_MISSILE_TIME = KKApi.const(240);
		#end

		INIT_CIRCLE = KKApi.const(4);
		MAX_ARMOR = KKApi.const(10);
		super();
		Game.root = r;
		kills = 0;
		color = new ColorSet();
		flash.ui.Mouse.hide();
		instance = this;
		slowFrames = 0;
		slowLevel = 0;
		armor = KKApi.const(8);
		score = KKApi.const(0);
		waves = KKApi.const(0);
		optTimes = KKApi.const(0);
		gameover = false;
		circle = KKApi.const(KKApi.val(INIT_CIRCLE));
		endTime = null;
		lastShot = 0;
		shotRate = 333;
		incomingArrows = [];
		shots = new List();
		options = new List();
		foes = new List();
		foesShots = new List();
		foesMines = new List();
		spawners = new List();
		anims = new List();
		missiles = new List();
		now = 0;
		lastZone = now + 2000;
		lastMissile = now + 2000;
		lastMissileK = -1;
		initGameLayer();
		for (i in 0...3){
			var arrow = new IncomingArrow();
			arrow.visible = false;
			incomingArrows.push(arrow);
			groundLayer.addChild(arrow);
		}
		initUserInterface();
		started = false;
		mt.Timer.wantedFPS = 30;
		Game.root.addChild(this);
		KKApi.registerButton(Game.root);
		Game.root.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(_) Game.mouseDown = true);
		Game.root.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(_) Game.mouseDown = false);
		Key.init();
	}

	public function doQuake( time:Float, power:Float ){
		if (slowLevel == 3)
			return;
		if (slowLevel == 2)
			power = power / 2;
		if (quake != null && quake.power > power){
			quake.timer += time / 2;
			quake.power += 0.01;
			quake.power = Math.min(0.02, quake.power);
			return;
		}
		quake = { timer:time, power:power };
	}

	function initGameLayer(){
		groundLayer = new Sprite();
		addChild(groundLayer);
		scroll = new GroundScroll();
		groundLayer.addChild(scroll);
		groundLayer.x = W/2;
		groundLayer.y = H/2;
		gameLayer = new Sprite();
		gameLayer.x = W / 2;
		gameLayer.y = H / 2;
		addChild(gameLayer);
		warZone = new WarZone();
		gameLayer.addChild(warZone);
		groundLayer = new Sprite();
		gameLayer.addChild(groundLayer);
		tank = new Tank();
		tank.x = 0;
		tank.y = 0;
		gameLayer.addChild(tank);
		fxLayer = new Sprite();
		addChild(fxLayer);
		target = new Target();
		tank.target = target;
		addChild(target);
	}

	function initUserInterface(){
		userInterface = new UserInterface();
		addChild(userInterface);
	}

	static var frames = 0;

	public function update(){
		frames++;
		var resetSlow = false;
		#if dev
		if (Key.MINUS.isDown){
			Key.MINUS.isDown = false;
			slowFrames = frames;
			mt.Timer.tmod = 1.02;
		}
		#end
		if (mt.Timer.tmod > 1.01 && slowLevel < 3){
			slowFrames++;
			var slowRatio = slowFrames / frames;
			if (frames < mt.Timer.wantedFPS * 5){
			}
			else {
				if (slowLevel < 1 && slowRatio > 0.3){
					slowLevel = 1;
					resetSlow = true;
					flash.ui.Mouse.show();
					target.visible = false;
					if (Std.string(flash.Lib.current.stage.quality) == "BEST"){
						flash.Lib.current.stage.quality = flash.display.StageQuality.HIGH;
						#if dev
						trace("setting to HIGH");
						#end
					}
				}
				else if (slowLevel < 2 && slowRatio > 0.5){
					if (Std.string(flash.Lib.current.stage.quality) != "LOW"){
						flash.Lib.current.stage.quality = flash.display.StageQuality.MEDIUM;
						#if dev
						trace("setting to MEDIUM");
						#end
					}
					slowLevel = 2;
					resetSlow = true;
				}
				else if (slowRatio > 0.8){
					if (Std.string(flash.Lib.current.stage.quality) != "LOW"){
						flash.Lib.current.stage.quality = flash.display.StageQuality.LOW;
						#if dev
						trace("setting to LOW");
						#end
					}
					slowLevel = 3;
					resetSlow = true;
				}
			}
		}
		if (resetSlow || frames > mt.Timer.wantedFPS * 10){
			frames = Math.round(frames / 2);
			slowFrames = Math.round(slowFrames / 2);
		}
		#if dev
		if (Key.DELETE.isDown){
			haxe.Firebug.trace("** quality = "+flash.Lib.current.stage.quality);
			haxe.Firebug.trace("** frames="+frames+" slowFrames="+slowFrames+" ratio="+(slowFrames/frames)+" slowLevel="+slowLevel);
		}
		#end
		if (flash.Lib.current.stage != null)
			flash.Lib.current.stage.focus = this;
		Key.update();
		var gameWasOver = gameover;
		now += mt.Timer.deltaT * 1000;
		if (quake != null && quake.timer > 0.0){
			quake.timer -= mt.Timer.deltaT;
			if (quake.timer <= 0.0){
				quake = null;
				x = 0;
				y = 0;
			}
			else {
				x = (Math.random() * quake.power * W * 2 - quake.power * W);
				y = (Math.random() * quake.power * H * 2 - quake.power * H);
			}
		}
		if (started && warZone.visible == false){
			#if dev
			if (Key.ENTER.isDown){
				trace(flash.Lib.current.stage.quality);
				enterWarZone();
			}
			else if (Key.SPACE.isDown)
				launchMissiles();
			#else
			if ((now - lastZone)/5000 > 1 + Math.random())
				enterWarZone();
			else
				launchMissiles();
			#end
		}
		if (!gameover){
			started = tank.updateControls(Key.UP.isDown, Key.DOWN.isDown, Key.LEFT.isDown, Key.RIGHT.isDown) || started;
			tank.move();
		}
		tank.update();
		// do not move over warzone's courtesy line
		if (warZone.visible){
			if (warZone.minX >= tank.x || warZone.maxX <= tank.x || warZone.minY >= tank.y || warZone.maxY <= tank.y)
				tank.unmove();
		}

		for (s in spawners)
			s.update();

		// update options
		for (o in options){
			o.update(now);
			if (Collision.isColliding(tank, o, gameLayer, true, 0)){
				if (activeOption != null){
					activeOption.inactivate();
					activeOption = null;
				}
				o.activate();
				score = KKApi.addScore(o.value);
				if (o.time != 0){
					activeOption = o;
					o.end = now + o.time;
				}
				gameLayer.removeChild(o);
				options.remove(o);
				userInterface.gotOption(o);
			}
			else if (o.dead){
				gameLayer.removeChild(o);
				options.remove(o);
			}
		}
		if (activeOption != null && activeOption.end <= now){
			activeOption.inactivate();
			activeOption = null;
		}

		updateShotsAndFoes();

		if (!gameover && mouseDown)
			createShot(now);

		// update view and scroll
		target.visible = target.visible && !gameover;
		target.x = Game.root.mouseX;
		target.y = Game.root.mouseY;
		var vx = tank.x;
		var vy = tank.y;
		if (warZone.visible){
			var minX = warZone.minX + W / 2 - 32;
			var maxX = warZone.maxX - W / 2 + 32;
			var minY = warZone.minY + H / 2 - 32;
			var maxY = warZone.maxY - H / 2 + 32;
			vx = Math.min(maxX, Math.max(minX, tank.x));
			vy = Math.min(maxY, Math.max(minY, tank.y));
		}
		else if (tankRecall != null){
			var rtime = 0.4;
			vx += tankRecall.x * rtime * mt.Timer.tmod;
			vy += tankRecall.y * rtime * mt.Timer.tmod;
			tankRecall.x -= tankRecall.x * rtime * mt.Timer.tmod;
			tankRecall.y -= tankRecall.y * rtime * mt.Timer.tmod;
			if (Math.abs(tankRecall.x) < 5.0 && Math.abs(tankRecall.y) < 5.0)
				tankRecall = null;
		}
		tank.screenX = tank.x - vx + W/2;
		tank.screenY = tank.y - vy + H/2;
		gameLayer.x = -vx + W/2 ;
		gameLayer.y = -vy + H/2 ;
		fxLayer.x = gameLayer.x;
		fxLayer.y = gameLayer.y;
		scroll.update(vx, vy);
		if (scroll.getCurrentCircle() > KKApi.val(circle)){
			new NewCircleAnim();
			circle = KKApi.const(scroll.getCurrentCircle());
			score = KKApi.addScore(KKApi.const((KKApi.val(circle) - KKApi.val(INIT_CIRCLE)) * 250));
		}
		// check life
		if (KKApi.val(armor) <= 0){
			gameover = true;
			tank.speed = 0;
		}
		var timeover = false;
		// check remaining time
		if (endTime != null){
			var remain = Math.max(0, endTime - now);
			timeover = remain == 0;
			gameover = gameover || timeover;
			var ex = remain % 1000;
			remain = Std.int(remain / 1000.0);
			var seconds = remain % 60;
			remain = Std.int(remain / 60);
			var minutes = remain;
			// update ui option
			if (activeOption == null || !Std.is(activeOption, OptTime))
				userInterface.time.text = StringTools.lpad(Std.string(minutes), "0", 2)+":"+StringTools.lpad(Std.string(seconds),"0",2);
		}
		// update ui circle
		userInterface.level.text = Std.string(KKApi.val(circle) - KKApi.val(INIT_CIRCLE));
		// game over reached during this frame
		if (!gameWasOver && gameover)
			gameOver(timeover);
		// no more foe
		if (warZone.visible == true && spawners.length == 0 && foes.length == 0){
			leaveWarZone(now);
			tankRecall = { x:vx - tank.x, y:vy - tank.y };
		}
		// update extra anims
		for (anim in anims)
			if (!anim.update())
				anims.remove(anim);
		// update user interface
		userInterface.update(now);
		// update incoming Arrows
		for (arrow in incomingArrows)
			arrow.visible = false;
		var done = 0;
		for (foe in foes){
			var dist = Geom.distance(tank, foe);
			if (dist > W/2){
				var angle = Geom.angleRad(tank, foe);
				var arrow = incomingArrows[done];
				arrow.visible = true;
				arrow.x = tank.x;
				arrow.y = tank.y;
				arrow.rotation = Geom.rad2deg(angle) - 180;
				Geom.moveAngle(arrow, angle, 100);
				done++;
				if (done == incomingArrows.length)
					break;
			}
		}
		if (gameOverAnim != null && !gameOverAnim.update()){
			KKApi.gameOver({
				_waves : KKApi.val(waves),
				_circle : KKApi.val(circle),
				_extraSeconds : KKApi.val(optTimes),
				_kills : kills,
				// etc.
			});
		}
	}

	function updateShotsAndFoes(){
		var boundaries = {
			min:{ x:tank.x - W/2 - 64, y:tank.y - H/2 - 64 },
			max:{ x:tank.x + W/2 + 64, y:tank.y + H/2 + 64 }
		};
		for (shot in shots){
			shot.update();
			var destroyed = false;
			for (e in foes){
				if (e.collideWithShot(shot)){
					destroyed = true;
					shots.remove(shot);
					gameLayer.removeChild(shot);
					break;
				}
			}
			if (!destroyed && (shot.x < boundaries.min.x || shot.x > boundaries.max.x || shot.y < boundaries.min.y || shot.y > boundaries.max.y)){
				gameLayer.removeChild(shot);
				shots.remove(shot);
			}
		}
		for (mine in foesMines){
			mine.update();
			if (Collision.isColliding(mine, tank, Game.root, true, 0)){
				foesMines.remove(mine);
				gameLayer.removeChild(mine);
				tankDamaged();
				tank.setState(Hurt);
			}
		}
		for (shot in foesShots){
			shot.update();
			if (Collision.isColliding(shot, tank, Game.root, true, 0)){
				if (Std.is(shot, Lazer)){
					anims.push(shot);
					foesShots.remove(shot);
				}
				else {
					gameLayer.removeChild(shot);
					foesShots.remove(shot);
				}
				tankDamaged(shot.power);
				tank.setState(Hurt);
			}
			else if (shot.x < boundaries.min.x || shot.x > boundaries.max.x || shot.y < boundaries.min.y || shot.y > boundaries.max.y || shot.destroyed){
				if (shot.parent != null)
					shot.parent.removeChild(shot);
				foesShots.remove(shot);
			}
		}
		for (enemy in foes){
			if (Collision.isColliding(enemy, tank, Game.root, true, 0)){
				enemy.damaged(10);
				tankDamaged();
				tank.setState(Hurt);
				if (enemy.life <= 0)
					enemyDestroyed(enemy, true);
			}
			else if (enemy.life <= 0)
				enemyDestroyed(enemy);
			else
				enemy.update();
		}
		for (missile in missiles){
			missile.update();
			if (missile.dangerous && missile.isColliding(tank)){
				missile.dangerous = false;
				tankDamaged();
				tank.setState(Hurt);
			}
		}
	}

	function tankDamaged( damages:Int=1 ){
		#if !dev
		var a = KKApi.val(armor);
		a -= damages;
		a = Std.int(Math.max(0, a));
		armor = KKApi.const(a);
		#end
		doQuake(1 / 2, 1 * 0.05);
		updateArmorBits();
	}

	public function updateArmorBits(){
		userInterface.updateArmorBits();
	}

	function createShot(now:Float){
		if (lastShot > now - shotRate)
			return;
		var angles = [ tank.getAimAngle() ];
		if (activeOption != null && Std.is(activeOption, OptShot)){
			angles.push(angles[0] - 10);
			angles.push(angles[0] + 10);
		}
		Shot.nextColor();
		for (angle in angles){
			var vector = Geom.radToVector(Geom.deg2rad(angle));
			var shot = new Shot(vector, Shot.COLOR);
			shot.x = tank.x + vector.x * 30;
			shot.y = tank.y + vector.y * 30;
			shot.rotation = angle - 180;
			shot.speed = Math.max(tank.maxSpeed * 1.5, shot.speed);
			gameLayer.addChild(shot);
			shots.push(shot);
		}
		lastShot = now;
	}

	function enemyDestroyed( e:Enemy, ?onCollisionWithTank=false ){
		kills++;
		e.onDeath();
		foes.remove(e);
		new EnemyDeathAnim(e);
		if (!gameover)
			score = KKApi.addScore(e.value);
		if (e.maxLife > 5)
			doQuake(0.5*Math.random(), 0.008);
		if (onCollisionWithTank == false)
			spawnOptionAt(e.x, e.y);
	}


	static var OPT_TABLE : Array<Class<Option>> = {
		var probabilities = [
			{ k:null, p:30 },
			{ k:OptShot, p:3 },
			{ k:OptTime, p:1 },
			{ k:OptArmor, p:1 },
			{ k:OptSpeed, p:2 },
	        { k:OptShotRate, p:2 }
		];
		var bigtable : Array<Class<Option>> = [];
		var i = 0;
		for (p in probabilities){
			if (p.k == null)
				i = p.p;
			else {
				for (j in 0...p.p)
					bigtable[i++] = p.k;
			}
		}
		bigtable;
	};

	function randomOption() : Option {
		var ran = Std.random(OPT_TABLE.length);
		if (OPT_TABLE[ran] == null)
			return null;
		if (KKApi.val(waves) < KKApi.val(FATAL_MISSILE_LAUNCH) && OPT_TABLE[ran] == OptTime)
			return null;
		return Type.createInstance(OPT_TABLE[ran], []);
	}

	function spawnOptionAt(x:Float, y:Float){
		var option = randomOption();
		if (option == null)
			return;
		option.x = x;
		option.y = y;
		var p = new flash.geom.Point(x,y);
		for (s in spawners)
			if (s.getRect(s.parent).containsPoint(p))
				return;
		for (o in options)
			if (o.getRect(o.parent).containsPoint(p))
				return;
		gameLayer.addChild(option);
		options.push(option);
	}

	function gameOver(timeup:Bool){
		gameOverAnim = if (timeup) new TheEnd() else new YouDie();
	}

	public function addAnimation( a:Anim ){
		anims.push(a);
	}

	public function delAnimation( a:Anim ) : Bool {
		return anims.remove(a);
	}

	public function addSpawner( s:Spawner ){
		spawners.push(s);
		groundLayer.addChild(s);
	}

	public function addFoe( f:Enemy ){
		foes.push(f);
		gameLayer.addChild(f);
	}

	public function createEnemyShot( emitter:Enemy, ?vector ) : EnemyShot {
		if (vector == null)
			vector = Geom.radToVector(Geom.angleRad(emitter, tank));
		var shot = new EnemyShot(vector);
		shot.x = emitter.x;
		shot.y = emitter.y;
		gameLayer.addChild(shot);
		foesShots.push(shot);
		return shot;
	}

	public function createEnemyLazer( origin:{x:Float, y:Float}, angleDeg:Float ){
		var shot = new Lazer();
		shot.x = origin.x;
		shot.y = origin.y;
		// shot.rotation = Geom.rad2deg(angle) - 90;
		shot.rotation = angleDeg;
		gameLayer.addChild(shot);
		foesShots.push(shot);
	}

	function enterWarZone(){
		if (warZone.visible == true || gameover)
			return;
		warZone.init(tank.x, tank.y);
		tank.setBounds(warZone);
		if (!gameover)
			setWarning(new Warning());
		var diff = Std.int(Math.max(1, KKApi.val(circle) - KKApi.val(INIT_CIRCLE)));
		diff = Std.int(Math.max(diff, KKApi.val(waves)));
		WarZoneBuilder.build(diff);
	}

	function leaveWarZone( now:Float ){
		waves = KKApi.const(KKApi.val(waves)+1);
		if (endTime == null && KKApi.val(waves) >= KKApi.val(FATAL_MISSILE_LAUNCH)){
			// TODO: check which fatal time is used there
			endTime = now + KKApi.val(FATAL_MISSILE_TIME) * 1000.0;
			userInterface.enableTime();
		}
		warZone.visible = false;
		lastZone = now;
		lastMissile = now;
		for (mine in foesMines){
			gameLayer.removeChild(mine);
			// TODO: mine explose
		}
		tank.setBounds(null);
		foesMines = new List();
		if (!gameover)
			setWarning(new Rainbow1());
	}

	function setWarning( w:Warning ){
		if (warning != null){
			delAnimation(warning);
			if (warning.parent != null)
				warning.parent.removeChild(warning);
		}
		warning = w;
	}

	function launchMissiles(){
		if (missiles.length >= 10 || (now - lastMissile) <= 1500 || Math.random() < 0.3)
			return;
		lastMissile = now;
		lastMissileK++;
		var angle = tank.angle;
		switch (lastMissileK % 3){
			case 0:
				var coord = { x:tank.x, y:tank.y };
				Geom.moveAngle(coord,  angle, tank.direction * tank.speed * 30);
				new XMissile(coord.x, coord.y);
			case 1:
				for (i in 0...3){
					angle = angle + (15 - Std.random(30));
					var coord = { x:tank.x, y:tank.y };
					Geom.moveAngle(coord, angle, tank.direction * tank.speed * 30);
					new XMissile(coord.x, coord.y, 0.5*i);
				}
			case 2:
				var coord = { x:tank.x, y:tank.y };
				Geom.moveAngle(coord, angle, tank.direction * tank.speed * 30);
				new XMissile(coord.x, coord.y, 0.0);
				var relative = { x:coord.x-tank.x, y:coord.y-tank.y };
				Geom.rotate(relative, Math.PI/3);
				new XMissile(tank.x + relative.x, tank.y + relative.y, 0.5);
				var relative = { x:coord.x-tank.x, y:coord.y-tank.y };
				Geom.rotate(relative, -Math.PI/3);
				new XMissile(tank.x + relative.x, tank.y + relative.y, 0.5);
		}
	}
}
