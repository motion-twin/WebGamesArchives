class game.Dart extends Game{//}

	// CONSTANTES
	var ray:Array<int>

	// VARIABLES
	var bp:{x:float,y:float,vitx:float,vity:float}
	var timer:float;
	
	// MOVIECLIPS
	var rt:Sprite
	var hand:Sprite
	var trg:Sprite
	
	
	
	function new(){
		super();
	}

	function init(){
		
		gameTime = 300;
		super.init();
		
		ray = [30,20,10]
		
		
		var a = Math.random()*6.28
		var sp = 5+dif*0.16
		
		bp = {
			x:Math.random()*Cs.mcw
			y:Math.random()*Cs.mch
			vitx:Math.cos(a)*sp
			vity:Math.sin(a)*sp
		}
		
		
		attachElements();
	};
	
	function attachElements(){
		
		// TARGET
		rt = downcast(newSprite("mcRoundTarget"))
		rt.x = Cs.mcw*0.5
		rt.y = Cs.mch*0.5
		downcast(rt.skin).center.gotoAndStop( string( Math.round(dif*0.02)+1 ) )
		rt.init()
		
		// TARGET
		trg  = newSprite("mcWhiteTarget")
		trg.x = Cs.mcw*0.5
		trg.y = Cs.mch*0.5
		trg.init()
		
		// HAND
		attachHand();
		
	}

	function attachHand(){
		hand = downcast(newSprite("mcDartHand"))
		hand.x = Cs.mcw*0.5
		hand.y = Cs.mch
		hand.init();			
		
		
	}
	
	
	function update(){
		super.update();
		switch(step){
			case 1:
				var m = {x:_xmouse,y:_ymouse}
				//trg.toward(m,0.1,null)
				
				// BALL
				bp.x += bp.vitx*Timer.tmod
				bp.y += bp.vity*Timer.tmod
				
				if( bp.x<0 || bp.x>Cs.mcw ){
					bp.vitx*=-1
					bp.x = Math.min(Math.max(0,bp.x),Cs.mcw)
				}
				if( bp.y<0 || bp.y>Cs.mch ){
					bp.vity*=-1
					bp.y = Math.min(Math.max(0,bp.y),Cs.mch)
				}				
				
				// TRG
				trg.x = (m.x+bp.x)*0.5
				trg.y = (m.y+bp.y)*0.5
				
				
				hand.toward(trg,0.1,null)
				
				
				break;
			case 2:
				hand.y += 33*Timer.tmod
				hand.skin._xscale *= 0.85
				hand.skin._yscale = hand.skin._xscale
				hand.skin._rotation -= 10*Timer.tmod
				if(hand.y>Cs.mch+300)hand.kill();
				
				if(timer!=null){
					timer-=Timer.tmod
					if(timer<0){
						step = 1
						trg.skin._visible = true;
						attachHand();
					}
				}
				
				break;
			
		}
		//
	
	}
	
	
	
	function click(){
		super.click()
		if(step==1){
			step = 2
			trg.skin._visible = false;
			downcast(hand.skin).dart._visible = false;
			var mc = dm.attach("mcDart",Game.DP_SPRITE)
			mc._x = trg.x
			mc._y = trg.y
			
			if( trg.getDist(rt) < ray[Math.round(dif*0.02)] ){
				setWin( true )
				
			}else{
				timer = 32
			}
			
			
			
			
			
		}
		
	}
	

	
//{	
}

