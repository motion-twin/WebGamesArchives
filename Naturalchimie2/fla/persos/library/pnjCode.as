function _setPnj(s) {	
	var infos = s.split(";") ;	
	apply(this, infos) ;
}

function apply(mc, infos) {
	for (var mm in mc) {
		var m = mc[mm] ;
		if (typeof m == "movieclip") {
			var n = "smc" ;
			if( m._name == n) {
				m.gotoAndStop(infos[0]) ;
				
				infos.shift() ;

				if (infos.length > 0) {
					apply(m, infos) ;
				} 
			}
		}
	}
}

/*

function _setPnj(s) {	
	var infos = s.split(";") ;
	var nmc = ["_pnj", "_p", "_f"] ;
	apply(this, infos, nmc, true) ;
	
}

function apply(mc, infos, isFirst) {
	for (var mm in mc) {
		var m = mc[mm] ;
		if (typeof m == "movieclip") {
			var n = null ;
			if (isFirst)
				n = "_p0" ;
			else 
				n = "smc" ;
			if (m._name == n) {
				m.gotoAndStop(infos[0]) ;
				
				infos.shift() ;
			
				if (infos.length > 0)
					apply(m, infos, false) ;
			}
		}
	}
}	
	*/
