package tools;

import data.Building;

class BuildingTool
{
	
	public static var BUILDINGS =  ods.Data.parse( "ods/chantiers.ods", "Chantiers", DataBuilding );
	static var _initialized = process();
	
	static function getCacheFile( file ) {
		return Config.ROOT + file;
	}
	
	static function process() {
		for( b in BUILDINGS ) {
			b.nom = StringTools.trim(b.nom);
			//Post process the resources string
			b.resources = new List();
			if( b.bois1 > 0 ) b.resources.add( { id : "wood", qty : b.bois1 } );
			if( b.metal1 > 0 ) b.resources.add( { id : "metal", qty : b.metal1 } );
			if( b.bois2 > 0 ) b.resources.add( { id : "wbeam", qty : b.bois2 } );
			if( b.metal2 > 0 ) b.resources.add( { id : "mbeam", qty : b.metal2 } );
			if( b.vis > 0 ) b.resources.add( { id : "mecaParts", qty : b.vis } );
			if( b.beton > 0 ) b.resources.add( { id : "concrWall", qty : b.beton } );
			if( b.tole > 0 ) b.resources.add( { id : "plate", qty : b.tole } );
			if( b.eau > 0 ) b.resources.add( { id : "water", qty : b.eau } );
			if( b.tube > 0 ) b.resources.add( { id : "tube", qty : b.tube } );
			if( b.explo > 0 ) b.resources.add( { id : "explo", qty : b.explo } );
			if( b.electro > 0 ) b.resources.add( { id : "electro", qty : b.electro } );
			
			if( b._raw != null ) {
				var str = StringTools.replace(b._raw, ";", ",");
				for( r in str.split(',') ) {
					r = StringTools.trim(r);
					var count 	= if( r.indexOf("*") >= 0 ) Std.parseInt(r.split("*")[0]) else 1;
					var tool 	= if( r.indexOf("*") >= 0 ) r.split("*")[1] else r;
					b.resources.add( { id:tool, qty:count } );
				}
			}
		}
		return true;
	}
	
	static public function generateBuildings() {
		check();
		var l = new List<Building>();
		for( b in BUILDINGS ) {
			//if(b.mod != null && !db.GameMod.hasMod(b.mod)) {
			//	continue;
			//}
			var c = new Building();
			c.id = b.id;
			c.key = b.key;
			c.drop = b.drop;
			c.name = b.nom;
			if( App.isEvent("paques") && (b.key == "hanger" || b.key == "hanger_solid") ) {
				c.name = Text.get.EasterCross;
			}
			c.parent = b.parent!=null ? b.parent : "";
			c.paCost = b.PA;
			c.unbreakable = b.isUnbreakable;
			c.def = b.def;
			c.temporary = b.isTmp;
			c.mod = b.mod;
			c.hasLevels = false;//default value
			c.needList = new List();
			if( b.resources != null )
				for ( a in b.resources ) {
					var t = XmlData.getToolByKey(a.id);
					if (t==null)
						throw "unknown tool "+a.id+" in building "+b.nom;
					c.needList.add( { t:t, amount : a.qty } );
				}
			l.add(c);
		}
		return l;
	}
	
	static function check() {
		for ( b in BUILDINGS )
			if( b.parent != null && !Lambda.exists( BUILDINGS, function(b2) return b2.key == b.parent ) )
				throw "No parent " + b.parent + " found  from building : " + b.nom+"("+b.key + "," + b.id + ")";
		
		for ( b in BUILDINGS )
			if ( b.parent != null && b.parent == b.key )
				throw "Parent " + b.parent + " isn't valid from Building : " + b.nom + "(" + b.key + "," + b.id + ") : can't be the same !";
				
		for ( b in BUILDINGS )
		for ( b2 in BUILDINGS )
			if ( b != b2 && (b.id == b2.id || b.key == b2.key) && b.mod == b2.mod )
				throw "chaque batiment doit avoir un id et un key unique ! " +b.nom + "(" + b.id + "," + b.key + ")/" + b2.nom + "(" + b2.id + "," + b2.key + ")";
	}
	
}
