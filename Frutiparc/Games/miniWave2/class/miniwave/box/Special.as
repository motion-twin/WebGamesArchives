class miniwave.box.Special extends miniwave.Box{//}
		
	var id:Number;
	var but:Button;
	
	var illus:MovieClip;
	var mask:MovieClip;
	
	function Special(){
		this.init();
	}
	
	function init(){
		super.init();
		
		//this.illus._visible = false;
		
	}
	
	function initContent(){
		super.initContent();
		
		// BUTTON
		this.attachMovie( "transp", "but", 10 )
		this.but._xscale = this.gw
		this.but._yscale = this.gh
		this.but.onPress = function(){
			this._parent.select();
		}
		
		// ILLUSTRATION
		this.attachMovie( "specialIllustration", "illus", 6 )
		this.illus.gotoAndStop(this.id+1);
		this.createEmptyMovieClip( "mask", 7 )
		
		var is = 4
		
		miniwave.MC.drawSmoothSquare( this.mask, {x:is,y:is,w:this.gw-is*2,h:this.gh-is*2}, 0xFF0000, 10-is )
		this.illus.setMask( this.mask )
		
		
	};
	
	function removeContent(){
		super.removeContent();
		this.but._visible = false;
		this.illus._visible = false;
	};
	
	function select(){
		this.page.menu.mng.sfx.play( "sMenuBeep")
		this.page.select(id)
	}
	
	
	
//{	
}