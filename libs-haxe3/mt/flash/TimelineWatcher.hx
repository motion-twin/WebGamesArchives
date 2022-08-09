package mt.flash;

import flash.display.MovieClip;
import flash.events.Event;
/** OPENFL n'est pas supporté actuellement car ils exposent pas les méthodes nécéssaires à cette classe **/
class TimelineWatcher implements mt.signal.Signaler2
{
#if !openfl
	@:signal
	public var onLabel:String->Int->Void;
	
	@:signal
	public var onLabelEnd:String->Void;
	
	@:signal
	public var onEndTimeline:String->Int->Void;
#end

	@:signal 
	public var onFrame:Int->Void;
	
	@:signal 
	public var onFinish:Void->Void;
	
	public var isAtStop(default, null)	: Bool;
	public var timeline(default, null)	: MovieClip;
	var previousLabel					: String;
	var previousFrame 					: Int;
	var watchedFrames:List<Int>;
	
	/**
	 * The TimelineWatcher class provides functionality to watch a timeline
	 */
	public function new(timeline:MovieClip)
	{
		this.timeline = timeline;
		this.previousFrame = timeline.currentFrame - 1;
		this.previousLabel = null;
		watchedFrames = new List();
		timeline.stop();
	}
	
	public function watch(p_frame:Int)
	{
		watchedFrames.add(p_frame);
	}
	
	public function update()
	{
		try
		{
			timeline.nextFrame();
			var total = #if(swf && mBase && flash) timeline.__totalFrames #else timeline.totalFrames #end;
			var current =  #if(swf && mBase && flash) timeline.__currentFrame #else timeline.currentFrame #end;
			isAtStop = previousFrame == current;
			if( !isAtStop )
			{
				for( f in watchedFrames )
				{
					if( f == current )
					{
						onFrame.dispatch(f);
						break;
					}
				}
				
				if ( current == total )
				{
					onFinish.dispatch();
				}
			#if !openfl
				var cl 	: String 	= timeline.currentLabel;
				
				for( label in timeline.currentLabels )
				{
					if( label.frame == current + 1 )
					{
						this.dispatchEndLabel(cl);
						break;
					}
				}
				
				if( cl != previousLabel )
				{
					this.dispatchLabel(cl, current);
				}
				
				if( current == timeline.totalFrames && current != previousFrame )
				{
					this.dispatchEndLabel(cl);
					this.dispatchEndTimeline(cl, current);
				}
				
				previousLabel = cl;
			#end
				previousFrame = current;
			}
		} catch(e:Dynamic) {}
	}
	
	/**
	 * Dispose a TimelineWatcher instance
	 */
	public function dispose():Void
	{
		try
		{
		#if !openfl
			onLabel.dispose();
			onLabelEnd.dispose();
			onEndTimeline.dispose();
		#end
			onFrame.dispose();
			watchedFrames = null;
			timeline = null;
		} catch(e:Dynamic) {}
	}
}
