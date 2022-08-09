package mt.heaps.scene;

class Camera extends h3d.scene.Object {
	var cam(default,null) : h3d.Camera;
	
	public var scene(get,null) : Null<h3d.scene.Scene>;
	public var active(get, set):Bool;
	
	public function new(?parent:h3d.scene.Object) {
		super(parent);
		cam = new h3d.Camera();
		
		x = cam.pos.x;
		y = cam.pos.y;
		z = cam.pos.z;
		customTransform = new h3d.Matrix();
		customTransform.identity();
	}
	
	public function loadFrom(c:h3d.Camera) {
		identity();
		setPosTarget( c.pos.x, c.pos.y, c.pos.z, c.target.x, c.target.y, c.target.z);
		cam.zNear = c.zNear;
		cam.zFar = c.zFar;
		cam.fovX = c.fovX;
		cam.update();
	}
	
	//////////////////
	//private section
	//////////////////
	public function setPosTarget( x:Float, y:Float, z:Float, tx:Float, ty:Float, tz:Float) {
		identity();
		
		customTransform.setAffineBase( 
			new h3d.Vector( x, y, z ),
			new h3d.Vector( tx-x, ty-y, tz-z ),
			new h3d.Vector( 0, 0, 1 ) );
		
		syncCam();
	}
	
	function identity() {
		this.x = 0; this.y = 0; this.z = 0;
		this.qRot = new h3d.Quat();
		this.setScale(1.0);
		customTransform.identity();
		posChanged = true;
	}
	
	static function getScene(o:h3d.scene.Object) : Null<h3d.scene.Scene> {
		if ( o == null  || o.parent == null ) return null;
		
		if ( Std.is( o.parent, h3d.scene.Scene) )  	return cast o.parent;
		else 										return getScene( o.parent );
	}
	
	function switchTo(c:h3d.Camera) {
		var sc = get_scene();
		if ( sc == null) return;
		
		set_active(false);
		sc.camera = cam;
	}
	
	function get_scene() return getScene(this);
	
	function get_active() {
		var sc = get_scene();
		if ( sc == null) return false;
		return sc.camera == cam;
	}
	
	function set_active(onOff) : Bool{
		var sc = get_scene();
		if ( sc == null) return false;
		
		if ( onOff ) 	{
			sc.camera = cam;
			return true;
		}
		else {
			if( sc.camera == cam )
				sc.camera = new h3d.Camera();
			
			return false;
		}
	}
	
	public function syncCam() {
		calcAbsPos();
		
		var pos = absPos.pos();
		var at = absPos.at();
		at.incr( pos );
		
		cam.pos.load( pos );
		cam.target.load( at );
	}
	
}