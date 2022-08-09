class game.Apple extends Game{//}
	
	// CONSTANTES

	// VARIABLES
	var fil:{x:float,y:float,max:float}
	var depthRun:int;
	var ray:float;
	var crunchSize:float;
	
	
	// MOVIECLIPS
	var mcFil:MovieClip;
	var mask:MovieClip;
	var crunchZone:MovieClip;
	var sky:MovieClip;
		var trognon:MovieClip;
	var apple:sp.Phys;

	function new(){
		super();
	}

	function init(){
		gameTime = 350-dif*2.5;
		super.init();
		fil = { 
			x: Cs.mcw*0.5,
			y: 0,//- Cs.mch*0.5,
			max: Cs.mch*0.5
		}
		ray = 50
		crunchSize = 50;
		depthRun = 0;
		attachElements();
	};
	
	function initDefault(){
		super.initDefault()
		airFriction = 0.97
	}
	
	function attachElements(){
		

		
		// APPLE
		apple = newPhys("mcApple")
		apple.x = Cs.mcw*0.5;
		apple.y = -ray//Cs.mch*0.5;
		apple.skin._xscale = ray*2
		apple.skin.gotoAndStop("1")
		apple.init();
		var me = this
		apple.skin.onPress = fun(){
			me.crunch();
		}
		crunchZone = Std.attachMC( apple.skin, "mcApple", 1 )
		crunchZone.gotoAndStop("3")
		crunchZone._alpha = 0;
		
		// SKY
		sky = dm.attach( "mcAppleSky", Game.DP_SPRITE )
		trognon = Std.attachMC( sky, "mcApple", 1 )
		trognon._x = apple.x
		trognon._y = apple.y
		trognon._xscale = ray*2
		trognon._yscale = ray*2
		trognon.gotoAndStop("2")

		// MASK
		mask = dm.attach( "mcAppleMask", Game.DP_SPRITE ) //newSprite("mcAppleMask")
		mask._x = apple.x
		mask._y = apple.y
		mask._xscale = ray*2
		mask._yscale = ray*2

		// MCFIL
		mcFil = dm.empty(Game.DP_SPRITE )
		sky.setMask(mask)
	
		
	}
	
	function update(){
		super.update();
		switch(step){
			case 1:
				//* FIL

				var dist = apple.getDist(fil)
				apple.y += ray				// TRES TRES SALE
				var a = apple.getAng(fil)
				apple.y -= ray				// TRES TRES SALE
				
				if( dist > fil.max) {
					var c = (dist-fil.max)/fil.max
					//var c = dist/fil.max
					
					var p = 4

					apple.vitx +=  Math.cos(a)*c*p
					apple.vity +=  Math.sin(a)*c*p
					
				}
				
				apple.skin._rotation = a/0.0174 + 90

				// DRAW
				var x = apple.x + Math.cos(a)*ray
				var y = apple.y + Math.sin(a)*ray
				
				var fall = Math.min( 0, fil.max-dist )*0.5
				
				var mx = (fil.x+x)*0.5
				var my = (fil.y+y)*0.5
				
				
				mcFil.clear();
				mcFil.lineStyle(4,0x448800,100)
				mcFil.moveTo(fil.x,fil.y-ray)

				mcFil.curveTo(mx,my+fall,x,y)
				
				//*/
			
			
			
			break;

		}
		//
		
		
		mask._x = apple.x;
		mask._y = apple.y;
		mask._rotation = apple.skin._rotation
		trognon._x = apple.x;
		trognon._y = apple.y;
		trognon._rotation = apple.skin._rotation		
		
	}
	
	function crunch(){
		
		// PARTICULE
		for( var i=0; i<8; i++ ){
			
			
			var a = Std.random(628)/100
			var p = 1+Std.random(10)
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			
			var x = apple.x + apple.skin._xmouse + ca*p*2.5
			var y = apple.y + apple.skin._ymouse + sa*p*2.5
			
			if( crunchZone.hitTest(x,y,true) && !sky.hitTest(x,y,true) ){
				var mc = newPart("mcPartAppleCrunch")
				mc.x = x
				mc.y = y
				mc.vitx = ca*p
				mc.vity = sa*p
				mc.vitr = Math.random()*20
				mc.skin._rotation = a/0.0174
				mc.init();
				mc.skin.gotoAndStop(string(Std.random(mc.skin._totalframes)+1))
			}
		}

		// ATTACH CRUNCH
		var mc = Std.attachMC( mask, "mcAppleCrunch", depthRun++)
		mc._x = apple.skin._xmouse
		mc._y = apple.skin._ymouse
		mc._xscale = crunchSize;
		mc._yscale = crunchSize;
		
		var m = {x:this._xmouse,y:_ymouse}
		var a = apple.getAng(m)
		var p = 14
		apple.vitx -= Math.cos(a)*p
		apple.vity -= Math.sin(a)*p
		
		// CHECK END
		var tol = 0
		for( var i=0; i<50; i++ ){
			var d = Std.random(Math.round(ray))
			var an = Std.random(628)/100
			var x = apple.x + Math.cos(an)*d
			var y = apple.y + Math.sin(an)*d
			if( crunchZone.hitTest(x,y,true) && !sky.hitTest(x,y,true) ){
				tol++
				if( tol > 2 )return;
			}
		}
		
		setWin(true)
		
		
	}
	

	
	
//{	
}






















