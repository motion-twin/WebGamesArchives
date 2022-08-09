package mt.text;

/**
 * Calculates the difference between 2 strings
 * with the Levensthein algorythm.
 * author Pimm Hogeling
 */
class Levensthein {
		
	
 	#if neko
 	private static var _urlEncode = neko.Lib.load("std","url_encode",1);
 	private static var _urlDecode = neko.Lib.load("std", "url_decode", 1);
	#end
	
	/**
	 * Calculates the levenshtein distance between the two passed strings, which is the number of character insertions, deletions
	 * and substitutions required to go from the first passed string to the second. The greater the distance, the more different
	 * the strings are. For instance, the levenshtein distance between "haxe" and "max" is two, because the fastest way to go
	 * from "haxe" to "max" is substituting the first "h" for an "m", and deleting the last "e". The output of this method ranges
	 * from 0 if the strings are completely equal, to the length of the longest string if the strings are completely different.
	 * Note that this method counts "A" and "a" as different characters. If you want this method to work case-insensitive,
	 * convert both strings to either upper- or lowercase before calling this method.
	 */
	public static #if php inline #end function getDistance(a:String, b:String):Int {
		// In PHP, use the much faster native levenshtein method.
		#if php
			return untyped __call__("levenshtein", a, b);
		#else
			// If string A is equal to string B, the levenshtein distance is 0.
			if (a == b) {
				return 0;
			}
			// If string A is empty, the levenshtein distance is equal to the length of string B. This is because the fastest way to go
			// from an empty string to string B is deleting all of the characters from B.
			if (0 == a.length) {
				return b.length;
			}
			// For the same reason, the levenshtein distance is equal to the length of String A if string B is empty.
			if (0 == b.length) {
				return a.length;
			}
			// Basically a list of the distances between the current substring of string A and all of the substrings of string B. The
			// first value in this list is the distance between the current substring of string A and an empty string (which is equal
			// to the length of string A, see comments above), whereas the last value is the distance between the current substring of
			// string A and string B.
			var distances:Array<Int> = new Array();
			for (index in 0...(b.length + 1)) {
				distances[index] = index;
			}
			// The list of the distances between the previous substring of string A and all of the substrings of string B.
			var previousDistances:Array<Int>;
			var cost:Int;
			var characterCode:Int;
			// Loop through all of the substrings of string A (excluding the empty string).
			for (index in 0...a.length) {
				previousDistances = distances;
				distances = [index + 1];
				// In AVM2 and JavaScript, use the cca method (the native charCodeAt method). The difference between the native method
				// and the haXe one, is that the haXe one returns null, instead of NaN, if the passed index is out of bounds. Since the
				// passed index will never be out of bounds, there is no reason not to use the faster native method here.
				characterCode = #if (js || flash9) untyped(a).cca(index); #else a.charCodeAt(index); #end
				// Loop through all of the substrings of string B (excluding the empty string).
				for (subIndex in 0...b.length) {
					// Again, in AVM2 and JavaScript use a native method for speed reasons.
					if (characterCode == #if (js || flash9) untyped(b).cca(subIndex) #else b.charCodeAt(subIndex) #end) {
						distances[subIndex + 1] = previousDistances[subIndex];
					} else {
						distances[subIndex + 1] = Math.floor(Math.min(Math.min(previousDistances[subIndex + 1] + 1, distances[subIndex] + 1), previousDistances[subIndex] + 1));
					}
				}
			}
			// Return the last value of the list of distances, as that is the distance between string A and string B.
			return distances[b.length];
		#end
	}
	
	/**
	 * Calculates the similarity between two strings as a number between 1 (equal) and 0 (no similarities). Note that this method
	 * counts "A" and "a" as different characters. If you want this method to work case-insensitive, convert both strings to
	 * either upper- or lowercase before calling this method.
	 */
	public static inline function getSimilarity(a:String, b:String):Float {
		return 1 - (getDistance(a, b) / Math.max(a.length, b.length));
	}


}
