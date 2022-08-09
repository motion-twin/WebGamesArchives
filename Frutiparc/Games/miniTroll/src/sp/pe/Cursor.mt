class sp.pe.Cursor extends sp.pe.Faerie{//}
	
	var slot:Slot;
	
	function new(){
		
		super();
		flBound = false
	}
	
	
	function update(){
		move();
		starFall(0.7)
		skin._x = x;
		skin._y = y;
	
	}
	
	
	function newPart(link,flFront){
		var d = slot.dpCursorFront;
		if(flFront) d = slot.dpCursorBack;
		return slot.newPart(link,d);
	}
	
	/*
	function setInfo(fi){
		
		//super.setInfo(fi)
	};
	//*/
	
//{
}
