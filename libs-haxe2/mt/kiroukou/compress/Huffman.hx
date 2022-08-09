package mt.kiroukou.compress;

using Lambda;
using mt.kiroukou.tools.IntTools;
using mt.kiroukou.tools.StringTools;
class Huffman
{
	//TODO, static dictionnaries to  optimise compression and avoid the headers need.  Still not found any solution to manage "out of dictionnary" character
	public static var ENGLISH_TEXT = [{c:'a', f:8167},{c:'b', f:1492},{c:'c', f:2782},{c:'d', f:4253},{c:'e', f:12702},{c:'f', f:2228},{c:'g', f:2015},{c:'h', f:6094},{c:'i', f:6966},{c:'j', f:153},{c:'k', f:747},{c:'l', f:4025},{c:'m', f:2406},{c:'n', f:6749},{c:'o', f:7507},{c:'p', f:1929},{c:'q', f:95},{c:'r', f:5987},{c:'s', f:6327},{c:'t', f:9056},{c:'u', f:2758},{c:'v', f:1037},{c:'w', f:2365},{c:'x', f:150},{c:'y', f:1974},{c:'z', f:74}];
	public static var FRENCH_TEXT = [{c:'a', f:7636},{c:'b', f:0901},{c:'c', f:3260},{c:'d', f:3669},{c:'e', f:14715},{c:'f', f:1066},{c:'g', f:0866},{c:'h', f:0737},{c:'i', f:7529},{c:'j', f:0545},{c:'k', f:0049},{c:'l', f:5456},{c:'m', f:2968},{c:'n', f:7095},{c:'o', f:5378},{c:'p', f:3021},{c:'q', f:1362},{c:'r', f:6553},{c:'s', f:7948},{c:'t', f:7244},{c:'u', f:6311},{c:'v', f:1628},{c:'w', f:0114},{c:'x', f:0387},{c:'y', f:0308},{c:'z', f:0136},{c:'à', f:0486},{c:'œ', f:0018},{c:'ç', f:0085},{c:'è', f:0271},{c:'é', f:1904},{c:'ê', f:0225},{c:'ë', f:0001},{c:'î', f:0045},{c:'ï', f:0005},{c:'ù', f:0058}];
	
	public static var lastDictionary : Array<{c:String, f:Int}> = null;
	
	public static function encode(text:String, ?local=false):String
	{
		var head;
		var codes = [];
		var count = 0;
		var chars = new Array<HuffmanNode>();
		//init
		for( i in 0...text.length )
		{
			var c = text.charAt(i);
			var code = c.charCodeAt(0);
			if( chars[code] == null )
			{
				chars[code] = new HuffmanNode(c);
				count++;
			}
			else
			{
				chars[code].frequence++;
			}
		}
		
		lastDictionary = chars.filter(function(n) return n != null).map( function(n) return { c:n.car.s, f:n.frequence } ).array();
		//
		head = _setTree( chars, count );
		_setCode( codes, head );
		//
		var byteCode = "";
		var output = "";
		function addBuffer(s:String) {
			output += s;
		}
		//On concatene la taille du texte original
		addBuffer(_setSize(text.length));
		//On ecrit le nombre de caracteres differents
		addBuffer(_setSize(count));
		if( !local )
		{
			//On ecrit notre enhead car on fait la forme statique de Huffman
			for( i in 0...256 )
			{
				if(codes[i] != null)
				{
					addBuffer(codes[i].car.s);
					addBuffer(_setSize(codes[i].frequence));
				}
			}
		}
		//On compresse les données maintenant
		var id = -1;
		while( ++id < text.length )
        {
			var code = text.charCodeAt(id);
			byteCode += codes[code].code;
			while( byteCode.length >= 8)
			{
				var tmpCode = byteCode.substring(0, 8);
				addBuffer(toChar( tmpCode ));
				byteCode = byteCode.substring(8);
			}
		}
		//Au cas ou il resterai moins de 8 bits pour former l'octet on complete par des 0. Ici test verifié et fonctionnel
		var size = byteCode.length;
		if( size > 0)
		{
			var tmpCode = byteCode;
			for( j in 0...8-size )
				tmpCode += "0";
			addBuffer(toChar( tmpCode ));
		}
		return output;
	}
	
	public static function decode(text:String, ?local=false):String
	{
		var length = text.length;
		var chars = [];
		var fileSize = _getSize(text.substring(0, 2));
		var charsCount = _getSize(text.substring(2, 4));
		text = text.substring(4);
		if( local )
		{
			for( d in lastDictionary )
				chars[d.c.charCodeAt(0)] = new HuffmanNode(d.c, d.f);
		}
		else
		{
			for( i in 0...charsCount )
			{
				chars[text.charCodeAt(0)] = new HuffmanNode(text.charAt(0));
				chars[text.charCodeAt(0)].frequence = _getSize(text.substring(1,3));
				text = text.substring(3);
			}
		}
		// on cree l'arbre
		var head = _setTree(chars, charsCount) ;
		var codes = [];
		_setCode(codes, head);
		
		var fileSize2 = 0;
		var node = head;
		var output = "";
		var id = -1;
		while( ++id < text.length )
		{
			var binCode = getBinaryCode(text.charAt(id));
			var i = -1;
			while( ++i < 8 )
			{
				if( fileSize2 == fileSize ) break;
				//
				if(node.type == HuffmanNodeKind.Leaf)
				{
					output += node.car.s;
					node = head;
					i--;
					fileSize2 ++;
				}
				else
				{
					if(binCode.charAt(i) == '0')
						node = node.fd;
					else if(binCode.charAt(i) == '1')
						node = node.fg;
					else
						throw("ERREUR(decompressionHuffman() => PB char inconnu :" + binCode.charAt(i) + "!");
				}
			}//end for
			if( (fileSize2 == fileSize))
				break;
		}//end While
		if( fileSize2 != fileSize ) throw("ERREUR : >>> Fichier mal decompressé "+fileSize+" != "+fileSize2+" <<<");
		return output;
	}
		
	static function _setTree(chars:Array<HuffmanNode>, count:Int):HuffmanNode
	{
		var tmp;
		var nb = count;
		//
		chars.sort( function( n1, n2 ) {
						return 	if( n1 == null ) 1
								else if( n2 == null ) -1
								else n2.frequence - n1.frequence;
							} );
		//
		while( nb > 1 )
		{
			var mins = _searchMins(chars, count);
			var min1 = chars[mins[0]];
			var min2 = chars[mins[1]];
			tmp = new HuffmanNode("#");
			tmp.frequence = min1.frequence + min2.frequence;
			tmp.fd = min1;
			tmp.fg = min2;
			tmp.type = HuffmanNodeKind.Node;
			chars[mins[0]] = tmp;
			chars[mins[1]] = null;
			nb --;
		}
		return tmp;
	}
	
	static function _setCode(codes:Array<HuffmanNode>, head:HuffmanNode)
	{
		if( HuffmanNodeKind.Leaf == head.type )
		{
			return;
		}
		
		if( head.fg != null )
		{
			head.fg.code = (head.code.length > 0) ? head.code + "1" : "1";
			if( HuffmanNodeKind.Leaf == head.fg.type )
			{
				codes[head.fg.car.code] = head.fg;
			}
		}
		
		if( head.fd != null )
		{
			head.fd.code = (head.code.length > 0) ? head.code + "0" : "0";
			if( HuffmanNodeKind.Leaf == head.fd.type )
			{
				codes[head.fd.car.code] = head.fd;
			}
		}
		
		// On lance la recurssion
		_setCode(codes, head.fg);
		_setCode(codes, head.fd);
	}
	
	static function _searchMins(tab:Array<HuffmanNode>, count:Int):Array<Int>
	{
		var i = 0, min1 = -1, min2 = -1;
		var a = [min1, min2];
		for( i in 0...count)
		{
			if( tab[i] == null ) continue;
			//
			var f = tab[i].frequence;
			if( -1 == min1 )
			{
				min1 = f;
				a[0] = i;
			}
			else if( min2 == -1 && min1 != -1 && a[0] != i )
			{
				min2 = f;
				a[1] = i;
			}
			
			if(f < min1)
			{
				min2 = min1;a[1] = a[0];
				min1 = f;
				a[0] = i;
			}
			else if(f < min2 && i != a[0])
			{
				min2 = f;
				a[1] = i;
			}
		}
		return a;
	}
	
	static function toChar(binary:String)
	{
		return String.fromCharCode( binary.toIntFromBase2() );
	}
	
	static function getBinaryCode(s:String):String
	{
		var s = s.charCodeAt(0).toString(2);
		for( i in s.length...8 )
			s = "0"+s;
		return s;
	}
		
	static function _setSize(val:Int):String
	{
		var s = val.toBase255();
		if( s.length < 2 )
			s = String.fromCharCode(0) + s;
		return s;
	}
	
	static function _displayTree(node:HuffmanNode, nbtab = 0):Void
	{
		nbtab ++;
		var s = "";
		if(node.type == HuffmanNodeKind.Leaf)
		{
			for( i in 0...nbtab)
				s += "     ";
			s += node.car.s + " " + node.frequence;
			trace(s);
			nbtab --;
			return;
		}
	
		_displayTree(node.fd, nbtab);
		for( i in 0...nbtab)
			s += "     ";
		s += node.car.s + " " + node.frequence;
		trace(s);
	
		_displayTree(node.fg, nbtab);
		nbtab -= 1;
	}
	
	static function _getSize(val:String):Int
	{
		if( val.charCodeAt(0) == 0 )
			val = val.substring(1);
		return val.fromBase255();
	}
}


enum HuffmanNodeKind {
	Leaf;
	Node;
}

typedef Char = {
	var s : String;
	var code : Int;
}

class HuffmanNode
{
	public var fd:Null<HuffmanNode>;
	public var fg:Null<HuffmanNode>;
	public var car:Char;
	public var frequence:Int;
	public var code:String;
	public var type:HuffmanNodeKind;
	
	public function new(char:String, frequency = 1)
	{
		car = { s : char, code : char.charCodeAt(0) } ;
		frequence = frequency;
		code = "";
		type = Leaf;
		fg = null;
		fd = null;
	}
	
	public function getCopy():HuffmanNode
	{
		var h:HuffmanNode =  new HuffmanNode(car.s);
		h.type = type;
		h.fd = fd;
		h.fg = fg;
		h.frequence = frequence;
		h.code = code;
		return h;
	}
}
	