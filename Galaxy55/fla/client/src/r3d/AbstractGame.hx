package r3d;
import Common;

class PlanetData {
	public var id : Int;
	public var biome : BiomeData;
	public var totalSize : Int;
	public var waterLevel : Int;
	public var animWater : { width : Float, scale : Float, speed : Float };
	public var defaultLight : Float;
	public var lightHeight : Int;
	public var curve : Float;
	
	public function new( p : PlanetInfos ) {
		id = p.id;
		biome = Data.getBiome(p.biome);
		totalSize = p.size << Const.BITS;
		waterLevel = p.waterLevel;
		animWater = { width : 0.5, scale : 0.3, speed : 0.5 };
		defaultLight = biome.sunPower / r3d.Builder.LBASE;
		lightHeight = Const.ZSIZE;
		curve = 2 / totalSize;
	}
}

typedef GameEffectsSelect = 
{ 
	x : Float,
	y : Float,
	z : Float, 
	laser : Null<Int>, 
	bx:Int, by:Int, bz:Int,
	btype:Int,
}

typedef GameEffectsEntity =
{
	var id : Int;
	var x : Float;
	var y : Float;
	var z : Float;
	var angle : Float;
	var name : String;
	var bmp : h3d.mat.PngBytes;
	var camera : Bool;
	var select : GameEffectsSelect;
}

typedef GameEffects = {
	var time : Float;
	var fades : Array<{ a : Float, col : Int }>;
	var fogPower : Float;
	var fogColors : Array<Int>;
	var dummies : List<{ block : Block, light : Float, x : Float, y : Float, z : Float, time : Float }>;
	var inWater : Bool;
	var select : { x : Int, y : Int, z : Int, b : Block, pt : h3d.Point, dir : h3d.Vector };
	var currentBlock : Block;
	var bobbing : { x : Float, y : Float };
	var laser : { canBreak : Bool, c : ChargeKind };
	var shipDock : { x : Int, y : Int, z : Int, h : Int };
	var skyBoxAlpha : Float;
	var entities : Array<GameEffectsEntity>;
}

typedef GameConstants = {
	var laserBitmaps : Array<Class<h3d.mat.PngBytes>>;
	var shipDockBitmap : Class<h3d.mat.PngBytes>;
}

class AbstractGame {

	public var level : Level;
	public var render : Render;
	public var engine : h3d.Engine;
	public var planet : PlanetData;
	public var softHudContext : flash.display.Sprite;
	public var constants : GameConstants;
	
	public function new(level, engine, planet, hud,cst) {
		this.level = level;
		this.engine = engine;
		this.planet = planet;
		this.softHudContext = hud;
		this.constants = cst;
	}
	
	public function real(p) {
		p %= planet.totalSize;
		if( p < 0 ) p += planet.totalSize;
		return p;
	}
	
	public function realDist(d:Float) {
		d %= planet.totalSize;
		if( (d<0?-d:d) > planet.totalSize>>1 ) d += (d<0)?planet.totalSize:-planet.totalSize;
		return d;
	}
	
	public function realFloat(p:Float) {
		p %= planet.totalSize;
		if( p < 0 ) p += planet.totalSize;
		return p;
	}
	
	public dynamic function makeField() {
		return new flash.text.TextField();
	}

	public dynamic function loadChunk(x, y) {
	}
	
	public dynamic function needRedraw() {
	}
	
	public dynamic function getEffects(x:Float,y:Float,z:Float) : GameEffects {
		throw "assert";
		return null;
	}

}