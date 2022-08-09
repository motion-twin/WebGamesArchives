import mt.bumdum9.Lib;
import mt.DepthManager;
import api.AKApi;
import api.AKProtocol;
import mt.bumdum9.Lib;
import mt.deepnight.Tweenie;
/**
 * LEVEL
 */
enum GStep {
	GInit;
	//GMove;
	GShake;
	GPlay;
}
	
typedef Matrix = Array<Array<Item>>;

class Level extends flash.display.Sprite
{
	//DM plans
	public static var DM_BACKGROUND = 1;
	public static var DM_BLOCKS = 2;
	public static var DM_CENTER	= 4;
	public static var DM_LIGHT	= 3;
	public static var DM_FX 	= 6;

	public var levelNum:Int;
	
	public var dm : DepthManager;
	public var items : Array<Array<Item>>;
	//public var itemsGfx : Array<Array<gfx.Item>>; //par cycle
	public static var CENTER = new PT(300, 230);
	public static var ANGLE = (Math.PI * 2) / 12;
	public static var MOVE_ANIM_DURATION = 10;
	public static var SHAKE_ANIM_DURATION = 20;
	public static var COLORS_NUM = 5;
	public static var ROUND_DURATION = 700;
	public static var ROUND_NUM = 12;
	
	public static var COLORS_NAME = ["zero", "vert", "jade", "rouge", "or", "noir","pierre","vide"];
	public static var COLORS_VAL = [0, 0x3D2E8D, 0x11A994, 0xB00800, 0xFFCC00, 0xAAAAAA];
	
	public static var LINE_PTS = 30;
	public static var EXTRALINE_PTS = 100;
	public static var CATACLISMO_PTS = 300;
	
	var noOnRelease:Bool;
	var isDragging:Bool;
	
	var mouse : gfx.Mouse;
	
	var step : GStep;
	var round:Int;
	var roundObjective:Int;
	var roundTimer:Int;
	
	var movePointerFx:mt.fx.Fx;
	
	var lastCycle:Int;
	//move block stuff
	//var moveTimer : Int;
	//var cycleMove : Int;
	//var cycleMoveLeft : Bool;
	var moveOffsets : Array<Int>; //cycle / 0:nothing, -1:left, 1:right;
	var moveTimers : Array<Int>; //move timers for each cycle
	
	//drag n drop
	var dragSelect : Int; //cycle selected, -1 = none
	var dragAngle : Float;
	
	//var regenTimer:haxe.Timer;
	var shakeFxs:List<mt.fx.Fx>;
	var shakeItems:List<Item>;

	var centerItem:ui.Center;
	var serpent : gfx.Serpent;
	var serpentState : Bool;

	public static var me:Level;

	var lava:gfx.Lava;
	var lg:LevelGenerator;
	var bg:flash.display.Bitmap;
	
	var age:Int;
	
	var _mouseX:Float;
	var _mouseY:Float;
	
	var tip:ui.Tip;
	
	
	//stuff to clean when cancel move
	var fxs : Array<mt.fx.Fx>;
	var mcs : Array<flash.display.Sprite>;
	
	
	public function new(l = 1)
	{
		super();
		me = this;
		dm = new DepthManager(this);
		moveOffsets = [0, 0, 0, 0];
		moveTimers = [-1, -1, -1, -1]; //no moves
		setStep(GInit);
		levelNum = l;
		shakeFxs = new List<mt.fx.Fx>();
		shakeItems = new List<Item>();
		roundTimer = 0;
		age = 0;
		noOnRelease = false;
		isDragging = false;
		round = 1;
		serpentState = false;
		
		// BG
		bg = new flash.display.Bitmap(new ui.Background(Game.WIDTH,Game.HEIGHT));
		dm.add(bg,DM_BACKGROUND);
		
		//lava
		lava = new gfx.Lava();
		lava.filters = [new flash.filters.GlowFilter(0xAA0000)];
		lava.masque.stop();
		dm.add(lava,DM_BACKGROUND);
		
		// BG
		var bg = new SP();
		bg.graphics.beginFill(0x666666);
		bg.graphics.drawRect(0, 0, Game.WIDTH, Game.HEIGHT );
		bg.alpha = 0;
		dm.add(bg, DM_BLOCKS);
		
		//drag
		dragSelect = -1;
		dragAngle = 0;
		lastCycle = -1;
		
		if(AKApi.isReplay()) {
			mouse = new gfx.Mouse();
			//mouse.stop();
			mouse.filters = [new flash.filters.DropShadowFilter(5, 45, 0, 1)];
			dm.add(mouse, DM_CENTER);
		}
		
		/*CONTROLS*/
		if(!AKApi.isReplay()) {
			addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(_) AKApi.emitEvent(1) );
			addEventListener(flash.events.MouseEvent.MOUSE_UP, function(_) AKApi.emitEvent(2) );
		}
		
		/*rounds duration*/
		ROUND_DURATION = getRoundDuration();
		
		/*center*/
		centerItem = new ui.Center();
		centerItem.x = CENTER.x;
		centerItem.y = CENTER.y;
		
		dm.add(centerItem, DM_CENTER);
		
		serpent = new gfx.Serpent();
		serpent.x = CENTER.x;
		serpent.y = CENTER.y;
		serpent.alpha = 0;
		dm.add(serpent, DM_CENTER);
		
		fxs = [];
		mcs = [];
		
		//flecheDirLeft = new gfx.FlecheDir();
		//flecheDirLeft.x = 157;
		//flecheDirLeft.y = 18;
		//flecheDirLeft.scaleX = 0 - flecheDirLeft.scaleX;
		//dm.add(flecheDirLeft,DM_BLOCKS);
		//flecheDirRight = new gfx.FlecheDir();
		//flecheDirRight.x = 442;
		//flecheDirRight.y = 20;
		//dm.add(flecheDirRight,DM_BLOCKS);
		
		items = [];
		
		/* Build level */
		if(AKApi.getGameMode() == GM_PROGRESSION) {
			levelNum = api.AKApi.getLevel();
		}else {
			//to get 5 colors
			levelNum = 1;
		}
		lg = new LevelGenerator(levelNum,1);
		items  = lg.generate();
		centerItem._txt.text = Std.string(lg.linesNum);
		roundObjective = lg.linesNum;
		
		randomize(true);
		redraw();
		
		moveOffsets = [0, 0, 0, 0];
		setStep(GPlay, "jeu pret");
		
		//trace('orginal');
		//dumpMatrix();
		//var f = copy(items);
		//f[0][0].color = 99;
		//trace('copie modifiée');
		//dumpMatrix(f);
		//trace('orginal');
		//dumpMatrix();
		
		if(levelNum == 1 && AKApi.getGameMode() == GM_PROGRESSION) {
			
			
			FTimer.delay(function() {
				
				//"your objective is X lines"
				var t = Text.make_x_lines({_lines:roundObjective});
				tip = new ui.Tip(t, 1);
				dm.add(tip, DM_FX);
				new mt.fx.Spawn(tip);
				tip.x = CENTER.x;
				tip.y = CENTER.y + 30;
			},60);
			
			FTimer.delay(function(){
				//" moves circles "
				var t = Game.me.tweener.create(tip, 'x', tip.x - 110);
				tip._txt.text = "";
				
				t.onEnd = function() {
					if(tip!=null){
						tip.gotoAndStop(2);
						tip._txt.text = Text.move_circles;
					}
				}
			},200);
		}
	}
	
	
	function displayTip(text:String) {
		if(tip!=null && tip.parent != null) tip.parent.removeChild(tip);
		tip = new ui.Tip(text, 1);
		dm.add(tip, DM_FX);
		new mt.fx.Flash(tip);
		tip.x = CENTER.x;
		tip.y = CENTER.y + 30;
	}
	
	function removeTip() {
		if(tip != null) {
			var fx = new mt.fx.Vanish(tip, 10, 10, true);
			fx.onFinish = function() tip = null;
		}
	}
	
	/**
	 * round duration in frames
	 */
	function getRoundDuration() {
		if(levelNum == 1) return 5000;
		var dur = 200 + Math.floor(800 * (1 - levelNum / 20));
		if(dur < 100) dur = 100;
		
		return dur;
	}
	
	function check() {
		//trace("CHECK!");
		
		var lines = checkLines();
		
		/* LINES ! */
		if(lines.length > 0 && lines.length < roundObjective) {
			for(id in lines) {
				for(x in 0...4) {
					new mt.fx.Shake(items[x][id].mc, 5, 5);
				}
			}
			if(levelNum < 4) {
				displayTip( Text.more_lines );
				FTimer.delay(function() {
					removeTip();
				},50);
			}
		}
		
		if(lines.length > 0 && lines.length >= roundObjective) {
			
			setStep( GShake );
			
			/*flash*/
			for(id in lines) {
				for(i in 0...4) {
					FTimer.delay(function() {
						var f = new mt.fx.Flash(items[i][id].mc);
					},i + 1);
					fxs.push( new fx.Vibrate(items[i][id].mc, 3, 3,100,'out'));
				}
			}
			
			doSerpent(true);
			/*after SHAKE_ANIM_DURATION*/
			FTimer.delay(function() {
				var wonpks = [];
				for(id in lines){
					for(cycle in 0...4) {
						var item  = items[cycle][id];
						//trace('DESTROY ITEM '+item);
						/*light FX*/
						if(cycle == 0) {
							FTimer.delay(function(){
								doLight(item);
							},item.id * 2);
						}
						
						FTimer.delay(function() {
							setStep(GInit); //lock moves from now
							
							/*explode items*/
							var part = new mt.fx.Part<flash.display.Sprite>(item.mc);
							part.vx = 40 * Math.cos((item.id-2)*ANGLE);    //pourquoi item.id-2 ?????
							part.vy = 40 * Math.sin((item.id-2)*ANGLE);
							part.frict = 0.95;
							//trace("id "+item.id+", x ="+part.vx+", y="+part.vy);
							part.weight = 1 * Math.pow(item.cycle + 1, 2);
							part.onBounceGround = part.kill;
							part.setGround(480, 0.9, 0.9);
							
							var mode = AKApi.getGameMode();
							/*PK anim*/
							if(item.pk !=null && item.pk.amount.get() > 0)	{
								var pos = getPosAt(item.cycle, item.id);
								//trace(pos+" "+item.pk+" PK");
								new fx.Pointer(5, item.pk.amount.get(), dm, pos.x, pos.y);
								wonpks.push(item.pk);
							}
							
							/*pop points*/
							if(mode == GM_LEAGUE && item.cycle==2) {
								var pos = getPosAt(item.cycle, item.id);
								new fx.Pointer(6, getScore(lines.length), dm, pos.x, pos.y);
							}
							
							/*sparkles*/
							for(i in 0...7) {
								doSparkles(item,i);
							}
						},(item.id * 2) + 20);
					}
				}
				
				FTimer.delay(function(){
					//trace("wonpk : "+Lambda.map(wonpks, function(c) return c.amount.get()));
					for(x in wonpks) {
						trace("take " + x.amount.get() + "PK in game");
						AKApi.takePrizeTokens(x);
					}
				},12 * 2 + 20 + 1);

			},SHAKE_ANIM_DURATION);
			
			/* next round */
			//copy vars for later display
			var roundObjectiveCopy = roundObjective;
			var linesCopy = lines.copy();
			var roundTimerCopy = roundTimer;
			FTimer.delay(function() {

				//clean
				for(id in lines){
					for(cycle in 0...4) {
						items[cycle][id].init(Item.TYPE_EMPTY, 0, id, cycle);
					}
				}
				lava.masque.gotoAndStop(1);
				
				dm.clear(DM_FX);
				dm.clear(DM_LIGHT);
				
				roundObjective -= lines.length;
				centerItem._txt.text = Std.string(Math.min(0, roundObjective));
				centerItem.resetPos();
				serpent.x = CENTER.x;
				serpent.y = CENTER.y;
				
				AKApi.addScore(AKApi.const(linesCopy.length * getScore(linesCopy.length)));
					
				if(AKApi.getGameMode() == GM_PROGRESSION) {
					/*PROGRESSION*/
					api.AKApi.setProgression(getProgression());
				}else{
					/*LEAGUE*/
					if(isCataclismo(linesCopy)) {
						doCataclismo();
					} else 	if(linesCopy.length > roundObjectiveCopy) {
						/*extra lines*/
						var b :Int = linesCopy.length - roundObjectiveCopy;
						doExtraLines(b);
					}
				
					levelNum++;
					ROUND_DURATION  = getRoundDuration();
					trace("LEAGUE : round duration:"+ROUND_DURATION+" pseudolevel:"+levelNum);
				}
				
				round++;
				if(AKApi.getGameMode() == GM_PROGRESSION && AKApi.getScore() >= roundObjective && round > ROUND_NUM) {
					/*PROGRESSION*/
					gameOver(true);
					return;
				}else {
					/*LEAGUE*/
					trace("ROUND " + round);
					var mc = [];
					for(cycle in 0...4) {
						for ( id in 0...12) {
							mc.push(items[cycle][id].mc);
						}
					}
					var lg = new LevelGenerator(levelNum,round);
					items = lg.generate();
					roundObjective = lg.linesNum;
					centerItem._txt.text = Std.string(lg.linesNum);
					randomize();
					redraw(null, null, true, mc);
					
					FTimer.delay(function() {
						step = GPlay;
					},4 * 12 + 12);
				}
				
				roundTimer = 0;
				doSerpent(false);
				
			},SHAKE_ANIM_DURATION+60);
		}
		
	}
	
	/**
	 * score par ligne faites
	 */
	function getScore(linesNum) {
		if(AKApi.getGameMode() == GM_PROGRESSION) {
			return 10;
		}else {
			return  10  + Math.round((1-roundTimer/getRoundDuration())*20) ;
		}
	}
	
	
	function doLight(item:Item) {
		var light = new gfx.Light();
		dm.add(light,DM_LIGHT);
		light.x = CENTER.x;
		light.y = CENTER.y;
		light.alpha = 0.4;
		light.blendMode = flash.display.BlendMode.ADD;
		new mt.fx.Blink(light,100,1,1);
		light.rotation = (item.id + 1) * (360 / 12);
		var c = Col.colToObj(COLORS_VAL[item.color]);
		light.transform.colorTransform = new flash.geom.ColorTransform(c.r / 256, c.g / 256, c.b / 256);
		mcs.push(light);
	}
	
	
	function doSparkles(item:Item,i:Int) {
		var star = new gfx.Star();
		star.blendMode = flash.display.BlendMode.ADD;
		addChild(star);
		var s = new mt.fx.Part<flash.display.Sprite>(star);
		s.vx = 15 * Math.cos((item.id-2)*ANGLE) + (Std.random(10)-5);    //pourquoi item.id-2 ?????
		s.vy = 15 * Math.sin((item.id-2)*ANGLE) + (Std.random(10)-5);
		s.setPos(CENTER.x + (s.vx*3), CENTER.y + (s.vy*3));
		s.weight = Math.random()+0.2;
		s.setScale(Math.random() + 0.1);
		s.onBounceGround = s.kill;
		s.setGround(480, 0.9, 0.9);
		
		if(i%10<6){
			var c = Col.colToObj(COLORS_VAL[item.color]);
			s.root.transform.colorTransform = new flash.geom.ColorTransform(c.r / 256, c.g / 256, c.b / 256);
		}
	}
	
	function doExtraLines(b) {
		var extralines = new fx.ExtraBonus(dm, CENTER.x+20, CENTER.y - 50);
		extralines.mc._txt1.text = "Extra Lines";
		
		var extra = b * EXTRALINE_PTS;
		extralines.mc._txt2.text = "+" + extra +"Pts";
		AKApi.addScore(AKApi.const(extra));
	}
	
	function doCataclismo() {
		
		var c = new fx.ExtraBonus(dm, CENTER.x+20, CENTER.y - 50);
		c.mc.scaleX = c.mc.scaleY = 1.4;
		c.mc._txt1.text = "Cataclismo !";
		c.mc._txt2.text = "+" + CATACLISMO_PTS +"Pts";
		
		new fx.Vibrate(c.mc, 8, 8,40,'in');
		new mt.fx.Flash(c.mc);
		
		AKApi.addScore(AKApi.const(CATACLISMO_PTS));
	}
	
	/**
	 * compte lignes de meme couleur
	 */
	function checkLines(?matrix:Matrix):Array<Int> {
		if(matrix == null) {
			matrix = items;
		}
		var lines = [];
		
		for(id in  0...12) {
			var color = 0;
			var colorCount = 1;
			//trace("check id " + id);
			for(cycle in 0...4) {
				if(matrix[cycle][id].type == Item.TYPE_STONE) break;
				if(matrix[cycle][id].type == Item.TYPE_EMPTY) break;
				//if(matrix[cycle][id].frozen) break;
				
				if(cycle == 0) {
					//first color
					color = matrix[cycle][id].color;
					//trace(COLORS_NAME[color]+" en cycle 0 de "+id);
				}else if(matrix[cycle][id].color==color) {
						colorCount++;
						//trace(colorCount+" de "+COLORS_NAME[color]+" en "+id);
						if(colorCount == 4) {
							//trace("Ligne de "+COLORS_NAME[color]+" en "+id);
							colorCount = 0;
							lines.push(id);
							break;
						}
				}else {
					//pas besoin de continuer a checker cette id
					break;
				}
			}
		}
		//trace("checklines :" + lines.length);
		return lines;
	}
	
	
	function setStep(mode:GStep,t='') {
		step = mode;
		//trace(step+" "+t );
	}
	
	function getLineAt(id:Int):Array<Item> {
		var out = [];
		for(cycle in 0...4) {
			out.push(items[cycle][id]);
		}
		return out;
	}
	
	function getPosAt(cycle:Int, id:Int): { x:Float, y:Float } {
		var rayon  = 50 + (cycle * 45);
		var angle = (id-2) * (Math.PI*2 / 12);
		
		return { x:CENTER.x + (rayon*Math.cos(angle)), y:CENTER.y + (rayon*Math.sin(angle))};
	}
	
	
	public function getProgression():Float {
		//return points.get() / roundObjective;
		return round / ROUND_NUM;
	}
	
	
	function doSerpent(on = true) {
		if(serpentState == on) return;
		
		if(on) {
			new fx.Vibrate(serpent, 4, 4, 100, 'in');
			new fx.Vibrate(centerItem, 4, 4, 100, 'in');
			serpent.play();
			Game.me.tweener.create(serpent, 'alpha', 1,TEaseIn,200);
			Game.me.tweener.create(serpent, 'scaleX', 1,TEaseIn,300);
			Game.me.tweener.create(serpent, 'scaleY', 1, TEaseIn, 300);
			Game.me.tweener.create(centerItem._bar, 'alpha', 0);
			
		}else {
			serpent.stop();
			haxe.Timer.delay( function() {
				Game.me.tweener.create(serpent, 'alpha', 0, TEaseIn, 600);
			}, 500);
			
			Game.me.tweener.create(serpent, 'scaleX', 0.7,TEaseIn,600);
			Game.me.tweener.create(serpent, 'scaleY', 0.7, TEaseIn,600);
			Game.me.tweener.create(centerItem._bar, 'alpha', 1);
		}
		serpentState = on;
	}
	
	/**
	 * fill empty slots with new blocks
	 */
	//function regenLines(lines:Array<Int>) {
			//FTimer.clear();
		//
			//doSerpent(false);
			//
			//trace("regen lines id "+lines);
			//
			//crazy regens !
			//var r = Game.me.seed.random(2);
			//var crazyRegens = [];
			//if(r >0 ) {
				//for(id in lines) {
					//for (i in 0...r) {
						//var id = Game.me.seed.random(12);
						//crazyRegens.push(id);
						//regenLineStatic(id, LevelGenerator.me.randomColor());
					//}
					//regenLineRandom(id);
				//}
			//}
			//
			///*display*/
			//for(id in lines) redraw(null, id, true);
			//for(id in crazyRegens) redraw(null, id, true);
			//
			//for(c in 0...4)
				//trace( Lambda.map(items[c],function(i) return i.id+"["+(i.mc!=null)+"]" ) );
			//
			///*randomize*/
			//FTimer.delay(function(){
				//randomize();
				//roundTimer = 0;
				//setStep(GInit);
			//},40);
			//
			//
	//}
	//
	/**
	 * regen line with random -but playable- color
	 * @param	id
	 */
	/*function regenLineRandom(id:Int) {
		for(cycle in 0...4) {
					
			// regen item [cycle][id]
			var col = 0;
			var ok = false;
			var fuckInfiniteLoop = 0;
			while(!ok){
				col = LevelGenerator.me.colorSet[Game.me.seed.random(LevelGenerator.me.colorSet.length)];
				trace('regen try '+col);
				//est ce que cette couleur est presente au moins une fois dans les autres cycles
				var count = 0;
				
				for(x in 0...4) {
					if(x == cycle) continue; //je passe mon propre cycle
					
					for(y in 0...12) {
						if(items[x][y] == null) continue;
						//trace("test cycle:" + x + ", id:" + y+" , loop:"+fuckInfiniteLoop);
						fuckInfiniteLoop++;
						if(items[x][y].color == col) {
							count++;	//ok 1 fois dans ce cycle
							break;
						}
					}
					
					if(count >= 3) {
						//trace('cycle '+cycle+' de la ligne '+id+', couleur '+COLORS_NAME[col]+" presente "+count+" fois ");
						ok = true;
						break;
					}
					if(fuckInfiniteLoop >= (11 * 3 * LevelGenerator.me.colorSet.length)) {
						//trace("fuck infinite loop, set "+COLORS_NAME[LevelGenerator.me.cColor]);
						col = LevelGenerator.me.cColor;
						ok = true;
						break;
					}
				}
				
				//init PK
				var pk = null;
				if(igpk.length > 0) {
					
					if(AKApi.getGameMode() == GM_PROGRESSION && (emittedpk / totalpk) < getProgression()) {
						pk = igpk.splice(0, 1)[0];
					}
					
					if(AKApi.getGameMode() == GM_LEAGUE && points.get() > igpk[0].score.get()) {
						pk = igpk.splice(0, 1)[0];
					}
					if(pk!=null) emittedpk += pk.amount.get();
				}
				
				//set this color !
				//trace("new item " + cycle + "@" + id + " color:" + COLOR_NAME[col]);
				items[cycle][id].init(Item.TYPE_NORMAL, col, id, cycle,pk);
			}
		}
	}
	
	function regenLineStatic(id:Int, color:Int) {
		//check stones
		for(cycle in 0...4) {
			if(items[cycle][id].type == Item.TYPE_STONE) return;
		}
		
		for(cycle in 0...4) {
			items[cycle][id].init(Item.TYPE_NORMAL, color, id, cycle,null);
		}
	}*/
	
	
	function cycleHasStone(c) {
		//check stones
			var hasStone = false;
			for(id in 0...12) {
				if(items[c][id].type == Item.TYPE_STONE) {
					hasStone = true;
					break;
				}
			}
			return hasStone;
	}
	
	/**
	 * moves cycles randomly
	 * @param	direct = false
	 */
	function randomize(direct = false) {
		//trace("randomize");
		var m = [0, 0, 0, 0];
		for(c in 0...4) {
			if(cycleHasStone(c)) continue;
			m[c] = Game.random(12)-6;
		}
		
		var tries = 0;
		
		//trace("DEBUG");
		//dumpMatrix(items);
		//trace("DEBUG COPY :");
		//dumpMatrix(copy(items));
		//trace("DEBUG OFFSET [1,0,1,0] :");
		//dumpMatrix(applyRotation( [-1,0,-1,0] ,copy(items)));
		
		
		
		while( checkLines(applyRotation(m, copy(items))).length > 0 && tries<50) {
			tries++;
			//trace("randomize " + tries);
			
			//try another move
			var c = Game.random(4);
			if(cycleHasStone(c)) continue;
			m[c] = Game.random(12)-6;
		}
		
		applyRotation(m, items);
		
		
		//trace('CECI NA PAS DE LIGNES :');
		//dumpMatrix(items);
		//trace('ON APPLIQUE '+m+' :');
		//var x = applyRotation(m, copy(items));
		//dumpMatrix(x);
		
		//update moveTimers
		//for(x in 0...4) {
			//moveTimers[x] += Math.floor(Math.abs(moveOffsets[x])) * MOVE_ANIM_DURATION;
		//}
		
		//no interpolation, direct set the items at the new place.
		//if(direct) {
			//endMove(m);
		//}
		
	}
	
	/**
	 * apply rotation to an item matrix
	 */
	function applyRotation(moves:Array<Int>,?matrix:Matrix) : Matrix {
		
		if(matrix == null) matrix = items;
		
		var original = copy(matrix);
		
		for(cycle in 0...4) {
			if(moves[cycle] == 0) continue;
			for(id in 0...12) {
				var n = (12 + id + moves[cycle]) % 12;
				matrix[cycle][n] = original[cycle][id];
				matrix[cycle][n].id = n;
			}
		}
		
		//
		//for(c in 0...4) {
			//var a = matrix[c].splice(matrix[c].length - moves[c], moves[c]);
			//matrix[c] = a.concat(matrix[c]);
		//}
		
		return matrix;
	}
	
	/**
	 * redraw items
	 * @param	?_cycle		only cycle X
	 * @param	?_id		only id X
	 * @param	fx=false	do flash FX
	 */
	function redraw(?_cycle:Int, ?_id:Int, fx = false, ?oldMcs:Array<Cacheable>) {
		//redraw all
		//trace("REDRAW " + (_cycle == null?'':' CYCLE ' + _cycle) + (_id == null?'':' ID '+_id ));
		for(cycle in 0...4) {
			if(_cycle != null && _cycle != cycle) continue;
			for(id in 0...12) {
				if(_id != null && _id != id) continue;
				var item = 	items[cycle][id];
				
				if(!fx) {
					item.render();
					dm.add(item.mc, DM_BLOCKS);
					item.mc.setCache(false);
				}else {
					
					FTimer.delay(function() {
						
						//remove old clips
						var mc = oldMcs[cycle * 12 + id];
						if(mc!=null && mc.parent!=null) mc.parent.removeChild(mc);
						
						item.render();
						item.mc.setCache(false);
						dm.add(item.mc, DM_BLOCKS);
						
						new mt.fx.Flash(item.mc);
					},cycle*12+id);
				}
			}
		}
	}
	
	
	/**
	 * copy a matrix
	 */
	function copy(input:Matrix){
		//copy matrix in $original
		var original  = new Matrix();
		for(cycle in 0...4) {
			var row = [];
			for(id in 0...12) {
				var i = input[cycle][id];
				var it = new Item();
				it.init(i.type, i.color, i.id, i.cycle,i.pk,i.protected);
				row.push(it);
			}
			original.push(row);
		}
		return original;
	}
	
	
	
	public function update() {
		
		age++;
		//var e : Null<Int> = 0;
		while(true) {
			var e = AKApi.getEvent();
			if(e == null) break;
			if(e == 1) onClick();
			if(e == 2) onRelease();
		}
		
		/* for replays*/
	
		var m = AKApi.getCustomValue( Std.int(this.mouseY>0?this.mouseY:0) * Game.WIDTH + Std.int(this.mouseX>0?this.mouseX:0)  );
		_mouseX = m % Game.WIDTH;
		_mouseY = Math.floor(m / Game.WIDTH);
		if(_mouseX <= 0 || _mouseX >= Game.WIDTH) onRelease();
		if(_mouseY <= 0 || _mouseY >= Game.HEIGHT) onRelease();
		
		if(AKApi.isReplay()) {
			mouse.x = _mouseX;
			mouse.y = _mouseY;
		}
		
		/*drag*/
		if(dragSelect > -1 && (step==GPlay || step==GShake)) {
			var a = getMouseAngle();
			//a = angle en degrés de la souris
			for(id in 0...12) {
				//var base = items[dragSelect][id].mc.rotation;
				items[dragSelect][id].mc.rotation = ((id) * (360 / 12)) +  (dragAngle - a);
				if(!items[dragSelect][id].mc.isCache) {
					items[dragSelect][id].mc.setCache();
				}
			}
		}
			
		/*cycle highlight*/
		if((step==GPlay || step==GShake)){
			var c = getCycle();
			if(c != lastCycle) {
				for(cycle in 0...4) {
					if(cycle==c /*&& age%10>4*/ ){
						for(id in 0...12 ) {
							//if(isDragging){
							if(items[cycle][id].mc!=null)
								items[cycle][id].mc.filters = [new flash.filters.GlowFilter(0xFFFFFF, 0.5, 4, 4, 10, 1, true)];
							//}else {
								//items[cycle][id].mc.filters = [new flash.filters.GlowFilter(0xFFFFFF, 1, 7, 7, 1, 1, true)];
							//}
						}
					}else {
						for(id in 0...12) {
							if(items[cycle][id].mc!=null)
							items[cycle][id].mc.filters = [];
						}
					}
				}
			}
			lastCycle = c;
		}
		
		/*move anim*/
		for(t in 0...4) {
			if(moveTimers[t] > 0) {
				/*moves to execute*/
				for(b in 0...12) {
					var i = items[t][b].mc;
					if(!i.isCache) i.setCache();
					
					var offsetAngle = moveOffsets[t] * (360 / 12);
					var baseAngle = b * (360 / 12);
					var completion = 0.0; //from 0 to 1;
					if(moveOffsets[t] !=0) {
						completion = 1 - (moveTimers[t] / (Math.abs(moveOffsets[t]) * MOVE_ANIM_DURATION));
					}else {
						completion = 0;
					}
					i.rotation = baseAngle + (completion * offsetAngle);
				}
				moveTimers[t]--;
			}
		}
		
		/* detecte le dernier timer a atteindre 0 */
		var stopped = 0;
		var toStop = 0;
		for( i in 0...4) {
			if(moveTimers[i] == 0) {
				toStop ++;
			}
			if(moveTimers[i] < 0) {
				stopped ++;
			}
		}

		
		if(toStop+stopped==4 && stopped<4) {
			endMove(moveOffsets);
			moveTimers = [ -1, -1, -1, -1]; //reset timers
			moveOffsets = [0, 0, 0, 0];	//reset moves
			setStep( GPlay, "fin de move");
			//trace("CHECK DE FIN DINTERPOL");
			check();
		}
		
		/*round*/
		if((step==GPlay)){
			roundTimer++;
			centerItem.setProgress(roundTimer / ROUND_DURATION);
			if(roundTimer > ROUND_DURATION) {
				//lose
				gameOver(false);
				step = GInit;
			}
			
			//lava progress
			if(roundTimer > (ROUND_DURATION / 3 *2)) {
				var progress = (roundTimer - (ROUND_DURATION / 3*2)) / (ROUND_DURATION / 3);
				lava.masque.gotoAndStop( Math.ceil(progress * 10) );
				
				var shakeX = roundTimer % 5 - 2;
				var shakeY = roundTimer % 3 - 1;
				
				Game.me.level.x = shakeX * progress;
				Game.me.level.y = shakeY * progress;
			}
		}
	}
	
	
	function getFlashVersion():Int {
		//format of Capabilities.version : 'WIN 11,321'
		return Std.parseInt(flash.system.Capabilities.version.split(' ')[1].split(',')[0]);
	}
	
	
	function gameOver(win:Bool) {
		
		if(getFlashVersion()>=11 && flash.ui.Mouse.supportsCursor) flash.ui.Mouse.cursor = "auto"; //reset mouse cursor
		
		if(win) {
			//WIN
			for(cycle in 0...4) {
				for(id in 0...12) {
					var item = 	items[cycle][id];
					FTimer.delay(function() {
						new mt.fx.Flash(item.mc);
					},cycle*10);
				}
			}
		}else {
			//LOSE
			var nde = new gfx.Serpent();
			nde.scaleX = 4; nde.scaleY = 4;
			nde.x = CENTER.x;
			nde.y = CENTER.y;
			nde.blendMode = flash.display.BlendMode.ADD;
			dm.add(nde, DM_FX);
			new mt.fx.Spawn(nde, 0.1, true, true);
			new mt.fx.FadeTo(Game.me.level, 0.005, 0, 0xFF6600);
		}
		
		FTimer.delay(function(){
			api.AKApi.gameOver(win);
		},80);
	}
	
	
	function onClick(?_:flash.events.MouseEvent) {
		if(getFlashVersion()>=11 && flash.ui.Mouse.supportsCursor) flash.ui.Mouse.cursor = "closed_hand";
		
		if(!(step==GPlay || step==GShake)) return;
		
		isDragging = true;
		
		FTimer.clear();
		
		/*reset potential FXs*/
		doSerpent(false);
		for(mc in mcs) if(mc.parent != null) mc.parent.removeChild(mc);
		mcs = [];
		for(fx in fxs) if(!fx.dead) fx.kill();
		fxs = [];
		setStep(GPlay);
		
		//trouver le rayon.
		var xo = _mouseX - CENTER.x;
		var yo = _mouseY - CENTER.y;
		//pythagore
		var rayon = Math.sqrt(Math.pow(xo, 2) + Math.pow(yo, 2));
		var event = 0;
		
		if(rayon < 80) {
			event = 0;
		}else if(rayon < 125) {
			event = 1;
		}else if(rayon < 170) {
			event = 2;
		}else {
			event = 3;
		}
		
		//check if stone
		var cycle = event;
		if(Lambda.exists(items[cycle], function(i) { return i.type == Item.TYPE_STONE; } )) {
			for(i in items[cycle]) {
				new mt.fx.Shake(i.mc, 2, 2);
			}
			noOnRelease = true;
			isDragging = false;
			return;
		}
		dragSelect = event;
		dragAngle = getMouseAngle();

	}
	
	/**
	 * get current mouse angle in degrees
	 */
	function getMouseAngle():Float {
		var xo = _mouseX - CENTER.x;
		var yo = _mouseY - CENTER.y;
		return Math.atan2(xo, yo) * 180 / Math.PI;
	}
	
	function getCycle():Int {
		
		if(isDragging) return dragSelect; //si on est en train de dragger, on renvoir le cycle sélectionné
		
		//trouver le rayon.
		var xo = _mouseX - CENTER.x;
		var yo = _mouseY - CENTER.y;
		//pythagore
		var rayon = Math.sqrt(Math.pow(xo, 2) + Math.pow(yo, 2));
		
		var c = -1;
		if(rayon < 80) {
			c = 0;
		}else if(rayon < 125) {
			c = 1;
		}else if(rayon < 170) {
			c = 2;
		}else if(rayon < 240) {
			c = 3;
		}
		return c;
	}
	
	
	/**
	 * release drag n drop action
	 */
	function onRelease(?_) {
		
		if(getFlashVersion()>=11 && flash.ui.Mouse.supportsCursor) flash.ui.Mouse.cursor = "open_hand";
		
		if(noOnRelease) {
			noOnRelease = false;
			return;
		}
		
		if(!(step==GPlay || step==GShake)) return;
		
		isDragging = false;
		
		if(AKApi.isReplay()) {
			//mouse.gotoAndStop(1);
		}
		
		if(dragSelect < 0) return;
		
		removeTip();
		
		//arrondi sur le bon angle
		for(id in 0...12) {
			var mc = items[dragSelect][id].mc;
			var a = 360 / 12;
			mc.rotation = Math.round(mc.rotation / a) * a;
		}
		
		//rotate matrix
		var rot = [];
		for(c in 0...4) {
			if(c == dragSelect ) {
				var ma = getMouseAngle();
				var a = 360 / 12;
				var offset = Math.round( (dragAngle - ma) / a );
				//trace(dragAngle+" + "+ma+" / "+a+" = "+offset);
				rot.push(offset);
			}else {
				rot.push(0);
			}
		}
		endMove(rot);
		//trace("CHECK ON RELEASE");
		check();
		
		dragSelect = -1;
		dragAngle = 0;
	}
	
	
	function move(event:Int) {
		
		//event : 0 turn cycle 0 left, 1 turn cycle 1 left, 4 turn cycle 0 right...etc
		var cycle = 0;
		var left = false;
		if(event < 4) {
			left = true;
			cycle = event;
		}else {
			left = false;
			cycle = event - 4;
		}
		
		//store move
		moveOffsets[cycle] += left? -1:1;	//set offset
		moveTimers[cycle] += MOVE_ANIM_DURATION; //give more time
		
		FTimer.clear();
		
		if(shakeFxs.length > 0) {
			for(fx in shakeFxs) fx.kill();
			shakeFxs.clear();
		}
		shakeItems.clear();
	}
	
	/**
	 * rotate matrix by applying moveOffsets (movement matrix)
	 * and redisplay items
	 */
	function endMove(moveOffsets:Array<Int>) {
		//trace("endMove :" + moveOffsets);
		
		//erase items wich has to move
		for(cycle in 0...4) {
			if(moveOffsets[cycle] == 0) continue;
			for(id in 0...12) {
				var i = items[cycle][id];
				if(i.mc!=null && i.mc.parent != null) i.mc.parent.removeChild(i.mc);
			}
		}
		
		//rotate matrix
		applyRotation(moveOffsets);
		
		//redraw only rotated cycles
		for(cycle in 0...4) {
			if(moveOffsets[cycle] == 0) continue;
			redraw(cycle);
		}

	}
	
	
	function dumpMatrix(?m:Matrix) {
		if(m == null) m = items;
		
		for(cycle in 0...4) {
			var row = '';
			for (id in 0...12) {
				row += "[" + m[cycle][id].color + "]";
			}
			trace(row);
		}
	}
	
	
	/**
	 * check if the whole level has been cleared
	 */
	function isCataclismo(lines:Array<Int>) {
		
		//var cata = false;
		
		for(id in 0...12) {
			if(Lambda.has(lines, id)) continue;
			//check that other lines are empty
			for (cycle in 0...4) {
				if(items[cycle][id].type != Item.TYPE_EMPTY /*&& items[cycle][id].type != Item.TYPE_STONE*/) return false;
			}
		}
		
		return true;
		
	}
	
	
}