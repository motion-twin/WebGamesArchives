package mt.ui.layout;

import mt.ui.layout.Element;

using mt.Std;

/**
* Children of this box are aligned relative to box bounds
*/
class CanvasLayout extends Element implements IElementContainer
{	
	var mElements:Array<Element>;
	public var hChildrenLayout:HLayoutKind;
	public var vChildrenLayout:VLayoutKind;
	public var numElements(get, null):Int;
	inline function get_numElements():Int
	{
		return mElements.length;
	}
	
	public function new(pWidth:String, pHeight:String, ?pHorizontalLayout:HLayoutKind=null, ?pVerticalLayout:VLayoutKind=null, ?pAspect:AspectKind=null)
	{
		super(pWidth, pHeight, pHorizontalLayout, pVerticalLayout, pAspect);
		mElements = new Array();
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
		super.clean();
	}
	
	override public function notify()
	{
		super.notify();
		for ( e in mElements ) 
			if( !e.disabled ) e.notify();
	}
	
	override public function getElementByName( pName:String ):Null<Element>
	{
		var el = super.getElementByName(pName);
		if ( el == null ) 
		{
			for ( e in mElements )
			{
				var t = e.getElementByName(pName);
				if ( t != null )
				{
					el = t; break;
				}
			}
		}
		return el;
	}
	
	override public function clone():Element
	{
		var e = new CanvasLayout("1", "1");
		e.name = this.name;
		e.parent = this.parent;
		e.config = { paddingLeft:config.paddingLeft, paddingRight:config.paddingRight, paddingTop:config.paddingTop, paddingBottom:config.paddingBottom, width:config.width, height:config.height };
		e.vLayout = this.vLayout;
		e.hLayout = this.hLayout;
		e.aspect = this.aspect;
		e.disabled = this.disabled;
		e.hChildrenLayout = this.hChildrenLayout;
		e.vChildrenLayout = this.vChildrenLayout;
		e.mElements = Lambda.array(Lambda.map(mElements, function(elt) {
			var c = elt.clone();
			c.parent = e;
			return c;
		} ));
		return e;
	}
	
	public function getElements()
	{
		return mElements.copy();
	}
	
	
	public function refresh(?p_silent:Bool=false)
	{
		for( e in mElements )
		{
			if( e.disabled ) continue;
			e.resize( contentWidth, contentHeight );
		}
	}
	
	override public function resize( pWidth:Float, pHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float>, ?p_silent:Bool=false)
	{
		if ( disabled ) return;
		super.resize( pWidth, pHeight, pForceWidth, pForceHeight, p_silent );
		refresh(p_silent);
	}
	
	public function addElement (child:Element, ?p_silent:Bool) : Element 
	{
		return addElementAt(child, mElements.size(), p_silent);
	}
	
	public function addElementAt (child:Element, p_index:Int, ?p_silent:Bool) : Element
	{
		mElements[p_index] = child;
		child.parent = this;
		if( !child.disabled )
			refresh(p_silent);
		return child;
	}
	
	public function removeElement(child:Element, ?p_silent:Bool):Bool
	{
		if( mElements.remove(child) )
		{
			if( !child.disabled )
				refresh(p_silent);
			return true;
		} else {
			return false;
		}
	}

}