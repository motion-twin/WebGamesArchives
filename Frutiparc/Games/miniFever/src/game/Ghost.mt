class game.Ghost extends Game{//}
	
	// CONSTANTES

	// VARIABLES
	var decal:float;
	var blob:float;
	
	// MOVIECLIPS
	var ghost:sp.Phys;
	var bubble:sp.Phys;
	var s1:MovieClip;
	var s2:MovieClip;
	var mesh:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 340;
		super.init();
		blob = 0;
		decal = 0;
		attachElements();

		
	};
	
	function attachElements(){
		// GHOST
		ghost = newPhys("mcGhost")
		ghost.x = Cs.mcw-10
		ghost.y = Cs.mch*0.5
		ghost.flPhys = false;
		ghost.skin.stop();
		ghost.init();
		
		// BUBBLE
		bubble = newPhys("mcGhostBubble")
		bubble.x = Cs.mcw-24
		bubble.y = Cs.mch*0.5
		bubble.weight = 0.004
		bubble.init();	
			
		// STALACTITES
		var frame = string( 1+Math.floor(dif*0.1) )
		s1.gotoAndStop(frame)
		s2.gotoAndStop(frame)
	
	}
	

	function update(){
		
		switch(step){
			case 1: // GAME
				moveGhost();
				moveBubble();

			
			
				break;
		}
		//
		super.update();
	}
	
	
	function moveGhost(){
		var m = {x:_xmouse,y:_ymouse}
		
		// MOVE
		var dx = ghost.x - m.x
		var dy = ghost.y - m.y
		ghost.x -= dx*0.1*Timer.tmod
		ghost.y -= dy*0.1*Timer.tmod		
		
		// LOOK
		var dist = ghost.getDist(bubble)
		var focus = null
		if( dist < 80 ){
			focus = upcast(bubble)
		}else{
			focus = m
		}
		var sens = null
		if(focus.x < ghost.x){
			sens = -1
		}else{
			sens = 1
		}
		
		dx = ghost.x - focus.x
		dy = ghost.y - focus.y		
		
		ghost.skin._xscale = 100*sens
		ghost.skin._rotation =Math.atan2(dy,dx)/0.0174 + ((sens*0.5)+0.5)*180
		

		// BLOW
		if( base.flPress ){
			ghost.skin.gotoAndStop("2")
			if( dist < 80 ){
				var c = 1-(dist/80)
				var a = ghost.getAng(bubble)
				bubble.vitx += Math.cos(a)*c*0.1*Timer.tmod
				bubble.vity += Math.sin(a)*c*0.1*Timer.tmod
				blob += Timer.tmod*0.02*c;
			}
		}else{
			ghost.skin.gotoAndStop("1")
		}

		
		// ALPHA
		var alpha = 100
		if( isIn( ghost.x, ghost.y) )	alpha = 0;
		var da = alpha - ghost.skin._alpha
		ghost.skin._alpha = Math.min(Math.max(20,ghost.skin._alpha+da*0.15*Timer.tmod),100)		
		
	}
	
	function moveBubble(){
		
		// BLOB
		decal = (decal+Timer.tmod*(16+blob*0))%628
		blob *= Math.pow(0.95,Timer.tmod)
		var c = 1+Math.cos(decal/100)*blob
		bubble.skin._xscale = 100*c
		bubble.skin._yscale = 100/c
		
		if( bubble.x < 0 )setWin(true);
		
		// HIT
		if( isIn( bubble.x, bubble.y) ){	// HIT TEST A ADAPTER ( --> FRUTIPARC )
			bubble.skin.play();
			bubble.vitx = 0;
			bubble.vity = 0;
			setWin(false)
		}
	}
	
	function isIn(x,y){
		return !mesh.hitTest(x,y,true) || s1.hitTest(x,y,true) || s2.hitTest(x,y,true)
	}
	
	

//{	
}


















