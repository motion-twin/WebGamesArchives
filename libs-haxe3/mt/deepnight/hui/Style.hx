package mt.deepnight.hui;

import h2d.Font;

enum BgOutline {
	None;
	Lighter;
	Darker;
	Col(c:UInt);
}

enum Bg {
	None;
	Col(c:UInt, alpha:Float);
	Texture(t:h2d.Tile);
}

enum VAlign {
	None;
	Top;
	Center;
	Bottom;
}

enum HAlign {
	None;
	Left;
	Center;
	Right;
}

enum CheckType {
	CheckBox;
	Outline(col:Int, alpha:Int);
}

class Style {
	static var FONT_CACHE : Map<String,Font> = new Map();

	var parentStyle							: Null<Style>;
	var linkedComponent(default,set)		: Null<Component>;

	@:isVar public var bg(get,set)				: Null<Bg>;
	@:isVar public var bgOutline(get,set)		: Null<BgOutline>;
	@:isVar public var textColor(get,set)		: Null<Int>;

	@:isVar public var padding(never,set)		: Null<Int>;
	@:isVar public var hpadding(get,set)		: Null<Int>;
	@:isVar public var vpadding(get,set)		: Null<Int>;

	@:isVar public var contentVAlign(get,set)	: Null<VAlign>;
	@:isVar public var contentHAlign(get,set)	: Null<HAlign>;

	@:isVar public var fontName(get,set)		: Null<String>;
	@:isVar public var fontSize(get,set)		: Null<Int>;
	@:isVar public var fontAntiAliasing(get,set): Null<Bool>;
	@:isVar public var fontFiltering(get,set)	: Null<Bool>;
	@:isVar public var lineSpacing(get,set)		: Null<Int>;

	@:isVar public var clickTrap(get,set)		: Null<Bg>;
	@:isVar public var checkType(get,set)		: Null<CheckType>;

	@:isVar public var paddingExpandsBox(get,set): Null<Bool>;


	public function new(?parentStyle:Style, ?c:Component) {
		if( c!=null )
			linkedComponent = c;

		if( parentStyle!=null )
			this.parentStyle = parentStyle;
	}

	public function copyValues(s:Style) {
		var oldParent = s.parentStyle;
		s.parentStyle = null; // disconnect parent inheritance temporarily to reveal null values

		bg = s.bg;
		textColor = s.textColor;
		bgOutline = s.bgOutline;

		hpadding = s.hpadding;
		vpadding = s.vpadding;
		paddingExpandsBox = s.paddingExpandsBox;

		contentHAlign = s.contentHAlign;
		contentVAlign = s.contentVAlign;

		fontName = s.fontName;
		fontSize = s.fontSize;
		fontAntiAliasing = s.fontAntiAliasing;
		fontFiltering = s.fontFiltering;
		lineSpacing = s.lineSpacing;

		clickTrap = s.clickTrap;
		checkType = s.checkType;

		s.parentStyle = oldParent;
		return s;
	}

	inline function getFontCacheId() return fontName+fontSize+fontAntiAliasing;
	public function getFont() {
		var cid = getFontCacheId();

		if( !FONT_CACHE.exists(cid) ) {
			var f = hxd.res.FontBuilder.getFont(fontName, fontSize, { antiAliasing:fontAntiAliasing });
			FONT_CACHE.set(cid, f);
		}

		return FONT_CACHE.get(cid);
	}

	public function setFont(id:String, size:Int, ?antiAlias=true) {
		fontName = id;
		fontSize = size;
		fontAntiAliasing = antiAlias;
	}

	public function setAlign(?h:HAlign, ?v:VAlign) {
		if( h!=null )
			contentHAlign = h;

		if( v!=null )
			contentVAlign = v;
	}

	inline function askRender(structureChanged:Bool) {
		if( linkedComponent!=null )
			linkedComponent.askRender(structureChanged);
	}

	inline function set_linkedComponent(v) {
		linkedComponent = v;
		askRender(true);
		return linkedComponent;
	}

	inline function get_bg() return bg==null && parentStyle!=null ? parentStyle.bg : bg;
	inline function set_bg(v) {
		askRender(false);
		//if( linkedComponent!=null )
			//linkedComponent.initBg();
		return bg = v;
	}

	inline function get_bgOutline() return bgOutline==null && parentStyle!=null ? parentStyle.bgOutline : bgOutline;
	inline function set_bgOutline(v) {
		askRender(false);
		return bgOutline = v;
	}

	inline function get_clickTrap() return clickTrap==null && parentStyle!=null ? parentStyle.clickTrap : clickTrap;
	inline function set_clickTrap(v) {
		askRender(false);
		return clickTrap = v;
	}

	inline function get_fontName() return fontName==null && parentStyle!=null ? parentStyle.fontName : fontName;
	inline function set_fontName(v) {
		askRender(true);
		return fontName = v;
	}

	inline function get_fontSize() return fontSize==null && parentStyle!=null ? parentStyle.fontSize : fontSize;
	inline function set_fontSize(v) {
		askRender(true);
		return fontSize = v;
	}

	inline function get_fontFiltering() return fontFiltering==null && parentStyle!=null ? parentStyle.fontFiltering : fontFiltering;
	inline function set_fontFiltering(v) {
		askRender(true);
		return fontFiltering = v;
	}

	inline function get_lineSpacing() return lineSpacing==null && parentStyle!=null ? parentStyle.lineSpacing : lineSpacing;
	inline function set_lineSpacing(v) {
		askRender(true);
		return lineSpacing = v;
	}

	inline function get_fontAntiAliasing() return fontAntiAliasing==null && parentStyle!=null ? parentStyle.fontAntiAliasing : fontAntiAliasing;
	inline function set_fontAntiAliasing(v) {
		askRender(true);
		return fontAntiAliasing = v;
	}

	inline function get_textColor() return textColor==null && parentStyle!=null ? parentStyle.textColor : textColor;
	inline function set_textColor(v) {
		askRender(false);
		return textColor = v;
	}

	inline function get_vpadding() return vpadding==null && parentStyle!=null ? parentStyle.vpadding : vpadding;
	inline function set_vpadding(v) {
		askRender(true);
		return vpadding = v;
	}

	inline function get_hpadding() return hpadding==null && parentStyle!=null ? parentStyle.hpadding : hpadding;
	inline function set_hpadding(v) {
		askRender(true);
		return hpadding = v;
	}

	inline function set_padding(v) {
		askRender(true);
		return vpadding = hpadding = v;
	}

	inline function get_contentVAlign() return contentVAlign==null && parentStyle!=null ? parentStyle.contentVAlign : contentVAlign;
	inline function set_contentVAlign(v) {
		askRender(true);
		return contentVAlign = v;
	}

	inline function get_contentHAlign() return contentHAlign==null && parentStyle!=null ? parentStyle.contentHAlign : contentHAlign;
	inline function set_contentHAlign(v) {
		askRender(true);
		return contentHAlign = v;
	}

	inline function get_checkType() return checkType==null && parentStyle!=null ? parentStyle.checkType : checkType;
	inline function set_checkType(v) {
		askRender(true);
		return checkType = v;
	}

	inline function get_paddingExpandsBox() return paddingExpandsBox==null && parentStyle!=null ? parentStyle.paddingExpandsBox : paddingExpandsBox;
	inline function set_paddingExpandsBox(v) {
		askRender(true);
		return paddingExpandsBox = v;
	}
}