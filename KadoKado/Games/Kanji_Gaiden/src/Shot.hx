
import mt.bumdum.Lib;

class Shot {//}
	public var ratio : Float;
	public var plan	: mt.flash.Volatile<Int>;
	
	public var goals  : Array<Float>;
	public var mc	: flash.MovieClip;
	var currentPlan : Int;
	var progress 	: Float;
	
	var cz 			: Float;
	var pastCz 		: Float;
	var hint 		: Float;
	var sType 		: mt.flash.Volatile<Int>;
	
	var depth		:  mt.flash.Volatile<Int>;

	public function new (type:Int){
		hint = Game.me.pos ;
		depth = Game.DP_SHOOT;
		mc = Game.me.dm.attach("kunai",depth);
		sType = type;
		mc.gotoAndStop(1);
		mc.smc.gotoAndStop(sType);
		cz = 1;
		pastCz = cz;
		var pos = Game.me.getPosShot(cz,hint);
		mc._x = pos.x ;
		
		currentPlan = 0;
		progress = 0;

		Game.me.shoots.push(this);
	}
	
	
	public function update(){
		
		var tmode = Math.floor(mt.Timer.tmod);
		if (tmode < 1) tmode = 1;
		
		for (i in 0...tmode) {
		
			sProgress();

		}
	}
	
	
	public function sProgress() {
			if (progress < 1 ) {
					
					if (sType==2) progress += Cs.SHURIKEN2;
					else progress += Cs.SHURIKEN;
					
	
				}else{
					if (Game.me.plans[currentPlan].hittest(mc._x,sType)){
						mc._x = -500;
						kill();
					}else if( currentPlan+1 == Game.me.plans.length){
						destroy();
					}else{
						currentPlan +=1;
						progress -= 1; 
						pastCz = cz;
						depth = 10-(currentPlan*2);
						Game.me.dm.swap(mc,depth);
					}
				}
				
				cz = (pastCz*(1-progress) + Game.me.plans[currentPlan].cz*progress) ;
					
				var pos = Game.me.getPosShot(cz,hint);
				mc._x = pos.x;
				mc._y = (pos.y+ Cs.mch*0.5 - cz*100 -10);
				
				
				if (currentPlan == 0 )mc._xscale = 100*(1-progress) + (100*Game.me.plans[currentPlan].cz)*progress +20;
				else if (currentPlan == 4 ){
					mc._xscale = 100*(1-progress) + (100*Game.me.plans[currentPlan].cz)*progress +20;
					mc._alpha = 100 - 100*(progress*2);
				} else mc._xscale = (100*Game.me.plans[currentPlan].cz)*(1-progress) + (100*Game.me.plans[currentPlan].cz)*progress +20;
				mc._yscale = mc._xscale;	
		
	}
	
	
	
	
	
	
	
	/*
	public function pBonus() {
		var nb = 10 + Std.random(5)  ;
		var dsx = 20 ;
		var dsy = 20 ;
		var p = Cs.getPos(pos, true) ;
		var px = p.x ;
		var py = p.y ;
		var vr = 0 ;

		for (i in 0...nb) {
			var mc = Game.me.dm.attach("part", depth) ;
			mc.gotoAndStop(2);
			
			var a = (i+Math.random())/nb *6.28 ;
			var ca = Math.cos(a) ;
			var sa = Math.sin(a) ;
			var sp = 0.5+Math.random()*10 ;

			var dx = ca*sp + 0.4 ;
			var dy = sa*sp + 0.4 ;

			var s = new Phys(mc) ;
			s.root.blendMode = "add" ;
			var sc = 40 + Std.random(60) ;
			s.root._xscale = sc ;
			s.root._yscale = sc ;

			s.x = px ;
			s.y = py ;
			s.frict = 0.9;
			s.vx = dx ;
			s.vy = dy ;
			s.fadeType = 5 ;
			s.timer =  10 + Std.random(10) ;

			if (Sprite.spriteList.length - 81 > 40 && i > 3)
				break ;
		}

	}
	*/
	
	
	
	public function kill(){
		Game.me.shoots.remove(this);
		mc.gotoAndStop(2);
		mc.smc.smc.gotoAndStop(sType);
		mc._rotation = (160 + Std.random(40))*(Std.random(2)-2);
		
		
	}
	
	public function destroy(){
		Game.me.shoots.remove(this);
		mc.removeMovieClip();

	}	
	
	
//{
}







