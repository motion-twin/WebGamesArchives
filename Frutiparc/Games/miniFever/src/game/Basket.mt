class game.Basket extends Game{//}

	// CONSTANTE
	
	// VARIABLES
	var flPoint:bool;
	var flWasUp:bool;
	var decal:float;
	var angle:float;
	var ballRay:float;
	var basketRay:float;
	var point:Array<{x:float,y:float}>
	
	// MOVIECLIPS
	var ball:sp.Phys;
	var basket:MovieClip;
	var arrow:MovieClip;
	

	function new(){
		super();
	}

	function init(){
		gameTime = 200;
		super.init();
		attachElements();
		flPoint = false;
		flWasUp = false;
		decal = 0;
		angle = Std.random(628);
		
	};
	
	function attachElements(){

		// PANIER
		basketRay = (110-dif*0.4)*0.5
		basket = dm.attach( "mcBasket", Game.DP_SPRITE)
		basket._x = Cs.mcw/2
		basket._y = 50
		basket.stop();
		basket._xscale = basketRay*2
		basket._yscale = basketRay*2
		
		// POINT
		point = new Array();
		for( var i=0; i<2; i++ ){
			var p = {
				x:basket._x+basketRay*(i*2-1),
				y:basket._y
			}
			point.push(p)
		}
		
		// BALLON
		ballRay = basketRay*0.5
		ball = newPhys("mcBasketBall");
		ball.x = Cs.mcw*0.5
		ball.y = Cs.mch-ballRay
		ball.skin._xscale = ballRay*2
		ball.skin._yscale = ballRay*2
		ball.flPhys = false;
		ball.init();

		// FLECHE
		arrow = dm.attach( "mcArrow", Game.DP_SPRITE)
		arrow._x = ball.x
		arrow._y = ball.y
		arrow._rotation = -90

	}
		
	function update(){
		super.update();
		
		switch(step){
			case 0:
				break;
			case 1:
				var speed = (4+dif*0.05)*Timer.tmod
				decal = (decal+speed)%628
				angle = Math.cos(decal/100)*0.9 - 1.57
				arrow._rotation = angle/(Math.PI/180)
				if(base.flPress)launch();
				break;
			case 2:
				var flUp =  ball.y+ballRay <  basket._y
				if(flPoint){
					// CHECK POINTS
					for( var i=0; i<2; i++ ){
						var p = point[i]
						var dist = ball.getDist(p)
						if( dist < ballRay ){
							var vit = Math.sqrt(ball.vitx*ball.vitx + ball.vity*ball.vity)
							var a = ball.getAng(p)
							ball.x = p.x - Math.cos(a)*ballRay
							ball.y = p.y - Math.sin(a)*ballRay
							ball.vitx = -Math.cos(a)*vit
							ball.vity = -Math.sin(a)*vit
							ball.vitr = Math.random()*10
						}
						
					}
				}else{
					if(flUp){
						flPoint = true;
						dm.over(basket)
					}
				}
				
				
				// CHECK SIDE
				if( ball.x < ballRay || ball.x > Cs.mcw-ballRay ){
					ball.vitx *= -1
					ball.x = Math.min(Math.max(ballRay,ball.x),Cs.mcw-ballRay)
					ball.vitr = Math.random()*10
				}
				
				// CHECK GROUND = CHECK LOOSE
				if( ball.y > Cs.mch-(ballRay+10) ){
					ball.vity *= -0.8
					ball.y = Cs.mch-(ballRay+10)
					setWin(false);
				}				
				
				
				// SCROLL
				var y = ball.y - Cs.mch/2
				dif = this._y - Math.max(0,-y)
				this._y -= dif*0.2*Timer.tmod
				
				// CHECK WIN
				
				flUp =  ball.y <  basket._y
				if( flWasUp && flPoint ){
					if(!flUp){
						if( Math.abs(basket._x-ball.x) < basket._xscale*0.5 ){
							//Log.trace("WIN!")
							basket.play();
							setWin(true);
						}
						
					}
				}
				flWasUp = flUp
				
				//
				ball.skin._x = ball.x
				ball.skin._y = ball.y
				
				// FILET BOUNDS
				if( this.flWin && ball.y < basket._y+basket._height){
					var min = point[0].x+ballRay
					var max = point[1].x-ballRay
					if( ball.x < min  || ball.x > max ){
						ball.x = Math.min(Math.max(min,ball.x),max)
						ball.vitx *= -1
					}
					min*=0.2
					max*=0.2
					if( ball.x < min  || ball.x > max ){
						ball.vitx *= Math.pow(0.95,Timer.tmod)
					}					
				}
				
				
				
				break;
				
		}
	
		
		
	}
	
	function launch(){
		var pow = 30
		step = 2
		ball.flPhys = true;
		ball.vitx = Math.cos(angle)*pow
		ball.vity = Math.sin(angle)*pow
		arrow.removeMovieClip();
	}
	
//{	
}




