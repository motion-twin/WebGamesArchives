class game.ShakeTree extends Game{//}
	
	// CONSTANTES
	var yBase:float;
	var height:float;
	var groundLevel:float;	
	var ray:float;
	var nbFruit:int;
	
	// VARIABLES
	var angle:float;
	var angleSpeed:float;
	var oldAngle:float;

	var fList:Array< { >sp.Phys, d:float, a:float, lnk:float, flGround:bool } >;
	
	// MOVIECLIPS
	var tronc:Sprite;
	var top:Sprite;
	var dTop:MovieClip;
	var dShade:MovieClip;
	var sky:MovieClip;
	
	function new(){
		
		super();
	}

	function init(){
		gameTime = 320-dif*2
		super.init();
		
		yBase = Cs.mch - 50;
		height = 100;
		ray = 12
		groundLevel = Cs.mch - 12
		
		angle = 0
		oldAngle = 0;
		angleSpeed = 0;
		nbFruit = 8
		
		attachElements();
	};
	
	function attachElements(){

		// DRAW TOP
		dShade = dm.empty(Game.DP_SPRITE)		

		// TRONC
		tronc = newSprite("mcShakeTronc");
		tronc.x = Cs.mcw*0.5;
		tronc.y = yBase;
		tronc.init();
		
		// TOP
		top = newSprite("mcShakeTreeTop");
		top.x = Cs.mcw*0.5;
		top.y = yBase-height;
		top.init();
		
		// DRAW TOP
		dTop = dm.empty(Game.DP_SPRITE)
		
		// FRUITS
		fList = new Array();
		for( var i=0; i<nbFruit; i++ ){
			
			var a = 0;
			var d = 0;
			var t = 0
			do{
				t++
				
				a = -Math.random()*3.14
				d = Math.random()*100
				
				var x = top.x + Math.cos(angle+a)*d
				var y = top.y + Math.sin(angle+a)*d
				
				var flGood = true;
				for(var n=0; n<fList.length; n++ ){
					var f = fList[n]
					var dist = f.getDist({x:x,y:y})
					if( dist < 40-(t*0.1) ){
						flGood = false;
						break;
					}
				}
				if(flGood)break;

			}while(true)
			
			
			var mc = downcast( newPhys("mcShakeApple") )
			mc.flPhys = false;
			mc.flGround = false
			mc.a = a
			mc.d = d
			
			mc.x = top.x + Math.cos(angle+mc.a)*mc.d
			mc.y = top.y + Math.sin(angle+mc.a)*mc.d
			
			mc.lnk = 100+Math.random()*200
			mc.init();
			//TYPE(fList.push)
			fList.push(mc)	// BUG MTYPE
		}
	
		// HERB
		var mc = dm.attach("mcShakeHerb",Game.DP_SPRITE)
		mc._y = Cs.mch
		
	}
	
	function update(){
		super.update();
		switch(step){
			case 1: 
				updateTronc();
				updateFruits()
				oldAngle = angle;
				break;
		}
		//
		
	}
	
	function updateTronc(){
		
		if(flTimeProof){
			angleSpeed -= angle*0.2
			angleSpeed *= Math.pow(0.95,Timer.tmod)
			angle += angleSpeed
		}else{
			angle = Math.min(Math.max(0,_xmouse/Cs.mcw),1)-0.5
		}
		
		var ex = tronc.x + Math.cos(angle-1.57)*height
		var ey = tronc.y + Math.sin(angle-1.57)*height
		
		dTop.clear();
		dTop.lineStyle( 36, 0x73522B, 100 )
		dTop.moveTo( tronc.x, tronc.y )
		dTop.curveTo( tronc.x, tronc.y-height*0.5, ex, ey )
		
		dShade.clear();
		dShade.lineStyle( 40, 0x000000, 100 )
		dShade.moveTo( tronc.x, tronc.y )
		dShade.curveTo( tronc.x, tronc.y-height*0.5, ex, ey )		
		
		top.skin._rotation = angle/0.0174
		top.x = ex
		top.y = ey
		
	}
	
	function updateFruits(){
		var da = oldAngle-angle
		//Log.clear();
		
		var flFreeTree = true;
		
		for( var i=0; i<fList.length; i++ ){
			var mc = fList[i]
			
			if( mc.lnk > 0 ){
				flFreeTree = false;
				mc.x = top.x + Math.cos(angle+mc.a)*mc.d
				mc.y = top.y + Math.sin(angle+mc.a)*mc.d
				mc.lnk -= Math.abs(da)*10
				//Log.trace(mc.lnk)
				if( mc.lnk < 0 ){
					mc.flPhys = true;
					mc.vitx += da*10
				}
				
			}else{
				
				if( mc.y > groundLevel-ray ){
					mc.y = groundLevel-ray;
					mc.vity *= -0.5
					if( mc.flGround != true ){
						nbFruit --;
					}
					mc.flGround = true;
				}
			}
			
			mc.skin._x = mc.x
			mc.skin._y = mc.y
			
			
		}
		
		if( !flTimeProof && flWin == null && flFreeTree ){
			flTimeProof = true;
			sky.play();
		}
		
		if( nbFruit == 0 ){
			
			setWin(true);
		}
		
	}
	
	
	
	
		
	
	
	
//{	
}









