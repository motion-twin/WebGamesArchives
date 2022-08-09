/*
$Id: FEString.as,v 1.14 2004/03/19 09:57:31  Exp $

Class: FEString
*/
class FEString{//}

	/*
	Function: replace
		Replace a substring by an other in a string
	
	Parameters:
		str - Original string
		
		
	Returns:
		The number
		
	See Also:
		<FENumber.encode62>
	*/
	static function replace(str,search,replace){
		var preText = "", newText = "";

		if(search.length==1) return str.split(search).join(replace);
		
		var position = str.indexOf(search);
		if(position == -1) return str;
		
		do { 
			position = str.indexOf(search); 
			preText = str.substring(0, position) 
			str = str.substring(position + search.length) 
			newText += preText + replace; 
		} while(str.indexOf(search) != -1) 
		newText += str; 
		return newText; 
	} 

	/*
	Function: decode62
		decode 'base62' strings
	
	Parameters:
		n - The string to decode
		
	Returns:
		The number
		
	See Also:
		<FENumber.encode62>
	*/
	static function decode62(n:String):Number{
		var r:Number = 0;
		var coef:Number = 1;
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
	}
	
	/*
	Function: unHTML
		Escapes html special chars to display string containing html in TextFields

	Note:
		Replace "<",">" and "&" by "&lt;", "&gt;" and "&amp;"
		
	Parameters:
		r - String to escape

	Returns:
		The modified string
	*/
	static function unHTML(r:String):String{
		if(r.length <= 0) return r;
		
		var i=0;
		while((i=r.indexOf("&",i)) > -1){
			r = r.substr(0,i) + "&amp;" + r.substr(i + 1);
			i += 4;
		}
		var i=0;
		while((i=r.indexOf("<",i)) > -1){
			r = r.substr(0,i) + "&lt;" + r.substr(i + 1);
			i += 3;
		}
		var i=0;
		while((i=r.indexOf(">",i)) > -1){
			r = r.substr(0,i) + "&gt;" + r.substr(i + 1);
			i += 3;
		}
		return r;
	}

	/**
	 * Supprime toutes les occurence d'un caract�re
	 */
	static function rmChr(r:String,aChar:String):String{
		if(r.length <= 0) return r;
	
		for(var i=0;i<r.length;i++){
			if(r.substr(i,1) == aChar){
				r = r.substr(0,i)+r.substr(i+1);
			}
		}
		return r;
	}

	/**
	 * Supprime les sauts de ligne
	 */
	static function rmNewLine(str:String):String{
		return rmChr(str,chr(13));
	}
	
	/**
	 * Supprime les espaces et sauts de ligne � gauche (au d�but de la chaine)
	 */
	static function ltrim(str:String){
		var i = 0;
		while(str.substr(i,1) == " " || str.substr(i,1) == chr(13)){
			i++;
			if(i >= str.length){
				return "";
			}
		}
		return str.substring(i,str.length);
	}

	/**
	 * Supprime les espaces et sauts de ligne � droite (� la fin de la chaine)
	 */
	static function rtrim(str:String){
		var i = str.length - 1;
		while(str.substr(i,1) == " " || str.substr(i,1) == chr(13)){
			i--;
			if(Math.abs(i) >= str.length){
				return "";
			}
		}
		return str.substr(0,i+1);
	}

	/**
	 * Supprime les espaces et sauts de ligne au d�but et � la fin de la chaine
	 */
	static function trim(str:String){
		return ltrim(rtrim(str));
	}
	
	/**
	 * G�n�re un identifiant al�atoire de longueure l, dans la base m (m de 2 � 32)
	 */
	static function randomId(l,m){
		if(arguments.length < 1){
			var l = 8;
		}

		if(arguments.length < 2){
			var m = 16;
		}

		var rs = "";
		for(var i=0;i<l;i++){
			rs += random(m).toString(m);
		}

		return rs;
	}

	static var __uniqid:Number;

	/**
	 * G�n�re un identifiant unique (mais pas al�atoire)
	 */
	static function uniqId(){
		if(__uniqid == undefined){
			__uniqid = Math.floor(Math.random()*100)+1;
		}
		__uniqid++;
		return FENumber.toAlphaString(__uniqid);
	}

	static function repeat(str:String,l):String{
		var r:String = "";
		for(var i=0;i<l;i++){
			r += str;
		}
		return r;
	}

	/*
	Function: formatVars
		Replace $? where ? is a character by the value of obj[?]
		
	Note:
		$$ is remplaced by a simple $
	
	Parameters:
		str - String to use
		obj - Object containing properties
		
	Returns:
		Formatted string
		
	See Also:
		<Lang.fv>
	*/
	static function formatVars(str:String,obj:Object){
		var pos = str.indexOf("$");

		while(pos > -1){
			var n = str.substr(pos+1,1);
			if(n == "$"){
				str = str.substr(0,pos)+"$"+str.substring(pos+2,str.length);
				pos = str.indexOf("$",pos+2);
			}else{
				var r = obj[n];

				str = str.substr(0,pos)+r+str.substring(pos+2,str.length);
				pos = str.indexOf("$",pos+r.length);
			}
		}

		return str;
	}

	static var urlsEnds:Array = [" ",")","\"","&lt;","&gt;"];

	/**
	 * Remplace les url par des liens
	 */
	static function parseUrls(str:String):String{
		var counter = 0;
		while (counter < str.length-7) {
			var urlStart = str.indexOf("http://",counter);
			if (urlStart == -1) {
				return str;
			} else {
				var end = new Array();
				for(var i=0;i<urlsEnds.length;i++){
					var t = str.indexOf(urlsEnds[i], urlStart);
					if(t>=0){
						end.push(t);
					}
				}
				if(end.length == 0){
					var urlEnd = -1;
				}else{
					var urlEnd = end.getMin();
				}
				if (urlEnd == -1) {
					var aUrl = str.substr(urlStart);
					return str.substring(0, urlStart)+"<b><a href=\""+aUrl+"\" target=\"_blank\">"+aUrl+"</a></b>";
				} else {
					var aUrl = str.substring(urlStart, urlEnd);
					str = str.substr(0, urlStart)+"<b><a href=\""+aUrl+"\" target=\"_blank\">"+aUrl+"</a></b>"+str.substr(urlEnd);
					counter= urlStart+aUrl.length*2+38;
				}
			}
		}
		return str;
	}

	/**
	 * Attend un tableau en param�tre
	 * Remplace les % par les �l�ments du tableau, dans l'ordre
	 * %% est remplac� par %
	 */
	static function format(str:String,arr):String{
		if(typeof(arr) != "object"){
			var arr = arguments.splice(0,1);
		}

		var pos = str.indexOf("%");
		var i = 0;

		while(pos > -1){
			if(str.substr(pos+1,1) == "%"){
				str = str.substr(0,pos)+"%"+str.substring(pos+2,str.length);
				pos = str.indexOf("%",pos+2);
			}else{
				var r = arr[i];

				str = str.substr(0,pos)+r+str.substring(pos+1,str.length);
				i++;
				pos = str.indexOf("%",pos+r.length);
			}
		}

		return str;
	}

	/**
	 * Retourne le nombre de majuscules dans la chaine
	 */
	static function countUpperCase(str:String):Number{
		var count = 0;
		for(var i=0;i<str.length;i++){
			var t = str.substr(i,1);
			if(t != t.toLowerCase()){
				count++;
			}
		}
		return count;
	}

	/**
	 * Retourne true si la chaine commence par str
	 */
	static function startsWith(str1:String,str2:String):Boolean{
		if(str1.substr(0,str2.length) == str2){
			return true;
		}else{
			return false;
		}
	}

	/**
	 * Retourne true si la chaine se termine par str
	 */
	static function endsWith(str1:String,str2:String):Boolean{
		if(str1.substr(str1.length-str2.length) == str2){
			return true;
		}else{
			return false;
		}
	}

	/**
	 * Retourne true si un caract�re se r�p�te plus de max fois
	 */
	static function checkRepeat(str:String,max:Number):Boolean{
		var last = str.charAt(0);
		var nb = 1;
		for(var i=1;i<str.length;i++){
			var j = str.charAt(i);
			if(j == last){
				nb++;
			}else{
				nb = 1;
				last = j;
			}
			if(nb > max){
				return true;
			}
		}
		return false;
	}

	static function mailParse(str:String):Array{
		var arr = str.split(",");
		var ret:Array = new Array();
		for(var i=0;i<arr.length;i++){
			var t = trim(arr[i]);
			var p = t.indexOf("<");
			if(p < 0){
				ret.push({m: t});
			}else{
				var m = t.substring(p+1,t.length-1);
				var n = trim(t.substring(0,p));
				ret.push({m: m,n: n});
			}
		}
		return ret;
	}

	static function propParse(str:String):Object{
			var arr = str.split(";");
			var ret:Object = new Object();
			for(var i=0;i<arr.length;i++){
				var s = arr[i];
				var p;
				if((p = s.indexOf("=")) >= 0){
					ret[s.substr(0,p)] = s.substr(p+1);
				}
			}
			return ret;
	}

	static function replaceBackSlashN(r:String){
		var i = 0;
		while((i=r.indexOf("\\n",i)) > -1){
			r = r.substr(0,i) + "\n" + r.substr(i + 2);
		}
		return r;
	}
	
	
	// TODO rendre ces param�tres dynamiques
	static var defaultFontFamily = "verdana";
	static var defaultFontSize = "12";
	static var defaultFontColor = "#335511";
	
	private static function simplifyXHTML(x){	
		if(x.nodeType == 3) return new XML(x.toString());


		var rs = new XML();
		switch(x.nodeName.toLowerCase()){
			case "font":
				if(!x.hasChildNodes()) return;
				
				var style = "";
				var f = x.attributes.FACE.toLowerCase();
				if(f != undefined && f != defaultFontFamily){
					style += "font-family: "+x.attributes.FACE+";";
					rs.attributes.face = x.attributes.FACE;
				}
				var s = x.attributes.SIZE.toLowerCase();
				if(s != undefined && s != defaultFontSize){
					style += "font-size: "+x.attributes.SIZE+"px;";
					rs.attributes.size = x.attributes.SIZE;
				}
				var c = x.attributes.COLOR.toUpperCase();
				if(c != undefined && c != defaultFontColor){
					style += "color: "+x.attributes.COLOR+";";
					rs.attributes.color = x.attributes.COLOR;
				}
				
				var rsb = new XML();
				
				if(style.length){
					rs.nodeName = "font";
					rsb.nodeName = "span";
					rsb.attributes.style = style;
				}
				
				for(var n=x.firstChild;n.nodeType>0;n=n.nextSibling){
					rsb.appendChild(simplifyXHTML(n));
				}
				
				rs.appendChild(rsb);

				break;

			case "b":
			case "i":
			case "u":
			case "li":
				rs.nodeName = x.nodeName.toLowerCase();
				for(var n=x.firstChild;n.nodeType>0;n=n.nextSibling){
					rs.appendChild(simplifyXHTML(n));
				}
				break;
				
			case "a":
			case "img":
				rs.nodeName = x.nodeName.toLowerCase();
				for(var n in x.attributes){
					rs.attributes[n] = x.attributes[n];
				}
				for(var n=x.firstChild;n.nodeType>0;n=n.nextSibling){
					rs.appendChild(simplifyXHTML(n));
				}
				break;

			case "p":
				rs.nodeName = "br";
				for(var n=x.firstChild;n.nodeType>0;n=n.nextSibling){
					rs.appendChild(simplifyXHTML(n));
				}
				break;
				
			case "textformat":
			default:
				for(var n=x.firstChild;n.nodeType>0;n=n.nextSibling){
					rs.appendChild(simplifyXHTML(n));
				}
				break;
		}
		return rs;
	};

	static function simplifyHTML(str){
		var myxml = new XML(str);
		myxml = simplifyXHTML(myxml);
		return replace(replace(replace(myxml.toString(),"<br>",""),"</br>","<br />"),"&apos;","'");
	};
	
//{
}
