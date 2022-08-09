



class Part extends Phys {//}

	public var weight:Float;
	public var flGrow:Bool;
	public var timer:Int;
	public var fadeLimit:Int;
	public var scale:Float;


	public function new(mc){
		super(mc);
		fadeLimit = 10;
		scale = 100;
		Game.me.parts.push(this);
	}

	public function update(){

		if(weight!=null)vy+=weight;

		if(timer!=null){
			timer--;
			if(timer<fadeLimit){
				var c = timer/fadeLimit;
				root._alpha = c*100;
				if(timer<=0)kill();
			}
		}

		if(flGrow){
			root._yscale += 5;
		}

		super.update();
	}

	public function setScale(n){
		scale = n;
		root._xscale = n;
		root._yscale = n;
	}

	public function kill(){
		Game.me.parts.remove(this);
		super.kill();
	}


//{
}




