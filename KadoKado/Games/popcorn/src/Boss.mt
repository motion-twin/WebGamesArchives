class Boss extends Phys{//}
	static var FR_END_STD = 	29
	static var FR_START_LAUNCH = 	31
	static var FR_END_LAUNCH = 	56

	static var LIFE = 7;
	static var MARGIN = 60;

	var invert:float;

	var launch:float;
	var frame:float;
	var speed:float;
	var popTimer:float;
	var dif:float;
	var timer:float;
	var startTimer:float;

	var escCoef:float;
	var escLim:float;
	var escPop:float;


	var sens:int
	var step:int;

	volatile var life:int;
	var lifeList:Array<MovieClip>


	function new(mc){
		mc= Cs.game.dm.attach("mcBoss",Game.DP_DECOR)
		super(mc)

		frame = 0;
		sens = 1
		speed = 4
		popTimer = 0

		x = Cs.mcw*0.5
		y = Cs.HEIGHT-250

		step = 0
		dif = 0

		escCoef = 0.08//0.06
		escLim = 0.08
		escPop = 0

		startTimer = 100

		initLife();


	}

	function initLife(){
		life = LIFE
		lifeList = new Array();
		for( var i=0; i<life; i++ ){
			var mc = Cs.game.gdm.attach("mcHeart",6)
			mc._x = 12 + i*16
			mc._y = 13
			mc.stop();
			lifeList.push(mc)
		}
	}

	function update(){
		super.update();
		if(invert!=null){
			invert--;
			if(invert<0){
				Cs.game.map.filters = []
				Cs.game.bg.filters = []
				invert = null;
			}
		}


		switch(step){
			case 0: // STANDARD


				if( startTimer < 0){
				frame = (frame+3*Timer.tmod)%FR_END_STD;
				root.gotoAndStop(string(int(frame)+1))
					checkPop();
				}else{
					startTimer-=Timer.tmod;
					if( startTimer < 50 ){
						if(root._currentframe<FR_END_LAUNCH){
							root.gotoAndPlay("hello")
						}else{

							root.play();
						}

					}else{
				frame = (frame+3*Timer.tmod)%FR_END_STD;
				root.gotoAndStop(string(int(frame)+1))
					}
				}


				move();
				break;
			case 1: // LAUNCH START
				launch = Math.min(launch+5*Timer.tmod,FR_END_LAUNCH) ;
				if(launch==FR_END_LAUNCH){
					step = 2
					var sp = Cs.game.genPopcorn(x-44*(100/root._xscale),y-34)
					sp.vx = sens*Math.random()*6
				}
				root.gotoAndStop(string(int(launch)+1))
				move();
				break;
			case 2: // LAUNCH END
				launch = Math.max(launch-5*Timer.tmod,FR_START_LAUNCH) ;
				if(launch== FR_START_LAUNCH){
					step = 0
					root._xscale = (Std.random(2)*2-1)*100
				}
				root.gotoAndStop(string(int(launch)+1))
				move();
				checkPop();
				break;
			case 3: // HIT
				root.play();
				//
				root._visible = !root._visible
				timer-= Timer.tmod;
				if(timer<0){
					step = 0
					root._visible = true
				}
				x = Cs.mm(MARGIN,x,Cs.mcw-MARGIN)
				vy -= 0.1
				//y = Math.min(Cs.game.hero.y-24, y)
				break;
			case 4 : // END
				if(root._currentframe<FR_END_LAUNCH)root.gotoAndPlay("die");
				vy += 0.5
				//vy *= Math.pow(0.95,Timer.tmod)

				//if( y > Cs.HEIGHT+100 )kill();

				break

		}
		dif += Timer.tmod;
		escPop += 0.00003

	}

	function move(){

		// HORIZONTAL
		speed += 0.003 //0.001
		var tvx = sens*speed
		var dvx = tvx-vx;
		vx += dvx*0.2*Timer.tmod;


		if( x>Cs.mcw-MARGIN || x<MARGIN ){
			x = Cs.mm(MARGIN,x,Cs.mcw-MARGIN)
			vx = 0
			sens *=-1
		}

		// VERTICAL
		var hy = Math.min(Cs.game.hero.y, Cs.game.ly)
		var ty = Math.max( hy - 215, 100 )
		var dy = ty-y
		var boost = dy*escCoef//0.06
		var acc = Math.min( escLim,Math.abs(boost))
		vy += Cs.mm(-acc,boost*Timer.tmod,acc)

	}

	function checkPop(){

		popTimer -= Timer.tmod
		while(popTimer<=0){


			var rnd = Math.max(12 - dif*0.004, 3)



			if( Math.random()*rnd<1 ){
				step = 1;
				if(launch==null)launch = 0;
			}
			popTimer += 3
		}

	};

	function hit(){
		var piou = Cs.game.hero

		var a = getAng(piou)
		var ca = Math.cos(a)
		var sa = Math.sin(a)
		vx  -= ca*10
		vy  -= sa*10
		piou.vx = ca*5
		piou.vy = sa*5



		// UPDATE LIFE
		life--;
		escCoef += 0.02
		escLim += 0.03
		for( var i=0; i<lifeList.length; i++ ){
			var mc = lifeList[i]
			var frame = "1"
			if(i>=life)frame ="2"
			mc.gotoAndStop(frame)
		}

		//S
		if( life>0 ){
			step = 3
			launch = null
			timer = 70
			Cs.game.setScore(x,y,Cs.SCORE_HIT,150)
			root.gotoAndStop("hitt");
			var m = [
				-1,	0,	0,	0,	255
				0,	-1,	0,	0,	255
				0,	0,	-1,	0,	255
				0,	0,	0,	1,	0
			]
			invert= 3;
			var fl = new flash.filters.ColorMatrixFilter();
			fl.matrix = m;
			Cs.game.map.filters = [fl]
			Cs.game.bg.filters = [fl]
		}else{
			step = 4;
			Cs.game.setScore(x,y,Cs.SCORE_BOSS,280)
			timer = 100
			//var sc = SCORE_HIT
		}



	}


	// flash invert + pause quand touché.
	//


//{
}




