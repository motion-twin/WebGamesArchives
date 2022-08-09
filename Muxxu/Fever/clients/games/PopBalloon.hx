import mt.bumdum9.Lib;

class PopBalloon extends Game{//}



	// CONSTANTES
	static var RAY = 16;
	// VARIABLES
	var wCount:Int;
	var wind:Null<Float>;
	var wx:Float;
	var wy:Float;
	var bList:Array<Phys>;
	var wList:Array<Phys>;
	var next:Phys;

	// MOVIECLIPS

	override public function init(dif){
		gameTime = 240;
		dif = 1.0;
		super.init(dif);
		
		wCount = 1;
		attachElements();
		selectNext();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("popballoon_bg",0);


		// BALLON
		var cs = 1;
		var ray = 30*cs;
		var speed = 0.1 + dif*0.3;
		var p = {
			va:0.0,
			a:Math.random()*6.28,
			x:Cs.omcw-2.0*ray,
			y:Cs.omch-2.0*ray,
		}

		var max = Std.int(8+dif*18);
		bList = [];
		for( i in 0...max ){

			var sp = newPhys("mcBalloon");
			var a = Math.random()*6.28;
			sp.x = p.x;
			sp.y = p.y;
			sp.vx += Math.cos(a)*Math.random()*speed;
			sp.vy += Math.sin(a)*Math.random()*speed;
			sp.root.stop();
			sp.updatePos();

			bList.push(sp);

			p.va += (Std.random(2)*2-1)*0.25;
			p.va *= 0.9;
			p.a += p.va;
			var vx = Math.cos(p.a)*ray;
			var vy = Math.sin(p.a)*ray;
			p.x += vx;
			p.y += vy;

			if( p.x < ray || p.x > Cs.omcw-ray ){
				p.x = Num.mm( ray, p.x, Cs.omcw-ray );
				vx *= -1;
				p.a = Math.atan2(vy,vx);
			}
			if( p.y < ray || p.y > Cs.omch-ray ){
				p.y = Num.mm( ray, p.y, Cs.omch-ray );
				vy *= -1;
				p.a = Math.atan2(vy,vx);
			}
		}
	}

	override function update(){
		switch(step){
			case 1:
				// CHECK HIT
				var mp = getMousePos();
				var d = next.getDist(mp);
				if( d < RAY ){
					var p = newPhys("partBalloonBurst");
					p.x = next.x;
					p.y = next.y;
					p.root.rotation = Math.random() * 360;
					p.timer = 6;
					p.fadeType = -1;
					p.updatePos();

					next.kill();
					bList.pop();
					if(bList.length>0){
						selectNext();
					}else{
						next = null;
						setWin(true, 15);
						step = 2;
					}

				}

				// CHECK COL
				for( b in bList ){
					if( b.x < RAY || b.x > Cs.omcw-RAY ){
						b.x = Num.mm( RAY, b.x, Cs.omcw-RAY );
						b.vx *= -1;
					}
					if( b.y < RAY || b.y > Cs.omch-RAY ){
						b.y = Num.mm( RAY, b.y, Cs.omch-RAY );
						b.vy *= -1;

					}
				}

				// WIND
				if(wind == null ){
					if( Std.random(  Std.int((30-dif*10)*wCount)  )==0 ){
						wind = 0;
						var a = Math.random()*6.28;
						var speed = 0.4+dif*1.5;
						wx = Math.cos(a)*speed;
						wy = Math.sin(a)*speed;
						wList = bList.copy();
						wCount++;
					}
				}else{
					wind += 10;
					var a = wList.copy();
					for( b in a ){
						if( b.x+b.y < wind ){
							b.vx += wx;
							b.vy += wy;
							wList.remove(b);
						}
					}
					if(wList.length == 0 )wind = null;
				}

		}
		super.update();
	}





	function selectNext(){
		next = bList[bList.length-1];
		next.root.gotoAndStop(2);
	}



//{
}

