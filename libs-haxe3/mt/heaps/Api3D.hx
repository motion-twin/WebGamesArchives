package mt.heaps;
import openfl.Assets;

import h2d.BlendMode;
import h3d.Engine;
import h3d.Vector;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.scene.Scene;

import hxd.Key;

using StringTools;


class Line implements h3d.IDrawable {
	var start:Vector;
	var end:Vector;
	var col:Int;
	public function new(start,end,col){
		this.start=start;
		this.end=end;
		this.col=col;
	}
	public function render( engine : h3d.Engine ) {
		engine.line(start.x, start.y, start.z, 	end.x, 	end.y, 	end.z, 	col);
	}
}

class Point implements h3d.IDrawable {
	var pos:Vector;
	var col:Int;
	public function new(pos,col){
		this.pos=pos;
		this.col=col;
	}
	public function render( engine : h3d.Engine ) {
		engine.point( pos.x, pos.y, pos.z, col );
	}
}

class VertexLink extends hxd.Behaviour {
	var handleRoot:h3d.scene.Object;
	var handled:h3d.scene.Mesh;
	var handle:Int;
	var m : h3d.Matrix;
	
	public function new( handled:h3d.scene.Object, handle:Int, obj:h3d.scene.Mesh ) {
		super(obj);
		handleRoot = handled;
		this.handled = Api3D.getMesh(handled);
		this.handle = handle;
	}
	
	public override function update() {
		super.update();
		var q = new h3d.Quat();
		var n = Api3D.getNormal( handle,handleRoot );
		var v = Api3D.getVertex( handle,handleRoot );
		q.initDirection( n );
		obj.setPosV( v );
		obj.setRotationQuat(q);
	}
	
}

class LinkBehaviour extends hxd.Behaviour {
	
	var parent : h3d.scene.Object;
	var bone : String;
	var saveMatrix : h3d.Matrix;
	var offsetMatrix : h3d.Matrix;
	
	var t : h3d.Vector;
	var r : h3d.Vector; 
	var s : h3d.Vector;
	
	/**
	 * 
	 * Bind this behaviour to object `c, using bone `b from object p as coordinate holder
	 */
	public function new(c,p,b, ?t,?r,?s) {
		super(c);
		parent = p;
		bone = b;
		saveMatrix = (c.defaultTransform == null)? new h3d.Matrix().identity() : c.defaultTransform.clone();
		offsetMatrix = new h3d.Matrix().identity();
		
		if ( t == null ) t = new h3d.Vector(0, 	0, 	0);
		if ( r == null ) r = new h3d.Vector(0, 	0, 	0);
		if ( s == null ) s = new h3d.Vector(1.,	1.,	1.);
		
		offset(t.clone(), r.clone(), s.clone());
	}
	
	public override function clone( c ) : hxd.Behaviour 
		return new LinkBehaviour(c, parent, bone,t,r,s);
	
	/**
	 * @return a read-only matrix
	 */
	public function getMatrix( name:String ) : h3d.Matrix {
		for ( o in parent.currentAnimation.objects) 
			if( o.objectName == name) {
				if ( o.targetSkin!=null) 
					return o.targetSkin.currentAbsPose[o.targetJoint];
				if ( o.targetObject !=null ) 
					return o.targetObject.getMatrix();
			}
		
		return h3d.Matrix.IDENTITY;
	}
	
	public override function destroy() {
		obj.defaultTransform = saveMatrix;
		super.destroy();
		parent = null;
		bone = null;
		saveMatrix = null;
	}
	
	var m:h3d.Matrix = new h3d.Matrix() ;
	public override function update() {
		if ( parent.currentAnimation == null ) return;
		
		m.loadFrom(getMatrix(bone));
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

class LineObj extends h3d.scene.Object{
	public var p0:h3d.Vector;
	public var p1:h3d.Vector;
	public var c : Int;
	
	public function new( p0:h3d.Vector, p1:h3d.Vector, ?c = 0x80FFFFFF, ?p) {
		super(p);
		this.p0 = p0;
		this.p1 = p1;
		this.c = c;
	}
	
	override function draw(ctx : h3d.scene.RenderContext) {
		super.draw(ctx);
		
		var v0 = p0.clone();
		var v1 = p1.clone();
		
		v0.transform( ctx.localPos );
		v1.transform( ctx.localPos );
		
		ctx.engine.line( v0.x, v0.y, v0.z, v1.x, v1.y, v1.z,c,true );
	}
}


@:keep
class ProcBehaviour extends hxd.Behaviour {
	
	var proc : Void -> Void;
	
	public function new(c,proc) {
		super(c);
		this.proc = proc;
	}
	
	public override function clone( c ) : hxd.Behaviour 		return new ProcBehaviour(c, proc );
	public override function destroy() {
		super.destroy();
		proc = null;
	}
	
	public override function update() {
		super.update();
		proc();
	}
}

@:keep
class Api3D {

	public static var scene: h3d.scene.Scene;
	public static var actions : Array < Void->Void > = [];
	
	public static function isWindows() 
		return #if windows true #else false #end;
		
	public static function isAndroid() 
		return #if android true #else false #end;
		
	public static function isFlash() 
		return #if (flash || air3) true #else false #end;
	
	public static function setLoop(scene:h3d.scene.Object,b) {
		function loop(sc:h3d.scene.Object) {
			for ( a in sc.animations ) 	a.loop = b;
			for ( c in sc) 				loop(c);
		}
		loop(scene);
	}
	
	public static function setAnimSpeed(scene:h3d.scene.Object,sp:Float) {
		function loop(sc:h3d.scene.Object) {
			for ( a in sc.animations ) 	a.speed = sp;
			for ( c in sc) 				loop(c);
		}
		loop(scene);
	}
	
	public static function play(sc:h3d.scene.Object) {
		for ( a in sc.animations ) 	a.pause = false;
		for ( c in sc) 				play(c);
	}
	
		
	public static function stop(sc:h3d.scene.Object) {
		for ( a in sc.animations ) 	a.pause = true;
		for ( c in sc) 				stop(c);
		setFrame(sc, 0);
	}
	
	public static function pause(sc:h3d.scene.Object) {
		for ( a in sc.animations ) 	a.pause = true;
		for ( c in sc) 				stop(c);
	}
		
	public static function setFrame(sc:h3d.scene.Object,fr:Int) {
		for ( a in sc.animations )	a.forceFrame( fr );
		for ( c in sc) 				setFrame(c,fr);
	}
	
	public static function meshMaterialTraverse( o : h3d.scene.Object , f : h3d.mat.MeshMaterial -> Void ) {
		o.traverse( function(o) {
			var mesh : h3d.scene.Mesh = Std.instance( o, Mesh);
			if ( mesh != null) {
				var mm = Std.instance( mesh.material, h3d.mat.MeshMaterial );
				if ( mm != null) 
					f(mesh.material);
			}
		});
	}
	
	public static function setFastFog( o:h3d.scene.Object, col:Int, start:Float, end:Float, scale:Float,dens:Float) {
		var len = scene.camera.zFar - scene.camera.zNear;
		var near = scene.camera.zNear;
		var far = scene.camera.zFar;
		
		if ( start < near ) 	start = near / len;
		else 					start = start / len;
		
		if ( end > far ) 		end = (far-near) / len;
		else 					end = end / len;
		
		o.traverse( function(o) {
			var mesh : h3d.scene.Mesh = Std.instance( o, Mesh);
			if ( mesh != null) {
				var mm = Std.instance( mesh.material, h3d.mat.MeshMaterial );
				if ( mm != null && mm.blendMode != Multiply) 
					if ( dens <= 0.0)
						mesh.material.setFastFog(null, null);
					else 
						mesh.material.setFastFog( h3d.Vector.fromColor(col), new h3d.Vector( start, end, scale,dens ));
			}
		});
	}

	public static function addOutline( obj : h3d.scene.Object, size : Float = 0.3, pow : Float = 0.0, color:Int, ?alpha:Float=1.0 ) {
		var o = obj.clone();
			o.traverse(function(c){
				if( c.isMesh()){
					var mesh = c.toMesh();
					var mat =  mesh.material;
					mat.isOutline = true;
					mat.outlineColor = color | (hxd.Math.f2b(alpha)<<24);
					mat.outlinePower = pow;
					mat.outlineSize = size;
					mat.culling = Front;
					mat.depthWrite = true;
					mat.blendMode = None;
					mat.depthTest = Less;
				}
			});
		for ( a in obj.animations ) 
			o.playAnimation(a).forceFrame(a.frame);
		return o;
	}

	public static function characterRim(obj) {
		Api3D.setRimColor( obj, 0xfff3a6, 0.3, 0.5, 0.97, true);
	}
	
	public static function otherRim(obj) {
		Api3D.setRimColor( obj, 0xfff3a6, 0.6, 0.7, 0.98, true);
	}
	
	public static function ringRim(obj) {
		Api3D.setRimColor(obj, 0xfff3a6, 0.2, 0.5, 0.97, true);
	}
	
	public static function softRim(obj) {
		Api3D.setRimColor(obj, 0xfff3a6, 0.1, 0.5, 0.97, true);
	}
	
	public static function iceRim(obj) {
		Api3D.setRimColor( obj, 0xfff3a6, 0.3, 0.98, 1.3, true );
	}
	
	public static function setRimColor( obj : h3d.scene.Object, color:Int, alpha:Float = 1.0, ?rimRampX0 = 0.92, ?rimRampX1 = 0.97 , ?rimAdd = false) {
		if (obj == null) return;
		var v = h3d.Vector.fromColor( color, 1.0 );
		v.a = alpha;
		obj.traverse(function(c) {
			if ( c.isMesh()) {
				var mesh = c.toMesh();
				var mat =  mesh.material;
				if ( alpha == 0.0) {
					mat.rimColor = null;
					mat.rimRamp = null;
				}
				else {
					if ( mat.rimColor == null ) mat.rimColor = new h3d.Vector();
					if ( mat.rimRamp == null ) mat.rimRamp = new h3d.Vector();
					
					mat.rimColor.load( v );
					mat.rimRamp.set( rimRampX0, rimRampX1,0,1 );
					mat.rimAdd = rimAdd;
				}
			}
		});
	}
	
	public static function setMorphRatios(mesh:h3d.scene.Object, arr:Array<Float>) {
		var arr = haxe.ds.Vector.fromArrayCopy(arr);
		
		function loop(n:h3d.scene.Object) {
			var mesh : h3d.scene.Mesh = Std.instance( n, h3d.scene.Mesh );
			if(mesh!=null) {
				var inst : h3d.prim.FBXModel = Std.instance( mesh.primitive, h3d.prim.FBXModel);
				if ( inst != null && inst.getNbShapes() > 0 ) {
					inst.setShapeRatios( arr );
				}
			}
		}
		
		mesh.traverse(loop);
	}
	
	public static function stopAllAnimation(on : h3d.scene.Object) {
		for ( i in 0...on.animations.length) 
			on.stopAnimation( i );
	}
	
	public static function loadCube() {
		var o  = new h3d.scene.Box();
		scene.addChild( o );
		return o;
	}
	
	public static function cleanMeshTRS(o:h3d.scene.Object) {
		o.remove();
		o.setPos(0, 0, 0);
		o.setRotate(0, 0, 0);
		o.setScale(1.0);
		o.traverse( function(o) {
			if ( o.isMesh()) {
				var m = o.toMesh();
				var mat = m.material;
				mat.lightSystem = { ambient:new Vector(1, 1, 1, 1), dirs:[], points:[] };
				mat.setFastFog(null, null);
			}
		});
		o.visible = true;
	}
	
	public static function cleanMesh(o:h3d.scene.Object) {
		o.setRotate(0, 0, 0);
		o.setScale(1.0);
		o.traverse( function(o) {
			if ( o.isMesh()) {
				var m = o.toMesh();
				var mat = m.material;
				
				mat.colorMul = new h3d.Vector(1,1,1,1);
				mat.colorAdd = null;
				
				mat.lightSystem = { ambient:new Vector(1, 1, 1, 1), dirs:[], points:[] };
				mat.setFastFog(null, null);
			}
		});
		o.visible = true;
		o.remove();
	}
	
	public static function setBlendMode(obj:Dynamic, mode:String,?rec=true) {
		var o : h3d.scene.Object = cast obj;
		var m : h3d.scene.Mesh = Std.instance( o, h3d.scene.Mesh );
		if ( m != null) 
			m.material.blendMode = Type.createEnum(h2d.BlendMode,mode);
		
		if ( rec )
			for ( c in o )
				setBlendMode( c, mode,rec );
	}
	
	public static function setAlpha(obj:h3d.scene.Object, value:Float, ?rec = true) {
		if ( obj == null ) return;
		
		var m : h3d.scene.Mesh = Std.instance( obj, h3d.scene.Mesh );
		
		if ( m != null) {
			if ( m.material.blendMode == None ) m.material.blendMode = Normal;
			if ( m.material.colorMul == null ) 	m.material.colorMul = new h3d.Vector(1.0, 1.0, 1.0, 1.0);
			m.material.colorMul.a = value;
		}
		
		if ( rec ) for ( c in obj ) setAlpha( c, value,rec );
	}
	
	public static function setClearColor(rgb){
		h3d.Engine.getCurrent().backgroundColor = (0xFF << 24 | rgb);
		flash.Lib.current.stage.color = rgb;
	}
	
	public static function setDepthTest(obj:h3d.scene.Object, mode:String,?rec=true) {
		var o : h3d.scene.Object = cast obj;
		var m : h3d.scene.Mesh = Std.instance( o, h3d.scene.Mesh );
		if ( m != null) 
			m.material.depthTest = Type.createEnum( h3d.mat.Data.Compare, mode );
		
		if ( rec ) for ( c in o ) setDepthTest( c, mode,rec );
	}
	
	public static function setDepthRead(obj:Dynamic, value:Bool,?rec=true) {
		var o : h3d.scene.Object = cast obj;
		var m : h3d.scene.Mesh = Std.instance( o, h3d.scene.Mesh );
		if ( m != null) 
			m.material.depthTest = value ? h3d.mat.Data.Compare.Less : h3d.mat.Data.Compare.Always;
		
		if ( rec ) for ( c in o ) setDepthRead( c, value,rec );
	}
	
	public static function setDepthWrite(obj:Dynamic, value:Bool,?rec=true) {
		var o : h3d.scene.Object = cast obj;
		var m : h3d.scene.Mesh = Std.instance( o, h3d.scene.Mesh );
		if ( m != null) {
			m.material.depthWrite = value;
		}
		
		if ( rec ) for ( c in o ) setDepthWrite( c, value,rec );
	}
	
	public static function setZBias(obj:h3d.scene.Object, value:Float, ?rec = true) {
		if ( obj == null)
			return;
			
		var m : h3d.scene.Mesh = Std.instance( obj, h3d.scene.Mesh );
		if ( m != null) m.material.zBias = value;
		if ( rec ) for ( c in obj ) setZBias( c, value,rec );
	}
	
	public static function setColor(obj:h3d.scene.Object, r:Float, g:Float, b:Float, ?a:Float = 1.0, ?rec = true) { 
		if ( obj == null ) return;
		
		var m : h3d.scene.Mesh = Std.instance( obj, h3d.scene.Mesh );
		if ( m != null) {
			if ( m.material.colorMul == null ) m.material.colorMul = new h3d.Vector(1.0, 1.0, 1.0, 1.0);
			
			m.material.colorMul.x = r;
			m.material.colorMul.y = g;
			m.material.colorMul.z = b;
			m.material.colorMul.w = a;
		}
		
		if ( rec ) for ( c in obj ) setColor( c, r,g,b,a,rec );
	}
	
	public static function setColorAdd(obj:h3d.scene.Object, r:Float, g:Float, b:Float, ?a:Float = 0.0, ?rec = true) {
		if ( obj == null ) return;
		
		var m : h3d.scene.Mesh = Std.instance( obj, h3d.scene.Mesh );
		if ( m != null){
			if ( m.material.colorAdd == null ) m.material.colorAdd = new h3d.Vector(0.0, 0.0, 0.0, 0.0);
				
			m.material.colorAdd.r = r;
			m.material.colorAdd.g = g;
			m.material.colorAdd.b = b;
			m.material.colorAdd.a = a;
		}
		
		if ( rec ) for ( c in obj ) setColorAdd( c, r,g,b,a,rec );
	}
	
	public static function setCameraNear(d){
		scene.camera.zNear = d;
	}
	
	public static function setCameraFar(d){
		scene.camera.zFar = d;
	}
	
	public static function setCameraPos(x, y, z) {
		scene.camera.pos.x = x;
		scene.camera.pos.y = y;
		scene.camera.pos.z = z;
	}
	
	public static function setCameraTarget(x, y, z) {
		scene.camera.target.x = x;
		scene.camera.target.y = y;
		scene.camera.target.z = z;
	}
	
	public static function setColor3(obj:Dynamic, v:Float,?rec=true) {
		var o : h3d.scene.Object = cast obj;
		var m : h3d.scene.Mesh = Std.instance( o, h3d.scene.Mesh );
		if ( m != null){
			if ( m.material.colorMul == null ) m.material.colorMul = new h3d.Vector(1.0, 1.0, 1.0, 1.0);
			
			m.material.colorMul.x = v;
			m.material.colorMul.y = v;
			m.material.colorMul.z = v;
		}
		
		if ( rec ) for ( c in o ) setColor3( c, v,rec );
	}
	
	public static function setColorMatrix(obj:Object,m:Null<h3d.Matrix>,?rec=true) {
		var mesh : h3d.scene.Mesh = Std.instance( obj, h3d.scene.Mesh );
		if ( mesh != null) 
			mesh.material.colorMatrix = m;
		if ( rec ) for ( c in obj ) setColorMatrix( c, m ,rec );
	}
	
	public static function setScale(obj:Object, value:Float) {
		obj.setScale(value);
	}
	
	public static function setRot(obj:Dynamic, x:Float,y:Float,z:Float) {
		var o : h3d.scene.Object = cast obj;
		o.setRotate(x,y,z);
	}

	public static var MREG_0 = new h3d.Matrix();
	public static var MREG_1 = new h3d.Matrix();
	
	public static var VREG_0 = new h3d.Vector();
	public static var VREG_1 = new h3d.Vector();
	public static var VREG_2 = new h3d.Vector();
	
	/**
	 * @return a read-only matrix
	 */
	public static function getEngineBoneMatrix( parent:h3d.scene.Object, name:String ) : h3d.Matrix {
		for ( o in parent.currentAnimation.objects) 
			if( o.objectName == name) {
				if ( o.targetSkin!=null) 
					return o.targetSkin.currentAbsPose[o.targetJoint];
				if ( o.targetObject !=null ) 
					return o.targetObject.getMatrix();
			}
		
		return h3d.Matrix.IDENTITY;
	}
	
	public static function getEngineBoneMatrix2( parent:h3d.scene.Object, name:String ) : h3d.Matrix {
		if ( name == "Bip001")
			return getEngineBoneMatrix( parent, name);
			
		var curObject = null;
		for ( o in parent.currentAnimation.objects) 
			if ( o.objectName == "Bip001 Spine") {
				curObject = o;
				break;
			}
			
		if (curObject == null) {
			#if debug
			var err = 0;
			#end
			return h3d.Matrix.IDENTITY;
		}
		var skin : h3d.scene.Skin = curObject.targetSkin;
		if (skin == null) {
			#if debug
			var err = 0;
			#end
			return h3d.Matrix.IDENTITY;
		}
		var skinData = skin.skinData;
		var mine = skinData.namedJoints.get( name );
		if (mine == null) {
			#if debug
			var err = 0;
			#end
			return h3d.Matrix.IDENTITY;
		}
		var pos = skin.currentAbsPose[mine.index];
		return pos;
	}
	
	public static function getBoneAbsPos(parent:h3d.scene.Object, bone:String, ?out:h3d.Vector ) : h3d.Vector {
		if ( out == null) out = new h3d.Vector();
		
		var r = VREG_1;
		var offsetMatrix = MREG_0;
		var res = MREG_1;
		
		var hp = -Math.PI * 0.5;
		
		r.set(hp, hp, hp);
		
		var boneMat = getEngineBoneMatrix2(parent, bone);
		offsetMatrix.identity();
		offsetMatrix.rotate(r.x, r.y, r.z);
		
		res.loadFrom( boneMat );
		res.multiply( offsetMatrix, res );
		
		return res.pos(out);
	}
	
	public static function getSkin(o:h3d.scene.Object) : h3d.scene.Skin {
		if ( Std.is( o , h3d.scene.Skin))
			return cast o;
		for ( c in o ){
			var sk = getSkin( c );
			if ( sk != null ) 
				return sk;
		}
		return null;
	}
	
	public static function getMesh(o:h3d.scene.Object) : h3d.scene.Mesh {
		if ( o.isMesh())
			return o.toMesh();
		for ( c in o.childs )
			if ( c.isMesh() )
				return c.toMesh();
			else {
				var m = getMesh(c);
				if ( m != null ) 
					return m;
			}
		return null;
	}
	
	public static function getFBXPrimitive(o:h3d.scene.Object) : h3d.prim.FBXModel {
		if ( o == null ) return null;
		var m = getMesh(o);
		return Std.instance( m.primitive, h3d.prim.FBXModel );
	}
	
	public static inline function getMaterial(o:h3d.scene.Object) : h3d.mat.MeshMaterial {
		return getMesh(o).material;
	}
	
	public static function getBoneMatrix(parent:h3d.scene.Object, bone:String, ?out:h3d.Matrix ) : h3d.Matrix {
		if ( out == null) out = new h3d.Matrix();
		
		var r = VREG_1;
		var offsetMatrix = MREG_0;
		var res = MREG_1;
		var hp = -Math.PI * 0.5;
		
		r.set(hp, hp, hp);
		
		var boneMat = getEngineBoneMatrix2(parent, bone);
		offsetMatrix.identity();
		offsetMatrix.rotate(r.x, r.y, r.z);
		
		res.loadFrom( boneMat );
		res.multiply( offsetMatrix, res );
		
		out.loadFrom( res );
		return out;
	}
	
	public static function linkTo(ochild:h3d.scene.Object, oparent:h3d.scene.Object, bone:String) {
		var l = new LinkBehaviour( ochild, oparent, bone );
		return l;
	}	
	
	static var ofsTranslate:h3d.Vector 	= new h3d.Vector();
	static var ofsRotation:h3d.Vector 	= new h3d.Vector(-Math.PI,-Math.PI,-Math.PI);
	static var ofsScale:h3d.Vector		= new h3d.Vector(1, 1, 1);
	
	/**
	 * @param	link is a linkbehaviour
	 * @param	t is a regular vector
	 * @param	r is a vector representing the rotation aroun X then y then z
	 * @param	s is a regular vector
	 */
	public static function linkOffset(link : LinkBehaviour, t:h3d.Vector,r:h3d.Vector,s:h3d.Vector) {
		ofsTranslate.load(t);
		ofsRotation.load(r);
		ofsScale.load(s);
		var l = link.offset(t, r, s);
		return l;
	}
	
	public static function waitAndPlay( obj:h3d.scene.Object, at:Int, fx:h3d.scene.Object) {
		fx.visible = false;
		
		obj.currentAnimation.waitForFrame( at, function() {
			
			setFrame(fx, 0);
			play(fx);
			setLoop(fx, false);
			fx.visible  = true;
			
			var fxAnim = fx.currentAnimation;
			fxAnim.onAnimEnd = function() { 
				fx.visible  = false; 
			}
		});
	}
	
	public static function update(tmod) {
		for ( a in actions )
			a();
	}
	
	public static function initLightSystem(o : h3d.scene.Object) {
		var z = h3d.Vector.ZERO.clone();
		meshMaterialTraverse(o, function(m){
			if ( m.lightSystem == null ) 
				m.lightSystem = { ambient: new h3d.Vector(1.0,1.0,1.0,1.0),
				points:[],
				dirs:[],
			}
		});
	}
	
	public static function trace(v){
		haxe.Log.trace(v);
	}
	
	public static function setAmbientLight( o : h3d.scene.Object, rgb:Int, ?alpha:Float = 1.0) {
		initLightSystem(o);
		meshMaterialTraverse(o, function(m) {
			if( m.blendMode != Multiply)
				m.lightSystem.ambient.setColor( rgb , alpha); 
		});
	}
	
	public static function setSaturation( o : h3d.scene.Object, value:Float ) {
		meshMaterialTraverse(o, function(m) {
			if ( value >= 0.99 ) {
				m.colorMatrix = null;
			}
			else {
				if (m.colorMatrix == null)
					m.colorMatrix = new h3d.Matrix();
				m.colorMatrix.identity();
				m.colorMatrix.colorSaturation(value); 
			}
		});
	}
	
	public static function setLightRamp( o : h3d.scene.Object, v0:Float,v1:Float ) {
		meshMaterialTraverse(o, function(m) {
			m.lightRamp = new h3d.Vector(v0, v1, 0.0);
		});
	}
	
	public static function setPointLight( idx:Int, o : h3d.scene.Object, 
		posx:Float, posy:Float, posz:Float,
		att0:Float, att1:Float, att2:Float, att3:Float, // linear , quadratic, cubic, distance scale
		rgb:Int, alpha:Float ) {
		initLightSystem(o);
		meshMaterialTraverse(o, function(m) {
			if( alpha > 0.01 ){
				var v =  
				{
					pos : new h3d.Vector(posx, posy, posz),
					att : new h3d.Vector(
						hxd.Math.max(att0, 0.0000001),
						hxd.Math.max(att1, 0.0000001),
						hxd.Math.max(att2, 0.000001),
						1.0/att3),
					color : h3d.Vector.fromColor(rgb, alpha ),
				};
				m.lightSystem.points[idx] = v; 
			}
			else 
				m.lightSystem.points.splice( idx,1);
				
			m.lightSystem = m.lightSystem;
		});
	}
	
	public static function addPointLight( o : h3d.scene.Object, 
		posx:Float, posy:Float, posz:Float,
		att0:Float, att1:Float, att2:Float, // linear , quadratic, cubic
		rgb:Int, alpha:Float ) {
			
		initLightSystem(o);
		meshMaterialTraverse(o, function(m) {
			m.lightSystem.points.push( 
			{
				pos : new h3d.Vector(posx, posy, posz),
				att : new h3d.Vector(hxd.Math.min(att0, 0.0000000001), hxd.Math.min(att1, 0.0000000001), hxd.Math.min(att2, 0.0000000001)),
				color : h3d.Vector.fromColor(rgb, alpha ),
			}); 
			m.lightSystem = m.lightSystem;
		});
	}
	

	
	public static function detectBadVertices() {
		h3d.fbx.Library.detectBadVertices = true;
	}
	
	
	public static function addDirLight( o : h3d.scene.Object, 
		dirx:Float, diry:Float, dirz:Float, // linear , quadratic, cubic
		rgb:Int, alpha:Float ) {
			
		initLightSystem(o);
		meshMaterialTraverse(o, function(m) {
			m.lightSystem.dirs.push( {
				dir : new h3d.Vector(dirx, diry, dirz).getNormalized(),
				color : h3d.Vector.fromColor(rgb, alpha),
			}); 
			m.lightSystem = m.lightSystem;
		});
	}
	
	public static function getDummyPos( ?obj:h3d.scene.Object,str:String) : h3d.Vector {
		if ( obj == null )
			obj = scene;
		var o = obj.findByName(str);
		var pos = new h3d.Vector(0, 0, 0);
		if( o != null ) pos = o.localToGlobal(pos);
		return pos;
	}

	public static function dispose() {
		actions = [];
	}

	static var rc : h3d.scene.RenderContext;
	public static function dummyContext() {
		if ( rc == null) {
			rc = new h3d.scene.RenderContext();
			rc.elapsedTime = 0.0;
		}
		rc.frame--;
		return rc;
	}
	
	public static function debugLine(start, end, col) {
		var p = line(start, end, col);
		haxe.Timer.delay( scene.removePass.bind(p), 500 );
	}
	
	public static function line(start, end, col) {
		var l;
		scene.addPass( l = new Line( start, end, col ));
		return l;
	}
	
	public static function point(pos,  col) {
		var p;
		scene.addPass( p= new Point( pos, col ));
		return p;
	}
	
	public static function shareShader( o : h3d.scene.Object, arr : Array<h3d.scene.Object>) {
		var sm = getMesh( o );
		for ( a in arr)
			a.traverse(function(e) {
				if ( e.isMesh()) {
					var m = e.toMesh();
					m.material.shader = sm.material.shader.clone();
				}
			});
	}
	
	public static function cloneMaterial( o : h3d.scene.Object, arr : Array<h3d.scene.Object>) {
		var sm = getMesh( o );
		for ( a in arr)
			a.traverse(function(e) {
				if ( e.isMesh()) {
					var m = e.toMesh();
					m.material = sm.material.clone();
				}
			});
	}
	
	public static function randomVertex( o : h3d.scene.Object , ?out:h3d.Vector) : h3d.Vector {
		if ( out == null ) 
			out = new Vector();
			
		var lRoot = getMesh(o);
		if ( lRoot == null ) return out;
		
		var mPrim = getFBXPrimitive( lRoot );
		if ( mPrim == null ) return out;
		
		var nb = nbVertex( mPrim );
		return getVertex( Std.random( nb ), o, out ); 
	}
	
	public static function getVertex( idx:Int, o : h3d.scene.Object , ?out:h3d.Vector) : h3d.Vector{
		if ( out == null ) 
			out = new Vector();
			
		var lRoot = getMesh(o);
		if ( lRoot == null ) return out;
		
		var mPrim = getFBXPrimitive( lRoot );
		if ( mPrim == null ) return out;
		
		if( o.animations[0] == null || mPrim.skin == null )
			out = skinVertex( getLocalVertex( idx, mPrim ), lRoot ); 
		else {
			var sk = getSkin( lRoot ) ;
			var lpos = getLocalVertex( idx, mPrim );
			
			var bytes = mPrim.geomCache.sbuf.getBytes();
			var pos = idx * 4 * 4;// 4 32 bit values
			
			var f0 = bytes.getFloat(pos);
			var f1 = bytes.getFloat(pos+4);
			var f2 = bytes.getFloat(pos+8);
			
			var idx0 = bytes.get(pos + 12);
			var idx1 = bytes.get(pos + 13);
			var idx2 = bytes.get(pos + 14);
			
			var skinned0 = lpos.clone();
			var skinned1 = lpos.clone();
			var skinned2 = lpos.clone();
			
			skinned0.transform( sk.currentPalette[idx0]);
			skinned1.transform( sk.currentPalette[idx1]);
			skinned2.transform( sk.currentPalette[idx2]);
			
			var total = new Vector(0, 0, 0, 1.0);
			
			total.mad( skinned0, f0 );
			total.mad( skinned1, f1 );
			total.mad( skinned2, f2 );
			
			out.load(total);
		}
		return out;
	}
	
	public static inline function getNormal( idx:Int, o : h3d.scene.Object, ?out:h3d.Vector) : h3d.Vector{
		if ( out == null ) 
			out = new Vector();
			
		var lRoot = getMesh(o);
		if ( lRoot == null ) return out;
		
		var mPrim = getFBXPrimitive( lRoot );
		if ( mPrim == null ) return out;
		
		if ( o.animations[0] == null || mPrim.skin == null ) {
			var n = getLocalNormal( idx, mPrim );
			n.transform3x3( o.getMatrix() );
			out.load(n);
		}
		else {
			var sk = getSkin( lRoot ) ;
			var lnorm = getLocalNormal( idx, mPrim );
			
			var bytes = mPrim.geomCache.sbuf.getBytes();
			var pos = idx * 4 * 4;// 4 32 bit values
			
			var f0 = bytes.getFloat(pos);
			var f1 = bytes.getFloat(pos+4);
			var f2 = bytes.getFloat(pos+8);
			
			var idx0 = bytes.get(pos + 12);
			var idx1 = bytes.get(pos + 13);
			var idx2 = bytes.get(pos + 14);
			
			var skinned0 = lnorm.clone();
			var skinned1 = lnorm.clone();
			var skinned2 = lnorm.clone();
			
			skinned0.transform3x3( sk.currentPalette[idx0]);
			skinned1.transform3x3( sk.currentPalette[idx1]);
			skinned2.transform3x3( sk.currentPalette[idx2]);
			
			var total = new Vector(0, 0, 0, 1.0);
			
			total.mad( skinned0, f0 );
			total.mad( skinned1, f1 );
			total.mad( skinned2, f2 );
			
			out.load(total);
		}
		return out;
	}
	
	public static inline function skinVertex( v : h3d.Vector, o : h3d.scene.Object) 
		: h3d.Vector {
		var tmp = v.clone();
		tmp.transform3x4( o.getMatrix());
		return tmp;
	}
	
	
	public static inline function getLocalVertex(idx:Int, o:h3d.prim.FBXModel) : h3d.Vector {
		if ( o.geomCache == null)
			o.alloc( h3d.Engine.getCurrent() );
		var vert = o.geomCache.pbuf;
		return new Vector(
			vert[ idx * 3 	 	],
			vert[ idx * 3 + 1 	],
			vert[ idx * 3 + 2 	] );
	}
	
	public static inline function getLocalNormal(idx:Int, o:h3d.prim.FBXModel) : h3d.Vector {
		if ( o.geomCache == null)
			o.alloc( h3d.Engine.getCurrent() );
		var norm = o.geomCache.nbuf;
		return new Vector(
			norm[ idx * 3 	 	],
			norm[ idx * 3 + 1 	],
			norm[ idx * 3 + 2 	] );
	}
	
	public static inline function nbVertex(o:h3d.prim.FBXModel){
		return Std.int(o.geomCache.pbuf.length / 3);
	}
	
	public static function makeFacingY(o:h3d.scene.Object,corrAngle:Float) {
		new ProcBehaviour( o, function() {
			var cam = scene.camera;
			var camPos = cam.pos.clone();
			var objPos = o.getMatrix().pos();
			var angle = Math.atan2( objPos.y - camPos.y, objPos.x - camPos.x );
			angle += corrAngle;
			o.setRotateAxis(0, 0, 1, angle );
		});
	}
	
	public static function makeFacingZero(o:h3d.scene.Object, corrAngle:Float) {
		var p=null;
		p=new ProcBehaviour( o, function() {
			var objPos = o.getMatrix().pos();
			var angle = Math.atan2( objPos.y, objPos.x);
			angle += corrAngle;
			o.setRotateAxis(0, 0, 1, angle );
			p.destroy();
		});
	}
	
}



