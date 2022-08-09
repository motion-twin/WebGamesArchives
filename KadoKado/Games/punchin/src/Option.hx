import Common;


class Option{

	public function new(){
		Game.me.options.push(this);
		Game.me.currentOption = this;
	}

	public function update(){

	}

	public function kill(){

	}
	
}