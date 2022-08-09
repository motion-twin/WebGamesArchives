class game.Gather extends Game{//}

	
	// VARIABLES
	var blobMax:int;
	var blobRay:float;
	var ringRay:float;
	var blowRay:float
	
	var blobList:Array<sp.Phys>
	
	// MOVIECLIPS
	var ring:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 300;
		super.init();

		blobRay = 10+(dif*0.05)
		ringRay = 70//80-(dif*0.2)
		blobMax = 1 + Math.floor(dif*0.05)
		blowRay = 20
		
		attachElements();
		
	};
	
	function initDefault(){
		super.initDefault();
		airFriction = 0.95
		
	}
	
	function attachElements(){
		// RING
		ring = dm.attach("mcCenterRing",Game.DP_SPRITE)
		ring._x = Cs.mcw*0.5
		ring._y = Cs.mch*0.5
		ring._xscale = ringRay*2
		ring._yscale = ringRay*2
		
		// BLOB
		blobList = new Array();
		for( var i=0; i<blobMax; i++ ){
			var mc = newPhys("mcGatherBlob");
			while(true){
				mc.x = blobRay + Std.random( Math.floor(Cs.mcw-2*blobRay) ) 
				mc.y = blobRay + Std.random( Math.floor(Cs.mch-2*blobRay) )
				var d = mc.getDist({x:ring._x,y:ring._y});
				if( d >  blobRay + ringRay )break;
			}
			mc.skin._xscale = blobRay*2*10
			mc.skin._yscale = blobRay*2*10
			mc.flPhys = false;
			mc.skin.stop();
			mc.init();
			blobList.push(mc)
		}
		
		
	}
	
	function update(){
		switch(step){
			case 1:
					
				var win = true;
				var p = {x:ring._x,y:ring._y}
				
				for( var i=0; i<blobList.length; i++ ){
					var mc = blobList[i]
					if(flWin==null){
						
						var d = mc.getDist(p);
						if( d < ringRay-blobRay ){
							mc.skin.gotoAndStop("2")
						}else{
							win = false
							mc.skin.gotoAndStop("1")						
						}
					}
					checkCol(mc)
					checkBounds(mc)
				}
				
				if(win)setWin(true);
				
				break;
		}
		//
		super.update();
	}
	
	function click(){
		var p = {x:this._xmouse,y:this._ymouse}
		for( var i=0; i<blobList.length; i++ ){
			var mc = blobList[i]
			
			var d = mc.getDist(p);
			var ray = blowRay*2
			if( d < ray ){
				var a = mc.getAng(p)
				var pow = 10*(ray-d)/ray
				mc.vitx -= Math.cos(a)*pow
				mc.vity -= Math.sin(a)*pow						
			}
		}
		
		var mc = newPart("mcPartBlow")
		mc.x = p.x
		mc.y = p.y
		mc.flPhys = true;
		mc.skin._xscale = blowRay*2
		mc.skin._xscale = blowRay*2
		mc.init();
		
	}
	
	function checkBounds(mc){
		var r = blobRay
		if( mc.x < r || mc.x > Cs.mcw-r ){
			mc.vitx *= -0.8
			mc.x = Math.min( Math.max( r, mc.x ), Cs.mcw-r )
		}
		if( mc.y < r || mc.y > Cs.mch-r ){
			mc.vity *= -0.8
			mc.y = Math.min( Math.max( r, mc.y ), Cs.mch-r )
		}		
		
	}
	
	function checkCol(mc){
		for( var i=0; i<blobList.length; i++ ){
			var mc2 = blobList[i]
			if( mc2 != mc ){
				var d = mc.getDist(mc2)
				if( d < blobRay*2 ){
					var dif = blobRay*2-d
					var a = mc.getAng(mc2)
					
					var p = Math.sqrt( mc.vitx*mc.vitx + mc.vity*mc.vity )
					var p2 = Math.sqrt( mc2.vitx*mc2.vitx + mc2.vity*mc2.vity )
					var pow = (p+p2)*0.5 
					
					// RECAL
					mc.x -=	Math.cos(a)*dif*0.5
					mc.y -=	Math.sin(a)*dif*0.5
					
					mc2.x += Math.cos(a)*dif*0.5
					mc2.y += Math.sin(a)*dif*0.5
					
					// FORCE
					mc.vitx -= Math.cos(a)*pow
					mc.vity -= Math.sin(a)*pow

					mc2.vitx += Math.cos(a)*pow
					mc2.vity += Math.sin(a)*pow


					
					
				}
				
				
			}
		}
	}
		
//{	
}






















