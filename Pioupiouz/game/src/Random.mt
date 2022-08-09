class Random {//

	var seedLow : int;
	var seedHigh : int;

	function new(n) {
		if(n==null)n=1;
		seedLow = n;
		seedHigh = 0;
	}

	function setSeed(n) {
		seedLow = n;
		seedHigh = 0;
		
	}

	function random(max) {
		var low = 0xDB6DB6DB;
		var high = 0xA65AEC2F;
		var slow = int(seedLow * low);
		var shigh = int(seedHigh * low + seedLow * high);
		seedLow = slow + 1;
		seedHigh = shigh;
		return (seedLow >>> 3) % max;
	}
	
	function rand(){
		return random(1000)/1000
	}
	
//{
}