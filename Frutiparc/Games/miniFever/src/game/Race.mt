class game.Race extends Game{//}
	
	// CONSTANTES
	var wpMax:int;
	var ray:int;
	// VARIABLES
	var carList:Array<{sp:sp.Phys,next:int,speed:float, a:float}>
	
	
	// MOVIECLIPS
	var car:Sprite;
	var race:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 700-dif*2;
		super.init();
		
		carList = new Array();
		wpMax = 31
		ray = 10
		attachElements();
	};
	
	function attachElements(){
		
		for( var i=0; i<2; i++ ){
			var wp = Std.getVar(this,"$wp"+wpMax)
			var sp = newPhys("mcRaceCar")
			sp.x = wp._x
			sp.y = wp._y+(i*2-1)*7
			sp.weight = 0;
			sp.init();
			sp.skin.gotoAndStop(string(i+1))
			var o = { sp:sp, next:0, speed:0, a:0 }
			
			if(i==1)o.speed = 0.15+dif*0.003;
			
			carList.push(o)
		}
		
	}
	
	function update(){
		switch(step){
			case 1: 
				moveCar();
				checkCol()
				break;
		}
		super.update();
	}
	
	function moveCar(){
		for( var i=0; i<carList.length; i++ ){
			var car = carList[i]
			var wp = Std.getVar(this,"$wp"+car.next)
			
			var p = {x:wp._x,y:wp._y}
			var ta = car.sp.getAng(p)
			var dist = car.sp.getDist(p)
			var da = ta - car.a;
			while(da>3.14)da-=6.28;
			while(da<-3.14)da+=6.28;
			var lim = 0.5
			var coef = 0.2					
			if(i==1){
				lim = 0.8
				coef = 0.4
			}
			car.a += Math.min(Math.max(-lim,da*coef),lim)*Timer.tmod;
			car.sp.skin._rotation = car.a/0.0174
			car.sp.vitx += Math.cos(car.a)*car.speed;
			car.sp.vity += Math.sin(car.a)*car.speed;
			
			//Log.print(wp)
			
			var f = 0.9
			if( i == 0 ){
				if(base.flPress)car.speed+=0.07;
				
				if(!race.hitTest(car.sp.x,car.sp.y,true)){
					f = 0.8
					car.speed = Math.min( 0.2, car.speed )
				}					
				
	
				car.speed *= Math.pow(0.9,Timer.tmod)
			}
			var frict =  Math.pow(f,Timer.tmod)
			car.sp.vitx *= frict;
			car.sp.vity *= frict;					
			
			if(dist<16){
				car.next++;
				if(car.next>wpMax){
					car.next = 0;
					setWin(i==0)
				}
			}
		}	
	}
	
	function checkCol(){
		var c0 = carList[0].sp
		var c1 = carList[1].sp
		var d = c0.getDist(c1)
		if( d<ray ){
			var dif = ray-d
			var a = c0.getAng(c1)
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			
			c0.x -= ca*dif
			c0.y -= sa*dif
			c1.x += ca*dif
			c1.y += sa*dif	

			var c = 1
			c0.vitx -= ca*dif*c
			c0.vity -= ca*dif*c
			c1.vitx += ca*dif*c
			c1.vity += ca*dif*c			
		}
		
		
		
		
		
	}
	
	function inRace(x,y){
		var o  = race.getBounds(this);
		return o.xMin < x && x < o.xMax && o.yMin < y && y < o.yMax	
	}

	
	
//{	
}

