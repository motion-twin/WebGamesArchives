package mt.ui.layout;

import mt.ui.layout.Element;
import mt.Compat;

using mt.Std;
class UIBuilder
{
	public static function build( pXml:Xml ):Element
	{		
		var root = parse( pXml.firstElement() );
		return root;
	}
	
	inline static function getVAlign(att:String) {
		return switch( att ) {
			case "middle": VLayoutKind.MIDDLE;
			case "top": VLayoutKind.TOP;
			case "bottom": VLayoutKind.BOTTOM;
			default :  null;
		}
	}
	
	inline static function getHAlign(att:String) {
		return switch( att ) {
			case "left": HLayoutKind.LEFT;
			case "right": HLayoutKind.RIGHT;
			case "center": HLayoutKind.CENTER;
			default : null;
		}
	}
	
	inline static function parseAlign(attr:String) {
		var aligns = attr.split(",").map( function(s) return StringTools.trim(s).toLowerCase() );
		if ( aligns.length > 2 ) throw "Layout element should have align property set with following format : (horizontal),(vertical)";
		var r = { h:HLayoutKind.INHERITED, v:VLayoutKind.INHERITED };
		
		for ( align in aligns )
		{
			var h = getHAlign(align);
			if ( h == null )
			{
				var v = getVAlign(align);
				if ( v == null ) throw "Invalid align attribute :" + align + "  valid values are (top, bottom, middle) (right, left, center)";
				r.v = v;
			}
			else
			{
				r.h = h;
			}
		}
		return r;
	}
	
	static function parse( pNode:Xml )
	{
		var elements = pNode.elements();
		var parent = parseNode(pNode);
		if ( !Std.is( parent, IElementContainer) && elements.hasNext() )
		{
			throw "node Element cannot have some children";
		}
		else if ( Std.is( parent, IElementContainer) )
		{
			var parent = cast( parent, IElementContainer);
			for ( e in pNode.elements() )
			{
				if ( e.nodeType != Xml.Element ) continue;
				var element = parse( e );
				parent.addElement(element);
			}
		}
		return parent;
	}
	
	
	static function parseNode( pXmlNode:Xml ):Element
	{
		var readAttr = [];
		inline function hasAtt(att:String):Bool 
		{
			return pXmlNode.exists(att);
		}
		
		inline function getAtt(att:String):Null<String>
		{
			if ( !pXmlNode.exists(att) ) throw "Current node doesn't have the attribute " + att + " defined";
			readAttr.push(att);
			return pXmlNode.get(att);
		}
		
		var id = getAtt('id');		
		var hAlign = HLayoutKind.INHERITED;
		var vAlign = VLayoutKind.INHERITED;
		if ( hasAtt("align") )
		{
			var r = parseAlign(getAtt("align"));
			hAlign = r.h;
			vAlign = r.v;
		}
		
		var aspect = AspectKind.MATCH_PARENT; 
		if ( hasAtt('aspect') )
		{
			var ratio = if ( hasAtt('aspectRatio') ) Std.parseFloat(getAtt('aspectRatio')) else 1.0;
			aspect = switch( getAtt('aspect') )
			{
				case "keep_in": AspectKind.KEEP_IN(ratio);
				case "keep_out": AspectKind.KEEP_OUT(ratio);
				case "stretch": AspectKind.MATCH_PARENT;
				case "fixed": AspectKind.FIXED;
				default: throw "unknown aspect for node " + getAtt('id');
			}
		}
		
		var noAttributes = false;
		var e = switch( pXmlNode.nodeName.toLowerCase() )
		{
			case "hbox", "vbox": 
				var w = hasAtt('width') ? getAtt('width') : '100%';
				var h = hasAtt('height') ? getAtt('height') : '100%';
				var b = new mt.ui.layout.BoxLayout(w, h, hAlign, vAlign, aspect ); 
				b.name = id;
				b.vertical = pXmlNode.nodeName == "vbox"; 
				b.autoSize = hasAtt("autoSize") && getAtt("autoSize").toLowerCase() == "true";
				
				if ( hasAtt("childAlign") )
				{
					var r = parseAlign(getAtt("childAlign"));
					b.hChildrenLayout = r.h;
					b.vChildrenLayout = r.v;
				}
				
				
				if( hasAtt('childPadding') )
					b.childPadding = getAtt('childPadding');
				b;
				
			case "canvas":
				var w = hasAtt('width') ? getAtt('width') : '100%';
				var h = hasAtt('height') ? getAtt('height') : '100%';
				var c = new mt.ui.layout.CanvasLayout(w, h, hAlign, vAlign, aspect ); 
				c.name = id;
				c;
			
			case "element":
				var w = hasAtt('width') ? getAtt('width') : '100%';
				var h = hasAtt('height') ? getAtt('height') : '100%';
				var e = new Element(w, h, hAlign, vAlign, aspect);
				e.name = id;
				e;
			
			case "stack":
				noAttributes = true;
				var e = new ElementStack();
				e.name = id;
				if( hasAtt("selectedIndex") )
					e.index = Std.parseInt(getAtt("selectedIndex"));
				e;
				
			default : throw pXmlNode.nodeName + " is not a valid layout element";
		}
		
		//CONFIG attributes
		if( noAttributes == false )
		{
			if( hasAtt('minHeight') ) e.config.minHeight = getAtt('minHeight');
			if( hasAtt('minWidth') ) e.config.minWidth = getAtt('minWidth');
			if( hasAtt('maxHeight') ) e.config.maxHeight = getAtt('maxHeight');
			if( hasAtt('maxWidth') ) e.config.maxWidth = getAtt('maxWidth');
			if( hasAtt('paddingLeft') ) e.config.paddingLeft = getAtt('paddingLeft');
			if( hasAtt('paddingRight') ) e.config.paddingRight = getAtt('paddingRight');
			if( hasAtt('paddingTop') ) e.config.paddingTop = getAtt('paddingTop');
			if( hasAtt('paddingBottom') ) e.config.paddingBottom = getAtt('paddingBottom');
			if( hasAtt('disabled') ) e.disabled = getAtt('disabled').toLowerCase() == "true";
		}
		
		//check if node does not define unvalid attributes, since it may represent a typo mistake
		for ( att in pXmlNode.attributes() )
		{
			//attribute starting with un underscore are considered as commented attributes, so no check is applied
			if ( StringTools.startsWith(att, '_') ) continue;
			if ( Lambda.indexOf(readAttr,att) == -1 )
			{
				throw "Attribute " + att + " is not used or invalid on the node " + id;
			}
		}
		
		return e;
	}
}
