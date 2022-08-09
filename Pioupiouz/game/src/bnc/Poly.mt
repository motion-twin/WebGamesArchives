class bnc.Poly extends Phys{//}


	function new(mc){
		super(mc)
		frict = 0.98
		bouncer = new Bouncer(this)
		bouncer.frict = 0.5
		bouncer.onBounce = callback(this,onBounce)
		weight = 0.1
	}
	
	function onBounce(){
		var speed = Math.sqrt(vx*vx+vy*vy)
		if( speed < 0.5 ){
			Level.drawMC(root)
			kill();
		}
	}
	
//{
}