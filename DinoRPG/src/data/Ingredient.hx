package data;

typedef Ingredient = {
	var id : String;
	var iid : Int;
	var name : String;
	var desc : String;
	var max : Int;
	var gather : Gather;
	var price : Int;
}

class IngredientXML extends haxe.xml.Proxy<"ingredients.xml",Ingredient> {

	public static function parse() {
		return new data.Container<Ingredient,IngredientXML>().parse("ingredients.xml",function(id,iid,i) {
			var max = switch( i.att.rarity ) {
				case "S": Std.parseInt(i.att.max);
				case "C": 50;
				case "U": 20;
				case "R": 5;
				default: throw "Unknown rarity "+i.att.rarity;
			};
			return {
				id : id,
				iid : iid,
				name : i.att.name,
				max : max,
				desc : i.innerData,
				price : Std.parseInt(i.att.price),
				gather : null,
			}
		});
	}

}
