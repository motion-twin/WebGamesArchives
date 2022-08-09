import mb2.Const;

class mb2.Tools {

	static function mc_size(mc) {
		var s = new Object();
		s.w = Math.ceil((mc._width / 2) / Const.DELTA) * 2;
		s.h = Math.ceil((mc._height / 2) / Const.DELTA) * 2;
		return s;
	}

	static function set_mcpos(mc,p) {
		var s = mc_size(mc);
		mc._x = (p.x + s.w / 2) * Const.DELTA;
		mc._y = (p.y + s.h / 2) * Const.DELTA;
	}

	static function pos_center(mc) {
		var s = mc_size(mc);
		var p = new Object();
		p.x = int((Const.LVL_CWIDTH - Const.BORDER_CSIZE*2) / 2 + Const.BORDER_CSIZE) - s.w / 2;
		p.y = int((Const.LVL_CHEIGHT - Const.BORDER_CSIZE*2) / 2 + Const.BORDER_CSIZE) - s.h / 2;
		return p;
	}

	static function to_deg(a) {
		return int(a * 180 / Math.PI + 360)%360;
	}

	static function rad_dif(a,b) {
		var d = b - a;
		d -= int(d / (2*Math.PI) )*Math.PI*2;
		if( d > Math.PI )
			return d - Math.PI*2;
		if( d <= -Math.PI )
			return d + Math.PI*2;
		return d;
	}

	static function dist2(mc1,mc2) {
		var dx = mc1._x-mc2._x;
		var dy = mc1._y-mc2._y;
		return dx*dx+dy*dy;
	}

	static function drawSmoothSquare(mc,pos,col,curve,alpha) {
		mc.moveTo(pos.x+curve,pos.y);
		mc.beginFill(col,alpha);
		mc.lineTo(pos.x+(pos.w-curve),pos.y);
		mc.curveTo(pos.x+pos.w,pos.y,pos.x+pos.w,pos.y+curve);
		mc.lineTo(pos.x+pos.w,pos.y+(pos.h-curve));
		mc.curveTo(pos.x+pos.w,pos.y+pos.h,pos.x+(pos.w-curve),pos.y+pos.h);
		mc.lineTo(pos.x+curve,pos.y+pos.h);
		mc.curveTo(pos.x,pos.y+pos.h,pos.x,pos.y+(pos.h-curve));
		mc.lineTo(pos.x,pos.y+curve);
		mc.curveTo(pos.x,pos.y,pos.x+curve,pos.y);
		mc.endFill();
	}

}