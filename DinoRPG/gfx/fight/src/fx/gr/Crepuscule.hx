package fx.gr;
import mt.bumdum.Lib;

import Fight;

typedef Meteork = {>Phys,tx:Float,dm:mt.DepthManager,life:Int,t:Fighter};

class Crepuscule extends fx.GroupEffect{//}

	static var SHADE = 150;

	var mcCrep:flash.MovieClip;
	var meteors:Array<Meteork>;

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.02;

		mcCrep = Scene.me.dm.attach("mcCrepuscule",Scene.DP_SHADE);
		mcCrep._y = -150;
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				updateAura(0,caster.skinBox);
				for( i in 0...2)genRayConcentrate();
				fade(coef);
				if(coef==1){
					caster.playAnim("release");
					nextStep();
					spc = 0.025;
					initMeteors();
				}
			case 1:
				updateAura(0,caster.skinBox,1);
				for( i in 0...meteors.length ){
					//var o = list[i];
					var sp = meteors[i];
					// PARTS LIGHTNING
					for( n in 0...2 ){
						var p = new mt.bumdum.Phys( sp.dm.attach("mcBolt",0));
						p.x = (Math.random()*2-1)*16;
						p.y = (Math.random()*2-1)*16;
						p.vx = -Math.random()*sp.vx*caster.intSide;
						p.root._rotation = Math.random()*360;
						p.root.blendMode = "add";
						Filt.glow(p.root,10,2,0xFFFF00);
						p.setScale( 100+Math.random()*100 );
					}
					// CHECK COL
					if( (sp.x-sp.tx)*caster.intSide > 0 ){

						sp.t.fxBurst("fxFireSpark", 12);
						if(  sp.life != null )
							sp.t.damages( sp.life, 30, _LLightning );
						meteors.splice(i,1);
						//i--;
						sp.kill();
					}

				}
				if( meteors.length==0 ){
					caster.backToDefault();
					coef = 0.1;
					nextStep();
				}
			case 2:
				fade(1-coef);
				updateAura(0,caster.skinBox,1-coef);
				if(coef==1){
					caster.skinBox.filters = [];
					mcCrep.removeMovieClip();
					end();
				}
		}
	}

	function initMeteors(){
		meteors = [];
		var w= Cs.mcw*0.5;
		for( o in list ){
			var sp:Meteork = cast new Phys( cast Scene.me.dm.attach("mcMeteor",Scene.DP_FIGHTER) );

			sp.x = w - (w+50)*caster.intSide;
			sp.tx = o.t.x;
			sp.y = o.t.y;
			sp.z = -20;
			sp.vx = 22*caster.intSide;
			sp.dropShadow();
			sp.setScale(130);
			sp.root._xscale *= caster.intSide;
			sp.dm = new mt.DepthManager(sp.root);
			sp.t = o.t;
			sp.life = o.life;
			Col.setColor(sp.root,0,Std.int(SHADE));
			meteors.push(sp);
			sp.updatePos();

		}
	}

	function fade(c:Float){
		var inc = Std.int(SHADE*c);
		Col.setColor(Scene.me.root, 0,-inc );
		mcCrep._y = -SHADE*(1-c);
		Col.setColor(caster.root,0,inc);
		for(o in list )Col.setColor(o.t.root,0,inc);
	}

//{
}























