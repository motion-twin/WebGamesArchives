package data;

enum ClanActionGift{
	GGiveObj( o : Object, qty : Int );
	GGiveIngr( i : Ingredient, qty : Int );
	GGAction( name : String );
}

typedef ClanAction = {
	var id : String;
	var aid : Int;
	var place : Null<Map>;
	var act : Action;
	var cond : Condition;
	var message : String;
	var finish : String;
	var need : Int;
	var give : ClanActionGift;
}

class ClanActionXML extends haxe.xml.Proxy<"clanactions.xml",ClanAction> {

	public static function parse() {
		return new data.Container<ClanAction,ClanActionXML>(false,false).parse("clanactions.xml",function(id,aid,a) {
		
			var act : Action = {
				id : id,
				text : a.att.label,
				icon : if( a.has.icon ) a.att.icon else "default",
				desc :  Tools.format(a.node.desc.innerHTML),
				confirm : a.has.confirm,
				hidden : a.has.hidden,
				active :  if( a.has.active ) Data.isActive(a.att.active) else true,
				dynDesc : null,
				dynLabel : null,
				ajax : false,
				ajaxAreas : null,
			};
		
			var clact : ClanAction = {
				id : id,
				aid : aid,
				place : Data.MAP.getName(a.att.place),
				message : Tools.format(a.node.message.innerData),
				finish : Tools.format(a.node.finish.innerData),
				act : act,
				cond : if( a.has.cond ) Script.parse(a.att.cond) else Condition.CTrue,
				need : Std.parseInt(a.att.need),
				give : parseGive( a.att.give ),
			};
			
			act.dynDesc = function(){
				var dbact = db.ClanAction.get(clact, false);
				var g;
				switch(clact.give){
					case GGAction(n):
						g = "1 "+n;
					case GGiveObj(o, qty):
						g = qty+" "+o.name;
					case GGiveIngr(i, qty):
						g = qty+" "+i.name;
				}
				var progress = 0;
				if( dbact != null )
					progress = dbact.progress;
				return Text.format( act.desc, {count:progress, total:clact.need, give:g } );
			}
			
			act.dynLabel = function(){
				var dbact = db.ClanAction.get(clact, false);
				var progress = 0;
				if( dbact != null )
					progress = dbact.progress;
					
				return Text.format( act.text, {progress:Std.int( progress/clact.need * 100 )} );
			}
			
			Data.ACTIONS.add(id,act);
			return clact;
		});
	}

	static function parseGive( n:String )
	{
		var d = n.split(",");
		if( d != null )
			d.remove("");
		for( elt in d ){
			var d = elt.split(":");
			var o = d[0];
			var q = Std.parseInt(d[1]);
			var gift = null;
			if( Data.OBJECTS.existsName( o ) ){
				gift = GGiveObj(Data.OBJECTS.getName( o ), q);
			}
			else if( Data.INGREDIENTS.existsName( o ) ){
				gift = GGiveIngr(Data.INGREDIENTS.getName( o ), q);
			}
			else{
				gift = GGAction( o );
			}
			return gift;
		}
		throw Text.get.clan_action_give_nocompatible;
	}

}