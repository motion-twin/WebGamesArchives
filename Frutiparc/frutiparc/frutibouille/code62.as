/**
 * Décode un nombre encodé en base 62
 */
// TODO: passer en as2 
String.prototype.decode62 = function(){
	var r = 0;
	var coef = 1;
	var n = this;
	for(var i=n.length-1;i>=0;i--){
		var c = n.substr(i,1);
		if(c.toLowerCase() == c){
			var t = parseInt(c,36);
		}else{
			var t = parseInt(c.toLowerCase(),36) + 26;
		}
		r += t * coef;
		coef *= 62;
	}
	return r;
};
ASSetPropFlags(String.prototype, "decode62", 1);

Number.prototype.encode62 = function(strlen){
	if(arguments.length == 0) var strlen = 1;
	
	var ret = "";
	var n = this;
	while(n > 0){
		var t = n % 62;
		if(t < 36){
			ret = t.toString(36)+ret;
		}else{
			ret = (t-26).toString(36).toUpperCase()+ret;
		}
		
		n = (n - t) / 62;
	}
	while(strlen > ret.length){
		ret = "0"+ret
	}
	return ret;
};
ASSetPropFlags(Number.prototype, "encode62", 1);