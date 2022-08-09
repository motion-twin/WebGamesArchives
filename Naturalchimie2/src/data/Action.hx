package data ;

typedef Action = {
	var id : String ;
	var type : String ;
	var text : String ;
	var link : String ;
	var special :String ;
	var icon : String ;
	var tipTitle : String ;
	var desc : String ;
	var confirm : Bool ;
	var hidden : Bool ;
	var questHighlight : Bool ;
}

class ActionXML extends haxe.xml.Proxy<"actions.xml",Action> {

	public static function parse() {
		return new data.Container<Action,ActionXML>(false,true).parse("actions.xml",function(id,_,a) {
			return {
				id : id,
				type : if (a.has.type) a.att.type else id,
				text : a.att.text,
				link : if (a.has.link) a.att.link else "act/" + id,
				special : if (a.has.special) a.att.special else null,
				icon : if( a.has.icon ) a.att.icon else "default",
				tipTitle : null,
				desc : Tools.format(a.innerData),
				confirm : a.has.confirm && Std.parseInt(a.att.confirm) == 1,
				hidden : a.has.hidden,
				questHighlight : false
			} ;
			
		}) ;
	}
	
}