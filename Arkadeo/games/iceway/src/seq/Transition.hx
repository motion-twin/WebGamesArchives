package seq;

import mt.fx.Blink;
import mt.fx.Flash;

using Lambda;
using mt.Std;
using mt.flash.Lib;
@:build(mt.kiroukou.macros.IntInliner.create([
	OUT,
	WAIT,
	VANISH,
	IN,
]))
class Transition extends mt.fx.Sequence
{
	var blackMask	: Sprite;
	var scoreView 	: gfx.ScoreScreen;
	var introView 	: gfx.IntroScreen;
	var wait : Int;
	
	public var onHidden : Void->Void;
	
	public function new() 
	{
		super();
	}
	
	public function init()
	{
		if( Game.me.gameLevel == 0 )
		{
			drawBlackMask();
			showIntro();
			setStep(WAIT);
			onHidden();
			introView.toFront();
		}
		else
		{
			wait = 25;
			setStep(OUT, 0.1);
		}
	}
	
	function showIntro()
	{
		var root = Game.me;
		var infos = root.levelInfos;
		//
		introView = new gfx.IntroScreen();
		introView._intro1TF.text = Texts.level_intro_1;
		introView._intro2TF.text = Texts.level_intro_2;
		introView._intro3TF.text = Texts.level_intro_3;
		introView._intro4TF.text = Texts.level_intro_4;
		introView._labelTF.text = Texts.intro_start;
		//
		introView.cacheAsBitmap = true;
		root.addChild(introView);
		//
		wait = 120;
	}
	
	function showScore()
	{
		var root = Game.me;
		var infos = root.levelInfos;
		//
		scoreView = new gfx.ScoreScreen();
		scoreView._titleTF.text = Texts.level_cleared;
		scoreView._levelTF.text = Texts.prochain_niveau( { _level:infos._nextLevel } );
		scoreView._pointsTF.text = Texts.level_points( { _points:infos._score } );
		scoreView._bonusResetTF.text = Texts.bonus_orientation_points( { _points:infos._bonusReset } );
		scoreView._bonusPerfectTF.text = Texts.bonus_perfect_points( { _points:infos._bonusPerfect } );
		//
		scoreView.cacheAsBitmap = true;
		root.addChild(scoreView);
		//
		wait = 120;
	}
	
	public function levelInit()
	{
		var cb = switch( api.AKApi.getGameMode() )
		{
			case GM_PROGRESSION:
				if( Game.me.gameLevel == 0 ) 
				{
					callback(setStep, VANISH);
				}
				else
				{
					wait = 40;
					callback(setStep, IN);
				}
			case GM_LEAGUE:
				callback(setStep, VANISH);
		}
		//
		if( Game.me.gameLevel == 0 ) 
		{
			wait = 300;
		}
		//
		cb();
	}
	
	function drawBlackMask()
	{
		if ( blackMask != null ) 
		{
			return;
		}
		
		blackMask = new Sprite();
		blackMask.graphics.beginFill(0);
		blackMask.graphics.drawRect(0, 0, std.Lib.STAGE_WIDTH, std.Lib.STAGE_HEIGHT);
		blackMask.graphics.endFill();
		Game.me.addChild(blackMask);
	}
	
	override public function setStep(step : Int, ?spc:Float) 
	{
		super.setStep(step, spc);
		switch( step )
		{
			case OUT:
				drawBlackMask();
				blackMask.alpha = 0;
			case IN:
				drawBlackMask();
				var ox = Game.me.gameContainer.x;
				var oy = Game.me.gameContainer.y;
				var pos = std.Lib.getCoord_XY(Game.me.player.cell.x, Game.me.player.cell.y, true);
				var fx = new seq.CircleTransition(Game.me.container, 50, Std.int(pos.x + ox), Std.int(pos.y + oy) );
				fx.onFinish = end;
				Game.me.swapChildren( Game.me.container, blackMask );
		}
	}
	
	override public function update()
	{
		if ( --wait >= 0 ) 
		{
			if ( api.AKApi.isClicked(Game.me) ) wait = 0;
			else if ( blackMask != null && api.AKApi.isClicked(blackMask) ) wait = 0;
			
			return;
		}
		//
		super.update();
		switch( step )
		{
			case OUT:
				blackMask.alpha = coef;
				if( coef == 1 )
				{
					switch( api.AKApi.getGameMode() )
					{
						case GM_PROGRESSION:
						case GM_LEAGUE:
							showScore();
					}
					setStep(WAIT);
					if( onHidden != null )
						onHidden();
				}
			case IN:
			case VANISH:
				setStep(WAIT);
				var view = scoreView == null ? introView : scoreView;
				var fx = new mt.fx.Vanish(view, 20, 10, true);
				fx.onFinish = callback(setStep, IN);
		}
	}
	
	function end()
	{
		Game.me.removeChild(blackMask);
		if( introView != null && introView.parent != null ) introView.parent.removeChild(introView);
		if( scoreView != null && scoreView.parent != null ) scoreView.parent.removeChild(scoreView);
		kill();
	}
	
	override function kill()
	{
		scoreView = null;
		introView = null;
		blackMask = null;
		super.kill();
	}
	
}

