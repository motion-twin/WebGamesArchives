class Skin {
	public static function decodeSkin( skin:String ) : String {
		try {
			var bytes = new haxe.BaseCode(haxe.io.Bytes.ofString(Base64.BASEU)).decodeBytes(haxe.io.Bytes.ofString(skin));
		
			var n = bytes.length;
		
			var echeck1 = (bytes.get(n-2) << 8) | bytes.get(n-4);
			var echeck2 = (bytes.get(n-1) << 8) | bytes.get(n-3);

			var bytes = bytes.sub(0,n-4);
		
			var check2 = 0;
			var encoded = new haxe.BaseCode(haxe.io.Bytes.ofString(Base64.BASEU)).encodeBytes(bytes).toString();
			for (i in 0...encoded.length){
				var x = Base64.BASEU.indexOf(encoded.charAt(i));
				check2 = ((check2 * 5) ^x) & 0xFFFF;			
			}
			var check1 = 0;
			var items = [];
			for (i in 0...bytes.length){
				var v = bytes.get(i);
				check1 = ((check1 * 7) ^ v) & 0xFFFF;
				items.push(v);
			}
			if (echeck1 == check1 && echeck2 == check2)
				return items.join(",");
		}
		catch (e:Dynamic){
		}
		return "0,1,2,3,4,5,6,7,8,9";
	}
}