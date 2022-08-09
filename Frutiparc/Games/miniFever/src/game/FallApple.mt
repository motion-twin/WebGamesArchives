class game.FallApple extends Game{//}
	
	// CONSTANTES
	static var GOAL = 8
	static var ARAY = 10
	static var PRAY = 25
	static var ECART = 18
	
	// VARIABLES
	var aList:Array<{>sp.Phys,step:int}>;
	var ph:float;
	var timer:float;
	
	// MOVIECLIPS
	var panier:sp.Phys;

	function new(){
		super();
	}

	function init(){
		gameTime = 320
		super.init();
		airFriction = 0.95
		aList = new Array();
		ph = Cs.mch - 46
		timer = 10
		attachElements();
	};
	
	function attachElements(){
		
		// PANIER
		panier = newPhys("mcPanier")
		panier.x = Cs.mcw*0.5
		panier.y = ph
		panier.vitr = 0
		panier.flPhys = false;
		panier.skin.stop()
		panier.init()
		
	}
	
	function update(){
		switch(step){
			case 1:
				// PANIER
				var p = {
					x:_xmouse
					y:ph
				}
				panier.towardSpeed(p,0.01,0.7)
				panier.vitx *= Math.pow(0.96,Timer.tmod);
				
				var dr = -panier.skin._rotation
				panier.vitr += dr*0.1*Timer.tmod;
				panier.vitr *= Math.pow(0.97,Timer.tmod)
				
				// APPLE
				timer-=Timer.tmod;
				if(timer<0){
					timer = ECART
					addApple();
				}		

				for( var i=0; i<aList.length; i++ ){
					var sp = aList[i]
					var adx = Math.abs( panier.x - sp.x )
					
					switch(sp.step){
						case 0:
							if( sp.y > panier.y-ARAY ){
								sp.step = 1
								if(  adx < PRAY-ARAY ){
									panier.vity += sp.vity*0.5
									sp.kill();
									panier.skin.nextFrame();
									if( panier.skin._currentframe == 8 )setWin(true);
								}else{
									
									for( var n=0; n<2; n++ ){
										var sens = n*2-1
										var pos = {
											x:panier.x+sens*PRAY
											y:panier.y
										}
										var dist = sp.getDist(pos)
										if( dist < ARAY ){
											sp.step = 0
											var a = sp.getAng(pos)
											var d = ARAY - dist
											var ca = Math.cos(a)
											var sa = Math.sin(a)
											sp.x -= ca*d
											sp.y -= sa*d;
											var speed = Math.sqrt(sp.vitx*sp.vitx+sp.vity*sp.vity)*0.8
											sp.vitx = -ca*speed
											sp.vity = -sa*speed
											panier.vitr += speed*0.5*sens
											panier.vity += speed*0.3
											sp.vitr += speed*2*sens
											
										}
										
									}
									
								}
							}					
							break;
						case 1:
							
							break;
					}
					
					
					
					
				}
				
				break;
		}
		super.update();
	}
	
	function addApple(){
		
		var sp = downcast(newPhys("mcFallApple"))
		var r = ARAY+80*(1-(dif*0.01))
		sp.x = r + Math.random()*(Cs.mcw-2*r)
		sp.y = -ARAY
		sp.weight = 0.1 + Math.random()*0.2
		sp.friction = 1
		sp.vitr = 0;
		sp.step = 0;
		sp.init();
		aList.push(sp)
	
	}
	
	
//{	
}

