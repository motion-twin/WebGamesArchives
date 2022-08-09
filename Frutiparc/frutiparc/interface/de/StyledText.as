class de.StyledText extends de.Field{//}

	var sid:Number;
	
	function StyledText(){
		this.init();
	}
	
	function init(){
		//_root.test+="deStyledText init\n"
		if(this.sid==undefined)this.sid=0;
		super.init()
	}

	function display(){
		if( this.style == undefined ){
			this.style = FEObject.recursiveClone(this.doc.docStyle.s[this.sid]);
			//_root.test+="this.doc.style.s("+this.doc.docStyle.s+"))\n"
		}
		super.display();
	}
//{	
}