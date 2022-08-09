package ;

import Lib;
import flash.display.GradientType;
import flash.display.SpreadMethod;
	
class Reflection extends MovieClip
{
	//reference to the original content
	public var mcRef(default, null):DisplayObject;
	//the BitmapData object that will hold a visual copy of the mc
	var mcBMP:BitmapData;
	//the BitmapData object that will hold the reflected image
	var reflectionBMP:Bitmap;
	//the clip that will act as out gradient mask
	var gradientMask:MovieClip;
	var bounds:Rectangle;
	//the distance the reflection is vertically from the mc
	public var distance(default, null):Float;
	var dropOff:Float;
	var gradientRatio:Float;
	
	/**
	 *
	 * @param	mc
	 * @param	?alpha=1.0  Reflection alpha level
	 * @param	?gradientRatio=100 the ratio opaque color used in the gradient mask
	 * @param	?dropOff=0. the distance at which the reflection visually drops off at
	 * @param	?distance=0. the distance the reflection starts from the bottom of the mc
	 */
	public function new(mc:DisplayObject, ?alpha = 1.0, ?gradientRatio = 100, ?dropOff = 0., ?distance = 0. )
	{
		super();
		this.mcRef = mc;
		//
		this.gradientRatio = gradientRatio;
		this.dropOff = dropOff;
		this.distance = distance;
		this.bounds = mc.getBounds(mc);
		//create the BitmapData that will hold a snapshot of the movie clip
		mcBMP = snapshot(mc);
		reflectionBMP = new Bitmap(mcBMP);
		//move the reflection to the bottom of the movie clip
		reflectionBMP.scaleY = -1;
		reflectionBMP.x = bounds.x;
		reflectionBMP.y = (bounds.height * 2) + distance + bounds.y;
	
		var reflectionBMPRef = addChild(reflectionBMP);
		reflectionBMPRef.name = "reflectionBMP";
		
		//add a blank movie clip to hold our gradient mask
		var gradientMaskRef = addChild( new MovieClip() );
		gradientMaskRef.name = "gradientMask";
		gradientMaskRef.y = distance;
		
		//get a reference to the movie clip - cast the DisplayObject that is returned as a MovieClip
		gradientMask = cast gradientMaskRef;
		//set the values for the gradient fill
		var fillType = GradientType.LINEAR;
		var colors = [0xFFFFFF, 0xFFFFFF];
		var alphas = [alpha, 0];
		var ratios = [0, gradientRatio];
		var spreadMethod = SpreadMethod.PAD;
		//create the Matrix and create the gradient box
		var matr = new Matrix();
		//set the height of the Matrix used for the gradient mask
		var matrixHeight;
		if( dropOff <= 0 )
		{
			matrixHeight = bounds.height;
		}
		else
		{
			matrixHeight = bounds.height / dropOff;
		}
		matr.createGradientBox(bounds.width, matrixHeight, (90/180)*Math.PI, 0, 0);
		//create the gradient fill
		gradientMask.graphics.beginGradientFill(fillType, cast colors, alphas, ratios, matr, spreadMethod);
		gradientMask.graphics.drawRect(0,0,bounds.width,bounds.height);
		//position the mask over the reflection clip
		gradientMask.x = reflectionBMPRef.x;
		gradientMask.y = reflectionBMPRef.y - reflectionBMPRef.height;
		//cache clip as a bitmap so that the gradient mask will work
		gradientMask.cacheAsBitmap = true;
		reflectionBMPRef.cacheAsBitmap = true;
		//set the mask for the reflection as the gradient mask
		reflectionBMPRef.mask = gradientMask;
		
		this.y = distance;
	}
	
	function snapshot(clip:DisplayObject)
	{
		var b = new BitmapData(Std.int(.5+bounds.width), Std.int(.5+bounds.height), true, 0x0);
		var m = new Matrix();
		m.translate( -bounds.x, -bounds.y );
		b.draw(clip, m, clip.transform.colorTransform);
		return b;
	}
	
	public function redraw(mc:DisplayObject)
	{
		mcBMP.dispose();
		mcBMP = snapshot(mc);
	}
	
	//updates the reflection to visually match the movie clip
	public function update()
	{
		redraw(mcRef);
		reflectionBMP.bitmapData = mcBMP;
	}
	
	public function dispose()
	{
		while( numChildren > 0 )
			removeChildAt(0);
		reflectionBMP = null;
		mcBMP.dispose();
	}
}