/*
	$Id: $
*/


import frusion.server.CommandParameter;


/*
	Class: frusion.server.XMLCommand
	Simple class to store a parameter name and its value
*/
class frusion.server.XMLCommand
{

	
/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: XMLCommand
		Constructor
	*/
	public function XMLCommand(){}
	

/*------------------------------------------------------------------------------------
 * Public static methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: buildCommand
		Send an xml command to server
		
		Parameters:
		commandName - String : command name		
		parameters - Array of CommandParameter(s) objects: all the command parameters		
		information - String : information to pass in xml		
	*/	
	public static function buildCommand( commandName: String, parameters: Array, xml : String) : XML
	{
		//_global.debug( "XMLCommand:buildCommand" );
		//_global.debug( "command name=" + commandName );

		// Creating xml with given command
		var x : Object = new XML();
		x.nodeName = commandName;
		
		// Apending parameters
		var l : Number = parameters.length;
		for( var i : Number = 0; i < l; i++)
		{
			var currentParameter : CommandParameter = CommandParameter (parameters[i]);			
			x.attributes[currentParameter.name] = currentParameter.value;
			//_global.debug( "parameter name=" + currentParameter.name );
			//_global.debug( "parameter value=" + currentParameter.value );
		}
		
		//_global.debug( "xml=" + xml );
		// Append already existing xml to our new xml command 
		if(xml != null)
		{
			var xml : XML = new XML(xml);
			x.appendChild(xml);
		}
		
		return XML (x);
	}	

	
}
