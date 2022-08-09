typedef FAApple = {>Phys,step:Int};
import Protocole;

class FallApple extends Game{//}

	// CONSTANTES
	static var GOAL = 8;
	static var ARAY = 10;
	static var PRAY = 25;
	static var ECART = 18;

	// VARIABLES
	var aList:Array<FAApple>;
	var ph:Float;
	var timer:Float;

	// MOVIECLIPS
	var panier:Phys;

	override function init(dif:Float){
		gameTime = 380-dif*60;
		super.init(dif);
		aList = new Array();
		ph = Cs.omch - 46;
		timer = 10;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("fallApple_bg",0);

		// PANIER
		panier = newPhys("mcPanier");
		panier.x = Cs.omcw*0.5;
		panier.y = ph;
		panier.vr = 0;
		panier.root.stop();
		panier.updatePos();
		panier.frict = 0.95;

	}

	override function update(){
		switch(step){
			case 1:
				// PANIER
				var p = {
					x:getMousePos().x,
					y:ph
				}
				panier.towardSpeed(p,0.01,0.7);
				panier.vx *= 0.96;

				var dr = -panier.root.rotation;
				panier.vr += dr*0.1;
				panier.vr *= 0.97;

				// APPLE
				timer--;
				if(timer<0){
					timer = ECART;
					addApple();
				}

				for( sp in aList ){
					var adx = Math.abs( panier.x - sp.x );

					switch(sp.step){
						case 0:
						
							if( sp.y > panier.y-ARAY ){
								sp.step = 1;
								if(  adx < PRAY-ARAY && win == null ){
									panier.vy += sp.vy*0.5;
									sp.kill();
									panier.root.nextFrame();
									if( panier.root.currentFrame == 8 ) {
										
										setWin(true,15);
									}
								}else{

									for( n in 0...2 ){
										var sens = n*2-1;
										var pos = {
											x:panier.x+sens*PRAY,
											y:panier.y
										}
										var dist = sp.getDist(pos);
										if( dist < ARAY ){
											
											sp.step = 0;
											var a = sp.getAng(pos);
											var d = ARAY - dist;
											var ca = Math.cos(a);
											var sa = Math.sin(a);
											sp.x -= ca*d;
											sp.y -= sa*d;
											var speed = Math.sqrt(sp.vx*sp.vx+sp.vy*sp.vy)*0.8;
											sp.vx = -ca*speed;
											sp.vy = -sa*speed;
											panier.vr += speed*0.5*sens;
											panier.vy += speed*0.3;
											sp.vr += speed*2*sens;
										}
									}
								}
							}

						case 1:

					}
				}


		}
		super.update();
	}

	function addApple(){

		var sp:FAApple =  cast newPhys("mcFallApple");
		var r = ARAY+80*(1-Math.min(1,dif));
		sp.x = r + Math.random()*(Cs.omcw-2*r);
		sp.y = -ARAY;
		sp.weight = 0.1 + Math.random()*0.2;
		sp.frict = 1;
		sp.vr = 0;
		sp.step = 0;
		sp.updatePos();
		aList.push(sp);

	}


//{
}

