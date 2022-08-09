class Cs{//}

	static var SPRITE = 		  0;
	static var PHYS = 		  1;
	static var HERO = 		  2;
	static var PART = 		  3;
	static var SHOT = 		  4;
	static var MOLE = 		  5;
	static var MAX_SPRITE_TYPE = 	 10;
	
	static var mcw = 		240;
	static var mch = 		240;
	
	
	//static var gameList:{link:String,freq:int}
	
	// GENERAL
	static function mm(min,n,max){
		return Math.min(Math.max(min,n),max)
	}
	
	static function round(n,lim){
		while(n>lim) n -=lim*2
		while(n<-lim)n +=lim*2
		return n
	}
	
	static function indexOf(list,n):int{
		for(var i=0; i<list.length; i++ ){
			if(list[i]==n)return i;
		}
		return null;
	}

	static function getRandRep(n):Array<float>{
		var list = new Array();
		var sum = 0;
		for(var i=0; i<n; i++){
			var p = Std.random(100)
			list[i] = p
			sum += p
		}
		var rep = new Array();
		for(var i=0; i<n; i++){
			var p = list[i]
			list[i] = p/sum
		}	
		
		return list
	}
	
	// SPECIFIC
	static function getTimeString(t){
		
		var min = string(Math.floor(t/60000))
		var sec = string(Math.floor((t%60000)/1000))
		var mil = string(t%1000)

		
		while(min.length<2)min="0"+min;
		while(sec.length<2)sec="0"+sec;
		while(mil.length<3)mil="0"+mil;
		
		return min+"'"+sec+"\""+mil
		
	}	
		
//{
}