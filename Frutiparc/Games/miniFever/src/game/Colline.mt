class game.Colline extends Game{//}
	
	// CONSTANTES
	static var MARGIN = 6
	static var SMARGIN = 2
	static var GL = 216 //226
	static var BRAY = 11
	
	// VARIABLES
	var flFall:bool;
	var max:int;
	var ec:float;
	var dList:Array<sp.phys.Part>
	
	// MOVIECLIPS
	var colline:MovieClip;
	var ball:sp.Phys;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 220
		super.init();
		flFall = false;
		attachElements();
	};
	
	function attachElements(){
		
		// DALLES
		dList = new Array();
		max = int(16-dif*0.09);
		ec = ( Cs.mcw - ( 2*MARGIN + SMARGIN*(max-1) ) )/max
		for( var i=0; i<max; i++ ){
			var p = newPart("mcCollineDalle")
			p.x = MARGIN + (ec+SMARGIN)*i
			p.y = GL
			p.flPhys = false;
			p.init()
			downcast(p.skin).d._xscale = ec
			dList.push(p)
		}
		
		// BALL
		ball = newPhys("mcCollineBall")
		ball.x = Cs.mcw*0.5
		ball.y = 30//Cs.mch*0.5
		ball.init();
		
	}
	
	function update(){
		super.update();
		moveBall();
		switch(step){
			case 1: // CENTER
				
				break;
		}
	}
	
	function moveBall(){
		
		var dx = Cs.mm(0,_xmouse,Cs.mcw) - ball.x
		
		// REBOND
		if( !flFall && ball.y > GL-BRAY ){
			var index = int( (ball.x-MARGIN) / (ec+SMARGIN) )
			var p = dList[index]
			
			// CHERCHE LES BORDS
			if(p==null){
				for( var i=0; i<2; i++ ){
					var sens = i*2-1
					index = int( (ball.x+(BRAY*sens)-MARGIN) / (ec+SMARGIN) )
					var cp = dList[index]
					if( cp != null ){
						p = cp;
						break;
					}
				}
			}
			
			
			
			if( p != null ){
				p.flPhys = true;
				p.timer = 10
				dList[index] = null;
				
				// REBOND
				ball.y = GL-BRAY
				ball.vitx += dx*0.04*Timer.tmod;
				ball.vity = -20
			}else{
				flFall = true;
				flFreezeResult = true;
			}			
		}
		
		// DEATH
		if( ball.y > Cs.mch+20 ){
			flFreezeResult = false;
			setWin(false);
		}
		
		// FOLLOW
		var lim = 0.15
		ball.vitx += Cs.mm(-lim,dx*0.05,lim)*Timer.tmod;
		
		// MUR
		if( ball.x < MARGIN+BRAY || ball.x > Cs.mcw-(MARGIN+BRAY) ){
			ball.x = Cs.mm( MARGIN+BRAY, ball.x, Cs.mcw-(MARGIN+BRAY) )
			ball.vitx *= -1;
		}
		
		// ROLL
		ball.skin._rotation += ball.vitx*4
		
		// UPDATE
		ball.skin._x = ball.x;
		ball.skin._y = ball.y;
	}
	
	function outOfTime(){
		setWin(true)
	}

	

	
//{	
}

