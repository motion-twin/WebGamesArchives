
class Dart extends Game{//}

	// CONSTANTES
	var ray:Array<Int>;

	// VARIABLES
	var bp:{x:Float,y:Float,vx:Float,vy:Float};
	var timer:Null<Float>;

	// MOVIECLIPS
	var rt:Sprite;
	var hand:Sprite;
	var trg:Sprite;


	override function init(dif){

		gameTime = 300;
		super.init(dif);
		ray = [30,20,10];

		var a = Math.random()*6.28;
		var sp = 5+dif*13;

		bp = {
			x:Math.random()*Cs.omcw,
			y:Math.random()*Cs.omch,
			vx:Math.cos(a)*sp,
			vy:Math.sin(a)*sp,
		}
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("dart_bg",0);

		// TARGET
		rt = cast newSprite("McRoundTarget");
		rt.x = Cs.omcw*0.5;
		rt.y = Cs.omch*0.5;
		var fr= Math.round(dif*2)+1;
		if( fr > 3 ) fr = 3;
		var mc:McRoundTarget = cast(rt.root);
		mc.center.gotoAndStop( fr );
		rt.updatePos();

		// TARGET
		trg  = newSprite("mcWhiteTarget");
		trg.x = Cs.omcw*0.5;
		trg.y = Cs.omch*2;
		trg.updatePos();
		
		
		// HOLES
		var max = 140;
		for( i in 0...max ) {
			var a = i / max * 6.28;
			var dist = 72 + Math.pow( Math.random(), 2 ) * 30;
			var mc = new McDartHole();
			bg.addChild(mc);
			mc.x = rt.x + Math.cos(a)*dist;
			mc.y = rt.y + Math.sin(a)*dist;
		}
		

		// HAND
		attachHand();

	}

	function attachHand(){
		hand = newSprite("McDartHand");
		hand.x = Cs.omcw*0.5;
		hand.y = Cs.omch*0.75;
		hand.updatePos();

	}


	override function update(){
		super.update();
		switch(step){
			case 1:
				var m = getMousePos();


				// BALL
				bp.x += bp.vx;
				bp.y += bp.vy;

				if( bp.x<0 || bp.x>Cs.omcw ){
					bp.vx*=-1;
					bp.x = Math.min(Math.max(0,bp.x),Cs.omcw);
				}
				if( bp.y<0 || bp.y>Cs.omch ){
					bp.vy*=-1;
					bp.y = Math.min(Math.max(0,bp.y),Cs.omch);
				}

				// TRG
				trg.x = (m.x+bp.x)*0.5;
				trg.y = (m.y+bp.y)*0.5;
				hand.toward(trg,0.1,null);

				//if( click ) onClick();
				
			case 2:
				hand.y += 33;
				hand.root.scaleX *= 0.85;
				hand.root.scaleY = hand.root.scaleX;
				hand.root.rotation -= 10;
				if(hand.y>Cs.omch+300)hand.kill();
				if(timer!=null){
					timer--;
					if(timer<0){
						step = 1;
						trg.root.visible = true;
						attachHand();
					}
				}

		}
		//

	}



	override function onClick(){
		super.onClick();
		
		if(step==1){
			step = 2;
			trg.root.visible = false;
			
			var mc:McDartHand = cast(hand.root);
			mc.dart.visible = false;
			
			var mc = dm.attach("mcDart",Game.DP_SPRITE);
			mc.x = trg.x;
			mc.y = trg.y;

			if( trg.getDist(rt) < ray[Math.round(dif*2)] ) {
				setWin( true, 15 );
				timer = null;
			} else {
				timer = 32;
			}

		}

	}



//{
}

