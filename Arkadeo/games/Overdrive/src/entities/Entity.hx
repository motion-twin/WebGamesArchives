package entities;
import anim.Animation;
import anim.FrameManager;
import api.AKApi;
import Data;
import events.EventManager;
import events.GameEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;
import mt.gx.MathEx;
import Road;
import ui.Fx;
import utils.IntPoint;

/**
 * ...
 * @author 01101101
 */

class Entity extends Sprite {
	
	public var type:OT;
	
	public var w:Int;
	public var h:Int;
	public var vx:Float;
	public var vy:Float;
	public var vr:Float;
	var floatx:Float;
	var floaty:Float;
	//public var baseColor(default, setBaseColor):UInt;
	//public var color(default, setColor):UInt;
	public var protection:Int;
	public var maxHealth(default, setMaxHealth):Float;
	public var health(default, setHealth):Float;
	public var shield:Int;
	public var colliding:Bool;
	
	public var layer:Int;
	
	public var dead:Bool;
	public var ctrlLock:Int;
	public var spinning:Int;
	var fading:Bool;
	
	// Anim
	
	public var anims (default, null):Array<Animation>;
	public var currentAnim (default, null):Int;
	public var currentFrame (default, null):Int;
	public var currentAnimName (getCurrentAnimName, never):String;
	public var currentFrameName (getCurrentFrameName, never):String;
	var manualFrameName:String;
	public var sheetName:String;
	public var offset(default, setOffset):IntPoint;
	public var shakeOffset:IntPoint;
	
	public var bmp:Bitmap;
	public var bmpAdd:Bitmap;
	public var offsetAdd:IntPoint;
	
	public var autoPlay:Bool;
	public var loop:Bool;
	public var repeatFrame:Int;
	public var repeatCount:Int;
	
	public var needGroundType:Bool;
	
	var useCustomBD:Bool;
	
	var data(getData, null):AnimData;
	public var version(default, null):Int;
	
	var anchor:Shape;
	
	public function new (type:OT) {
		super();
		
		this.type = type;
		useCustomBD = false;
		sheetName = Game.SHEET_SPRITES;
		
		w = 32;
		h = 64;
		vx = vy = vr = floatx = floaty = 0;
		
		layer = Level.VEHICLES_DEPTH;
		
		needGroundType = false;
		colliding = true;
		protection = 0;
		shield = 0;
		
		dead = false;
		ctrlLock = 0;
		spinning = 0;
		fading = false;
		
		maxHealth = 1;
		health = 1;
		
		// Anim
		resetAnims();
		
		bmp = new Bitmap();
		addChild(bmp);
		
		offset = new IntPoint();
		shakeOffset = new IntPoint();
		
		autoPlay = false;
		loop = false;
		repeatFrame = repeatCount = 0;
		
		if (data != null) {
			//version = Std.random(data.versions);
			version = Game.RAND.random(data.versions);
			var sName = ((data.shadowName != null) ? data.shadowName : data.name) + ((data.name == "struck" && version == 1) ? "1" : "0") + "_shadow";
			setAddBmp( FM.getFrame(sName, Game.SHEET_SPRITES), data.shadowOffset);
		}
		
		//showAnchor();
	}
	
	function showAnchor (show:Bool = true) {
		if (anchor == null) {
			anchor = new Shape();
			anchor.graphics.beginFill(0x00FF00, 0.5);
			anchor.graphics.drawCircle(0, 0, 5);
			anchor.graphics.endFill();
		}
		if (show)					addChild(anchor);
		else if (contains(anchor))	removeChild(anchor);
	}
	
	public function update (?ground:GroundType) :Void {
		
		if (ctrlLock > 0) {
			ctrlLock--;
			if (ctrlLock == 0)	onCtrlUnlock();
		}
		if (spinning > 0) {
			spinning--;
			Fx.instance.tireOil(center.x, bottomRight.y - 8);
			if (spinning == 0)	rotation = 0;
			else				rotation = Game.RAND.random(10)-5;
		}
		if (shield > 0)	shield--;
		if (protection > 0)	protection--;
		
		// Anim
		if (!useCustomBD) {
			var fc = getFrameName();
			if (fc.name != currentFrameName) {
				//if (type == OT.PlayerCar)	trace(fc.flipped + " && " + data.flippable);
				var mustFlip = fc.flipped && data.flippable;
				if (type == OT.Bike || type == OT.OHarley)
					mustFlip = !mustFlip;
				changeFrame(fc.name, sheetName, mustFlip);
			}
		}
		
		if (bmp != null && bmp.bitmapData != null) {
			w = Std.int(bmp.bitmapData.width * Math.abs(bmp.scaleX));
			h = Std.int(bmp.bitmapData.height * Math.abs(bmp.scaleY));
		}
		
		// update screeen pos
		
		floatx += vx;
		floaty += vy;
		
		while (Math.abs(floatx) > 1) {
			if (floatx > 0) {
				floatx--;
				x++;
			} else if (floatx < 0) {
				floatx++;
				x--;
			}
		}
		while (Math.abs(floaty) > 1) {
			if (floaty > 0) {
				floaty--;
				y++;
			} else if (floaty < 0) {
				floaty++;
				y--;
			}
		}
		
		if (vr != 0)	rotation += vr;
		
		if (bmp.scaleX == -1)	bmp.x = bmp.width + offset.x + shakeOffset.x;
		else					bmp.x = offset.x + shakeOffset.x;
		bmp.y = offset.y + shakeOffset.y;
		
		if (fading && !dead) {
			alpha *= 0.9;
			if (alpha < 0.05) {
				dead = true;
				EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, this));
			}
		}
	}
	
	function onCtrlUnlock () {
		
	}
	
	public function loseControl (duration:Int) {
		ctrlLock = duration;
		spinning = duration;
		vx = Game.RAND.sign() * (Game.RAND.random(3) + 1);
	}
	
	function setMaxHealth (h:Float) :Float {
		maxHealth = h;
		health = h;
		return h;
	}
	
	function setHealth (h:Float) :Float {
		h = Math.max(Math.min(h, maxHealth), 0);
		return health = h;
	}
	
	public function setParams (p:Dynamic) { }
	
	public function burn () {
		if (bmp == null)	return;
		var ct = new ColorTransform(0.5, 0.5, 0.5);
		bmp.transform.colorTransform = ct;
	}
	
	public function selfDestruct (time:Int = 15, dir:Int = 0) :Void {
		health = 0;
		colliding = false;
		protection = 99999;
		vx = Game.SPEED * 0.5 * dir;
		vy = Game.SPEED;
		burn();
		
		var size = (type == OT.OHarley || type == OT.Bike) ? 0 : 1;
		var xplos = new Explosion(size);
		xplos.x = center.x - xplos.w / 2;
		xplos.y = center.y - xplos.h / 2;
		xplos.vx = vx;
		xplos.vy = vy;
		var sd = new SpawnData(xplos, { _adaptY:false } );
		EM.instance.dispatchEvent(new GameEvent(GE.SPAWN_ENTITY, sd));
		
		var level = Game.me.level;
		level.paintEntityDirect(  "hole_" + (Std.random(3) + 1), xplos.x + (xplos.w >> 1), xplos.y + (xplos.h >> 1));
		
		fading = true;
		//FTimer.delay(destruction, time);
		//vr = -5 * dir;
		
		if (AKApi.getGameMode() == GM_LEAGUE && version == 666)	Fx.instance.bossKill(center.x, center.y);
	}
	
	/*function destruction () {
		dead = true;
		EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, this));
	}*/
	
	public function destroy () {
		dead = true;
		if (bmp != null && bmp.bitmapData != null) {
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
		}
		if (bmpAdd != null && bmpAdd.bitmapData != null) {
			bmpAdd.bitmapData.dispose();
			bmpAdd.bitmapData = null;
		}
	}
	
	var klist:List<Int>;
	var kcx:Int;
	var kcy:Int;
	
	public function getKeys (xOffset:Int = 0, yOffset:Int = 0) :List<Int> {
		if (klist == null)	klist = new List<Int>();
		else {
			var tx = (Std.int(x) + offset.x + xOffset) >> 3;
			var ty = (Std.int(y) + offset.y + yOffset) >> 3;
			if (tx == kcx && ty == kcy)	
				return klist;// Return stored version
			else						
				klist.clear();
		}
		Game.DBGCNT++;
		//for (i in 0...(Math.round(w / Game.GRID_SIZE))) {
		for (i in 0...w>>3) {
			//for (j in 0...(Math.round(h / Game.GRID_SIZE))) {
			for (j in 0...h>>3) {
				//kcx = Math.round((x + offset.x + xOffset) / Game.GRID_SIZE) + i;
				//kcy = Math.round((y + offset.y + yOffset) / Game.GRID_SIZE) + j;
				kcx = ((Std.int(x) + offset.x + xOffset) >> 3) + i;// equals dividind by 8
				kcy = ((Std.int(y) + offset.y + yOffset) >> 3) + j;
				if (kcx >= 0 && kcy >= 0 && kcx < Level.gridSize.width && kcy < Level.gridSize.height) {
					klist.add(kcx | kcy << Game.BIT_OFFSET);
				}
			}
		}
		//kcx = (Std.int(x) + offset.x + xOffset) >> 3;
		//kcy = (Std.int(y) + offset.y + yOffset) >> 3;
		return klist;
	}
	
	public function getScreenPos () :Point {
		var p = new Point();
		var e:DisplayObject = this;
		while (e.parent != null) {
			p.x += e.x;
			p.y += e.y;
			e = e.parent;
		}
		return p;
	}
	
	// Anim
	public function resetAnims () :Void {
		anims = new Array<Animation>();
		currentAnim = -1;
		currentFrame = -1;
		manualFrameName = null;
	}
	
	public function play (aName:String) :Void {
		if (anims.length == 0)	return;
		
		for (i in 0...anims.length) {
			if (anims[i].name == aName) {
				currentAnim = i;
				currentFrame = 0;
				break;
			}
		}
	}
	
	private function getCurrentFrameName () :String {
		if (anims == null || anims[currentAnim] == null) {
			if (manualFrameName != null)	return manualFrameName;
			else							return null;
		}
		return anims[currentAnim].frames[currentFrame].name;
	}
	
	private function getCurrentAnimName () :String {
		if (anims == null || anims[currentAnim] == null) return null;
		return anims[currentAnim].name;
	}
	
	public function updateG () :Void {
		if (currentAnim != -1 && anims[currentAnim].frames.length > 1) {
			currentFrame++;
			if (currentFrame >= anims[currentAnim].frames.length) {
				if (anims[currentAnim].looping)	currentFrame = 0;
				else							currentFrame = anims[currentAnim].frames.length - 1;
			}
		}
		if (bmp.bitmapData == null) {
			bmp.bitmapData = FrameManager.getFrame(currentFrameName, anims[currentAnim].spritesheet);
		} else {
			FrameManager.getFrameOpt(bmp.bitmapData, currentFrameName, anims[currentAnim].spritesheet);
		}
		if (anims[currentAnim].frames[currentFrame].flipped) {
			bmp.scaleX = -1;
			bmp.x = bmp.width + offset.x;
		} else {
			bmp.scaleX = 1;
			bmp.x = offset.x;
		}
	}
	
	public function changeFrame (name:String, sheet:String, flipped:Bool = false) :Void {
		resetAnims();
		manualFrameName = name;
		sheetName = sheet;
		if (bmp.bitmapData == null) {
			var b = FrameManager.getFrame(name, sheet);
			if (b != null)	bmp.bitmapData = b;
			else			bmp.bitmapData = new BitmapData(w, h, true, 0x80FF00FF);
		} else {
			if (!FrameManager.getFrameOpt(bmp.bitmapData, name, sheet)) {
				//trace("didn't find " + name);
				bmp.bitmapData.fillRect(bmp.bitmapData.rect, 0x80FF00FF);
			}
		}
		if (flipped) {
			bmp.scaleX = -1;
			bmp.x = bmp.width + offset.x;
		} else {
			bmp.scaleX = 1;
			bmp.x = offset.x;
		}
	}
	
	private function setOffset (point:IntPoint) :IntPoint {
		offset = point.clone();
		
		if (bmpAdd != null) {
			offsetAdd = point.clone();
			bmpAdd.x = offsetAdd.x;
			bmpAdd.y = offsetAdd.y;
		}
		
		if (bmp.scaleX == -1)	bmp.x = bmp.width + offset.x;
		else					bmp.x = offset.x;
		bmp.y = offset.y;
		return offset;
	}
	
	public function setAddBmp (bd:BitmapData, ?p:IntPoint) :Void {
		if (bd == null)	return;
		if (p == null)	offsetAdd = new IntPoint();
		else			offsetAdd = p.clone();
		if (bmpAdd == null) {
			bmpAdd = new Bitmap();
			bmpAdd.blendMode = BlendMode.MULTIPLY;
			addChildAt(bmpAdd, 0);
		}
		bmpAdd.bitmapData = bd;
		bmpAdd.x = offsetAdd.x;
		bmpAdd.y = offsetAdd.y;
	}
	
	function getFrameName () :FrameChange {
		// Default to idle
		var s;
		
		// If side animation
		//var r = MathEx.ratio(vel.x, 0, vxMax);
		var r = MathEx.ratio(vx, 0, Game.SPEED * 0.3 * 0.6);
		//var r = 0.0;
		var f = r > 0;
		r = Math.abs(r);
		r = Math.max(0, Math.min(1, r));
		r = Math.round(r * data.sideFrames);
		if (Math.abs(r) > 0) {
			r = r - 1;
			//s = Std.string(AnimState.Side).toLowerCase();
			s = "side" + r;
			//s = s.substring(0, s.length - 1) + r;
			// If not flippable
			if (!data.flippable) {
				if (type == OT.Bike || type == OT.OHarley)	s += (f) ? "_l" : "_r";
				else										s += (f) ? "_r" : "_l";
			}
		}
		// If idle animation
		else {
			//s = Std.string(AnimState.Idle).toLowerCase();
			//#if !standalone
			//s = s.substring(0, s.length - 1);
			//#end
			s = "idle";
			var n = 0;
			if (currentFrameName != null) {
				var os = currentFrameName.split("_").pop();
				n = Std.parseInt(os.substring(os.length - 1, os.length));
				//#if !standalone
				//os = os.substring(0, os.length - 1);
				//#end
				
				if (s == os) {
					n += 1;// Look for an n+1 animation frame
					var fi = FM.getFrameInfo(data.name + version + "_" + os + "" + n, Game.SHEET_SPRITES);
					if (fi == null) { // if frame name doesn't exist with n+1, revert back to 0
						n = 0;
					}
				}
				else n = 0;
			}
			s += Std.string(n);
		}
		
		// Return name
		return { name:data.name + version + "_" + s, flipped:f };
	}
	
	function getData () :AnimData {
		return Data.vehicles.get(Std.string(type));
	}
	
	public var center(getCenter, never):Point;
	function getCenter () :Point { return new Point(x + w / 2 + offset.x, y + h / 2 + offset.y); }
	public var centeri(getCenteri, never):IntPoint;
	function getCenteri () :IntPoint { return new IntPoint(Std.int(x + w / 2 + offset.x), Std.int(y + h / 2 + offset.y)); }
	
	public var topLeft(getTopLeft, never):Point;
	function getTopLeft () :Point { return new Point(x + offset.x, y + offset.y); }
	public var topLefti(getTopLefti, never):IntPoint;
	function getTopLefti () :IntPoint { return new IntPoint(Std.int(x + offset.x), Std.int(y + offset.y)); }
	
	public var bottomRight(getBottomRight, never):Point;
	function getBottomRight () :Point { return new Point(x + w + offset.x, y + h + offset.y); }
	public var bottomRighti(getBottomRighti, never):IntPoint;
	function getBottomRighti () :IntPoint { return new IntPoint(Std.int(x + w + offset.x), Std.int(y + h + offset.y)); }
	
}

typedef FrameChange = {
	var name:String;
	var flipped:Bool;
}











