class miniwave.box.Life extends miniwave.Box{//}
	
	// PARAMETRES
	var id:Number;
	var limit:Number;
	
	// VARIABLES
	
	//REFERENCES
	var panel:miniwave.panel.Life;

	
	
	
	function Life(){
		this.init();
	}
	
	function init(){
		super.init();
		this.colBack = 0x8A8ABD//0xA0A0CB//
		this.colLine = 0xFFFFFF//0xBCBCDA		
	}
	
	function update(){
		super.update();
		switch(this.step){
			case 2 :

				break;
		}		
	}
	
	function initContent(){
		super.initContent();
		this.attachMovie("miniWave2PanelLife","panel",10,{game:this.page.menu})
		this.panel._x = this.gw-6
		this.panel._y = this.gh-4
		this.panel.size = 12
	}
	
	function addLife(id){
		this.panel.addLife(id)
	}
	
	function removeContent(){
		super.removeContent();
		this.panel.removeMovieClip();
	}
	
		
		
	
//{	
}