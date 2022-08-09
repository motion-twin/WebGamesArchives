class game.Hole extends Game{//}
	
	// CONSTANTES

	// VARIABLES
	var id:int;
	var fid:int;
	var timer:float;
	var speed:float;
	//
	var toy:{>MovieClip,dm:DepthManager,list:Array<{>MovieClip,o:MovieClip}>};
	
	var cList:Array<{>MovieClip,tx:float,vx:float,o:MovieClip}>
	
	// MOVIECLIPS
	var door:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 650-dif*2;
		super.init();
		id = Std.random(4)
		fid = Std.random(3)
		speed = 5+dif*0.3
		timer = 20
		attachElements();
	};
	
	function attachElements(){
		
		//
		toy = downcast(dm.empty(Game.DP_SPRITE))
		toy.list = new Array();
		toy.dm = new DepthManager(toy);
		toy._y = Cs.mch*0.5;
		
		
		/*
		downcast( dm.attach("mcHoleObject",Game.DP_SPRITE) )
		toy.o.gotoAndStop(string(id+1))
		*/
		
		//toy._rotation = (Math.random()*2-1)*dif*2
		
		//
		door = dm.attach("mcHoleDoor",Game.DP_SPRITE)
		

	}
	
	function update(){

		switch(step){
			case 1:
				timer-=Timer.tmod;
				if(timer<=0)step = 2;
				break;
			case 2:
				for( var i=0; i<toy.list.length; i++ ){
					var mc = toy.list[i]
					mc._alpha *= 0.9;
					if( mc._alpha < 4 ){
						mc.removeMovieClip();
						toy.list.splice(i--,1);
					}
				}

				var delta = 2+dif*0.1
				var mc = downcast(toy.dm.attach("mcHoleObject",1))
				mc.gotoAndStop(string(fid+1))
				mc.o.gotoAndStop(string(id+1))
				mc._x = (Math.random()*2-1)*delta
				mc._y = (Math.random()*2-1)*delta
				mc._alpha = 20
				mc._rotation = (Math.random()*2-1)*delta
				toy.list.push(mc)
			
				toy._x += speed*Timer.tmod
			
				if( toy._x > Cs.mcw ){
					toy.removeMovieClip();
					initChoices();
					door.play();
					step = 3
				}
				break;
			case 3:
				for( var i=0; i<cList.length; i++ ){
					var mc = cList[i];
					var dx = mc.tx-mc._x;
					var lim = 2;
					mc.vx += Cs.mm(-lim,dx*0.1,lim);
					mc.vx *= Math.pow(0.85,Timer.tmod);
					mc._x += mc.vx*Timer.tmod;
				}
				
				
				break;				
		}
		
		super.update();
	}
	
	function initChoices(){
		cList =new Array();
		var q = Cs.mcw*0.25
		var i = 0;
		for( var x=0; x<2; x++ ){
			for( var y=0; y<2; y++ ){
				var mc = downcast(dm.attach("mcHoleObject",Game.DP_SPRITE))
				mc.gotoAndStop(string(fid+1))
				mc.o.gotoAndStop(string(i+1))
				mc._x  = Cs.mcw*0.5 + (x*2-1)*(Cs.mcw*(0.75+(y*0.2)))
				mc.tx = q+2*x*q;
				mc._y = q+2*y*q;
				mc.onPress = callback(this,select,i)
				mc.vx = 0
				cList.push(mc)
				i++
			}
		}
		
		dm.over(door)
	}
	
	function select(n){
		for( var i=0; i<cList.length; i++ ){
			var choice = cList[i]
			if( (id==i && n==id ) || (id!=i && n!=id) ){
				var mc = dm.attach("mcHoleMark",Game.DP_SPRITE)
				mc._x = choice._x;
				mc._y = choice._y;
				mc.stop();
				mc.gotoAndStop((id==i)?"1":"2")
			}

				
		}
		
		dm.over(door)
		
		if(n==id){
			setWin(true)
		}else{
			setWin(false)
		}
	}
	
	
//{	
}

