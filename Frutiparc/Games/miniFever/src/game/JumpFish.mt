class game.JumpFish extends Game{//}
	
	// CONSTANTES

	// VARIABLES
	var decal:float;
	var speed:float;
	var shadeFrame:float;
	var shadeScale:float;
	var flash:float;
	var size:float;
	var distance:float;
	
	// MOVIECLIPS
	var shade:Sprite;
	var fish:sp.Phys;
	var mask:Sprite;
	var photo:Sprite;
	var bg:MovieClip;
	var fishMask:MovieClip;

	
	function new(){
		super();
	}

	function init(){
		gameTime = 200;
		super.init();
		decal = Std.random(628);
		speed = 4+dif*0.2;
		shadeFrame = 0;
		size = 100-dif*0.4
		attachElements();
	};
	
	function attachElements(){
		// SHADE
		bg = dm.attach("mcFishBg",Game.DP_SPRITE)
		
		// SHADE
		shade = newSprite("mcFishShade")
		shade.skin._alpha  = 0;
		shade.skin.stop();
		shade.init();
		
		// PHOTO
		photo = newSprite("mcFishPhoto")
		photo.x = _xmouse
		photo.y = _ymouse
		photo.skin._xscale = size
		photo.skin._yscale = size
		photo.init();
		photo.skin.stop();
		
	}

	function update(){
		super.update();
		switch(step){
			case 1:
				movePhoto();
				decal = (decal+10*Timer.tmod)%628
				var cx = Cs.mcw*0.5
				var cy = Cs.mch - 20
				var ny = cy + Math.sin(decal/100)*4
				var dy = ny - shade.y
				shade.x = cx + Math.cos(decal/100)*60
				shade.y = ny
				
				shadeScale = 100+(shade.y-cy)*4
				shadeFrame = (shadeFrame+Math.abs(dy*2))%shade.skin._totalframes;
				shade.skin.gotoAndStop(string(Math.round(shadeFrame)+1))
				shade.skin._alpha = Math.min(shade.skin._alpha+Timer.tmod*2,100)
				shade.skin._xscale = shadeScale
				shade.skin._yscale = shadeScale
				
				if( base.gameTimer < 100 ){
					initJump();
				}else if( base.gameTimer < 140 && Std.random(int(100/Timer.tmod))==0 ){
					initJump();
				}
				break;
			case 2:
				movePhoto();
				var a = Math.atan2(fish.vity,fish.vitx)
				fish.skin._rotation = a/0.0174
				if( base.flPress ){
					makePhoto();
				}
				if( fish.y > fishMask._y+fishMask._yscale*0.5){
					plouf(fish.x,fish.y)
					fish.kill();
					fishMask.removeMovieClip();
				}
				
				break;
			case 3:
				flash = Math.min( flash+2*Timer.tmod, 100 )
				Mc.setPColor(Std.cast(this),0xFFFFFF,flash)
				
				if( flash > 98 ){
					setWin(distance<size*0.3)
				}
				
				break;
		}
		//
	
	}
	
	function movePhoto(){
		var c = 0.4
		var dx = _xmouse - photo.x
		var dy = _ymouse - photo.y
		var dr = dx*0.5 - photo.skin._rotation
		photo.x += dx*c*Timer.tmod
		photo.y += dy*c*Timer.tmod
		photo.skin._rotation += dr*c*Timer.tmod
		
		
	}
	
	function initJump(){
	
		step = 2

		plouf(shade.x,shade.y)
		
		// FISH
		fish = newPhys("mcFish")
		fish.weight = 0.3 + dif*0.015
		fish.x = shade.x
		fish.y = shade.y
		
		var tx = Cs.mcw*0.5+Math.random()*60
		var ty = 50+(Math.random()*2-1)*10
		var dx = tx - fish.x
		var dy = ty - fish.y
		var a = Math.atan2(dy,dx)
		var p = 9+Math.random()*3 + dif*0.15
		
		fish.vitx = Math.cos(a)*p
		fish.vity = Math.sin(a)*p
		
		if( fish.vitx<0 ) fish.skin._yscale *= -1;
		shade.kill();
		fish.init();
		
		// FISH MASK
		fishMask = dm.attach("mcFishPhotoMask",Game.DP_SPRITE)
		fishMask._x = Cs.mcw*0.5
		fishMask._y = fish.y*0.5
		fishMask._xscale = Cs.mcw
		fishMask._yscale = fish.y
		fish.skin.setMask(fishMask)
		
	
	}
	
	function makePhoto(){
		step = 3
		flash = 0
		Mc.setPColor(Std.cast(this),0xFFFFFF,flash)

		mask = newSprite("mcFishPhotoMask")
		mask.x = photo.x
		mask.y = photo.y
		mask.skin._rotation = photo.skin._rotation;
		mask.skin._xscale = size
		mask.skin._yscale = size
		mask.init();
		bg.setMask(mask.skin)
		
		photo.skin.gotoAndStop("2")
		dm.over(photo. skin)

		//
		distance = fish.getDist(photo)
		
		// FIGE
		var mc = Std.attachMC(bg,"mcFish",1)
		mc._x = fish.skin._x
		mc._y = fish.skin._y
		mc._rotation = fish.skin._rotation
		mc._yscale = fish.skin._yscale
		mc.gotoAndStop(string(fish.skin._currentframe))
		fish.kill();
		fishMask.removeMovieClip();

		
	
		
	}

	function plouf(x,y){
		// PART
		var mc = newPart("mcPartFishPlouf")
		mc.x = x
		mc.y = y
		mc.flPhys = false;
		mc.init();
		mc.skin._rotation = Math.random()*10	
	}
	
	
//{	
}









