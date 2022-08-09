package fx;

import mt.bumdum.Lib;

class Snow extends State {

	var caster:Fighter;
	var id:Int;
	var glowColor:Int;
	var rainbowPercent:Int;

	public function new( f, id, glowColor, rainbowPercent ) {
		super();
		this.id = id;
		this.glowColor = glowColor;
		this.rainbowPercent = rainbowPercent;
		caster = f;
		addActor(f);
		spc = 0.01;
	}

	override function init(){
		caster.playAnim("cast");
	}

	public override function update(){
		super.update();
		if(castingWait)return;

		if( coef < 0.9 && Std.random(2)==0 ){
			var d = Fighter.DP_BACK;
			if(Std.random(2) == 0)d = Fighter.DP_FRONT;
			var p = new sp.Petal( caster.bdm.attach("partAuraSnow",d) );
			p.x = (Math.random()*2-1)*caster.ray;
			p.y = -(caster.height+Math.random()*4);
			p.vy = Math.random()*2;
			p.weight = 0.1+Math.random()*0.2;
			p.timer = 10+Math.random()*20;
			p.root._rotation = Math.random()*360;
			p.fadeType = 0;
			p.root.gotoAndStop(id+1);

			Filt.glow(p.root,4,2,glowColor);
			var co = Col.getRainbow(Math.random());
			Col.setPercentColor(p.root.smc, rainbowPercent, Col.objToCol(co) );
		}

		if(coef==1){
			caster.backToDefault();
			end();
		}

	}
}























