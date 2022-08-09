class Generator extends Sprite{//}

	static var TEMPO = 20


	volatile var timer:float


	function new(mc){
		super(mc)
		timer = 0
	}

	function update(){
		super.update();
		timer-=Timer.tmod
		if(timer<0){
			timer = TEMPO
			var p = new Piou(null)
			var x = x
			var y = y
			p.bouncer.setPos(int(x),int(y))
			//p.vx  = (Math.random()*2-1)*sp
			//p.vy  = (Math.random()*2-1)*sp
		}
	}




//{
}