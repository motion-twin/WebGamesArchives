package data;

typedef Action = {
	var id : String;
	var text : String;
	var icon : String;
	var desc : String;
	var confirm : Bool;
	var hidden : Bool;
	var active : Bool;
	var dynDesc : Void -> String;
	var dynLabel : Void -> String;
	var ajax : Bool;
	var ajaxAreas : Null<Array<String>>;
	//var needAction : Bool;
}

using Lambda;
class ActionXML extends haxe.xml.Proxy<"actions.xml",Action> {

	public static function parse() {
		return new data.Container<Action,ActionXML>(false,true).parse("actions.xml",function(id,_,a) {
			return {
				id : id,
				text : a.att.text,
				icon : if( a.has.icon ) a.att.icon else "default",
				desc : Tools.format(a.innerData),
				confirm : a.has.confirm,
				hidden : a.has.hidden,
				active : if( a.has.active ) Data.isActive(a.att.active) else true,
				ajax : if( a.has.ajax ) a.att.ajax == "true" else false,
				ajaxAreas : if( a.has.ajaxAreas ) a.att.ajaxAreas.split(",").map( function(s) return "'"+s+"'" ).array() else null,
				//needAction : if(  a.has.needAction ) a.att.needAction == "true" else false,
				dynDesc : null,
				dynLabel : null,
			};
		});
	}
}