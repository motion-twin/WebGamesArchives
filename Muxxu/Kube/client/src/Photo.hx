import Common;

class Photo {

	var g : Kube;
	var i : Interface;
	var zx : Int;
	var zy : Int;
	var last : flash.display.BitmapData;

	public function new(g) {
		this.g = g;
	}

	public function onClick() {
		i = g.interf;
		if( g.lock ) {
			i.defaultAction();
			return;
		}
		g.lock = true;
		i.message(g.texts.taking_photo);
		doPhoto();
		/*
		var me = this;
		var onReady = null;
		var count = 0;
		onReady = function(_) {
			count++;
			if( count < 2 ) return;
			me.g.root.removeEventListener(flash.events.Event.ENTER_FRAME,onReady);
			me.doPhoto();
		};
		g.root.addEventListener(flash.events.Event.ENTER_FRAME,onReady);
		*/
	}


	function takePhoto() {
		var w = g.width, h = g.height, rw, rh;
		var ow = w, oh = h;
		var bgBits;
		if( g.hasFlag(GameConst.FLAG_PHOTO_4X) ) {
			bgBits = 1;
			w = 1024;
			h = 768;
			rw = 1600;
			rh = 1200;
		} else if( g.hasFlag(GameConst.FLAG_PHOTO_2X) ) {
			bgBits = 1;
			w = 800;
			h = 600;
			rw = 1600;
			rh = 1200;
		} else {
			bgBits = 2;
			w = 400;
			h = 300;
			rw = 800;
			rh = 600;
		}
		g.width = rw;
		g.height = rh;
		g.initBytes();
		var px = g.px - Math.cos(g.angle) * 0.44;
		var py = g.py - Math.sin(g.angle) * 0.44;
		var pz = g.pz + g.viewZ;
		g.render.render(g.bmpPosition,g.levelPosition,g.getCurBgPosition(),bgBits-1,rw,rh,px,py,pz,g.angle,g.angleZ);
		calculateZone(px,py,pz);
		var bmp = new flash.display.BitmapData(rw,rh,true,0);
		g.bytes.position = g.bmpPosition;
		bmp.setPixels(bmp.rect,g.bytes);
		bmp.applyFilter(bmp,bmp.rect,new flash.geom.Point(0,0),new flash.filters.BlurFilter(1.1,0.2,3));
		var photo = new flash.display.BitmapData(w,h,true,0);
		var mat = new flash.geom.Matrix();
		mat.translate(0,g.bg.mc.y);
		mat.scale(w/ow,h/oh);
		photo.draw(g.bg.mc,mat);
		mat.identity();
		mat.scale(w/rw,h/rh);
		photo.draw(new flash.display.Bitmap(bmp),mat);
		bmp.dispose();
		g.width = ow;
		g.height = oh;
		g.initBytes();
		return photo;
	}

	function calculateZone( px, py, pz ) {
		var picks = new Hash<{ x : Int, y : Int, n : Int }>();
		var max = 0;
		zx = Std.int(g.px + g.cx + Math.cos(g.angle) * 5) >> GameConst.ZONEBITS;
		zy = Std.int(g.py + g.cy + Math.cos(g.angle) * 5) >> GameConst.ZONEBITS;
		for( x in 0...5 )
			for( y in 0...5 ) {
				var dx = Std.int((x+2)*g.width/8);
				var dy = Std.int((y+3)*g.height/10);
				var b = g.render.pick(g.levelPosition,g.width,g.height,px,py,pz,g.angle,dx,dy,g.angleZ,false);
				if( b == null ) continue;
				var x = (b.x + g.cx) >> GameConst.ZONEBITS;
				var y = (b.y + g.cy) >> GameConst.ZONEBITS;
				var id = x+"."+y;
				var p = picks.get(id);
				if( p == null ) {
					p = { x : x, y : y, n : 0 };
					picks.set(id,p);
				}
				p.n++;
			}
		for( p in picks )
			if( p.n > max ) {
				zx = p.x;
				zy = p.y;
				max = p.n;
			}
	}

	function doPhoto() {
		flash.ui.Mouse.hide();
		if( last != null ) {
			savePhoto(last);
			last = null;
			return;
		}
		var t0 = flash.Lib.getTimer();
		var bmp = takePhoto();
		if( flash.Lib.getTimer() - t0 > 7000 ) {
			last = bmp;
			onAnswer(AMessage(g.texts.photo_save_delay,false));
			return;
		}
		// we can't sent file on network outside of click event
		savePhoto(bmp);
		//haxe.Timer.delay(callback(savePhoto,bmp),50);
	}

	function savePhoto( bmp : flash.display.BitmapData ) {
		// build big png
		var output = new haxe.io.BytesOutput();
		new format.jpg.Writer(output).write({ width : bmp.width, height : bmp.height, quality : 90., pixels : format.tools.Image.getBytesARGB(bmp) });
		var bytes = output.getBytes();
		// build small image
		output = new haxe.io.BytesOutput();
		var sbmp = new flash.display.BitmapData(100,75,false);
		var m = new flash.geom.Matrix();
		m.scale(sbmp.width / bmp.width,sbmp.height / bmp.height);
		sbmp.draw(new flash.display.Bitmap(bmp),m);
		new format.jpg.Writer(output).write({ width : sbmp.width, height : sbmp.height, quality : 100., pixels : format.tools.Image.getBytesARGB(sbmp) });
		var sbytes = output.getBytes();
		// send to server
		bmp.dispose();
		sbmp.dispose();
		i.message(g.texts.saving_photo);
		var small = null, big = null, me = this;
		doUpload(sbytes,function(d) { small = d; if( big != null ) me.complete(small,big); });
		doUpload(bytes,function(d) { big = d; if( small != null ) me.complete(small,big); });
	}

	function complete( small : String, big : String ) {
		try big = haxe.Unserializer.run(big) catch( e : Dynamic ) big = "";
		try small = haxe.Unserializer.run(small) catch( e : Dynamic ) small = "";
		Codec.call(Kube.DATA._s,CSavePhoto(zx,zy,big,small,g.hidePhoto),onAnswer);
	}

	function onAnswer( a : _Answer ) {
		flash.ui.Mouse.show();
		i.message();
		i.defaultAction();
		g.lock = false;
		switch( a ) {
		case AMessage(text,err): if( err ) i.warning(text) else i.notice(text);
		default:
		}
	}

	function doUpload( bytes : haxe.io.Bytes, callb : String -> Void ) {
		var r = new flash.net.URLRequest("https://imgup.motion-twin.com/upload/");
		var boundary = "";
		for( i in 0...32 )
			boundary += String.fromCharCode( "a".code + Std.random(26) );
		var filename = "upload.jpg";
		var vars = new Hash();
		vars.set("Filename",filename);
		vars.set("site","kube");
		vars.set("prefix",Std.string(Kube.DATA._uid));
		var data = new haxe.io.BytesOutput();
		for( v in vars.keys() ) {
			data.writeString('--'+boundary+"\r\n");
			data.writeString('Content-Disposition: form-data; name="'+v+'"\r\n\r\n'+vars.get(v)+'\r\n');
		}
		data.writeString('--'+boundary+"\r\n");
		data.writeString('Content-Disposition: form-data; name="file"; filename="'+filename+'"\r\n');
		data.writeString('Content-Type: application/octet-stream\r\n\r\n');
		data.write(bytes);
		data.writeString("\r\n");
		data.writeString("--"+boundary+"--");
		r.contentType = "multipart/form-data; boundary="+boundary;
		r.method = flash.net.URLRequestMethod.POST;
		r.data = data.getBytes().getData();
		var l = new flash.net.URLLoader(r);
		l.addEventListener(flash.events.Event.COMPLETE,function(_) {
			callb(l.data);
		});
		l.addEventListener(flash.events.IOErrorEvent.IO_ERROR,function(_) {
			callb("");
		});
	}

}
