package data ;

import GameData._ArtefactId ;

enum WWin {
	WRToken(qty : Int, all : Bool, opm : Bool) ;
	WRReput(school : String, r : Int, all : Bool, opm : Bool) ; 
	WROtherRecipe(qty : Int, all : Bool, opm : Bool) ;
	WRSecretRecipe(type : String, qty : Int, all : Bool, opm : Bool) ;
	WRRandomRecipe(wMin : Int, wMax : Int, qty : Int, all : Bool, opm : Bool) ;
	WRItem(objects : List<{o : _ArtefactId, qty : Int}>, all : Bool, opm : Bool) ;
}


typedef SCTReward = {
	public var id		: String ;
	public var place	: {x : Int, y : Int} ;
	public var name		: String ;
	public var desc		: String ;
	public var listInfo	: String ;
	public var rewards 	: Array<WWin> ;
}



class SCTRewardXML extends haxe.xml.Proxy<"sctRewards.xml", SCTReward> {

	public static function parse() {
		return new data.Container<SCTReward, SCTRewardXML>(true).parse("sctRewards.xml",function(id,iid,f) {
			var k : SCTReward = {
				id : id,
				place : null,
				name : f.att.name,
				desc : Data.TEXTDESC.format(Tools.format(f.node.desc.innerData)),
				listInfo : Data.TEXTDESC.format(Tools.format(f.node.list.innerData)),
				rewards : new Array()
			} ;

			var p = f.att.place.split(",") ;
			k.place = {x : Std.parseInt(p[0]), y : Std.parseInt(p[1])} ;


			for (g in f.elements) {
			switch(g.name) {
				case "desc", "list" : continue ;
				case "token" :
					k.rewards.push(WRToken(Std.parseInt(g.att.v), g.has.all && Std.parseInt(g.att.all) == 1, g.has.opm && Std.parseInt(g.att.opm) == 1)) ;
				case "reput" :
					k.rewards.push(WRReput(g.att.s, Std.parseInt(g.att.v), g.has.all && Std.parseInt(g.att.all) == 1, g.has.opm && Std.parseInt(g.att.opm) == 1)) ;
				case "item" : 
					k.rewards.push(WRItem(Lambda.map(Game.getArtefacts(g.att.v), function(x) { return {o : x._id, qty : x._freq} ; }), g.has.all && Std.parseInt(g.att.all) == 1, g.has.opm && Std.parseInt(g.att.opm) == 1)) ;
				case "otherrecipe" : 
					k.rewards.push(WROtherRecipe(Std.parseInt(g.att.v), g.has.all && Std.parseInt(g.att.all) == 1, g.has.opm && Std.parseInt(g.att.opm) == 1)) ;
				case "randomrecipe" : 
					var weights = g.att.v.split(":") ;
					k.rewards.push(WRRandomRecipe(Std.parseInt(weights[0]), Std.parseInt(weights[1]), Std.parseInt(g.att.v), g.has.all && Std.parseInt(g.att.all) == 1, g.has.opm && Std.parseInt(g.att.opm) == 1)) ;
				case "secretrecipe" : 
					var weights = g.att.v.split(":") ;
					k.rewards.push(WRSecretRecipe(weights[0], Std.parseInt(weights[1]), g.has.all && Std.parseInt(g.att.all) == 1, g.has.opm && Std.parseInt(g.att.opm) == 1)) ;
				
				default :
					throw "Invalid case "+ g.name + " in SCTReward "+id ;
			}
		}

			return k ;
		}) ;
	}

}

