class Medusa extends Bads{//}

	
	var speed:float;
	var speedDecal:float;
	
	function new(mc){
		level = 10
		super(mc)
		ray = 10
		hp = 60
		root.stop();
		frict = 0.98
		score = Cs.SCORE_MEDUSA
		gid = 8
		speedDecal = 0
		speed = 1.5
		x = Cs.mcw+ray+5
		y = ray + Math.random()*(Cs.GL+ray*2)		
	}
	
	function update(){
		super.update();
		speed *= 1.002
		speedDecal = (speedDecal+(speed*13.5)*Timer.tmod)%628
		
		var h = Cs.game.hero
		var sp = speed+Math.cos(speedDecal/100)*6
		
		var a = getAng(h)
		
		var dx = Math.cos(a)*sp - vx
		var dy = Math.sin(a)*sp - vy
		
		var c = 0.3
		var lim = 1/0
		vx += Cs.mm(-lim,dx*c,lim)*Timer.tmod;
		vy += Cs.mm(-lim,dy*c,lim)*Timer.tmod;
		
		checkGround();
		bounceFamily();
	}
	
}