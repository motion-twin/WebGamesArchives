class miniwave.page.Option extends miniwave.Page{//}

	/*
	
	- TOUCHES CLAVIERS :
		GAUCHE
		DROITE
		TIR
		SUPER ATTAQUE
	- MUSIC ON/OFF
	- SFX ON/OFF
	- PARTICULE ON/OFF
	
	
	*/
	
	
	
	var box:miniwave.box.Option

	
	function Option(){
		this.init();
	}
	
	function init(){
		super.init();
	}
	
	function initBox(){
		super.initBox();
		
		var lh = 24
		
		// DECRIPTION
		var  initObj = {
			gx:0,
			gy:0,
			gw:this.width,
			gh:this.height-lh,
			waitTimer:0
		}
		this.box = this.newBox("miniWave2BoxOption",initObj)
		
		// RETOUR
		var  initObj = {
			id:100,
			gx:(this.width-100)/2,
			gy:this.height-(lh-6),
			waitTimer:18,
			name:"RETOUR"
		}
		var mc = this.newBox("miniWave2BoxMenu",initObj)		

	}
	
	function select(id){
		switch(id){
			case 100:
				this.menu.setNextPage({link:"miniWave2PageMain"})
				break;
		}
		this.menu.mng.client.saveSlot(1);
	}

//{
}