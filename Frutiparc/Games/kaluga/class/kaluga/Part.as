class kaluga.Part extends MovieClip{//}

	var box:Object;

	function Part(){
		//this.init()
	}
	
	function init(){

	};
	
	function drawBackground(){
		this.lineStyle(1,0xBAD595);
		this.beginFill(0xE8EFD8);
		this.moveTo( box.x,		box.y		);
		this.lineTo( box.x+box.w,	box.y		);
		this.lineTo( box.x+box.w,	box.y+box.h	);
		this.lineTo( box.x,		box.y+box.h	);
		this.lineTo( box.x,		box.y		);
		this.endFill();	
	};

	function createField(mc,text,pos,depth,align,textFormat){
		//_root.test+="text("+text+") depth("+depth+") position("+pos.x+","+pos.y+","+pos.w+","+pos.h+")\n"
		
		if(textFormat == undefined){
			textFormat = {
				font:"Verdana",
				size:10,
				color:0xBAD595
			}
		}
		
		
		mc.createTextField("field"+depth, depth, pos.x, pos.y, pos.w, pos.h)
		var field = mc["field"+depth]
		field.text = text//+"cm"
		field.selectable = false;
		var tf = field.getTextFormat();
		for( var elem in textFormat ){
			tf[elem] = textFormat[elem]
		}
		
		
		if(align!=undefined)tf.align=align;
		/*
		tf.font = "Verdana"
		tf.size = 10;
		tf.color = 0xBAD595;
		*/
		field.setTextFormat(tf)	
		return field;
	}
	
//{	
}