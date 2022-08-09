class kaluga.sp.Butterfly extends kaluga.Sprite{//}

	// CONSTANTES
	var margin:Number = 10
	var speed:Number = 0.15
	var shake:Number = 0//4
	var flySpeed:Number = 40
	
	
	
	// PARAMETRES
	var id:Number;
	
	// VARIABLES
	var wScale:Number;
	var mode:Number;
	var sens:Number;
	var fly:Number;
	var flySpeedMod:Number;
	
	
	// REFERENCES
	var map:kaluga.Map;
	var game:kaluga.Game;
	
	// MOVIECLIPS
	var w1:MovieClip;
	var w2:MovieClip;
	var wa1:MovieClip;
	var wa2:MovieClip;
	
	
	function Butterfly(){
		this.init();
	}
	
	function init(){
		//_root.test+="[butterfly] init()\n"
		this.type="Butterfly"
		super.init();
		this.mode = 0;
		this.sens = 1;
		this.wScale = 0;
		this.fly = 0;
		this.flySpeedMod = 0;
	}
		
	function update(){
		super.update();
		switch(mode){
			case 0:
				// BOUGE
				this.flySpeedMod += 2*((random(200)-100)/100)*kaluga.Cs.tmod
				this.flySpeedMod *= this.game.frict
				
				this.fly = (this.fly+(this.flySpeed+Math.min(0,this.flySpeedMod))*kaluga.Cs.tmod)%628
				var s = Math.cos((this.fly-314)/100)*100
				this.w1._yscale = s
				this.w2._yscale = s+random(20)-10
				this.wa1._yscale = this.wScale
				this.wa2._yscale = this.wScale
				this.vity += (s-this.wScale)/20
				this.wScale = s
			
				//
				this.vitx += (this.speed*this.sens*1.2) +  (this.speed*2.5) * (random(200)-100)/100 * kaluga.Cs.tmod
				this.vity += (this.speed*this.sens) +  (this.speed*2.5) * (random(200)-100)/100 * kaluga.Cs.tmod
				this.vitx *= this.game.frict;
				this.vity *= this.game.frict;				
				this.x += ( this.vitx + this.shake * (random(200)-100)/100	) * kaluga.Cs.tmod;
				this.y += ( this.vity + this.shake * (random(200)-100)/100	) * kaluga.Cs.tmod;
			
				this._rotation = this.vity*4*this.sens
							
				// SOL
				var gy = this.map.height-this.map.groundLevel;
				if(this.y+this.margin > gy){
					this.y = gy-this.margin;
					this.vity -= kaluga.Cs.tmod;
					//this.vity = -Math.abs(this.vity)
				}
				// SIDE
				var limitLeft = this.margin
				var limitRight = this.map.width-this.margin
				if(this.x < limitLeft){
					this.vitx = 0;
					this.x = limitLeft
					this.setSens(1)
				}
				if(this.x > limitRight){
					this.vitx = 0;
					this.x = limitRight
					this.setSens(-1)
				}
				// SKY
				if(this.y < this.margin){
					this.vity += kaluga.Cs.tmod;
				}				

				// CHANGESENS
				if( !random(300/kaluga.Cs.tmod) ) this.setSens(-this.sens)
				
				//GFX
				if( !random(50/kaluga.Cs.tmod) ) this.dropPaillette();
		
				
				
				break;
				
		
			
		}
		this.endUpdate();
	}	
	
	function dropPaillette(){
		var mc = this.game.newFX("paillette");
		this.game.particuleList.push(mc);
		/*
		var sens = random(2)*2-1
		mc.gotoAndPlay(random(40)+1)
		*/
		mc.vitx = this.vitx/2
		mc.vity = this.vity/2
		mc.x = this.x;
		mc.y = this.y;
		mc.time = 20+random(10);
		mc.mode = 0;
		mc.gotoAndStop(this.id+1)
		//_root.test+="[Bird] drop paillete("+mc+")\n"
		return mc;		
	}
	
	function setSens(sens){
		this.sens = sens
		this._xscale = this.sens*100	
	}
	
	function kill(){
		this.game.removeFromList(this,"butterflyList")
		this.removeMovieClip();
	}
		
	
	
	
	
	
	
//{	
}