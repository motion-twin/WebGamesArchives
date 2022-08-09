class miniwave.box.Menu extends miniwave.Box{//}
	
	
	var bubbleSpawnMax:Number = 6;
	var bubbleSpawnAccel:Number = 0.3;
	
	// VARIABLES
	var flActive:Boolean;

	
	// PARAMETRES
	var id:Number;
	var name:String;	
	var cb:Object;
	
	
	// REFERENCES
	var label:MovieClip;
	var but:Button;
	
	function Menu(){
		this.init();
	}
	
	function init(){
		this.gw = 100;
		this.gh = 20;
		this.flActive = false;
		super.init();
		

		

	}
	
	function initContent(){
		super.initContent();

		// BUTTON
		this.attachMovie( "transp", "but", 14 )
		this.but._xscale = this.w
		this.but._yscale = this.h
		this.but.onRollOver = function(){
			this._parent.setActive(true)
		}
		this.but.onRollOut = function(){
			this._parent.setActive(false)
		}
		this.but.onDragOut = this.but.onRollOut
		
		this.but.onPress = function(){
			this._parent.select();
		}
		
	
		// ETIQUETTE
		this.attachMovie( "menuLabel", "label", 20 )
		this.label.gfx.field.text = this.name		
	
	}
	
	function removeContent(){
		super.removeContent();
		this.label.removeMovieClip();
		this.but._visible = false;	// TODO:Prendre le temps de chercher comment on vire les boutons
	}
	
	function update(){
		super.update();
		switch(this.step){
			case 2 :
				if( this.flActive ){
					this.label.nextFrame();
				}else{
					this.label.prevFrame();
				}
				break;
		}
	
	}

	function setActive(flag){
		this.flActive = flag;
		if(this.flActive){
			this.page.menu.mng.sfx.play( "sRollOver")
			this.colBack = 0xA0A0CB
			this.page.rOver(this.id)
		}else{
			this.colBack = 0xBCBCDA
			this.page.rOut(this.id)
		}
		this.colLine = 0xFFFFFF
		this.updateDraw()
		
		
		
	}
	
	function select(){
		this.page.menu.mng.sfx.play( "sMenuBeep")
		//this.mng.music.setVolume( 1, 50 )		
		this.page.select(this.id)
		//this.cb.obj[this.cb.method](this.cb.args);
	}
	
	
	
	
	
//{	
}











