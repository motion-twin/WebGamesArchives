package data;

typedef Shop = {
	var id : String;
	var act : data.Action;
	var gfx : Null<String>;
	var objects : List<{ o : Object, price : Int, payWith : Null<data.Object>, payWithIngr : Null<data.Ingredient>, cond : Condition }>;
	var cond : Condition;
}

class ShopXML extends haxe.xml.Proxy<"shops.xml",Shop> {

	public static function parse() {
		return new data.Container<Shop,ShopXML>().parse("shops.xml", function(id,_,s) {
			var objects = new List();
			for( o in s.nodes.item )
				objects.add({
					o : Data.OBJECTS.getName(o.att.i),
					price : Std.parseInt(o.att.v),
					payWith : if( o.has.o ) Data.OBJECTS.getName(o.att.o) else null,
					payWithIngr : if( o.has.ingr ) Data.INGREDIENTS.getName(o.att.ingr) else null,
					cond : if( o.has.cond ) Script.parse(o.att.cond) else Condition.CTrue,
				});
			var act : Action = {
				id : id,
				text : s.att.name,
				icon : "shop",
				desc : s.node.desc.innerHTML,
				confirm : false,
				hidden : s.has.hidden,
				active : true,
				dynDesc : null,
				dynLabel : null,
				ajax : false,
				ajaxAreas : null,
			};
			Data.ACTIONS.add(id, act);
			var shop : Shop = {
				id : id,
				act : act,
				gfx : if( s.has.gfx ) s.att.gfx else null,
				objects : objects,
				cond : if( s.has.cond ) Script.parse(s.att.cond) else Condition.CTrue,
			};
			if( s.has.place )
				Data.MAP.getName(s.att.place).shops.add(shop);
			return shop;
		});
	}

}
