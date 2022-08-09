package game.viewer;

import game.viewer.TransitionFunctions;
import GameParameters;
import game.Event;
import game.viewer.State;

/*
 * The Maravision 3000 : Replay a game in flash.
 *
 * Copyright (c) 2010-3000 Bourinette's Crew
 */
class Viewer implements GameListener {
	static var TEND = 999999999;
	public static var DEBUG = false;
	public static var DRAW_EXTRA = false;
	public static var DRAW_FIELD = true;
	public static var instance : Viewer;
	public static var stepPlay : Bool = false;
	static var interpolationsPerResolverFrame = 3;
	static var lastUpdate = 0;
	static var frames = 0;
	static var delay = 0;
	static var stepplay = false;
	static var tipTemplate = new haxe.Template(haxe.Resource.getString("maravision-player-tip.mtt"));
	var id : Int;
	var dataSrc : String;
	var data : game.InitialData;
	public var showIndicators : Bool;
	var root : flash.display.MovieClip;
	var eventTxt : flash.text.TextField;
	var eventSmallTxt : flash.text.TextField;
	var eventTxtTimer : Int;
	var eventTxtDuration : Int;
	var zoom : Float;
	public var field : Field;
	public var resolver: game.Resolver;
	var _state : game.viewer.State;
	var players : IntHash<FieldPlayer>;
	var ball : FieldBall;
	var target : FieldTarget;
	var W : Int;
	var H : Int;
	var FW : Float;
	var FH : Float;
	var jsConnect : haxe.remoting.ExternalConnection;
	var debug : flash.display.Graphics;
	var round : game.viewer.Round;
	var board : game.viewer.Board;
	var eventStack : Array<Event>;
	var gameVersion : Int;
	var animators : List<Animator>;
	var seed : mt.Rand;
	var targetAttempt : Null<Int>;
	var minimumTimeBeforeNextAttempt : Null<Float>;
	var pauseRequest : Bool;
	var maxAttempts : Int;

	function new(){
		instance = this;
		maxAttempts = 90;
		targetAttempt = null;
		showIndicators = false;
		root = flash.Lib.current;
		root.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		W = root.stage.stageWidth;
		H = root.stage.stageHeight;
		reset();
		root.addEventListener(flash.events.Event.ENTER_FRAME, update);
		var params = root.loaderInfo.parameters;
		pauseRequest = Reflect.field(params,"autoplay") != "1";
		if (Reflect.field(params,"rounds") == "3")
			maxAttempts = 3*18;
		GameLog.watcherName = Reflect.field(params, "watcher");
		// The game engine is versionned but we can force any Maravision to play any Game (Debug only)
		gameVersion = Std.parseInt(Reflect.field(params, "gameV"));
		DEBUG = Reflect.field(params, "debug") == "1";
		if (gameVersion != game.Resolver.VERSION){
			if (!DEBUG)
				throw "This Maravision cannot replay the match";
			trace("MARAVISION VERSION ("+game.Resolver.VERSION+") != game VERSION ("+gameVersion+").");
		}
		// Load Data
		var dataUrl = "/sample.txt?v=2";
		if (Reflect.field(params, "dataUrl") != null)
			dataUrl = Reflect.field(params, "dataUrl");
		id = (Reflect.field(params, "gameId") != null) ? Std.parseInt(Reflect.field(params, "gameId")) : 0;
		var request = new haxe.Http(dataUrl);
		request.onData = function(str){
			Viewer.instance.dataSrc = str;
			if (Reflect.field(params, "jump") != null){
				var p = Viewer.instance.pauseRequest;
				Viewer.instance.initReady();
				Viewer.instance.pauseRequest = p;
				Viewer.instance.jumpToTime(Std.parseInt(Reflect.field(params,"jump")));
				try { Viewer.instance.jsConnect.listener.setAttemptId.call([Viewer.instance.resolver.totalAttemptsCounter]); } catch (x:Dynamic){}
			}
			else {
				Viewer.instance.setState(READY);
			}
		}
		request.request(true);
		// Connect to javascript
		if (Reflect.field(params, "jsConnect") != null){
			var context = new haxe.remoting.Context();
			context.addObject("viewer", this);
			jsConnect = haxe.remoting.ExternalConnection.jsConnect("jsConnect",context);
			if (jsConnect != null){
				board = new game.viewer.Board(jsConnect);
				round = new game.viewer.Round();
				jsConnect.listener.setVersion.call([gameVersion, game.Resolver.VERSION]);
			}
		}
		setState(game.viewer.State.INIT);
		// Bind some events
		root.stage.addEventListener(flash.events.Event.RESIZE, onResize);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseClic);
		onResize(null);
		// We can draw there for debug purpose
		var debugS = new flash.display.Sprite();
		root.addChild(debugS);
		debug = debugS.graphics;
	}

	inline public function getState() : game.viewer.State {
		return _state;
	}

	inline function setState( s:game.viewer.State ){
		_state = s;
		if ((_state == INIT || _state == READY) && pauseRequest){
		}
		else if (_state == PLAY)
			jsConnect.listener.setPlay.call([true]);
		else {
			pauseRequest = false;
			jsConnect.listener.setPlay.call([false]);
		}
	}

	function jumpToTime( attempt:Int ){
		if (data == null)
			return;
		attempt = Std.int(Math.max(0, attempt));
		attempt = Std.int(Math.min(attempt, maxAttempts));
		pauseRequest = pauseRequest || (getState() == PAUSE);
		targetAttempt = attempt;
		if (resolver.totalAttemptsCounter >= attempt){
			reset();
			initReady();
		}
		while (resolver.totalAttemptsCounter < attempt && resolver.next()){}
		targetAttempt = null;
		for (animator in animators)
			animator.resolverFrame(0);
		field.update();
		field.clearAnims();
		delay = 0;
		setState(pauseRequest ? PAUSE : PLAY);
	}

	function onUiButtonClicked( name:String ){
		switch (name){
			case "btnPlay":
				play();
			case "btnSkip":
				setState(OVER);
		}
	}

	function reset(){
		animators = new List();
		eventStack = [];
		players = new IntHash();
		var oldField = field;
		ball = null;
		target = null;
		field = new Field();
		seed = new mt.Rand(id);
		lastUpdate = 0;
		frames = 0;
		delay = 0;
		clearArtwork();
		GameLog.reset(new mt.Rand(id));
		FW = field.fieldLayer.width;
		FH = field.fieldLayer.height;
		if (field.rotation == -90 || field.rotation == 90){
			var tmp = FW;
			FW = FH;
			FH = tmp;
		}
		if (oldField == null){
			root.addChild(field);
		}
		else {
			var idx = root.getChildIndex(oldField);
			root.removeChild(oldField);
			root.addChildAt(field, idx);
			onResize(null);
		}
	}

	/* On resize, scale the field. */
	function onResize(_){
		try {
			var PAD_BOTTOM = 30;
			W = root.stage.stageWidth;
			H = root.stage.stageHeight - PAD_BOTTOM;
			field.scaleX = 1;
			field.scaleY = 1;
			zoom = Math.max(1, Math.min(W / FW, H / FH));
			field.scaleX = zoom;
			field.scaleY = zoom;
			if (field.rotation == 90){
				field.x = W/2;
				field.y = (H - FH*zoom) / 2;
			}
			else if (field.rotation == -90){
				field.x = W/2;
				field.y = H;
			}
			else {
				field.x = (W - FW*zoom) / 2;
				field.y = H / 2;
			}
		}
		catch (e:Dynamic){
			trace(e);
		}
	}

	function onMouseClic(e:flash.events.MouseEvent){
		onMouseMove(e);
	}

	function onMouseMove(e:flash.events.MouseEvent){
		var p = findPlayerUnderMouse(e);
		if (p != null){
			var title = GameLog.getPlayerName(p.player);
			var content = GameLog.posName(p.player.pos);
			var content = tipTemplate.execute({
				name: StringTools.htmlEscape(title),
				pos: StringTools.htmlEscape(GameLog.posName(p.player.pos)),
				p: p.player,
				spirit: Math.round(p.player.getMoraleFactor() * 100)+"%"
			});
			var mouse = new geom.PVector3D(e.stageX, e.stageY);
			jsConnect.listener.showPlayerToolTip.call([
				Math.round(mouse.x),
				Math.round(mouse.y),
				title,
				content
			]);
		}
		else {
			jsConnect.listener.showPlayerToolTip.call([]);
		}
	}

	public function playerClicked(p:FieldPlayer){
		try {
			setState(PAUSE);
			jsConnect.listener.playerClicked.call([
				GameLog.getPlayerName(p.player),
				p.player.getFullFace(),
				{ power:p.player.power, agility:p.player.agility, accuracy:p.player.accuracy, endurance:p.player.endurance, charisma:p.player.charisma },
				Lambda.array(Lambda.map(p.player.competencesList, function(c) return {
					name:c.name,
					desc:c.desc,
					icon:c.icon,
				})),
				Lambda.array(Lambda.map(p.player.vicesList, function(v) return {
					name:v.name,
					desc:v.desc,
				})),
			]);
		}
		catch (e:Dynamic){
		}
		trace(p.player);
		trace((p.player.currentState != null) ? p.player.currentState.toString(p.player) : "no state");
		trace("team leader="+(p.player.team.leader == null ? 'null' : Std.string(p.player.team.leader.pos)));
		trace(resolver.stateToString());
		trace("- velocity = "+p.player.velocity);
		trace("- steering = "+p.player.steering);
		trace("- accelera = "+p.player.acceleration);
	}

	function findPlayerUnderMouse(e:flash.events.MouseEvent){
		var mouse = new geom.PVector3D( (e.stageX - field.x)/zoom, (e.stageY - field.y)/zoom);
		if (field.rotation != 0){
			mouse.rotateZ(-field.rotation/180 * Math.PI);
		}
		var candidates = [];
		for (p in players){
			var d = p.position.distance(mouse);
			if (d <= 4)
				candidates.push({ d:d, p:p });
		}
		if (candidates.length == 0)
			return null;
		candidates.sort(function(a,b) return Reflect.compare(a.d, b.d));
		return candidates[0].p;
	}

	function update(_){
		try {
			mt.Timer.update();
			lastUpdate = flash.Lib.getTimer();
			inputs();
			frames++;
			updateBigText();
			logic();
			lastUpdate = flash.Lib.getTimer() - lastUpdate;
		}
		catch (e:Dynamic){
			trace("ERROR: "+Std.string(e));
			trace(haxe.Stack.exceptionStack().join("\n"));
			root.removeEventListener(flash.events.Event.ENTER_FRAME, update);
		}
	}

	function updateSprites(?skipAnim=false){
		field.update();
		for (p in players)
			p.update();
		if (ball != null){
			ball.update();
			target.update(resolver.ballDest, resolver.ball.isFlying);
		}
	}

	// Keyboard inputs for debug purpose
	function inputs(){
		if (!DEBUG)
			return;
		Key.update();
		if (Key.ENTER.isDown){
			// Key.ENTER.isDown = false;
		}
		if (Key.ADD.isDown){
			Key.ADD.isDown = false;
			showIndicators = !showIndicators;
		}
		if (Key.DELETE.isDown){
			Key.DELETE.isDown = false;
			for (t in [resolver.attTeam, resolver.defTeam]){
				trace("Team "+t.name);
				for (p in t.players){
					trace("Player "+p.name+" at "+p.pos+" life="+p.life);
					if (p.currentState != null)
						trace(p.currentState.toString(p));
				}
			}
		}
		if (Key.SPACE.isDown){
			Key.SPACE.isDown = false;
			stepplay = true;
			setState(PLAY);
		}
		else if (DEBUG && Key.X.isDown){
			Key.X.isDown = false;
			for (k in players.keys()){
				delay = 15;
				if (!isForwarding()){
					var fp = players.get(k);
					var anim = new ViceAnim(fp);
					field.aboveFxLayer.addChild(anim);
					field.anims.push(cast anim);
				}
			}
		}
	}

	// Data loaded, feed maravision
	function initReady(){
		data = haxe.Unserializer.run(dataSrc);
		resolver = new game.Resolver(data);
		GameLog.resolver = resolver;
		target = new FieldTarget();
		ball = new FieldBall(resolver.ball);
		animators.push(new game.viewer.Animator(resolver.ball, ball));
		resolver.addEventListener(this);
		setState(pauseRequest ? PAUSE : PLAY);
	}

	function logic(){
		try {
			switch (getState()){
				case game.viewer.State.INIT:

				case game.viewer.State.READY:
					initReady();

				case game.viewer.State.PLAY:
					if (pauseRequest){
						setState(PAUSE);
						return;
					}
					var hasAnim = Lambda.exists(animators, function(p:Animator) return p.autoAnimated);
					if (hasAnim)
						for (animator in animators)
							animator.update();
					if (delay > 0){
						--delay;
						--frames;
						field.update();
						return;
					}
					if (hasAnim){
						--frames;
						return;
					}
					if (frames % interpolationsPerResolverFrame == 0){
						if (eventStack.length > 0){
							onEvent(eventStack.shift());
						}
						else {
							var end = !resolver.next();
							interpolationsPerResolverFrame = if (resolver.state == game.GameState.THROW) 8 else if (resolver.state == game.GameState.FLY) 2 else 2;
							for (animator in animators)
								animator.resolverFrame(interpolationsPerResolverFrame);
							if (end)
								setState(OVER);
						}
					}
					else {
						for (animator in animators)
							animator.update();
					}
					field.update();
					return;

				case PAUSE:
				case OVER:
				case ERROR:
			}
		}
		catch (e:Dynamic){
			trace("ERROR state="+getState());
			trace(Std.string(e));
			trace(haxe.Stack.exceptionStack().join("\n"));
			setState(ERROR);
		}
	}

	function isForwarding() : Bool {
		return targetAttempt != null;
	}

	function clearArtwork(){
		minimumTimeBeforeNextAttempt = null;
		try { jsConnect.listener.setEventArt.call([null,null,null]); } catch (e:Dynamic) {}
	}

	public function onEvent( e:game.Event ){
		if (delay > 0 && !isForwarding()){
			eventStack.push(e);
			return;
		}
		// trace(resolver.time+" "+Std.string(e));
		if (jsConnect != null){
			var str = GameLog.eventToString(e);
			if (str != null)
				jsConnect.listener.addEventLog.call([str]);
			var art = GameLog.eventArtwork(e);
			if (art != null){
				jsConnect.listener.setEventArt.call([art.team, art.img, art.title]);
				minimumTimeBeforeNextAttempt = flash.Lib.getTimer() + 2000;
			}
			if (round != null){
				round.onEvent(e);
				jsConnect.listener.setRound.call([round.text]);
			}
			if (board != null){
				board.onEvent(e);
			}
		}
		switch (e){
			case DefPlayer(team, pl):
				var pd = resolver.playersHash.get(pl.id);
				var p = new FieldPlayer(team.id, pd);
				field.addPlayer(p);
				players.set(pl.id, p);
				animators.push(new Animator(pd, p));
			case DefStart:
				if (jsConnect != null)
					jsConnect.listener.reset.call([]);
			case DefEnd:
				field.addTarget(target);
				field.addBall(ball);
			case HalfTime:
				delay = 240;
				bigText("MI-TEMPS", 0xFFFFFF);
			case NextAttempt(r,p,b,a):
				ball.respawn();
				delay = 10;
				if (jsConnect != null && seed.random(200) < 5){
					try {
						var str = GameLog.getAmbiant();
						if (str != null)
							jsConnect.listener.addEventLog.call([str]);
					}
					catch (x:Dynamic){
						haxe.Firebug.trace(Std.string(x));
					}
				}
			case PicoSafe(pId):
				if (ball != null)
					ball.kill();
				if (!isForwarding())
					field.addPunchAnim(resolver.ball.position, 0xFF0000, true);
				bigText("SAUVE", 0xFFFFFF);
				smallText("tentative suivante", 0xFFFFFF);
			case PicoPafAttempt(p):
				if (!isForwarding())
					field.addPunchAnim(players.get(p.id));
			case PicoPaf(id):
				ball.kill();
				if (!isForwarding())
					field.addPunchAnim(resolver.ball.position, 0xFF0000, true);
				bigText("SPLATCH", 0xFFFFFF);
				smallText("1 point pour l'attaque", 0xFFFFFF);
			case PicoStar:
				ball.kill();
				if (!isForwarding())
					field.addPunchAnim(resolver.ball.position, 0xFF0000, true);
				bigText("PICOSTAR", 0xFFFFFF);
				smallText("1 point pour l'attaque", 0xFFFFFF);
			case Hit(att, def, life, lostBall):
				if (!isForwarding())
					field.addPunchAnim(players.get(att.id), true);
			case Recovered(pId):
			case AttScore,AttFailed:
				delay = 60;
			case DefFault(x):
				delay = 60;
				bigText("FAUTE", 0xFF0000);
				smallText("1 point pour l'attaque", 0xFF0000);
			case Strike,FalseStrike:
				if (ball != null){
					ball.kill();
					field.addPunchAnim(resolver.ball.position, 0xFF0000, true);
				}
				delay = 120;
				bigText("STRIKE", 0xFFFFFF);
				smallText("tentative suivante", 0xFFFFFF);
			case DebugPos(p):
				var s = new FieldTarget(0xFF0000);
				s.update(p, true);
				field.addChild(s);
			case ViceActive(p,v):
				delay = 30;
				if (!isForwarding()){
					var fp = players.get(p.id);
					var anim = new ViceAnim(fp);
					field.aboveFxLayer.addChild(anim);
					field.anims.push(cast anim);
				}
			case PicoOut:
				ball.kill();
			case Ground(dist):
			case Winner(t):
			case GiveUp(t):
			case Draw:
			case RoundStart:
			case TooShort:
			case TooMuchKo(t):
			case ThrowFault,FalseThrowFault:
				ball.kill();
			case PreThrow:
				if (stepPlay && !isForwarding())
					setState(PAUSE);
				if (!isForwarding())
					clearArtwork();
			case Throw(k,c):
				delay = 10 + seed.random(50);
				if (!isForwarding() && c != null){
					var bubble = new Bubble(players.get(resolver.thrower.id), "/img/comps/"+c.icon+".jpg");
					field.aboveFxLayer.addChild(bubble);
					field.anims.push(cast bubble);
				}
			case Replace(o,i,p):
				delay = 120;
				bigText("Remplacement", 0xFFFFFF);
			case BatTry:
				if (!isForwarding())
					field.addPunchAnim(players.get(resolver.battler.id), 0xFFFFFF, false);
			case RefereeJocker(_):
			case Push(_):
			case PlayerDisabled(_):
			case AttemptEnd:
				if (!isForwarding()){
					try { jsConnect.listener.setAttemptId.call([resolver.totalAttemptsCounter]); } catch (x:Dynamic){}
					var now = flash.Lib.getTimer();
					if (minimumTimeBeforeNextAttempt != null && now < minimumTimeBeforeNextAttempt){
						delay = Math.ceil((minimumTimeBeforeNextAttempt - now) * 60 / 1000.0);
					}
				}
			case PhaseStart(_):
			case NextBattler(_):
				// delay = 60;
				var n : Int = (untyped resolver.batNumber);
				var t = switch (n){
					case 0: "Premier batteur";
					case 1: "Second batteur";
					case 2: "Troisième batteur";
				}
				bigText(resolver.attTeam.name, 0xFFFFFF);
				smallText(t, 0xFFFFFF);
			case Ko(p):
				delay = 60;
			case Injure(_):
				delay = 60;
			case HasPicoron(_):
			case Fault(t,pId):
				delay = 120;
				bigText("FAUTE", 0xFF0000);
			case CompetenceActive(p, c):
				delay = 90;
				if (!isForwarding()){
					var fp = players.get(p.id);
					var anim = new CompetenceAnim(fp);
					field.belowFxLayer.addChild(anim);
					field.anims.push(cast anim);

					var bubble = new Bubble(fp, "/img/comps/"+c.icon+".jpg");
					field.aboveFxLayer.addChild(bubble);
					field.anims.push(cast bubble);
				}
			case CompetenceActive2(p, o, c):
				delay = 90;
				if (!isForwarding()){
					var fp = players.get(p.id);
					var tp = players.get(o.id);
					var anim = new CompetenceAnim(fp, tp);
					field.belowFxLayer.addChild(anim);
					field.anims.push(cast anim);
					var bubble = new Bubble(fp, "/img/comps/"+c.icon+".jpg");
					field.aboveFxLayer.addChild(bubble);
					field.anims.push(cast bubble);
				}
			case Bobo(_):
				delay = 60;
			case BattlerTricked(b,t,m):
			case BattlerNotTricked(b,t):
			case BattlerCannotPlayAttempt(n):
			case Battled:
			case BatFault:
				delay = 120;
				bigText("FAUTE", 0xFF0000);
			case AttFault:
				delay = 120;
				bigText("FAUTE", 0xFF0000);
			case ItemDamaged(p),ItemDestroyed(p):
				delay = 20;
				if (!isForwarding()){
					var fp = players.get(p.id);
					var anim = new ViceAnim(fp);
					field.aboveFxLayer.addChild(anim);
					field.anims.push(cast anim);
				}
			case RefereeIsWaitingThrower(pId):
				delay = 10;
			case UseDrug(p, d):
				delay = 40;
				if (!isForwarding()){
					var fp = players.get(p.id);
					var anim = new CompetenceAnim(fp);
					field.belowFxLayer.addChild(anim);
					field.anims.push(cast anim);
				}
			case DrugFault(seen, p, d):
			case HooliganAlone(t, h):
			case HooliganDraw(hA, hB, s):
			case HooliganFight(tA, hA, sA, tB, hB, sB):
		}
	}

	function updateBigText(){
		if (eventTxt == null && eventSmallTxt == null)
			return;
		eventTxtTimer++;
		if (eventTxtTimer >= eventTxtDuration){
			if (eventTxt != null){
				eventTxt.parent.removeChild(eventTxt);
				eventTxt = null;
			}
			if (eventSmallTxt != null){
				eventSmallTxt.parent.removeChild(eventSmallTxt);
				eventSmallTxt = null;
			}
		}
		else {
			var stay = 60;
			var ratio = (eventTxtTimer <= stay)
				? 0.0
				: TransitionFunctions.get(Pow(3.0))((eventTxtTimer-stay) / (eventTxtDuration-stay));
			if (eventTxt != null)
				eventTxt.alpha = 1 - ratio;
			if (eventSmallTxt != null)
				eventSmallTxt.alpha = 1 - ratio;
		}
	}

	function bigText( str:String, color:UInt ){
		if (isForwarding())
			return;
		str = str.toUpperCase();
		if (eventTxt != null && eventTxt.parent != null)
			eventTxt.parent.removeChild(eventTxt);
		eventTxt = new flash.text.TextField();
		eventTxt.mouseEnabled = false;
		eventTxt.selectable = false;
		eventTxt.textColor = color;
		eventTxt.x = 0;
		eventTxt.width = W;
		eventTxt.y = H/5.5;
		var format = new flash.text.TextFormat();
		format.font = "Arial Black";
		format.size = 30;
		format.align = flash.text.TextFormatAlign.CENTER;
		eventTxt.text = str;
		eventTxt.setTextFormat(format);
		var r = Math.round(((color & 0xFF0000) >> 16) / 2);
		var g = Math.round(((color & 0x00FF00) >> 8) / 2);
		var b = Math.round((color & 0x0000FF) / 2);
		var shadow = r << 16 | g << 8 | b;
		eventTxt.filters = [
			new flash.filters.GlowFilter(color, 0.8, 2, 2, 2, 2),
			new flash.filters.DropShadowFilter(0.0, 0.0, shadow, 1, 10, 10, 1)
		];
		// eventTxt.blendMode = flash.display.BlendMode.SCREEN;
		eventTxtDuration = 90;
		eventTxtTimer = 0;
		root.addChild(eventTxt);
	}

	function smallText( str:String, color:UInt ){
		if (isForwarding())
			return;
		str = str.toUpperCase();
		if (eventSmallTxt != null && eventSmallTxt.parent != null)
			eventSmallTxt.parent.removeChild(eventSmallTxt);
		eventSmallTxt = new flash.text.TextField();
		eventSmallTxt.textColor = color;
		eventSmallTxt.x = 0;
		eventSmallTxt.width = W;
		eventSmallTxt.y = H/3;
		eventSmallTxt.selectable = false;
		eventSmallTxt.mouseEnabled = false;
		var format = new flash.text.TextFormat();
		format.font = "Arial Black";
		format.size = 30;
		format.align = flash.text.TextFormatAlign.CENTER;
		eventSmallTxt.text = str;
		eventSmallTxt.setTextFormat(format);
		var r = Math.round(((color & 0xFF0000) >> 16) / 2);
		var g = Math.round(((color & 0x00FF00) >> 8) / 2);
		var b = Math.round((color & 0x0000FF) / 2);
		var shadow = r << 16 | g << 8 | b;
		eventSmallTxt.filters = [
			new flash.filters.GlowFilter(color, 0.8, 2, 2, 2, 2),
			new flash.filters.DropShadowFilter(0.0, 0.0, shadow, 1, 10, 10, 1)
		];
		// eventSmallTxt.blendMode = flash.display.BlendMode.SCREEN;
		eventTxtDuration = 90;
		eventTxtTimer = 0;
		root.addChild(eventSmallTxt);
		var format = eventSmallTxt.getTextFormat();
		format.font = "Arial";
		format.bold = true;
		format.size = 14;
		eventSmallTxt.setTextFormat(format);
		eventSmallTxt.y -= 6;
	}

	// Toggle play/pause
	function play(){
		if (getState() == INIT){
			pauseRequest = true;
			jsConnect.listener.setPlay.call([false]);
			return;
		}
		switch (getState()){
			case PLAY:
				pauseRequest = true;
				jsConnect.listener.setPlay.call([false]);

			case PAUSE:
				pauseRequest = false;
				setState(PLAY);

			default:
				pauseRequest = true;
				jsConnect.listener.setPlay.call([false]);
		}
	}

	// Show players' names
	function showNames( b:Bool ){
		if (!isForwarding())
			for (p in players)
				p.pname.visible = b;
	}

	public static function main(){
		try {
			haxe.Serializer.USE_ENUM_INDEX = true;
			mt.Timer.wantedFPS = 60;
			Key.init();
			var params = flash.Lib.current.loaderInfo.parameters;
			Viewer.DRAW_FIELD = Reflect.field(params, "hi") == null;
			if (Reflect.field(params, "watcher") == "yota")
				haxe.Firebug.redirectTraces();
			else
				haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos){}
			if (Reflect.field(params, "debug") != null)
				Bufferer.IMMEDIATE_FLUSH = true;
			if (Reflect.field(params, "txtOnly") != null)
				new Bufferer();
			else
				new Viewer();
		}
		catch (e:Dynamic){
			trace(Std.string(e));
			trace(haxe.Stack.exceptionStack().join("\n"));
		}
	}
}
