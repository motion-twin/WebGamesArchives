class bar.Level extends MovieClip{

	// PARAM
	
	var fieldLevel:TextField;
	
	function Level(){
		this.init();
	}
	
	function init(){
	}
	
	function setLevel(level,xpCoef){
		//_root.test+="setLevel\n"
		// LEVEL
		this.fieldLevel.text = level
		// XP
		var h = 2
		var e = 1
		var max = 9
		for(var i=0; i<max; i++){
			var col,w;
			var dif = xpCoef-(1-(i/max))
			if(dif<0){
				if(-dif<1/max){
					col = { r:162, g:235, b:86 }
					var pos = {
						x:4,
						y:4+i*(h+e),
						w:27,
						h:h
					}
					FEMC.drawSquare(this,pos, FEObject.toColNumber(col) )
					col = { r:115, g:176, b:30 }
					w = 27 * (1-(-dif/(1/max)))					
				}else{
					col = { r:162, g:235, b:86 }
					w = 27
				}
			}else{
				col = { r:115, g:176, b:30 }
				w = 27
			}
			var pos = {
				x:4,
				y:4+i*(h+e),
				w:w,
				h:h
			}
			FEMC.drawSquare(this,pos, FEObject.toColNumber(col) )
		};
	}
	
	
	
	
}