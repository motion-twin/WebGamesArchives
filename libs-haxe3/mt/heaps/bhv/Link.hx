package mt.heaps.bhv;

class Link extends hxd.Behaviour {
	var parent : h3d.scene.Object;
	var bone : String;
	
	public var saveMatrix : h3d.Matrix;
	var offsetMatrix : h3d.Matrix;
	public var m:h3d.Matrix = new h3d.Matrix();
	
	var t : h3d.Vector;
	var r : h3d.Vector; 
	var s : h3d.Vector;
	
	public function new(c : h3d.scene.Object,p : h3d.scene.Object,b:String, ?t,?r,?s) {
		super(c);
		if ( c == null ) throw "assert";
		if ( p == null ) throw "assert";
		parent = p;
		bone = b;
		saveMatrix = (c.defaultTransform == null)? new h3d.Matrix().identity() : c.defaultTransform.clone();
		offsetMatrix = new h3d.Matrix().identity();
		
		if ( t == null ) t = new h3d.Vector(0, 	0, 	0);
		if ( r == null ) r = new h3d.Vector(0, 	0, 	0);
		if ( s == null ) s = new h3d.Vector(1.,	1.,	1.);
		
		offset(t, r, s);
	}
	
	public override function clone( c ) : hxd.Behaviour 
		return new Link(c, parent, bone,t,r,s);
	
	public override function destroy() {
		if( obj != null)
			obj.defaultTransform = saveMatrix;
		super.destroy();
		parent = null;
		bone = null;
		saveMatrix = null;
		obj = null;
	}
	
	function getMatrix( parent:h3d.scene.Object, name:String ) : h3d.Matrix {
		for ( o in parent.currentAnimation.objects) 
			if( o.objectName == name) {
				if ( o.targetSkin!=null) 
					return o.targetSkin.currentAbsPose[o.targetJoint];
				if ( o.targetObject !=null ) 
					return o.targetObject.getMatrix();
			}
		
		return h3d.Matrix.IDENTITY;
	}
	
	function getEngineBoneMatrix( parent:h3d.scene.Object, name:String ) : h3d.Matrix {
		if( parent.currentAnimation == null )
			return h3d.Matrix.IDENTITY;
		
		if ( name == "Bip001")
			return getMatrix( parent, name);
			
		var curObject = null;
		for ( o in parent.currentAnimation.objects) 
			if ( o.objectName == "Bip001 Spine") {
				curObject = o;
				break;
			}
			
		if (curObject == null) return h3d.Matrix.IDENTITY;
		var skin : h3d.scene.Skin = curObject.targetSkin;
		if (skin==null) return h3d.Matrix.IDENTITY;
		var skinData = skin.skinData;
		var mine = skinData.namedJoints.get( name );
		if (mine==null) return h3d.Matrix.IDENTITY;
		var pos = skin.currentAbsPose[mine.index];
		return pos;
	}
	
	public override function update() {
		if ( parent.currentAnimation == null ) return;
		
		m.loadFrom( getEngineBoneMatrix( parent,bone));
		m.multiply( offsetMatrix, m );
		m.multiply( saveMatrix, m  );
		obj.defaultTransform = m;
	}
	
	public function offset(t : h3d.Vector, r : h3d.Vector, s : h3d.Vector) {
		this.t = t; this.r = r; this.s = s;
		offsetMatrix.initScale(s.x, s.y, s.z);
		offsetMatrix.rotate(r.x, r.y, r.z);
		offsetMatrix.translate(t.x, t.y, t.z);
		return this;
	}
}
