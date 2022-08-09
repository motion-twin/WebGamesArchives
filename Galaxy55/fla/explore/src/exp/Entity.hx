package exp;

import mt.deepnight.Lib;
import mt.deepnight.SpriteLib;

class Entity implements haxe.Public {
	var man			: Manager;
	var room		: Room;
	var dataId		: Null<Int>;
	
	var spr			: flash.display.Sprite;
	var speed		: Float;
	var external(default,null)	: Null<flash.display.Sprite>;
	
	var x			: Float;
	var y			: Float;
	
	var dx			: Float;
	var dy			: Float;
	var rotation	: Float; // degrés
	var scale		: Float;
	
	var zoom		: Float;
	var fl_zoomScale: Bool;
	
	var target		: Null<{x:Float, y:Float}>;
	var onArrive	: Null<Void->Void>;
	var onArriveDist: Int;
	
	var name		: Null<String>;
	
	public function new(r,s) {
		room = r;
		//seed = room.rseed.random(999999);
		spr = s;
		man = Manager.ME;
		x = y = 0;
		zoom = 0;
		fl_zoomScale = true;
		rotation = 0;
		onArriveDist = 0;
		scale = 1;
		dx = dy = 0.1;
		target = null;
		speed = 0.19;
	}
	
	inline function getAngleDeg() {
		return 180 * getAngleRad()/Math.PI;
	}
	
	inline function getAngleRad() {
		if( dx==0 && dy==0 )
			return rotation*Math.PI/180;
		else
			return Math.atan2(dy, dx);
	}
	
	function setExternal(s) {
		external = s;
		man.externalSprites.addChild(s);
		s.mouseChildren = s.mouseEnabled = false;
	}
	
	inline function getScreenSpeed() {
		return Math.sqrt( dx*dx + dy*dy );
	}
	
	inline function getTargetDist() {
		return target==null ? 0 : Math.sqrt( Math.pow(target.x-x, 2) + Math.pow(target.y-y, 2) );
	}
	
	inline function update(?tmod=1.0) {
		var d = target==null ? 0 : getTargetDist();
		if( target!=null ) {
			//var max = 0.50*speed;
			var max = 3*speed;
			var ang = Math.atan2(target.y-y, target.x-x);
			var s = d* (0.01 + 0.001*speed);
			if( s<-max ) s = -max;
			if( s>max ) s = max;
			dx += Math.cos(ang)*s;
			dy += Math.sin(ang)*s;
		}
		
		x+=dx*tmod;
		y+=dy*tmod;
		
		dx *= Math.pow(0.83,tmod);
		dy *= Math.pow(0.83,tmod);
		
		if( target!=null ) {
			// cible atteinte
			if( d<=onArriveDist && onArrive!=null ) {
				var cb = onArrive;
				onArrive = null;
				cb();
			}
			if( d<=1 && getScreenSpeed()<=0.1 ) {
				x = target.x;
				y = target.y;
				target = null;
				dx = 0;
				dy = 0;
				var cb = onArrive;
				onArrive = null;
				if( cb!=null )
					cb();
			}
		}
		
		if( Lib.abs(dx)<=0.001 )
			dx = 0;
		if( Lib.abs(dy)<=0.001 )
			dy = 0;
		
		if( zoom==0 ) {
			spr.x = room.viewPort.width * 0.5 + x - room.viewPort.x;
			spr.y = room.viewPort.height * 0.5 + y - room.viewPort.y;
			spr.rotation = rotation;
			spr.scaleX = spr.scaleY = scale;
		}
		else {
			var m = new flash.geom.Matrix();
			m.rotate(rotation*Math.PI/180);
			m.scale(scale,scale);
			if( !fl_zoomScale )
				m.scale( (1/(1+zoom)), (1/(1+zoom)) );
			m.translate(-room.viewPort.width*0.5, -room.viewPort.height*0.5);
			m.scale(1+zoom, 1+zoom);
			m.translate(room.viewPort.width*0.5, room.viewPort.height*0.5);
			
			var xm = room.viewPort.width * 0.5 + x - room.viewPort.x;
			var ym = room.viewPort.height * 0.5 + y - room.viewPort.y;
			m.translate( xm*zoom, ym*zoom );
			m.translate( xm, ym );
			spr.transform.matrix = m;
		}
		
		if( external!=null ) {
			var pt = man.bufferToGlobal({x:spr.x, y:spr.y});
			external.x = Math.round(pt.x);
			external.y = Math.round(pt.y);
			external.alpha = spr.alpha;
			external.visible = spr.visible;
			external.scaleX = external.scaleY = spr.scaleX;
		}
		
		spr.x = Std.int(spr.x);
		spr.y = Std.int(spr.y);
		
		//spr.x = Std.int( x - room.viewPort.x + room.viewPort.width*0.5 );
		//spr.y = Std.int( y - room.viewPort.y + room.viewPort.height*0.5 );
		//spr.x += room.bounds.width*0.5 - (room.bounds.width*0.5)*(1+zoom);
		//spr.y += room.bounds.height*0.5 - (room.bounds.height*0.5)*(1+zoom);
		//spr.scaleX = spr.scaleY = 1+zoom*0.4;
		//spr.x +=
	}
}
