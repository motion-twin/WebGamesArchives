package mt.ui.layout;

import mt.ui.layout.Element;

interface IElementContainer
{
	function addElement (child:Element, ?p_silent:Bool) : Element; 
	
	function addElementAt (child:Element, p_index:Int, ?p_silent:Bool) : Element; 
	
	function getElementByName( pName:String ):Null<Element>;
	
	function getElements():Iterable<Element>;
	
	function getElementIndex(p_element:Element):Int;
	
	function getElementAt(p_index:Int):Null<Element>;
	
	function removeAll():Void;
	
	function removeElement(child:Element, ?p_silent:Bool):Bool;
	
	function refresh(?p_silent:Bool):Void;
	
	function resize( pWidth:Float, pHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float>, ?p_silent:Bool = false ):Void;
	
	function clean():Void;
	
	var numElements(get, null):Int;
	
	var hLayout:HLayoutKind;
	var vLayout:VLayoutKind;
	
	var hChildrenLayout:HLayoutKind;
	var vChildrenLayout:VLayoutKind;
	
	var globalX(get, null):Float;
	var globalY(get, null):Float;
	
	var x(default, null):Float;
	var y(default, null):Float;
	
	var width(default, null):Float;
	var height(default, null):Float;
	var bounds(default, null): Bounds;
}