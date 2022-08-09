import mt.bumdum.Phys;
import mt.bumdum.Lib;
import Common;

class Particule extends Phys{//}

	public var ox:Float;
	public var oy:Float;
	public var a:Float;
	public var speed:Float;
	public var ca:Float;
	public var lim:Float;
	public var bhl:Array<Int>;

	public function new(mc){
		super(mc);
	}

	public function update(){

		for( n in bhl ){
			switch(n){
				case 0: // TRACER
					Game.me.drawRainbowShade(root);

				case 1: // REBOND
					if( x < Cs.MX || x >Cs.mcw-Cs.MX ){
						x = Num.mm(Cs.MX,x,Cs.mcw-Cs.MX);
						vx *= -0.5;
					}

				case 2: // DESTROY ON OUT
					if( y < -30 )kill();

				case 3: // BLUR Y
					var fl = new flash.filters.BlurFilter();
					fl.blurX = 0;
					fl.blurY = Math.abs(vy)*2;
					root.filters = [fl];

				case 4: // GO TO OPTIONS
					var dx = 33 - x;
					var dy = 71+(Game.me.bg.optList.length-1)*13 - y;
						var ta = Math.atan2(dy,dx);
					var da = Num.hMod(ta-a,3.14);
					lim *= 1.02;
					ca *= 1.02;
					a += Num.mm(-lim,da*ca, lim)*mt.Timer.tmod;
					vx = Math.cos(a)*speed;
					vy = Math.sin(a)*speed;

					if( Math.abs(dx)+Math.abs(dy)*0.5 < 25 ){

						Game.me.addOpt();
						kill();
					}



				case 5: // QUEUE
					if(ox==null){
						ox = x;
						oy = y;
					}
					var mc = Game.me.dm.attach("mcQueueOption",Game.DP_FG);
					mc._x = ox;
					mc._y = oy;

					var dx = x-ox;
					var dy = y-oy;

					mc._rotation = Math.atan2(dy,dx)/0.0174;
					mc._xscale = Math.sqrt(dx*dx+dy*dy);
					var o = Col.getRainbow(Game.me.rainbowCoef);
					Filt.glow(mc,12,4,Col.objToCol(o));
					mc.blendMode = "overlay";


					ox = x;
					oy = y;



			}
		}
		super.update();
	}




//{
}

// COL
// REVOIR LES LUCIOLES






