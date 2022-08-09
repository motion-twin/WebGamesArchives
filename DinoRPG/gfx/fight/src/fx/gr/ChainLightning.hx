package fx.gr;
import mt.bumdum.Lib;

import Fight;

class ChainLightning extends fx.GroupEffect{

	var segments:Array<{x:Float,y:Float,flZap:Bool}>;
	var targets:Array<{t:Fighter,life:Int}>;
	var cid:Int;
	var clength:Int;
	var mcDraw:flash.MovieClip;

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.03;
		targets = list.copy();

		mcDraw = Scene.me.dm.empty(Scene.DP_PARTS);
		mcDraw.blendMode = "add";
		Filt.glow(mcDraw,10,1,0xFFFF00);

		var units = 20;
		var px = caster.root._x;
		var py = caster.root._y;
		segments = [{x:px,y:py,flZap:false}];
		clength = 20;
		cid = -clength;

		for( o in list ){
			var tdx = o.t.root._x - px;
			var tdy = o.t.root._y - py;
			var dist = Math.sqrt(tdx*tdx+tdy*tdy);
			var k = Math.ceil(dist/units);
			for( i in 0...k ){
				var c = (i+1)/k;
				segments.push({ x:px+c*tdx, y:py+c*tdy, flZap:c==1  });
			}
			px += tdx;
			py += tdy;
		}
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				updateAura(3,caster.skinBox);
				for( i in 0...2)genRayConcentrate();
				if(coef==1){
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
				}
			case 1:
				mcDraw.clear();
				// DRAW
				var a = [];
				cid++;
				for( i in cid...cid+clength){
					var p = segments[i];
					if( p !=null ){
						a.push(p);
					}
					if( p.flZap ){
						var o = targets.shift();
						if(  o.life != null )
							o.t.damages(o.life,20,_LLightning);
						p.flZap = false;
					}
				}

				if( a.length>1 ){
					mcDraw.lineStyle(1,0xFFFFFF,100);
					var first = a.shift();
					mcDraw.moveTo(first.x,first.y);
					var ec = 6;
					var id = 0;
					var half = a.length*0.5;

					for( p in a ){
						var c = (1-Math.abs(id-half)/half);
						mcDraw.lineStyle(1+c*4,0xFFFFFF,100);
						mcDraw.lineTo( p.x+(Math.random()*2-1)*ec, p.y+(Math.random()*2-1)*ec );
						id++;
					}
				}

				if( cid> segments.length ){
					mcDraw.removeMovieClip();
					end();

				}
		}
	}
}
