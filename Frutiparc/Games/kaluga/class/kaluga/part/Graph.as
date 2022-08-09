class kaluga.part.Graph extends kaluga.Part{//}

	var flBackground:Boolean;
	
	function Graph(){
	
	}
	
	function init(){
		_root.test += "[ PART GRAPH ] init()\n"
		this.draw();
		//this.drawBackGround();
	}
	
	function draw(){
		if(this.flBackground)this.drawBackground();
	}

	
	function modCol(nb:Number,inc,coef){

		if(inc == undefined) inc = 0; 
		if(coef == undefined) coef = 1; 
		var r = (nb >> 16) & 0xFF;
		var g = (nb >> 8) & 0xFF;
		var b = nb & 0xFF;
		//_root.test+="("+r+","+g+","+b+") -->"
		r = Math.min(Math.max(0,Math.round((r+inc)*coef)),255);
		g = Math.min(Math.max(0,Math.round((g+inc)*coef)),255);
		b = Math.min(Math.max(0,Math.round((b+inc)*coef)),255);
		//_root.test+="("+r+","+g+","+b+") -->"+FEObject.toColNumber( { r:r, g:g, b:b } )+"\n"
		return "0x"+r.toString(16)+g.toString(16)+b.toString(16)

	}

	
	/*
	function createField(mc,text,pos,depth,align){
		//_root.test+="text("+text+") depth("+depth+") position("+pos.x+","+pos.y+","+pos.w+","+pos.h+")\n"
		mc.createTextField("field"+depth, depth, pos.x, pos.y, pos.w, pos.h)
		var field = mc["field"+depth]
		field.text = text//+"cm"
		field.selectable = false;
		var tf = field.getTextFormat();
		if(align!=undefined)tf.align=align;
		tf.font = "Verdana"
		tf.size = 10;
		tf.color = 0xBAD595;
		field.setTextFormat(tf)	
		return field;
	}
	*/
	
//{
}