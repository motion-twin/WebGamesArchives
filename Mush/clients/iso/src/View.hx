package ;
import flash.display.MovieClip;
import flash.text.TextFieldAutoSize;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.MouseEvent;
/**
 * ...
 * @author de
 */

 import mt.bumdum9.Lib;
 using As3Tools;


class View extends MovieClip
{
	public function new()
	{
		super();
		fx = [];
		onScrollDone = null;
	}
	
	public function init()
	{
		#if !master
			drawHelp();
		#end
		
	}
	
	public inline function getScrollPix()
	{
		return { x: Std.int(this.x), y:Std.int(this.y) };
	}
	
	public function scrollPix(x : Float,y:Float)
	{
		this.x = Std.int(x);
		this.y = Std.int(y);
	}
	
	static function viewLerp(v0 : Float,v1: Float,t: Float) : Float
	{
		var tt = t <= MathEx.EPSILON ? 0 : Math.sqrt( t );
		return Math.round( (v1 - v0) * tt + v0 ) ;
	}
	
	public function isScrolling()
	{
		return fx.length != 0;
	}
	
	public function update()
	{
		if (!isScrolling() && (onScrollDone != null))
		{
			var proc = onScrollDone;
			onScrollDone = null;
			proc();
		}
	}
	
	var onScrollDone : Void->Void;
	
	public function onEndScroll(f : Void->Void)
	{
		Debug.ASSERT( f != null);
		if ( isScrolling() )
		{
			onScrollDone = f;
		}
		else
		{
			onScrollDone = null;
			f();
		}
	}
	
	public function stopScroll()
	{
		for ( x in fx )
		{
			x.kill();
		}
		fx = [];
	}
	
	var fx : Array<fx.FX>;
	public function tweenPix(x : Float,y: Float)
	{
		fx.push( new fx.Tween( 0.4, this.x, x, function(v) this.x = v )
							.interp( viewLerp )
							.end( function(t) fx.remove(t)) );
							
		fx.push( new fx.Tween( 0.4, this.y, y, function(v) this.y = v )
					.interp( viewLerp )
					.end( function(t) fx.remove(t)) );
	}
	
	public function scrollCell(x,y)
	{
		var v = V2DIso.grid2px(x, y);
		scrollPix( v.x,v.y );
	}
	
	public var message : TextField;
	public var fpsMeter : TextField;
	
	public function drawHelp()
	{
		var baseT = 8;
		var doT = function(txt)
		{
			var t = new flash.text.TextField();
			t.x = 8;
			t.y = baseT;
			t.text = txt;
			//t.borderColor = 0xFFFF0000;
			t.textColor = 0xFFCDCDCD;
			baseT += 18;
			t.visible = true;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.selectable = false;
			t.mouseEnabled = false;
			//t.addEventListener(  MouseEvent.MOUSE_OVER, function(_) { Debug.MSG("aie"); } );
			//addChild( t );
			return t;
		};
		
		var o = doT("CTRL-S : sauvegarde de la configuration");
		
		var gui = Main.guiStage();
		gui.addChild( o );
		gui.addChild( doT("X : swap de perso"));
		gui.addChild( doT("HAUT BAS GAUCHE DROITE : Deplacer la vue"));
		gui.addChild( doT("CLICK sur perso : changement orientation"));
		gui.addChild( doT("CLICK cadre vert : deplacement"));
		
		gui.addChild( doT("B N : Piece precedente/suivante"));
		
		for( d in Main.keyb.downHandlers )
			gui.addChild( doT( d.msg ) );
		
		for( d in Main.keyb.releasedHandlers)
			gui.addChild( doT( d.msg ) );
		
		message = doT("");
		message.x = Window.W() - 96;
		message.y = 32;
		message.textColor = 0xFFFf0000;
		message.mouseEnabled = false;
		gui.addChild( message );
		
		fpsMeter = doT("FPS");
		fpsMeter.x = Window.W() - 96;
		fpsMeter.y = 48;
		fpsMeter.textColor = 0xFFFf0000;
		fpsMeter.mouseEnabled = false;
		gui.addChild( fpsMeter );
		
		Main.loadingScreen.toFront();
	}
	
	
}
