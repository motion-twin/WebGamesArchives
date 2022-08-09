class Phys extends Sprite{//}

	var ray:float;
	
	var weight:float;
	var frict:float;
	var vx:float;
	var vy:float;
	
	function new(mc){
		super(mc)
		frict = 0.95
		vx = 0;
		vy = 0;
	}
	
	function update(){
		super.update();
		
		if( weight!=null ){
			vy += weight*Timer.tmod;
		}
		
		if( frict!=null ){
			var f = Math.pow(frict,Timer.tmod)
			vx *= f;
			vy *= f;
		}
		
		x += vx*Timer.tmod;
		y += vy*Timer.tmod;
	}
	
	function speedToward(o,c,lim){
		var a = getAng(o)
		var dx = o.x - x;
		var dy = o.y - y;
		vx += Cs.mm(-lim,dx*c,lim)
		vy += Cs.mm(-lim,dy*c,lim)
	}
	
	function genGroundSmoke(){
		var p = new Part(Cs.game.mdm.attach("partSmoke",Game.DP_PARTS))
		p.x = x+(Math.random()*2-1)*8;
		p.y = y+ray;
		p.vx = -Cs.SCROLL_SPEED*3 + (Math.random()*2-1)*4
		p.timer = 10+Math.random()*10
		p.root._rotation = Math.random()*360	
	}
	
//{
}