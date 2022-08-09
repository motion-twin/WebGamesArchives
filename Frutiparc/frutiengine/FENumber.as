/*
$Id: FENumber.as,v 1.11 2004/03/12 11:40:52  Exp $

Class: FENumber
*/
class FENumber extends ext.util.MTNumber{//}
	
	static function toColorObj(nb:Number):Object{
		var hex = nb.toString(16)
		var o = {
			r:Number("0x"+(hex.substring(0,2))),
			g:Number("0x"+(hex.substring(2,4))),
			b:Number("0x"+(hex.substring(4,6)))
		}
		//_root.test+="o={r:"+o.r+",g:"+o.g+",b:"+o.b+",}"
		return o;
	}
	
	
	/*
	Function: toAlphaString
		Convert number to an alphabetic string where 1 => a, 26 => z, 27 => aa, aso...
		
	Parameters:
		nb - Number to convert
		
	Returns:
		Alphabetic string
	*/
	static function toAlphaString(nb:Number):String{
		if(nb > 26){
			if(nb % 26 == 0){
				var next = toAlphaString(Math.floor((nb-1) / 26));
				nb = 26;
			}else{
				var next = toAlphaString(Math.floor(nb / 26));
				nb %= 26;
			}
			nb += 9;
			return next + nb.toString(36);
		}else{
			return (nb+9).toString(36);
		}
	}

	/*
	Function: encode62
		Convert number to base 62 ( 0-9a-zA-Z ), with a minimum string length
		
	Parameters:
		n - Number to convert
		strlen - Minimum length of the returned string
		
	Returns:
		Alphanumeric string
	*/
	static function encode62(n:Number,strlen:Number):String{
		if(arguments.length == 1) strlen = 1;

		var ret:String = "";
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
	}

	/*
	Function: toStringL
		Convert a number to string (base 10), with a minimum string length
		
	Parameters:
		n - Number to convert
		strlen - Minimum length of the returned string
		
	Returns:
		Numeric string
	*/
	static function toStringL(n:Number,l:Number):String{
		if(isNaN(n) || n == undefined) n = 0;
		
		var s = n.toString();
		while(s.length < l){
			s = "0"+s;
		}
		return s;
	}

	static function modCol(nb:Number,inc,coef){
		if(inc == undefined) inc = 0; 
		if(coef == undefined) coef = 1; 
		var r = (nb >> 16) & 0xFF;
		var g = (nb >> 8) & 0xFF;
		var b = nb & 0xFF;
		//_root.test+="("+r+","+g+","+b+") -->"
		r = Math.min(Math.max(0,Math.round((r+inc)*coef)),255);
		g = Math.min(Math.max(0,Math.round((g+inc)*coef)),255);
		b = Math.min(Math.max(0,Math.round((b+inc)*coef)),255);
		//_root.test+="("+r+","+g+","+b+") -->"+FEObject.toColNumber( { r:r, g:g, b:b } )+"\n"
		return FEObject.toColNumber( { r:r, g:g, b:b } )
	}
	
	
	
//{
}

