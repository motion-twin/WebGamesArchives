package mt.ui.layout;

import mt.ui.layout.Element;
import mt.Metrics;
using mt.Std;

/**
* Children of this box are aligned relative to box bounds
*/
class BoxLayout extends Element implements IElementContainer
{	
    //Should we arrange children vertically (true) or horizontally (false). True by default.
    public var vertical : Bool = true;
	//Distance between children
	// "wide"  "auto"  "%"  "px"  "dp" are valid values
    public var childPadding : String;
    //if this is set to true, all children will be set to equal size to fit box size
    public var autoSize : Bool = false;
	
	//valeur du padding en Flotant, READ-ONLY
	public var childPaddingPx(default, null):Float;
	public var hChildrenLayout:HLayoutKind;
	public var vChildrenLayout:VLayoutKind;
	
	public var numElements(get, null):Int;
	inline function get_numElements():Int
	{
		return mElements.length;
	}
	
	var mElements:Array<Element>;
	
	public function new(pWidth:String, pHeight:String, ?pHorizontalLayout:HLayoutKind=null, ?pVerticalLayout:VLayoutKind=null, ?pAspect:AspectKind=null)
	{
		super(pWidth, pHeight, pHorizontalLayout, pVerticalLayout, pAspect);
		hChildrenLayout = HLayoutKind.LEFT;
		vChildrenLayout = VLayoutKind.TOP;
		mElements = new Array();
		childPadding = "0";
	}
	
	override public function clone():Element
	{
		var e = new BoxLayout("1", "1");
		e.name = this.name;
		e.parent = this.parent;
		e.config = { paddingLeft:config.paddingLeft, paddingRight:config.paddingRight, paddingTop:config.paddingTop, paddingBottom:config.paddingBottom, width:config.width, height:config.height };
		e.vLayout = this.vLayout;
		e.hLayout = this.hLayout;
		e.aspect = this.aspect;
		e.disabled = this.disabled;
		e.vertical = this.vertical;
		e.childPadding = this.childPadding;
		e.autoSize = this.autoSize;
		e.hChildrenLayout = this.hChildrenLayout;
		e.vChildrenLayout = this.vChildrenLayout;
		e.numElements = this.numElements;
		e.mElements = Lambda.array(Lambda.map(mElements, function(elt) {
			var c = elt.clone();
			c.parent = e;
			return c;
		} ));
		return e;
	}
	
	public function getElementAt(p_index):Null<Element>
	{
		return mElements[p_index];
	}
	
	public function getElementIndex(p_element:Element):Int
	{
		return mElements.indexOf(p_element);
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
	
	public function removeElementAt(childIndex:Int, ?p_silent:Bool):Bool
	{
		var child = getElementAt(childIndex);
		if( mElements.remove(child) )
		{
			if( !child.disabled )
				refresh(p_silent);
			return true;
		} else {
			return false;
		}
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
	
	public function getElements()
	{
		return mElements.copy();
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
			if( !e.disabled )
				e.notify();
	}
	
	override public function resize( pWidth:Float, pHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float>, ?p_silent:Bool=false )
	{
		if ( disabled ) return;
		updateSize( pWidth, pHeight, pForceWidth, pForceHeight );
		updatePosition( pWidth, pHeight );
		//
		refresh(p_silent);
		//
		if( !p_silent )
		{
			notify();
		}
	}
	
	public function refresh(?p_silent:Bool=false) : Void 
	{
		this.resizeElements();
		this.alignElements();
		if( !p_silent )
			notify();
	}
	
	function resizeElements()
	{
		if( this.autoSize )
		{
			this._autoSize();
		}
		else
		{
			var totalParts = 0., usedSpace = 0., postProcess = new List();
			for( e in mElements )
			{
				if( e.disabled ) continue;
				if( vertical && px(e.config.height) >= 0 || !vertical && px(e.config.width) >= 0 )
				{
					e.resize( contentWidth, contentHeight, true );
					if( vertical ) 	usedSpace += e.bounds.height;
					else 			usedSpace += e.bounds.width;
				}
				else
				{
					postProcess.add(e);
					if( vertical ) totalParts -= px(e.config.height);
					else 		   totalParts -= px(e.config.width);
				}
			}
			
			var freeSpace = vertical ? contentHeight - usedSpace : contentWidth - usedSpace;
			for( e in postProcess )
			{
				if( vertical )	e.resize( contentWidth, contentHeight, null, -px(e.config.height)/totalParts * freeSpace, true );
				else 			e.resize( contentWidth, contentHeight, -px(e.config.width)/totalParts * freeSpace, null, true );
			}
		}
		
		// compute padding
		if ( childPadding == "auto" || childPadding == "wide" )
		{
			var freeSpace = vertical ? contentHeight : contentWidth;
			var count = 0;
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( !vertical && e.hLayout != INHERITED ) continue;
				if ( vertical && e.vLayout != INHERITED ) continue;
				freeSpace -= vertical ? e.bounds.height : e.bounds.width;
				count ++;
			}
			if( childPadding == "wide" )
				childPaddingPx = freeSpace / (count - 1);
			else
				childPaddingPx = freeSpace / (count + 1);
		}
		else if ( vertical )
		{
			childPaddingPx = px(childPadding, contentHeight);
		}
		else
		{
			childPaddingPx = px(childPadding, contentWidth);
		}
	}
	
	function alignElements () : Void 
	{
		switch( hChildrenLayout )
		{
			case LEFT : this._hAlignLeft();
			case RIGHT : this._hAlignRight();
			case CENTER : this._hAlignCenter();
			case INHERITED :
		}
		
		switch( vChildrenLayout )
		{
			case TOP : this._vAlignTop();
			case BOTTOM : this._vAlignBottom();
			case MIDDLE : this._vAlignCenter();
			case INHERITED :
		}
	}

	function _autoSize () : Void 
	{
		var visibleElements = 0;
		for( e in mElements )
			if ( !e.disabled ) 
				visibleElements ++;
		
		if ( this.vertical )
		{
			childPaddingPx = 0;
			if ( childPadding != "auto" && childPadding != "wide" ) 	
				childPaddingPx = px(childPadding, this.contentHeight);
			
			var childWidth  = this.contentWidth;
			var childHeight = (this.contentHeight - childPaddingPx * (visibleElements - 1)) / visibleElements;
			for( e in mElements )
			{
				if( e.disabled ) continue;
				e.resize(contentWidth, contentHeight, childWidth, childHeight, true);
			}
		}
		else
		{
			childPaddingPx = 0;
			if ( childPadding != "auto" && childPadding != "wide" ) 	
				childPaddingPx = px(childPadding, this.contentWidth);
			//
			var childWidth  = (this.contentWidth - childPaddingPx * (visibleElements - 1)) / visibleElements;
			var childHeight = this.contentHeight;
			for( e in mElements )
			{
				if( e.disabled ) continue;
				e.resize(contentWidth, contentHeight, childWidth, childHeight, true);
			}
		}
	}
	
	function _vAlignTop () : Void 
	{
		var base = 0.0;// this.paddingTop;
		if( this.vertical )
		{
			var lastY = base;
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.vLayout != INHERITED ) continue;
				_setObjY(e, lastY);
				lastY += e.bounds.height + childPaddingPx;
			}
		}
		else
		{
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.vLayout != INHERITED ) continue;
				_setObjY(e, base);
			}
		}
	}
	
	function _vAlignCenter () : Void 
	{
		//vertical box
		if( this.vertical )
		{
			//count sum children height
			var nb = 0, h = 0.;
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.vLayout != INHERITED ) continue;
				h += e.bounds.height;
				nb ++;
			}
			//childPaddingPx = px(childPadding, this.contentHeight);
			//add padding
			h += (nb - 1) * childPaddingPx;
			//arrange elements
			var lastY = (this.contentHeight - h) / 2 + this.contentY;
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.vLayout != INHERITED ) continue;
				_setObjY(e, lastY);
				lastY += e.bounds.height + childPaddingPx;
			}
		}
		else
		{
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.vLayout != INHERITED ) continue;
				_setObjY(e, (this.contentHeight - e.bounds.height) / 2);
			}
		}
	}

	function _vAlignBottom() : Void 
	{
		var lastY = bounds.height - paddingBottom;
		if( this.vertical )
		{
			//childPaddingPx = px(childPadding, contentHeight);
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.vLayout != INHERITED ) continue;
				_setObjY(e, lastY - e.bounds.height);
				lastY = e.contentY - childPaddingPx;
			}
		}
		else
		{
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.vLayout != INHERITED ) continue;
				_setObjY(e, lastY - e.bounds.height);
			}
		}
	}
	
	function _hAlignLeft() : Void 
	{
		var base = 0.0;// this.paddingLeft;
		//vertical box
		if( this.vertical )
		{
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.hLayout != INHERITED ) continue;
				_setObjX(e, base);
			}
		}
		else
		{
			var lastX  = base;
			//childPaddingPx = px(childPadding, contentWidth);
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.hLayout != INHERITED ) continue;
				_setObjX(e, lastX);
				lastX += e.bounds.width + childPaddingPx;
			}
		}
	}

	function _hAlignRight() : Void
	{
		var base = this.bounds.width - this.paddingRight;
		//vertical box
		if( this.vertical )
		{	
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.hLayout != INHERITED ) continue;
				_setObjX(e, base - e.bounds.width);
			}
		}
		else
		{
			//childPaddingPx = px(childPadding, this.contentWidth);
			var lastX = base;
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.hLayout != INHERITED ) continue;
				_setObjX(e, lastX - e.bounds.width);
				lastX = e.contentX - childPaddingPx;
			}
		}
	}

	function _hAlignCenter() : Void 
	{
		//vertical box
		if(this.vertical)
		{
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.hLayout != INHERITED ) continue;
				_setObjX(e, 0 + (this.contentWidth - e.bounds.width) / 2);
			}
		}
		else
		{
			//sum children width
			var nb = 0, w = 0.;
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.hLayout != INHERITED ) continue;
				w += e.bounds.width;
				nb++;
			}
			//childPaddingPx = px(childPadding, this.contentWidth);
			//add padding
			w += (nb-1) * childPaddingPx;
			//arrange elements
			var lastX = .5 * (this.contentWidth - w);
			if ( childPadding == "auto" )
			{
				lastX = childPaddingPx;
			}
			for( e in mElements )
			{
				if ( e.disabled ) continue;
				if ( e.hLayout != INHERITED ) continue;
				_setObjX(e, lastX);
				lastX += e.bounds.width + childPaddingPx;
			}
		}
	}
	
	inline function _setObjX (e:Element, p_x:Float) : Void 
	{
		e.contentX = p_x + e.paddingLeft;
	}
	
	inline function _setObjY (e:Element, p_y:Float) : Void 
	{
		e.contentY = p_y + e.paddingTop;
	}
}