/*
	$Id: AnimFileLoader.as,v 1.1 2003/11/13 16:04:32  Exp $
*/

/*
	Class: frusion.util.AnimFileLoader
*/
class frusion.util.AnimFileLoader extends FileLoader
{


/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/


	/*
		Function : AnimFileLoader
		Constructor
		
		Parameters: 
			- url : animation file url
			- size: file size in bytes
	*/
	public function AnimFileLoader( url : String, size : Number )
	{
		super( url, size );
	}	
	

	/*
		Function : onLoadComplete
		Callback after file completion. Broadcast a new event to be listened to by client
	*/
	public function onLoadComplete() : Void
	{
		if(this.size == undefined || this.size == this.bytesLoaded)
		{
			this.loaded = true;
			this.broadcastMessage("onAnimLoadComplete");
		}
		else
		{
			this.broadcastMessage("onLoadError");
		}
	}	
	
	
}