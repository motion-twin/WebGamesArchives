class game.SplashPiou extends Game{//}
	
	// CONSTANTES
	static var GL = 220
	static var FMAX = 15
	static var RAY = [16,22,31,50]
	
	// VARIABLES
	var flWillWin:bool;
	var size:int;
	var frame:float;
	var shake:float;
	var dec:float;
	var tx:float;
	var pvy:float;
	var limit:float;
	var timer:float;
	
	// MOVIECLIPS
	var shade:MovieClip;
	var piou:MovieClip;
	var splasher:sp.Phys;
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 180
		super.init();
		frame = 0
		dec = 0
		tx = Cs.mcw*0.5
		airFriction = 0.92
		limit = 30+Math.random()*80
		size = Math.round(dif*0.03)
		attachElements();
	};
	
	function attachElements(){
		
		// SHADE
		shade = dm.attach("mcPiouSplasherShade",Game.DP_SPRITE)
		shade._x = Cs.mcw*1.2
		shade._y = GL
		shade._xscale = RAY[size]*2
		
		// SPLASHER
		splasher = newPhys("mcPiouSplasher")
		splasher.x = Cs.mcw*1.2
		splasher.y = 40
		splasher.flPhys =false;
		splasher.init();
		splasher.skin.gotoAndStop(string(size+1))
		
		// PIOU
		piou = dm.attach("mcPiouPiou",Game.DP_SPRITE)
		piou._x = Cs.mcw*0.5;
		piou._y = GL;
		piou.stop();
		
	}
	
	function update(){
		super.update();
		switch(step){
			case 1:
				moveSplasher();
				movePiou();
				if( base.gameTimer < limit || ( base.gameTimer < 150 && (Math.abs(splasher.x - piou._x)+Std.random(200))-RAY[size] < 2) ){
					step = 2;
					splasher.vitx = 0;
					splasher.vity -= 6;
				}
				break;
			case 2:
				movePiou();
				splasher.vity += 6*Timer.tmod;
				if( splasher.y>GL )splash();
				break;
			case 3 :
				if( piou!=null ){
					piou._y += pvy*Timer.tmod;
					pvy += 0.4+Timer.tmod
					if(piou._y>GL){
						piou._y = GL
						pvy *= -0.4
					}
				}
				timer -= Timer.tmod;
				if(timer<0)setWin(flWillWin);
				break;
		}
		
		splasher.skin._x = splasher.x;
		splasher.skin._y = splasher.y;
		
		if(shake>0.1){
			shake*=0.6
			_y = (Math.random()*2-1)*shake
		}
		
	}

	function movePiou(){
		var dx = _xmouse - piou._x
		if( Math.abs(dx) > 5 ){
			var lim = 6
			var dist = Cs.mm(-lim,dx*0.1,lim)*Timer.tmod;
			var ray = 14
			piou._x = Cs.mm(ray,piou._x+dist,Cs.mcw-ray)
			piou._xscale = (dx<0)?-100:100;
			frame += dist*0.2
			while(frame<0)frame+=FMAX
			while(frame>=FMAX)frame-=FMAX
			piou.gotoAndStop(string(int(frame)+1))
		}
	}
	
	function moveSplasher(){
		
		// FOLLOW
		dec = (dec+10)%628
		tx = piou._x + Math.cos(dec/100)*40
		
		// MOVE
		splasher.towardSpeed( {x:tx,y:splasher.y}, 0.2, 2 )
		shade._x = splasher.x
		var ray = RAY[size]
		splasher.x = Cs.mm(ray,splasher.x,Cs.mcw-ray)
		
	}
	
	function splash(){
		splasher.y = GL;
		splasher.vity = 0;
		var dx = piou._x - splasher.x;
		flWillWin = Math.abs(dx) > RAY[size] ;
		if( flWillWin ){
			pvy = -8;
		}else{
			var mc = dm.attach("partPiouDeath",Game.DP_SPRITE)
			mc._x = piou._x;
			mc._y = piou._y;
			piou.removeMovieClip();
			piou = null;
		}
		step = 3;
		timer = 8;
		shake = 5*(size+1)
	}
	
//{	
}

