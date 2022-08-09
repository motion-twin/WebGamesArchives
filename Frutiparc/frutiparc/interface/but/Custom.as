class but.Custom extends But{//}

	/*-----------------------------------------------------------------------
		Function: Custom()
		constructeur
	------------------------------------------------------------------------*/		
	function Custom(){
		this.init()
	}
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		//_root.test+="initButCustom\n"
		if(this.frameDecal==undefined)this.frameDecal=0;
		this.initCustomMode()
		super.init();
		this.defineCustomAction()	
	}
//{
}

