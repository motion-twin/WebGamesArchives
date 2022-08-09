import haxe.Utf8;

import mt.gx.Pair;
import HashEx;
import IntHashEx;

using Lambda;

enum TagElem
{
	Txt(str:String);
	Tg(tag:Tag);
}

class Tag
{
	var name : String;
	var children : List<TagElem>;
	var att : Array< Pair<String,String>>;
	
	public function new(n)
	{
		name = n;
		children = new List();
		att =  new Array();
	}
	
	public function css(n:String,v:String) {
		att.push( new Pair('style', ''+n+':'+v+';') );
	}
	
	public function attr( n, c )
	{
		att.push( new Pair(n, c) );
		return this;
	}
	
	public function clone() : Tag
	{
		var cl = new Tag(name);
		cl.children = children.map(
		function( e )
		{
			switch(e )
			{
				case Txt(s): return Txt( s);
				case Tg ( t ): return Tg(t.clone());
			}
		});
		cl.att = att.fold(function(p, r : Array<Pair<String,String>>)
		{
			r.push( new Pair( p.first, p.second ));
			return r;
		},[]);
		return cl;
	}
	
	public function content( str:  String )
	{
		children.add( Txt(str)); return this;
	}
	
	public function append( tg:  Tag )
	{
		children.add( Tg(tg) ); return this;
	}
	
	public function format(c : Dynamic)
	{
		name = StdEx.format( name , c );
		children = children.map(
		function( e )
		{
			switch(e )
			{
				case Txt(s): return Txt( StdEx.format(s, c ));
				case Tg ( t ):
				{
					t.format( c );
					return Tg(t);
				}
			}
		});
		
		for(p in att)
		{
			p.second = StdEx.format(p.second);
		}
	}
	
	public function toString()
	{
		var listAttr = function()
		{
			var s = " ";
			for(p in att)
			{
				s += " " + p.first +' ="' + p.second + '" ';
			}
			return s;
		};
		
		var s = "<" + name +" "+ listAttr() + (children.length>0 ? ">" : "/>");
		
		for( c in  children )
		{
			switch(c)
			{
				case Tg(tg):s += tg.toString();
				case Txt(t):s += t;
			}
		}
		
		if ( children.length > 0)
		{
			s += "</" + name + ">";
		}
		
		return s;
	}
	
	public static var escapeHash : Hash<String>
	=
	{
		var h = new Hash();
		h.set("'", "&quot;");
		h.set("é", "&eacute;");
		h.set("\r", "");
		h.set("\n", "");
		h;
	}
	
	public function htmlEscapeEx( s : String  )
	{
		Debug.NOT_NULL(s);
		var l = s;
		for (k in escapeHash.keys())
		{
			l = l.split(k).join(escapeHash.get(k));
		}
		return StringTools.htmlEscape( l );
	}
	
	public static var hash2Attr : Hash<String>
	=
	{
		var h = new Hash();
		h.set("é", "&eacute;");
		h.set("à", "&agrave;");
		h.set("'", "\'");
		h.set("\r", "");
		h.set("\n", "");
		h;
	}
	
	public static function attr2Html( s : String  )
	{
		var l = s;
		for (k in hash2Attr.keys())
			l = l.split(k).join(hash2Attr.get(k));
		return l;
	}
	
	#if neko
	public function tip( title : String, body : String="" )
	{
		Debug.NOT_NULL(title);
		Debug.NOT_NULL(body);
		//Debug.MSG(body);
		
		this.attr( "onmouseover",
		"Main.showTip(this,"+
			"'<div class=\\\'tiptop\\\' >"+
				"<div class=\\\'tipbottom\\\'>"+
					"<div class=\\\'tipbg\\\'>" +
						"<div class=\\\'tipcontent\\\'>" +
							"<h1>" + htmlEscapeEx(title) + "</h1>" + htmlEscapeEx(body) +
						"</div>"+
					"</div>"+
				"</div>"+
			"</div>')"
		);
		this.attr( "onmouseout" , "Main.hideTip()");
		
		return this;
	}
	#else
	public function tip( title : String, body : String="" )
	{
		Debug.NOT_NULL(title);
		Debug.NOT_NULL(body);
		//Debug.MSG(body);
		
		this.attr( "onmouseover",
		"Main.showTip(this,"+
			"'<div class=\\\'tiptop\\\' >"+
				"<div class=\\\'tipbottom\\\'>"+
					"<div class=\\\'tipbg\\\'>" +
						"<div class=\\\'tipcontent\\\'>" +
							"<h1>" + attr2Html(title) + "</h1>" + attr2Html(body) +
						"</div>"+
					"</div>"+
				"</div>"+
			"</div>')"
		);
		this.attr( "onmouseout" , "Main.hideTip()");
		
		return this;
	}
	#end
}