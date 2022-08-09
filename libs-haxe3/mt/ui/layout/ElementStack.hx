package mt.ui.layout;

import mt.ui.layout.Element;
using mt.Std;

class ElementStack extends Element implements IElementContainer
{	
	@:signal public var onChange:Element->Element->Void;
	
	public var currentElement(default, null):Element;
	public var selectedIndex(get, set):Int;
	public var numElements(get, null):Int;
	inline function get_numElements():Int
	{
		return mElements.length;
	}

	public var hChildrenLayout:HLayoutKind;
	public var vChildrenLayout:VLayoutKind;
	
	var mElements:Array<Element>;
	var mLastWidth:Float;
	var mLastHeight:Float;
	var mLastForcedWidth:Null<Float>;
	var mLastForcedHeight:Null<Float>;
	var mReady:Bool;
	@:allow(mt.ui.layout) var index:Int;
	
	public function new()
	{
		super("0", "0");
		mElements = new Array();
		mReady = false;
		index = 0;
		mLastWidth = mLastHeight = 0.0;
		mLastForcedHeight = mLastForcedWidth = null;
	}
	
	public function refresh(?p_silent:Bool)
	{
		if( currentElement != null )
			currentElement.resize(mLastWidth, mLastHeight, mLastForcedWidth, mLastForcedHeight, p_silent);
	}
	
	inline function get_selectedIndex()
	{
		return index;
	}
	
	//TODO invalidate parent layout !!  Find a way to do that
	function set_selectedIndex(p_index:Int):Int
	{
		p_index = mt.MLib.wrap(p_index, 0, mElements.length - 1);
		//
		if( mReady && selectedIndex == p_index ) return p_index;
		//
		var oldElement = currentElement;
		index = p_index;
		currentElement = mElements.get(p_index);
		
		this.hLayout = currentElement.hLayout;
		this.vLayout = currentElement.vLayout;
		this.aspect = currentElement.aspect;
		this.config = currentElement.config;
		
		this.contentHeight = currentElement.contentHeight;
		this.contentWidth = currentElement.contentWidth;
		this.contentX = currentElement.contentX;
		this.contentY = currentElement.contentY;
		this.bounds = currentElement.bounds;	
		mReady = true;
		//
		onChange.dispatch( oldElement, currentElement );
		return selectedIndex;
	}
	
	override public function getElementByName( pName:String ):Null<Element>
	{
		var el = super.getElementByName(pName);
		if( el == null ) 
		{
			el = currentElement.getElementByName(pName);
		}
		return el;
	}
	
	public function getElementAt(p_index):Null<Element>
	{
		return mElements[p_index];
	}
	
	public function getElementIndex(p_element:Element):Int
	{
		return mElements.indexOf(p_element);
	}
	
	public function removeAll()
	{
		while( mElements.size() > 0 )
		{
			var e = mElements.removeLast();
			e.clean();
			if( Std.is(e, IElementContainer) ) cast( e, IElementContainer ).removeAll();
		}
	}
	
	override public function clean()
	{
		for( e in mElements )
			e.clean();
		onChange.dispose();
		super.clean();
	}
	
	override public function notify()
	{
		if( currentElement != null ) currentElement.notify();
		super.notify();
	}
	
	public function getElements()
	{
		return mElements.copy();
	}
	
	override public function resize( pWidth:Float, pHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float>, ?p_silent:Bool=false )
	{
		if ( disabled ) return;
		mLastWidth 	= pWidth; 
		mLastHeight = pHeight;
		mLastForcedHeight 	= pForceHeight;
		mLastForcedWidth 	= pForceWidth;
		//
		if( currentElement != null )
		{
			currentElement.resize( pWidth, pHeight, pForceWidth, pForceHeight, p_silent );
		}
	}
	
	public function setActive( p_element:Element ):Void
	{
		selectedIndex = mElements.indexOf(p_element);
	}
	
	public function removeElement(child:Element,  ?p_silent:Bool):Bool
	{
		if( mElements.remove(child) )
		{
			refresh(p_silent);
			return true;
		} else {
			return false;
		}
	}
	
	public function addElement (child:Element, ?p_silent:Bool) : Element 
	{
		return addElementAt(child, mElements.size(), p_silent);
	}
	
	public function addElementAt (child:Element, p_index:Int, ?p_silent:Bool) : Element
	{
		mElements[p_index] = child;
		child.parent = this;
		if( !mReady && selectedIndex == (mElements.size() - 1) )
			selectedIndex = selectedIndex;
		if( !child.disabled )
			refresh(p_silent);
		return child;
	}
	
	override public function clone():Element
	{
		var e = new ElementStack();
		e.name = this.name;
		e.parent = this.parent;
		e.config = { paddingLeft:config.paddingLeft, paddingRight:config.paddingRight, paddingTop:config.paddingTop, paddingBottom:config.paddingBottom, width:config.width, height:config.height };
		e.vLayout = this.vLayout;
		e.hLayout = this.hLayout;
		e.aspect = this.aspect;
		e.disabled = this.disabled;
		e.numElements = this.numElements;
		e.mElements = Lambda.array(Lambda.map(mElements, function(elt) {
			var c = elt.clone();
			c.parent = e;
			return c;
		} ));
		
		e.selectedIndex = this.selectedIndex;
		return e;
	}
}
