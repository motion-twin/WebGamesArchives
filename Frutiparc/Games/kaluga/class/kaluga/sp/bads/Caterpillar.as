class kaluga.sp.bads.Caterpillar extends kaluga.sp.Bads{//}
	
	// CONSTANTE
	var speed:Number = 0.6;
	var length:Number = 36//31;
	var posListMaxLength = 20
	var growingSpeed = 0.3
	// PARAMETRES
		
	// VARIABLES
	var flPlante:Boolean;
	var flGrowing:Boolean;
	var stunTimer:Number;
	var scale:Number
	var mode:Number;
	var sens:Number;
	var compt:Number;
	
	var posList:Array;
	var anim:kaluga.FrameAnimManager;
	
	//MOVIECLIP
	var line:MovieClip;
	
	function Caterpillar(){
		this.init();
	}
	
	function init(){
		//return;
		//_root.test+="[Caterpillar] init()\n"
		this.mode = 0;
		this.type = "Caterpillar";
		this.posList = new Array();
		this.anim  = new kaluga.FrameAnimManager({end:22,root:this});
		super.init();
		this.initGroundMode();
		this.stop();
	}
	
	function initDefault(){
		if( this.flPhys == undefined ) this.flPhys = false;
		if( this.flGrowing == undefined ) this.flGrowing = false;
		if( this.weight == undefined ) this.weight = 0.8;
		if( this.volume == undefined ) this.volume = 0.8;
		if( this.adr == undefined ) this.adr = 2;
		if( this.scale == undefined ) this.scale = 100;
		super.initDefault();
	}
	
	function update(){
		//return;
		super.update()
		//_root.test+=".\n"
		switch(this.mode){
			case 0: //---------------- NORMAL --------------

				// ANIM
				this.anim.update(this.game.debugCoef+1);
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
				// GROWING
				if(this.flGrowing){
					this.scale += this.growingSpeed*kaluga.Cs.tmod;
					if(this.scale>=100){
						this.scale = 100
						this.flGrowing = false;
					}
					this.setScale(this.scale)
				}
				// UPDATE POSLIST
				this.updatePosList();

				break;
							
			case 1: //---------------- PHYS --------------
				// GROUND
				var gy = this.map.height - this.map.groundLevel;
				//var length = this.length
				if(this.y> gy){
					this.y = gy
					var power = this.getPower();
					this.vitx = 0;
					this.vity = 0;					
					//_root.test+="power("+power+")\n"
					if(this.game.type=="$caterLaunch" || power>10){
						this.initMode(2);
						this.stunTimer = (power-10)*170;
						var l = Math.min( Math.max( 0, this.length-(power-10) ), this.length )
						this.updateDraw(l)
						if(this.game.type == "$caterPlant" )this.game.onCaterCrash(power);

					}else{
						this.initMode(0);
					}
					this.initGroundMode();
					break;
				}
				// DRAW
				this.updateDraw(this.length);				
				// UPDATE POSLIST
				this.updatePosList();
				break;
			case 2: //---------------- PLANTE --------------
				this.stunTimer -= kaluga.Cs.tmod
				if( this.stunTimer<0 and this.game.type != "$caterLaunch" ){
					this.initMode(0)
				}
				break;
			case 3:	//---------------- SPLASH --------------
				break;		
				
				
		}
		this.endUpdate();
	}
	
	function updateDraw(l){

		//var l = this.length;
		var pList = new Array();
		var pos;
		var oldpos = {x:0,y:0};
		//
		for(var i=0; i<this.posList.length; i++){
			pos = new Object();
			pos.x = this.posList[i].x + oldpos.x
			pos.y = this.posList[i].y + oldpos.y;
			var difx = pos.x - oldpos.x
			var dify = pos.y - oldpos.y
			var dist = Math.sqrt( difx*difx + dify*dify)
			//l -= dist;
			if(l-dist>0){
				l-=dist;
				pList.push({x:pos.x,y:pos.y})
				oldpos = pos;
			}else{
				/*
				var coef = 1 + l/dist
				pos.x += difx*coef
				pos.y += dify*coef
				pList.push({x:pos.x,y:pos.y})
				*/
				var a = Math.atan2(dify,difx)
				pos.x = oldpos.x + Math.cos(a)*l
				pos.y = oldpos.y + Math.sin(a)*l
				pList.push({x:pos.x,y:pos.y})
				
				break;
			}
		}
		this.line.clear();
		this.line.lineStyle(6.8,0x000000)
		this.line.moveTo(0,0)		
		//_root.test=""
		/*
		for(var i=0; i<40; i++){
			this["r"+i].removeMovieClip();
		}
		var r = 0
		*/
		for(var i=0; i<pList.length; i++){
			var p = pList[i]
			this.line.lineTo(p.x,p.y)
		}
		
		this.line.lineStyle(5,0x25892B)
		this.line.moveTo(0,0)	
		for(var i=0; i<pList.length; i++){
			var p = pList[i]
			this.line.lineTo(p.x,p.y)
			/*
			r++;
			this.attachMovie("redPoint","r"+r,20000+r)
			var mc = this["r"+i]
			mc._x = p.x;
			mc._y = p.y;
			*/
		}		
		
		
		
		
	}
	
	function updatePosList(){

		for(var i=0; i<this.posList.length; i++){
			this.posList[i].y += this.game.grav * this.weight * kaluga.Cs.tmod * 2;
		}
		this.posList.unshift({x:-this.vitx,y:-this.vity});
		while( this.posList.length > this.posListMaxLength ){
			this.posList.pop();
		}

	}
	
	function initGroundMode(){
		var w = (this.map.width/2)
		var dist = Math.abs(this.x-w)
		if(dist>w+10){
			var d = Math.round((dist-w)*10)/10
			this.game.stat.bestVal( "Meilleur lancer de vers" , d )
			this.game.scroller.put( "Lancer de vers ", d+" cm" );
		}
		super.initGroundMode();
		this.exitPhysMode();
	}
	
	function exitGroundMode(){
		super.exitGroundMode();
		this.initPhysMode();

	}
	
	function initPhysMode(){
		super.initPhysMode();
		this.initMode(1)
	}
	
	function initMode(mode){
		this.exitMode(this.mode)
		switch(mode){
			case 0: //---------------- NORMAL --------------
				
				break;
			case 1:	//---------------- PHYS --------------
				this.setSens(-1)
				this.gotoAndStop("fly")
				break;

			case 2: //---------------- PLANTE --------------
				this.gotoAndStop("plante");
				//this.updateDraw();
				//this.flFreeze = true;				
				break;
			
			case 3:	//---------------- SPLASH --------------
				this.gotoAndPlay("splash");
				this.flFreeze = true;	
				break;			
		}
		this.mode = mode;
	}
	
	function exitMode(mode){
		switch(mode){
			case 0: //---------------- NORMAL --------------
				
				break;
			case 1:	//---------------- PHYS --------------
				this.line.clear();
				break;
			case 2: //---------------- PLANTE --------------
				this.line.clear();
				break;
			case 3:	//---------------- SPLASH --------------
				this.flFreeze = false;
				break;
		}	
	}	
	
	function setSens(sens){
		//_root.test+="setSens("+sens+")\n"
		if(sens!=undefined)this.sens = sens;
		this._xscale = -scale*this.sens;
	}
	
	function fruitSeek(){
		for(var i=0; i<this.gList.length; i++){
			var mc:kaluga.sp.phys.Fruit = this.gList[i];
			if(mc.type == "Fruit"){
				if( mc.weight>0.9 && (mc.holeNum == 0 || (mc.holeNum == 1 && mc.weight>1.2 )) && mc.crunch*2<mc.weight && !mc.flGold ){
					this.game.mng.sfx.play("sCrunch")
					mc.addCaterpillar();
					this.kill();
				}
			}
		}
	}
	
	function splash(){
		this.initMode(3);
	}
		
	function kill(){

		this.game.removeCaterpillar(this);
		super.kill();	
	}
	
	function setScale(scale){
		this.scale = scale
		this._xscale = -scale*this.sens;
		this._yscale = scale
	}
	
	
//{	
}














