package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Generator extends Event {//}

	static var MOLECULES_MAX = 6;
	static var CYCLE = 140;

	var timer:Float;
	public var bl:Block;

	public function new(bl){
		this.bl = bl;
		super();
		timer = CYCLE*0.5;

	}

	override public function update(){
		super.update();



		if( Game.me.molecules.length<MOLECULES_MAX && bl.flIce != true ){
			timer -= mt.Timer.tmod;
			var lim = 30;
			if(timer<=lim){
				if( timer>3 ){
					for( i in 0...3 ){
						if(Math.random()*timer < 5){
							var p = new Phys(Game.me.dm.attach("mcGenLine",Game.DP_PARTS));
							p.x = bl.root._x+Cs.BW*0.5;
							p.y = bl.root._y+Cs.BH*0.5;
							p.root._rotation = Math.random()*360;
							p.timer = 5+Std.random(8);
							p.fadeLimit = p.timer;
							p.fadeType = 0;
							p.updatePos();
							Filt.glow(p.root,10,2,0xCC88FF);
							p.root.blendMode = "add";
						}
					}
				}

				bl.root.smc._xscale = bl.root.smc._yscale = 100*(1-timer/lim);

			}
			if(timer<=0){
				timer = CYCLE;
				bl.root.smc._xscale = bl.root.smc._yscale = 0;
				bl.genMolecule();
				bl.fxSparks(14);

			}

		}else{
			bl.root.smc._xscale = bl.root.smc._yscale = 0;
		}



	}




//{
}













