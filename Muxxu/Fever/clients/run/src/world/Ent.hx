package world;
import world.Island;
import Protocole;




class Ent extends flash.display.Sprite {//}
	
	var depth:Null<Int>;

	public var type:EntType;
	public var block:Bool;
	var island:world.Island;
	public var sq:Square;

	public function new(island, sq) {

		super();
		this.island = island;
		this.sq = sq;
		
		block = false;
		sq.ent = this;
		if( depth == null ) depth = world.Island.DP_ELEMENTS;
		
		island.dm.add(this, depth);
		x = (sq.x + 0.5) * 16;
		y = (sq.y + 0.5) * 16;
		
	}
	
	public function heroIn() {
		
	}
	
	public function trigSide() {
		return false;
	}
	public function isTrig() {
		return false;
	}
	
	public function destroy(?anim) {
		kill();
	}
	public function kill() {
		parent.removeChild(this);
		sq.ent = null;
	}
	
	public function getProtectValue() {
		return 0;
	}
	
	public function onComplete() {
		
	}
	
//{
}








