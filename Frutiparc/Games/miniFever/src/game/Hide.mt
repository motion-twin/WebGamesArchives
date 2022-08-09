class game.Hide extends Game{//}
	
	// CONSTANTES

	
	// VARIABLES
	var winList:Array<Sprite>
	var openList:Array<Sprite>
	var compt:float;
	var speed:float;
	var sens:int;
	
	// MOVIECLIPS
	var current:Sprite;
	
	
	function new(){
		
		super();
	}

	function init(){
		gameTime = 320+dif*0.3;
		super.init();
		speed = 4;
		attachElements();
		openWin();
		
	};
	
	function attachElements(){
		winList= new Array();
		var scale = 32
		for(var x=0; x<3; x++ ){
			for(var y=0; y<4; y++ ){
				if( y!=3 || x!=1 ){
					var sp = newSprite("mcWindow")
					sp.x = 40+x*64
					sp.y = 50+y*40
					sp.skin._xscale = scale
					sp.skin._yscale = scale
					sp.skin.stop();
					Std.cast(sp.skin).man._visible = false;
					sp.init();
					winList.push(sp)
				}
			}		
		}
	}
	
	function update(){
		//dif = 100
		switch(step){
			case 1: 
				compt += Timer.tmod*sens*speed;
				speed *= 1.013
				if( sens > 0 && compt > 100){
					sens *= -1
					//compt = 200-compt
					compt = 100
				}
				if( sens < 0 && compt < 0){
					compt = 0;
				}
				var frame = 1+Math.round((compt/100)*30)
				for( var i=0; i<openList.length; i++ ){
					var sp  = openList[i]
					sp.skin.gotoAndStop(string(frame))
				}
				if( sens<0 && compt == 0 ){
					if( speed < 50+(dif*0.75) ){
						openWin();
					}else{
						step = 2
						for( var i=0; i<winList.length; i++){
							initBut(winList[i]);
						}
					}
				}
				
				
				break;
			case 2:

				break;
			case 3:
				compt += Timer.tmod*4
				current.skin.gotoAndStop(string(Math.round(compt)))
				break;				
		}
		//
		super.update();
	}
	
	function openWin(){
		compt = 0;
		sens = 1
		openList = new Array();
		var old = current
		while( old == current ){
			current = getWin();
		}
		downcast(current.skin).man._visible = true;
		openList.push(current)
		
		while( Std.random(Math.floor(dif*0.1)) > openList.length ){
			var win  = getWin();
			if( win != current ){
				downcast(win.skin).man._visible = false;
				openList.push(win)
			}
		}
		
		
	}
	
	function getWin(){
		return winList[Std.random(winList.length)]
	}
	
	function initBut(win){
		var me = this;
		win.skin.onPress = fun(){
			me.select(win)
		}
	}
	
	function select(sp){
		var fl = sp == current
		var mc = downcast(sp.skin).man
		mc._visible = fl;
		mc.gotoAndStop(2)
		
		setWin(fl);
		current = sp;
		compt = 0;
		step = 3 		
	}
	
	
	
	
//{	
}






















