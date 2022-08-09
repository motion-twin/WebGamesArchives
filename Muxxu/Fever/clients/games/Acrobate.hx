typedef AAcrobate = {>Phys,step:Int,sens:Int,side:Int,pos:Null<Int>,flReject:Bool}

class Acrobate extends Game{//}

	// CONSTANTES
	static var INTERVAL = 48; //50
	static var GL = 220;
	static var RAY = 10;
	static var DX = 70;
	static var DRAY = 17;
	static var RUN = 3;
	static var POWER = 8;

	// VARIABLES
	var objectif:Int;
	var qdec:Float;
	var decal:Float;
	var timer:Float;
	var last:Null<Int>;
	var aList:Array<AAcrobate>;

	// MOVIECLIPS
	var dalle:flash.display.MovieClip;
	var arrow:flash.display.MovieClip;


	override function init(dif:Float){
		gameTime = 500;
		super.init(dif);
		aList = new Array();
		timer = 0;
		qdec = 0;
		objectif = 1+Math.floor(dif*8.5);
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("acrobate_bg",0);

		dalle = cast(bg).dalle;

		// DALLE
		dalle.x = DX;
		//
		var y =  -18;
		var d = new mt.DepthManager(dalle);
		for( i in 0...objectif ){
			var mc = d.attach("mcAcrobateShade",Game.DP_SPRITE);
			mc.y = y;
			y -= 2*RAY;

		}

	}

	override function update(){
		super.update();
	
		timer--;
		if(timer<0){
			timer = INTERVAL;
			genApple();
		}
		moveApple();
		if( last == objectif-1 )setWin(true,20);



	}

	function genApple(){
		var sp:AAcrobate = cast newPhys("mcRunningApple") ;
		sp.x = Cs.omcw + RAY;
		sp.y = GL-RAY;
		//sp.flPhys = false;
		sp.step = 0;
		sp.sens = -1;
		sp.side = 1;
		//sp.weight = 0.5;
		sp.updatePos();
		aList.push(sp);

	}

	function moveApple(){
		var flSeekJumper = step == 1;
		var list = new Array();
		var a = aList.copy();
		for( sp in aList ){
			switch(sp.step){
				case 0: // RUNNING
					sp.x += sp.sens*RUN;

					//trace(sp.x);
					var m = 30;
					if( sp.sens==-1 && sp.side == 1 && sp.x < DX+DRAY+RAY ){
						sp.x = DX+DRAY+RAY;
						sp.sens = 1;
						sp.root.scaleX = -1;
					}

					// CHECK JUMP
					if(  flSeekJumper && click && sp.sens ==-1 && sp.x > DX+m && sp.x < Cs.omcw-m ){
						step = 2;
						sp.step = 1;
						decal = 314;
						arrow = dm.attach("mcAcrobateOrient",Game.DP_SPRITE);
						arrow.x= sp.x;
						arrow.y= sp.y;
						arrow.rotation = -180;
						flSeekJumper = false;
						sp.root.gotoAndPlay("prepare");
						sp.vx = -RUN;
					}

					if( sp.x+RAY < 0 || sp.x > Cs.omcw+RAY+10 ){
						sp.kill();
						aList.remove(sp);
					}


				case 1: // PREPARE JUMP
					sp.vx *= 0.8;
					decal = (decal+12)%628;
					var angle = 3.14+(0.77+Math.cos(decal/100)*0.77);
					arrow.x= sp.x;
					arrow.y= sp.y;
					arrow.rotation = angle/0.0174;
					if(!click){
						sp.root.gotoAndPlay("fly");
						step = 1;
						sp.step = 2;
						sp.weight = 0.5;
						var p = POWER*1.0;
						if(last!=null)p+=last*1.5;
						sp.vx += Math.cos(angle)*p;
						sp.vy += Math.sin(angle)*p;
						arrow.parent.removeChild(arrow);
						arrow = null;
					}

				case 2: // FLYING

					// ORIENT
					sp.root.rotation = (Math.atan2(sp.vy,sp.vx)/0.0174) + 180*(sp.sens-1)*0.5;


					// CHECK GROUND
					if( sp.y > GL-RAY ){
						sp.y = GL-RAY;
						sp.vx = 0;
						sp.vy = 0;
						sp.weight = null;
						//sp.flPhys = false;
						sp.flReject = false;
						sp.step = 0;
						sp.side = (sp.x<DX)?-1:1;
						sp.root.gotoAndPlay("1");
						sp.root.rotation = 0;
					}

					// CHECK COLLIDE
					if(last==null){
						if( sp.vy > 0 && Math.abs(DX-sp.x)<DRAY && sp.y > GL-((2*RAY)+4) ){
							land(sp);
						}
					}else{
						for( spo in aList ){
							if(spo.pos!=null){
								var dist = sp.getDist(spo);
								if( dist < (2*RAY*1.2) ){
									if(last==spo.pos && sp.y < spo.y ){
										land(sp);
										break;
									}else{
										if(!sp.flReject){
											sp.sens*=-1;
											sp.vx*=-1;
											var a = spo.getAng(sp);
											var d = 2*RAY - dist;
											sp.x += Math.cos(a)*d;
											sp.y += Math.sin(a)*d;
											sp.flReject = true;
											sp.root.scaleX = -sp.sens;

										}
										break;
									}
								}
							}
						}
					}

				case 3: // QUEUE
					list[sp.pos] = sp;

					if( !sp.flReject && Math.random()<0.02 ){
						if(sp.pos==0){

						}else{
							sp.root.gotoAndPlay("$anim"+Std.random(6));
							sp.flReject = true;
						}
					}



			}

			sp.root.x = sp.x;
			sp.root.y = sp.y;

		}

		// QUEUE
		qdec = (qdec+8)%628;
		var next = {
			x:DX*1.0,
			y:GL-23.0
		}
		var a = Math.cos(qdec/100)*0.05;//0.02//0.016//*0.012
		var angle = -1.57;
		for( sp in list ){
			sp.x = next.x;
			sp.y = next.y;
			sp.root.rotation = angle/0.0174 + 90;
			next.x += Math.cos(angle)*2*RAY;
			next.y += Math.sin(angle)*2*RAY;
			angle += a;
			a *= 1.23;
		}




	}


	function land(sp:AAcrobate){
		//trace(last);
		var frame = 2;
		if(last==null){
			last=0;
			frame = 1;
		}else{
			last++;
		}
		sp.pos = last;
		sp.step = 3;
		sp.vx = 0;
		sp.vy = 0;
		//sp.flPhys = false;
		sp.weight = null;
		sp.root.gotoAndPlay("base");
		sp.root.tabIndex = frame;
		//nextShoes = { mc:sp.root, n:frame};
		//downcast(sp.root).shoes.gotoAndStop(string(frame))
		
	}



//{
}

