class fc.slot.Game extends fc.Slot{//}

	// CONSTANTE
	
	
	//REFERENCES
	

	
	function Game(){
		this.init()
	}
	
	function init(){
		this.col=this.root.colorSet[0];
		super.init();
		//this.genContent("panCreateGame");
	}

	function updateContent(){
		super.updateContent();
	}

	function toggle(){
		//_root.test+="toggle this.flOpen("+this.flOpen+") type("+this.type+")\n"
		if( !this.flOpen && this.type==undefined ){
			//_root.test+="the time is now !\n"
			 this.root.manager.initDefaultGamePanel();
		}else{
			super.toggle()
			//this.room.updateSlotTarget();
		}
		
	}

//{	
}













