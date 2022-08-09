import mt.bumdum9.Lib;

class SplashPiou extends Game{//}

	// CONSTANTES
	static var GL = 220;
	static var FMAX = 15;
	static var RAY = [16,22,31,50];

	// VARIABLES
	var flWillWin:Bool;
	var size:Int;
	var frame:Float;
	var shake:Float;
	var dec:Float;
	var tx:Float;
	var pvy:Float;
	var limit:Float;
	var timer:Float;

	// MOVIECLIPS
	var shade:flash.display.MovieClip;
	var piou:flash.display.MovieClip;
	var splasher:Phys;



	override function init(dif){
		gameTime = 180;
		super.init(dif);
		frame = 0;
		dec = 0;
		tx = Cs.omcw*0.5;
		limit = 30+Math.random()*80;
		size = Math.round(dif*3);
		if(size>3)size = 3;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("splashPiou_bg",0);

		// SHADE
		shade = dm.attach("mcPiouSplasherShade",Game.DP_SPRITE);
		shade.x = Cs.omcw*1.2;
		shade.y = GL;
		shade.scaleX = RAY[size]*0.02;

		// SPLASHER
		splasher = newPhys("mcPiouSplasher");
		splasher.x = Cs.omcw*1.2;
		splasher.y = 40;
		splasher.updatePos();
		splasher.root.gotoAndStop(size+1);
		splasher.frict = 0.92;

		// PIOU
		piou = dm.attach("mcPiouPiou",Game.DP_SPRITE);
		piou.x = Cs.omcw*0.5;
		piou.y = GL;
		piou.stop();

	}

	override function update(){
		super.update();
		switch(step){
			case 1:
				moveSplasher();
				movePiou();
				if( gameTime < limit || ( gameTime < 150 && (Math.abs(splasher.x - piou.x)+Std.random(200))-RAY[size] < 2) ){
					step = 2;
					splasher.vx = 0;
					splasher.vy -= 6;
				}

			case 2:
				movePiou();
				splasher.vy += 6;
				if( splasher.y>GL )splash();

			case 3 :
				if( piou!=null ){
					piou.y += pvy;
					pvy += 1;
					if(piou.y>GL){
						piou.y = GL;
						pvy *= -0.4;
					}
				}
				timer--;
				if(timer<0)setWin(flWillWin,20);

		}

		splasher.root.x = splasher.x;
		splasher.root.y = splasher.y;

		if(shake>0.1){
			shake*=0.6;
			box.y = (Math.random()*2-1)*shake;
		}

	}

	function movePiou(){
		var dx = getMousePos().x - piou.x;
		if( Math.abs(dx) > 5 ){
			var lim = 6-dif;
			var dist = Num.mm(-lim,dx*0.1,lim);
			var ray = 14;
			piou.x = Num.mm(ray,piou.x+dist,Cs.omcw-ray);
			piou.scaleX = (dx<0)?-1:1;
			frame += dist*0.2;
			while(frame<0)frame+=FMAX;
			while(frame>=FMAX)frame-=FMAX;
			piou.gotoAndStop(Std.int(frame)+1);
		}
	}

	function moveSplasher(){

		// FOLLOW
		dec = (dec+10)%628;
		tx = piou.x + Math.cos(dec/100)*40;

		// MOVE
		splasher.towardSpeed( {x:tx,y:splasher.y}, 0.2, 2 );
		shade.x = splasher.x;
		var ray = RAY[size];
		splasher.x = Num.mm(ray,splasher.x,Cs.omcw-ray);

	}

	function splash(){
		splasher.y = GL;
		splasher.vy = 0;
		var dx = piou.x - splasher.x;
		flWillWin = Math.abs(dx) > RAY[size] ;
		if( flWillWin ){
			pvy = -8;
		}else {
			for( i in 0...8 ) {
				var mc = dm.attach("partPiouDeath", Game.DP_SPRITE);
				var f = getMc(mc, "f");
				f.gotoAndPlay(Std.random(f.totalFrames + 1));
				var p = new Phys(mc);
				p.weight = 0.1+Math.random()*0.2;
				p.vx = (Math.random() * 2 - 1) * 3;
				p.vy = -Math.random() * 4;
				p.sleep = Std.random(3);
				p.x = piou.x;
				p.y = piou.y - 40;
				p.updatePos();
			}

			piou.parent.removeChild(piou);
			piou = null;
		}
		step = 3;
		timer = 8;
		shake = 5*(size+1);
	}

//{
}

