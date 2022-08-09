class Hole extends MovieClip{//}
	
	var doorNb:Number;
	var size:Number;
	var doorList:Array;
	var ecartOpen:Number;
	var flOpen:Boolean;
	var flDoor:Boolean;
	var flAnim:Boolean;
	var id:Number;
	
	var doors:MovieClip;
	var animList:AnimList;
	var mask:MovieClip;
	var rond:MovieClip;
	var picture:MovieClip;
	var halo:MovieClip;
	var but:Button;
	var slurp:MovieClip;
	
	function Hole(){
		this.init();
	}
	
	function init(){
		this.animList = new AnimList();
		this.flOpen = false;
		this.flDoor = false;
		this.flAnim = false;
		if(this.id==undefined)this.id = random(2)+1;
		if(this.ecartOpen==undefined)this.ecartOpen = (size/2)-8
		this.attachMovie("picture","picture",1)
		this.picture._width = this.size;
		this.picture._height = this.size;
		this.picture._x = this.size/2;
		this.picture._y = this.size/2;
		this.picture.gotoAndStop(this.id)
		
		this.picture.holeObj = this;
		this.picture.onPress = function(){
			this.holeObj.onClick();
		}
		//this.toggleDoor();
		
		// green
		if(id == 1){
			_global.dragListener.addListener("alltype",{obj: this,startMethod: "onStartDragTarget",stopMethod: "onEndDragTarget"});
			
			// TODO: synchroniser pour connaitre l'uid de la recyclebin !
			//_global.fileMng.addListener("blacklist",this);
		// black
		}else if(id == 2){
			_global.dragListener.addListener("contact",{obj: this,startMethod: "onStartDragTarget",stopMethod: "onEndDragTarget"});
			_global.fileMng.addListener("blacklist",this);
		}else{
			// todo
		}
	}
		
	function initDoor(){
		this.attachMovie("slurpHalo"+this.id,"halo",3)
		this.halo._x = this.size/2;
		this.halo._y = this.size/2;
		this.halo._width = this.size-7;
		this.halo._height = this.size-7;
		this.halo.dropBox = this;		
		//FEMC.setPColor(this.halo,0x401c5e,20)
		//
		this.doorList = new Array();
		this.createEmptyMovieClip("doors",10);
		for( var i=0; i<this.doorNb; i++){
			//_root.test+="initDoor\n";
			var mc = this.createDoor(i,0)
			this.doorList.push(mc)
			
			if(i==0){
				var mc2 = this.createDoor(i,1000)
				mc.followList=[mc2]
			}else if(i==this.doorNb-1){
				this.doors.createEmptyMovieClip("dMask",this.doorNb);
				var mc2 = this.doors.dMask
				mc2._x = this.size/2;
				mc2._y = this.size/2;
				var pos ={ x:-100, y:-50, w:100, h:100 };
				FEMC.drawSquare( mc2, pos, 0xFF0000 );
				mc2._rotation = i*(360/this.doorNb)
				//this.doors.d1000._visible=false;
				this.doors.d1000.setMask(this.doors.dMask)
				mc.followList=[this.doors.dMask]
			}			
		}
		
		this.attachMovie("rond","mask",12)
		this.mask._xscale = this.size-6;
		this.mask._yscale = this.size-6;
		this.mask._x = this.size/2
		this.mask._y = this.size/2
		this.doors.setMask(this.mask)
		this.flDoor=true;
	}
	
	function detachDoor(){
		this.halo.removeMovieClip()
		this.doors.removeMovieClip();
		this.mask.removeMovieClip()
		this.flDoor=false;
	}
		
	function createDoor(i,d){
		this.doors.createEmptyMovieClip("d"+(i+d),i+d);
		var mc = this.doors["d"+(i+d)];
		mc._x = this.size/2;
		mc._y = this.size/2;
		//PICTURE
		mc.attachMovie("picture","picture",1);
		mc.picture.gotoAndStop(this.id)
		mc.picture._width = this.size;
		mc.picture._height = this.size;		
		//MASK
		mc.createEmptyMovieClip("mask",2);
		var pos ={ x:-100, y:-50, w:100, h:100 };
		FEMC.drawSquare( mc.mask, pos, 0xFF0000 );
		mc.mask._rotation = i*(360/this.doorNb);
		mc.picture.setMask(mc.mask);
		
		//SIDE
		/*
		mc.picture.createEmptyMovieClip("side",1);
		var pos ={ x:-1, y:-50, w:1, h:100 };
		FEMC.drawSquare( mc.picture.side, pos, 0x000000 );
		mc.picture.side._rotation = mc.mask._rotation
		//mc.picture.side._alpha = 0;
		*/
		//ANIM
		var a = (i*((2*Math.PI)/this.doorNb))
		mc.open = {
			x:(size/2)-this.ecartOpen*Math.cos(a),
			y:(size/2)-this.ecartOpen*Math.sin(a)
		}
		return mc;
	}
	
	function toggleDoor(){
		//_root.test+="toggleDoor\n"
		if(this.flOpen){
			this.closeDoor();
		}else{
			this.openDoor();
		}
		//this.flOpen = !this.flOpen
	}
	
	function openDoor(){
		if(!this.flDoor){
			this.initDoor();
		}
		for( var i=0; i<this.doorList.length; i++){
			var mc = this.doorList[i];
			mc.pos = {x:mc.open.x,y:mc.open.y}
			this.animList.addSlide("slide"+i,mc)
		}
		this.flOpen=true;
	}
	
	function closeDoor(){
		for( var i=0; i<this.doorList.length; i++){
			var mc = this.doorList[i];
			mc.pos = {x:size/2,y:size/2}
			this.animList.addSlide("slide"+i,mc,{obj:this,method:"detachDoor"})
			//mc.picture.side._alpha = 0;
		}
		this.flOpen=false;
	}
	
	function kill(){
		this.removeMovieClip("")
	}
	
	function eatIcon(ico){
		/*
		_root.test+="eatIcon("+ico+")\n"
		for(var elem in ico){
			_root.test+="- "+elem+" = "+ico[elem]+"\n"
		}
		*/
		if(ico.type == "contact" && FEString.endsWith(ico.desc[0],"@frutiparc.com")){
			this.eatFrutibouille(ico.fbouille);
			return;
		}
		this.slurpInit();
		//
		// TODO
		//
		this.slurpLaunching();
	}
	
	function eatFrutibouille(id){
		_root.test+="eatFrutibouille\n"
		//
		this.slurpInit();
		//
		this.slurp.attachMovie("frutibouille","fb",1,{id:id});
		this.slurp.fb._xscale = this.size-8;
		this.slurp.fb._yscale = this.size-8;
		this.slurp.fb._x = -(this.size-8)/2;
		this.slurp.fb._y = -(this.size-8)/2;
		//
		this.slurpLaunching();
	}
	
	function slurpInit(){
		this.flAnim = true;
		this.createEmptyMovieClip("slurp",5);
		this.slurp._x = this.size/2;
		this.slurp._y = this.size/2;
	}
	
	function slurpLaunching(){
		this.slurp.rot = 1;
		this.animList.addAnim("slurp",setInterval(this,"slurpTurn",25))
	}
	
	function slurpTurn(){
		this.slurp.rot *= Math.pow(1.1,_global.tmod)
		this.slurp._rotation += slurp.rot*_global.tmod
		this.slurp._alpha = 100-this.slurp.rot
		if(this.slurp.rot>100){
			this.animList.remove("slurp");
			this.slurp.removeMovieClip("");
			this.flAnim=false;
			this.closeDoor();
		}
	}
	
	function onStartDragTarget(){
		if(!this.flOpen){
			this.openDoor();
		}
	}

	function onEndDragTarget(){
		if(this.flOpen and !this.flAnim){
			this.closeDoor();
		}
	}

	function onDrop(obj){

		_global.debug("onDrop: "+obj.uid);
		
		// green
		if(this.id == 1){
			var destUid = _global.fileMng.recyclebin;
			
		// black
		}else if(this.id == 2){
			var destUid = "blacklist";

		}else{
			// TODO
		}

		if(obj.uid == "new"){
			_global.fileMng.make(obj,destUid);
		}else{
			if(Key.isDown(Key.CONTROL)){
				_global.fileMng.copy(obj.uid,destUid);
			}else{
				_global.fileMng.move(obj.uid,destUid);
			}
		}
		
		//
		
		
		
	}
	
	function addFile(obj){
		var ico = new IconFileBox(obj);
		// TODO: jouer anim de quand un fichier arrive !
		// ico est un objet qu'on peut passer pour initialiser un icone
		// Ne fonctionne qu'avec la liste noire pour le moment
		
		// J'ai mis eatIcon paske je crois que c'est ça qu'il faut mettre, je sais pas trop moi...
		this.eatIcon(ico);
	}
	
	
	// TODO: appeler cette fonction (ou alors mettre ça ailleurs)
	function onClick(){
		if(this.id == 1){
			_global.explorerMng.open(_global.fileMng.recyclebin);
		}else if(this.id == 2){
			_global.explorerMng.open("blacklist");
		}else{
		 	// TODO
		}
	}
	
//{	
}








