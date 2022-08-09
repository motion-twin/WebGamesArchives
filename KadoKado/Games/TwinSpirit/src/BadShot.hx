import Protocol;
import mt.bumdum.Lib;


class BadShot extends Phys {//}

	public var owner:Int;
	public var bsid:Int;

	var flDeath:Bool;
	var px:Int;
	var py:Int;


	public function new(mc,owner,bsid){
		this.owner = owner;
		this.bsid = bsid;
		super(mc);
		Game.me.shots.push(this);
		ray = 4;
		if( owner == Game.me.robertId && bsid == Game.me.shotId ){
			setLabel(0xFF0000);
		}
	}
	public function update(){

		super.update();
		updateGridPos();

		if( x<-ray || x>Cs.mcw+ray ||  y<-ray || y>Cs.mch+ray ){
			kill();
		}


	}
	public function setType(type){
		root.gotoAndStop(Type.enumIndex(type)+1);
		switch(type){
			case STVolt:
				root._rotation = Math.random()*360;
				vr = (Math.random()*2-1)*15;
			default:
		}
	}

	public function kill(){
		flDeath = true;
		removeFromGrid();
		Game.me.shots.remove(this);
		super.kill();
	}

	// GRID
	function updateGridPos(){
		if(flDeath)return;
		var npx = Cs.getPX(x);
		var npy = Cs.getPY(y);
		if( npx!=px || npy!=py ){
			removeFromGrid();
			px = npx;
			py = npy;
			insertInGrid();
		}
	}
	function insertInGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				Game.me.sgrid[gx][gy].push(this);
			}
		}
	}
	function removeFromGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				Game.me.sgrid[gx][gy].remove(this);
			}
		}
	}

//{
}






















