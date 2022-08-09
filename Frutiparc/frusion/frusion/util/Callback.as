/*
	$Id: $
*/


/*
	Class : frusion.util.Callback
*/
class frusion.util.Callback
{


/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/

	
	private var context : Object;
	private var method : String;
	
	
/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/
	
	
	/*
		Function: Callback
		Constructor. Creates a new Callback object.
		
		Parameters:
		- context: Object - pointer to the context from which the function or method must be called
		- method: String - the name of the method to be called
	*/
	public function Callback( context: Object, method: String )
	{
		this.context = context;
		this.method = method;
	}
	
	
	/*
		Function: execute
		Execute callback
	*/
	public function execute( object: Object ) : Void
	{
		this.context[ this.method ]( object );
	}
	
}