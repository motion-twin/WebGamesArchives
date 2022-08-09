class Spark extends Phys{//}

	var distLimit:float;
	var coefLimit:float
	var coef:float;
	var score:KKConst
	
	function new(mc){
		Cs.game.sparkList.push(this)
		super(mc);
		frict  = 0.9
		coef = 0.01
		
		distLimit = 5
		coefLimit = 0.1
	}
	
	function update(){
		super.update();

		distLimit += 0.05*Timer.tmod;
		coefLimit += 0.001*Timer.tmod
		
		
		coef = Math.min(coef+0.005*Timer.tmod,coefLimit);
		speedToward(Cs.game.blob,coef,distLimit)
		
		
		if(getDist(Cs.game.blob)<Blob.RAY+8){
			blast();
			KKApi.addScore(score)
			kill();
		}
		
		if( Math.random()/Timer.tmod < 0.4 ){
			var p = newStar();
			p.vx = vx*(0.5+(Math.random()*2-1)*0.1)
			p.vy = vy*(0.5+(Math.random()*2-1)*0.1)
		}
		
		
	}
	
	function newStar(){
		var p = new Part( Cs.game.dm.attach("partStar",Game.DP_STAR) )
		p.x = x;
		p.y = y;
		p.fadeType = 0
		p.timer = 10+Math.random()*10
		p.weight = 0.1+Math.random()*0.1
		return p;
	}
	
	function blast(){
		var mc = Cs.game.dm.attach("mcStartExplo",Game.DP_STAR)
		var sc = 60
		mc._x = x;
		mc._y = y;
		mc._xscale = sc;
		mc._yscale = sc;
		/*
		var max = 12
		var r = 8
		for( var i=0; i<max; i++ ){
			var p = newStar();
			var a = Math.random()*6.28//i/max * 6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var sp = 1+(i%2)*2
			p.x += ca*r;
			p.y += sa*r;
			p.vx = ca*sp
			p.vy = sa*sp
			p.timer = 20-sp*2
		}
		*/
		
		
	}
		
	function kill(){
		Cs.game.sparkList.remove(this)
		super.kill();
	}
	
//{
}