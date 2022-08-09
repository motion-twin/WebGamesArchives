package fx.gr;

import mt.bumdum.Lib;
import Fight;

class Lightning extends fx.GroupEffect{

	var lights:Array<Sprite>;

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.03;
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				updateAura(3,caster.skinBox);
				for( i in 0...2)genRayConcentrate();
				if(coef == 1){
					lights = [];
					for( o in list ){
						var sp = new Sprite(Scene.me.dm.empty(Scene.DP_FIGHTER));
						sp.x = o.t.x;
						sp.y = o.t.y-0.5;
						sp.root.blendMode = "add";
						Filt.glow(sp.root,10,2,0xFFFF00);
						lights.push(sp);
						o.t.shake = 40;
						if(  o.life != null )
							Col.setPercentColor(o.t.skinBox,100,0);
					}
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
					spc = 0.025;
				}
			case 1:
				var id = 0;
				for ( sp in lights ) {

					var f = list[id].t;
					sp.root.clear();
					for( i in 0...3 ){
						var y = 0.0;
						var ec = 20.0;
						sp.root.lineStyle(i+1,0xFFFFFF,100);
						sp.root.moveTo((Math.random()*2-1)*f.ray,0);
						while(true){
							y -= (30+Math.random()*30);
							var x = (Math.random()*2-1)*ec;
							sp.root.lineTo(x,y);
							ec *= 0.5;
							if( sp.root._y+y < 0 )break;
						}
					}
					// BOLT
					var mc = f.bdm.attach("mcBolt",Fighter.DP_FRONT);
					mc._x = (Math.random()*2-1)*f.ray;
					mc._y = -Math.random()*f.height;
					mc._rotation = Math.random()*360;
					mc.blendMode = "add";
					Filt.glow(mc,10,2,0xFFFF00);
					mc._xscale = mc._yscale = 100+Math.random()*100;

					id++;
				}
				if(coef==1){
					for( sp in lights )sp.kill();
					for(o in list) if(  o.life != null ) Col.setPercentColor(o.t.skinBox,0,0);
					damageAll();
					end();
				}
		}
	}
}
