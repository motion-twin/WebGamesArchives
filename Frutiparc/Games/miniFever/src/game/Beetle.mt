class game.Beetle extends Game{//}

	// CONSTANTE
	var gl:int;
	var bRay:float;
	var gunHeight:int;
	
	// VARIABLES
	var angle:float;
	var bList:Array<{sp:Sprite,sens:int,speed:float}>;
	var nList:Array<float>;
	
	// MOVIECLIPS
	var gun:Sprite;

	function new(){
		super();
	}

	function init(){
		gameTime = 400;
		super.init();
		bRay = 8
		gl = Cs.mch - 8
		angle = 1.57
		gunHeight=80;
		nList = new Array();
		attachElements();

	};
		
	function attachElements(){
	
		// BEETLES
		bList = new Array();
		var max = 2+dif*0.03
		for(var i=0; i<max; i++){
			var sp = newSprite("mcBeetle");
			sp.x = Std.random(Cs.mcw)
			sp.y = gl
			sp.init();
			
			var sens = Std.random(2)*2-1
			sp.skin._xscale = sens*100
			bList.push( { sp:sp, sens:sens, speed:1+i*0.5 } )
		}
		
		// GUN
		gun = newSprite("mcNailLauncher");
		gun.x = Cs.mcw*0.5;
		gun.y = 0//60;
		gun.skin._rotation = 90;
		gun.init();
		
		
	}
	
	function update(){
		switch(step){
			case 1:
				// BEETLE
				for( var i=0; i<bList.length; i++ ){
					var o = bList[i]
					var vit = o.sens*(o.speed+bRay)*Timer.tmod
					for( var n=0; n<nList.length; n++ ){
						var x  = nList[n]
						var nx = o.sp.x+vit
						if(  (o.sp.x-x)/(nx-x) < 0 ){
							o.sens*=-1
							o.sp.skin._xscale = o.sens*100
						}
							}
					o.sp.x += o.sens*o.speed

					
					if( o.sp.x+bRay > Cs.mcw || o.sp.x-bRay < 0 ){
						o.sp.x = Math.min(Math.max(bRay,o.sp.x),Cs.mcw-bRay)
						o.sens*=-1
						o.sp.skin._xscale = o.sens*100
						
					}
				}
				
				// GUN
				//gun.toward( {x:_xmouse,y:0}, 0.1, 100 )
				var dx =_xmouse -  gun.x;
				gun.x += dx*0.2
				angle += dx*0.002
				var da = 1.57-angle
				angle += da*0.25
				gun.skin._rotation = angle/0.0174
				
				if( base.flPress && gun.skin._currentframe == 1 ){
					shoot();
					checkWin();
				}
				
			
			
				break;
		}
		//
		super.update();
	}
	
	function shoot(){
		gun.skin.play();
		
		var ca = Math.cos(angle)
		var sa = Math.sin(angle)
		var sx = gun.x+ca*gunHeight;
		var sy = gun.y+sa*gunHeight;
		
		var ry = gl-sy
		
		var c = ry/Math.cos(angle-1.57)
		var rx = c*Math.sin(angle-1.57)
		
		var nail = newSprite("mcNail")
		nail.x = sx-rx
		nail.y = gl
		nail.init();
		nail.skin._rotation = angle/0.0174
		var mask = dm.attach("mcNailMask",Game.DP_SPRITE)
		mask._x  = nail.x
		mask._y  = nail.y
		nail.skin.setMask(mask)
		
		var index = 0
		for(index=0; index<nList.length; index++){
			if(nList[index]>nail.x)break;
		}
		nList.insert(index,nail.x)
		
		for( var i=0; i<bList.length; i++ ){
			var o = bList[i]
			if( Math.abs(o.sp.x - nail.x) < bRay ){
				dm.over(o.sp.skin)
				o.sp.skin.gotoAndPlay("death")
				bList.splice(i--,1)
				var sp = newSprite("mcBeetleJuice")
				sp.x = nail.x
				sp.y = nail.y
				sp.init();
				setWin(false)
			}
		}	
	}
	
	function checkWin(){
		var x = 0;
		for( var i=0; i<=nList.length; i++ ){
			var nx = nList[i]
			if(nx==null)nx = Cs.mcw;
			var t = 0
			for( var b=0; b<bList.length; b++){
				var o = bList[b]
				if( o.sp.x>x && o.sp.x<nx )t++;
				if(t>1){
					//Log.trace("lost("+i+") ("+x+"<"+o.sp.x+"<"+nx+")")
					return;
				}
			}			
			x = nx
		}
		setWin(true)
	}

	
	
//{	
}

