/*
	$Id: $
*/


/*
	Class: frusion.server.CommandParameter
	Simple class to store a parameter name and its value
*/
class frusion.server.CommandParameter
{


/*------------------------------------------------------------------------------------
 * Public members
 *------------------------------------------------------------------------------------*/


	public var name : String;
	public var value : Object;
	
	
/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: CommandParameter
		Constructor
	*/
	public function CommandParameter( name : String, value : Object )
	{
		this.name = name;
		this.value = value;
	}
	
	
}
