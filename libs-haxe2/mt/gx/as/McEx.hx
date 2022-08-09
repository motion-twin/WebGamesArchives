package mt.gx.as;

import flash.display.MovieClip;

class McEx
{
	#if !nme
	public static function gotoEnd( pc:MovieClip, min:Int=0)
	{
		if( pc.currentFrame < pc.totalFrames)
			while ( pc.currentFrame != pc.totalFrames)
				pc.nextFrame();
		else
			while ( pc.currentFrame != pc.totalFrames)
				pc.prevFrame();
	}
	#end
}