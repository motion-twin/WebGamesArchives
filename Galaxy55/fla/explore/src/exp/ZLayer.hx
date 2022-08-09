package exp;

class ZLayer implements haxe.Public {
	var man			: Manager;
	var cont		: flash.display.Sprite;
	var bd			: Null<flash.display.BitmapData>;
	var room		: Room;
	
	var z			: Float;
	var xOffset		: Float;
	var yOffset		: Float;
	var texWid		: Int;
	var texHei		: Int;
	var zoom		: Float;
	
	var fl_repeat(default,null)	: Bool;
	var fl_snapPixel			: Bool;
	var fl_hideZoom				: Bool;
	
	public function new(r:Room, ?tex:flash.display.BitmapData, ?mc:flash.display.Sprite, z:Float, ?repeat=false, ?scaleX=1.0, ?scaleY:Null<Float>) {
		if( mc!=null && tex!=null )
			throw "Invalid parameters";
		man = Manager.ME;
		fl_repeat = repeat;
		cont = new flash.display.Sprite();
		cont.blendMode = flash.display.BlendMode.ADD;
		zoom = 0;
		this.z = z;
		xOffset = yOffset = 0;
		fl_snapPixel = true;
		fl_hideZoom = false;
		room = r;
		if( scaleY==null ) scaleY = scaleX;
		
		if( mc!=null && tex==null ) {
			// à partir d'un MC
			//mc.scaleX = mc.scaleY = scale;
			mc.scaleX = scaleX;
			mc.scaleY = scaleY;
			cont.addChild(mc);
			texWid = texHei = 1;
		}
		if( tex!=null && mc==null ) {
			// à partir d'un Bitmap
			var bmp = new flash.display.Bitmap(flash.display.PixelSnapping.ALWAYS, false);
			bmp.smoothing = false;
			texWid = Math.ceil(tex.width);
			texHei = Math.ceil(tex.height);
			if( fl_repeat ) {
				var w = Math.ceil(1 + man.buffer.width / texWid);
				var h = Math.ceil(1 + man.buffer.height / texHei);
				bmp.bitmapData = new flash.display.BitmapData(
					texWid * w,
					texHei * h,
					true, 0x0
				);
				var bd = bmp.bitmapData;
				for( x in 0...w )
					for( y in 0...h )
						bd.copyPixels(tex, tex.rect, new flash.geom.Point(x*tex.width, y*tex.height));
			}
			else
				bmp.bitmapData = tex.clone();
			bd = bmp.bitmapData;
			var m = new flash.geom.Matrix();
			m.translate(-bd.width*0.5, -bd.height*0.5);
			m.scale(scaleX,scaleY);
			m.translate(bd.width*0.5, bd.height*0.5);
			bmp.transform.matrix = m;
			cont.addChild(bmp);
			tex.dispose();
		}
			
		#if debug
		if( !fl_repeat ) {
			cont.graphics.lineStyle(1, 0xff0000,1);
			cont.graphics.drawRect(0,0, texWid, texHei);
		}
		#end
		
		room.layers.push(this);
	}
	
	public function destroy() {
		cont.parent.removeChild(cont);
		if( bd!=null )
			bd.dispose();
	}
	
	public function update() {
		if( cont.visible || cont.alpha>0 ) {
			var zoom = zoom*z*z; // amplification des écarts selon Z
			
			var s = 1 + zoom*z;
			var m = new flash.geom.Matrix();
			m.translate(-room.viewPort.width*0.5, -room.viewPort.height*0.5);
			m.scale(s, s);
			m.translate(room.viewPort.width*0.5, room.viewPort.height*0.5);
			
			var x = room.viewPort.width * 0.5 * (1-z) - texWid*0.5 + (room.viewPort.width * 0.5 + xOffset - room.viewPort.x ) * z;
			var y = room.viewPort.height * 0.5 * (1-z) - texHei*0.5 + (room.viewPort.height * 0.5 + yOffset - room.viewPort.y ) * z;
			m.translate( x*(zoom*z), y*(zoom*z) );
			m.translate( x, y );
			
			if( fl_repeat ) {
				while( m.tx>0 )
					m.tx -= texWid*s;
				while( m.tx+texWid*s < 0 )
					m.tx += texWid*s;
					
				while( m.ty>0 )
					m.ty -= texHei*s;
				while( m.ty+texHei*s < 0 )
					m.ty += texHei*s;
			}
			
			cont.transform.matrix = m;

			if( fl_snapPixel ) {
				cont.x = Std.int(cont.x);
				cont.y = Std.int(cont.y);
			}
		}
	}
}