class game.Toupie extends Game{//}
	
	// CONSTANTES
	
	
	// VARIABLES
	var index:int;
	var timer:float;
	var sc:float
	var tdm:DepthManager;
	var cList:Array<MovieClip>
	
	// MOVIECLIPS
	var ground:MovieClip
	var track:{>MovieClip,col:MovieClip}
	var toupie:{>MovieClip,vx:float,vy:float,base:MovieClip}
	var shade:MovieClip;
	

	function new(){
		super();
	}

	function init(){
		gameTime = 700
		index = 0;
		sc = 0
		super.init();
		attachElements();
	};
	
	function attachElements(){
		
		// GROUND
		ground = dm.attach("mcToupieGround",Game.DP_SPRITE)
		
		// TRACK
		track = downcast(dm.empty(Game.DP_SPRITE))
		
		track._x = Cs.mcw*0.5;
		track._y = Cs.mch*0.5;
		tdm = new DepthManager(track)
		
			// COL
			track.col = tdm.attach("mcToupieTrack",1)
			track.col.gotoAndStop(string(Math.round(dif*0.03)+1))
			// SHADE
			shade = tdm.attach("mcToupieShade",1)
			
			// TOUPIE
			toupie = downcast(tdm.attach("mcToupie",1))
			toupie.vx = 0;
			toupie.vy = 0;
		
			// CP
			cList = new Array();
			for( var i =0; i<3; i++ ){
				var mc = Std.getVar(track.col,"$m"+i)
				mc._visible = false;
				cList.push(mc)
			}

	}
	
	function update(){

		switch(step){
			case 1:
			
				// START COEF
				sc = Math.min((sc+0.05),1)
			
				// TOUPIE
				
				var dx = track._xmouse - toupie._x;
				var dy = track._ymouse - toupie._y;
				var lim = 0.15
				toupie.vx += Cs.mm(-lim,dx*0.005,lim)*sc*Timer.tmod;
				toupie.vy += Cs.mm(-lim,dy*0.005,lim)*sc*Timer.tmod;
			

			
				toupie._x += toupie.vx*Timer.tmod;
				toupie._y += toupie.vy*Timer.tmod;
				
				toupie.base._rotation = Math.random()*360
			
				if( !track.col.hitTest(toupie._x+track._x,toupie._y+track._y,true) ){
					fall();
				}
			
				// INDEX
				var p = cList[index]

				if(index < 2 ){
					var ddx = p._x - toupie._x;
					var ddy = p._y - toupie._y;
					var dist = Math.sqrt(ddx*ddx+ddy*ddy)					
					if(dist<100){
						index++
					}
				}else{
					if(toupie._y < p._y)setWin(true);
				}
				
				// SHADE
				shade._x = toupie._x+4;
				shade._y = toupie._y+4;

				break;
			case 2:
				var frict = Math.pow(0.95, Timer.tmod)
				toupie.vx *= frict
				toupie.vy *= frict				
				toupie._xscale *= frict;
				toupie._yscale = toupie._xscale;
				timer -= Timer.tmod;
				if( timer<0 ){
					setWin(false)
				}
				break;
			
		}
		
		// TOUPIE
		var frict = Math.pow(0.98, Timer.tmod)
		toupie.vx *= frict
		toupie.vy *= frict
		
		toupie._x += toupie.vx*Timer.tmod;
		toupie._y += toupie.vy*Timer.tmod;
		
		// MAP
		/*
		var tx = -toupie._x
		var ty = -toupie._y
		var c = 0.5
		track._x += tx*c*Timer.tmod;
		track._y += ty*c*Timer.tmod;
		*/
		track._x = Cs.mcw*0.5 -toupie._x
		track._y = Cs.mch*0.5 -toupie._y
		
		// GROUND
		ground._x = (1000+track._x*0.5)%40
		ground._y = (1000+track._y*0.5)%40

		
		super.update();
	}
	
	function fall(){
		step = 2
		timer = 5
		var a = 3.14 + Math.atan2(toupie.vy,toupie.vx)
		toupie._rotation = a/0.0174
		toupie.gotoAndPlay("fall")
		shade.removeMovieClip();
	}
	
	
//{	
}

