package seq;
import mt.bumdum9.Lib;
import mt.kiroukou.flash.TimelineWatcher;

@:build( mt.kiroukou.macros.IntInliner.create( [
	STEP_SHOW,
	STEP_HIDE,
] ) )
class ShowBallInfo extends mt.fx.Sequence
{
	var root 	: gfx.CardAnim;
	var smc 	: gfx.Card;
	var ball 	: Null<ent.Ball>;
	var watcher : TimelineWatcher;
	var _timer 	: Null<haxe.Timer>;
	
	public function new()
	{
		super();
		root = new gfx.CardAnim();
		smc = root._smc;
		watcher = new TimelineWatcher(root);
		Game.me.dm.add( root, Game.DP_UI );
		init();
	}
	
	function init()
	{
		var stageW = Cs.WIDTH, stageH = Cs.HEIGHT;
		root.x = stageW;
		root.y = stageH;
	}
	
	function updateInfos()
	{
		if( ball == null )
			#if dev throw "No ball is selected"
			#else return
			#end;
			
		var bdata = null;
		for( data in ent.Ball.DATA )
		{
			if( data.id == this.ball.type )
			{
				bdata = data;
				break;
			}
		}
		smc._ball.gotoAndStop(Type.enumIndex(ball.type) + 1);
		smc._ball.smc.gotoAndStop("stand");
		
		smc._title.text = Texts.ALL.get(Std.string(bdata.id)+"_NAME");
		smc._txt.text = Texts.ALL.get(Std.string(bdata.id)+"_DESC");
	}
	
	override public function setStep(step : Int, ?spc:Float)
	{
		super.setStep(step, spc);
		switch(step)
		{
			case STEP_SHOW : if( root.currentLabel != "start" ) 	root.gotoAndPlay("start");
			case STEP_HIDE : if( root.currentLabel != "end" ) 		root.gotoAndPlay("end");
		}
	}
	
	function clean()
	{
		if( _timer != null )
		{
			_timer.stop();
		}
	}
	
	public function show()
	{
		setStep(STEP_SHOW);
	}
	
	public function hide()
	{
		setStep(STEP_HIDE);
		if( _timer != null ) _timer.stop();
		_timer = null;
	}
	
	public function hideInfo()
	{
		clean();
		ball = null;
		if( root.currentLabel == "start" )
		{
			_timer = haxe.Timer.delay( hide, 300 );
		}
	}
	
	public function showInfo( pBall : Null<ent.Ball> )
	{
		clean();
		if( pBall == null )
		{
			hideInfo();
			return;
		}
		//
		if( ball == null )
		{
			_timer = haxe.Timer.delay( show, 500 );
		}
		ball = pBall;
		updateInfos();
	}
	
	override function kill()
	{
		watcher.dispose();
		root.parent.removeChild(root);
		super.kill();
	}
}
