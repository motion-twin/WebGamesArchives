package data ;


import Recipe.DispWay ;
import GameData._ArtefactId ;
import GameData._ProductData ;

enum ProductType {
	TCollection ;
	TEffect ;
	TArtefact ;
	TRecipe ;
	TSpecial ;
	THidden ;
	TBarter ;
}
	

typedef Product = {
	var id : String ;
	var type : ProductType ;
	var cost : Array<Int> ;
	var max : Int ; //max quantity you can buy 
	var qty : Int ; //qty bought per buy
	var sellQty : Int ; 
	var disp : Int ; // always disp if null, else x by day
	var cond : Condition ; //condition d'achat
	var hideCond : Condition ; //condition pour voir l'objet en boutique
	var available : Bool ; //objet pas disponible 
	var notEnough : Bool ; //pas assez de sous
	var ne : Int ; //0 : not enough gold / 1 : not enough token
	var alreadyHaveIt : Bool ; //ne peut pas acheter car l'a déjà
	var obj : Dynamic ;
	var pData : String ;
}


typedef Merchant = {
	var id : String ;
	var iid : Int ;
	var name : String ;
	var fullName : String ;
	var intro : String ;
	var place : Map ;
	var gfx : String ;
	var cond : Condition ;
	var products : Array<Product> ;
	var selling : {ratio : Float, products : Array<Product>} ;
	var preSelected : String ;
}



class MerchantXML extends haxe.xml.Proxy<"merchants.xml", Merchant> {
	
	static var SELL_ELEMENTS_DEFAULT_QTY = [5, 3, 2, 1] ;
	
	static function getSellProducts(s : String, ?ratio = 1.0) : Array<Product> {
		var res = [] ;
		var tab = getSellArtefacts(s) ;
		
		for (t in tab) {
			var o = Data.getArtefactInfo(t.o) ;
			if (o == null || o.price == null)
				throw "invalid artefact to sell " + Std.string(t) ;
			
			res.push({
				id : Std.string(t.o).substr(1),
				type : TArtefact,
				cost : [0, if (Std.int(o.price * ratio) <= 0) 1 else Std.int(o.price * ratio)],
				max : 1000,
				qty : t.qty,
				sellQty : 0,
				disp : null,
				cond : Condition.CTrue,
				hideCond : Condition.CTrue,
				available : true,
				notEnough : false,
				ne : null,
				alreadyHaveIt : false,
				obj : null,
				pData : haxe.Serializer.run(_Art(t.o, t.qty))
			}) ;
		}
		
		return res ;
	}
	
	static function getSellArtefacts(s : String) : Array<{o : _ArtefactId, qty : Int}> {
		var specials = ["default", "allElements", "allArtefacts"] ;
		var tab = [] ;
		
		var defaultElements = function() {
			var res = new Array() ;
			for (i in 0...12)
				res.push({o : _Elt(i), qty : if (SELL_ELEMENTS_DEFAULT_QTY[i] != null) SELL_ELEMENTS_DEFAULT_QTY[i] else 1}) ;
			return res ;
		}
		
		switch (s) {
			case null : return defaultElements() ;
			case "" : return defaultElements() ;
			case specials[0] : return defaultElements() ; //default
			case specials[1] : 
				var tab = tab.concat(defaultElements()) ;
				for (i in 12...28) {
					tab.push({o : _Elt(i), qty : 1}) ;
				}
				return tab ;
			case specials[2] :
				for (a in Data.OBJECTS.iterator()) {
					if (a.price != null)
						tab.push({o : a.o, qty : 1}) ;
				}
				return tab ;
				
			default : 
				var tt = s.split(";") ;
				for(sp in specials) {
					if (!Lambda.exists(tt, function(x) { return x == sp ; } ))
						continue ;
					tt.remove(sp) ;
					tab = tab.concat(getSellArtefacts(sp)) ;
				}			

				for (t in tt) {
					var aid = Data.parseArtefact(t) ;
					if (Lambda.exists(tab, function(x) { return x.o == aid ; }))
						throw "sell artefact " + Std.string(aid) + " already in list" ;
					tab.push({o : aid, qty : 1}) ;
				}
				return tab ;
		}
	}
		

	public static function parse() {
		return new data.Container<Merchant,MerchantXML>().parse("merchants.xml",function(id,iid,f) {
			var m = {
				id : id,
				iid : iid,
				name : f.att.name,
				fullName : if (f.has.fullName) f.att.fullName else f.att.name,
				intro : if (f.hasNode.intro) Data.TEXTDESC.format(f.node.intro.innerData) else "",
				place : if (f.att.place != "") Data.MAP.getName(f.att.place),
				gfx : f.att.gfx,
				cond : if (f.has.cond) Script.parse(f.att.cond) else Condition.CTrue,
				products : new Array(),
				selling : null,
				preSelected : null
			} ;
			
			for (o in f.nodes.obj) {
				var obj = {
					id : o.att.o,
					type : null,
					cost : null,
					max :if (o.has.max) Std.parseInt(o.att.max) else 1000,
					qty : if (o.has.qty) Std.parseInt(o.att.qty) else 1,
					sellQty : null,
					disp : if (o.has.disp) { if (o.att.disp == "a") null ; else Std.parseInt(o.att.disp) ; } else 1,
					cond : if (o.has.cond) Script.parse(o.att.cond) else Condition.CTrue,
					hideCond : if (o.has.hideCond) Script.parse(o.att.hideCond) else Condition.CTrue,
					available : true,
					notEnough : false,
					ne : null,
					alreadyHaveIt : false,
					obj : null,
					pData : null
				} ;
				
				switch(o.att.type) {
					case "col" : obj.type = TCollection ;
					case "fx" : obj.type = TEffect ;
					case "art" : obj.type = TArtefact ;
					case "recipe" : 
						obj.type = TRecipe ;
					
						var r = Data.RECIPES.getName(obj.id) ;
						if (r != null && r.disps != null) {
							for (d in r.disps) {
								switch(d.way) {
									case School :
										if (d.cond == Condition.CTrue)
											d.cond = obj.cond ;
										break ;
									default : 
										continue ;
								}
							}
						}
						
					case "special" : obj.type = TSpecial ;
					case "troc" : obj.type = TBarter ;
					default :
						throw "invalid product type : " + o.att.type ;
				}
				
				if (o.has.cost)
					obj.cost = Lambda.array(Lambda.map(o.att.cost.split(":"), function(x : String) { return Std.parseInt(x) ; })) ;
				else 
					throw "missing product cost " + obj.id ;
				
				m.products.push(obj) ;
			}
			
			
			if (f.hasNode.sell) {
				m.selling = {ratio : if (f.node.sell.has.ratio) Std.parseFloat(f.node.sell.att.ratio) else 1.0, products : null} ;
				m.selling.products = getSellProducts(f.node.sell.att.products, m.selling.ratio) ;
				
			}
			
			return m ;
		});
	}

}