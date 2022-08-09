package mt.heaps.fx;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.Vector;


class Lib {
	public static function setAlphaMin( h : h2d.Sprite , c : Float) {
		h.traverse( function (sp) {
			if ( Std.is(sp, h2d.Drawable)) {
				var d : h2d.Drawable = cast sp;
				d.alpha = Math.min( d.alpha, c);
			}
		});
	}
	
	public static function setAlpha( h : h2d.Sprite , c : Float) {
		h.traverse( function (sp) {
			if ( Std.is(sp, h2d.Drawable)) {
				var d : h2d.Drawable = cast sp;
				d.alpha = c;
			}
		});
	}
	
	public static function setAlphaMax( h : h2d.Sprite , c : Float) {
		h.traverse( function (sp) {
			if ( Std.is(sp, h2d.Drawable)) {
				var d : h2d.Drawable = cast sp;
				d.alpha = Math.max( d.alpha, c);
			}
		});
	}
	
	public static function setAlpha3D( h : h3d.scene.Object , c : Float) {
		h.traverse( 
			function (sp)
				if (sp.isMesh()) {
					var mat = sp.toMesh().material;
					if ( mat.colorMul == null) mat.colorMul = h3d.Vector.ONE.clone();
					sp.toMesh().material.colorMul.a = c;
				}
		);
	}
	
	public static function setAlpha3DMin( h : h3d.scene.Object , c : Float) {
		h.traverse( 
			function (sp)
				if (sp.isMesh()) {
					var mat = sp.toMesh().material;
					if ( mat.colorMul == null)mat.colorMul = h3d.Vector.ONE.clone();
					var cm = mat.colorMul;
					cm.a = Math.min( cm.a, c);
				}
		);
	}
}