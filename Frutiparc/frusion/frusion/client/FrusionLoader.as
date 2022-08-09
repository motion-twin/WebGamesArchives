/*
	$Id: FrusionLoader.as,v 1.1 2003/11/13 16:04:32  Exp $
*/


import frusion.util.GameFileLoader;
import frusion.util.AnimFileLoader;
import frusion.gamedisc.GameDisc;
import frusion.gfx.LoadingBar;
import frusion.gfx.FrusionAnim;


/*
	Class: frusion.FrusionLoader
	The FrusionLoader class is responsible for loading the frusion logo anim and the game
*/
class frusion.client.FrusionLoader 
{


/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/

	
	private var animLoadingCompleteState : Boolean;
	private var gameLoadingCompleteState : Boolean;
	private var animPlayingCompleteState : Boolean;
	private var gameRunningState : Boolean;
	
	private var gameDisc : GameDisc;
	private var mc : MovieClip;
	
	private var animFileLoader : AnimFileLoader;
	private var gameFileLoader : GameFileLoader;
	
	private var animDepth : Number ;
	private var animScale : Number;
	private var animWidth : Number;
	private var animHeight : Number;

	private var loadDepth : Number;
	private var gameDepth : Number;

	private var loadingBar: LoadingBar;
	private var frusionAnim: FrusionAnim;



/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/


	/*
		Function : FrusionLoader
		Constructor

		Parameters: 
			- mc : MovieClip - context for newly created movie clips ( game and anim )
			- gameDisc :  GameDisc - current game
	*/
	public function FrusionLoader( baseURL : String, mc : MovieClip, gameDisc : GameDisc )
	{
		this.mc = mc;
		this.gameDisc = gameDisc;
		_global.debug("FrusionLoader Const : "+gameDisc.id) ;
		
		this.animDepth = 10;
		this.gameDepth = 5;
		this.loadDepth = 20;
		this.animWidth = 400;
		this.animHeight = 300;

		
		// creating new frusion anim loader 
		this.mc.createEmptyMovieClip("anim_init", this.animDepth );
		this.animFileLoader = new AnimFileLoader( baseURL + "animfrusion.swf", null );
		this.animFileLoader.addListener( this );
		this.frusionAnim = new FrusionAnim( this.mc.anim_init );
		this.animFileLoader.loadClip( this.mc.anim_init );
		
		// creating new game loader
		//_global.debug( "baseURL + gameDisc.id=" + baseURL + gameDisc.id) ;
		this.mc.createEmptyMovieClip( "game", this.gameDepth);
		this.mc.game._visible = false;		
		this.gameFileLoader = new GameFileLoader( baseURL + gameDisc.id, gameDisc.size );
		this.gameFileLoader.addListener(this);
		this.gameFileLoader.loadClip( this.mc.game );				
	}
	
	

/*------------------------------------------------------------------------------------
 * Public callback methods
 *------------------------------------------------------------------------------------*/

		
	/*
		Function: onGameLoadStart
		CALLBACK. When game starts loading, creates loading bar
	*/	
	public function onGameLoadStart() : Void
	{
		//this.loadingBar = new LoadingBar( this.mc, this.loadDepth );
		this.mc.game._visible = false;
	}

	
	/*
		Function: onGameLoadProgress
		CALLBACK. Update current progressbar
	*/	
	public function onGameLoadProgress()
	{
		//this.loadingBar.increase( this.gameFileLoader.percent );
	}


	/*
		Function: onGameLoadComplete
		CALLBACK. update state
	*/
	public function onGameLoadComplete() : Void
	{
		this.gameLoadingCompleteState = true;
		this.tryToLaunchGame();
	}

	
	/*
		Function: onAnimLoadComplete
		CALLBACK. When animation is loaded, update gfx
	*/
	public function onAnimLoadComplete() : Void
	{
		this.frusionAnim.update();
		this.animLoadingCompleteState = true;
	}
	

/*------------------------------------------------------------------------------------
 * Private methods
 *------------------------------------------------------------------------------------*/


	/*
		Function: tryToLaunchGame
		Verifies states and launch game is all conditions are met.
	*/
	private function tryToLaunchGame() : Void
	{
		if( this.gameLoadingCompleteState 
				&& this.animLoadingCompleteState )
		{	
			//_global.debug( "FrusionClient:Launching game" );
						
			this.finalize();
			this.mc.game._visible = true;
			this.mc.game.play();
		}
	}
	
	
	/*
		Function: finalize
		Do some cleanup before going elsewhere... in the Realm Of The Dead ;)
	*/
	private function finalize() : Void
	{
		/*
		this.loadingBar.finalize();
		delete this.loadingBar;
		*/
		
		this.mc.anim_init.removeMovieClip("");
		delete this.frusionAnim;
	}

	
}