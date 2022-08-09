import mt.bumdum9.Lib;

class Pilul extends Game{//}

	// CONSTANTES
	static var RAY = 12;
	static var FEAR_RAY = 60.0;
	static var POS = [
		{x:11,y:213},
		{x:24,y:210},
		{x:97,y:67},
	];
	
	var specialInit:Bool;
	
	// VARIABLES
	var sens:Int;
	var mList:Array<Phys>;

	// MOVIECLIPS
	var decor:flash.display.MovieClip;
	var p:{>flash.display.MovieClip,p:flash.display.MovieClip};
	var tempo : Int;

	override function init(dif){
		gameTime = 600;
		super.init(dif);
		sens = 1;
		tempo = 20;
		attachElements();

		if( dif>0.9 ) FEAR_RAY *= Math.max( 1.9-dif, 0.1);
	
		initScreen();
		bg.visible = false;
		screenDraw(bg);
		
		specialInit = false;
		
	}

	function attachElements(){

		//bg.visible = false;

		bg = dm.attach("pilul_bg",0);

		// LEVEL
		var lvl = Math.round(dif*3);
		bg.gotoAndStop(lvl+1);

	}

	

	function doSpecialInit() {
		
		p = cast(bg).p;
		decor = cast(bg).decor;
		if( decor == null ) return;
		specialInit = true;
		
		// MICROBES
		mList = new Array();
		for( i in 0...4 ){
			var mc:flash.display.MovieClip = Reflect.field(bg,"$m"+i);//Std.getVar(this,"$m"+i)
			mc.gotoAndPlay(Std.random(5)+1);
			mc.alpha = 0.8;

			var sp = new Phys(mc);
			sp.x = mc.x;
			sp.y = mc.y;
			sp.frict = 1;
			sp.updatePos();
			mList.push(sp);
		}
		

		
		
	
	}
	
	override function update(){
		super.update();
		if(!specialInit) {
			doSpecialInit();
			return;
		}
	
		
		switch(step){
			case 1:
				if( tempo -- <= 0 ) {
				var mp = getMousePos();
				var a = p.rotation*0.0174;
				var dx = mp.x-p.x/0.6;
				var dy = mp.y-p.y/0.6;
				var da = Math.atan2(dy,dx) - p.rotation*0.0174;
				while(da>3.14)da-=6.28;
				while(da<-3.14)da+=6.28;
				a += da*0.2;
				p.rotation = a/0.0174;
				//
				var x = p.x + Math.cos(a)*RAY*sens;
				var y = p.y + Math.sin(a)*RAY*sens;
				//var x = Math.cos(a)*RAY*sens;
				//var y = Math.sin(a)*RAY*sens;
				
				//mark(x, y);
				
				if(hitTest(x, y)) {
					
					do{
						var lim = 0.1;
						a -= Num.mm(-lim, da*0.01, lim );
						x = p.x + Math.cos(a)*RAY*sens;
						y = p.y + Math.sin(a)*RAY*sens;
					}while(hitTest(x,y));
					p.rotation = a/0.0174;
					//
					sens *= -1;
					p.x = x;
					p.y = y;
					p.p.x = 6*sens;
				}

				//
				var flDone = true;
				var pos ={x:p.x,y:p.y}
				var a = mList.copy();

			
				
				var  fr = FEAR_RAY;
				/*
				if( dif>0.9 ) {
					FEAR_RAY *= 1.9-dif;
					trace( dif );
				}
				*/

				for( sp in a ){
					var dist = sp.getDist(pos);
					if(dist<fr){
						var c = (fr-dist)/FEAR_RAY;
						var s = 0.5;
						var pa = sp.getAng(pos);
						sp.vx -= Math.cos(pa)*c*s;
						sp.vy -= Math.sin(pa) * c * s;
					
					}
					var m = 10;
					if( sp.x<-m || sp.x>Cs.omcw+m || sp.y<-m || sp.y>Cs.omch+m ){
						sp.kill();
						mList.remove(sp);
					}
					if(sp.vx==0 && sp.vy==0)flDone = false;

				}
				}

				//if(flDone)timeProof=true;
				if(mList.length == 0)setWin(true);

				screenDraw(bg);
				
				/*
				for( i in 0...100 ){
					var x = Std.random(Cs.omcw);
					var y = Std.random(Cs.omch);
					if( hitTest(x, y) ) mark(x, y);
				}
				*/
				

		}



	}
	
	function mark(x,y) {
		var m = new McMark();
		m.x = x;
		m.y = y;
		bg.addChild(m);
	}

	function hitTest(x:Float, y:Float) {

		if( decor == null ) return false;

		var pos  = new flash.geom.Point(x, y);
		pos = decor.localToGlobal(new flash.geom.Point(x,y));
		return decor.hitTestPoint(pos.x, pos.y, true);
	
	}
	



//{
}

