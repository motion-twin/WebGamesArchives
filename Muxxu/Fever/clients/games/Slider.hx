import mt.bumdum9.Lib;
typedef SliderPod = {>Phys,angle:Float,cd:Float,shadow:flash.display.MovieClip};

class Slider extends Game{//}

	// CONSTANTES
	static var RAY = 12;
	static var BRAY = 8;
	static var WALL = 20;
	static var GRAY = 80;

	// VARIABLES
	var pList:Array<SliderPod>;

	// MOVIECLIPS
	var ball:Phys;

	override function init(dif:Float){
		gameTime = 400;
		super.init(dif);
		timeProof = false;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("slider_bg",0);

		// BALL
		ball = newPhys("mcSliderBall");
		ball.x = Cs.omcw*0.5;
		ball.y = Cs.omcw*0.5;
		ball.updatePos();
		ball.frict = 0.92;

		// SLIDER
		pList = new Array();
		var max = 2+Std.int(dif*9);
		for(  i in 0...max ){
			var sl:SliderPod = cast newPhys("mcSlider");
			if(i<2){
				sl.x = Cs.omcw*0.5+(i*2-1)*40;
				sl.y = Cs.omch*0.5;
			}else{
				sl.x = Cs.omcw-(RAY+WALL);
				sl.y = 40+((i-2)/(max-2))*(GRAY*2) + ((GRAY*2)/(max-1))*0.5;
			}

			sl.angle = 0;
			sl.cd = 0;
			sl.updatePos();
			var frame = "2";
			if(i == 0) frame =  "1";
			getMc(sl.root, "b").gotoAndStop(frame);
			//cast(sl.root).b.gotoAndStop(frame);
			pList.push(sl);

			sl.shadow = dm.attach("mcSliderShadow",Game.DP_SPRITE2);
			sl.shadow.x = sl.x;
			sl.shadow.y = sl.y;
			sl.frict = 0.92;


		}


	}

	override function update(){
		super.update();
		switch(step){
			case 1:
				moveSliders();
				moveBall();

		}


	}

	function moveSliders(){

		//trace("---"+pList.length);
		for( i in 0...pList.length ){
			var sl = pList[i];
			sl.cd--;
			{
				var mp = getMousePos();
				var a = sl.getAng(mp);
				var dist = sl.getDist(mp);

				switch(i){
					case 0:
					case 10,6:
						// CORNER
						var lim = (Cs.omcw*0.5);
						var p = {
							x:Cs.omcw-(RAY+WALL)*1.0,
							y:Num.mm(Cs.omcw*0.5-GRAY,ball.y,Cs.omcw*0.5+GRAY),
						}
						a = sl.getAng(p);
						dist = sl.getDist(p);

						if( sl.cd<0 && ball.x > Cs.omcw-(RAY*2+WALL+6) && Math.abs(ball.y-Cs.omch*0.5) < GRAY ){
							sl.cd = 30;
							var lm = 22;
							sl.vy += Num.mm( -lm, (ball.y-sl.y)*0.5, lm );
						}

					case 8,3:
						// ATTAQUANT
						sl.cd--;
						a = sl.getAng(ball);
						dist = sl.getDist(ball);
						if( Math.abs(a) > 1.7 ){
							if( ball.x > 100 && Math.random()<0.02 && sl.cd<0){
								sl.angle = a;
								sl.cd = 30;
								var sp = 16;
								sl.vx += Math.cos(sl.angle)*sp;
								sl.vy += Math.sin(sl.angle)*sp;
							}
						}else{
							var gp = {x:Cs.omcw,y:Cs.omch*0.5}

							var p = {
								x:ball.x*0.8+gp.x*0.2,
								y:ball.y*0.8+gp.y*0.2,
							}
							a = sl.getAng(p);
							dist = sl.getDist(p);
						}

					default:
						// GARDIEN
						var gp = {x:Cs.omcw,y:Cs.omch*0.5}

						var p = {
							x:(ball.x+gp.x)*0.5,
							y:(ball.y+gp.y)*0.5,
						}
						a = sl.getAng(p);
						dist = sl.getDist(p);
				}


				var da = Num.hMod( a-sl.angle, 3.14);
				var la = 0.5;

				sl.angle += Num.mm( -la, da*0.3, la );
				sl.root.rotation = sl.angle/0.0174;

				var speed = Num.mm( 0, (dist-5)*0.006-Math.abs(da), 0.7 );

				sl.vx += Math.cos(sl.angle)*speed;
				sl.vy += Math.sin(sl.angle)*speed;

				if( i==0 && sl.cd<0 && click ){
					sl.cd = 30;
					var ba = sl.getAng(ball);
					sl.angle = ba;
					var sp = 22;
					sl.vx += Math.cos(sl.angle)*sp;
					sl.vy += Math.sin(sl.angle)*sp;

				}


				sl.root.gotoAndStop(Std.int(speed*40)+1);



			}


			// COL SLIDER
			for( slo in pList ){
				if(slo != sl){
					var dist = sl.getDist(slo);
					if(dist<RAY*2){
						var a = sl.getAng(slo);
						var d = RAY*2-dist;
						sl.x -= Math.cos(a)*d*0.5;
						sl.y -= Math.sin(a)*d*0.5;
						slo.x += Math.cos(a)*d*0.5;
						slo.y += Math.sin(a)*d*0.5;

					}

				}
			}

			// COL BALL
			var dist = sl.getDist(ball);
			if(dist<RAY+BRAY){
				var a = sl.getAng(ball);
				var d = (RAY+BRAY)-dist;
				ball.x += Math.cos(a)*d;
				ball.y += Math.sin(a)*d;



				var cyn1 = Math.sqrt(Math.pow(sl.vx,2)+Math.pow(sl.vy,2));
				var cyn2 = Math.sqrt(Math.pow(ball.vx,2)+Math.pow(ball.vy,2));
				var cyn =cyn1+cyn2;
				//var cyn = Math.min( cyn1+cyn2, 17 )


				var c =   cyn2 / (cyn1+cyn2);

				var a2 = Math.atan2(sl.vy,sl.vx);
				var da = Num.hMod(a-a2,3.14);
				var a3 = (a2+da*c);



				ball.vx += Math.cos(a3)*cyn;
				ball.vy += Math.sin(a3)*cyn;

				var r = 0.1;
				if(i==0) r = 0.75;

				sl.vx -= Math.cos(a3)*cyn*r;
				sl.vy -= Math.sin(a3)*cyn*r;





			}



			//BORDS
			//*
			if(sl.x<RAY ){
				sl.x =  RAY;
				sl.vx = Math.abs(sl.vx);
			}
			if( sl.x>Cs.omcw-(RAY+WALL)){
				sl.x = Cs.omcw-(RAY+WALL);
				sl.vx = -Math.abs(sl.vx);
			}
			/*/

			if(sl.x<RAY || sl.x>Cs.omcw-(RAY+WALL)){
				Log.print("collide ("+sl.x+")")
				sl.x = Num.mm( RAY, sl.x, Cs.omcw-(RAY+WALL) )
				Log.print("-->("+sl.x+")")
				sl.vx*= -1
			}

			//*/
			if(sl.y<RAY || sl.y>Cs.omch-RAY){
				sl.y = Num.mm(RAY,sl.y,Cs.omch-RAY);
				sl.vy*= -1;
			}
			//
			if(sl.cd>0){
				var a = dm.attach("mcSliderShade",Game.DP_SPRITE2);
				a.x = sl.x;
				a.y = sl.y;
				getMc(a,"h").gotoAndStop((i==0)?"1":"2");
			}

			// SHADOW
			sl.shadow.x = sl.x+5;
			sl.shadow.y = sl.y+5;


			// ACTU
			sl.root.x = sl.x;
			sl.root.y = sl.y;



		}






	}

	function moveBall(){




		// BORDS


		if(timeProof){
			if( Math.abs(ball.y-Cs.omch*0.5) > GRAY-BRAY ){
				ball.y = Num.mm(Cs.omcw*0.5-GRAY,ball.y,Cs.omcw*0.5+GRAY);
				ball.vy*= -1;
			}

			ball.vx += 0.5;


			if( ball.x > Cs.omcw+BRAY )setWin(true);

		}else{
			if(ball.x<BRAY  ){
				ball.x = BRAY;
				ball.vx*= -1;
			}

			if( ball.x>Cs.omcw-(BRAY+WALL)  ){
				if( Math.abs(ball.y-Cs.omch*0.5) > GRAY-BRAY ){
					ball.x = Num.mm(BRAY,ball.x,Cs.omcw-(BRAY+WALL));
					ball.vx*= -1;
				}else{
					timeProof = true;
				}


			}

			if(ball.y<BRAY || ball.y>Cs.omch-BRAY ){
				ball.y = Num.mm(BRAY,ball.y,Cs.omcw-BRAY);
				ball.vy*= -1;
			}
		}


		// RECALAGE DE LA VITESSE DE LA BALLE
		var speed = Math.sqrt( Math.pow(ball.vx,2)+ Math.pow(ball.vy,2) );
		var a = Math.atan2(ball.vy,ball.vx);
		speed = Math.min(speed, 20);
		ball.vx = Math.cos(a)*speed;
		ball.vy = Math.sin(a)*speed;



		// ACTU
		ball.root.x = ball.x;
		ball.root.y = ball.y;


	}



//{
}













