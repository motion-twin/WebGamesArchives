class Game {//}

	static var DP_BG = 1;
	static var DP_SHADE = 2;
	static var DP_OIL = 3;
	static var DP_BLOB = 4
	static var DP_WHEEL = 5;
	static var DP_STAR = 6;
	static var DP_PART = 8;
	static var DP_WATER = 10;
	static var DP_WPART = 12;

	static var DEBUG = false;

	var flCameraJump:bool;

	var step:int;
	var genStep:int
	volatile var timer:float;
	volatile var maxHeight:float;
	var svy:float;
	volatile var roof:float;
	volatile var waterBoost:float;

	var dm:DepthManager;
	var gdm:DepthManager;

	var sList:Array<Sprite>;

	var gList:Array<{x:float,y:float,mc:MovieClip,type:int}>
	var awList:Array<Wheel>
	var sparkList:Array<Spark>
	var bg:MovieClip;
	var map:MovieClip;
	var bgs:MovieClip;
	var wheelLoading:MovieClip;
	var panel:{>MovieClip,txt:String};


	var eList:Array<{s:int,e:int,list:Array<Element>}>
	var blob:Blob;
	var water:MovieClip;
	var focus:{y:float}

	var stats:{$b:Array<int>,$hm:int,$jp:int,$pl:int,$bl:int}

	function new(mc) {
		Cs.init();
		Cs.game = this

		gdm = new DepthManager(mc);
		map = gdm.empty(1)
		map._y = Cs.mch
		map._x = Cs.mcw

		dm = new DepthManager(map);
		//bg = gdm.attach("mcBg",0)
		//bgs = gdm.attach("mcBackground",0)

		sList = new Array();
		eList = new Array();
		sparkList = new Array();

		svy = 0;
		waterBoost = 0;

		//
		stats = {$b:[0,0,0],$hm:0,$jp:0,$pl:0,$bl:0}

		//
		//initDecor();

		//
		maxHeight = 0;



		initStep(1)
	}


	function initDecor(n){
		var size = 40
		var height = 2000
		var xMax = Cs.mcw/size
		var yMax = height/size


			var bmp = new flash.display.BitmapData( Cs.mcw, height, false, 0x00436B70 );
			for( var x=0; x<xMax; x++){
				for( var y=0; y<yMax;y++){

					var mc = gdm.attach("mcTile",10)
					mc.gotoAndStop(string(n*10+Std.random(10)+1))
					Cs.drawMcAt(bmp,mc,x*size,y*size)
					mc.removeMovieClip();
				}
			}
			var by = 100
			while(by<2000){
				if(Math.random()<0.2){
					var link = "mcMotif"
					var bx = Std.random(Cs.mcw)
					if(Math.random()<0.2){
						link = "mcFrise"
						bx = Cs.mcw*0.5
					}
					var mc = gdm.attach(link,10)
					by += mc._height*0.5
					mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
					Cs.drawMcAt(bmp,mc,bx,by)
					by += mc._height*0.5
					mc.removeMovieClip();
				}

				by+= Std.random(100)

			}


			for( var y=0; y<yMax; y++){
				for( var i=0; i<2; i++ ){
					var mc = gdm.attach("mcSide",10)
					mc.gotoAndStop(string(n*10+Std.random(10)+1))
					Cs.drawMcAt(bmp,mc,i*(Cs.mcw-Cs.SIDE),y*40)
					mc.removeMovieClip();
				}
			}
			var skin = dm.empty(DP_BG)
			skin.attachBitmap(bmp,1)
			skin._y = -(n+1)*height




	};

	function initWheels(){

		var list = new Array();

		var ow = new Wheel();
		ow.ray =  (Cs.mcw-2*(Cs.SIDE+Cs.SPACE))*0.5
		ow.x = Cs.mcw*0.5 //Math.random()*Cs.mcw - Cs.SIDE*2
		ow.y = 0
		ow.speed = 0.1

		list.push(ow)

		for( var i=0; i<Cs.WMAX; i++ ){
			var c = Cs.mm( 0,(i/Cs.WMAX)+(Math.random()*2-1)*Cs.DIF_RANDOMIZER, 1)
			var c2 = Cs.mm( 0,(i/Cs.WMAX)+(Math.random()*2-1)*Cs.DIF_RANDOMIZER, 1)
			var c3 = Cs.mm( 0,(i/Cs.WMAX)+(Math.random()*2-1)*Cs.DIF_RANDOMIZER, 1)

			var w = new Wheel()
			w.ray = Cs.WHEEL_RAY_MIN + (1-c2)*(Cs.WHEEL_RAY_MAX-Cs.WHEEL_RAY_MIN) + Math.random()*Cs.WHEEL_RAY_RANDOM
			w.speed = Cs.WHEEL_SPEED_MIN + c3*(Cs.WHEEL_SPEED_MAX-Cs.WHEEL_SPEED_MIN) + Math.random()*Cs.WHEEL_SPEED_RANDOM


			var dist = Cs.WHEEL_DIST_MIN+ c*(Cs.WHEEL_DIST_MAX-Cs.WHEEL_DIST_MIN) + (ow.ray+w.ray)
			var a = null
			var lim = Cs.SIDE+Cs.SPACE+w.ray
			var flBreak = null;
			while(true){
				a = -1.57 + (Math.random()*2-1)*1.4
				w.x = ow.x + Math.cos(a)*dist
				w.y = ow.y + Math.sin(a)*dist
				flBreak = w.x>lim && w.x<Cs.mcw-lim
				if(flBreak){
					var w2 = list[list.length-2]
					if(w2!=null){
						if( Cs.getDist(w,w2) < w.ray+w2.ray){
							flBreak = false;
						}
					}
				}
				if(flBreak)break;
			}
			//w.addMine();
			while(Math.random()+0.4<c){
				w.addMine();
			}


			// INTER WHEEL
			if(Math.random()>c){
				var nw = new Wheel();
				nw.y = (w.y+ow.y)*0.5
				var tr = 0
				while(true){
					flBreak = true

					nw.ray = Cs.WHEEL_RAY_MIN + 10 + Math.random()*(Cs.WHEEL_RAY_MAX-Cs.WHEEL_RAY_MIN)
					nw.speed = Cs.WHEEL_SPEED_MIN + Math.random()*(Cs.WHEEL_SPEED_MAX-Cs.WHEEL_SPEED_MIN)
					var m = Cs.SIDE+Cs.SPACE+nw.ray
					nw.x = m+Cs.mcw-(2*m)
					var lst = [w,ow]
					for( var n=0; n<lst.length; n++ ){
						var w2 = lst[n]
						if( Cs.getDist(nw,w2) < nw.ray+w2.ray+Cs.SPACE){
							flBreak = false;
							break;
						}
					}

					if(flBreak){
						list.push(nw)
						break;
					}
					if(tr++>30)break;


				}



			}


			//
			ow = w;
			list.push(w);
		}
		roof = ow.y - ow.ray
		eList.push({list:list,s:Cs.START_WHEEL_ID,e:Cs.START_WHEEL_ID-1})
	}

	function initPastilles(){
		var list = new Array();
		for( var y=-100; y>roof; y-=20){
			if( Math.random()< y/roof ){
				var p = new Pastille()
				var m = Cs.SIDE + p.ray
				p.x = m+Math.random()*(Cs.mcw-2*m)
				p.y = y
				list.push(p)
			}
		}
		eList.push({list:list,s:Cs.START_WHEEL_ID,e:Cs.START_WHEEL_ID-1})
	}

	function initStep(s:int){
		step = s;

		switch(step){
			case 0: //
				initWheels()
				initPastilles()

				//
				blob = new Blob(dm.attach("mcBlob",DP_BLOB));
				blob.x = Cs.mcw*0.5
				blob.y = 0
				blob.cw = downcast(eList[0].list[Cs.START_WHEEL_ID])
				blob.initStep(2)

				//
				water = dm.attach("mcWater",DP_WATER)
				water._y = -300//-300
				//
				flCameraJump = true;
				//
				KKApi.processing(false);
				//
				map._x = 0
				//
				panel = downcast(gdm.attach("mcPanel",5))
				panel.txt = "0m"
				//
				wheelLoading.removeMovieClip();
				break;
			case 1:	// INITDECOR
				wheelLoading = gdm.attach("mcWheelLoading",5)
				wheelLoading._x = Cs.mcw*0.5
				wheelLoading._y = Cs.mcw*0.5
				KKApi.processing(true);
				genStep = 0
				break;
			case 9: // ENDGAME
				timer = 30
				focus = {x:blob.x,y:blob.y}
				break


		}

	}

	function main() {
		timer-=Timer.tmod;
		if(DEBUG){
			if(Key.isDown(Key.ENTER)){
				water._y -= 4*Timer.tmod
			}
		}
		//for( var i=0; i<10000; i++)var a = Math.pow(Math.random(),Math.random())
		//
		updateElements();
		//
		switch(step){
			case 0: //

				waterBoost += Cs.WATER_SPEED_INC*Timer.tmod;
				water._y -= (Cs.WATER_SPEED+waterBoost)*Timer.tmod;
				blob.checkDeath();

				var dx = -blob.y-maxHeight
				if( dx>0 )KKApi.addScore(KKApi.const(int(dx)))
				maxHeight = Math.max(-blob.y,maxHeight)
				var n = int(maxHeight*0.2)
				panel.txt = n+"$m".substring(1)
				stats.$hm = n

				break;
			case 1:
				initDecor(genStep)
				genStep++
				if(genStep==5)initStep(0)
			case 9:
				if(timer<0){
					KKApi.gameOver(stats);
					initStep(10)
				}
				break;

		}
		//


		// SPARKS BOUNCE
		for( var i=0; i<sparkList.length; i++ ){
			var p0 = sparkList[i]
			for( var n=i+1; n<sparkList.length; n++ ){
				var p1 = sparkList[n]
				var dif = 16 - p0.getDist(p1)

				if(dif>0){
					var a = p0.getAng(p1)
					var cx = Math.cos(a)*dif*0.5
					var cy = Math.sin(a)*dif*0.5
					p0.x -= cx
					p0.y -= cy
					p1.x += cx
					p1.y += cy
				}

			}
		}
		// SCROLL
		scrollMap();


		// SPRITES
		var list = sList.duplicate();
		for( var i=0; i<list.length;i++){
			list[i].update();
		}
	}

	function scrollMap(){

		var fy = focus.y
		/*
		if(downcast(focus).vy!=null){
			var lim = 80
			fy += Cs.mm(-lim,downcast(focus).vy*14,lim)
		}
		*/
		var ty = Cs.mch*0.5-fy
		var dy = ty - map._y
		svy +=  dy*0.1*Timer.tmod;
		svy *= Math.pow(0.6,Timer.tmod)


		//map._y = Math.max( Cs.mch-10,map._y+svy*Timer.tmod )
		map._y += svy*Timer.tmod;
		bgs._y = Cs.mch+map._y*0.1

		if(flCameraJump){
			map._y = ty
			svy = 0
			flCameraJump = false;
		}

	}

	function updateElements(){


		//
		for( var n=0; n<eList.length; n++ ){
			var o = eList[n]
			var flAgain = false;

			var flFirst = true
			var tr = 0
			while(true){
				var flBreak = true;
				for( var i=o.s; i<=o.e; i++ ){
					var w = o.list[i]
					if(flFirst)w.update();

					if(w.flRemove){
						o.e--
						w.detach();
						o.list.splice(i--,1)
						flBreak = false;
					}else if( w.y-w.ray > -map._y+Cs.mcw ){
						o.s++
						w.detach();
						flBreak = false;
					}else if( w.y+w.ray < -map._y ){
						o.e--
						w.detach();
						flBreak = false;
					}
				}

				var w = o.list[o.s-1]
				if( w.y-w.ray < -map._y+Cs.mcw ){
					o.s--
					w.attach();
					flBreak = false;
				}

				w = o.list[o.e+1]
				if( w.y+w.ray > -map._y ){
					o.e++
					w.attach();
					flBreak = false;
				}
				flFirst = false;
				if(flBreak || tr++>20)break;
			}

		}

	}


//{
}

// NOM DE JEU
// Wheel-o
// H2Ink
// InterWheel
// Buole de suif
// Mad-Wheel

// DECOR FOND
// ROUE SCORE
// SPLASH ENTREE SORTIE






