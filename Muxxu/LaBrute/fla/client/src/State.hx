class State{//}


	var flMain:Bool;
	var step:Int;
	var coef:Float;
	var cs:Float;

	public function new() {
		Game.me.states.push( cast this);
		coef = 0;
		cs = 0;

	}

	public function setMain(){
		flMain = true;
		Game.me.current = this;
	}


	public function update() {
		coef = Math.min(coef+cs*mt.Timer.tmod,1);

	}

	public function end(){
		flMain = false;
		if( Game.me.current == this )Game.me.endCurrentState();
	}

	public function kill(){
		Game.me.states.remove( cast this);
	}


//{
}