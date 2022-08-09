class kaluga.sp.bads.Frog extends kaluga.sp.Bads{//}
	
	// CONSTANTE
	var eyeRay:Number = 1.8
	var eyeRange:Number = 400
	var eatRange:Number = 100
	var nbFrameJump:Number = 16;
	
	
		
	var defMobilite:Number = 80
	var defSensRange:Number = 400
	var defTensionMax:Number = 200;
	
	
	
	// PARAMETRES
	var mobilite:Number;
	var sensRange:Number;
	var tensionMax:Number;
	var hitPoint:Number;	
	
	// VARIABLES
	var flEating:Boolean;
	var flLostControl:Boolean;
	var flEscape:Boolean;
	var step:Number;
	var sens:Number;
	var tension:Number;
	
	
	
	// REFERENCE
	var focus:Object;
	var oldFocus:Object;
	
	// MOVIECLIP
	var h:MovieClip;
	var up:MovieClip;
	var ca:MovieClip;
	var cb:MovieClip;

	function Frog(){
		this.init();
	}
	
	function init(){
		//_root.test+="[Frog] init()\n"
		this.type = "Frog";
		super.init();
		this.flEating = false;
		this.flLinkable = false;
		this.flLostControl = false;
		this.flEscape = false;
		this.step=0;
		this.setSens(1);
		this.tension = this.tensionMax;
		this.stop();
	}
	
	function initDefault(){
		if( this.flPhys == undefined ) 		this.flPhys = false;
		if( this.weight == undefined ) 		this.weight = 0.6//1.4;
		if( this.mobilite == undefined )	this.mobilite = this.defMobilite
		if( this.sensRange == undefined )	this.sensRange = this.defSensRange
		if( this.tensionMax == undefined )	this.tensionMax = this.defTensionMax
		if( this.hitPoint == undefined )	this.hitPoint = 20;
		super.initDefault();
		
	}
	//
	function update(){
		super.update()
		
		if( this.flEating ){
			if( this.focus != undefined ) {
				var difx = this.x - this.focus.x
				var dify = this.y - this.focus.y
				var rot = Math.atan2(dify, -difx*this.sens)/(Math.PI/180)
				rot += (this._rotation +this.h._rotation) * this.sens
			}else{
				var rot = 0;
			}
			this.h.h._rotation = this.h.h._rotation*0.5 + this.getAngle(rot)*0.5
		}
		
		switch(step){
			case 0:		//{ BASE
				
				this.centerEye()
				//ESCAPE
				if(this.flEscape){
					var dif = this.x - (this.map.width/2)
					if( Math.abs(dif) > 40+this.map.width/2 ){
						this.kill();
					}else{
						this.vitx = 7*this.sens;
						this.vity = -7;
						this.initJump();
					}
					break;			
				}
				
				
				// GORGE
				if(!random(100/kaluga.Cs.tmod)){
					this.h.h.g.play();
					this.game.mng.sfx.play("sFrog")
				}
				
				// TOURNE
				
				var flNeedTurn;
				var w = this.map.width/2
				var dif = this.x-w
				
				if( !random(150/kaluga.Cs.tmod) || ( Math.abs(this.x-w) > w && dif*this.sens > 0) ){
					this.gotoAndPlay("turn")
					this.step = 3
					break;
				}			
				
				// DEPLACEMENT		
				if(!random(this.mobilite/kaluga.Cs.tmod)){
					this.vitx = this.sens*(4+random(5));
					this.vity = -(5+random(5));
					this.initJump();
					break;
				}
				
				// VUE
				if( this.focusView(this.sensRange) ){
					//_root.test = "startHunt:"
					this.step = 1;
					this.tension = this.tensionMax;
					this.oldFocus = this.focus
					break;
				}
	
				
				break;//}
			case 1:		//{ TENSION

				this.updateEye()
				
				if( this.focusView(this.sensRange) ){
					var dx = Math.abs( this.focus.x - this.oldFocus.x )
					var dy = Math.abs( this.focus.y - this.oldFocus.y )
					
					var dist = this.getDist(this.focus)
					var ratio = 1-Math.min(dist/this.sensRange,1)
					this.tension -= (dx+dy)*ratio*kaluga.Cs.tmod
				}else{
					this.tension += 6*kaluga.Cs.tmod
				}
				var frame = 20-Math.round(this.nbFrameJump*(this.tension/this.tensionMax))
				this.gotoAndStop(frame)
				
				// JUMP
				if( this.tension < 0 ){
					var difx = this.focus.x - this.x;
					var dify = this.focus.y - this.y;
					this.vity = Math.min( -8, dify/19 );
					this.vitx = difx/23;					
					this.initJump();
					break;
					//_root.test += "chasse\n"
				}
				
				// CALM
				if( this.tension > this.tensionMax ){
					this.gotoAndStop("base")
					this.step = 0;
					break;
				}

				this.oldFocus = { x:this.focus.x, y:this.focus.y }
				break;//}
			case 2:		//{ FLY
				// GFX
				
				if(!this.flLostControl && this.parentLink != undefined && this.game.tzongre.flLift && !this.flEating){
					this.flLostControl = true;
					this.gotoAndStop("linked")
				}
				
				
				if( this.flLostControl ){
					var rot = 0;
					
					var d = ( this.x - this.game.map.width/2 )/50
					
					this.up._rotation = this.vity*2		- this.vitx*2*this.sens
					this.ca._rotation = (-this.vity*2 - d)	- this.vitx*2*this.sens
					this.cb._rotation = (-this.vity*2 + d)  - this.vitx*2*this.sens
					
					var dy = (this.map.height-this.map.groundLevel)-this.y;
					if(dy<10 && this. vity>0){

						if( this.vity>8 ){
							this.hitPoint -= this.vity;
							if( this.hitPoint < 0 ){
								this.flEscape = true;
								this.flLinkable = false;
							}
							this.vity *= -0.8
						}else{
							this.parentLink.removeLink(this);
							this.flLostControl = false;
							this.land();
							break;
						}
					}			
				}else{

					// GFX
					var a = Math.atan2(-this.vity,-this.vitx)
					var rot = a/(Math.PI/180) 
					if(this.sens == 1)rot = this.getAngle(rot+180)
					var dy = (this.map.height-this.map.groundLevel)-this.y;
					var frame = 30+Math.round(Math.min( Math.max( dy/12 ,0),10))
					this.gotoAndStop(frame)
					
					if(this.vity>0){
						if(dy<10){
							rot = 0;
							this.land();
						}else if( dy<40 ){
							var c = dy/40;
							rot = rot*c;
						}
					}
					//CHECK EAT
					if( !this.flEating && this.focusView( this.eatRange ) ){
						this.eat();
					}					

				}
				
				
				this._rotation = this._rotation*0.5 + rot*0.5
				break;//}
			case 3:		//{ TURNING
			break;//}
		};
		//_root.test = "this.parentLink("+this.parentLink+")\n"
		this.endUpdate();
	}
	//

	function land(){
		this.step = 0;
		this._rotation = 0;
		this.flLinkable = false;
		this.flPhys =false;
		this.gotoAndStop("base")
		this.y = this.map.height - this.map.groundLevel;	
	}
	
	function eat(){
		this.h.h.play();
		this.flLinkable = false;
		this.flEating = true;
		this.game.onTzDeath();
		//this.game.endGame(100)
	}
	
	function crunch(){
		// PANEL
		var titleList = [
			"Miam!",
			"Crunch!",
			"Glurps!",
			"Scrounch!"
		]
		
		var msgList = [
			this.focus.name+" a été absorbé par la grenouille.",
			this.focus.name+" n'a pas éviter la langue de la grenouille.",
			"La grenouille a gobé "+this.focus.name+" en un éclair.",
			"La persévérance de la grenouille a eu raison de notre pauvre "+this.focus.name+"."
		]			
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:titleList[random(titleList.length)],
					msg:msgList[random(msgList.length)]
				}
			
			]
		}
		this.game.endPanelStart.push(obj);
		// CODE 
		this.h.h.tz.gotoAndStop(this.game.tzongreInfo.id+1)
		this.focus.kill();
		this.focus = undefined
		this.game.setCameraFocus(this);
	}
	
	function focusView(range){
	
		return this.focus!=undefined && (this.focus.x - this.x)*this.sens > 0 &&  this.getDist(this.focus)<range
	}
	
	function initJump(){
		this.flPhys = true;
		if(!this.flEscape && this.game.type == "$classic" ){
			this.flLinkable = true;
		}
		
		this.step = 2;
	}
	
	function centerEye(){
		this.h.h.o.p._x *= 0.8
		this.h.h.o.p._y *= 0.8 	
	}
		
	function updateEye(){
		var difx = this.focus.x - this.x
		var dify = this.focus.y - this.y
		var dist = Math.sqrt( difx*difx + dify*dify )
		var ratio = Math.min(dist/this.eyeRange, 1)
		var a = Math.atan2( dify, difx*(-this.sens) )
		
		this.h.h.o.p._x = this.eyeRay*ratio * Math.cos(a)
		this.h.h.o.p._y = this.eyeRay*ratio * Math.sin(a)		
	}
	
	function setSens(sens){
		if(sens!=undefined)this.sens = sens;
		this._xscale = -100*this.sens;
	}

	function turn(){
		this.setSens(-this.sens)
		this.gotoAndStop("base")
		this.step = 0;
	}
	
	
	//
	function kill(){
		this.game.removeFromList(this,"frogList")
		super.kill();	
	}
	
	
	// UTILS
	function getAngle(a){
		while(a<-180)a+=360;
		while(a>180)a-=360;
		return a;
	}
	

	
//{	
}
