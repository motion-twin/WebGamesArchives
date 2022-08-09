class kaluga.sp.bads.Ant extends kaluga.sp.Bads{//}
	
	// CONSTANTE
	var speed:Number = 0.3;
	var crunchSpeed = 0.0002//0.001
	
	// PARAMETRES
		
	// VARIABLES
	var mode:Number;
	var sens:Number;
	var compt:Number;
	var posList:Array;
	var timer:Number;
	var vitr:Number;
	
	var fruitPoint:Object;
	
	// REFERENCES
	var fruit:kaluga.sp.phys.Fruit;
	
	//MOVIECLIP
	
	function Ant(){
		this.init();
	}
	
	function init(){
		//_root.test+="[Ant] init("+this.mode+")\n"
		this.type = "Ant";
		this.timer = 0;
		super.init();
		this.initGroundMode();
	}
	
	function initDefault(){
		if( this.flPhys == undefined ) this.flPhys = false;
		if( this.volume == undefined ) this.volume = 0.4
		if( this.weight == undefined ) this.weight = 0.1;
		super.initDefault();
		if( this.mode == undefined ) this.mode = 0;
		if( this.vitr == undefined ) this.vitr = 0;
		
	}
	
	function update(){
		super.update()
		switch(this.mode){
			case 0: //------------------ NORMAL ------------------
				if(!this.flPhys){
					// MOVE
					this.x += this.speed * this.sens * kaluga.Cs.tmod * (this.game.debugCoef+1);
					this.updateGroundId();
					// CHECK FOR SENS
					if(this.sens == 1 && this.x>this.map.width ){
						this.setSens(-1)
					}
					if(this.sens == -1 && this.x<0 ){
						this.setSens(1)
					}
					// LOOK FOR FRUIT
					if(this.gList.length>1){
						this.fruitSeek();
					}

					
				}else{	
					// ROTATION
					this.vitr *= this.game.frict
					this._rotation += this.vitr * kaluga.Cs.tmod
					
					// GROUND
					var gy = this.map.height - this.map.groundLevel;
					if(this.y> gy){
						
						this.y = gy;
						this.vity = 0;
						this.vitx = 0;
						this.initGroundMode();
						break;
					}
					if(this.game.type=="$invasion"){
						if(this.x>this.map.width ){
							this.x = this.map.width
							this.vitx = -Math.abs(vitx)*0.9
							this.setSens(-1)
						}
						if(this.x<0 ){
							this.x = 0
							this.vitx = Math.abs(vitx)*0.9						
							this.setSens(1)
						}
					}
					
				};
				break;
			case 1:	//------------------ POMME ------------------
				this.timer -= kaluga.Cs.tmod
				if(this.timer<0){
					this.changeFruitPoint();
				}
				if(this.fruitPoint!=undefined){
					this._rotation = this._rotation*0.8 + this.fruitPoint.rot*0.2
					this.x += this.vitx;
					this.y += this.vity;
					if(Math.abs(this.x-this.fruitPoint.x)+Math.abs(this.y-this.fruitPoint.y)<1){
						delete this.fruitPoint;
						this.flFreeze=true;
					}
				}
				var crunch = this.crunchSpeed * kaluga.Cs.tmod
				this.fruit.crunch += crunch;
				this.game.stat.incVal("Quantité mangée par les fourmis",crunch*10,"gr")
				break;
		}
		//_root.test="x:"+this.x+"\ny:"+this.y+"\n"
		
		this.endUpdate();
	}
	
	function initGroundMode(){
		super.initGroundMode();
		
		if(this.game.type=="$classic"){
			var w = (this.map.width/2)
			var dist = Math.abs(this.x-w)
			if(dist>w+10){
				//_root.test += "- Meilleur lancer de fourmi -->("+(dist-w)+")\n"
				var d = Math.round((dist-w)*10)/10
				this.game.stat.bestVal( "Meilleur lancer de fourmi" , d );
				this.game.scroller.put( "Lancer de fourmi ", d+" cm" );
	
			}
		}
		this.exitPhysMode();
		this._rotation = 0;
		
	}
	
	function exitGroundMode(){
		super.exitGroundMode();
		this.initPhysMode();
	}
	
	function setSens(sens){
		//_root.test+="setSens("+sens+")\n"
		if(sens!=undefined)this.sens = sens;
		this._xscale = -100*this.sens;
	}

	function fruitSeek(){
		for(var i=0; i<this.gList.length; i++){
			var mc = this.gList[i];
			if(mc.type == "Fruit"){
				if( mc.crunch<mc.weight && mc.caterNum == 0 && !mc.flGold ){
					mc.addAnt(this);
				}
			}
		}
	}
	
	function changeFruitPoint(){
		var r = random(this.fruit.ray);
		var a = random(624)/100
		this.fruitPoint = { x:Math.cos(a)*r, y:Math.sin(a)*r };
		
		var difx = this.fruitPoint.x - this.x
		var dify = this.fruitPoint.y - this.y
		var a = Math.atan2(dify,difx)
		this.vitx = Math.cos(a) * this.speed
		this.vity = Math.sin(a) * this.speed
		this.fruitPoint.rot = a/(Math.PI/180)
		//_root.test +="[Ant] changeFruitPoint("+this.fruitPoint.x+","+this.fruitPoint.y+") this("+this.x+","+this.y+")\n"
		this.timer = random(200*kaluga.Cs.tmod); // bouge moins souvent si ca rame;
		this.flFreeze=false;
	}
	
	/* SPLASH
	function splash(){
		this.gotoAndPlay("splash");
	}
	*/
	
	function kill(){
		this.game.removeFromList(this,"antList")
		super.kill();	
	}
	
	
	
	
	
	
//{	
}














