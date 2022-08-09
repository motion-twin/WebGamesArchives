package data ;


	
class KnowledgeXML extends haxe.xml.Proxy<"knowledges.xml",Knowledge> {

	public static function parse() {
		return new data.Container<Knowledge,KnowledgeXML>(true).parse("knowledges.xml",function(id,iid,f) {
			var k =  new Knowledge() ;
			k.id = id ;
			k.place = null ;
			k.name = f.att.name ;
			k.school = if (f.has.school) Data.schoolIndex(f.att.school) else null ;
			k.desc = Data.TEXTDESC.format(Tools.format(f.node.desc.innerData)) ;
			k.points = Std.parseInt(f.att.points) ;
			k.pre = if (f.has.pre) f.att.pre.split(",") else null ;
			k.values = if (!f.hasNode.values) null else Lambda.array(Lambda.map(f.node.values.innerData.split(","), function(x) { return Std.parseInt(x) ; })) ;
			k.textComplements = if (!f.hasNode.comp) null else f.node.comp.innerData.split("%") ;
			k.perMemberValue = k.values != null && f.node.values.has.pmv && f.node.values.att.pmv == "1" ;
			var p = f.att.place.split(",") ;
			k.place = {x : Std.parseInt(p[0]), y : Std.parseInt(p[1])} ;

			return k ;
		}) ;
	}

}

