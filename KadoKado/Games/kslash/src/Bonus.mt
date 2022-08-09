class Bonus {//}

	var root:MovieClip;
	
	var id:int;
	var time:float;
	
	function new(mc) {
		root = mc;
		Cs.game.bList.push(this)
		time = 300;
	}
	
	function update(){
		time-=Timer.tmod;
		if(time<10){
			root._alpha=time*10
			if(time<0)kill();
		}
		
		
		
	}
	
	function setId(n){
		id=n;
		root.gotoAndStop(string(id))
	}
	
	function take(){
		var pid = null
		switch(id){
			case 1:
				
				addScore(Cs.C200)
				pid = 0
				break;
			case 2:
				addScore(Cs.C1000)
				pid = 0
				break;
			case 3:
				addScore(Cs.C5000)
				pid = 0
			case 4:
				Cs.game.hero.incStar(20)
				pid = 1
				break;
			case 5:
				Cs.game.hero.incStar(50)
				pid = 1
				break;
			case 6:
			case 7:
			case 8:
				Cs.game.optList[id-6] = true
				Cs.game.updateIcons();
				pid = 1
				break;
			case 9:
				for( var i=0; i<18; i++ ){
					Cs.game.newMonster(3)
				}
				addScore(Cs.C8000)
				break;
			case 10:
				Cs.game.hero.initSupa();
				break;				
		}
		//

		switch (pid){
			case 0:
				for(var i=0; i<12; i++ ){
					var p = Cs.game.newPart("partSpark")
					var a = Math.random()*6.28
					var d = Math.random()*(6+18*(1-(i/24)))
					p._x = root._x + Math.cos(a)*d
					p._y = root._y + Math.sin(a)*d
					p.t = 10+Math.random()*10
					p.wt = Math.max(0,Math.pow(i*30,0.5)-8)
					p.scale = 30+Math.random()*100 - p.wt*2
					p._xscale = p.scale
					p._yscale = p.scale
					p.ft = 0
					
					p._visible = false;
				}
				break;
			case 1:
				for(var i=0; i<3; i++ ){
					var p = Cs.game.newPart("partCircle")
					p._x = root._x
					p._y = root._y
					p._rotation = Math.random()*360
					p.t = 18-i*3
					p.vs = 6+i*8
					p.vr = 8+i*12
				}
				break;
			case 2:
				var max = 8
				for( var i=0; i<max; i++ ){
					for( var n=0; n<2; n++ ){
						var p = Cs.game.newPart("partLight")
						p._x = root._x
						p._y = root._y
						var a = ((i+0.5*n)/max)*6.28
						var speed = (3+n*2)
						p.vx += Math.cos(a)*speed
						p.vy += Math.sin(a)*speed
						p.t = 26+Math.random()*4-n*10
						p.frict = 0.9
					}
					
				}				
				break;
		
		}
		
		Cs.game.stats.$opt[id-1]++
		
		kill();
		
	}
	
	function addScore(n){
		KKApi.addScore(n)
		var p = Cs.game.newPart("mcScore")
		p._x = root._x;
		p._y = root._y;
		p.vy = -1
		p.t = 24
		downcast(p).field.text = string(KKApi.val(n))
	}
	
	function kill(){
		Cs.game.bList.remove(this);
		root.removeMovieClip();
	}
	
	
//{
}









