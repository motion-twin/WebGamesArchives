/*
$Id: FEObject.as,v 1.6 2004/01/12 12:18:41  Exp $

Class: FEObject
*/
class FEObject{//}
	static function clone(obj){
		var r = new Object();
		for(var f in obj){
			r[f] = obj[f];
		};
		return r;
	}
	
	static function recursiveClone(obj){
		var r = new Object();
		for(var f in obj){
			var t = typeof(obj[f]);
			if(t == "object"){
				r[f] = recursiveClone(obj[f]);
			}else{
				r[f] = obj[f];
			}
		};
		return r;
	}

	static function addObject(obj,o,splash){
		//if(splash==undefined)splash=false;
		for(var element in o){
			if(obj[element]==undefined or splash){
				obj[element] = o[element]
			}
		}
	}
	
	static function toColNumber(obj){
		var str = "0x"+obj.r.toString(16)+obj.g.toString(16)+obj.b.toString(16)
		return Number(str)
	}
	
//{
}
