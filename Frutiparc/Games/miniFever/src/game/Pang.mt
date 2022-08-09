class game.Pang extends Game{//}
	
	var perso:MovieClip;

	var frame:float;
	var ballList:Array<sp.Phys>;
	var a:float;
	var b:float;
	var distance:float;
	var c:float;
	var e:float;
	var f:float;
	var flDeath:bool;
	var flRedeath:bool;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 250;
		super.init();
		frame = 0;
		ballList=new Array();
		airFriction=1;
		flDeath=false;
		attachElements();
	};
	
	function attachElements(){
		perso=dm.attach("mcPerso",Game.DP_SPRITE);
		perso._x=50;
		perso._y=230;

		
		
		
		
		
		for( var i=0; i<1+dif*0.08; i++ ){
			var sp = newBall(15)
			
			
			while(true){
				sp.x=Std.random(30)-30;
							
				sp.y=Std.random(60);	
				
				var flbreak=true

					for(var u=0; u<ballList.length; u++){
						
						var ball2 = ballList[u]
						if(ball2!=sp){
							a=ball2.x-sp.x;
							b=ball2.y-sp.y;
							distance=Math.sqrt(a*a+b*b)
							if(distance<15){
								flbreak=false	
							}
						}
					}
					if(flbreak){
						break
					}
				
			}
			
			sp.init();
			
			
		}
		
		
			
			
					
		
		
		
		
	}
	
	function update(){
		super.update();
		movePerso();
		updateBall();
		
		
		
		
	}
	
// 	function killPerso(){
// 		e=sp.x-perso._x;
// 		f=sp.y-perso._y;
// 		c=Math.sqrt(e*e+f*f)
// 		
// 		if (c<20){
// 			setWin(false)
// 		}
// 		
// 		
// 		
// 	}
	
	
	function movePerso(){
		if(!flDeath){
			var d=_xmouse-perso._x	
		
			perso._x=perso._x+d*0.1			
			
			perso._xscale=-((Math.abs(d))/d)*100
	
			var vit=Math.abs(d/240)*10;
			frame=(frame+vit)%13;
			perso.gotoAndStop(string(int(frame+1)));
		}
	}
	
	function updateBall(){
		for( var i=0; i<ballList.length; i++ ){
		
			var sp = ballList[i]
// 			Log.trace(sp.y)
			
			if(sp.y>220){
				sp.y=220;
				sp.vity *=-1
			}
			if(sp.x>240){
				sp.x=240;
				sp.vitx *=-1
			}
			if(sp.x<0){
				sp.x=0;
				sp.vitx *=-1
			}
			
			sp.skin._x = sp.x;
			sp.skin._y = sp.y;

			if(sp.vity>0){
				e=sp.x-perso._x;
				f=sp.y-(perso._y-20);
				c=Math.sqrt(e*e+f*f)
				if( c<20 ){
					if(!flDeath){
						flDeath=true;
						perso.gotoAndPlay("death");
						setWin(false);
					}else{
						perso.gotoAndPlay("redeath");
					}
					sp.vity*=-1;
				}
			}
		}
	}
	
	function newBall(size){
		var sp = newPhys("mcPangBall");
		ballList.push(sp);
		sp.vity=-10;
		sp.vitx=Std.random(4)+1;
		return sp;
	}
	
	function outOfTime(){
		setWin(true)
	}
		
	
	
//{	
}

