class Bads extends Phys{//}

	var flDeath:bool;
	var hp:float;
	var score:KKConst;
	var mid:int;
	
	var dif:float;
	var spawnDist:float;
	
	function new(mc){
		Cs.game.badsList.push(this)
		super(mc)
		score = Cs.C5
		dif = 1;
		mid = 0
	}
	
	function initStartPosition(){
		var ntry = 0;
		/*
		while(true){
			var flBreak = true;
			x = Math.random()*Cs.mcw
			y = Math.random()*Cs.mch
			
			if( getDist(Cs.game.hero) < Cs.START_SAFE_DIST+ray+Cs.game.hero.ray ){
				flBreak = false;
			}
			
			if(try<30){
				for( var i=0; i<Cs.game.badsList.length; i++ ){
					var b = Cs.game.badsList[i]
					if(b!=this && getDist(b)<ray+b.ray ){
						flBreak = false;
					}
				}
			}
			
			if(try++>50){
				kill();
				break;
			}
			
			if(flBreak)break;
		}
		*/
		var rnd = Std.random(4)
		var rx = Math.random()*(Cs.mcw+2*ray)
		var ry = Math.random()*(Cs.mch+2*ray)
		
		switch(rnd){
			case 0:
				x = rx
				y = -ray
				break;
			case 1:
				x = rx
				y = Cs.mch+ray			
				break;
			case 2:
				x = -ray
				y = ry		
				break;
			case 3:
				x = Cs.mcw+ray
				y = ry			
				break;
		}
		
		
	}
	
	function update(){

		
		super.update();
		checkCols();
		updateFlash();

		
	}
	
	function checkCols(){
	
		if( getDist(Cs.game.hero)<ray+Cs.game.hero.ray ){
			heroCollide();
		}
		
	}
	
	function heroCollide(){
		var h = Cs.game.hero
		if( !h.flInvincible ){
			h.explode();
		}else{
			if(h.flBounce){
				var a = getAng(h)
				var sp = Math.sqrt(h.vx*h.vx+h.vy*h.vy)+Math.sqrt(vx*vx+vy*vy)+ray*0.1
				h.vx = Math.cos(a)*sp;
				h.vy = Math.sin(a)*sp;
			}
		}
		score = Cs.C0;
		damage(10);
	}

	function hit(shot:Shot){
		damage(shot.damage)
		
	}
	
	function damage(n){
		flash = 100
		hp-=n
		if(hp<=0){
			if(!flDeath)explode();
		}
	}
	
	function explode(){
		
		
		
		/*
		// ONDE
		{
			var p = Cs.game.dm.attach("partOnde",Game.DP_UNDERPARTS)
			p._x = x;
			p._y = y;
			var sc = ray*2 + 30
			p._xscale = sc;
			p._yscale = sc;
		}
		
		// PAILLETES
		{
			var p = new Part(Cs.game.dm.attach("partExplosion",Game.DP_UNDERPARTS))//Cs.game.newPart("partExplosion")
			p.x = x;
			p.y = y;
			p.updatePos();
			p.root._rotation = Math.random()*360
			var sc = 20+ray*6
			p.root._xscale = sc;
			p.root._yscale = sc;
		}
		// DEBRIS

		*/
		
		// SCORE
		KKApi.addScore(score)
		//
		Cs.game.stats.$k[mid]++
		kill();
	}


	function kill(){
		flDeath = true;
		Cs.game.badsList.remove(this)
		super.kill()
	}

//{
}