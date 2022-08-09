package fx.gr;
import mt.bumdum.Lib;
import Fight;


using mt.kiroukou.motion.Tween;
class Sylfide extends fx.GroupEffect {

	var fairies:IntHash<Array<flash.MovieClip>>;

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.03;
	}

	public override function update() {
		super.update();
		switch(step) {
			case 0:
				var aura = 2;
				updateAura(aura, caster.skinBox);
				for( i in 0...2) genRayConcentrate();
				if(coef == 1) {
					caster.skinBox.filters = [];
					caster.playAnim("release");
					
					fairies = new IntHash();
					for( target in list ) {
						var fairy = [];
						fairies.set(target.t.fid, fairy);
						target.t.lock = true;
						var count = 25;
						for( i in 0...count ) {
							var mc = Scene.me.dm.attach( "_sylphide", Scene.DP_PARTS );
							mc._x = Math.random() * Cs.mcw;
							mc._y = -Std.random(30);
							//
							var ox = 1.2 * (Math.random() * target.t.root._width - target.t.root._width / 2);
							var oy = -1.2 * (Math.random() * target.t.body._height - target.t.root._height / 4);
							//
							mc.tween().to( 2.0, _x = target.t.root._x + ox, _y = target.t.root._y + oy ).fx(TFx.TLinear).onComplete( function(t) {
								if( --count == 0 ) {
									spc = 0.5;
									nextStep();
								}
							} );
							fairy.push(mc);
						}
					}
					
					nextStep();
				}

			case 2:
				// Petites fées qui remontent
				if( coef == 1 ) {
					var count = 0;
					for( target in list ) {
						for( f in fairies.get(target.t.fid) ) {
							var tx = if( f._x > target.t.root._x ) 20 else -20;
							f.tween().to( Math.random()*.5, _x = f._x + tx ).fx( TFx.TLoopEaseIn ).loop(5);
							f.tween().to( 2, _y = -20 - Math.random() * target.t.root._height ).onComplete( function(t) {
								if( --count == 0 ) nextStep();
							} );
							count ++;
						}
						//
						Sprite.spriteList.remove(target.t);
						target.t.root.tween().to( 2, _y = -40 );
					}
					nextStep();
				}
			case 4:
				for( target in list ) {
					for( f in fairies.get(target.t.fid) )
						f.removeMovieClip();
					target.t.kill();
				}
				fairies = null;
				end();
		}
	}
}























