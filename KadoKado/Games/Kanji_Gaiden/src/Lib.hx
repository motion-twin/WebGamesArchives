
typedef Point = {x:Float,y:Float}

class Num {//}
	static public function mm(a,b,c){
		return Math.min(Math.max(a,b),c);
	}
	static public function sMod(n:Float,mod:Float){
		if( mod==0 || mod == null || n == null )return null;

		while(n>=mod)n-=mod;
		while(n<0)n+=mod;
		return n;
	}
	static public function hMod(n:Float,mod:Float){
		if( mod==0 || mod == null || n == null )return null;
		while(n>mod)n-=mod*2;
		while(n<-mod)n+=mod*2;
		return n;
	}

	static public function rnd(n:Int,f:Float){
		return Std.int(Math.pow(Math.random(),f)*n);
	}


//{
}

class Geom {
	static public function getDist(o1:Point,o2:Point){
		var dx = o1.x-o2.x;
		var dy = o1.y-o2.y;
		return Math.sqrt(dx*dx+dy*dy);
	}
	static public function getAng(o1:Point,o2:Point){
		var dx = o1.x-o2.x;
		var dy = o1.y-o2.y;
		return Math.atan2(dy,dx);
	}

	static public function getParentCoord(mc:flash.MovieClip,parent:flash.MovieClip){
		var par = null;
		var to = 0;

		var x:Float = mc._x;
		var y:Float = mc._y;

		while(true){
			par = mc._parent;
			if( par._rotation != 0 ){
				var dist = Math.sqrt(x*x + y*y);
				var a  = Math.atan2(y,x);
				a += par._rotation*0.0174 ;
				x = Math.cos(a)*dist;
				y = Math.sin(a)*dist;
			}

			x *= par._xscale*0.01;
			y *= par._yscale*0.01;

			x += par._x;
			y += par._y;

			if( par == parent || par==flash.Lib._root ){
				return {x:x,y:y};
			}
			mc = par;
			if(to++>20){
				trace("GET PARENT COORD ERROR");
				break;
			}
		}


		return null;
	}

}

class Col {//}
	static public function colToObj(col){
		return {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
	}
	static public function objToCol(o){
			return (o.r << 16) | (o.g<<8 ) | o.b;
	}
	static public function colToObj32(col){
		return {
			a:col>>>24,
			r:(col>>16)&0xFF,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
	}
	static public function objToCol32(o){
			return (o.a << 24) | (o.r << 16) | (o.g<<8 ) | o.b;
	}

	static public function setPercentColor( mc, prc:Float, col, ?inc:Float ){
		if(inc==null)inc=0;
		var color = colToObj(col);
		var co = new flash.Color(mc);
		var c  = prc/100;
		var ct = { _ : null };
		var cprc = Std.int(100-prc);
		untyped {
			ct["ra"] = cprc;
			ct["ga"] = cprc;
			ct["ba"] = cprc;
			ct["aa"] = 100;
			ct["rb"] = Std.int(c*color.r + inc );
			ct["gb"] = Std.int(c*color.g + inc );
			ct["bb"] = Std.int(c*color.b + inc );
			ct["ab"] = 0;
		};
		co.setTransform( cast ct );
	}
	static public function setColor( mc, col, ?dec ){
		if(dec==null)dec =-255;
		var o = colToObj32(col);
		var co = new flash.Color(mc);

		var ct = { _ : null };
		untyped {
			ct["ra"] = 100;
			ct["ga"] = 100;
			ct["ba"] = 100;
			ct["aa"] = 100;
			ct["rb"] = Std.int(o.r+dec);
			ct["gb"] = Std.int(o.g+dec);
			ct["bb"] = Std.int(o.b+dec);
			ct["ab"] = 0;
		};



		/*
		var ct = {
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:o.r+dec,
			gb:o.g+dec,
			bb:o.b+dec,
			ab:0
		};
		*/

		co.setTransform( cast ct );
	}

	static public function mergeCol(col:Int,col2:Int,?c){
		if(c==null)c=0.5;
		var o = Col.colToObj(col);
		var o2 = Col.colToObj(col2);
		var o3 = {
			r:Std.int(o.r*c+o2.r*(1-c)),
			g:Std.int(o.g*c+o2.g*(1-c)),
			b:Std.int(o.b*c+o2.b*(1-c))
		}
		return Col.objToCol(o3);
	}
	static public function mergeCol32(col:Int,col2:Int,?c){
		if(c==null)c=0.5;
		var o = Col.colToObj32(col);
		var o2 = Col.colToObj32(col2);
		var o3 = {
			r:Std.int(o.r*c+o2.r*(1-c)),
			g:Std.int(o.g*c+o2.g*(1-c)),
			b:Std.int(o.b*c+o2.b*(1-c)),
			a:Std.int(o.a*c+o2.a*(1-c))
		}
		return Col.objToCol32(o3);
	}

	static public function getRainbow(?c){
		if(c==null)c = Math.random();
		var max = 3;
		var a:Array<Float> = [0.0,0.0,0.0];

		var part =  (1/max*2);

		for( i in 0...max ){
			var med = part+i*2*part;
			var dif = Num.hMod( med-c, 0.5 );
			a[i] = Math.min( 1.5-Math.abs(dif)*3 ,1);
		}
		return {
			r:Std.int(a[0]*255),
			g:Std.int(a[1]*255),
			b:Std.int(a[2]*255)
		}
	}
	static public function shuffle(col:Int,inc:Int){
		var o  = colToObj(col);
		o.r = Std.int( Num.mm( 0, o.r+(Math.random()*2-1)*inc ,255 ) );
		o.g = Std.int( Num.mm( 0, o.g+(Math.random()*2-1)*inc ,255 ) );
		o.b = Std.int( Num.mm( 0, o.b+(Math.random()*2-1)*inc ,255 ) );
		return objToCol(o);


	}


	/*
	static public function setColorMatrix(mc, m, dec){
		if(dec!=null){
			m = m.duplicate();
			for( i in 0...3 ){
				m[4+5*i] = dec;
			}
		}
		var fl = new flash.filters.ColorMatrixFilter();

		fl.matrix = m;
		mc.filters = [fl];
	}
	*/




//{
}

class Str{
	static public function searchAndReplace(str:String,search:String,replace:String){
		return str.split(search).join(replace);
	}
}


class Filt{//}
	static public function glow(mc:flash.MovieClip,?bl:Float,?str:Float,?col,?inner){

		if(bl==null)	bl=2;
		if(str==null)	str=10;
		if(col==null)	col=0;
		if(inner==null)	inner=false;

		var fl = new flash.filters.GlowFilter();
		fl.blurX = bl;
		fl.blurY = bl;
		fl.strength = str;
		fl.color = col;
		fl.inner = inner;

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;


	}
	static public function blur(mc:flash.MovieClip,?blx:Float,?bly:Float){
		if(blx==null)blx = 0;
		if(bly==null)bly = 0;

		var fl = new flash.filters.BlurFilter();
		fl.blurX = blx;
		fl.blurY = bly;

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;

	}
	static public function grey( mc:flash.MovieClip, ?c:Float, ?inc:Int, ?o, ?m1 ){
		if(c==null)	c = 1;
		if(inc==null)	inc = 0;
		if(o==null)	o = {r:0,g:0,b:0};

		var m0 = [
			1,	0,	0,	0,	0,
			0,	1,	0,	0,	0,
			0,	0,	1,	0,	0,
			0,	0,	0,	1,	0
		];


		if(m1==null){
			var r = 0.25;
			var g = 0.15;
			var b = 0.6;
			m1 = [
				r,	g,	b,	0,	o.r+inc,
				r,	g,	b,	0,	o.g+inc,
				r,	g,	b,	0,	o.b+inc,
				0,	0,	0,	1,	0,

			];
		}

		var m = [];
		for( i in 0...m0.length ){
			m[i] = m0[i]*(1-c) + m1[i]*c;
		}

		var fl = new flash.filters.ColorMatrixFilter();
		fl.matrix = m;

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;


	}
//{
}


class Tween{

	public var sx:Float;
	public var sy:Float;
	public var ex:Float;
	public var ey:Float;

	public function new(?sx:Float,?sy:Float,?ex:Float,?ey:Float){
		this.sx = sx;
		this.sy = sy;
		this.ex = ex;
		this.ey = ey;
	}

	public function getPos(c:Float){
		return {
			x: sx*(1-c) + ex*c,
			y: sy*(1-c) + ey*c
		};
	}

}




























