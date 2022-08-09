package part;
import mt.bumdum.Lib;
typedef Ray = { > Phys, t:Fighter };

class TwistingRay extends fx.GroupEffect {
	var rays:Array<Ray>;

	public function new( f ) {
		super(f,list);
		spc = 0.10;

		rays = [];
		var id = 0;
		for( i in 0...20 ){
			var ray:Ray = cast new Phys( Scene.me.dm.attach("mcRay",Scene.DP_FIGHTER) );
			ray.x = caster.x;
			ray.y = caster.y+0.2*id;
			ray.z = -((caster.height-caster.z)+30);
			ray.setScale(200 + Std.random(150));
			ray.vr = (Math.random() * 2 - 1) * 1.5;
			ray.root._rotation = Math.random() * 360;
			//disc.ray = 25 ;
			id++;
			rays.push(ray);
			//Filt.glow(ray.root, 1, 4, 0xFFFFFF, false);
		}
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				if(coef==1) {
				//for( r in rays ) r.kill();
				end();
				}
		}
	}
}
