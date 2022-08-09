package horde ;

class Horde {
	
	
	static var mode = 1 ;
	
	
	static public function grow(map : Map) {
		
		switch(mode) {
			case 0 : horde.Online.process(map) ;  // current online version
			case 1 : horde.ModDone.process(map) ; //online version algo improved
			case 2 : horde.CrowdControl.process(map) ; // crowd control process
		}
		
	}
	
	
}