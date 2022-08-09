package fx;

import mt.bumdum.Lib;

class Aura extends State {

	var caster:Fighter;
	var color:Int;
	var id:Int;
	var type:Int;

	public function new( f, c, ?id, ?type ) {
		super();
		this.type = type;
		this.id = id;
		caster = f;
		color = c;
		addActor(f);
		spc = 0.05;
	}

	override function init() {
		super.init();
		var ray = 20;
		var pmax = 0;
		var sp = 0.3;
		switch(type){
			case 0:
				pmax = 36;
			case 1:
				pmax = 72;
				sp = 3;
				var mc = Scene.me.dm.attach("mcDetonation", Scene.DP_PARTS);
				mc._x = caster.root._x;
				mc._y = caster.root._y - caster.height * .5;
				Filt.blur(mc, 4, 4);
				mc.blendMode = "overlay";
		}

		for( i in 0...pmax ) {
			var cx = (Math.random() * 2 - 1);
			var cy = (Math.random() * 2 - 1);
			var p = new Part( Scene.me.dm.attach("fxFireSpark", Scene.DP_FIGHTER) );
			p.x = caster.x + cx*ray;
			p.y = caster.y + cy*ray;
			p.vx = cx*sp;
			p.vy = cy*sp;
			p.root.stop();
			p.z = -Math.random()*caster.height;
			p.weight = 0.5+Math.random()*0.5;
			p.groundFrict = 0.5;
			p.vz = -(5+Math.random()*10);
			p.timer = 20+Math.random()*80;
			p.fadeType = 0;
			p.onBounce = function(){ if(p.root._currentframe == 1) p.root.gotoAndPlay(10); };
		}
	}

	public override function update(){
		super.update();
		if( castingWait ) return;

		switch(id){
			case null:
				if(coef < 0.9){
					for( i in 0...2 ){
						var d = Fighter.DP_BACK;
						if(Std.random(2)==0)d = Fighter.DP_FRONT;
						var p = new mt.bumdum.Phys( caster.bdm.attach("partAura2",d) );
						p.x = (Math.random()*2-1)*caster.ray;
						p.y = -Math.random()*caster.height;
						p.timer = 10+Math.random()*10;
						p.vr = (Math.random()*2-1)*20;
						p.fr = 0.95;
						p.root._rotation = Math.random()*360;
						p.root.smc._x = Math.random()*12;
						p.root.smc._xscale = p.root.smc._xscale = 100+Math.random()*100;
						p.weight = -(0.1+(Math.random()*0.2));
						//Col.setPercentColor(p.root,100,color);
						p.root.blendMode = "add";
						Filt.glow(p.root,10,1,color);
						p.fadeType = 0;
					}
				}
			default :
				if( coef < 0.9 && Std.random(2) == 0 ){
					var d = Fighter.DP_BACK;
					if(Std.random(3)==0)d = Fighter.DP_FRONT;
					var p = new mt.bumdum.Phys( caster.bdm.attach("partAura",d) );
					p.x = 0;
					p.y = -10;
					p.timer = 20;
					p.vr = (Math.random()*2-1)*2;
					p.root.smc.gotoAndStop(id+1);
					p.root._rotation = -(p.vr*10);
					p.root._xscale = (Std.random(2)*2-1)*(50+Math.random()*50);
					p.root._yscale = 50+Math.random()*50;
					if(d==Fighter.DP_FRONT)p.root.blendMode = "overlay";
					caster.bdm.under(p.root);
					Filt.glow(p.root,4,2,color);
				}
		}
		if(coef == 1) end();
	}
}
