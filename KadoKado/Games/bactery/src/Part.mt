class Part{//}
	
	var x:float;
	var y:float;
	var vitx:float;
	var vity:float;
	var vitr:float;
	var vits:float;
	var timer:float;
	
	var sleep:float;
	var weight:float;
	
	var friction:float;
	var scale:float;
	var alpha:float;
	var fadeLimit:float;
	
	var skin:MovieClip;

	var fadeTypeList:Array<int>;
		var fadeColor:int;

	var game:Game;
	
	function new(){
		x = 0;
		y = 0;
		vitx = 0;
		vity = 0;
		scale = 100;
		alpha = 100;
		fadeTypeList = [0]
		fadeLimit = 10		
	}
	
	function init(){

		
		skin._xscale = scale;
		skin._yscale = scale;
		skin._alpha = alpha
	}
	
	
	function setSkin(mc){
		skin = mc;
		downcast(mc).obj = this;
	}
	
	function update(){
		if(sleep!=null){
			sleep-=Timer.tmod;
			if(sleep<0){
				skin._visible = true;
				sleep = null;
			}
			return;
		}
		
		var flKill = false;
		if(weight!=null){
			vity += weight*Timer.tmod;
		}
		
		if( friction  != null ){
			vitx *= friction;
			vity *= friction;
		}
		
		x += vitx*Timer.tmod;
		y += vity*Timer.tmod;
		
		if( timer != null ){
			timer -= Timer.tmod
			if( timer < 0 ){
				flKill = true
			}else if( timer < fadeLimit){
				var c  = timer/fadeLimit
				for(var i=0; i<fadeTypeList.length; i++){
					var fadeType = fadeTypeList[i]
					switch( fadeType){
						case 0:
							skin._xscale = c*scale;
							skin._yscale = c*scale;
							break;
						case 1:
							skin._alpha = c*alpha;
							break;
						case 2:
							Mc.setPercentColor(skin,100-c*100,fadeColor)
							break;
						case 3:	// BIGGIFY
							skin._xscale = scale*(2-c)
							skin._yscale = scale*(2-c)						
							break;
						case 4: // YSCALE ONLY
							skin._yscale = c*scale;						
							break;						
					}
				}
			}
		}
		
		if( vitr != null ){
			if( friction  != null )vitr *= friction;
			skin._rotation += vitr*Timer.tmod
		}
		
		if( vits != null ){
			if( friction  != null )vits *= friction;
			scale += vits*Timer.tmod
			skin._xscale = scale;
			skin._yscale = scale;
		}		
		
		if(flKill)kill();
		
		skin._x = x
		skin._y = y
		
	
	}
	
	// TOOLS
	function orient(){
		skin._rotation = Math.atan2(vity,vitx)/0.0174
	}
	
	
	function kill(){
		for( var i=0; i<game.pList.length; i++ ){
			if(game.pList[i]==this){
				game.pList.splice(i,1)
				break;
			}
		}
		skin.removeMovieClip();
	}
	

	
//{	
}