class game.Point extends Game{//}
	
	// CONSTANTES

	// VARIABLES
	var index:int;
	
	// MOVIECLIPS
	var shape:MovieClip;
	var next:MovieClip;
	var line:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 500-dif;
		super.init();
		gotoAndStop(string(Math.round(1+dif*0.04)))
		
		index = 0

		initPoints()
		updateNext();
		attachElements();
		
		line.lineStyle(2,0x746410,100)
		line.moveTo(next._x,next._y)		
	};
	
	function attachElements(){
		// SHAPE
		shape._visible = false;
		
		// LINE
		line = dm.empty(Game.DP_BACKGROUND)
		
		//TEXTURE
		var mc = dm.attach("mcTexture",Game.DP_BACKGROUND)
		var col = new Color(mc)
		var o  = {
			ra:200,
			ga:150,
			ba:100,
			aa:50,
			rb:0,
			gb:0,
			bb:0,
			ab:0
		}
		col.setTransform(o)
	}
	
	function initPoints(){
		var i=0
		var mc = null
		do{
			//mc = Std.cast(this)["$p"+index]
			mc = Std.getVar(this,"$p"+i)
			mc._alpha = 20
			mc.stop();
			i++
			
		}while(mc._visible)
		
		
	}
	
	function update(){
		super.update();
		switch(step){
			case 1:
				break;
		}
		//
	
	}
	
	function updateNext(){
		next.gotoAndStop("1")
		next._visible =false;
		next.onRollOver = null;
		next = Std.getVar(this,"$p"+index)
		
		if( next._visible ){
			next.gotoAndStop("2")
			next._alpha = 100
			var me = this;
			next.onRollOver = fun(){
				me.draw();
			}
		}else{
			setWin(true)
			shape._visible = true;
		}
		
	}
	
	function draw(){
		if(next._rotation == 0){
			line.lineTo( next._x, next._y );
		}else{
			line.moveTo( next._x, next._y );
		}
		index++
		updateNext();
	}
	
	


	
	
//{	
}

