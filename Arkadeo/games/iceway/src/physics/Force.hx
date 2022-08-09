/**
 *  Copyright (c) 2011 Martin Lindelof
 *  contact martin.lindelof(at)gmail.com
 *  website www.martinlindelof.com
 *
 *  Copyright (c) 2009 Jeffrey Traer Bernstein (jeff@traer.cc)
 */
package physics;

interface Force
{
	function turnOn():Void;
	function turnOff():Void;
	function isOn():Bool;
	function isOff():Bool;
	function apply():Void;
}
