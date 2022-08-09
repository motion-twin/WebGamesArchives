import Common;


class Option{//}

	public function new(){
		Game.me.options.push(this);
		Game.me.currentOption = this;
	}

	public function update(){

	}

	function destroyPiece(){
		Game.me.piece.explode();
	}

	// ON
	public function onLine(){

	}

	// FX
	function whiteFlash(?flForeground){
		var d = Game.DP_BG;
		if(flForeground)d = Game.DP_INTER;
		var mc = Game.me.dm.attach("mcFlash",d);
	}

	//
	public function kill(){
		
		Game.me.options.remove(this);
		if(Game.me.currentOption==this)Game.me.currentOption = null;
	}


//{
}