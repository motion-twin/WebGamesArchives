/*
$Id: CBeeLocal.as,v 1.1 2003/10/25 14:43:14  Exp $

Class: CBeeLocal
*/
intrinsic dynamic class CBeeLocal{

	
	function CBeeLocal(obj);

	function init();
	
	function onConnect(success);
	function onClose();
	function onXML(node);
	function onStatus(obj);
	function onIdent(node);


	function check();
	function send(s);
	function cmd(a,b,c);

	/*
	Function: addListener
		Add a listener for a specific command

	Parameters:
		cmd - Coder's friendly command name
		obj - Object in which call the method
		method - Name of the method to call
		attrib - Required attribute name
		value - Required attribute value

	See Also:
		<CBee.removeListenerCmd>
		<CBee.removeListenerCmdObj>
	*/
	function addListener(cmd,obj,method,attrib,value);

	/*
	Function: removeListenerCmd
		Remove all listeners for a specific command (attrib/value)

	Parameters:
		cmd - Coder's friendly command name
		attrib - Required attribute name
		value - Required attribute value

	See Also:
		<CBee.addListener>
		<CBee.removeListenerCmdObj>
	*/
	function removeListenerCmd(cmd,attrib,value);

	/*
	Function: removeListenerCmdObj
		Remove listeners for a specific command (attrib/value), which call a specific object

	Parameters:
		cmd - Coder's friendly command name
		obj - Object in which the method was called
		attrib - Required attribute name
		value - Required attribute value

	See Also:
		<CBee.addListener>
		<CBee.removeListenerCmd>
	*/
	function removeListenerCmdObj(cmd,obj,attrib,value);
	function callListenersArray(arr,node);
}