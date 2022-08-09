class game.Hamburger extends Game{//}
	//			    
	static var RAY = 30
	static var MAX = 4
	
	// CONSTANTES
	var gl:float;
	
	// VARIABLES
	var index:int;
	var timer:float;
	var fallTimer:float;
	var fallInterval:float;
	var speed:float;
	var speedDecal:float;
	var hList:Array<{mc:MovieClip,dx:float}>;
	var fList:Array<{mc:MovieClip,decal:float,sd:float,flUp:bool}>;
	
	

	function new(){
		super();
	}

	function init(){
		gameTime = 650
		super.init();

		gl = Cs.mch-30
		speed = 1.5+dif*0.025
		speedDecal = 3+dif*0.08
		fallTimer = 0
		fallInterval = 35-dif*0.2
		index = 0
		
		fList =new Array();
		
		attachElements();
			

	};
	
	function attachElements(){
		hList= new Array();
		for( var i=0; i<2; i++){
			var mc = dm.attach("mcHamburger",Game.DP_SPRITE)
			mc.gotoAndStop(string(11-i*10))
			mc._y = gl
			hList.push({mc:mc,dx:0}); 
		}
		
		

		
		
	}
	
	function update(){
		switch(step){
			case 1:
				moveAll();
			
				fallTimer -= Timer.tmod
				if( fallTimer < 0 ){
					if(index < MAX ){
						index++
						fallTimer = fallInterval+Math.random()*fallInterval
						var dec = Math.random()*628
						var sd = speedDecal+Math.random()*speedDecal
						for( var i=0; i<2; i++){
							var mc = dm.attach("mcHamburger",Game.DP_SPRITE)
							mc.gotoAndStop(string(index+1+i*10))
							mc._y = -20
							if( i == 1 )dm.under(mc);
							fList.push( { mc:mc, decal:dec, flUp:true, sd:sd } ); 
						}
					}	
				}
				
				for( var i=0; i<fList.length; i++ ){
					var info = fList[i]
					var mc = info.mc
					var h = Cs.mcw*0.5
					info.decal = (info.decal+info.sd*Timer.tmod)%628
					mc._x = Cs.mcw*0.5 + Math.cos(info.decal/100)*((Cs.mcw-RAY*2)*0.5)
					mc._y += speed*Timer.tmod
					if( info.flUp && mc._y > gl ){
						mc._y = gl;
						info.flUp = false;
						var last =hList[hList.length-2]
						var dx = last.mc._x-mc._x
						if( Math.abs(dx) < RAY*0.8 ){
							hList.push({mc:mc,dx:last.dx-dx})
							fList.splice(i--,1)
						}
					}
					
					if(mc._y > Cs.mch )setWin(false);
					
				}
				//Log.print(fList.length+" x "+index)
				if( fList.length == 0 && index == MAX ){
					setWin(true)
				}				
				
				break;
			case 2:

				break;

		}
		super.update();
	}
	
	
	
	function moveAll(){
		for( var i=0; i<hList.length; i++ ){
			var info = hList[i]
			info.mc._x = Cs.mm( RAY, _xmouse, Cs.mcw-RAY )+info.dx
			
			
		}
	}

	
//{	
}



