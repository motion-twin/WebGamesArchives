class Behaviour{//}

	var b:Bad;

	public function new(){

	}

	public function init(b){
		this.b = b;
		b.behaviours.push(this);
	}

	public function update(){

	}

	public function kill(){
		b.behaviours.remove(this);
	}


//{
}