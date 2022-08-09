class game.Titanic extends Game{//}
	
	// CONSTANTES
	static var SEUIL = [20,30,40,50]
	
	// VARIABLES
	var score:float;
	var timer:float;
	var bp:float;
	var index:int;
	var wList:Array<{>MovieClip,dec:float}>
	var bList:Array<{>MovieClip,b:MovieClip,s:MovieClip}>
	var uList:Array<{>sp.phys.Part,dec:float,ds:float,amp:float}>
	
	// MOVIECLIPS
	var boat:{>MovieClip,pompe:{>MovieClip,tir:MovieClip}};
	var epave:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 400-dif*2;
		super.init();
		score = 0;
		index = 0;
		bp = 0;
		uList =new Array();
		attachElements();
	};
	
	function attachElements(){
		
		wList = new Array();
		for(var i=0; i<4; i++ ){
			var mc = Std.getVar(this,"$s"+i)
			mc.dec = 60*i
			wList.push(mc)
		}
		
		bList = new Array();
		for(var i=0; i<6; i++ ){
			var mc = Std.getVar(epave,"$b"+i)
			setScale(mc,10)
			bList.push(mc)
		}
		
		// DUNE
		dm.attach("mcTitanicDune",Game.DP_FRONT)
		
	}

	function update(){
		super.update();
		switch(step){
			case 1:
				var h = 0
				// WAVE
				for(var i=0; i<wList.length; i++ ){
					var mc = wList[i]
					mc.dec = (mc.dec+10*Timer.tmod)%628
					mc._rotation = Math.cos(mc.dec/100)*1.5
					if(i==0){
						var a = mc._rotation*0.0174
						var sa = Math.sin(a)
						boat._y = mc._y + sa*70
						boat._rotation = -sa*50
					}
				}
				
				// POMPE
				var c = Cs.mm(0,_ymouse/Cs.mch,1)
				var y = -32*(1-c)
				var dy = y - boat.pompe.tir._y
				boat.pompe.tir._y += dy*0.75
				
				if(dy>0){
					var inc = Math.pow(dy,2)*0.013
					for(var i=0; i<bList.length; i++ ){
						var mc = bList[i]
						setScale(mc,mc.b._xscale+inc)
					}
					score += inc*0.4;
		
				}
				
				// SCORE
				if( score > SEUIL[index] ){
					index++
					play();
					if(index==4){
						step = 2
						flTimeProof = true
						timer = 30
					}
					bp = (index+1)*8

				}
				
				//
				bp *= 0.8
				
				
				break;
			case 2:
				//
				bp = Math.max(5,bp*0.9)
				timer -= Timer.tmod;
				if(timer<0)setWin(true);
				break;
		}
		
		// BUBBLE
		
		for(var i=0; i<(1+bp); i++){
			if(Std.random(int(10/Timer.tmod))==0){
				var p = downcast(newPart("partTitanicBubble"))
				p.x = epave._x + 20 +(Math.random()*2-1)*80
				p.y = epave._y + Math.random()*40
				p.weight = -(0.1+Math.random()*0.1)
				p.timer = 15+Math.random()*40
				p.scale = 20+Math.random()*50
				p.timerFadeLimit = 15
				p.timerFadeType = 1
				p.dec = Math.random()*628;
				p.amp = 0.1 + Math.random()*0.1
				p.ds = 15+Math.random()*30
				p.init()
				uList.push(p)
			}
		}
		
		for( var i=0; i<uList.length; i++ ){
			var p = uList[i]
			p.dec = (p.dec+p.ds)%628
			p.vitx += Math.cos(p.dec/100)*p.amp
			if(p.y<60)p.kill();
		}
		
	}
	
	
	function setScale(mc,size){
			mc.b._xscale = size
			mc.b._yscale = size
			mc.s._xscale = size+2	
			mc.s._yscale = size+2	
	}

//{	
}





