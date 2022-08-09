class ac.piou.Liquid extends ac.Piou{//}
	
	var ammo:int;
	var maxHeight:int;

	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		piou.root.gotoAndStop("liquefy")
		ammo = 170
		flExclu = true;
		maxHeight = 2
	}
	
	function update(){
		
		super.update();
		ammo--
		
		var dec = [0]
		for( var i=0; i<4; i++ ){
			for( var n=0; n<2; n++ )dec.push(i*(n*2-1))
		}
		
		
		if( ammo>0 ){
			var px = int(piou.x);
			var py = int(piou.y);
			var flPut = false
			for( var i=0; i<maxHeight; i++ ){
				py-=gs
				for( var dx=0; dx<dec.length; dx++){
					var ddx = dec[dx]
					if(Level.isFree(px+ddx,py)){
						px += ddx;
						flPut = true;
						maxHeight = int( Math.max( maxHeight, i+2 ) )
						break;
					}
				}
				if(flPut)break;
			}			
			if(flPut){
				var sp = new sp.Liquid( attachBuilder("mcPiouPix",0,0,false) );
				piou.updateColor(sp.root);
				sp.sens = piou.sens;
				sp.x = px;
				sp.y = py-1;
			}
		}else{
			piou.die();
			kill();
		}
		
	}
	
	function onReverse(){
		super.onReverse();
		piou.root._yscale = 100*gs
	}


	
//{
}