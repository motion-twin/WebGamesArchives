package fx;

import mt.bumdum.Lib;

class Hypnose extends State{//}

	var step:Int;
	var caster:Fighter;
	var trg:Fighter;
	var move:Tween;
	var proj:Tween;

	public function new( f, t ) {
		super();
		caster = f;
		trg = t;
		addActor(f);
		addActor(t);
		spc = 0.05;
		step = 0;
	}
	
	override function init(){
		super.init();
		proj = new Tween(caster.x,caster.y,trg.x,trg.y);
	}

	public override function update(){
		super.update();
		if(castingWait)return;

		switch(step){
			case 0:
				var pos = proj.getPos(coef);
				for( i in 0...2 ){
					var p = fxStar();
					p.x = pos.x+(Math.random()*2-1)*10;
					p.y = pos.y+(Math.random()*2-1)*10;
					p.z = (Math.random()*2-1)*10-20;
				}

				if(coef==1){
					trg.playAnim("Jump");
					var py = Scene.getRandomPYPos();
					move = new Tween(trg.x,trg.y,caster.x,py);
					coef = 0;
					step++;
				}
			case 1:
				var p = move.getPos(coef);

				trg.x = p.x;
				trg.y = p.y;
				trg.z = -Math.sin(coef*3.14)*120;

				for( i in 0...2 ){
					var p = fxStar(trg);
				}

				if( coef == 1 ){

					for( i in 0...36 ){
						var p = fxStar(trg);
						var dx = p.x-trg.x;
						var dy = p.y-trg.y;
						var a = Math.atan2(dy,dx);
						var dist = Math.sqrt(dx*dx+dy*dy);
						p.vx = Math.cos(a)*dist*0.4;
						p.vy = Math.sin(a)*dist*0.4;
						p.vz = dist-10;
					}

					trg.setSide(caster.side);
					//trace(caster.side);
					trg.setSens(1);
	
					trg.playAnim("land");
					end();
				}
		}
		//if(coef==1)end();
	}

	function fxStar(?trg){
		var p = new Part(Scene.me.dm.attach("fxStar3",Scene.DP_FIGHTER));
		p.timer = 10+Math.random()*10;
		p.fadeType = 0;
		p.weight = -(0.1+Math.random()*0.2);
		p.root._rotation = Math.random()*360;
		p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
		if(trg!=null){
			p.x = trg.x +(Math.random()*2-1)*10;
			p.y = trg.y +(Math.random()*2-1)*10;
			p.z = trg.z +(Math.random()*2-1)*10 - 20;
		}

		return p;
	}

//{
}























