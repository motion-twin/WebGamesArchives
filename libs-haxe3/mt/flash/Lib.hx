package mt.flash;
import flash.geom.Matrix;

typedef TextField = flash.text.TextField;
typedef TextFormat = flash.text.TextFormat;

typedef Bitmap = flash.display.Bitmap;
typedef BitmapData = flash.display.BitmapData;

typedef Shape = flash.display.Shape;
typedef DisplayObject = flash.display.DisplayObject;
typedef DisplayObjectContainer = flash.display.DisplayObjectContainer;
typedef Sprite = flash.display.Sprite;
typedef MovieClip = flash.display.MovieClip;

typedef Rectangle = flash.geom.Rectangle;
typedef Point = flash.geom.Point;
typedef Matrix = flash.geom.Matrix;

typedef Keyboard = flash.ui.Keyboard;

class Lib
{
	public static function printHierarchy(mc:DisplayObject)
	{
		var s = "";
		while ( mc != null )
		{
			s += mc + "("+mc.name+") > ";
			mc = mc.parent;
		}
		return s;
	}

	public static function center(mc:DisplayObject, p_with:Float, p_height:Float ):DisplayObject
	{
		mc.x = (p_with - mc.width) / 2;
		mc.y = (p_height - mc.height) / 2;
		return mc;
	}

	/**
	 * The shape will be scaled to fit the destination sizes keeping its original ratio
	 * The shape will fit AT MAXIMUM the targeted rectangle
	 */
	public static function fitIn( mc:DisplayObject, p_width:Float, p_height:Float ):DisplayObject
	{
		var ratio = mc.width / mc.height;
		if ( Math.isNaN(ratio) ) ratio = 1.0;
		if(p_width / ratio > p_height)
		{
			mc.width = p_height * ratio;
			mc.height = p_height;
		}
		else
		{
			mc.width = p_width;
			mc.height = p_width / ratio;
		}
		return mc;
	}

	/**
	 * The shape will be scaled to fit the destination sizes keeping its original ratio
	 * The shape will fit AT MINIMUM the targeted rectangle, meaning the the resulting shape may exeed targeted width or height depending on original ratio
	 */
	public static function fitOut( mc:DisplayObject, p_width:Float, p_height:Float):DisplayObject
	{
		var ratio = mc.width / mc.height;
		if(p_width / ratio < p_height)
		{
			mc.width = p_height * ratio;
			mc.height = p_height;
		}
		else
		{
			mc.width = p_width;
			mc.height = p_width / ratio;
		}
		return mc;
	}

	public static inline function randomFrame( mc:flash.display.MovieClip, ?rnd:Int->Int ) :flash.display.MovieClip
	{
		if ( rnd == null ) rnd = Std.random;
		var id = rnd( mc.totalFrames - 1 ) + 1;
		mc.gotoAndStop(id);
		return mc;
	}

	public static inline function removeAllChildren( mc : DisplayObjectContainer ) : DisplayObjectContainer{
		while( mc.numChildren > 0 ){
			mc.removeChildAt(0);
		}
		return mc;
	}

	public static function scale( s : DisplayObject, value:Float ) : DisplayObject{
		s.scaleX = s.scaleY = value;
		return s;
	}

	public static inline function toFront( mc : DisplayObject ) : DisplayObject{
		if( mc.parent != null)
			mc.parent.setChildIndex( mc , mc.parent.numChildren - 1 );
		return mc;
	}

	/**
	 * Hierarchically send the sprite to front of the display list... with its parents !
	 */
	public static inline function toFrontEx( mc : DisplayObject ) : DisplayObject{
		if ( mc.parent != null) {
			mc.parent.setChildIndex( mc , mc.parent.numChildren - 1 );
			toFrontEx( mc.parent );
		}
		return mc;
	}

	public static inline function putBefore( mc0 : DisplayObject, mc1 : DisplayObject ) : DisplayObject{
		detach( mc0);
		var i = mc1.parent.getChildIndex( mc1 );
		mc1.parent.addChildAt( mc0,i + 1 );
		return mc0;
	}

	public static inline function putAfter( mc0 : DisplayObject, mc1 : DisplayObject ) : DisplayObject
	{
		detach( mc0);
		if( mc1.parent != null)
		{
			var i = mc1.parent.getChildIndex( mc1 );
			mc1.parent.addChildAt( mc0, i  );
		}
		return mc0;
	}

	public static inline function toBack( mc : DisplayObject ) : DisplayObject
	{
		if( mc.parent != null)
		{
			mc.parent.setChildIndex( mc , 0);
		}
		return mc;
	}

	public static inline function detach( a : DisplayObject ) : DisplayObject{
		if( a!=null && a.parent != null)
			a.parent.removeChild( a );
		return a;
	}

	public static inline function listChildren( mc : DisplayObjectContainer) : Iterable<DisplayObject>{
		var v = new #if haxe3 haxe.ds.GenericStack<DisplayObject>() #else haxe.FastList<DisplayObject>() #end;
		for( i in 0...mc.numChildren)
		{
			v.add( mc.getChildAt(i) );
		}
		return v;
	}

	public static function listAllChildren( mc : DisplayObjectContainer, ?addContainers:Bool = false) : Iterable<DisplayObject>{
		var v = new #if haxe3 haxe.ds.GenericStack<DisplayObject>() #else haxe.FastList<DisplayObject>() #end;
		for( i in 0...mc.numChildren)
		{
			var child = mc.getChildAt(i);
			if ( Std.is( child, DisplayObjectContainer) )
			{
				if ( addContainers ) v.add(child);
				for ( e in Lib.listAllChildren(cast child, addContainers) )
					v.add(e);
			}
			else
			{
				v.add( child );
			}
		}
		return v;
	}

	public static function stopAllAnimation(par:DisplayObjectContainer):DisplayObjectContainer{
		if( Std.is(par, MovieClip ))
		{
			var par : MovieClip = cast par;
			par.stop();
		}

		for( m in 0...par.numChildren)
		{
			var s = par.getChildAt(m);
			if( Std.is( s , DisplayObjectContainer))
				stopAllAnimation(cast s);
		}

		return par;
	}

	/**
	 * Flatten en bitmap l'object vectoriel.
	 * à la différent de la fonction flatten, pixFlatten créé un object bitmap à taille exacte de l'objet au moment de l'appel.
	 * Ainsi l'objet bitmap retourné n'a pas de transformation appliquée, et est donc pixel perfect, sans problème d'aliasing.
	 */
	public static function pixFlatten( mc:flash.display.DisplayObject, ?p_matrix:flash.geom.Matrix, ?smoothing = false, ?padding = 0.0, ?p_buffer:Null<BitmapData>=null, ?p_container:Null<Bitmap>=null ):Bitmap {
		var bounds = mc.getBounds(mc);
		var m = if ( p_matrix != null ) p_matrix.clone()
				else mc.transform.matrix.clone();
		var mDraw = m.clone();
		//TODO necessary?
		mDraw.tx = mDraw.ty = 0;
		mDraw.translate(-bounds.x, -bounds.y);
		if ( padding != 0.0 ) mDraw.translate( padding, padding);

		var buffer = if ( p_buffer == null ) new BitmapData(mt.MLib.ceil(mc.width + padding * 2), mt.MLib.ceil(mc.height + padding * 2), true, 0x0);
					 else p_buffer;

		buffer.draw(mc, mDraw, mc.transform.colorTransform, smoothing);

		if ( p_container == null ) p_container = new Bitmap();
		p_container.bitmapData = buffer;
		p_container.x = bounds.x + m.tx;
		p_container.y = bounds.y + m.ty;
		return p_container;
	}

	/**
	 * experimental
	 */
	public static function advancedFlatten( mc:flash.display.DisplayObjectContainer, p_excludeChildrenList:Array<String>, ?p_replaceChildrenList:Array<String>, ?smoothing = false, ?padding = 0.0 ):Sprite {
		var excludedChildren = [];
		for ( childName in p_excludeChildrenList )
		{
			var child = mc.getChildByName(childName);
			excludedChildren.push( child );
			mc.removeChild( child );
		}
		var replacedChildren = [];
		if ( p_replaceChildrenList != null )
		{
			for ( childName in p_replaceChildrenList )
			{
				var child = mc.getChildByName(childName);
				mc.removeChild( child );

				var b = Lib.flatten(child, 0, true, true );
				b.name = child.name;
				b.alpha = child.alpha;

				replacedChildren.push( b );
			}
		}

		var bounds = mc.getBounds(mc);
		var msave = mc.transform.matrix.clone();
		var m = new flash.geom.Matrix();
		m.translate(-bounds.x, -bounds.y);
		if ( padding != 0.0 ) m.translate( padding, padding);

		var buffer = new BitmapData(mt.MLib.ceil(bounds.width + padding * 2), mt.MLib.ceil(bounds.height + padding * 2), true, 0x0);
		var bitmap = new Bitmap(buffer);
		buffer.draw(mc, m, mc.transform.colorTransform, smoothing);

		var container = new flash.display.Sprite();
		m.identity();
		m.translate(bounds.x, bounds.y);
		if ( padding != 0.0 ) m.translate(-padding, -padding);
		m.scale(mc.scaleX, mc.scaleY);
		m.rotate( mt.MLib.toRad(mc.rotation) );
		m.translate(mc.x, mc.y);
		container.transform.matrix = m;

		container.addChild( bitmap );

		for ( child in replacedChildren )
			container.addChild( child );
		for( child in excludedChildren )
			container.addChild(child);

		return container;
	}

	/**
	 * Classe permettant de transformer le DisplayObjectContainer en version optimisée.
	 * Va transformer en bitmap les enfants de l'objet à l'exception de ceux présents dans p_excludeChildrenList.
	 * Conserve les transformations appliquées, le flatten se faisant à la taille actuelle, le caching ne se voit pas (pixel perfect)
	 * Testé avec SSW et semble robuste !
	 */
	public static function advancedPixFlatten( mc:flash.display.DisplayObjectContainer, p_excludeChildrenList:Array<String>, ?smoothing = false, ?padding = 0.0 ):DisplayObjectContainer
	{
		var x = mc.x;
		var y = mc.y;
		var m = mc.transform.matrix.clone();
		m.tx = m.ty = 0;

		var count = mc.numChildren;
		for ( i in 0...count )
		{
			var child = mc.getChildAt(i);
			var mt = child.transform.matrix;
			mt.concat( m );
			child.transform.matrix = mt;

			if( ! Lambda.has(p_excludeChildrenList, child.name) && !Std.is(child, Bitmap) )
			{
				mc.removeChildAt( i );
				//
				var b = pixFlatten(child, true );
				b.name = child.name;
				b.alpha = child.alpha;
				mc.addChildAt(b, i);
			}
		}

		mc.transform.matrix = new Matrix();
		mc.x = x;
		mc.y = y;
		return mc;
	}

	public static function flatten(mc:flash.display.DisplayObject, ?padding=0.0, ?copyTransforms=false, ?smoothing=false, ?quality:flash.display.StageQuality.StageQuality, ?container:Bitmap ) : Bitmap{
		var qold = flash.display.StageQuality.HIGH;
		if ( flash.Lib.current.stage != null )
		{
			qold = flash.Lib.current.stage.quality;
			if( quality != null )
			{
				try flash.Lib.current.stage.quality = quality catch( e:Dynamic ) throw("flatten quality error");
			}
		}

		var bounds = mc.getBounds(mc);
		var pixels = new BitmapData(mt.MLib.ceil(bounds.width + padding * 2), mt.MLib.ceil(bounds.height + padding * 2), true, 0x0);
		var bmp  = 	if(container != null ) container
					else new Bitmap();
		bmp.bitmapData = pixels;
		//
		var m = new Matrix();
		m.translate(-bounds.x, -bounds.y);
		m.translate(padding, padding);
		pixels.draw(mc, m, mc.transform.colorTransform, smoothing);
		//
		m.identity();
		m.translate(bounds.x, bounds.y);
		m.translate(-padding, -padding);
		if( copyTransforms )
		{
			m.scale(mc.scaleX, mc.scaleY);
			m.rotate( mt.MLib.toRad(mc.rotation) );
			m.translate(mc.x, mc.y);
		}
		bmp.transform.matrix = m;

		if( quality != null )
		{
			if ( flash.Lib.current.stage != null )
			{
				try flash.Lib.current.stage.quality = qold catch ( e:Dynamic ) throw("flatten quality error");
			}
		}
		return bmp;
	}

	/**
	support experimental
	*/
	public static function cacheAllAsBitmap(mc : flash.display.DisplayObjectContainer) : DisplayObjectContainer {
		if ( mc == null ) return null;

		for ( i in 0...mc.numChildren ) {
			var o = mc.getChildAt( i );
			if( Std.is( o, flash.display.DisplayObjectContainer))
				cacheAllAsBitmap( cast o );
			else
				o.cacheAsBitmap = true;
		}

		mc.cacheAsBitmap = true;
		return mc;
	}

	/**
	support experimental
	*/
	public static function freeOne(o : DisplayObject) {
		if ( o == null ) return;

		if ( Reflect.hasField( o, "dispose" ) && Reflect.isFunction( Reflect.getProperty( o , "dispose" )))
			Reflect.callMethod( o, Reflect.getProperty( o , "dispose" ), [] );

		if( Std.is( o,flash.display.Bitmap ))
		{
			var bmp = (cast o);
			if( bmp.bitmapData != null)
				bmp.bitmapData.dispose();
			bmp.bitmapData = null;
		}

		detach(o);
	}

	/**
	support experimental
	*/
	public static function free( mc : DisplayObject )
	{
		if (Std.is( mc, DisplayObjectContainer )) {
			var doc = cast mc;
			for ( i in 0...doc.numChildren ) {
				var o = doc.getChildAt( 0 );

				if(Std.is( o,DisplayObjectContainer ))	free( cast o );
				else 									freeOne( o );

			}
		}

		freeOne(mc);
	}

	/** cant work in regular flash
	public static function freeProperties( mc : DisplayObjectContainer ){
		for ( f in Reflect.fields(mc) ) {
			var val = Reflect.getProperty( mc, f );

			if ( 	Std.is( val , DisplayObjectContainer )
			|| 		Std.is( val , DisplayObject ) )
			{
				free( cast val );
				Reflect.setProperty( mc,f,null);
			}
		}
	}
	*/

	/**
	support experimental
	*/
	public static function freeChildren( mc : DisplayObjectContainer ){
		for ( i in 0...mc.numChildren ) {
			var o = mc.getChildAt( 0 );
			if(Std.is( o,DisplayObjectContainer ))	free( cast o );
			else 									freeOne( o );
		}
	}


	/**
	 * support experimental
	 * not removal safe
	 */
	public static function children( mc : DisplayObjectContainer ) : Iterable<DisplayObject> {
		var i = 0;
		return
		{
			iterator:function() return {
								next: function() { var oi = i;  i++; return mc.getChildAt(oi); },
								hasNext: function() return i < mc.numChildren,
							}
		};
	}

	#if (flash&&!cpp)
	public static function getNativeCaps(){
		var driverInfo : Null<String> = null;
		var contextProfile : Null<String> = null;
		#if h3d
		if( h3d.Engine.getCurrent()!=null && h3d.Engine.getCurrent().driver!=null){
			var driver = Std.instance(h3d.Engine.getCurrent().driver, h3d.impl.Stage3dDriver);
			driverInfo = driver.getDriverName(true);
			#if flash12
			contextProfile = @:privateAccess driver.ctx.profile;
			#end
		}
		#end

		var o = {};
		#if debug
		Reflect.setField(o,"debug",true);
		#end
		#if air
		Reflect.setField(o,"air",true);
		#end
		if( driverInfo != null )
			Reflect.setField(o,"driverInfo",driverInfo);
		if( contextProfile != null )
			Reflect.setField(o,"contextProfile",contextProfile);

		var fv = new flash.net.URLVariables();
		fv.decode( flash.system.Capabilities.serverString );
		var fcaps = {};
		for( k in Reflect.fields(fv) )
			Reflect.setField(fcaps,k,Reflect.field(fv,k));
		Reflect.setField(o,"fcaps",fcaps);

		return 	haxe.Json.stringify( o );
	}
	#end
}


