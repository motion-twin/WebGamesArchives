class game.Hammer extends Game{//}
	
	// CONSTANTES
	var cSpeed:float;
	
	// VARIABLES
	var flReady:bool;
	var bList:Array<{hole:MovieClip,t:float,frame:int}>
	var hList:Array<MovieClip>
	
	// MOVIECLIPS
	var hammer:Sprite;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 320;
		super.init();
		Log.clear()
		cSpeed = 0.3
		flReady = true;
		attachElements();
		
	};
	
	function attachElements(){
		
		// HOLE
		hList = new Array();
		for( var i=0; i<18; i++ ){
			var mc:MovieClip = Std.getVar(this,"$t"+i)
			downcast(mc).b._visible = false;
			downcast(mc).h._visible = false;
			hList.push(mc)
		} 
		
		// BADS
		bList = new Array()
		var max = 1 + dif*0.08
		for( var i=0; i<max; i++ ){
			var b = {hole:null,t:null,frame:Std.random(8)+1}
			findHole(b)
			bList.push(b)
		} 		
		
		// HAMMER
		hammer = newSprite("mcHammer")
		hammer.x = Cs.mcw*0.5
		hammer.y = Cs.mch*0.5
		hammer.init();

		
	}
	
	function update(){
		switch(step){
			case 1:
				if(flReady){
					hammer.toward({x:_xmouse,y:_ymouse},0.5,null)
				}
			
				
				// BADS
				for(var i=0; i<bList.length; i++){
					//Log.trace("bad")
					var b = bList[i]
					var bad = downcast(b.hole).b
					if( b.t!=null ){
						
						if( bad._y > 0 ){
							bad._y *= cSpeed
							if( bad._y < 1 ) bad._y = 0 ;
						}else{
							if( b.t > 0 ){
								b.t -= Timer.tmod
							}else{
								b.t = null;
								bad.onPress = null;
							}
						}
					}else{
						bad._y += (20+dif*0.2)*Timer.tmod
						if( bad._y > 100 ){
							freeHole(b)
							findHole(b);
						}
					}
				}
				
				break;
		}
		//
		super.update();
	}
	
	function findHole(b){

		var n = Std.random(hList.length)
		var hole = hList[n]
		hList.splice(n,1)
		var bad  = downcast(hole).b
		bad._visible = true;
		bad._y = 100;
		bad.gotoAndStop(b.frame);
		var me = this;
		bad.onPress = fun(){
			me.catchBad(b)
		}
		
		
		b.hole = hole
		b.t = Std.random( Math.round(15+(80*(1-dif*0.01))) )
		

		
	}
	
	function freeHole(b){
		var bad  = Std.cast(b.hole).b
		bad._visible = false;
		hList.push(b.hole)
		b.hole = null
		
	}
	
	function catchBad(b){
		//Log.trace("catchBad!")
		if(flReady){
			// HAMMER
			flReady = false;
			hammer.x = b.hole._x
			hammer.y = b.hole._y
			hammer.skin._visible = false;
			Std.cast(b.hole).h.gotoAndPlay("2")
			Std.cast(b.hole).h._visible = true

			//
			
			var bad = Std.cast(b.hole).b
			freeHole(b)
			for( var i=0; i<bList.length; i++ ){
				if( bList[i] == b ){
					bList.splice(i,1)
					if(bList.length==0)setWin(true);					
					break;
				}
			}


			

		}
		

	}
	
	function readyToBlast(){
		flReady = true;
		hammer.skin._visible = true;
		hammer.skin.gotoAndPlay("2")
	}
	
	
//{	
}






