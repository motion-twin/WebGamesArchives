class miniwave.box.ShipDemo extends miniwave.Box{//}
	
	// PARAMETRES
	var id:Number;
	var totalSlot:Number;
	
	// VARIABLES
	var flOver:Boolean;
	var heroList:Array;
	var starList:Array;
	
	//REFERENCES
	var slot:MovieClip;
	var mask:MovieClip;
	var hero:MovieClip;
	var but:Button;
	
	function ShipDemo(){
		this.init();
	}
	
	function init(){
		super.init();
		this.heroList = new Array();
		this.colBack = 0x8A8ABD//0xA0A0CB//
		this.colLine = 0xFFFFFF//0xBCBCDA
		
		this.starList = new Array();

		
	}
	
	function update(){
		super.update();
		switch(this.step){
			case 2 :
				for(var i=0; i<this.heroList.length; i++ ){
					var mc = this.heroList[i];
					var c = Math.pow( 0.2, Std.tmod );
					var dif = (mc.y-mc._y)*c;
					mc._y += Math.min(Math.max(-16,dif),16);
				}
				
				this.updateStars();
				
				break;
		}	
	}
	
	function initContent(){
		super.initContent();
		
		// BASE
		this.createEmptyMovieClip("slot",10)
		this.createEmptyMovieClip("mask",12)
		miniwave.MC.drawSmoothSquare( this.mask, {x:0,y:0,w:this.gw,h:this.gh}, 0xFF0000, 10 )
		this.slot.setMask( this.mask )
		this.slot.d = 10;
		
		// HERO
		this.attachHero();
		
		// BOUTON
		this.attachMovie( "transp", "but", 14 )
		this.but._xscale = this.w
		this.but._yscale = this.h
		this.but.onRollOver = function(){
			this._parent.rOver();
		};
		this.but.onRollOut = function(){
			this._parent.rOut();
		};
		this.but.onDragOut = this.but.onRollOut
		
		this.but.onPress = function(){
			this._parent.select();
		};
		
	}
	
	function select(){
		if(this.page.flActive){
			this.page.menu.mng.sfx.play( "sMenuBeep")
			this.hero.y = -120
			if(id==0){
				this.attachHero();
			}else{
				this.but._visible = false;
			}
			this.page.select(id)
		}

	};
	
	function attachHero(){
		var link = this.page.menu.mng.heroInfo[id].link
		var d = this.slot.d++
		this.slot.attachMovie( link, "hero"+d, d )
		var mc = this.slot["hero"+d]
		mc._x = this.gw/2;
		mc._y = this.gh+16;
		mc.y = this.gh-12;
		this.heroList.push(mc)	
		this.hero = mc;		
	}
	
	function removeContent(){
		super.removeContent();
		this.slot.removeMovieClip();
		this.mask.removeMovieClip();
		this.but._visible = false;
	}		
	
	function rOver(){
		this.flOver = true;
		this.page.rOver(id)
	}
	
	function rOut(){
		this.flOver = false;
		this.page.rOut(id)
	}
	
	function updateStars(){
		//_root.test = 100/this.totalSlot
		if( Std.tmod <1.3 && this.starList.length < 40/this.totalSlot ){
			var o = {
				x:random(this.gw),
				y:0,
				s:8+random(80)
			}
			this.starList.push(o);
		}
		
		
		this.slot.clear();
		this.slot.lineStyle(1,0xFFFFFF,50);
		for( var i=0; i<this.starList.length; i++ ){
			var o = this.starList[i];
			var sp = o.s*Std.tmod;
			var h = sp*3;
			
			o.y += sp;
			if( o.y-h > this.gh ){
				this.starList.splice(i,1);
				i--;
			}else{
				//_root.test+="trace("+o.x+","+o.y+","+h+")\n"
				this.slot.moveTo( o.x, o.y );
				this.slot.lineTo( o.x, o.y-h );
			}
		}
	}
	
	
	
//{	
}









