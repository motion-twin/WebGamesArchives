
function _setSpirit(s) {	
	apply(this, s) ;
	
}

function apply(mc, infos) {
	for (var mm in mc) {
		var m = mc[mm] ;
		if (typeof m == "movieclip") {
			if (m._name == "_p0") {
				m.gotoAndStop(infos) ;
				return ;
			}
		}
	}
}
