
typedef Bamboo = {>flash.MovieClip,mask:flash.MovieClip, taupe:flash.MovieClip, bottom:flash.MovieClip};


class Plan {//}

	public static var DP_M = 1;
	public static var DP_CANVAS = 2;
	public static var DP_BB = 3;
	
	public static var me:Plan;
	public var mcPlan	: flash.MovieClip;
	public var cz 		: Float;
	public var z 		: Float;
	
	public var dm		: mt.DepthManager;
	public var width	: mt.flash.Volatile<Int>;
	
	public var nbPl		: mt.flash.Volatile<Int>;
	
	public var nbBamb	: mt.flash.Volatile<Int>;
	
	public var bamboos  : Array<Float>;
	
	public var monkeys  : Array<Monkey>;
	
	var canvas			: {>flash.MovieClip, bmp: flash.display.BitmapData };	
	
		
	public function new( mc : flash.MovieClip, nb : Int, dev : Float, type: Int ){
		mcPlan = mc;
		me = this;
		nbPl = nb;
		cz = dev;

		width = Math.ceil((300+600*(1-cz)));
		
		var pos = Game.me.getPos(cz);
		mcPlan._x = pos.x;
		z = Cs.mch*0.5 + pos.y;
		
		dm = new mt.DepthManager(mc);
		
		canvas = cast dm.empty(DP_CANVAS);
		canvas._x = 0;
		canvas._y = 0;
		
		var bmp = new flash.display.BitmapData(width+20,Cs.mch,true,0x00000000);
		canvas.attachBitmap(bmp,0);
		canvas.bmp = bmp;
		
		
		
		
		switch(type){
			case 0:
// Bamboonier
				bamboos = [];
				//initBamboo();
				initBambooDraw();
				initNature();

			case 1 :
			// FG
			
			
			case 2:
// Interplan
				initNature();
		}
	}
	
	public function update(){
		var pos = Game.me.getPos(cz);
		mcPlan._x = -pos.x;	
	}
	
	public function addMonkey(){
		var mmc = dm.attach("monkey",DP_M);
		var m: Monkey = new Monkey(mmc,cz,z,nbPl);
		Game.me.monkeys.push(m);
	}
	
	public function addMonkeyTyped(mtype:Int ,life:Int,diff:Int,btype:Int){
		var mmc = dm.attach("monkey",DP_M);
		var m: Monkey = new Monkey(mmc,cz,z,nbPl,mtype,life,diff,btype);
		Game.me.monkeys.push(m);
	}
	
	function drawB(b: flash.MovieClip ) {
		var m = new flash.geom.Matrix();

		m.scale(b._xscale/100,Math.abs(b._xscale)/100);
		m.rotate(3.14*b._rotation/180);
		m.translate(b._x,b._y);
		
		canvas.bmp.draw(b,m);
	}
	
	
	function initBambooDraw(){	
		var b:Bamboo = cast dm.attach("bamboo",DP_BB);
		

		b.taupe.gotoAndStop(Std.random(b.taupe._totalframes)+1);
		b.bottom.gotoAndStop(Std.random(b.bottom._totalframes)+1);
		b._x = 0;
		b._y = z - Cs.SPHERATIO*Math.sin(0);
		b._rotation = -Cs.SPHERANGLE;
		b._xscale = (cz*100);
		b._yscale = b._xscale;
		drawB(b);


		b.taupe.gotoAndStop(Std.random(b.taupe._totalframes)+1);
		b.bottom.gotoAndStop(Std.random(b.bottom._totalframes)+1);
		b._x = width;
		b._y = z - Cs.SPHERATIO*Math.sin(3.14);
		b._xscale = (cz*100);
		b._yscale = b._xscale;
		b._rotation = Cs.SPHERANGLE;
		drawB(b);
		
		

		var nb = Math.ceil((width) /120) + nbPl*7  ;
		var range = Math.ceil(width/nb) ;
		

		for( i in 0...nb ){
			b.taupe.gotoAndStop(Std.random(b.taupe._totalframes)+1);
			b.bottom.gotoAndStop(Std.random(b.bottom._totalframes)+1);
			b._x = range*i + Std.random((range-30)) - (range-30)/2;
			var ratiooo = Math.sin(b._x/width*3.14);
			b._y = z -  Cs.SPHERATIO*ratiooo;
			if (b._x< (width*0.5)) b._rotation = -(Cs.SPHERANGLE - ratiooo *Cs.SPHERANGLE);
			else b._rotation = Cs.SPHERANGLE - ratiooo *Cs.SPHERANGLE;
		
			if (Std.random(2) ==1) b._xscale = (cz*100);
			else  b._xscale = -(cz*100);
			
			b._yscale = Math.abs(b._xscale);
			b.mask._y = Std.random(385);
			
			drawB(b);
			bamboos.push(b._x);
			}
			
		b.removeMovieClip();

	}	
	
	function initNature(){	
		var nb = Math.ceil(width/(100*cz)) ;

		for( i in 0...nb ){
			var h = dm.attach("herbes",DP_BB+nb);
			h._x = i*300*cz;
			h._y = z ;
			h._xscale = (cz*100);
			h._yscale = h._xscale;
			
			var ratiooo = Math.sin(h._x/width*3.14);
			h._y = z -  Cs.SPHERATIO*ratiooo+ cz*(20) ;

			drawB(h);
			h.removeMovieClip();
			}
	}	

	public function move(dir:Int){
		switch(dir){
			case 0:
				if ( mcPlan._x > -(width-Cs.mcw)){
					mcPlan._x -= Cs.DEV*cz;
				}else{
					mcPlan._x = -(width-Cs.mcw) ;
				}			
			case 1:
				if ( (mcPlan._x) < width){
					mcPlan._x += Cs.DEV*cz ;
					}else{
					mcPlan._x = width;
					}
		}
	}
	
	public function hittest(x,type):Bool{
		var ret = false;
		for(b in bamboos ){
			var left = mcPlan._x + b - 30*cz ;
			var right = mcPlan._x + b + 30*cz ;
			if ( x<right && x>left) ret = true;
		}
		
		if (!ret){
			for(m in Game.me.monkeys ){
				if ((m.pl == nbPl) && !m.protected){
					var left = mcPlan._x + m.x - m.mcMonkey._width*0.5;
					var right = mcPlan._x + m.x + m.mcMonkey._width*0.5 ;
					if ( x<right && x>left) ret = true;
					if (ret) {
						m.ouch(type);
						return ret;
					}
				}
			}
				
		}
		
		return ret;
	}
	
	
	
	
//{
}




