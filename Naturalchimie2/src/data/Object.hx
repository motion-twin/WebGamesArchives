package data;

import GameData._ArtefactId ;

typedef Object = {
	var id : String ;
	var name : String ;
	var weight : Int ;
	var need : Array<{points : Int, school : Int}> ;
	var ratio : Float ;
	var desc : String ;
	var flavor : String ;
	var gameHelp : String ;
	var action : String ;
	var caul : Bool ;
	var playable : Bool ;
	var price : Int ;
	var inv : Bool ;
	var img : String ;
	var rank : Int ;
	var o : _ArtefactId ;
}


class ObjectXML {

	public static function parse() {
		var h = new Hash() ;
		var file = "artefacts.xml" ;
		for( e in Data.xml(file).elements() ) {
			//var data = try
				parseObject(new haxe.xml.Fast(e), h) ;
			/*catch( e : Dynamic ) {
				neko.Lib.rethrow("Error in objects : "+Std.string(e));
			}
			h.set(data.id, data) ;*/
		}
		return h ;
	}

	
	static function parseObject(d : haxe.xml.Fast, h : Hash<Object>) {
		try {
			if (d.att.id != "Destroyer") {		
				var o = Data.parseArtefact(d.att.id) ;
				if (o == null)
					throw "unvalid artefact in xml : " + d.att.id ;
				
				 var data = {
					id : Data.getArtefactCode(o),
					name : d.att.name,
					desc : Data.TEXTDESC.format(d.node.desc.innerData),
					flavor : if (d.hasNode.flavor) Data.TEXTDESC.format(d.node.flavor.innerData) else "" ,
					gameHelp : if (d.hasNode.gameHelp) d.node.gameHelp.innerData else null ,
					weight : if (d.has.weight) Std.parseInt(d.att.weight) else null,
					ratio : null,
					action : if (d.has.action) Std.string(d.att.action) else null,
					caul : !(d.has.nocaul && Std.parseInt(d.att.nocaul) == 1),
					playable : d.has.playable && Std.parseInt(d.att.playable) == 1,
					price : if (d.has.price) Std.parseInt(d.att.price) else null,
					need : if (d.has.need) parseNeed(d.att.need) else null,
					inv : !(d.has.inv && Std.parseInt(d.att.inv) == 0),
					img : if (d.has.img) d.att.img else Data.getArtefactCode(o),
					rank : null,
					o : o
				} ;
				
				h.set(data.id, data) ;
			} else {
				for (e in Data.ELEMENTS.iterator()) {
					var eid = null ;
					switch(e.o) {
						case _Elt(i) :
							eid = i ;
						default : throw "wtf" ;
					}
					
					var data = {
						id : Data.getArtefactCode(_Destroyer(eid)),
						name : d.att.name + e.name,
						desc : Data.TEXTDESC.format(Text.format(d.node.desc.innerData, {element : e.name})),
						flavor : if (d.hasNode.flavor) Data.TEXTDESC.format(d.node.flavor.innerData) else "" ,
						gameHelp : if (d.hasNode.gameHelp) d.node.gameHelp.innerData else null,
						weight : if (d.has.weight) Std.parseInt(d.att.weight) else null,
						ratio : null,
						action : if (d.has.action) Std.string(d.att.action) else null,
						caul : !(d.has.nocaul && Std.parseInt(d.att.nocaul) == 1),
						playable : d.has.playable && Std.parseInt(d.att.playable) == 1,
						price : if (d.has.price) Std.parseInt(d.att.price) else null,
						need : null, 
						inv : !(d.has.inv && Std.parseInt(d.att.inv) == 0),
						img : if (d.has.img) d.att.img else Data.getArtefactCode(_Destroyer(eid)),
						rank : null,
						o : _Destroyer(eid)
					} ;
					
					if (d.has.need) {
						if (eid <= 3) //crux à potions => need objet classique
							data.need = [{points : Std.parseInt(d.att.need), school : null}] ;
						/*else if (Lambda.exists([15, 19, 23, 27], function (x) {return x == eid ; } )) //crux à potions => need objet classique
							data.need = {points : Std.parseInt(d.att.need) + 2, school : Data.schoolIndex("ap")} ;*/
					}					
					
					h.set(data.id, data) ;
				}
			}
		}catch( e : Dynamic ) {
			neko.Lib.rethrow("Error in objects : "+Std.string(e)) ;
		}
	}


	public static function parseNeed(s : String) : Array<{points : Int, school : Int}> {
		var res = new Array() ;

		var forAll = false ;

		for (e in s.split(";")) {
			if (e == null || e == "")
				continue ;
			if (e.indexOf(":") == -1) {
				if (forAll)
					throw "need for all is given twice in " + s ;
				forAll = true ;
				res.push({points : Std.parseInt(e), school : null}) ;
			} else {
				var infos = e.split(":") ;
				res.push({points : Std.parseInt(infos[1]), school : Data.schoolIndex(infos[0]) }) ;
			}
		}

		return res ;
	}
}


class ElementXML extends haxe.xml.Proxy<"elements.xml",Object> {

	public static function parse() {
		return new data.Container<Object,ElementXML>(true, true).parse("elements.xml",function(id,_,f) {
			var e = _Elt(Std.parseInt(f.att.id)) ;
			
			return {
				id : Data.getArtefactCode(e),
				name : f.att.name,
				weight : Std.parseInt(f.att.weight),
				ratio : null,
				desc : f.innerData,
				flavor : "",
				gameHelp : null,
				action : if (f.has.action) Std.string(f.att.action) else null,
				caul : true,
				playable : false,
				price : if (f.has.price) Std.parseInt(f.att.price) else null,
				need : if (f.has.need) ObjectXML.parseNeed(f.att.need) else null,
				inv : true,
				img : Data.getArtefactCode(e),
				rank : Std.parseInt(if (f.has.rank) f.att.rank else f.att.id),
				o : e
			};
		});
	}

}

