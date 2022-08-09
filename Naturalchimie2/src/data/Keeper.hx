package data ;

typedef Success = {
	var text : String ;
	var weight : Int ;
	var frame : String ;
	var cat : Int ;
}


typedef Keeper = {
	var id : String ;
	var name : String ;
	var gfx : String ;
	var frame : String ;
	var weight : Int ;
	var goOut : Array<{to : String, text : String}> ;
	var dialogs : Array<{d : data.Dialog, weight : Int}> ;
	var luck : Success ;
	var forbidden : Success ;
	var fail : Success ;
	var success: Array<Success> ;
}

class KeeperXML extends haxe.xml.Proxy<"keepers.xml",Keeper> {

	public static function parse() {
		var defaultWeight = 5 ;
		
		return new data.Container<Keeper,KeeperXML>(true,true).parse("keepers.xml",function(id,_,a) {
			var res = {
				id : id,
				name : a.att.name,
				gfx : a.att.gfx,
				frame : if (a.has.frame) a.att.frame else "1",
				weight : Std.parseInt(a.att.weight),
				goOut : new Array(),
				dialogs : new Array(),
				luck : null,
				forbidden : null,
				fail : null,
				success : new Array()
			} ;
			
			for(e in a.nodes.goOut ) {
				res.goOut.push({
					to : e.att.to,
					text : Data.TEXTDESC.format(e.innerData)
				}) ;
			}
			
			
			for(e in a.nodes.dialog) {
				var d = Data.CAULDRONDIALOGS.get(e.att.did) ;
				res.dialogs.push({d : d, weight : if (e.has.weight) Std.parseInt(e.att.weight) else defaultWeight}) ; 
			}
			
			for(e in a.nodes.luck) {
				res.luck = {
					text : Data.TEXTDESC.format(e.innerData),
					weight : if (e.has.weight) Std.parseInt(e.att.weight) else defaultWeight,
					frame : if (e.has.frame) e.att.frame else null,
					cat : null
				} ;
			}
			if (res.luck == null)
				throw "no luck node for keeper " + res.id ;
			
			for(e in a.nodes.forbidden) {
				res.forbidden = {
					text : Data.TEXTDESC.format(e.innerData),
					weight : if (e.has.weight) Std.parseInt(e.att.weight) else defaultWeight,
					frame : if (e.has.frame) e.att.frame else null,
					cat : null
				} ;
			}
			if (res.forbidden == null)
				throw "no forbidden node for keeper " + res.id ;
			
			
			for(e in a.nodes.fail) {
				res.fail = {
					text : Data.TEXTDESC.format(e.innerData),
					weight : if (e.has.weight) Std.parseInt(e.att.weight) else defaultWeight,
					frame : if (e.has.frame) e.att.frame else null,
					cat : null
				} ;
			}
			if (res.fail == null)
				throw "no fail node for keeper " + res.id ;
			
			for(e in a.nodes.success) {
				var s = {
					text : Data.TEXTDESC.format(e.innerData),
					weight : if (e.has.weight) Std.parseInt(e.att.weight) else defaultWeight,
					frame : if (e.has.frame) e.att.frame else null,
					cat : null
				} ;
				
				if (e.has.cat) {
					var c = Data.CATEGORIES.getName(e.att.cat) ;
					if (c == null)
						throw "unknown recipe category : " + e.att.cat ;
					s.cat = c.id ;
				}
				res.success.push(s) ;
			}
			
			
			return res ;
		}) ;
	}
}