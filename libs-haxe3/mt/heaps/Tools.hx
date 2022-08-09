package mt.heaps;
import h2d.BlurredBitmap;
import h2d.col.Point;
import h2d.Drawable;
import h2d.Sprite;
import h3d.Matrix;
import hxd.Macros;
import hxd.Math;


class Tools {

	/**
	 * will fallback to gaussian3x3
	 */
	public static function blur( spr : h2d.Sprite, ?method : BlurMethod, ?freezed = false) : BlurredBitmap {
		var parent = spr.parent;
		var index = 0;
		if ( parent != null )
			index = spr.parent.getChildIndex(spr);
			
		var b = spr.getBounds();
		spr.detach();
		
		var bsize : Int = 4;//keep some pixel
		var hbsize : Int = (bsize >> 1);
		var blur = new BlurredBitmap(parent, Math.ceil(b.width + bsize), Math.ceil(b.height + bsize), method);
		
		blur.x = spr.x;
		blur.y = spr.y;
		blur.rotation =  spr.rotation;
		blur.scaleX = spr.scaleX; 
		blur.scaleY = spr.scaleY; 
		
		spr.scaleX = 1.0;
		spr.scaleY = 1.0;
		spr.x = 0;
		spr.y = 0;
		spr.rotation = 0;
		
		spr.x += b.width*0.5 + hbsize;
		spr.y += b.height*0.5 + hbsize;
		
		blur.freezed = freezed;
		blur.addChild( spr );
		
		blur.x -= hbsize + b.width *0.5;
		blur.y -= hbsize + b.height *0.5;
		
		parent.addChildAt( blur, index );
		return blur;
	}
	
	public static function glow( spr : h2d.Sprite, ?col : Int = 0xFFd700, ?alpha = 1.0, ?freezed = false  ) : BlurredBitmap {
		col = col & 0xFFFFFF;
		var method = Gaussian3x3OnePass;
		var blur = Tools.blur(spr, method, freezed);
		blur.redrawChilds = true;
		var ca = hxd.Math.getColorVector(col);
		ca.w = alpha;
		blur.colorSet = ca;
		blur.killAlpha = true;
		
		return blur;
	}
	
	
	
	public static function dropShadow( 
		spr : h2d.Sprite, ?col : Int = 0x0, 
		?alpha = 0.5, ofsX = 2.5, ofsY = 2.0, ?freezed = false  ) 	: BlurredBitmap {
		
		col = col & 0xFFFFFF;
		var method = Gaussian3x3OnePass;
		var blur = Tools.blur(spr, method, freezed);
		blur.width += ofsX;
		blur.height += ofsY;
		blur.redrawChilds = true;
		
		var m = new Matrix();
		var c = hxd.Math.getColorVector(col);
		c.w = alpha;
		m.identity();
		m._11 = 0.3; m._21 = 0.59; m._31 = 0.11;
		m._12 = 0.3; m._22 = 0.59; m._32 = 0.11;
		m._13 = 0.3; m._23 = 0.59; m._33 = 0.11;
		blur.colorMatrix = m;
		blur.color = c;
		
		var spr = blur.getChildAt(0);
		blur.ofsX = ofsX;
		blur.ofsY = ofsY;
		blur.blendMode = h2d.BlendMode.Multiply;
		
		return blur;
	}
	
	/**
	 * Will not restore coordinates 
	 */
	public static function unglow(spr:h2d.Sprite) : h2d.Sprite {
		if ( !Std.is( spr, h2d.BlurredBitmap )) return spr;
		
		var c = spr.getChildAt( 0 );
		c.scaleX = spr.scaleX;
		c.scaleY = spr.scaleY;
		c.rotation = spr.rotation;
		
		spr.parent.addChildAt( c, spr.parent.getChildIndex( spr ));
		spr.detach();
		
		return c;
	}
	
	public static function createSphere() : h3d.scene.Object{
		var mt	= new h3d.mat.MeshMaterial( h3d.mat.Texture.fromColor(0xFFFF00FF));
		mt.blendMode = None;
		var prim	= new h3d.prim.Sphere();
		prim.addUVs();
		prim.addNormals();
		var obj = new h3d.scene.Mesh(prim, mt, null);
		obj.scale(0.03);
		return obj;	
	}
	
	public static function putUnder( a : h3d.scene.Object, b : h3d.scene.Object ) {
		if ( a == null ) return;
		
		var root = a.parent;
		var aIndex = root.getChildIndex( a );
		b.remove();
		root.addChildAt( b , aIndex-1);
	}
	
	public static function putOnTop( a:h3d.scene.Object, b:h3d.scene.Object ) {
		if ( a == null ) return;
		
		var root = a.parent;
		var aIndex = root.getChildIndex( a );
		b.remove();
		root.addChildAt( b , aIndex+1);
	}
	
	public static function putOnTop2D( a:h2d.Sprite, b:h2d.Sprite ) {
		if ( a == null ) return;
		
		var root = a.parent;
		var aIndex = root.getChildIndex( a );
		b.remove();
		root.addChildAt( b , aIndex+1);
	}
	
	//replace A occurence by B
	public static function replace( a:h2d.Sprite, b:h2d.Sprite ) {
		if ( a == null ) return;
		
		var root = a.parent;
		var aIndex = root.getChildIndex( a );
		b.remove();
		a.remove();
		root.addChildAt( b , aIndex);
	}
}

