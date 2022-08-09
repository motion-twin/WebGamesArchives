/*
	$Id: GameFileLoader.as,v 1.3 2003/11/17 01:14:28  Exp $
*/

/*
	Class: frusion.util.GameFileLoader
*/
class frusion.util.GameFileLoader extends FileLoader
{


/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/


	/*
		Function : GameFileLoader
		Constructor

		Parameters: 
			- url : animation file url
			- size: file size in bytes
	*/
	public function GameFileLoader( url : String, size : Number )
	{
		super( url, size );
	}
	

	/*
		Function : onLoadComplete
		Callback after file completion. Broadcast a new event to be listened to by client
	*/
	public function onLoadComplete() : Void
	{
		this.broadcastMessage("onGameLoadComplete");
	}	
	
	
	/*
		Function: onLoadStart
		CALLBACK. called when loading starts
	*/
	public function onLoadStart() : Void
	{
		this.broadcastMessage("onGameLoadStart");
	}
	
	
	/*
	 	Function: onLoadProgress
	 	CALLBACK. called during loading progress.
	 */
	public function onLoadProgress( mc,loadedBytes, totalBytes) : Void
	{
		// Update loading percent
		this.percent = Math.round( loadedBytes * 10000 / totalBytes ) / 100;						
		this.broadcastMessage( "onGameLoadProgress" );
	}
	
}