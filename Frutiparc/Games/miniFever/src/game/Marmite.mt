class game.Marmite extends Game{//}
	
	// CONSTANTES
	var rx:int;
	var ry:int;
	
	// VARIABLES
	var ingMax:int;
	var speed:float;
	var decal:float;
	var bookPos:int;
	var ingList:Array<sp.Phys>
	var fallList:Array<{mc:sp.Phys,mask:MovieClip}>
	var recette:Array<int>
	
	
	var center:{x:float,y:float};
	
	
	// MOVIECLIPS
	var book:Sprite;
	var bZone:{>MovieClip,dm:DepthManager};
	
	function new(){
		super();
	}

	function init(){
		//dif = 100
		gameTime = 460;
		super.init();
		rx = 100
		ry = 60		
		ingMax = 9//6+Math.floor(dif*0.05)

		decal = 0
		speed = 0;
		
		fallList = new Array();
		center = { x:Cs.mcw*0.5, y:0 }
		bookPos = Cs.mch
		
		initRecette();
		attachElements();
	
		
	};
	
	function initRecette(){
		recette = new Array();
		var a = new Array();
		for( var i=0; i<ingMax; i++ )a.push(i);
		var max = 1+(dif*0.08)//Math.round(ingMax*(0.5+dif*0.005))
		for( var i=0; i<max; i++ ){
			var index = Std.random(a.length)
			recette.push(a[index])
			a.splice(index,1)
		}
	}
	
	function attachElements(){

		// BUBBLE ZONE
		bZone = downcast(dm.empty(Game.DP_SPRITE))
		bZone.dm = new DepthManager(bZone)
		bZone._x = 120
		bZone._y = 144
		
		var mask = dm.attach("mcMarmiteMask",Game.DP_PART)
		bZone.setMask(mask)	
		
		// INGREDIENTS
		ingList = new Array();
		for( var i=0; i<ingMax; i++ ){
			var mc = newPhys("mcIngredient")
			mc.x = Cs.mcw*0.5
			mc.y = 0
			mc.skin.gotoAndStop(string(i+1))
			mc.init();
			mc.flPhys = false;
			ingList.push(mc)			
		}
		
		// BOOK
		book = newSprite("mcRecetteBook")
		book.x = Cs.mcw*0.5
		book.y = bookPos
		book.init();
		var page = Std.cast(book.skin).page
		
		var s = 24
		var lim = 4
		for( var i=0; i<recette.length; i++ ){
			var mc = Std.attachMC( page, "mcIngredient", i )
			mc._x = 16 + (i%lim)*s
			mc._y = 30 + Math.floor(i/lim)*s
			mc._xscale = 50
			mc._yscale = 50
			mc._alpha = 75
			
			mc.gotoAndStop(string(recette[i]+1))
			//Log.trace(mc)
		}
		

	 	
		
		//ball = newPhys("mcPongBall")

		
	}

	function update(){
		
		switch(step){
			case 1: 
				
				
				if( _ymouse > Cs.mch*0.5 ){
					center.y = -100
					bookPos = Cs.mch
				}else{
					center.y = 0
					bookPos = Cs.mch+100
				}

				
				// DEPLACE LES INGREDIENT
				
				//*
				var speed = (_xmouse-Cs.mcw*0.5)*0.3
				decal = (decal+speed*Timer.tmod)%628
				/*/
				speed += (_xmouse-Cs.mcw*0.5)*0.02
				speed *= Math.pow(0.95,Timer.tmod)
				decal = (decal+speed*Timer.tmod)%628
			
				//*/
				for(var i=0; i<ingList.length; i++){
					var a = (decal/100) + (i/ingList.length)*6.28
					var x  = center.x + Math.cos(a)*rx
					var y  = center.y + Math.sin(a)*ry
					var mc = ingList[i]
					var dx = x - mc.x
					var dy = y - mc.y
					mc.x += dx*0.2*Timer.tmod
					mc.y += dy*0.2*Timer.tmod
				}
				
				// DEPLACE LE BOOK
				var dy = bookPos - book.y
				book.y += dy*0.2*Timer.tmod
							

				// FALL
				for( var i=0; i<fallList.length; i++ ){
					var info = fallList[i]
					
					if( info.mc.y > 190 ){
						var id = info.mc.skin._currentframe-1
						if(  id == recette[0] ){
							recette.shift();
							if(recette.length==0){
								setWin(true)
							}
							
						}else{
							setWin(false)
						}
						
						info.mask.removeMovieClip();
						info.mc.kill();
						fallList.splice(i,1)
						i--;
					}
				}
				
				// BUBBLE
				updateBubble();
				
				
				break;

		}
		//
		super.update();
	}
	// McPartMarmiteBubble
	
	function updateBubble(){
		
		if( Std.random(1) == 0){
			var b = newPart("mcPartMarmiteBubble");
			
			b.skin.removeMovieClip();
			b.setSkin(bZone.dm.attach("mcPartMarmiteBubble",1))

			var a = Math.random()*6.28
			var d = Math.random()*55
			b.x = Math.cos(a)*d
			b.y = Math.sin(a)*d*0.3
			b.flPhys = false
			b.scale = 50+Math.random()*100
			b.init();
			

		}
		
	}
	
	function click(){
		if( step ==1 ){
			var mc = getBottom()
			if( mc != null ){
				mc.flPhys = true;
				var mask = dm.attach("mcMarmiteMask",Game.DP_SPRITE)
				mc.skin.setMask(mask)
				fallList.push({mc:mc,mask:mask})
				
				
				var ec = ( (1/(ingList.length-1))-(1/ingList.length) )*628
				decal+=ec*0.5
				
				for(var i=0; i<ingList.length; i++){
					if(ingList[i]==mc){
						ingList.splice(i,1)
						break;
					}
				}
				
			}		
		}
	}

	function getBottom(){
		var dx = 50
		var bot = null
		for( var i=0; i<ingList.length; i++ ){
			var mc = ingList[i]
			var d = Math.abs(mc.x - Cs.mcw*0.5)
			if( d < dx && mc.y>0){
				dx = d
				bot = mc
			}
		}
		return bot;
		
		
	}
	
	
	
//{	
}












