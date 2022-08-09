package ;
import api.AKApi;
import flash.geom.Point;
import utils.IntPoint;

/**
 * ...
 * @author 01101101
 */

 // List all different vehicles here
typedef OT = ObjectType;
enum ObjectType {
	
	ORail;
	OBorderRail;
	ODropper;
	ORapidDropper;
	OShooter;
	ODoubleShooter;
	OTripleShooter;
	OMovingShooter;
	OLoner;
	OTrio;
	OSons;
	OHarley;
	OHarleyV;
	OBikeLine;
	OSportCar;
	OTruck;
	OTruckTwo;
	OTruckFour;
	OTruckSix;
	OBus;
	Bike;
	OLightCar;
	ODelorean;
	OLimo;
	OMonster;
	
	PlayerCar;
	Ghost;
	
	ODrop;
	OWarningShot;
	OShot;
	OExplosion;
	OBulletImpact;
	OOil;
	
	OArmor;
	OOverdrive;
	OKado;
	
	ORock;
	OSkull;
	OCrack;
	OCrackEdge;
	
	/*SportCar;
	PinupTruck;
	Van;
	SmallTruck;
	Pickup;
	FireTruck;
	Tank;
	Limo;
	// Breakable
	Crate;
	Barrel;
	Tire;
	// Fixed
	Nitro;
	Oil;
	Pitstop;
	PKado;
	Hole;
	BigHole;
	// Deco
	Skull;
	Rock;
	Crack;
	CrackEdge;
	Sand;
	Explosion;*/
}

class Data {
	
	//static var levels:IntHash<Int> = new IntHash<Int>();
	static var colors:Hash<UInt> = new Hash<UInt>();
	static public var vehicles:Hash<AnimData> = new Hash<AnimData>();
	
	static public function init () {
		// Levels
		//levels.set(1, 1000);
		//levels.set(2, 1500);
		//levels.set(3, 2000);
		
		// List colors
		colors.set(Std.string(OT.ORail),			0xFF);
		colors.set(Std.string(OT.ODropper),			0xFE);
		colors.set(Std.string(OT.ORapidDropper),	0xFD);
		colors.set(Std.string(OT.OShooter),			0xFC);
		colors.set(Std.string(OT.ODoubleShooter),	0xFB);
		colors.set(Std.string(OT.OTripleShooter),	0xFA);
		colors.set(Std.string(OT.OMovingShooter),	0xF9);
		colors.set(Std.string(OT.OLoner),			0xF8);
		colors.set(Std.string(OT.OTrio),			0xF7);
		colors.set(Std.string(OT.OSons),			0xF6);
		colors.set(Std.string(OT.OArmor),			0xF5);
		colors.set(Std.string(OT.OOverdrive),		0xF4);
		colors.set(Std.string(OT.OSportCar),		0xF3);
		colors.set(Std.string(OT.OTruck),			0xF2);
		colors.set(Std.string(OT.OBus),				0xF1);
		colors.set(Std.string(OT.OLightCar),		0xF0);
		colors.set(Std.string(OT.ODelorean),		0xEF);
		colors.set(Std.string(OT.OKado),			0xEE);
		colors.set(Std.string(OT.OBorderRail),		0xED);
		colors.set(Std.string(OT.OOil),				0xEC);
		colors.set(Std.string(OT.OHarley),			0xEB);
		colors.set(Std.string(OT.OHarleyV),			0xEA);
		colors.set(Std.string(OT.OBikeLine),		0xE9);
		colors.set(Std.string(OT.OTruckTwo),		0xE8);
		colors.set(Std.string(OT.OTruckFour),		0xE7);
		colors.set(Std.string(OT.OTruckSix),		0xE6);
		colors.set(Std.string(OT.OLimo),			0xE5);
		colors.set(Std.string(OT.OMonster),			0xE4);
		
		// List vehicles properties below			new VehicleData(name, versions, boss, side frames, flippable, shadow offset, shadow name);
		vehicles.set(Std.string(OT.PlayerCar),		new AnimData("car",			1, false,	2, false,	new IntPoint()));
		vehicles.set(Std.string(OT.Ghost),			new AnimData("ghost",		1, false,	1, true,	new IntPoint(),	"car"));
		vehicles.set(Std.string(OT.ODropper),		new AnimData("tank",		2, true,	1, false,	new IntPoint()));
		//vehicles.set(Std.string(OT.OShooter),		new AnimData("hovercraft",	1, false,	1, false,	new IntPoint()));
		vehicles.set(Std.string(OT.OShooter),		new AnimData("hovercraft",	1, false,	0, true,	new IntPoint(80, 80)));
		vehicles.set(Std.string(OT.OLoner),			new AnimData("van",			5, true,	1, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OTrio),			new AnimData("pickup",		4, true,	1, false,	new IntPoint()));
		vehicles.set(Std.string(OT.OSons),			new AnimData("bike",		5, false,	1, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OSportCar),		new AnimData("sport",		4, true,	1, true,	new IntPoint(50)));
		vehicles.set(Std.string(OT.OTruck),			new AnimData("truck",		5, true,	2, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OTruckTwo),		new AnimData("truck",		5, true,	2, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OTruckFour),		new AnimData("truck",		5, true,	2, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OTruckSix),		new AnimData("truck",		5, true,	2, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OBus),			new AnimData("bus",			1, true,	2, false,	new IntPoint()));
		vehicles.set(Std.string(OT.OHarley),		new AnimData("harley",		5, false,	1, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OHarleyV),		new AnimData("harley",		5, false,	1, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OBikeLine),		new AnimData("bike",		5, false,	1, true,	new IntPoint()));
		//vehicles.set(Std.string(OT.Bike),			new AnimData("bike",		5, false,	1, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OLightCar),		new AnimData("light",		4, true,	1, true,	new IntPoint(-50, -10)));
		vehicles.set(Std.string(OT.ODelorean),		new AnimData("delorean",	1, false,	1, true,	new IntPoint()));
		vehicles.set(Std.string(OT.OLimo),			new AnimData("limo",		1, false,	1, false,	new IntPoint()));
		vehicles.set(Std.string(OT.OMonster),		new AnimData("struck",		2, false,	0, false,	new IntPoint()));
		
		vehicles.set(Std.string(OT.ORail),			new AnimData("nope",		1, false,	1, false,	new IntPoint()));
		vehicles.set(Std.string(OT.ODrop),			new AnimData("mine",		1, false,	0, false,	new IntPoint()));
		vehicles.set(Std.string(OT.OWarningShot),	new AnimData("nope",		1, false,	0, false,	new IntPoint()));
		vehicles.set(Std.string(OT.OShot),			new AnimData("nope",		1, false,	0, false,	new IntPoint()));
		vehicles.set(Std.string(OT.OExplosion),		new AnimData("nope",		1, false,	0, false,	new IntPoint()));
		vehicles.set(Std.string(OT.OBulletImpact),	new AnimData("nope",		1, false,	0, true,	new IntPoint()));
		
		/*vehicles.set(Std.string(OT.SportCar),		new AnimData("sport",		4, true,	1, true,	new IntPoint(-20, -17)));
		vehicles.set(Std.string(OT.Truck),			new AnimData("truck",		5, true,	2, true,	new IntPoint(-17, -15)));
		vehicles.set(Std.string(OT.PinupTruck),		new AnimData("ptruck",		1, false,	2, false,	new IntPoint(-17, -17),	"truck"));
		vehicles.set(Std.string(OT.Van),			new AnimData("van",			5, true,	1, true,	new IntPoint(-22, -17)));
		vehicles.set(Std.string(OT.SmallTruck),		new AnimData("struck",		2, false,	2, true,	new IntPoint(-20, -16)));
		vehicles.set(Std.string(OT.Pickup),			new AnimData("pickup",		4, true,	1, false,	new IntPoint(-24, -20)));
		vehicles.set(Std.string(OT.FireTruck),		new AnimData("ftruck",		1, false,	2, false,	new IntPoint(-17, -15)));
		vehicles.set(Std.string(OT.Tank),			new AnimData("tank",		2, true,	1, false,	new IntPoint(-40, -30)));
		vehicles.set(Std.string(OT.Bus),			new AnimData("bus",			1, true,	2, false,	new IntPoint(-27, -14)));
		vehicles.set(Std.string(OT.Limo),			new AnimData("limo",		1, false,	1, false,	new IntPoint( -19, -16)));*/
	}
	
	static public function l (level:Int) :Int {
		//if (AKApi.getGameMode() == GM_PROGRESSION)	return 2000 + 3000 * level;
		if (AKApi.getGameMode() == GM_PROGRESSION) {
			return switch (level) {
				default:
					20000 + 900 * level;
			}
		}
		else return 500 + 750 * level;
	}
	
	static public function c (type:ObjectType) :UInt {
		if (colors.exists(Std.string(type)))	return colors.get(Std.string(type));
		else									return 0;
	}
	
	/*static public function getClass (t:OT) :Class<Dynamic> {
		switch (t) {
			case PlayerCar, Ghost, SportCar, Truck, PinupTruck, Van, LightCar, Bike, Harley, SmallTruck, Pickup, FireTruck, Tank, Bus, Delorean, Limo:
				return Vehicle;
			case Nitro, Oil, Pitstop, Skull, Rock, Crack, CrackEdge, Hole, BigHole, Sand, Explosion:
				return FixedObject;
			case Crate, Barrel, Tire:
				return BreakableObject;
			case PKado:
				return Kado;
		}
	}*/
	
	/*static public function isVehicle (t:OT) :Bool {
		switch (t) {
			case PlayerCar, Ghost, SportCar, Truck, PinupTruck, Van, LightCar, Bike, Harley, SmallTruck, Pickup, FireTruck, Tank, Bus, Delorean, Limo:
				return true;
			default:
				return false;
		}
	}*/
	
}

class AnimData {
	
	public var name:String;
	public var versions:Int;
	public var boss:Bool;
	public var sideFrames:Int;
	public var flippable:Bool;
	public var shadowOffset:IntPoint;
	public var shadowName:String;
	
	/**
	 * @param	name			Name in sprite sheet
	 * @param	versions		Number of different versions
	 * @param	boss			Wheter or not the vehicle has a "boss" version
	 * @param	sideFrames		Number of frames of the side animation
	 * @param	flippable		Whether or not the side animation can be flipped (if not, _l an _r suffixes will be used)
	 * @param	shadowOffset	Position of the shadow
	 * @param	shadowName		Name of the shadow (if different from name)
	 */
	
	public function new (name:String, versions:Int = 1, boss:Bool = false, sideFrames:Int = 1, flippable:Bool = true, shadowOffset:IntPoint = null, shadowName:String = null) {
		this.name = name;
		this.versions = versions;
		this.boss = boss;
		this.sideFrames = sideFrames;
		this.flippable = flippable;
		this.shadowOffset = shadowOffset;
		this.shadowName = shadowName;
	}
	
	public function toString () :String {
		return "[AnimData] { name:" + name + ", versions:" + versions + ", boss:" + boss + ", sideFrames:" + sideFrames + ", flippable:" + flippable + ", shadowOffset:" + shadowOffset + ", shadowName:" + shadowName + " }";
	}
	
}

/*enum AnimState {
	Idle;
	Side;
}*/








