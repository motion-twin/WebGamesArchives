import snake3.Const;

class snake3.BackgroundFX {

	var fx_mc;
	var points;

	function BackgroundFX( mc, npoints ) {
		npoints = 0;
		fx_mc = Std.createEmptyMC(mc,0);
		points = new Array();
		var i;
		for(i=0;i<npoints;i++) {
			points.push({
				x : random(Const.WIDTH),
				y : random(Const.HEIGHT), 
				a : random(180) / Math.PI,
				da : (random(180) - 90) / Math.PI / 1000,
				s : 1+random(200)/100,
				k : 50+random(50)
			});
		}
	}

	function draw(pcalc,scale,color) {
		var pi = Math.PI;
		var pi4 = Math.PI/4;
		var pi2 = Math.PI/2;
		var sq2 = Math.sqrt(2);

		fx_mc.lineStyle(0,color,100);

		var i;
		for(i=0;i<pcalc.length;i++) {
			var c = pcalc[i];
			var p = points[i];
			var xd = c.xd * scale;
			var yd = c.yd * scale;
			var x = p.x;
			var y = p.y;

			fx_mc.moveTo(x,y-yd);
			fx_mc.beginFill(color,100);			
			fx_mc.curveTo(x+xd,y-yd,x+xd,y);
			fx_mc.curveTo(x+xd,y+yd,x,y+yd);
			fx_mc.curveTo(x-xd,y+yd,x-xd,y);
			fx_mc.curveTo(x-xd,y-yd,x,y-yd);
			fx_mc.endFill();
		}
	}

	function main() {
		var i,j;

		fx_mc.clear();

		var pcalc = new Array();
		for(i=0;i<points.length;i++) {
			var p = points[i];
			var s = p.s * Std.tmod;
			p.a += p.da;
			p.x += Math.cos(p.a) * s;
			p.y += Math.sin(p.a) * s;

			var xd = 1, yd = 1;
			for(j=0;j<points.length;j++) 
				if( i != j ) {
					var p2 = points[j];
					var dx = p2.x - p.x;
					var dy = p2.y - p.y;
					var dist = Math.max(20,Math.sqrt(dx * dx + dy * dy));
					var a = Math.atan2(dy,dx);
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					xd += Math.abs(ca * 20000 / dist);
					yd += Math.abs(sa * 20000 / dist);
					if( dist < p.k ) {
						p.x -= ca * 100 / dist;
						p.y -= sa * 100 / dist;
					}
				}
			if( p.x > Const.WIDTH )
				p.x = Const.WIDTH;
			else if( p.x < 0 )
				p.x = 0;
			if( p.y > Const.HEIGHT )
				p.y = Const.HEIGHT;
			else if( p.y < 0 )
				p.y = 0;

			if( xd / yd > 3 )
				xd = yd * 3;
			else if( yd / xd > 3 )
				yd = xd * 3;
			var alpha = 0;
			var tot = Math.sqrt(xd * xd + yd * yd);
			xd /= tot;
			yd /= tot;
			xd *= p.k;
			yd *= p.k;
			pcalc.push({ xd : xd, yd : yd });
		}
		draw(pcalc,6.5,0x8EDE36);
		draw(pcalc,4.0,0x86D72C);
		draw(pcalc,2.9,0x7ED123);
// 		draw(pcalc,3.5,0x8EDE36);
// 		draw(pcalc,2.0,0x86D72C);
// 		draw(pcalc,0.9,0x7ED123);
	}

	function close() {
		fx_mc.removeMovieClip();
	}

}