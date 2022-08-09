// 19 petits carrés de compilation

class TextInfo{//}

	var textFormat:Object;
	var fieldProperty:Object;
	var pos:Object;

	
	/*-----------------------------------------------------------------------
		Function: TextInfo()
		constructeur
	------------------------------------------------------------------------*/	
	function TextInfo(ts){
		this.init(ts);
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(ts){
		
		if(ts==undefined){
			//if(this.flTrace)_root.test+="!!!\n";
			var tsg = Standard.getTextStyle()
			this.fieldProperty =	 tsg.def.fieldProperty;
			this.textFormat =	 tsg.def.textFormat;
			
		}else{
			this.fieldProperty =	 ts.fieldProperty;
			this.textFormat =	 ts.textFormat;
		}

		//_root.test+= "this.fieldProperty: "+this.fieldProperty+"\n"
		//_root.test+= "this.textFormat: "+this.textFormat+"\n"
		
		if(this.pos == undefined){
			this.pos = {x:0,y:0,w:80,h:10}
		}		
	}
	
	/*-----------------------------------------------------------------------
		Function: attachField(target,name,depth)
	------------------------------------------------------------------------*/	
	function attachField(target,name,depth){
		target.createTextField(name,depth,this.pos.x,this.pos.y,this.pos.w,this.pos.h);
		var mc = target[name];
		FEObject.addObject(mc,this.fieldProperty,true);
		var tf = new TextFormat();
		for(var element in this.textFormat){
			tf[element] = this.textFormat[element];
		}
		mc.setNewTextFormat(tf);

		return mc;
	}
	
//{
}

