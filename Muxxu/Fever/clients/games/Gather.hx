import Protocole;

class Gather extends Game{//}

	// VARIABLES
	var blobMax:Int;
	var blobRay:Float;
	var ringRay:Float;
	var blowRay:Float;

	var blobList:Array<Phys>;

	// MOVIECLIPS
	var ring:flash.display.MovieClip;

	override function init(dif){
		gameTime = 300;
		super.init(dif);
		blobRay = 10+(dif*5);
		ringRay = 70-dif*10;
		blobMax = 1 + Math.floor(dif*5);
		blowRay = 20;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("gather_bg",0);

		// RING
		ring = dm.attach("mcCenterRing",Game.DP_SPRITE);
		ring.x = Cs.omcw*0.5;
		ring.y = Cs.omch*0.5;
		ring.scaleX = ringRay*0.02;
		ring.scaleY = ringRay*0.02;

		// BLOB
		blobList = new Array();
		for( i in 0...blobMax ){
			var mc = newPhys("mcGatherBlob");
			while(true){
				mc.x = blobRay + Std.random( Math.floor(Cs.omcw-2*blobRay) );
				mc.y = blobRay + Std.random( Math.floor(Cs.omch-2*blobRay) );
				var d = mc.getDist({x:ring.x,y:ring.y});
				if( d >  blobRay + ringRay )break;
			}
			mc.root.scaleX = blobRay*2*0.1;
			mc.root.scaleY = blobRay*2*0.1;
			//mc.flPhys = false;
			mc.root.stop();
			mc.updatePos();
			mc.frict = 0.95;
			blobList.push(mc);
		}


	}

	override function update(){
		switch(step){
			case 1:
				var win = true;
				var p = {x:ring.x,y:ring.y};

				for( mc in blobList ){
					if(this.win==null){

						var d = mc.getDist(p);
						if( d < ringRay - blobRay ) {
							
							swapTo(mc, 2);
							
						}else{
							win = false;
							swapTo(mc, 1);
						}
					}
					checkCol(mc);
					checkBounds(mc);
				}
				if(win && this.win==null) {
					for( mc in blobList ) new mt.fx.Flash(mc.root);
					setWin(true, 20);
				
				}

		}
		//
		super.update();
	}
	
	function swapTo(mc:Sprite, n) {
		if( mc.root.currentFrame != n ){
			mc.root.gotoAndStop(n);
			//new mt.fx.Flash(mc.root);
		}
	}
	

	override function onClick(){

		var p = getMousePos();
		for( mc in blobList ){
			var d = mc.getDist(p);
			var ray = blowRay*2;
			if( d < ray ){
				var a = mc.getAng(p);
				var pow = 10*(ray-d)/ray;
				mc.vx -= Math.cos(a)*pow;
				mc.vy -= Math.sin(a)*pow;
			}
		}

		var mc = newPhys("mcPartBlow");
		mc.x = p.x;
		mc.y = p.y;
		mc.frict = 0.95;
		mc.root.scaleX = blowRay*0.02;
		mc.root.scaleY = blowRay*0.02;
		mc.updatePos();

	}

	function checkBounds(mc:Phys){
		var r = blobRay;
		if( mc.x < r || mc.x > Cs.omcw-r ){
			mc.vx *= -0.8;
			mc.x = Math.min( Math.max( r, mc.x ), Cs.omcw-r );
		}
		if( mc.y < r || mc.y > Cs.omch-r ){
			mc.vy *= -0.8;
			mc.y = Math.min( Math.max( r, mc.y ), Cs.omch-r );
		}

	}

	function checkCol(mc:Phys){
		for(mc2 in blobList ){
			if( mc2 != mc ){
				var d = mc.getDist(mc2);
				if( d < blobRay*2 ){
					var dif = blobRay*2-d;
					var a = mc.getAng(mc2);

					var p = Math.sqrt( mc.vx*mc.vx + mc.vy*mc.vy );
					var p2 = Math.sqrt( mc2.vx*mc2.vx + mc2.vy*mc2.vy );
					var pow = (p+p2)*0.5;

					// RECAL
					mc.x -=	Math.cos(a)*dif*0.5;
					mc.y -=	Math.sin(a)*dif*0.5;

					mc2.x += Math.cos(a)*dif*0.5;
					mc2.y += Math.sin(a)*dif*0.5;

					// FORCE
					mc.vx -= Math.cos(a)*pow;
					mc.vy -= Math.sin(a)*pow;

					mc2.vx += Math.cos(a)*pow;
					mc2.vy += Math.sin(a)*pow;




				}


			}
		}
	}

//{
}






















