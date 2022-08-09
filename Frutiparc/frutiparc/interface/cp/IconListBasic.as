class cp.IconListBasic extends cp.IconList{//}

	/*-----------------------------------------------------------------------
		Function: IconListBasic()
	 ------------------------------------------------------------------------*/	
	function IconListBasic(){
		//_root.test =">"+FEObject.toString(this.struct)+"\n";
		/*
		for( var a in this.struct){
			_root.test+="struct."+a+" = "+this.struct[a]+"\n"
		}
		*/
		//_root.test+="newBasicIconList("+this.struct+") struct.order("+this.struct.order+")\n"
		this.init()
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		super.init()
		this.build();
	}
//{
}
