package mt.data;

using Lambda;

enum TagElem{
	Txt(str:String);
	Tg(tag:Tag);
}

class Pair<S,T>{
	public var first:S;
	public var second:T;
	
	public function new(s,t){
		first=s;
		second =t;
	}
}

class Tag {
	
	var name : String;
	var children : List<TagElem>;
	var att : Array< Pair<String,String>>;
	
	public function new(n){
		name = n;
		children = new List();
		att =  new Array();
	}
	
	public function css(n:String,v:String) {
		att.push( new Pair('style', ''+n+':'+v+';') );
	}
	
	public function attr( n, c ){
		att.push( new Pair(n, c) );
		return this;
	}
	
	public function clone() : Tag{
		var cl = new Tag(name);
		cl.children = children.map(
		function( e ){
			switch(e ){
				case Txt(s): return Txt( s);
				case Tg ( t ): return Tg(t.clone());
			}
		});
		cl.att = att.fold(function(p, r : Array<Pair<String,String>>){
			r.push( new Pair( p.first, p.second ));
			return r;
		},[]);
		return cl;
	}
	
	public function content( str:  String ){
		children.add( Txt(str)); return this;
	}
	
	public function append( tg:  Tag ){
		children.add( Tg(tg) ); return this;
	}
	
	public function toString(){
		var listAttr = function(){
			var s = " ";
			for(p in att)
				s += " " + p.first +' ="' + p.second + '" ';
			return s;
		};
		
		var s = "<" + name +" "+ listAttr() + (children.length>0 ? ">" : "/>");
		
		for( c in  children )
			switch(c) {
				case Tg(tg):s += tg.toString();
				case Txt(t):s += t;
			}
		
		if ( children.length > 0)
			s += "</" + name + ">";
		
		return s;
	}
	
}