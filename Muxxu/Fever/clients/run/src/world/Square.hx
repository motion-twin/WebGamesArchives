package world;
import mt.bumdum9.Lib;
import Protocole;
import world.Island;

class Square {//}
	

	public var island:Island;

	public var id:Int;
	public var x:Int;
	public var y:Int;
	
	public var nei:Array<Square>;
	public var dnei:Array<Square>;
	public var rnei:Array<Square>;
	
	public var type:Int;
	
	public var score:Int;
	public var a:Int;
	public var tswell:Float;
	public var swell:Float;
	public var swellNoise:Float;
	
	public var floor:Int;
	public var elements:Array<IslandElement>;
	public var but:flash.display.Sprite;
	public var ints:Array<Int>;
	public var playable:Bool;
	public var win:Bool;
	public var ent:Ent;
	public var field:flash.text.TextField;
	public var oceans:Array<pix.Element>;
	public var feverHead:FeverHead;
	
	public function new(x, y, isl) {
		island = isl;
		this.x = x;
		this.y = y;
		
		id = 0;
		floor = 0;

		nei = [];
		dnei = [];
		rnei = [];
		
		ints = [];
		elements = [];
		
		type = 0;
		score = 0;
		a = 0;
		swell = 0;
		tswell = 0;
		swellNoise = Math.random() * 2 - 1;

		playable = false;
		win = false;
	
		island.grid[x][y] = this;
		island.squares.push(this);


	}
	
	// MAJ
	public function majRealNeighbours() {
		rnei = [];
		if( !isWalkable() ) return;
		for( di in 0...4 ) {
			var nsq = dnei[di];
			if( nsq == null || !nsq.isWalkable() ) continue;
			if( type == 1 && nsq.type == 1 && floor != nsq.floor ) continue;
			if( ( type == 3 || nsq.type == 3 ) && di % 2 == 0 ) continue;
			
			rnei.push(nsq);
		}
	}
	public function addElement(type:Int,str:String,fr=0,ec=0) {
		var sp = new pix.Element();
		sp.visible = false;
		sp.x = (x + 0.5) * 16;
		sp.y = (y + 0.5) * 16;
		sp.x += island.seed.random(ec * 2) - ec;
		sp.y += island.seed.random(ec * 2) - ec;
		sp.drawFrame(Gfx.world.get( fr,str ));
		elements.push( { sp:sp, type:type } );
		island.dm.add(sp, Island.DP_ELEMENTS );
	}
		
	// TOOLS
	public function conquest() {
		win = true;
	}
	public function distTo(sq:Square) {
		var dx = x - sq.x;
		var dy = y - sq.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	// IS
	public function isReachable() {
		return score > 0;
	}
	public function isBlock() {
		return ent != null && ent.block;
		
	}
	public function isWalkable() {
		return type == 1 || type == 3;
	}
	public function isWide() {
		
		var free:Null<Bool> = null;
		var swap = 0;
		for( di in 0...9 ) {
			var d = Cs.DDIR[di % 8];
			var nx = x + d[0];
			var ny = y + d[1];
			var sq = island.grid[nx][ny];
			var walk = sq.isWalkable();
			if( free != null && free != walk ) swap++;
			free = walk;
		}
		return swap <= 2;
		
	}
	
	//
	public function getMonsterData() {
		var mon:world.ent.Monster = cast ent;
		return mon.data;
	}
	public function getCenter() {
		return {
			x:(x+0.5)*16,
			y:(y+0.5)*16,
		}
	}
	
	//
	public function pushOcean(oc) {
		if( oceans == null ) oceans = [];
		oceans.push(oc);
	}
	
	// SWELL
	public function setSwell(c,init=false) {
		tswell = c;
		if( init ) {
			swell = c;
			paint();
		}
	}
	public function updateSwell() {
		if( tswell == swell ) return;
		var dif = tswell - swell;
		var lim = 0.005;
		swell += Num.mm( -lim, dif * 0.1, lim);
		if( Math.abs(dif) < 0.02 ) swell = tswell;
		paint();
	}
	public function paint() {
		var c = 1 - swell;
		
		if( c < 1 ) c = Num.mm(0, c + swellNoise * 0.02, 1);
		
		//c = Std.int(c * 16) / 16;
		
		for( oc in oceans ) {
			var dark  = 0xAA6644;
			var color = Col.mergeCol(Main.worldColor, dark, c);
			Col.overlay(oc, color );
		}
	}
	
	
	// TRIGGER
	public function heroIn() {
		if( ent == null ) return;
		ent.heroIn();
	}
	public function trigSide() {
		if( ent == null ) return false;
		return ent.trigSide();
	}
	public function isTrig() {
		if( ent == null ) return false;
		return ent.isTrig();
	}
	

	
	// DEBUG
	public function mark() {
		if( field != null ) field.parent.removeChild(field);
		var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		f.x = x * 16;
		f.y = y * 16;
		island.dm.add(f, 8);
		f.text = Std.string(score);
		field = f;
	}
	public function getMapCoord() {
		return {
			x:island.x + x * 16,
			y:island.y + y * 16,
		}
	}
	
	
	
//{
}








