package mt.kiroukou.flash;

import flash.display.MovieClip;

class TimelineWatcher implements mt.kiroukou.events.Signaler
{
	@:signal
	public function label( signal:mt.kiroukou.events.Signal, label : String, frame : Int ) { }
	
	@:signal
	public function endLabel( signal:mt.kiroukou.events.Signal, label : String ) {}
	
	@:signal
	public function endTimeline( label:String, frame:Int) {}
	
	@:as3signal(flash.events.Event.ENTER_FRAME, timeline)
	private function _frame() {}
	
	public var isAtStop(default, null)	: Bool;
	public var timeline(default, null)	: MovieClip;
	var previousLabel					: String;
	var previousFrame 					: Int;
	
	/**
	 * The TimelineWatcher class provides functionality to watch a timeline
	 */
	public function new(timeline:MovieClip)
	{
		this.timeline = timeline;
		this._bindFrame( watch );
		this.previousFrame = 0;
		this.previousLabel = null;
	}
	
	function watch()
	{
		try
		{
			isAtStop = previousFrame == timeline.currentFrame;
			if( !isAtStop )
			{
				var cf	: Int 		= timeline.currentFrame;
				var cl 	: String 	= timeline.currentLabel;
				
				for( label in timeline.currentLabels )
				{
					if( label.frame == cf + 1 )
					{
						this.dispatchEndLabel(cl);
						break;
					}
				}
				
				if( cl != previousLabel )
				{
					this.dispatchLabel(cl, cf);
				}
				
				if( cf == timeline.totalFrames && cf != previousFrame )
				{
					this.dispatchEndLabel(cl);
					this.dispatchEndTimeline(cl, cf);
				}
				
				previousLabel = cl;
				previousFrame = cf;
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
			unbindAll();
			timeline = null;
		} catch(e:Dynamic) {}
	}
}
