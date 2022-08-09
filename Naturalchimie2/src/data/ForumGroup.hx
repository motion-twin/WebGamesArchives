package data;

typedef ForumGroup = {
	var id : String ;
	var name : String ;
	var fullName : String ;
	var desc : String ;
	var place : Map ;
	var cread : Condition ;
	var cwrite : Condition ;
	var cssClass : String ;
}


class ForumGroupXML extends haxe.xml.Proxy<"forumgroup.xml",ForumGroup> {

	public static function parse() {
		return new data.Container<ForumGroup,ForumGroupXML>().parse("forumgroup.xml",function(id,iid,f) {
			var res = {
				id : f.att.id,
				name : f.att.name,
				fullName : if (f.has.fullname) f.att.fullname else f.att.name,
				desc : Data.TEXTDESC.format(f.innerData),
				place : if (f.att.place != "") Data.MAP.getName(f.att.place) else null,
				cread : if (f.has.read) Script.parse(f.att.read) else Condition.CTrue,
				cwrite : if (f.has.write) Script.parse(f.att.write) else Condition.CTrue,
				cssClass : if (f.has.cssClass) f.att.cssClass else ""
			};
			
			if (res.place != null) {
				var m = Data.MAP.getId(res.place.mid) ;
				if (m == null)
					throw "unknown zone for forum group : " + res.place.mid ;
				m.fGroup = res ;
			}
			
			return res ;
		});
	}

}
