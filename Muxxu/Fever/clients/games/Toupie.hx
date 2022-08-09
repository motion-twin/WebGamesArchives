import mt.bumdum9.Lib;
class Toupie extends Game{//}


	// VARIABLES
	var index:Int;
	var trackId:Int;
	var timer:Float;
	var sc:Float;
	var tdm:mt.DepthManager;
	var cList:Array<flash.display.MovieClip>;

	// MOVIECLIPS
	var ground:flash.display.MovieClip;
	var track:{>flash.display.MovieClip,col:flash.display.MovieClip};
	var toupie:{>flash.display.MovieClip,vx:Float,vy:Float,base:flash.display.MovieClip};
	var shade:flash.display.MovieClip;


	override function init(dif:Float) {
	
		gameTime = 600 - dif * 100;
		trackId = Math.round(dif * 3);
		gameTime += trackId * 50;
		index = 0;
		sc = 0;
		super.init(dif);
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("toupie_bg",0);

		// GROUND
		ground = dm.attach("mcToupieGround",Game.DP_SPRITE);
		//ground.scaleX = ground.scaleY = Cs.omcw/Cs.mch*100;

		// TRACK
		track = cast(dm.empty(Game.DP_SPRITE));

		track.x = Cs.omcw*0.5;
		track.y = Cs.omch*0.5;
		tdm = new mt.DepthManager(track);

			// COL
			track.col = tdm.attach("mcToupieTrack",1);
			track.col.gotoAndStop(trackId+1);
			// SHADE
			shade = tdm.attach("mcToupieShade",1);

			// TOUPIE
			toupie = cast tdm.attach("mcToupie",1);
			toupie.vx = 0;
			toupie.vy = 0;

			// CP
			cList = new Array();
			for( i in 0...3 ){
				//var mc = Std.getVar(track.col,"$m"+i);
				var mc:flash.display.MovieClip = Reflect.field(track.col,"$m"+i);
				mc.visible = false;
				cList.push(mc);
			}

	}

	override function update(){

		switch(step){
			case 1:

				// START COEF
				sc = Math.min((sc+0.05),1);

				// TOUPIE
				var dx = (track.mouseX - toupie.x);
				var dy = (track.mouseY - toupie.y);
				var lim = 0.15;
				toupie.vx += Num.mm(-lim,dx*0.0007,lim)*sc;
				toupie.vy += Num.mm(-lim,dy*0.0007,lim)*sc;



				toupie.x += toupie.vx;
				toupie.y += toupie.vy;

				toupie.base.rotation = Math.random()*360;

		
				var x = toupie.x;
				var y = toupie.y;

				var pos = track.col.localToGlobal(new flash.geom.Point(x, y));
				
				if( !track.col.hitTestPoint(pos.x,pos.y,true) )	fall();

				// INDEX
				var p = cList[index];

				if(index < 2 ){
					var ddx = p.x - toupie.x;
					var ddy = p.y - toupie.y;
					var dist = Math.sqrt(ddx*ddx+ddy*ddy);
					if(dist<100)index++;
				}else{
					if(toupie.y < p.y)setWin(true,10);
				}

				// SHADE
				shade.x = toupie.x+4;
				shade.y = toupie.y+4;

			case 2:
				var frict = 0.95;
				toupie.vx *= frict;
				toupie.vy *= frict;
				toupie.scaleX *= frict;
				toupie.scaleY = toupie.scaleX;
				timer --;
				if( timer<0 )setWin(false,25);


		}

		// TOUPIE
		var frict = 0.98;
		toupie.vx *= frict;
		toupie.vy *= frict;
		toupie.x += toupie.vx;
		toupie.y += toupie.vy;


		track.x = Cs.omcw*0.5 -toupie.x;
		track.y = Cs.omch*0.5 -toupie.y;

		// GROUND
		ground.x = (1000+track.x*0.5)%40;
		ground.y = (1000+track.y*0.5)%40;


		super.update();
	}

	function fall(){

		step = 2;
		timer = 5;
		var a = 3.14 + Math.atan2(toupie.vy,toupie.vx);
		toupie.rotation = a/0.0174;
		toupie.gotoAndPlay("fall");
		shade.parent.removeChild(shade);
		tdm.over(track.col);
	}


//{
}

