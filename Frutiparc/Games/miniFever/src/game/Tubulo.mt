class game.Tubulo extends Game{//}
	
	// CONSTANTES

	// VARIABLES
	var flCheck:bool;
	var xMax:int
	var yMax:int
	var size:int
	var decal:float;
	var tubeList:Array<Array<{mc:Sprite,id:int,p:float,tp:int}>>
	var moveList:Array<MovieClip>
	var can:Array<{x:int,y:int}>
	
	// MOVIECLIPS


	function new(){
		super();
	}

	function init(){
		gameTime = 320;
		super.init();
		
		xMax = 4
		yMax = 4
		
		size = 40
		
		can = [
			{ x:0, y:0 },
			{ x:1, y:0 },
			{ x:0, y:1 },
			{ x:-1, y:0 },
			{ x:0, y:-1 }
		]
		

		initPuzzle();
		attachElements();
	};
	
	function initPuzzle(){
	
		tubeList = new Array();
		for( var x=0; x<xMax; x++ ){
			tubeList[x] = new Array();
			for( var y=0; y<yMax; y++ ){
				tubeList[x].push({id:0,mc:null,p:100,tp:null})
			}			
		}

		shuffle()

		
	}
	
	function shuffle(){
		var max = 1+Math.round(dif*0.12)
		for( var i=0; i<max; i++){
			var x = Std.random(xMax)
			var y = Std.random(yMax)
			for( var c=0; c<can.length; c++){
				var info = tubeList[x+can[c].x][y+can[c].y]
				info.id = (info.id+2)%3
			}
		}
	}
	
	function attachElements(){
		
		var bx = Cs.mcw*0.5
		var by = Cs.mch*0.5 - size*(yMax+xMax)*0.125
		
		for( var x=0; x<xMax; x++ ){
			for( var y=0; y<yMax; y++ ){
				var mc = newSprite("mcTube")
				var slot = tubeList[x][y]
				mc.x = bx + x*size*0.5		+ 	y*(-size*0.5)
				mc.y = by + x*size*0.4		+ 	y*size*0.4
				mc.skin._xscale =  size
				mc.skin._yscale =  size
				Std.cast(mc.skin).tube.gotoAndStop(string(slot.id+1))
				mc.init();
				initTube(mc,x,y)
			}			
		}
	}
	
	function initTube(mc,x,y){
		tubeList[x][y].mc = mc
		
		var me = this
		mc.skin.onPress = fun(){
			me.select(x,y)
		}
		mc.skin.onRollOver = fun(){
			me.setColor(x,y,70)
		}		
		mc.skin.onRollOut = fun(){
			me.setColor(x,y,100)
		}
		mc.skin.onDragOut = mc.skin.onRollOut;
		
		
	}
	
	function select(x,y){
		if(step==2)return;
		moveList = new Array();
		step = 2
		decal = 0
		flCheck = true;
		for( var i=0; i<can.length; i++){
			var info = tubeList[x+can[i].x][y+can[i].y]
			moveList.push(info.mc.skin)
			info.id = (info.id+1)%3
			
		}	
	}
	
	function setColor(x,y,p){
		
		for( var i=0; i<can.length; i++){
			tubeList[x+can[i].x][y+can[i].y].tp = p
		}
		
		
	}
	
	
	
	
	function update(){
		super.update();
		switch(step){
			case 1:
				checkLight();
				break;
			case 2:
				checkLight();
				decal += 40*Timer.tmod
				if( decal > 314 ){
					step = 1
					decal = 314
				}
				for( var i=0; i<moveList.length; i++ ){
					var mc = Std.cast(moveList[i])
					mc.tube._y = Math.sin(decal/100)*size*2
					
				}
				if( flCheck && decal > 157 ){
					checkColor();
					flCheck = false;
				}
				
				
				break;
		}
		//
	
	}
	
	function checkLight(){
		for( var x=0; x< tubeList.length; x++ ){
			for( var y=0; y< tubeList[y].length; y++ ){
				var info = tubeList[x][y];
				if( info.tp != null ){
					var dif = info.tp - info.p
					info.p += dif*0.2*Timer.tmod
					Mc.setPColor(Std.cast(info.mc.skin),0xFFFFFF,info.p)
				}
			}
		}	
	}
	
	function checkColor(){
		var win = true
		for( var x=0; x< tubeList.length; x++ ){
			for( var y=0; y< tubeList[y].length; y++ ){
				var info = tubeList[x][y];
				Std.cast(info.mc.skin).tube.gotoAndStop(string(info.id+1))
				if( info.id != 0 )win = false;
			}
		}
		if(win)setWin(true);
	}
	
	

	
	
//{	
}

