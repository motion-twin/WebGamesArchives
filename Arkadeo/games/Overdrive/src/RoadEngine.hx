package ;
import anim.FrameManager;
import api.AKApi;
import Data;
import entities.Bonus;
import entities.Dropper;
import entities.Entity;
import entities.Obstacle;
import entities.Oil;
import entities.Player;
import entities.Rail;
import entities.Shooter;
import events.EventManager;
import events.GameEvent;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.Public;
import mt.gx.MathEx;
import mt.Rand;
import Road;
import utils.IntPoint;

/**
 * ...
 * @author 01101101
 */

@:bitmap("../gfx/img/sand_a.jpg") class SandBMa extends BitmapData { }
@:bitmap("../gfx/img/sand_b.jpg") class SandBMb extends BitmapData { }
@:bitmap("../gfx/img/sand_c.jpg") class SandBMc extends BitmapData { }
@:bitmap("../gfx/img/sand_d.jpg") class SandBMd extends BitmapData { }

@:bitmap("../gfx/img/road_a.jpg") class RoadBMa extends BitmapData { }
@:bitmap("../gfx/img/road_b.jpg") class RoadBMb extends BitmapData { }
@:bitmap("../gfx/img/road_c.jpg") class RoadBMc extends BitmapData { }

typedef RE = RoadEngine;
class RoadEngine {
	
	public static var SAND_COLOR:UInt = 0xFF0000;// IMPORTANT: only use the red channel to leave the others for objects
	public static var ROAD_COLOR:UInt = 0x000000;// Same here
	
	static var ready:Bool = false;
	public static var sandBM:BitmapData;// sand texture
	public static var roadBM:BitmapData;// road texture (size must be a multiple of tile size)
	public static var guides:Hash<Array<UInt>>;// guide list for borders
	public static var ySand:Int = 0;
	public static var yRoad:Int = 0;
	
	public static var land:String;
	
	public static function init () {
		// Store textures
		var l = Game.RAND.random(20) + 1;
		if (AKApi.getGameMode() == GM_PROGRESSION) {
			l = AKApi.getLevel();
			land = "a";
			switch (l) {
				case 3, 4, 7, 9, 12:
					if (sandBM == null)	sandBM = new SandBMb(0, 0);
					if (roadBM == null)	roadBM = new RoadBMb(0, 0);
					land = "b";
				case 8, 10, 13, 14, 17:
					if (sandBM == null)	sandBM = new SandBMd(0, 0);
					if (roadBM == null)	roadBM = new RoadBMa(0, 0);
					land = "d";
				case 18, 19, 20:
					if (sandBM == null)	sandBM = new SandBMc(0, 0);
					if (roadBM == null)	roadBM = new RoadBMc(0, 0);
					land = "e";
				case 15, 16:
					if (sandBM == null)	sandBM = new SandBMc(0, 0);
					if (roadBM == null)	roadBM = new RoadBMb(0, 0);
					land = "c";
				default:
					if (sandBM == null)	sandBM = new SandBMa(0, 0);
					if (roadBM == null)	roadBM = new RoadBMa(0, 0);
					land = "a";
			}
		} else {
			if (Game.RAND.random(2) == 0) {
				if (sandBM == null)	sandBM = new SandBMb(0, 0);
				if (roadBM == null)	roadBM = new RoadBMb(0, 0);
				land = "b";
			} else {
				if (sandBM == null)	sandBM = new SandBMa(0, 0);
				if (roadBM == null)	roadBM = new RoadBMa(0, 0);
				land = "a";
			}
		}
		ySand = sandBM.height;
		yRoad = roadBM.height;
		// Store guides
		if (guides == null) {
			guides = new Hash<Array<UInt>>();
			guides.set("SRUL",	[RE.ROAD_COLOR, RE.SAND_COLOR, RE.SAND_COLOR, RE.SAND_COLOR]);
			guides.set("SRUR",	[RE.SAND_COLOR, RE.ROAD_COLOR, RE.SAND_COLOR, RE.SAND_COLOR]);
			guides.set("SRDR",	[RE.SAND_COLOR, RE.SAND_COLOR, RE.SAND_COLOR, RE.ROAD_COLOR]);
			guides.set("SRDL",	[RE.SAND_COLOR, RE.SAND_COLOR, RE.ROAD_COLOR, RE.SAND_COLOR]);
			guides.set("RSUL",	[RE.SAND_COLOR, RE.ROAD_COLOR, RE.ROAD_COLOR, RE.ROAD_COLOR]);
			guides.set("RSUR",	[RE.ROAD_COLOR, RE.SAND_COLOR, RE.ROAD_COLOR, RE.ROAD_COLOR]);
			guides.set("RSDR",	[RE.ROAD_COLOR, RE.ROAD_COLOR, RE.ROAD_COLOR, RE.SAND_COLOR]);
			guides.set("RSDL",	[RE.ROAD_COLOR, RE.ROAD_COLOR, RE.SAND_COLOR, RE.ROAD_COLOR]);
			guides.set("RS90",	[RE.ROAD_COLOR, RE.SAND_COLOR, RE.ROAD_COLOR, RE.SAND_COLOR]);
			guides.set("SR90",	[RE.SAND_COLOR, RE.ROAD_COLOR, RE.SAND_COLOR, RE.ROAD_COLOR]);
			guides.set("RS0",	[RE.ROAD_COLOR, RE.ROAD_COLOR, RE.SAND_COLOR, RE.SAND_COLOR]);
			guides.set("SR0",	[RE.SAND_COLOR, RE.SAND_COLOR, RE.ROAD_COLOR, RE.ROAD_COLOR]);
		}
		ready = true;
	}
	
	public static function createRoad () :Road {
		var r = new Road();
		return r;
	}
	
	public static function addSlice (road:Road, ground:GP, ?objects:Array<OP>/*, lvl:Int = 0*/) {
		var slice = new RS(ground, objects, road.newWidth);
		road.slices.push(slice);
	}
	
	public static function smartAddSlice (road:Road, lvl:Int, start:Bool = false) {
		
		if (AKApi.getGameMode() == GM_PROGRESSION && addLevelUpSlice(road, lvl, start))	return;
		else if (AKApi.getGameMode() == GM_LEAGUE)	lvl = Std.int(lvl / 2);
		
		if (start) {
			road.slices.push(new RS(GP.Straight, null, road.newWidth, 40));
			return;
		}
		
		var objects = new Array<OP>();
		
		var dropper:Bool = false;
		var shooter:Bool = false;
		var rail:Bool = false;
		
		// Dropper
		//if (lvl > 4 && Game.RAND.random(10) > 5) {
		if (lvl > 10 && Game.RAND.random(10) > 5) {
			objects.push(OP.PRapidDropper);
			dropper = true;
		// } else if (lvl > 3 && Game.RAND.random(10) > 5) {
		} else if (lvl > 6 && Game.RAND.random(10) > 5) {
			objects.push(OP.PDropper);
			dropper = true;
		}
		
		// Rail
		if (objects.length == 0 && Game.RAND.random(16) == 0) {
			objects.push(OP.PRail);
			rail = true;
		}
		if (Game.RAND.random(10) == 0) {
			objects.push(OP.POil);
		}
		
		// Shooter
		//if (lvl > 2 && Game.RAND.random(10) > 6) {
		if (lvl > 1 && Game.RAND.random(10) > 6) {
			objects.push(OP.PShooter);
			shooter = true;
		// } else if (lvl > 3 && Game.RAND.random(10) > 5) {
		} else if (lvl > 2 && Game.RAND.random(10) > 5) {
			objects.push(OP.PMovingShooter);
			shooter = true;
		// } else if (lvl > 4 && Game.RAND.random(10) > 5) {
		} else if (lvl > 5 && Game.RAND.random(10) > 5) {
			objects.push(OP.PDoubleShooter);
			shooter = true;
		// } else if (lvl > 5 && Game.RAND.random(10) > 5) {
		} else if (lvl > 8 && Game.RAND.random(10) > 5) {
			objects.push(OP.PTripleShooter);
			shooter = true;
		}
		
		// Obstacles
		var nObst = 0;
		while (nObst < Math.max(2, Math.min(lvl / 3, 8))) {
			if (lvl > 9 && Game.RAND.random(3) == 0) {
				switch (Game.RAND.random(4)) {
					case 0:	objects.push(OP.PTruckSix);
					case 1:	objects.push(OP.PHarleyV);
					case 2:	objects.push(OP.PSons);
					case 3:	objects.push(OP.PBikeLine);
				}
				nObst++;//These count for 2
			} else if (lvl > 6 && Game.RAND.random(3) == 0) {
				switch (Game.RAND.random(4)) {
					case 0:	objects.push(OP.PTruckFour);
					case 1:	objects.push(OP.PTruckTwo);
					case 2:	objects.push(OP.PLimo);
					case 3:	objects.push(OP.PTrio);
				}
			} else if (lvl > 3 && Game.RAND.random(3) == 0) {
				switch (Game.RAND.random(4)) {
					case 0:	objects.push(OP.PLoner);
					case 1:	objects.push(OP.PTruck);
					case 2:	objects.push(OP.PBus);
					case 3:	objects.push(OP.PMonster);
				}
			} else {
				switch (Game.RAND.random(4)) {
					case 0:	objects.push(OP.PSportCar);
					case 1:	objects.push(OP.PLightCar);
					case 2:	objects.push(OP.PDelorean);
					case 3:	objects.push(OP.PHarley);
				}
			}
			nObst++;
		}
		
		// Armor
		if (Game.RAND.random(20) == 0) {
			objects.push(OP.PArmor);
		}
		// OD
		if (!Player.instance.isOD && Game.RAND.random(10) > 7) {
			objects.push(OP.POverdrive);
		}
		
		var prevW:Int = 0;
		var prevX:Int = 0;
		
		var slice = new RS(GP.Straight, objects, road.newWidth, prevW, prevX);
		road.slices.push(slice);
	}
	
	public static function addLevelUpSlice (road:Road, lvl:Int, start:Bool) :Bool {
		
		var objects = new Array<OP>();
		var rtype = GP.Straight;
		var r:Int;
		var prevW:Int = 0;
		var prevX:Int = 0;
		//
		switch (lvl) {
			case 1:
				// Bonus
				if (Game.RAND.random(16) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(5) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				objects.push(OP.PLightCar);
				objects.push(OP.PSportCar);
				if (Game.RAND.random(10) == 0)	objects.push(OP.PSportCar);
				if (Game.RAND.random(15) == 0)	objects.push(OP.PLoner);
				if (Game.RAND.random(15) == 0)	objects.push(OP.PTrio);
				else if (Game.RAND.random(20) == 0) {
					objects.push(OP.PShooter);
				}
			case 2:
				// Bonus
				if (Game.RAND.random(16) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(5) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				objects.push(OP.PLightCar);
				objects.push(OP.PSportCar);
				if (Game.RAND.random(2) == 0) {
					objects.push(OP.PLightCar);
				}
				if (Game.RAND.random(12) == 0) {
					objects.push(OP.POil);
				}
				else if (Game.RAND.random(20) == 0) {
					objects.push(OP.PShooter);
				}
			case 3:
				// Bonus
				if (Game.RAND.random(16) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(5) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				objects.push(OP.PLightCar);
				objects.push(OP.PSportCar);
				if (Game.RAND.random(5) == 0) {
					objects.push(OP.PTrio);
				}
				if (Game.RAND.random(10) == 0) {
					objects.push(OP.PShooter);
					objects.push(OP.POil);
				}
			case 4:
				// Bonus
				if (Game.RAND.random(16) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(5) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				
				objects.push(OP.PLightCar);
				objects.push(OP.PSportCar);
				
				switch (Game.RAND.random(4)) {
					case 0:		objects.push(OP.PTrio);
					default:	objects.push(OP.PTruck);
				}
				if (Game.RAND.random(15) == 0) {
					objects.push(OP.PMovingShooter);
				}
			case 5:
				// Bonus
				if (Game.RAND.random(16) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(5) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				var noShooter = true;
				objects.push(OP.PLightCar);
				objects.push(OP.PLightCar);
				//objects.push(OP.PLoner);
				
				switch (Game.RAND.random(3)) {
					case 0:	objects.push(OP.PLightCar);
					case 1:	objects.push(OP.PDelorean);
					case 2:
						objects.push(OP.PShooter);
						noShooter = false;
				}
				if (Game.RAND.random(8) == 0) {
					objects.push(OP.PTrio);
				}
				else if (noShooter && Game.RAND.random(10) == 0) {
					objects.push(OP.PMovingShooter);
				}
			case 6:
				// Bonus
				if (Game.RAND.random(24) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(5) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				//objects.push(OP.PLoner);
				switch (Game.RAND.random(3)) {
					case 0, 1:	objects.push(OP.PTruck);
					case 2:	objects.push(OP.PTrio);
				}
				if (Game.RAND.random(4) == 0) {
					objects.push(OP.PShooter);
				}
				else if (Game.RAND.random(10) == 0) {
					objects.push(OP.PMovingShooter);
				}
			case 7:
				// Bonus
				if (Game.RAND.random(24) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(8) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				objects.push(OP.PLoner);
				//if (Game.RAND.random(20) > 18) {
					//objects.push(OP.PRail);
				//}
				objects.push(OP.PBus);
				if (Game.RAND.random(10) == 0) {
					objects.push(OP.PDropper);
				}
				if (Game.RAND.random(10) == 0) {
					objects.push(OP.PMovingShooter);
				}
				
			case 8:
				rtype = GP.Tunnel(RW.XL);
				// Bonus
				if (Game.RAND.random(24) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(8) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				switch (Game.RAND.random(8)) {
					case 0:	objects.push(OP.PBikeLine);
					case 1:	objects.push(OP.PSons);
					case 2:	objects.push(OP.PTrio);
					default:	objects.push(OP.PSons);
				}
				if (Game.RAND.random(10) == 0) {
					objects.push(OP.PDoubleShooter);
				}
				else if (Game.RAND.random(15) == 0) {
					objects.push(OP.PMovingShooter);
				}
			case 9:
				// Bonus
				if (Game.RAND.random(24) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(8) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				objects.push(OP.PSons);
				if (Game.RAND.random(3) == 0) {
					objects.push(OP.PBikeLine);
				}
				if (Game.RAND.random(10) == 0) {
					objects.push(OP.PDropper);
				}
				else if (Game.RAND.random(10) == 0) {
					objects.push(OP.PMovingShooter);
				}
			case 10:
				rtype = GP.Tunnel(RW.L);
				// Bonus
				if (Game.RAND.random(24) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(8) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				switch (Game.RAND.random(2)) {
					case 0:	objects.push(OP.PSportCar);
					case 1:	objects.push(OP.PSons);
				}
				if (Game.RAND.random(10) == 0) {
					objects.push(OP.PTruck);
					objects.push(OP.POil);
				}
				else if (Game.RAND.random(8) == 0) {
					objects.push(OP.PRail);
					objects.push(OP.PMovingShooter);
				}
				if (Game.RAND.random(10) == 0) {
					objects.push(OP.PDropper);
				}
			case 11:
				// Bonus
				if (Game.RAND.random(24) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(8) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				objects.push(OP.PSons);
				objects.push(OP.PTruck);
				switch (Game.RAND.random(2)) {
					case 0:	objects.push(OP.PLightCar);
					case 1:	objects.push(OP.PSportCar);
				}
				if (Game.RAND.random(12) == 0) {
					objects.push(OP.PMovingShooter);
					objects.push(OP.PDropper);
				}
				else if (Game.RAND.random(8) == 0) {
					objects.push(OP.PMovingShooter);
				}
			case 12:
				// Bonus
				if (Game.RAND.random(24) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(12) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				objects.push(OP.PBikeLine);
				if (Game.RAND.random(10) == 0) {
					objects.push(OP.PBikeLine);
					objects.push(OP.POil);
				}
				if (Game.RAND.random(10) == 0) {
					objects.push(OP.PMovingShooter);
				}
				else if (Game.RAND.random(10) == 0) {
					objects.push(OP.PDoubleShooter);
				}
			case 13:
				rtype = GP.Tunnel(RW.M);
				// Bonus
				if (Game.RAND.random(24) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(12) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				// Vehicules
				objects.push(OP.PLoner);
			
				if (Game.RAND.random(20) > 16)	objects.push(OP.PRail);
				objects.push(OP.POil);
				switch (Game.RAND.random(5)) {
					case 0:	objects.push(OP.PLoner);
					case 2:	objects.push(OP.PTruckFour);
					case 1: objects.push(OP.PBikeLine);
				}
				if (Game.RAND.random(10) == 0)	objects.push(OP.PDoubleShooter);
				else if (Game.RAND.random(6) == 0) {
					objects.push(OP.PMovingShooter);
				}
			case 14:
				rtype = GP.Tunnel(RW.L);
				// Bonus
				if (Game.RAND.random(24) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(12) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				switch (Game.RAND.random(3)) {
					case 0:	objects.push(OP.PTruckTwo);
					case 1:	objects.push(OP.PTruckFour);
					case 2:	objects.push(OP.PRapidDropper);
				}
				if (Game.RAND.random(10) == 0)	objects.push(OP.PDoubleShooter);
				else if (Game.RAND.random(2) == 0)	objects.push(OP.PTruck);
				else if (Game.RAND.random(6) == 0)	objects.push(OP.PTruckSix);
				else if (Game.RAND.random(8) == 0) {
					objects.push(OP.PMovingShooter);
				}
				objects.push(OP.PTruck);
				objects.push(OP.PMonster);
				
			case 15:
				rtype = GP.Tunnel(RW.L);
				// Bonus
				if (Game.RAND.random(30) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(15) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				objects.push(OP.PHarleyV);
				switch (Game.RAND.random(6)) {
					case 0:	objects.push(OP.PBikeLine);
					case 1:	objects.push(OP.PSons);
					case 3:	objects.push(OP.PHarley);
				}
				if (Game.RAND.random(8) == 0){
					objects.push(OP.PDropper);
					objects.push(OP.POil);
				}
				else if (Game.RAND.random(6) == 0) {
					objects.push(OP.PMovingShooter);
				}
			case 16:
				rtype = GP.Tunnel(RW.M);
				// Bonus
				if (Game.RAND.random(30) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(15) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				var noShooter = true;
				switch (Game.RAND.random(8)) {
					case 0:	objects.push(OP.PBikeLine);
					case 1:	objects.push(OP.PSons);
					case 2:	objects.push(OP.PHarleyV);
				}
				if (Game.RAND.random(5) == 0){
					objects.push(OP.PRapidDropper);
					objects.push(OP.POil);
					objects.push(OP.PMonster);
				}
				else if (Game.RAND.random(6) == 0) {
					objects.push(OP.PMovingShooter);
					noShooter = false;
				}
				if (noShooter) {
					switch (Game.RAND.random(4)) {
						case 0:	objects.push(OP.PShooter);
						case 1:	objects.push(OP.PDoubleShooter);
					}
				}
				
			case 17:
				rtype = GP.Tunnel(RW.L);
				// Bonus
				if (Game.RAND.random(30) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(15) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				switch (Game.RAND.random(4)) {
					case 0:	objects.push(OP.PBus);
					case 1:	objects.push(OP.PSons);
					case 2:	objects.push(OP.PTruck);
					case 3:	objects.push(OP.PMonster);
				}
				if (Game.RAND.random(20) == 0) {
					objects.push(OP.PDelorean);
				}
				if (Game.RAND.random(5) == 0) {
					objects.push(OP.PMovingShooter);
				} else if (Game.RAND.random(5) == 0) {
					objects.push(OP.PDoubleShooter);
				}
				objects.push(OP.PBikeLine);
				objects.push(OP.PRail);
				objects.push(OP.PRapidDropper);
				
			case 18:
				rtype = GP.Tunnel(RW.M);
				// Bonus
				if (Game.RAND.random(30) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(15) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				var noShooter = true;
				switch (Game.RAND.random(4)) {
					case 0:	objects.push(OP.PBus);
					case 1:	objects.push(OP.PSons);
					case 2:	objects.push(OP.PTruck);
					case 3:
						objects.push(OP.PDoubleShooter);
						noShooter = false;
				}
				if (Game.RAND.random(4) == 0) {
					if (noShooter)	objects.push(OP.PTripleShooter);
					objects.push(OP.POil);
				} else if (Game.RAND.random(5) == 0) {
					objects.push(OP.PRail);
				} else if (Game.RAND.random(10) == 0) {
					objects.push(OP.PLimo);
				}
				if (noShooter && Game.RAND.random(5) == 0) {
					objects.push(OP.PMovingShooter);
				}
				objects.push(OP.PRapidDropper);
			case 19:
				rtype = GP.Tunnel(RW.XL);
				// Bonus
				if (Game.RAND.random(40) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(15) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				var noShooter = true;
				var g = Game.RAND.random(5);
				//#if tuning g=2; #end
				switch (g) {
					case 0:
						objects.push(OP.PShooter);
						noShooter = false;
					case 1:
						objects.push(OP.PMovingShooter);
						noShooter = false;
					case 2:
						objects.push(OP.PTripleShooter);
						noShooter = false;
					case 3:
						objects.push(OP.PRapidDropper);
					case 4:
						objects.push(OP.PMonster);
				}
				if (Game.RAND.random(5) == 0)		objects.push(OP.PLimo);
				if (noShooter)	objects.push(OP.PMovingShooter);
				
				objects.push(OP.PSons);
				objects.push(OP.POil);
				objects.push(OP.PRail);
				
				
			case 20:
				rtype = GP.Tunnel(RW.XL);
				// Bonus
				if (Game.RAND.random(40) == 0)	objects.push(OP.PArmor);
				if (!Player.instance.isOD && Game.RAND.random(15) == 0)			objects.push(OP.POverdrive);
				// Vehicules
				var noShooter = true;
				var noDropper = true;
				switch (Game.RAND.random(5)) {
					case 0:
						objects.push(OP.PShooter);
						noShooter = false;
					case 1:
						objects.push(OP.POil);
					case 2:
						objects.push(OP.PTripleShooter);
						noShooter = false;
					case 3:
						objects.push(OP.PDropper);
						noDropper = false;
					case 4:
						objects.push(OP.PMonster);
				}
				if (noShooter)	objects.push(OP.PMovingShooter);
				if (noDropper)	objects.push(OP.PRapidDropper);
				objects.push(OP.PLimo);
				objects.push(OP.PRail);
				
			default:
				return false;
		}
		
		// Add slice
		if (start)	objects = null;
		road.slices.push(new RS(rtype, objects, road.newWidth, 42));
		if (rtype != GP.Straight)	road.decoration = false;
		return true;
	}
	
	static public var lastRoadStart:UInt;
	static public var lastRoadWidth:UInt;
	static var checkOffsetY:Int = 2;
	
	public static function renderPart (road:Road, target:BitmapData, offset:Int = 0) :Void {
		if (!ready)	init();
		
		drawSandPart(target, offset);
		drawRoadPart(road, target, offset);
		
		//trace("rendered a line");
		
		// See if start of a slice and get spawn infos
		//var px:Int = road.getBD().getPixel(0, 0);
		//var px:Int = road.getBD().getPixel(0, offset);
		
		var px:Int = road.getBD().getPixel(0, offset + checkOffsetY);
		if (px & 0xFF0000 != px) {
			//trace((px & 0xFF0000) + " / " + ((px & 0x00FF00) >> 8) + " / " + (px & 0x0000FF));
			lastRoadStart = (px & 0x00FF00) >> 8;
			lastRoadWidth = px & 0x0000FF;
			var hash:IntHash<Bool> = new IntHash<Bool>();
			
			var toSpawn:List<Dynamic> = new List<Dynamic>();
			var spots:Array<IntPoint> = new Array<IntPoint>();
			
			//trace("----------------------------------");
			
			for (x in 1...road.getBD().width) {
				var hx:Int = 1;
				var hy:Int = 0;
				var safety:Int;
				//var p = road.getBD().getPixel(x, 0);
				var p = road.getBD().getPixel(x, offset + checkOffsetY);
				var t = p & 0x0000FF;
				var v = (p & 0x00FF00) >> 8;
				if (t != 0) {
					var e:Entity = null;
					var sd:SpawnData;
					switch (t) {
						case Data.c(OT.ORail):
							e = new Rail(v);
							hx = Std.int(lastRoadStart + lastRoadWidth / 2) - Game.rand(0, 3, true);
							hy = -v - 1 + offset + checkOffsetY + 5;
							safety = 0;
							while (!isXFree(hx, hy, spots) && safety < 50) {
								hx = Std.int(lastRoadStart + lastRoadWidth / 2) - Game.rand(0, 3, true);
								safety++;
							}
						case Data.c(OT.OBorderRail):
							e = null;
							hx = x;
							hy = -v - 1 + offset + checkOffsetY;
							//addBorderRails(hx, hy, toSpawn, (x != Std.int(lastRoadStart)));
							addBorderRails(Std.int(lastRoadStart), hy, toSpawn, false);
							addBorderRails(Std.int(lastRoadStart + lastRoadWidth - 1), hy, toSpawn, true);
						//{
						case Data.c(OT.OOil):
							e = new Oil();
							hx = lastRoadStart + Game.RAND.random(lastRoadWidth - Math.ceil(e.w / Game.TILE_SIZE) - 2) + 1;
							hy = -Game.RAND.random(35);
						case Data.c(OT.ODropper):
							if (Game.RAND.random(2) == 0) {
								v = lastRoadStart + 1;
								e = new Dropper(v, -1);
								hx = lastRoadStart + lastRoadWidth - 3;
							} else {
								v = lastRoadStart + lastRoadWidth - 3;
								e = new Dropper(v, 1);
								hx = lastRoadStart + 1;
							}
						case Data.c(OT.ORapidDropper):
							if (Game.RAND.random(2) == 0) {
								v = lastRoadStart;
								e = new Dropper(v, -1, true);
								hx = lastRoadStart + lastRoadWidth - 2;
							} else {
								v = lastRoadStart + lastRoadWidth - 2;
								e = new Dropper(v, 1, true);
								hx = lastRoadStart;
							}
						case Data.c(OT.OShooter):
							e = new Shooter(v);
							hx = Std.int(lastRoadStart + lastRoadWidth / 2);
						case Data.c(OT.OMovingShooter):
							e = new Shooter(v, 0, true);
							hx = Std.int(lastRoadStart + lastRoadWidth / 2);
						case Data.c(OT.OLoner):
							addObstacle(OT.OLoner, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OTrio):
							addObstacle(OT.OTrio, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OSons):
							addObstacle(OT.OSons, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OHarley):
							addObstacle(OT.OHarley, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OHarleyV):
							addObstacle(OT.OHarleyV, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OBikeLine):
							addObstacle(OT.OBikeLine, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OSportCar):
							addObstacle(OT.OSportCar, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
							
						case Data.c(OT.OTruck):
							addObstacle(OT.OTruck, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OTruckTwo):
							addObstacle(OT.OTruckTwo, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OTruckFour):
							addObstacle(OT.OTruckFour, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OTruckSix):
							addObstacle(OT.OTruckSix, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
							
						case Data.c(OT.OLimo):
							addObstacle(OT.OLimo, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OMonster):
							addObstacle(OT.OMonster, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						
						case Data.c(OT.OBus):
							addObstacle(OT.OBus, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.ODelorean):
							addObstacle(OT.ODelorean, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OLightCar):
							addObstacle(OT.OLightCar, hash, lastRoadStart, lastRoadWidth, 0, toSpawn);
						case Data.c(OT.OArmor):
							e = new Bonus(OT.OArmor);
							hx = Std.int(lastRoadStart + Game.RAND.random(lastRoadWidth - 3)) + 1;
							hy = offset - checkOffsetY - Game.RAND.random(10);
						case Data.c(OT.OOverdrive):
							e = new Bonus(OT.OOverdrive);
							hx = Std.int(lastRoadStart + Game.RAND.random(lastRoadWidth - 3)) + 1;
							hy = offset - checkOffsetY - Game.RAND.random(10);
						//}
						default:
							trace("unknown type: " + StringTools.hex(t));
							continue;
					}
					if (e != null) {
						e.x = hx * Game.TILE_SIZE;
						e.y = (hy + checkOffsetY) * Game.TILE_SIZE;
						if (Std.is(e, Bonus)) {
							Game.TAP.x = e.x;
							Game.TAP.y = e.y;
							cast(e, Bonus).setOrigin(Game.TAP);
						}
						sd = new SpawnData(e, { _adaptY:false } );
						toSpawn.push(sd);
					}
				}
			}
			
			var s = 0;
			for (e in toSpawn) {
				if (Std.is(e, Shooter) || (Std.is(e, SpawnData) && Std.is(cast(e, SpawnData).entity, Shooter))) {
					s++;
				}
			}
			Level.instance.setAllowedShooters(s);
			for (e in toSpawn) {
				EM.instance.dispatchEvent(new GameEvent(GE.SPAWN_ENTITY, e));
			}
		}
		
		if (road.decoration && Game.OBJ_RAND.random(3) == 0) {
			var o = Level.instance.baseObjects.draw(Game.OBJ_RAND.random);
			var p = blendPosition(o, road.getBD().width, checkOffsetY);
			
			function paint(str, x, y) {
				if( Level.me!=null )
					Level.me.paintEntityDirect(str, x, y);
			}
			
			var d = switch (o) {
				case OT.ORock:	paint("stone_" + (Game.OBJ_RAND.random(5) + 1), p.x, p.y);
				case OT.OSkull:	paint("skull", p.x, p.y);
				case OT.OCrack:	paint("crack_" + Game.OBJ_RAND.random(4), p.x, p.y);
				default:		
			}
		}
	}
	
	static function addBorderRails (xx, yy, list, flip) {
		for (i in 0...3) {
			var e = new Rail(14, true, flip);
			e.x = xx * Game.TILE_SIZE;
			e.y = (yy - i * 14) * Game.TILE_SIZE;
			var sd = new SpawnData(e, { _adaptY:false } );
			list.push(sd);
		}
	}
	
	static function isXFree (x:Int, y:Int, spots:Array<IntPoint>, add:Bool = true) :Bool {
		for (s in spots) {
			if (s.x == x)	return false;
		}
		if (add)	spots.push(new IntPoint(x, y));
		return true;
	}
	
	/*static function isFree (x:Int, y:Int, spots:Array<IntPoint>, add:Bool = true) :Bool {
		for (s in spots) {
			if (s.x == x && s.y == y)	return false;
		}
		if (add)	spots.push(new IntPoint(x, y));
		return true;
	}*/
	
	static function blendPosition (o:OT, totalWidth:Int, checkOffsetY:Int) :IntPoint {
		var p = new IntPoint(0, checkOffsetY * Game.TILE_SIZE);
		switch (o) {
			case OT.OSkull, OT.ORock:
				if (Game.OBJ_RAND.random(2) == 0)	p.x = Game.randObj(1, lastRoadStart - 1) * Game.TILE_SIZE;
				else								p.x = Game.randObj(lastRoadStart + lastRoadWidth + 1, totalWidth - 1) * Game.TILE_SIZE;
			default:
				p.x = Game.randObj(lastRoadStart + 1, lastRoadStart + lastRoadWidth - 1) * Game.TILE_SIZE;
		}
		return p;
	}
	
	static function drawSandPart (target:BitmapData, offset:Int = 0) :Void {
		
		// Init vars
		var w = 0;
		Game.TAP.x = 0;
		Game.TAP.y = offset * Game.TILE_SIZE;
		Game.TAR.x = Game.TAR.y = 0;
		Game.TAR.width = sandBM.width;
		Game.TAR.height = Game.TILE_SIZE;
		
		ySand -= Game.TILE_SIZE;
		Game.TAR.y = ySand;
		
		while (w < target.width) {
			target.copyPixels(sandBM, Game.TAR, Game.TAP);
			// Update vars for horizontal repeat
			Game.TAP.x += sandBM.width;
			w += sandBM.width;
		}
		
		if (ySand <= 0)	ySand = sandBM.height;
	}
	
	static function drawRoadPart (road:Road, target:BitmapData, offset:Int = 0) :Void {
		Game.TAR.x = 0;
		Game.TAR.y = 0;
		Game.TAR.width = Game.TAR.height = Game.TILE_SIZE;
		Game.TAP.x = 0;
		Game.TAP.y = offset * Game.TILE_SIZE;
		
		yRoad -= Game.TILE_SIZE;
		Game.TAR.y = yRoad;
		
		for (x in 0...road.getBD().width) {
			Game.TAP.x = x * Game.TILE_SIZE;
			Game.TAP.y = offset * Game.TILE_SIZE;
			
			//var px = road.getBD().getPixel(x, 0);
			var px = road.getBD().getPixel(x, offset);
			// Draw road background
			var rpx = px & 0xFF0000;// get only the R channel
			if (rpx == 0) {
				// Pick the right part of the texture
				Game.TAR.x = (x % (roadBM.width / Game.TILE_SIZE)) * Game.TILE_SIZE;
				//Game.TAR.y = (ty % (roadBM.height / Game.TILE_SIZE)) * Game.TILE_SIZE;
				target.copyPixels(roadBM, Game.TAR, Game.TAP);
				//trace("painting road " + Game.TAP);
			}
			else if (rpx == 0x80) {
				Game.TAR.x = Game.TAR.y = 0;
				Game.TAR.width = Game.TAR.height = Game.TILE_SIZE;
				target.copyPixels(sandBM, Game.TAR, Game.TAP);
			}
			// Draw road borders if needed
			//var b = getBorders(road.getBD(), x, 0);
			var b = getBorders(road.getBD(), x, offset);
			if (b == null)	continue;
			else {
				Game.TAP.x -= Game.TILE_SIZE / 2;
				Game.TAP.y += Game.TILE_SIZE / 2;
				FM.copyFrame(target, b, Game.SHEET_TRANS, Game.TAP);
			}
		}
		
		if (yRoad <= 0)	yRoad = roadBM.height;
	}
	
	static function getBorders (bd:BitmapData, x:Int, y:Int) :String {
		//return null;
		// If all pixels are the same color, no border
		var px = getR(bd, x, y);// Get only the R channel
		//trace(x + "," + y + ": " + px + " / " + getR(bd, x - 1, y) + " / " + getR(bd, x - 1, y + 1) + " / " + getR(bd, x, y + 1));
		if (px == getR(bd, x - 1, y) && px == getR(bd, x-1, y+1) && px == getR(bd, x, y+1)) {
			return null;
		}
		
		// Get array for the current area
		var area = new Array<UInt>();
		area.push(getR(bd, x-1, y));
		area.push(getR(bd, x, y));
		area.push(getR(bd, x-1, y+1));
		area.push(getR(bd, x, y+1));
		
		// Compare area to guides
		for (k in guides.keys()) {
			if (area.toString() == guides.get(k).toString()) {
				var s = "border" + k + RE.land;
				var rand = new Rand(y * 6415327);// big seed or else no random
				s += switch (k) {
					case "RS90", "SR90": "_" + Std.string(rand.random(2));
					//case "RS0", "SR0": "_0";
					//default: "_" + Std.string(rand.random(2));
					default: "_0";
				}
				return s;
			}
		}
		// Failed to find a match (should never happen)
		return null;
	}
	
	static function addObstacle (t:OT, hash:IntHash<Bool>, roadStart:Int, roadWidth:Int, y:Int, list:List<Dynamic>) {
		var E:Obstacle = null;
		var e:Obstacle = null;
		var hx:Int = 1;
		var hy:Int = 1;
		var s:Int = 0;
		switch (t) {
			case OT.OLoner, OT.OSportCar, OT.OBus, OT.OTruck, OT.OLightCar, OT.ODelorean, OT.OHarley, OT.OMonster:
				e = new Obstacle(t);
				hx = roadStart + Game.RAND.random(roadWidth - e.w - 2) + 1;
				hy = -Game.RAND.random(35);
				e.x = hx * Game.TILE_SIZE;
				e.y = hy * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
			case OT.OLimo:
				e = new Obstacle(t);
				if (Game.RAND.random(2) == 0) {
					hx = roadStart + 1;
					s = roadStart + roadWidth - 2;
				} else {
					hx = roadStart + roadWidth - 2;
					s = roadStart + 1;
				}
				hy = -Game.RAND.random(35);
				e.x = hx * Game.TILE_SIZE;
				e.y = hy * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Crosser, null, new IntPoint(s, 0));
				list.push(e);
			case OT.OTruckTwo:
				hx = roadStart + 3;
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = y * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				hx = roadStart + roadWidth - 3;
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = y * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
			case OT.OTruckFour:
				hx = roadStart + 3;
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = y * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = (y - 8) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				hx = roadStart + roadWidth - 3;
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = y * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = (y - 8) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
			case OT.OTruckSix:
				hx = roadStart + 5;
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = y * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OTruck);
				e.x = (hx + 1) * Game.TILE_SIZE;
				e.y = (y - 6) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = (y - 12) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				hx = roadStart + roadWidth - 5;
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = y * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OTruck);
				e.x = (hx - 1) * Game.TILE_SIZE;
				e.y = (y - 6) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OTruck);
				e.x = hx * Game.TILE_SIZE;
				e.y = (y - 12) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
			case OT.OTrio:
				hx = roadStart + Game.RAND.random(roadWidth - 6) + 4;
				E = new Obstacle(OT.OTrio);
				E.x = hx * Game.TILE_SIZE;
				E.y = y * Game.TILE_SIZE;
				E.setOrigin(E.x);
				E.setBehaviour(Behaviour.Leader);
				list.push(E);
				//
				e = new Obstacle(OT.OTrio);
				e.x = (hx - 2.5) * Game.TILE_SIZE - 20;
				e.y = (y + 1) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Follower, E, new IntPoint(-2 * Game.TILE_SIZE - 16));
				list.push(e);
				//
				e = new Obstacle(OT.OTrio);
				e.x = (hx + 2.5) * Game.TILE_SIZE + 20;
				e.y = (y + 1) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Follower, E, new IntPoint(2 * Game.TILE_SIZE + 16));
				list.push(e);
				//
			case OT.OSons:
				hx = roadStart + Game.RAND.random(roadWidth - 9) + 1;
				e = new Obstacle(OT.OSons);
				e.x = hx * Game.TILE_SIZE;
				e.y = y * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OSons);
				e.x = hx * Game.TILE_SIZE;
				e.y = (y + 2) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OSons);
				e.x = hx * Game.TILE_SIZE;
				e.y = (y + 4) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OSons);
				e.x = hx * Game.TILE_SIZE;
				e.y = (y + 6) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
				e = new Obstacle(OT.OSons);
				e.x = hx * Game.TILE_SIZE;
				e.y = (y + 8) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				list.push(e);
				//
			case OT.OHarleyV:
				hx = roadStart + Game.RAND.random(roadWidth - 4) + 2;
				E = new Obstacle(OT.OHarley);
				E.x = hx * Game.TILE_SIZE;
				E.y = y * Game.TILE_SIZE;
				E.setOrigin(E.x);
				E.setBehaviour(Behaviour.Leader);
				list.push(E);
				//
				e = new Obstacle(OT.OHarley);
				e.x = (hx - 1) * Game.TILE_SIZE;
				e.y = (y + 2) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Follower, E, new IntPoint(-Game.TILE_SIZE, 2*Game.TILE_SIZE));
				list.push(e);
				//
				e = new Obstacle(OT.OHarley);
				e.x = (hx + 1) * Game.TILE_SIZE;
				e.y = (y + 2) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Follower, E, new IntPoint(Game.TILE_SIZE, 2*Game.TILE_SIZE));
				list.push(e);
				//
				e = new Obstacle(OT.OHarley);
				e.x = (hx - 2) * Game.TILE_SIZE;
				e.y = (y + 4) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Follower, E, new IntPoint(-2*Game.TILE_SIZE, 4*Game.TILE_SIZE));
				list.push(e);
				//
				e = new Obstacle(OT.OHarley);
				e.x = (hx + 2) * Game.TILE_SIZE;
				e.y = (y + 4) * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Follower, E, new IntPoint(2*Game.TILE_SIZE, 4*Game.TILE_SIZE));
				list.push(e);
				//
			case OT.OBikeLine:
				hx = roadStart + Game.RAND.random(roadWidth - 6) + 1;
				hy = -(Game.RAND.random(8) + 1) * 4;
				E = new Obstacle(OT.OHarley);
				E.x = hx * Game.TILE_SIZE;
				E.y = hy * Game.TILE_SIZE;
				E.setOrigin(E.x);
				E.setBehaviour(Behaviour.Leader);
				list.push(E);
				//
				e = new Obstacle(OT.OHarley);
				e.x = (hx + 2.5) * Game.TILE_SIZE;
				e.y = hy * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Follower, E, new IntPoint(2*Game.TILE_SIZE));
				list.push(e);
				//
				e = new Obstacle(OT.OHarley);
				e.x = (hx + 5) * Game.TILE_SIZE;
				e.y = hy * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Follower, E, new IntPoint(4*Game.TILE_SIZE));
				list.push(e);
				//
				e = new Obstacle(OT.OHarley);
				e.x = (hx + 7.5) * Game.TILE_SIZE;
				e.y = hy * Game.TILE_SIZE;
				e.setOrigin(e.x);
				e.setBehaviour(Behaviour.Follower, E, new IntPoint(6*Game.TILE_SIZE));
				list.push(e);
				//
			default:
				trace(t + " not spawned, case not handled");
				return;
		}
	}
	
	inline static function getR (bd:BitmapData, x:Int, y:Int) :UInt {
		return (bd.getPixel(x, y) & 0xFF0000);
	}
	
	/*public static function blendObjects (objects:Array<ObjectSpawnData>, target:BitmapData, y:Int = 0) :Void {
		if (objects == null || objects.length == 0) return;
		
		var obj = objects.filter(function (s:ObjectSpawnData) :Bool { return s.blend; } );
		for (o in obj) {
			if (o.pos == null || o.pos.length <= 0)	continue;
			for (p in o.pos) {
				//trace("blending " + o.type + " at " + p);
				var pt = new Point(p.x * Game.TILE_SIZE, p.y * Game.TILE_SIZE + y);
				
				var flip = false;
				var center = true;
				
				if (o.onSide) {
					center = false;// onSide objects are not meant to be centered
					// Since default sprite are made for the left side, this one needs to be flipped
					if (p.side == 1)	flip = true;
				}
				else {
					flip = (Game.OBJ_RAND.random(4) == 0);// Random flip for regular objects
				}
				if (flip)	pt.x += TS;
				if (center) {
					pt.x += 0.5 * Game.TILE_SIZE;
					pt.y += 0.5 * Game.TILE_SIZE;
				}
				
				if (o.type == OT.OSkull)				FM.copyFrame(target, "skull", Game.SHEET_ROAD, pt, center, flip);
				else if (o.type == OT.ORock)			FM.copyFrame(target, "stone_" + (RAND.random(5) + 1), Game.SHEET_ROAD, pt, center, flip);
				else if (o.type == OT.OCrackEdge)		FM.copyFrame(target, "crackEdge_" + RAND.random(4), Game.SHEET_ROAD, pt, center, flip);
				else if (o.type == OT.OCrack)			FM.copyFrame(target, "crack_" + RAND.random(4), Game.SHEET_ROAD, pt, center, flip);
			}
		}
	}*/
	
}

typedef GP = GroundPattern;
enum GroundPattern {
	Straight;
	Tunnel(n:Int);
	AllRoad;
	AllSand;
}

typedef OP = ObjectsPattern;
enum ObjectsPattern {
	PLoner;
	PTrio;
	PSons;
	PHarley;
	PHarleyV;
	PBikeLine;
	PSportCar;
	PTruck;
	PTruckTwo;
	PTruckFour;
	PTruckSix;
	PBus;
	PLightCar;
	PDelorean;
	PLimo;
	PMonster;
	
	PShooter;
	PDoubleShooter;
	PTripleShooter;
	PMovingShooter;
	
	PDropper;
	PRapidDropper;
	
	PRail;
	POil;
	
	PArmor;
	POverdrive;
	PKado;
}

class ObjectSpawnData implements Public {
	
	var type:OT;
	var groundReq:UInt;
	var onSide:Bool;
	var sideCheck:Int;
	var count:Int;
	var perSlice:Bool;
	var color:UInt;
	var pos:Array<SpawnPoint>;
	var blend:Bool;
	var usePerlin:Bool;
	
	function new (type:OT, count:Int, perSlice:Bool = true) {
		this.type = type;
		this.count = count;
		this.perSlice = perSlice;
		// Set default values
		groundReq = switch (type) {
			case OT.ORock, OT.OSkull: RE.SAND_COLOR;
			default: RE.ROAD_COLOR;
		}
		onSide = switch (type) {
			case OT.OCrackEdge: true;
			default: false;
		}
		blend = switch (type) {
			case OT.OCrack, OT.OCrackEdge, OT.ORock, OT.OSkull: true;
			default: false;
		}
		usePerlin = !onSide;
		color = Data.c(type);
	}
	
	function clone (full:Bool = true) :ObjectSpawnData {
		var sd = new ObjectSpawnData(type, count, perSlice);
		sd.blend = blend;
		sd.color = color;
		sd.groundReq = groundReq;
		sd.onSide = onSide;
		if (pos != null) {
			if (full)	sd.pos = pos.concat([]);
			else		sd.pos = new Array<SpawnPoint>();
		}
		sd.sideCheck = sideCheck;
		return sd;
	}
	
	function toString () :String {
		return "[ObjectSpawnData] { type:" + type + ", count:" + count + ", pos:" + pos + " }";
	}
	
}

class SpawnPoint extends Point {
	public var side:Int;
	public function new (x:Int, y:Int, side = 0) {
		super(x, y);
		this.side = side;
	}
	override public function clone () :SpawnPoint {
		return new SpawnPoint(Std.int(x), Std.int(y), side);
	}
}










