import Data;
import mt.bumdum.Lib;

typedef MC = flash.MovieClip;
typedef TF = flash.TextField;

typedef Glad = {
	var id : Int;
	var gfx : String;
	var lvl : Int;
	var name : String;
	var user : String;
	var match : Int;
	var clips : Array<MC>;
}

class Tournoi {//}

	static inline var WIDTH = 800;
	static inline var HEIGHT = 600;
	static inline var TOTAL_MATCHES = 6;

	static var GLOW = new flash.filters.GlowFilter(0xFFFFFF,1.0,5,5,20);

	static var CORNERS = [[0,6],[0,0],[0,0],[40,0],[0,0],[0,0],[0,0]];

	/*
	static var DISABLE = {
		var blend = 0x990000;
		var k = 0.3;
		new flash.filters.ColorMatrixFilter([
			0.3,0.2,0.2,0,((blend >> 16) & 0xFF) * k,
			0.2,0.3,0.2,0,((blend >> 8) & 0xFF) * k,
			0.2,0.2,0.3,0,(blend & 0xFF) * k,
			0,0,0,1.0,0,
		]);
	}
	*/
	static var DISABLE = null;
	var data : TournamentData;
	var dm : mt.DepthManager;
	var base : MC;
	var links : MC;
	var brute : MC;
	var podium:MC;
	var blinks : Array<MC>;
	var brutes : Hash<flash.display.BitmapData>;
	var root : MC;
	var curMatch : Int;
	var maxMatches : Int;
	var tip : {> MC, name : TF, user : TF, lvl : TF, p : MC };

	function new(root:flash.MovieClip) {
		this.root = root;
		base = 	root.createEmptyMovieClip("base",0);
		base.onMouseMove = scroll;
		dm = new mt.DepthManager(base);
		dm.attach("mcBg",0);
		links = dm.empty(0);
		links.lineStyle(4,0xFAF8C3);
		var bl = 3;
		var fl = new flash.filters.GlowFilter(0x771100,0.4,bl,bl,4,1,false,false);
		links.filters = [fl];

		dec = 0;
		blinks = [];

		tip = cast dm.attach("tip",2);
		tip._visible = false;
		try {
			data = Codec.getData("data");
		} catch( e : Dynamic ) {
			var g = new Array();
			var flag = true;
			var max = 64;
			for( i in 0...max ) {
				var gfx = [Std.random(2),0];
				for( p in 0...20 )
					gfx.push(Std.random(100));
				g.push({ _id : i, _u : "player"+i, _n : "brute"+i, _lvl : Std.random(100)+1, _gfx : gfx.join(";"), _m : 0 });

			}
			data = {
				_glads : g,
				_perso : "../../www/swf/perso.swf",
				_fight : null,
				_view : null,
				_user : "player"+Std.random(max),
				_league:Std.random(11),
				_max : max,
			};
			var all = g.copy();
			while( all.length > 1 ) {
				var next = new Array();
				var i = 0;
				while( i < all.length ) {
					var g = (Std.random(2) == 0) ? all[i] : all[i+1];
					g._m++;
					next.push(g);
					i += 2;
				}
				all = next;
			}
		}
		curMatch = 0;
		for( g in data._glads )
			if( g._m > curMatch )
				curMatch = g._m;
		brutes = new Hash();

		load();

	}

	function scroll() {
		tip._x = if( base._xmouse < WIDTH / 2 ) base._xmouse + 10 else base._xmouse - (tip._width + 10);
		tip._y = base._ymouse + 10;
		var h = tip._y + base._y + tip._height;
		if( h > HEIGHT )
			tip._y -= h - HEIGHT;
		if( tip._y < 0 )
			tip._y = 0;
	}

	function load() {
		var mcl = new flash.MovieClipLoader();
		var cont = dm.empty(0);
		var loaded = false;
		var me = this;
		cont._visible = false;
		brute = cont.createEmptyMovieClip("empty",0);
		mcl.onLoadInit = mcl.onLoadComplete = function(_) if( loaded ) me.init() else loaded = true;
		mcl.loadClip(data._perso,brute);
	}

	function init() {
		
		// init all brutes
		var count = 10;
		for( g in data._glads ) {
			if( brutes.exists(g._gfx) )
				continue;
			Reflect.callMethod(brute,Reflect.field(brute,"_init"),[g._gfx]);
			var bmp = new flash.display.BitmapData(100,160,true,0);
			bmp.draw(brute);
			brutes.set(g._gfx,bmp);
			if( --count == 0 ) {
				haxe.Timer.delay(init,1);
				return;
			}
		}
		
		podium = dm.attach("mcPodium", 1);
		podium._x = WIDTH * 0.5;
		podium._y = HEIGHT - 60;
		podium.smc.gotoAndStop(data._league+1);
		
		// done
		brute.removeMovieClip();
		var infos = new Array();
		var i = 0;
		while( i < data._glads.length ) {
			var g0 = makeG(data._glads[i]);
			var g1 = makeG(data._glads[i+1]);
			infos.push({ g0 : g0, g1 : g1 });
			i += 2;
		}
		
		maxMatches = 0;
		while( 1 << maxMatches < data._max )
			maxMatches++;
		doDisplayRec(infos,TOTAL_MATCHES - maxMatches);
	}

	function makeG(g) : Glad {
		if( g == null ) return null;
		return {
			id : g._id,
			gfx : g._gfx,
			name : g._n,
			user : g._u,
			match : g._m,
			clips : [],
			lvl : g._lvl,
		};
	}

	function initTip( p : MC, g : Glad ) {
		if( g == null ) return;
		var me = this;
		p.onRollOver = function() {
			var filters = [GLOW];
			if( g.match < me.curMatch )
				filters.unshift(cast DISABLE);
			for( mc in g.clips )
				mc.filters = filters;
			var t = me.tip;
			t.name.text = g.name;
			t.user.text = g.user;
			t.lvl.text = Std.string(g.lvl);
			t.p.attachBitmap(me.brutes.get(g.gfx),0,null,true);
			t._visible = true;
		};
		p.onRollOut = function() {
			var filters = [];
			if( g.match < me.curMatch )
				filters.push(DISABLE);
			for( mc in g.clips )
				mc.filters = filters;
			me.tip._visible = false;
		}
		p.onPress = function() {
			if( me.data._view != null )
				flash.Lib.getURL(me.data._view+g.id,"_self");
		}
	}

	function initSlot( p : MC, g : Glad ) {

		p.attachBitmap(brutes.get(g.gfx),0,null,true);
		if( g.match < curMatch ) p.filters = [DISABLE];
		g.clips.push(p);
		if( g.user == data._user ) blinks.push(p);
		initTip(p,g);
	}

	function doDisplay(infos:Array<{ g0 : Glad, g1 : Glad }>,count:Int) {

		var dx = 100 - count*10;

		var dist = [350,250,190,130,100,50];
		var scales = [50,50,50,70,85,100,100];

		for( i in 0...infos.length ) {
			var inf = infos[i];

			var vs : {>MC,p0:MC,p1:MC,vs:MC} = cast dm.attach("vs",0);

			var p = getPos(i,count);

			vs._x = p.x;
			vs._y = p.y;
			vs._xscale = vs._yscale = scales[count];
			initSlot(vs.p0,inf.g0);
			initSlot(vs.p1,inf.g1);
			if( inf.g0.match < curMatch || inf.g1.match < curMatch ) {
				var me = this;
				vs.vs.onPress = function() {
					flash.Lib.getURL(me.data._fight+"b1="+inf.g0.id+";b2="+inf.g1.id,"_self");
				}
			} else
				vs.vs._visible = false;

			if( count > TOTAL_MATCHES-maxMatches ) {
				for( k in 0...2 ){
					var p = getPos(i*2+k,count-1);
					var co = CORNERS[count-1];
					var div = Math.pow(2,TOTAL_MATCHES-(2+count));
					var sx = Std.int(i/div)*2-1;
					var sy = k*2-1;
					var bx = vs._x - co[0]*sx;
					var px = p.x;
					var py = p.y + co[1]*sy;

					links.moveTo(bx,vs._y);
					links.lineTo(bx,py);
					links.lineTo(px,py);


				}
			}
			if( count == TOTAL_MATCHES-1 && vs.vs._visible ) {
				var winner = inf.g0;
				if( inf.g0.match < inf.g1.match ) winner = inf.g1;
				var bmp = podium.createEmptyMovieClip("bmp",0);
				bmp.attachBitmap( brutes.get(winner.gfx),0,null,true );
				bmp._y = -165;
				bmp._x = 45;
				bmp._xscale *= -1;
			}
		}


	}

	function getPos(i,count){
		var dist = [350,250,190,130,100,50,25,10,5,0,0,0,0,0];
		var div = Math.pow(2,TOTAL_MATCHES-(2+count));
		var side = Std.int(i/div)*2-1;
		if( count == TOTAL_MATCHES-1 ){
			return { x:WIDTH*0.5, y:60.0 };
		}

		return {
			x : WIDTH*0.5 + side * dist[count],
			y : 10 + ((i%div)+ 0.5) * 36 * Math.pow(2,count),
		}
	}

	function doDisplayRec(infos:Array<{ g0 : Glad, g1 : Glad }>,count:Int) {

		if( count == 0 && infos.length < data._max>>1 ) {

			var col = 9;
			var lines = 7;
			var n = 0;
			var ec = 76;
			var mx = (WIDTH-(ec*col))*0.5;
			var my = (HEIGHT-(ec*lines))*0.5;
			for( o in infos ){
				var a = [o.g0,o.g1];
				for( gl in a ){
					if( n == 63 ) break;
					var mc = dm.attach("mcStartSlot",1);
					mc._x = mx + (n%col)*ec;
					mc._y = my + Std.int(n/col)*ec;
					mc.smc.attachBitmap(brutes.get(gl.gfx),0,null,true);
					mc.gotoAndStop(Std.random(4)+1);
					var fl = new flash.filters.DropShadowFilter(2,45,0x401000,0.25,0,0,4);
					mc.filters = [fl];
					dm.under(mc);
					initTip(mc,gl);
					n++;
				}
			}
			podium._visible = false;
			return;
		}

		doDisplay(infos,count);
		if( infos.length == 1 )
			return;
		// build next phase
		var inf = new Array();
		var i = 0;
		while( i < infos.length ) {
			var i0 = infos[i];
			var i1 = infos[i+1];
			if( i0.g1 == null || i1.g1 == null || (i0.g0.match == i0.g1.match) || (i1.g0.match == i1.g1.match) ) {
				inf.push(null);
				i += 2;
				continue;
			}
			inf.push({ g0 : if( i0.g0.match > i0.g1.match ) i0.g0 else i0.g1, g1 : if( i1.g0.match > i1.g1.match ) i1.g0 else i1.g1 });
			i += 2;
		}
		haxe.Timer.delay(callback(doDisplayRec,inf,count+1),1);
	}

	static var inst : Tournoi;
	static function main() {
		inst = new Tournoi(flash.Lib.current);
		flash.Lib.current.onEnterFrame = inst.update;

	}

	var dec:Int;
	function update(){
		dec = (dec+43)%628;
		for( mc in blinks ){
			var prc = Math.cos(dec*0.01)*200 - 100;
			if( prc < 0 ) prc = 0;
			Col.setPercentColor(mc,prc,0xFFFFFF);
		}
	}


//{
}
