class game.Pair extends Game{//}
	//			    
	static var POS_LIST = [
		[3,2],
		[4,2],
		[5,2],
		[4,3],
		[4,4],
		[6,3]
	]
	
	static var CW = 32
	static var CH = 50
	
	
	// CONSTANTES
	
	var xMax:int;
	var yMax:int;
	var waitTimer:float;

	
	//var loop_t:int;
	
	// VARIABLES
	var winPoints:int;
	var cList:Array<{>Sprite,card:MovieClip,timer:float,id:int,flFace:bool}>
	var tc:{>Sprite,card:MovieClip,timer:float,id:int,flFace:bool}
	var tc2:{>Sprite,card:MovieClip,timer:float,id:int,flFace:bool}
	var freezeTimer:float;
	
	// MOVIECLIPS


	function new(){
		super();
	}

	function init(){

		gameTime = 500
		super.init();

		waitTimer = 80
		winPoints = 0
		attachElements();
			

	};
	
	function attachElements(){
		
		// CARD
		var index = Math.floor((dif/101)*POS_LIST.length)

		var xMax = POS_LIST[index][0]
		var yMax = POS_LIST[index][1]
		
		var ec = 5
		var mx = (Cs.mcw-( xMax*CW   + (xMax-1)*ec ))*0.5
		var my = (Cs.mch-( yMax*CH   + (yMax-1)*ec ))*0.5
		
		var max = xMax*yMax
		var dispo = new Array();
		for( var i=0; i<max; i++)dispo.push(Math.floor(i/2))
		dispo = Std.cast(Tools.shuffle)(dispo)
		
		cList = new Array();
		for( var x=0; x<xMax; x++ ){
			for( var y=0; y<yMax; y++ ){
				var card = downcast(newSprite("mcPairCard"))
				card.x = mx + x*(ec+CW)
				card.y = my + y*(ec+CH)
				card.id = dispo.pop()//Math.floor(cList.length/2)
				card.timer = (x+y)*8
				card.flFace=false;
				card.init();
				cList.push(card)
			}				
		}
		
		
		
	}
	


	function update(){
		switch(step){
			case 1:
				var flNext = true;
				for( var i=0; i<cList.length; i++ ){
					var card = cList[i]
					if( card.timer !=null ){
						//Log.print(">"+card.id)
						flNext = false;
						card.timer -= Timer.tmod
						if( card.timer <= 0 ){
							if(!card.flFace){
								card.timer = waitTimer
								card.skin.gotoAndPlay("face");
								card.flFace = true;
							}else{
								card.timer = null
								card.skin.gotoAndPlay("back");
								card.flFace = false;
							}
						}
					}else{
						if( card.skin._currentframe > 1 )flNext = false;
					}
				}

				if(flNext){
					for( var i=0; i<cList.length; i++ ){
						initCardAction(cList[i])
						
					}
					step = 2
				}
				
				break;
			case 2:
				if(freezeTimer!=null){
					freezeTimer-=Timer.tmod
					if( freezeTimer < 0 ){
						freezeTimer = null;
						tc.skin.gotoAndPlay("back");
						tc2.skin.gotoAndPlay("back");
						initCardAction(tc)
						initCardAction(tc2)
						tc = null;
						tc2 = null;						
					}
				}
				
				if( int(cList.length*0.5) == winPoints ){
					setWin(true)
					step = 3
				}
				
				break;
			case 3:
				break;
		}
		
		super.update();
	}
	
	function initCardAction(card){
		card.skin.onPress = callback(this,turn,card)
	}
	
	function turn(card){
		if(tc2!=null)return;
		card.skin.onPress = null
		card.skin.gotoAndPlay("face");
		if(tc==null){
			tc = card
		}else{
			if( card.id == tc.id ){
				winPoints += 1
				tc = null
			}else{
				tc2 = card
				freezeTimer = 18
			}		
		}
	}
	
	
//{	
}













