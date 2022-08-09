import mt.MLib;
import mt.deepnight.Tweenie;
import b.Room;

class Viewport {
	public var dx				: Float;
	public var dy				: Float;
	public var x				: Float;
	public var y				: Float;
	public var wid(get,null)	: Float;
	public var hei(get,null)	: Float;
	var curZoom					: Float;
	var userZoom				: Float;
	var forcedZoom				: Float;
	public var zoomLocked		: Bool;
	public var tw				: Tweenie;

	public function new() {
		x = y = 0;
		dx = dy = 0;
		tw = new mt.deepnight.Tweenie(Const.FPS);
		zoomLocked = false;

		forcedZoom = -1;
		userZoom = 1;
		curZoom = userZoom;
	}

	public inline function getZoom() return curZoom;
	inline function getTargetZoom() return forcedZoom!=-1 ? forcedZoom : userZoom;

	inline function get_wid() return Game.ME.w();
	inline function get_hei() return Game.ME.h();

	public function isInSight(tx:Float, ty:Float, screenRatio:Float) {
		return tx>=x-wid*screenRatio && tx<x+wid*screenRatio && ty>=y-hei*screenRatio && ty<y+hei*screenRatio;
	}

	public function focusIfNotInSight(tx:Float, ty:Float, screenRatio:Float) {
		if( !isInSight(tx,ty,screenRatio) ) {
			var tx = (tx-x)*0.6 + x;
			var ty = (ty-y)*0.6 + y;
			focus(tx,ty);
		}
	}

	public function focus(tx,ty, ?d=800) {
		tw.create(x, tx, d, TEase);
		tw.create(y, ty, d, TEase);
	}

	public function focusAndZoom(tx,ty, z, d) {
		tw.create(x, tx, d, TEase);
		tw.create(y, ty, d, TEase);
		tw.create(userZoom, z, d, TEase);
	}


	public function focusRoom(r:b.Room, ?delay:Int, ?ratio=1.0) {
		var tx = (r.globalCenterX-x)*ratio + x;
		var ty = (r.globalCenterY-y)*ratio + y;
		focus(tx,ty, delay);
	}

	public function cancelTweens() {
		tw.terminateWithoutCallbacks(x);
		tw.terminateWithoutCallbacks(y);
		//tw.terminateWithoutCallbacks(zoom);
	}

	public inline function resetForcedZoom() forcedZoom = -1;
	public inline function forceZoomOut() {
		if( Game.ME.cd.has("camLock") )
			return;

		#if responsive
		var v = MLib.fmax(0.45, userZoom*0.62);
		#else
		var v = MLib.fmax(0.45, userZoom*0.71);
		#end
		if( userZoom>v )
			forcedZoom = v;
	}


	public inline function deltaZoom(v) {
		userZoom = clampZoom(userZoom+v);
	}

	public inline function deltaZoomRatio(v:Float) {
		userZoom = clampZoom(userZoom*v);
	}

	public function setUserZoom(v) {
		userZoom = v;
	}

	public function destroy() {
		tw.destroy();
		tw = null;
	}

	function getMaxZoom() {
		return Assets.SCALE==1 ? 2 : 1.15;
	}

	function getMinZoom() {
		var h = Game.ME.hotelRender;
		var min = MLib.fmax( mt.Metrics.w() / (h.right-h.left), mt.Metrics.h() / (h.bottom-h.top) );
		return (0.025 + min)/Game.ME.baseScale;
	}

	function clamp() {
		var h = Game.ME.hotelRender;
		if( h!=null ) {
			curZoom = clampZoom(curZoom);

			x = MLib.fclamp(x, h.left+wid*0.5+30, h.right-wid*0.5-30);
			y = MLib.fclamp(y, h.top-2*Const.ROOM_HEI+hei*0.5, h.bottom-hei*0.5);
		}
	}

	inline function clampZoom(v:Float) return MLib.fclamp( v, getMinZoom(), getMaxZoom() );


	public function update() {
		tw.update();

		x+=dx;
		y+=dy;
		dx*=0.8;
		dy*=0.8;
		if( !zoomLocked ) {
			var spd = Game.ME.pinching ? 1 : forcedZoom!=-1 ? 0.10 : 0.13;
			curZoom += (getTargetZoom()-curZoom) * spd;
		}
		clamp();
	}
}
