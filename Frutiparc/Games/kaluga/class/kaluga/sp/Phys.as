class kaluga.sp.Phys extends kaluga.Sprite{//}

	// VARIABLES
	var flPhys:Boolean;
	var flLinkable:Boolean;
	
	var weight:Number;
	var power:Number;
	var nbTake:Number;
	var adr:Number;
	var range:Number;
	var fillFall:Number;
	var volume:Number;
	
	var linkList:Array;
	var tension:Object;
	
	//
	var nbResist:Number;
	var searchTimer:Number;
	
	// REFERENCES
	var parentLink:MovieClip;
	
	
	//var sound:Object;

	// A CLEANER
	var ray
	
	function Phys(){
		//this.init();
	}
	
	function init(){
		super.init();
		this.linkList = new Array();
		this.initDefault();
		this.power = 0;
		this.searchTimer = 0;
		this.tension = {x:0,y:0};
		
		//this.sound = new Sound(this)
		//this.sound.attachSound("sLink")
		
	}
	
	function initDefault(){
		super.initDefault();
		if(this.weight == undefined)		this.weight = 1;
		if(this.nbTake == undefined)		this.nbTake = 80
		if(this.flPhys == undefined)		this.flPhys = true;
		if(this.flLinkable == undefined)	this.flLinkable = true;
		if(this.adr == undefined)		this.adr = 0;
		if(this.nbResist == undefined)		this.nbResist = 1;
		if(this.range == undefined)		this.range = 1;
		if(this.volume == undefined)		this.volume = 1;
	}
	
	function update(){
		super.update();
		if(this.flPhys){
			if(!this.flGround)this.vity += this.game.grav * this.weight * kaluga.Cs.tmod;
			
			var frict = Math.pow(this.game.frict,this.volume)
			this.vitx *= frict;
			this.vity *= frict;
			
			this.x += this.vitx * kaluga.Cs.tmod;
			this.y += this.vity * kaluga.Cs.tmod;
			
			
		}
		if(this.flGround){
			// CHECK TENSION
			var pow = Math.abs(this.tension.x)+Math.abs(this.tension.y)
			if(pow>this.adr){
				this.exitGroundMode(true);
			}
			this.tension = {x:0,y:0}
		}
	}
	
	function unLink(){		// ENLEVE TOUS LES LIEN ENFANTS EN RECURSIF
		while(this.linkList.length>0){  
			var mc = this.linkList.pop(); 
			mc.unLink();
			delete mc.parentLink;
		}
	}
	
	function updateLink(tensionMax,collideList){
		// VERIFIE LES COLLISIONS AVEC LES POMMES PRECEDENTES
		if(this.flPhys){
			for(var i=0; i<collideList.length; i++){
				var mc = collideList[i]
				if( mc.flPhys && !mc.flGround ){
					var distMax = this.ray + mc.ray
					var difx = this.x - mc.x
					var dify = this.y - mc.y
					var dist = Math.sqrt((difx*difx)+(dify*dify))
					if(dist<distMax){
						var power = dist-distMax
						var a = Math.atan2(dify, difx)
						var cos = Math.cos(a);
						var sin = Math.sin(a);
						
						var p = 20
						
						this.vitx -= cos * power/p
						if(!this.flGround) this.vity -= sin * power/p
						mc.vitx += cos * power/p
						if(!mc.flGround) mc.vity += sin * power/p				
					}
				}
			}
		}
		collideList.push(this)
		
		// TENSION
		for(var i=0; i<this.linkList.length; i++){
			var mc = this.linkList[i]
			var ca = this
			var cb = mc
			var difx = ca.x - cb.x
			var dify = ca.y - cb.y
			var dist = Math.sqrt((difx*difx)+(dify*dify))
			var a = Math.atan2(dify,difx)
			if(dist>tensionMax){
				/* RECAL
				var limit = 280
				if( dist > limit ){
					dist = limit;
					mc.x = this.x - Math.cos(a)*dist;
					mc.y = this.y - Math.sin(a)*dist;
				}
				//*/
				
				var dif = (dist-tensionMax)/30;
				var cos = Math.cos(a);
				var sin = Math.sin(a);

				var wa = ca.weight + ca.power	
				var wb = cb.weight + cb.power	
				var ratio = wb/(wa+wb);
				
				var px = cos * dif * ratio
				var py = sin * dif * ratio
				
				if(ca.flGround){
					ca.tension.x += px;
					ca.tension.y += py;
				}else{
					ca.vitx -= px * ca.nbResist *kaluga.Cs.tmod;
					ca.vity -= py * ca.nbResist *kaluga.Cs.tmod;				
				}
				
				var px = cos * dif * (1-ratio)
				var py = sin * dif * (1-ratio)
				
				if(cb.flGround){
					cb.tension.x += px;
					cb.tension.y += py;
				}else{
					cb.vitx += px * cb.nbResist * kaluga.Cs.tmod;
					cb.vity += py * cb.nbResist * kaluga.Cs.tmod;				
				}
				

				
				
				mc.filFall = 0
			}else{
				mc.filFall = (tensionMax-dist)/2
			}

			
			mc.updateLink(tensionMax/2,collideList);
		}
	}

	function drawLink(){
		//return;
		for(var i=0; i<this.linkList.length; i++){
			var mc = this.linkList[i]
			
			var x1 = this.x + this.game.mapDecal.x;
			var y1 = this.y + this.game.mapDecal.y;
			var x2 = mc.x + this.game.mapDecal.x;
			var y2 = mc.y + this.game.mapDecal.y;
			/*
			var difx = x1-x2;
			var dify = y1-y2;
			var dist = Math.sqrt(difx*difx,dify*dify)
			*/
			this.game.fil.moveTo( x1, y1 );
			if(mc.filFall>0){
				var x = (x1+x2)/2;
				var y = Math.min( (y1+y2)/2 + mc.filFall*3 , (this.map.height+4)-this.map.groundLevel);
				this.game.fil.curveTo( x, y, x2, y2 );
			}
			this.game.fil.lineTo( x2, y2 );
			
			
			mc.drawLink();			
		}	
	}
	
	function onLink(parent){
		this.parentLink = parent;
		//this.fillFall = 0;
		//this.flGround=false;
		//if(this.flGround)this.exitGroundMode();
	}
	
	function removeLink(mc:kaluga.sp.Phys){	// ENLEVE UN LIEN ENFANT VERS UN MOVIE SPECIFIQUE + EFFECTUE UN UNLINK SUR CELUI CI
		for(var i=0; i<this.linkList.length; i++){
			if(this.linkList[i] == mc){
				mc.unLink();
				this.linkList.splice(i,1)
				delete mc.parentLink;
				return;
			}
		}
	}
		
	function search(combo){
		if(this.searchTimer<=0){
			var link;
			var max = this.nbTake
			if(this.linkList.length<this.range){
				for( var i=0; i<this.game.physList.length; i++){
					var mc = this.game.physList[i];
					if(mc.parentLink==undefined && mc != this && !mc.flPanier && !mc.flTree &&  mc.linkList.length==0 && mc.flLinkable){
						var difx = mc.x - this.x
						var dify = mc.y - this.y
						var dist = Math.abs(difx) + Math.abs(dify) //Math.sqrt((difx*difx)+(dify*dify));
						//var dist = this.getDist(mc)
						if(dist<max){
							link = mc;
							max = dist;
						}
					}
				}
				if(link != undefined){
					//_root.test+="found("+link+")\n"
					this.linkTo(link);
					this.searchTimer = 12//20
					link.searchTimer = 12//20;
					link.onLink(this);
				}
			}
		}else{
			this.searchTimer -= kaluga.Cs.tmod;
		}
		// Cherche les fruits deja linké pour les chaines.
		for( var i=0; i<this.linkList.length; i++ ){
			link = this.linkList[i];
			if(combo>0)link.search(combo-1);
		}		
	}	

	function initPhysMode(){
		this.flPhys = true;
	}
	
	function exitPhysMode(){
		this.flPhys = false;
	}	

	function getPower(){
		var cyn = Math.abs(this.vitx) + Math.abs(this.vity)
		return  this.weight*2 + cyn 
	}
	
	function kill(){
		if(this.parentLink){
			this.parentLink.removeLink(this)
		}
		if(this.linkList.length>0){
			this.unLink();
		}
		
		this.game.removePhys(this);
		super.kill();
	}
	
	function linkTo(link){
		this.game.mng.sfx.play("sLink")
		//this.sound.start();
		this.linkList.push(link);
		link.fillFall = 0;
	}
	
	/*
	function getMulti(){
		var m = this.nbMulti+this.bonusMulti+1
		if(m==undefined) m = 1;
		return m;
	}
	*/
	
	//{
}









