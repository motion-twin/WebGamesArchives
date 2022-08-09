package data;
import GameData._ArtefactId ;


class RecipeXML extends haxe.xml.Proxy<"recipes.xml",Recipe> {

	
	public static function parse() : data.RecipeContainer {
		return new data.RecipeContainer(true).parseRecipes("recipes.xml",function(id,iid,p) {
			var r = new Recipe() ;
			r.id = id ;
			r.mid = iid ;
			r.name = p.att.name ;
			r.school = if (p.has.school) Data.schoolIndex(p.att.school) else Data.GU ;
			r.scOnly = r.school != Data.GU ;
			r.category = Data.CATEGORIES.getName(p.att.category) ;
			r.specialist = if (p.has.specialist) (Std.parseInt(p.att.specialist) == 1) else false ;
			r.flash = if (p.has.flash) (Std.parseInt(p.att.flash) == 1) else false ;
			r.forbidden = if (p.has.forbidden) (Std.parseInt(p.att.forbidden) == 1) else false ;
			r.desc = Data.TEXTDESC.format(StringTools.trim(p.node.desc.innerData)) ;
			r.flavor = if (p.hasNode.flavor) Data.TEXTDESC.format(StringTools.trim(p.node.flavor.innerData)) else "" ;
			r.icon = if (p.has.icon) StringTools.trim(p.att.icon) else null ;
			r.questOnly = if (p.has.quest) Std.parseInt(p.att.quest) == 1 else false ;
			
			
			for (d in p.nodes.disp) {
				r.setDisp(d) ;
			}
			
			r.setNeeds(p.node.needs.innerData) ;
			r.setResult(p.node.result.innerData) ;
			
			return r ;
		}) ;
	}

}


