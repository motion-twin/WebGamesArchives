package ;
import api.AKApi;
import Data;
import entities.Dropper;
import entities.Rail;
import entities.Shooter;
import events.EventManager;
import events.GameEvent;
import flash.display.BitmapData;
import flash.geom.Point;
import mt.deepnight.RandList;
import mt.deepnight.RandList;
import mt.gx.MathEx;
import RoadEngine;

/**
 * ...
 * @author 01101101
 */

class Road {
	
	//public var widths:WeightedList<Int>;
	public var widths:RandList<Int>;
	public var currentWidth:Int;
	public var newWidth (getNewWidth, null):Int;
	
	public var height(getHeight, null):Int;
	
	public var slices:Array<RS>;
	
	public var decoration:Bool;
	
	var scrollOffset:Int;
	var bd:BitmapData;
	
	var locked:Bool;
	
	var diff:Float;
	
	public function new () {
		decoration = true;
		
		scrollOffset = 0;
		
		//widths = new WeightedList<Int>();
		widths = new RandList<Int>();
		setDifficulty(0);
		currentWidth = widths.draw(Game.RAND.random);
		
		slices = new Array();
		
		locked = false;
		//EM.instance.addEventListener(GE.LOCK_ROAD, gameEventHandler);
		//EM.instance.addEventListener(GE.UNLOCK_ROAD, gameEventHandler);
	}
	
	/*function gameEventHandler (e:GameEvent) :Void {
		//trace(e.type + " / " + e.data);
		switch (e.type) {
			case GE.LOCK_ROAD:
				locked = true;
			case GE.UNLOCK_ROAD:
				locked = false;
		}
		trace("road locked: " + locked + " (" + currentWidth + ")");
	}*/
	
	function getNewWidth () :Int {
		// TODO adjust center
		if (locked)	return currentWidth;
		else {
			var w = widths.draw(Game.RAND.random);
			//if (w < currentWidth)	trace("REDUCTION");
			currentWidth = w;
			return w;
		}
	}
	
	function getHeight () :Int {
		if (slices == null)	return 0;
		var h:Int = 0;
		for (s in slices)	h += s.bd.height;
		return h;
	}
	
	public function scroll (delta:Int, refreshBD:Bool = true) :Bool {
		if (slices.length == 0)	return false;
		scrollOffset += delta;
		//trace(" -> scroll " + delta + " / " + scrollOffset);
		if (scrollOffset > slices[0].bd.height) {
			scrollOffset -= slices[0].bd.height;
			slices.shift().destroy();
			//trace("shifted slices: " + slices.length + " left");
			while (height < 80)	EM.instance.dispatchEvent(new GameEvent(GE.GENERATE_ROAD));
			//trace("NEW HEIGHT " + height);
		}
		if (refreshBD)	getBD(true);
		return true;
	}
	
	public function getBD (force:Bool = false) :BitmapData {
		if (bd == null) {
			bd = new BitmapData(RW.XL + 10, 40, false);
			force = true;
		}
		if (force && slices.length > 0) {
			var i = 0;
			var left = Game.TAP.y = bd.height;
			Game.TAP.x = 0;
			Game.TAR.x = Game.TAR.y = 0;
			Game.TAR.width = bd.width;
			
			if (scrollOffset > 0) {
				Game.TAR.height = slices[i].bd.height - scrollOffset;
				left -= Std.int(Game.TAR.height);
				Game.TAP.y = left;
				bd.copyPixels(slices[i].bd, Game.TAR, Game.TAP);
				//trace("copied " + Game.TAR.height + " lines from slice " + i + " at y=" + Game.TAP.y);
				i++;
			}
			
			while (left > 0 && i < slices.length) {
				if (left < slices[i].bd.height) {
					Game.TAR.y = slices[i].bd.height - left;
					Game.TAR.height = left;
					Game.TAP.y = left = 0;
				}
				else {
					Game.TAR.y = 0;
					Game.TAR.height = slices[i].bd.height;
					left -= Std.int(Game.TAR.height);
					Game.TAP.y = left;
				}
				bd.copyPixels(slices[i].bd, Game.TAR, Game.TAP);
				//trace("copied " + Game.TAR.height + " lines from slice " + i + " at y=" + Game.TAP.y);
				i++;
			}
		}
		return bd;
	}
	
	public function upDifficulty () {
		setDifficulty(diff + 0.1);
	}
	
	public function setDifficulty (d:Float) {
		d = MathEx.clamp(d, 0, 1);
		diff = d;
		var di = Math.round(d * 3);
		switch (di) {
			case 0:		setWidths(10, 5, 2, 0);
			case 1:		setWidths(5, 10, 5, 2);
			case 2:		setWidths(2, 5, 10, 5);
			case 3:		setWidths(0, 2, 5, 10);
			default:	setWidths(10, 10, 10, 10);
		}
		//trace("road difficulty: " + diff + " -> " + di);
	}
	
	public function setWidths (xl:Int = 0, l:Int = 0, m:Int = 0, s:Int = 0) {
		widths = new RandList<Int>();
		widths.add(RW.XL, xl);
		widths.add(RW.L, l);
		widths.add(RW.M, m);
		widths.add(RW.S, s);
	}
	
}

class RW {
	public static inline var XL:Int = 18;
	public static inline var L:Int = 15;
	public static inline var M:Int = 12;
	public static inline var S:Int = 9;
}

typedef RS = RoadSlice;
class RoadSlice {
	
	public var bd:BitmapData;
	public var xStart:Int;
	public var width:Int;
	public var height:Int;
	
	public function new (ground:GP, ?objects:Array<OP>, width:Int, height:Int = 0, prevWidth:Int = 0, prevX:Int = 0) {
		//trace("new RS " + ground);
		// -----------
		// INIT FROM OBJECTS
		var bdh = height;
		if (bdh == 0)	bdh = 20 + Game.RAND.random(8);
		var hRail = 0;
		
		/*if (objects != null) {
			for (o in objects) {
				switch (o) {
					// Rail
					case OP.PRail:
						var f = Rail.simulateTime();
						f = Math.floor(f * Game.SPEED / Game.TILE_SIZE);
						hRail = MathEx.mini(bdh - 9, f);
					default:
						continue;
				}
			}
		}*/
		
		// -----------
		// GROUND
		switch (ground) {
			case GP.AllRoad:
				bd = new BitmapData(RW.XL + 10, bdh, false, RE.ROAD_COLOR);
				Game.TAR.x = 0;
				Game.TAR.width = bd.width;
			default:
				bd = new BitmapData(RW.XL + 10, bdh, false, RE.SAND_COLOR);
		}
		
		xStart = 0;
		width = switch (ground) {
			case GP.Tunnel(n):	n;
			default:			width;
		}
		this.width = bd.width;
		this.height = bd.height;
		
		//trace("new slice " + bd.height);
		
		bd.lock();
		
		// Add road
		Game.TAR.x = Game.TAR.y = 0;
		if (ground != GP.AllSand && ground != GP.AllRoad) {
			if (prevWidth != 0) {
				if (prevWidth != width) {
					var rx = Game.RAND.random(MathEx.absi(prevWidth - width));
					if (prevWidth > width)	Game.TAR.x = prevX + rx;
					else					Game.TAR.x = prevX - rx;
				} else {
					if (Game.RAND.random(3) == 0)	Game.TAR.x = prevX + Game.sign();
					else							Game.TAR.x = prevX;
				}
				Game.TAR.x = MathEx.mini(Std.int(Game.TAR.x), bd.width - width - 2);
				Game.TAR.x = MathEx.maxi(Std.int(Game.TAR.x), 2);
			} else {
				Game.TAR.x = Std.int((bd.width - width) / 2);
			}
			
			Game.TAR.y = 0;
			Game.TAR.width = width;
			Game.TAR.height = bd.height;
			bd.fillRect(Game.TAR, RE.ROAD_COLOR);
		}
		
		xStart = Std.int(Game.TAR.x);
		
		var drawX = 1;
		var px:UInt;
		
		switch (ground) {
			case GP.Tunnel(n):
				px = bd.getPixel(drawX, bd.height - 1) & 0xFF0000;
				bd.setPixel(drawX, bd.height - 1, px | 14 << 8 | Data.c(OT.OBorderRail));
				drawX++;
			default:
		}
		
		px = bd.getPixel(0, 0) & 0xFF0000;
		px = px | Std.int(Game.TAR.x) << 8 | Std.int(Game.TAR.width);
		bd.setPixel(0, bd.height - 1, px);
		// -----------
		// ADD THE OBJECTS
		if (objects != null) {
			var x = drawX;
			var y:Int = bd.height - 1;
			var v:UInt = 0;
			var s:Int;
			for (o in objects) {
				px = bd.getPixel(x, y) & 0xFF0000;
				switch (o) {
					case OP.PArmor:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OArmor));
					case OP.POverdrive:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OOverdrive));
					case OP.PKado:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OKado));
						
					case OP.PRail:
						//v = MathEx.mini(bd.height - 4, hRail);
						v = 8 + Game.RAND.random(14);
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.ORail));
					case OP.POil:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OOil));
						
					case OP.PDropper:
						v = width - 2;
						/*if (Std.random(2) == 0)	v = width - 1;
						else					v = 0;*/
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.ODropper));
						//trace("added ODropper: " + StringTools.hex(Data.c(OT.ODropper)));
						
					case OP.PRapidDropper:
						v = width - 2;
						/*if (Std.random(2) == 0)	v = width - 1;
						else					v = 0;*/
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.ORapidDropper));
						//trace("added ORapidDropper: " + StringTools.hex(Data.c(OT.ORapidDropper)));
						
					case OP.PShooter:
						v = Std.int(230 / Game.TILE_SIZE);
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OShooter));
						
					case OP.PDoubleShooter:
						v = Std.int(Game.SIZE.height / 3 / Game.TILE_SIZE);
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OShooter));
						x++;
						v = Std.int(Game.SIZE.height / 3 * 2 / Game.TILE_SIZE);
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OShooter));
						
					case OP.PTripleShooter:
						v = 2;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OShooter));
						x++;
						v = 6;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OShooter));
						x++;
						v = 10;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OShooter));
						
					case OP.PMovingShooter:
						v = 1;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OMovingShooter));
						
					case OP.PLoner:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OLoner));
						
					case OP.PTrio:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OTrio));
						
					case OP.PSons:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OSons));
						
					case OP.PHarley:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OHarley));
					case OP.PHarleyV:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OHarleyV));
					case OP.PBikeLine:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OBikeLine));
						
					case OP.PSportCar:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OSportCar));
						
					case OP.PTruck:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OTruck));
					case OP.PTruckTwo:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OTruckTwo));
					case OP.PTruckFour:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OTruckFour));
					case OP.PTruckSix:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OTruckSix));
						
					case OP.PBus:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OBus));
						
					case OP.PLightCar:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OLightCar));
						
					case OP.PDelorean:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.ODelorean));
						
					case OP.PLimo:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OLimo));
						
					case OP.PMonster:
						v = 0;
						bd.setPixel(x, y, px | v << 8 | Data.c(OT.OMonster));
						
					default:
						trace("unknown pattern: " + o);
						continue;
				}
				x++;
			}
		}
		
		bd.unlock();
	}
	
	/*function isFree (?pt:Point) :Bool {
		if (pt == null)	pt = Game.TAP;
		var px:UInt = bd.getPixel(Std.int(pt.x), Std.int(pt.y)) & 0x0000FF;
		if (px == 0)	return true;
		else			return false;
	}*/
	
	public function destroy () {
		bd.dispose();
	}
	
}

enum GroundType {
	Asphalt;
	Sand;
	Unknown;
}




