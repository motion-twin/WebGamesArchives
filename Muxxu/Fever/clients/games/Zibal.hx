import mt.bumdum9.Lib;
typedef Patte = {mc:flash.display.MovieClip,base:flash.display.MovieClip,x:Float,y:Float,angle:Null<Float>,dist:Null<Float>};

class Zibal extends Game{//}




	// CONSTANTES
	static var FOOT_SPEED = 20;
	static var INFO = [
		{
			s:{x:37,y:118},
			d:{x:194,y:125}
		},
		{
			s:{x:184,y:184},
			d:{x:59,y:115}
		},

		{
			s:{x:172,y:73},
			d:{x:35,y:58}
		},

		{
			s:{x:184,y:56},
			d:{x:178,y:178}
		},
		{
			s:{x:49,y:183},
			d:{x:175,y:190}
		}
	];

	// VARIABLES
	var flWillWin:Bool;
	var next:Int;
	var timer:Float;
	var zibal:Phys;
	var pList:Array<Patte>;

	// MOVIECLIPS
	var level:{>flash.display.MovieClip,spos:flash.display.MovieClip};
	var door:flash.display.MovieClip;
	var mask_:flash.display.MovieClip;


	override function init(dif:Float){
		gameTime =  600-100*dif;
		super.init(dif);
		next = 0;
		attachElements();
		zoomOld();
		
		//Filt.glow(level,10,0.3,0);

	}

	function attachElements(){
		var li = Math.round(dif*5);
		if( li>4 )li=4;
		var lvl = INFO[li];

		bg = dm.attach("zibal_bg",0);



		// LEVEL
		level = cast dm.attach("mcZibalLevel",Game.DP_SPRITE);
		level.gotoAndStop(li+1);

		// DOOR
		door = dm.attach("mcPortail",Game.DP_SPRITE2);
		door.x = lvl.d.x;
		door.y = lvl.d.y;


		// ZIBAL
		zibal = newPhys("mcZibal");
		zibal.x = lvl.s.x;
		zibal.y = lvl.s.y;
		zibal.weight = 0.3;
		zibal.updatePos();
		zibal.root.stop();
		zibal.frict = 0.95;





	}

	override function update(){

		if(pList==null){
			// PATTES
			pList = new Array();
			for( i in 0...4 ){
				var p = {
					mc:dm.attach("mcZibalFoot",Game.DP_SPRITE2),
					base:dm.attach("mcZibalBaseFoot",Game.DP_SPRITE2),
					x:zibal.x,
					y:zibal.y,
					angle:null,
					dist:null,
				}
				p.mc.stop();
				var a = ((i/4)+0.125)*6.28;
				var dx = Math.cos(a);
				var dy = Math.sin(a);

				var to = 0;
				while( !hitTest(p.x,p.y) ){
					p.x += dx;
					p.y += dy;
					if(to>400)break;
				}

				updateFoot(p);
				pList.push(p);
			}
		}


		// UPDATE FOOTS
		for( p in pList )updateFoot(p);

		// CHECK DEATH
		if( step!=4 && hitTest(zibal.x,zibal.y) ){
			willWin(false,10);
			destroyFoots();
			zibal.vx = 0;
			zibal.vy = -4;
			zibal.root.gotoAndStop("death");
		}

		// CHECK DOOR
		if( step!=4  ){
			var dist = zibal.getDist({x:door.x,y:door.y});
			if( door.currentFrame==1 && dist<80 ){
				door.play();
			}
			if( door.currentFrame > 14 && dist<14  ){
				willWin(true,10);
				mask_ = dm.attach("mcZibalMask",Game.DP_SPRITE);
				mask_.x = door.x;
				mask_.y = door.y;
				//mask_.alpha = 0;
				zibal.root.mask = mask_;
				destroyFoots();
			}

		}


		// ORIENT
		var ma = zibal.getAng(getMousePos());
		zibal.root.rotation = ma/0.0174;


		// CONTROL
		switch(step){
			case 1:
				if(click){
					step = 2;
					var p = pList[next];
					p.angle = ma;
					p.dist = 0;
					p.x = zibal.x;
					p.y = zibal.y;
					p.mc.gotoAndStop(1);

				}
			case 2:
				var p = pList[next];
				var dx = Math.cos(p.angle);
				var dy = Math.sin(p.angle);
				var max = Math.floor(FOOT_SPEED);
				for(  i in 0...max ){
					p.x += dx;
					p.y += dy;
					if( hitTest(p.x,p.y) ){
						p.dist = null;
						p.angle = null;
						next = (next+1)%4;
						step = 3;
						pList[next].mc.gotoAndStop(2);
						break;
					}
				}

			case 3:
				if(!click)step=1;

			case 4:
				timer--;
				if(timer<0){
					//flFreezeResult = false;
					setWin(flWillWin,10);
				}

		}

		super.update();
	}

	function updateFoot(p:Patte){
		var a = zibal.getAng(p);
		var dist = zibal.getDist(p);
		p.mc.x = zibal.x;
		p.base.x = zibal.x;
		p.mc.y = zibal.y;
		p.base.y = zibal.y;
		p.mc.rotation = a/0.0174;
		p.base.rotation = a/0.0174;
		p.mc.scaleX = dist*0.01;

		if(p.dist==null){
			var att = dist*0.01;
			zibal.vx += Math.cos(a)*att;
			zibal.vy += Math.sin(a)*att;
		}
	}

	function destroyFoots(){
		while(pList.length>0){
			var p = pList.pop();
			p.mc.parent.removeChild(p.mc);
			p.base.parent.removeChild(p.base);
		}
	}

	function willWin(flag,t){
		flWillWin = flag;
		timeProof = true;
		step = 4;
		timer = t;
	}

	function hitTest(x:Float,y:Float){
		
		/*
		var ratio = Cs.mcw/240;
		x *= ratio;
		y *= ratio;
		*/
		var pos = level.localToGlobal(new flash.geom.Point(x,y));
		return level.hitTestPoint(pos.x, pos.y, true);
		//return level.hitTest(x,y,true);

	}

//{
}

