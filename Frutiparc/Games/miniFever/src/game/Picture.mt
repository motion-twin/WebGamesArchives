class game.Picture extends Game{//}
	
	// CONSTANTES
	var picSize:int;
	var marginDown:float
	
	
	// VARIABLES
	var face:int;
	var rot:int;
	var mvt:int;
	var tRotation:int;
	var tXScale:int;
	var tYScale:int;
	var frame:int;
	var doorSens:int;
	var winIndex:int;
	var decal:float;
	var size:float;
	var speed:float;
	var pause:float;
	var pausePool:float;
	var cSpeed:float;
	
	var tryList:Array<{face:int,rot:int,mc:Sprite,timer:float}>
	
	
	// MOVIECLIPS
	var cadre:Sprite;
	var img:Sprite;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 400;
		super.init();
		speed = 30 + dif*0.2//0.25// + dif*0.001
		mvt = 2 + Math.floor(dif*0.05)// + 5
		size = 100;
		rot = 0;
		face = 1;
		pausePool = 10
		attachElements();
		picSize = 68
		marginDown = picSize+20
		
	};
	
	function attachElements(){
		
		// IMG
		img = newSprite("mcImage");
		img.x = Cs.mcw*0.5;
		img.y = -size*0.5;
		img.skin._xscale = size
		img.skin._yscale = size
		img.skin.stop();
		img.init();
		
		// CADRE
		cadre = newSprite("mcCadre")
		cadre.x = Cs.mcw*0.5
		cadre.y = Cs.mch*0.5
		cadre.skin._xscale = size
		cadre.skin._yscale = size
		cadre.skin.stop();
		cadre.init();

		
	}
	
	function update(){
		switch(step){
			case 1: //SHOW
				//Log.print(img.y)
				var dy = cadre.y - img.y
				img.y  += dy*0.4*Timer.tmod
				if( Math.abs(dy)< 0.5 ){
					step = 2;
					doorSens = 1
					frame = 0
					img.y = cadre.y
					
				}
			
				break;
			case 2: // MOVE DOOR
				frame += doorSens*Timer.tmod
				
				if( frame < 0 ){
					frame = 0;
					step = 5;
				}
				if( frame > cadre.skin._totalframes-1 ){
					frame = cadre.skin._totalframes-1;
					img.skin._visible = false;
					step = 3;
					launchMvt();
				}
				
				cadre.skin.gotoAndStop(string(Math.round(frame+1)))

				
				
			case 3: //TURN
				if( decal != null ){
					decal += Timer.tmod*speed*cSpeed //157
					checkReset();
				}
				var c = (1-Math.cos(decal/100))*0.5
				if( tRotation != null ){
					cadre.skin._rotation = c*tRotation//d*speed*Timer.tmod
				}
				if( tXScale != null ){
					cadre.skin._xscale = 100+tXScale*c*2
				}					
				if( tYScale != null ){
					cadre.skin._yscale = 100+tYScale*c*2
				}		
				if( pause != null){
					//Log.print("pausing ")
					if( pause<0 ){
						pause = null;
						launchMvt();
					}else{
						pause -= Timer.tmod
					}
				}
				break;
				
			case 4: //CHOOSE
				var ty = Cs.mch - marginDown*0.5
				for( var i=0; i<tryList.length; i++ ){
					var info = tryList[i]
					if( info.timer < 0 ){
						var mc = info.mc
						var d = ty - mc.y;
						mc.y += d*0.3*Timer.tmod;
					}else{
						info.timer -= Timer.tmod
					}
				}
				ty = ( Cs.mch-marginDown )*0.5
				
				var d = ty - cadre.y
				cadre.y += d*0.3*Timer.tmod;
				
				img.y = cadre.y
				
				
				break;				
		}
		super.update();
	}
	
	function launchMvt(){
		mvt--;
		decal = 0;
		switch(Std.random(6)){
			case 0:
			case 1:
				rot = (rot+1)%4
				tRotation = 90
				cSpeed = 1
				//Log.print("turn right --> ("+rot+","+face+")")
				break;
			case 2:
			case 3:
				rot = (rot+3)%4
				tRotation = -90
				cSpeed = 1
				//Log.print("turn right --> ("+rot+","+face+")")
				break;
			case 4:
				tXScale = -100
				if( rot==1 || rot == 3 ) rot = (rot+2)%4;
				face = (face+1)%2
				cSpeed = 0.5
				break;
			case 5:
				tYScale = -100
				if( rot==0 || rot == 2 ) rot = (rot+2)%4 ;
				face = (face+1)%2
				cSpeed = 0.5
				break;				
		}
		//Log.trace("launchMvt!")
	}
	
	function checkReset(){
		if(decal>314){
			//Log.trace("endMvt!")
			cadre.skin._rotation = 0;
			cadre.skin._xscale = 100;
			cadre.skin._yscale = 100;
			tRotation = null;
			tXScale = null;
			tYScale = null;
			decal = null
			if(mvt>0){
				pause = pausePool//+Std.random(pausePool)
				pausePool *= 0.5
			}else{
				step = 4
				initTryStep();
			}			
		}
	}
	
	function initTryStep(){
		Log.clear();
		// INIT TRYLIST
		tryList = new Array();
		for( var i=0; i<3; i++ ){

			var r = Std.random(4)
			var f = Std.random(2)
			
			var flValide  =  r != rot || f != face 
			//Log.trace("try("+r+","+f+") --> flValide("+flValide+")")
			for( var n=0; n<tryList.length; n++ ){
				var o = tryList[n]
				if( o.rot == r && o.face == f ) flValide=false;
			}

			if(flValide){
				//Log.trace("validate("+r+","+f+")")
				tryList.push({rot:r,face:f,mc:null,timer:4+i*8})
			}else{
				i--;
			}
		}
		
		winIndex = Std.random(3);
		var inf = tryList[winIndex];
		//Log.trace("replace("+winIndex+") with("+rot+","+face+")")
		inf.rot = rot;
		inf.face = face;
		
		// GEN PIC
		var max = tryList.length
		var w = (Cs.mcw - max*picSize)
		var e = w/(max+1)
		for( var i=0; i<max; i++ ){
			var info = tryList[i]
			var mc = newSprite("mcImage")
			mc.x = e + picSize*0.5 + i*(e+picSize)
			mc.y = Cs.mch + picSize*0.5
			mc.skin._xscale = picSize
			mc.skin._yscale = picSize
			//mc.skin._xscale *= (info.face*2-1)
			mc.skin.gotoAndStop(string(2-info.face))
			mc.skin._rotation = info.rot*90
			mc.init();
			tryList[i].mc = mc
			initPic(mc,i);
			
		}

	}

	function initPic(mc,i){
		var me = this
		mc.skin.onPress = fun(){
			me.select(i);
		}		
	}
	
	function select(i){
		setWin(i == winIndex);
		doorSens =-1
		step = 2
		img.skin._visible = true;
		img.skin._rotation = rot*90
		img.skin.gotoAndStop(string(2-face))
	}
	
	

//{	
}

















