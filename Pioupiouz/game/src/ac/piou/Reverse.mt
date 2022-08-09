class ac.piou.Reverse extends ac.Piou{//}

	var aura:MovieClip;
	var pList:Array<{>Arrow,timer:int}>;
	
	
	function new(x,y){
		super(x,y)
		
	}
	
	function init(){
		super.init();
		flExclu= true;
		piou.root.gotoAndStop("turnIncant");
		timer = 60
		step =0
		aura = Cs.game.dm.attach( "mcReverseAura", Game.DP_PART_2 )
		pList = new Array();
	}
	
	function update(){
		super.update();
		
		switch( step){
			case 0:
				piou.y--;
				if(timer<0){
					Cs.game.flasher = 100
					Level.reverse();
					release();

					
				}else{
					// FN
					for( var i=0; i<2; i++ ){
						if( Math.random()*timer<10 ){
							var p = new Part( Cs.game.dm.attach( "mcConcentration", Game.DP_PART_2 ) )
							p.x = piou.x;
							p.y = piou.y-Piou.RAY;
							p.vy = -1
							p.frict = 1
							p.updatePos();
							p.root._rotation = Math.random()*360
							

							if( Std.random(3) == 0 ){
								var ar = downcast(new Arrow(downcast(Cs.game.dm.attach( "partLightFlip", Game.DP_PART_2 ))))
								var a = Math.random()*6.28
								var ray = 20+Math.random()*30
								ar.x = piou.x+Math.cos(a)*ray
								ar.y = piou.y+Math.sin(a)*ray
								ar.angle = Math.random()*6.28
								ar.vy = -1
								ar.root._xscale = 50+Math.random()*50
								ar.root._yscale = ar.root._xscale
								pList.push(ar)
							}	
						}
						
					}
					aura._xscale += 5
					aura._yscale = aura._xscale
					
				}
				
				if(!Level.isFree(piou.x,piou.y-Piou.RAY*2)){
					release();
				}
				
				// PART 
				for( var i=0; i<pList.length; i++ ){
					var ar = pList[i]
					ar.towardAngle(ar.getAng(piou),0.2,1)
					ar.towardVit(0.15,5)
					ar.y--;
				}
				
				
				break;
			case 1:
				aura._xscale += 80
				aura._yscale = aura._xscale
				aura._alpha *=0.3

				/*
				for( var i=0; i<pList.length; i++ ){
					var ar = pList[i]
					ar.towardAngle(piou.getAng(ar),0.4,1.5)
					ar.towardVit(0.3,10)
					ar.root._xscale *= 0.8
					ar.root._yscale = ar.root._xscale
					if(ar.root._xscale<6){
						pList.splice(i--,1)
						ar.kill();
					}
				}
				*/
				for( var i=0; i<pList.length; i++ ){
					var p = pList[i]
					p.timer--
					if(p.timer<10){
						p.root._xscale *= 0.7
						p.root._yscale = p.root._xscale
						if(p.root._yscale<=5){
							pList.splice(i--,1)
							p.kill();
						}
					}
				}				
				if( aura._alpha < 5 )aura.removeMovieClip();
				if( aura._visible != true && pList.length==0){
					aura.removeMovieClip();
					kill();
				}
				
				break;
		}
		aura._x = piou.x
		aura._y = piou.y-Piou.RAY
	}
	
	function release(){
		while(Cs.game.partList.length>0)Cs.game.partList.pop().kill();
		piou.fall();
		piou.vy = -1.5
		step = 1
		for( var i=0; i<pList.length; i++ ){
			var p = pList[i]
			var a = piou.getAng(p);
			var speed = piou.getDist(p)*0.1
			p.vx = Math.cos(a)*speed;
			p.vy = Math.sin(a)*speed;
			p.timer = 10+Std.random(10)
		}		
							
	}
	
//{
}

//18h15 au 55 quai richelieu