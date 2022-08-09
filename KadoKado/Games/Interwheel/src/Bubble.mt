class Bubble extends Part{//}

	var dec:float;
	var dsp:float;
	var ec:float;
	var outTimer:float;
	
	function new(mc){
		mc = Cs.game.dm.attach("mcBubble",Game.DP_WPART)
		super(mc);
		frict  = 0.98
		dec = Math.random()*628
		dsp = 10+Math.random()*20
		ec = 0.5+Math.random()*4
		weight = -(0.15+Math.random()*0.5 )
		setScale(30+Math.random()*50)
		root.stop();
		
		Std.cast(root).blendMode = "$screen".substring(1)
	
	}
	
	function update(){
		
		if(outTimer!=null){
			outTimer-=Timer.tmod;
			y = Cs.game.water._y
			setScale(scale+Timer.tmod)
			if(outTimer<0){
				kill();
			}

		}else{
			dec=(dec+dsp*Timer.tmod)%628
			vx = Math.cos(dec/100)*ec
			if(y<Cs.game.water._y){
				y = Cs.game.map._y
				vx = 0;
				vy = 0;
				root.nextFrame();
				outTimer = 10+Math.random()*20
			}
		}
		
		super.update();
	}
	

//{
}