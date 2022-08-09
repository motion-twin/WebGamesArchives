import Common;



class Mode {//}

	static var CURRENT:Mode;
	public var cosmo:pix.Cosmo;
	public var flDeath:Bool;

	public function new(?cosmo) {
		CURRENT.kill();
		CURRENT = this;
		Game.me.mods.push(this);
		this.cosmo = cosmo;
		init();
	}

	function init(){

	}
	function remove(){

	}

	// UPDATE
	public function update(){

	}

	// TOOLS
	public function getMousePos(){
		return {x:cosmo.root._xmouse-cosmo.head.x,y:cosmo.root._ymouse-cosmo.head.y};
	}



	public function kill(){
		cosmo.flAutoTurnHead = true;
		remove();
		flDeath = true;
		Game.me.mods.remove(this);

	}



//{
}











