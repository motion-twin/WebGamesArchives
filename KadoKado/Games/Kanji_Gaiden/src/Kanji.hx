
class Kanji extends Phys{
	var sLock 			: Bool;
	public var speedy 	: Bool;
	var sCount 			: Float;
	var kanji 			: flash.MovieClip;
	public var sType	: mt.flash.Volatile<Int>;
	
	
	public function new(){
		kanji = Game.me.dm.attach("hero",Game.DP_HERO);

		kanji._x = Cs.mcw*0.5;
		kanji._y = Cs.mch;
		sType = 1;
		kanji.smc.smc.smc.gotoAndStop(sType);
		super(kanji);
		sLock = false;
		speedy = false;
	}
	
	public function shoot(){
		if (!sLock){
			if (sType==2) sCount = Cs.sCool2;
			else sCount = Cs.sCool;
			sLock = true;
			kanji.smc.smc.smc.gotoAndStop(sType);
			var s = new Shot(sType);
			kanji.smc.gotoAndPlay("_shoot");
			
			if (sType !=0 ) {
				Game.me.bonus[0].qte--;
			}	
		}
	}

	public override function update(){
		if (sCount > 0) {
				sCount -= mt.Timer.tmod;
			}else {
				sLock = false;
		}
	}
	
	
	public function move(dir:Int){
		switch(dir){
			case 0:
				if ( Game.me.pos < 1 ){
					Game.me.pos += Cs.DEV*mt.Timer.tmod;
					if (!sLock) Game.me.pos += 0.010; 
					if (speedy) Game.me.pos += 0.020; 
				}
					
			case 1:
				if ( Cs.DEV < Game.me.pos ){
					Game.me.pos -= Cs.DEV*mt.Timer.tmod;
					if (!sLock) Game.me.pos -= 0.010;
					if (speedy) Game.me.pos -= 0.020; 
				}else {Game.me.pos =0; }
		}
	
	}
	
}







