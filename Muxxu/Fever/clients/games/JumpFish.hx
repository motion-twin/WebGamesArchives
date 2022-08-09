import mt.bumdum9.Lib;

class JumpFish extends Game{//}

	// CONSTANTES

	// VARIABLES
	var decal:Float;
	var speed:Float;
	var shadeFrame:Float;
	var shadeScale:Float;
	var flash:Float;
	var size:Float;
	var distance:Float;

	// MOVIECLIPS
	var shade:Sprite;
	var fish:Phys;
	var spMask:Sprite;
	var photo:Sprite;
	var fishMask:flash.display.MovieClip;


	override function init(dif){
		gameTime = 200;
		super.init(dif);
		decal = Std.random(628);
		speed = 4+dif*15;
		shadeFrame = 0;
		size = 100-dif*40;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		var mc = dm.attach("jumpfish_bg",0);

		// SHADE
		bg = dm.attach("mcFishBg",Game.DP_SPRITE);

		// SHADE
		shade = newSprite("mcFishShade");
		shade.root.alpha  = 0;
		shade.root.stop();
		shade.updatePos();

		// PHOTO
		photo = newSprite("mcFishPhoto");

		photo.root.scaleX = size*0.01;
		photo.root.scaleY = size*0.01;
		photo.updatePos();
		photo.root.stop();

	}

	override function update(){
		super.update();
		switch(step){
			case 1:
				movePhoto();
				decal = (decal+10)%628;
				var cx = Cs.omcw*0.5;
				var cy = Cs.omch - 20;
				var ny = cy + Math.sin(decal/100)*4;
				var dy = ny - shade.y;
				shade.x = cx + Math.cos(decal/100)*60;
				shade.y = ny;

				shadeScale = 100+(shade.y-cy)*4;
				shadeFrame = (shadeFrame+Math.abs(dy*2))%shade.root.totalFrames;
				shade.root.gotoAndStop(Math.round(shadeFrame)+1);
				shade.root.alpha = Math.min((shade.root.alpha+0.02),1);
				shade.root.scaleX = shadeScale*0.01;
				shade.root.scaleY = shadeScale*0.01;

				if( gameTime < 100 ){
					initJump();
				}else if( gameTime < 140 && Std.random(Std.int(100))==0 ){
					initJump();
				}

			case 2:
				movePhoto();
				
				if( fish!=null ){
					var a = Math.atan2(fish.vy,fish.vx);
					fish.root.rotation = a / 0.0174;
				}
				
				if( click )makePhoto();
				
				
				if( fish!= null && fish.y > fishMask.y+fishMask.scaleY*50){
					plouf(fish.x,fish.y);
					fish.kill();
					fishMask.parent.removeChild(fishMask);
					fish = null;
				}
				


			case 3:
				flash = Math.min( flash+2, 100 );
				Col.setPercentColor(box,1-flash*0.01,0xFFFFFF );
		
				if( flash > 40 )setWin(distance<size*0.3, 20);


		}
		//

	}

	function movePhoto(){
		var c = 0.4;
		var mp  = getMousePos();
		var dx = mp.x - photo.x;
		var dy = mp.y - photo.y;
		var dr = dx*0.5 - photo.root.rotation;
		photo.x += dx*c;
		photo.y += dy*c;
		photo.root.rotation += dr*c;


	}

	function initJump(){

		step = 2;

		plouf(shade.x,shade.y);

		// FISH
		fish = newPhys("mcFish");
		fish.weight = 0.3 + dif*1.2;
		fish.x = shade.x;
		fish.y = shade.y;

		var tx = Cs.omcw*0.5+Math.random()*60;
		var ty = 50+(Math.random()*2-1)*10;
		var dx = tx - fish.x;
		var dy = ty - fish.y;
		var a = Math.atan2(dy,dx);
		var p = 9+Math.random()*3 + dif*12;

		fish.vx = Math.cos(a)*p;
		fish.vy = Math.sin(a)*p;

		if( fish.vx<0 ) fish.root.scaleY *= -1;
		shade.kill();
		fish.updatePos();

		// FISH MASK
		fishMask = dm.attach("mcFishPhotoMask",Game.DP_SPRITE);
		fishMask.x = Cs.omcw*0.5;
		fishMask.y = fish.y*0.5;
		fishMask.scaleX = Cs.omcw*0.01;
		fishMask.scaleY = fish.y*0.01;
		fish.root.mask = fishMask;


	}

	function makePhoto(){
		step = 3;
		flash = 0;
		Col.setPercentColor(box,1-flash*0.01,0xFFFFFF);
		//Mc.setPColor(Std.cast(this),0xFFFFFF,flash)

		spMask = newSprite("mcFishPhotoMask");
		spMask.x = photo.x;
		spMask.y = photo.y;
		spMask.root.rotation = photo.root.rotation;
		spMask.root.scaleX = size*0.01;
		spMask.root.scaleY = size*0.01;
		spMask.updatePos();
		bg.mask = spMask.root;

		photo.root.gotoAndStop(2);
		dm.over(photo.root);

		//
		distance = 9999;
		if( fish == null ) return;
		distance = fish.getDist(photo);

		// FIGE
		var mc = new mt.DepthManager(bg).attach("mcFish",1);
		mc.x = fish.root.x;
		mc.y = fish.root.y;
		mc.rotation = fish.root.rotation;
		mc.scaleY = fish.root.scaleY;
		mc.gotoAndStop(Std.string(fish.root.currentFrame));
		fish.kill();
		fishMask.parent.removeChild(fishMask);

		//
		//setWin(distance<size*0.3, 40);



	}

	function plouf(x,y){
		// PART
		var mc = newPhys("mcPartFishPlouf");
		mc.x = x;
		mc.y = y;
		mc.updatePos();
		mc.root.rotation = Math.random()*10;
	}


//{
}









