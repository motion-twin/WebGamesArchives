package mt.deepnight;

#if (flash||nme||openfl)
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	#if haxe3
	import haxe.ds.StringMap.StringMap;
	#end
#end

enum Day {
	Sunday;
	Monday;
	Tuesday;
	Wednersday;
	Thursday;
	Friday;
	Saturday;
}

class Lib {
	public static inline function countDaysUntil(now:Date, day:Day) {
		var delta = Type.enumIndex(day) - now.getDay();
		return if(delta<0) 7+delta else delta;
	}

	public static inline function getDay(date:Date) : Day {
		return Type.createEnumIndex(Day, date.getDay());
	}

	public static inline function setTime(date:Date, h:Int, ?m=0,?s=0) {
		var str = "%Y-%m-%d "+StringTools.lpad(""+h,"0",2)+":"+StringTools.lpad(""+m,"0",2)+":"+StringTools.lpad(""+s,"0",2);
		return Date.fromString( DateTools.format(date, str) );
	}

	public static inline function countDeltaDays(now_:Date, next_:Date) {
		var now = setTime(now_, 5);
		var next = setTime(next_, 5);
		return Math.floor( (next.getTime() - now.getTime()) / DateTools.days(1) );
	}

	public static inline function leadingZeros(s:Dynamic, zeros:Int) {
		var str = Std.string(s);
		while (str.length<zeros)
			str="0"+str;
		return str;
	}
	
	#if neko
	public static function drawExcept<T>(a:List<T>, except:T, ?randFn:Int->Int):T {
		if (a.length==0)
			return null;
		if (randFn==null)
			randFn = Std.random;
		var a2 = new Array();
		for (elem in a)
			if (elem!=except)
				a2.push(elem);
		return
			if (a2.length==0)
				null;
			else
				a2[ randFn(a2.length) ];
			
	}
	#end
	
	#if flash9
	public static function redirectTracesToConsole(?customPrefix="") {
		haxe.Log.trace = function(m, ?pos)
		{
			try
			{
				if ( pos != null && pos.customParams == null )
					pos.customParams = ["debug"];
				
				flash.external.ExternalInterface.call("console.log", pos.fileName + "(" + pos.lineNumber + ") : " + customPrefix + Std.string(m));
			}
			catch(e:Dynamic) { }
		}
	}
	
	public static function isMac() {
		return flash.system.Capabilities.os.indexOf("mac")>=0;
	}
	
	public static function getFlashVersion() { // renvoie Float sous la forme "11.2"
		var ver = flash.system.Capabilities.version.split(" ")[1].split(",");
		return Std.parseFloat(ver[0]+"."+ver[1]);
	}

	public static function atLeastVersion(version:String) { // format : xx.xx.xx.xx ou xx,xx,xx,xx
		var s = StringTools.replace(version, ",", ".");
		var req = s.split(".");
		var fv = flash.system.Capabilities.version;
		var mine = fv.substr(fv.indexOf(" ")+1).split(",");
		for (i in 0...req.length) {
			if (mine[i]==null || req[i]==null)
				break;
			var m = Std.parseInt(mine[i]);
			var r = Std.parseInt(req[i]);
			if ( m>r )	return true;
			if ( m<r )	return false;
			
		}
		return true;
	}
	
	public static function getCookie(cookieName:String, varName:String, ?defValue:Dynamic) : Dynamic {
		var cookie = flash.net.SharedObject.getLocal(cookieName);
		return
			if ( Reflect.hasField(cookie.data, varName) )
				Reflect.field(cookie.data, varName);
			else
				defValue;
	}
	
	public static function setCookie(cookieName:String, varName:String, value:Dynamic) {
		var cookie = flash.net.SharedObject.getLocal(cookieName);
		Reflect.setField(cookie.data, varName, value);
		cookie.flush();
	}
	
	public static function resetCookie(cookieName:String, ?obj:Dynamic) {
		var cookie = flash.net.SharedObject.getLocal(cookieName);
		cookie.clear();
		if (obj!=null)
			for (key in Reflect.fields(obj))
				Reflect.setField(cookie.data, key, Reflect.field(obj, key));
		cookie.flush();
	}
	
	public static inline function constraintBox(o:flash.display.DisplayObject, maxWid, maxHei) {
		var r = Math.min( Math.min(1, maxWid/o.width), Math.min(1, maxHei/o.height) );
		o.scaleX = r;
		o.scaleY = r;
		return r;
	}
	
	public static inline function isOverlap(a:flash.geom.Rectangle, b:flash.geom.Rectangle) : Bool {
		return
			b.x>=a.x-b.width && b.x<=a.right &&
			b.y>=a.y-b.height && b.y<=a.bottom;
	}
	#end
	
	
	public static function shuffle<T>(l:Iterable<T>, ?rand:Int->Int) : Array<T> {
		if(rand==null)
			rand = Std.random;
		var arr = new Array();
		for (e in l)
			arr.insert(rand(arr.length), e);
		return arr;
	}
	
	public static function randomSpread(total:Int, pools:Int, ?maxPoolValue:Null<Int>, ?randFunc:Int->Int) : Array<Int> {
		if( randFunc==null )
			randFunc = Std.random;
			
		if (total<=0 || pools<=0)
			return new Array();
			
		if( total/pools>maxPoolValue ) {
			var a = [];
			for(i in 0...pools)
				a.push(maxPoolValue);
			return a;
		}
		
		var plist = new Array();
		for (i in 0...pools)
			plist[i] = 0;
			
		var remain = total;
		while (remain>0) {
			var move = Math.ceil(total*(randFunc(8)+1)/100);
			if (move>remain)
				move = remain;
			
			var p = randFunc(pools);
			if( maxPoolValue!=null && plist[p]+move>maxPoolValue )
				move = maxPoolValue - plist[p];
			plist[p]+=move;
			remain-=move;
		}
		return plist;
	}
	
	
	public static inline function constraint(n:Dynamic, min:Dynamic, max:Dynamic) {
		return
			if (n<min) min;
			else if (n>max) max;
			else n;
	}
	
	public static inline function replaceTag(str:String, char:String, open:String, close:String) {
		var char = "\\"+char.split("").join("\\");
		var re = char+"([^"+char+"]+)"+char;
		return try { new EReg(re, "g").replace(str, open+"$1"+close); } catch (e:String) { str; }
	}
	
	public static inline function sign() {
		return Std.random(2)*2-1;
	}
		
	public static inline function distanceSqr(ax:Float,ay:Float,bx:Float,by:Float) : Float {
		return (ax-bx)*(ax-bx) + (ay-by)*(ay-by);
	}
		
	public static inline function distance(ax:Float,ay:Float, bx:Float,by:Float) : Float {
		return Math.sqrt( distanceSqr(ax,ay,bx,by) );
	}
		
	
	public static inline function getNextPower2(n:Int) { // n est sur 32 bits
		n--;
		n |= n >> 1;
		n |= n >> 2;
		n |= n >> 4;
		n |= n >> 8;
		n |= n >> 16;
		return n++;
	}
	public static inline function getNextPower2_8bits(n:Int) { // n est sur 8 bits
		n--;
		n |= n >> 1;
		n |= n >> 2;
		n |= n >> 4;
		return n++;
	}
	
	// Comparaison optimisée pour éviter les collisions et erreurs de prédiction
	// Source : http://bits.stephan-brumme.com/minmax.html
	static inline function fastSelect(x:Int,y:Int, ifXSmaller:Int, ifYSmaller:Int) {
		var diff = x-y;
		var bit31 = diff >> 31;
		return (bit31 & (ifXSmaller ^ ifYSmaller)) ^ ifYSmaller;
	}
	
	public static inline function fastMinimum(x:Int,y:Int) {
		return fastSelect(x,y, x,y);
	}
	public static inline function fastMaximum(x:Int,y:Int) {
		return fastSelect(x,y, y,x);
	}
	
	
	public static inline function abs(a:Float) {
		return (a<0) ? -a : a;
	}
	
	public static inline function rnd(min:Float, max:Float, ?sign=false) {
		if( sign )
			return (min + Math.random()*(max-min)) * (Std.random(2)*2-1);
		else
			return min + Math.random()*(max-min);
	}
	
	public static inline function irnd(min:Int, max:Int, ?sign:Bool) {
		if( sign )
			return (min + Std.random(max-min+1)) * (Std.random(2)*2-1);
		else
			return min + Std.random(max-min+1);
	}
	
	public static inline function rad(a:Float) : Float {
		return a*3.1416/180;
	}
	
	public static inline function deg(a:Float) : Float {
		return a*180/3.1416;
	}
	
	public static function splitUrl(url:String) {
		if( url==null || url.length==0 )
			return null;
		var noProt = if( url.indexOf("://")<0 ) url else url.substr( url.indexOf("://")+3 );
		return {
			prot	: if( url.indexOf("://")<0 ) null else url.substr(0, url.indexOf("://")),
			dom		: if( noProt.indexOf("/")<0 ) noProt else if( noProt.indexOf("/")==0 ) null else noProt.substr(0, noProt.indexOf("/")),
			path	: if( noProt.indexOf("/")<0 ) "/" else noProt.substr(noProt.indexOf("/")),
		}
	}
	
	public static function splitMail(mail:String) {
		if (mail==null || mail.length==0)
			return null;
		if (mail.indexOf("@")<0)
			return null;
		else {
			var a = mail.split("@");
			if ( a[1].indexOf(".")<0 )
				return null;
			else
				return {
					usr	: a[0],
					dom	: a[1].substr(0,a[1].indexOf(".")),
					ext	: a[1].substr(a[1].indexOf(".")+1),
				}
		}
	}

	#if (flash9 || nme || openfl)
	#if haxe3
	static var flattened : haxe.ds.StringMap<flash.display.Bitmap> = new haxe.ds.StringMap();
	#else
	static var flattened : Hash<flash.display.Bitmap> = new Hash();
	#end
	public static function disposeFlattened(uniqId:String) {
		if( !flattened.exists(uniqId) )
			return;
		flattened.get(uniqId).bitmapData.dispose();
		flattened.remove(uniqId);
	}
	
	public static function disposeAllFlatteneds() {
		for( bmp in flattened )
			if( bmp.bitmapData!=null )
				bmp.bitmapData.dispose();
		#if haxe3
		flattened = new StringMap();
		#else
		flattened = new Hash();
		#end
	}
	
	public static function flatten(o:flash.display.DisplayObject, ?uniqId:String, ?padding=0.0, ?copyTransforms=false, ?quality:flash.display.StageQuality) {
		var qold = try { flash.Lib.current.stage.quality; } catch(e:Dynamic) { flash.display.StageQuality.MEDIUM; };
		if( quality!=null )
			try {
				flash.Lib.current.stage.quality = quality;
			} catch( e:Dynamic ) {
				throw("flatten quality error");
			}
		var b = o.getBounds(o);
		var bmp = new flash.display.Bitmap( new flash.display.BitmapData(Math.ceil(b.width+padding*2), Math.ceil(b.height+padding*2), true, 0x0) );
		var m = new flash.geom.Matrix();
		m.translate(-b.x, -b.y);
		m.translate(padding, padding);
		bmp.bitmapData.draw(o, m, o.transform.colorTransform);

		var m = new flash.geom.Matrix();
		m.translate(b.x, b.y);
		m.translate(-padding, -padding);
		if( copyTransforms ) {
			m.scale(o.scaleX, o.scaleY);
			m.rotate( rad(o.rotation) );
			m.translate(o.x, o.y);
		}
		bmp.transform.matrix = m;
		
		if( uniqId!=null ) {
			disposeFlattened(uniqId);
			flattened.set(uniqId, bmp);
		}
		if( quality!=null )
			try {
				flash.Lib.current.stage.quality = qold;
			} catch( e:Dynamic ) {
				throw("flatten quality error");
			}
		return bmp;
	}
	//
	//public static function repeatTexture(tex:BitmapData, target:BitmapData) {
		//target.lock();
		//var pt = new flash.geom.Point(0,0);
		//for(x in 0...Math.ceil(target.width/tex.width)
			//for(y in 0...Math.ceil(target.height/tex.height) {
				//pt.x = x;
				//pt.y = y;
				//target.copyPixels(tex, tex.rect, pt, true);
			//}
		//target.unlock();
	//}
	public static function createTexture(source:flash.display.BitmapData, width:Int, height:Int, autoDisposeSource:Bool) {
		var bd = new BitmapData(width, height, source.transparent, 0x0);
		bd.lock();
		var pt = new flash.geom.Point(0,0);
		for(x in 0...Math.ceil(width/source.width))
			for(y in 0...Math.ceil(height/source.height)) {
				pt.x = x * source.width;
				pt.y = y * source.height;
				bd.copyPixels(source, source.rect, pt);
			}
		bd.unlock();
		if( autoDisposeSource )
			source.dispose();
		return bd;
	}
	
	
	public static function flipBitmap(bd:BitmapData, flipX:Bool, flipY:Bool) {
		var tmp = bd.clone();
		var m = new flash.geom.Matrix();
		if( flipX ) {
			m.scale(-1, 1);
			m.translate(bd.width, 0);
		}
		if( flipY ) {
			m.scale(1, -1);
			m.translate(0, bd.height);
		}
		bd.draw(tmp, m);
		tmp.dispose();
	}
	
	#end

	
	// Credits : http://brianin3d.blogspot.fr/2008/11/haxe-bresenhams-line-drawing-algorithm.html
	public static function bresenham( x0:Int, y0:Int, x1:Int, y1:Int, ?cb:Int->Int->Void ) {
		var pts = [];
		var steep = Math.abs( y1 - y0 ) > Math.abs( x1 - x0 );
        var tmp : Int;
        if ( steep ) {
            // swap x and y
            tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
            tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
        }
        if ( x0 > x1 ) {
            // make sure x0 < x1
            tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
            tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
        }
        var deltax = x1 - x0;
        var deltay = Math.floor( Math.abs( y1 - y0 ) );
        var error = Math.floor( deltax / 2 ); // this is a little hairy
        var y = y0;
        var ystep = if ( y0 < y1 ) 1 else -1;
        for ( x in x0 ... x1+1 ) {
            if ( steep ) {
				if( cb!=null )
					cb(y,x);
				pts.push({x:y, y:x});
			}
            else {
				if( cb!=null )
					cb(x,y);
				pts.push({x:x, y:y});
			}
            error -= deltay;
            if ( error < 0 ) {
                y = y + ystep;
                error = error + deltax;
            }
        }
		return pts;
	}
	
	// cb est une fonction qui renvoie TRUE ou FALSE pour chaque point (FALSE = interrompre le parcours et renvoyer FALSE)
	public static function bresenhamCheck( x0:Int, y0:Int, x1:Int, y1:Int, cb:Int->Int->Bool ) {
		var steep = Math.abs( y1 - y0 ) > Math.abs( x1 - x0 );
        var tmp : Int;
        if ( steep ) {
            // swap x and y
            tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
            tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
        }
        if ( x0 > x1 ) {
            // make sure x0 < x1
            tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
            tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
        }
        var deltax = x1 - x0;
        var deltay = Math.floor( Math.abs( y1 - y0 ) );
        var error = Math.floor( deltax / 2 ); // this is a little hairy
        var y = y0;
        var ystep = if ( y0 < y1 ) 1 else -1;
        for ( x in x0 ... x1+1 ) {
            if ( steep ) {
				if( !cb(y,x) )
					return false;
			}
            else {
				if( !cb(x,y) )
					return false;
			}
            error -= deltay;
            if ( error < 0 ) {
                y = y + ystep;
                error = error + deltax;
            }
        }
		return true;
	}
	
}
