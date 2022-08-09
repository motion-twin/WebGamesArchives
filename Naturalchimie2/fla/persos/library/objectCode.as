
function _set(s) {	
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
				
				if (infos.length > 0)
					apply(m, infos) ;
			}
		}
	}
}
/*
function apply(mc, infos, n) {
	if (n == infos.length)
		return ;
	
	for (var mm in mc) {
		var m = mc[mm] ;
		if (typeof m == "movieclip") {
			if( e._name == "_p" + n) {
				m.gotoAndStop(infos[n+1]) ;
				apply(m, infos, n++) ;
			}
		}
	}
}*/