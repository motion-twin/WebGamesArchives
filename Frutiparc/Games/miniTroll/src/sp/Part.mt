class sp.Part extends Sprite{//}
	
	var flGrav:bool;
	
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
	//var fadeType:int;
	var fadeTypeList:Array<int>;
		var fadeColor:int;
	
	//var list:Array<sp.Part>
	
	function new(){
		super();

	}
	
	function init(){
		super.init();
		skin._xscale = scale;
		skin._yscale = scale;
		skin._alpha = alpha
	}
	
	function initDefault(){
		super.initDefault();
		vitx = 0;
		vity = 0;
		weight = 1;
		scale = 100;
		alpha = 100;
		fadeTypeList = [0]
		fadeLimit = 10
		flGrav = false
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
		if(flGrav){
			vity += weight*Timer.tmod;
		}
		var frict = Cs.frict;
		if( friction  != null ) frict = friction;
		
		vitx *= frict;
		vity *= frict;
		
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
			vitr *= frict;
			skin._rotation += vitr*Timer.tmod
		}
		
		if( vits != null ){
			vits *= frict;
			scale += vits*Timer.tmod
			skin._xscale = scale;
			skin._yscale = scale;
		}		
		
		if(flKill)kill();
		
		super.update()
	}
	
	function towardSpeed(t,c,lim){
		var dx = t.x - x
		var dy = t.y - y
		vitx += Math.min( Math.max( -lim, dx*c*Timer.tmod ), lim )
		vity += Math.min( Math.max( -lim, dy*c*Timer.tmod ), lim )
	}
	
	// TOOLS
	function orient(){
		skin._rotation = Math.atan2(vity,vitx)/0.0174
	}
	
	
	
	
	
	
//{	
}