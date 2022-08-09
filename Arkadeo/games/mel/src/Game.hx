import api.AKApi;
import flash.display.Shape;
import DefaultImport;
import gfx.Title;
import mt.fx.Flash;
import mt.Rand;
using mt.gx.Ex;
using mt.gx.as.Lib;

class TitleLogo extends Title
{
	
}

import McCache;

#if ide
import mt.flash.Key;
#end


@:keep
class Game //extends flash.display.DisplayObject
extends flash.display.Sprite
{
	public var view : View;
	public var level : Level;
	public var char : Char;
	public static var  me:Game;
	public var tweenie : mt.deepnight.Tweenie;
	public var fxMan : mt.fx.Manager;
	public var ui : Ui;
	
	public var time : mt.gx.time.Ticker;
	
	public var score : Int;
	public var fixScore : Int = 0;
	
	public var rd : mt.Rand;
	
	public static function showScore()
	{
		return isLeague();
	}
	
	public static function isLevelup()
	{
		return isLeague() ? false : true;
	}
	
	public static function isLeague()
	{
		#if ide 
			return true;
		#end
		return AKApi.getGameMode() == GM_LEAGUE;
	}
	
	//1...20
	public static function getLevel()
	{
		var n = 1;
		
 		#if !ide 
			n = AKApi.getLevel();
		#end
		
		return n - 1;
	}
	
	public static var conf :
	{
		?deadLine:Bool,
		?deadLineSpeed:Float,
		?spawnBonuses : Bool,
	};
	
	public function getRandom() : mt.Rand
	{
		return new Rand( getSeed() ^ Game.getFrame());
	}
	
	public function destroy() {
		return;
		/*
		if( view != null ) view.destroy();
		view = null;
		
		if( char!=null) char.destroy();
		char = null;
		
		if ( fxMan != null) fxMan.destroy();
		*/
		
		trace("DESTROYING");
	}
	
	public function new()
	{
		super(); 
		
		me = this;
		rd = new mt.Rand(0xdeadbeef + getSeed() );
		#if !ide
		//haxe.Firebug.redirectTraces();
		mt.deepnight.Lib.redirectTracesToConsole();
		#end
		
		fxMan = new mt.fx.Manager();
		
		Nmy.create();
		time = new mt.gx.time.Ticker();
		
		var stage = flash.Lib.current.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
	
		conf = { deadLine: Game.isLeague(), spawnBonuses:false };
		
		if ( Game.isLevelup() )
		{
			var l = Data.LD[Game.getLevel()];
			if ( l.deadline != null )
			{
				conf.deadLine = true;
				conf.deadLineSpeed = l.deadline; 
			}
			if ( Game.getLevel() >= 11 )
				conf.spawnBonuses = true;
		}
		else
			conf.spawnBonuses = true;
		
				
		tweenie = new mt.deepnight.Tweenie( 40 );
		
		addChild( view = new View());
		level = new Level();
		level.init();
		view.addChild( level.getRoot() );
		
		#if ide
			Lib.Prof.get().enable = true;
		#else
			haxe.Firebug.redirectTraces();
		#end
	
		
		ui  = new Ui();
		
		trace("TRUC!! UI");
	}
	
	public var blades :  Array<CachedMc>;
	
	
	public function hasDeadLine()
	{
		if ( Level.NO_DEADLINE ) return false;
		return conf != null && conf.deadLine == true;
	}
	
	public var pause : Bool = false;
	
	public function debugKey()
	{
		return ;
		
		if ( level.gameOverCalled ) return;
		
		if ( isKeyDown( K.ENTER ))
		{
			trace(Lib.Prof.get().dump());
			Lib.Prof.get().clean();
			trace( "nmies kinds: " + level.nmy.count() );
			trace( "tot nmies " + level.nmy.sum( function(l) return l.length ));
			trace( "render w:" + this.width +" h:" + this.height);
			trace( "page:" + level.getPage());
		}
		
		if ( isKeyDown( K.NUMPAD_ADD ))
		{
			Lib.Prof.get().enable = !Lib.Prof.get().enable;
			trace("PROFILER : " + Lib.Prof.get().enable);
		}
		
		if ( isKeyDown( K.NUMPAD_9 ))
		{
			new fx.Win();
		}
		
		if (isKeyDown(K.CONTROL))
		{
			if ( isKeyDown( K.UP ))
			{
				Level.SKIP_VIEW_SYNC = true;
				view.y += 20;
			}
			else if ( isKeyDown( K.DOWN ))
			{
				Level.SKIP_VIEW_SYNC = true;
				view.y -= 20;
			}
		}
		
		if (isKeyDown(K.SHIFT))
		{
			if ( isKeyDown( K.UP ))
			{
				Level.SKIP_VIEW_SYNC = true;
				Main.r.y += 20;
			}
			else if ( isKeyDown( K.DOWN ))
			{
				Level.SKIP_VIEW_SYNC = true;
				Main.r.y -= 20;
			}
		}
		
		if (isKeyDown(K.NUMPAD_5))
		{
			char.powers.set( CP_WALL_STICK );
			char.powers.set( CP_KICK );
			char.powers.set( CP_DOUBLE_JUMP );
			char.powers.set( CP_CANCEL );
			char.powers.set( CP_SUPER_JUMP );
		}
		
	
		
	}
	public function update(_)
	{
		Lib.Prof.get().begin( 'ugm' );
		time.update();
		if ( level.gameOverCalled ) return;
		
		rd.initSeed( (getFrame() + getSeed() * 1337) ^ 0xdeadbeef, 2);
		
		#if debug
		debugKey();
		#end
		
		if ( !pause)
			level.update();
		
		tweenie.update();
		fxMan.update();
		mt.gx.time.FTimer.update();
		if ( level.gameOverCalled ) return;
		
		var nscore = fixScore + Std.int(char.getAbsCy() * 20);
		if ( nscore > score) {
			#if !ide 
			AKApi.addScore( AKApi.const( nscore - score ) );
			#end
			
			var v = Math.abs(( Game.getLevel() * 48683843 + Game.getSeed() * score )  % 500);
			
			if( Game.isLeague() )
				if( v == 1)
 					new fx.SMS( Data.getSmsVar());
				
			score = nscore;
		}
		
		ui.update();
		view.update();
		Lib.Prof.get().end( 'ugm' );
	}
	
	public static function getFrame() : Int
	{
		return
		#if ide
		me.time.ufr;
		#else
		AKApi.getFrame();
		#end
	}
	
	static var sd :Null<Int> = null;
	public static function getSeed() : Int
		#if ide
		
		//return sd != null ? sd : (sd = Std.random( 1354435) * Std.random( 313) + Std.random( 32351315))
		
	 	//return 15111 * getLevel()
		//return 424482 * getLevel()
		//return 6844
		//return Std.random(1253344353)
		//return 256063
		return 4089+15
		//return 40910 //
		//return 40927
		#else
		return api.AKApi.getSeed()
		#end
		
	
	public static function isKeyDown(k)
	{
		#if ide
			return Key.isDown( k );
		#else
			return api.AKApi.isDown(k);
		#end
	}
	
	public static function isKeyToggled(k)
	{
		#if ide
 			return Key.isToggled( k );
		#else
			return api.AKApi.isToggled(k);
		#end
	}
	
	public static function isLowQuality() { return 
		#if ! ide
			AKApi.isLowQuality()
		#else
			false
		#end
		;
	}
}