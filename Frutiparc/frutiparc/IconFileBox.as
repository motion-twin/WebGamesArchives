/*
$Id: IconFileBox.as,v 1.23 2004/07/09 16:48:20  Exp $

Class: IconFileBox
*/
class IconFileBox{//}
	
	// CONSTANTES
	var dragDistMin:Number = 4;
	
	//
	
	static var dragEnd:Number;	

	////

	var uid:String;
	var type:String;
	var desc:Array;
	var date:String;
	
	var parent:String;
	var moving:Boolean = false;
	var path:MovieClip;
	var name:String = "";
	var from:String = "";
	var to:String = "";
	var box;
	var fbouille:String;
	var status:Object;
	var dropBox;
	var presence:Number;
	var checkDragInterval:Number
	
	var access:String;
	
	var pos:Object;
	var dragPoint:Object;
	
	function IconFileBox(obj,box){
		for(var n in obj){
			this[n] = obj[n];
		}
		
		//_global.debug("new IconFileBox({type: "+obj.type+",desc: "+obj.desc+"})");
		
		//_global.debug("IconFileBox a r�cup la date "+this.date);
		this.box = box;
		this.dropBox = this;
		
		this.name = _global.fileMng.getName(this.type,this.desc);

		if(this.type == "mail"){
			this.from = FPString.toDisplayMail(this.desc[0],"text");
			this.to = FPString.toDisplayMail(this.desc[2],"text");
		}
		
		// Frutiparc internal contact
		if(this.type == "contact" && this.name.indexOf("@") < 0){
			_global.mainCnx.atrace(this.name,this,"onStatusObj",false);
		}
		
		_global.fileMng.addListener(this.uid,this);
		
		//

		
	}
	
	function initMove(){
		this.moving = true;
		if(this.path != undefined) this.path._alpha = 50;
	}

	function click(){
		//_root.test+="click\n"
		//if(getTimer() - dragEnd < 60) return false;
		if( this.checkDragInterval != undefined ){
			//_root.test+="-("+this.checkDragInterval+")\n"
			clearInterval(this.checkDragInterval);
			delete this.checkDragInterval;
			
			if(this.box.specialClick({uid: this.uid,type: this.type,desc: this.desc,name: this.name})){
         
      }else if(this.type == "folder"){
				this.box.getList(this.uid);
			}else{
				_global.onFileClick({uid: this.uid,type: this.type,desc: this.desc,name: this.name,date: this.date,access: this.access});
			}			

		}
		

	}
	
	function pressIcon(){
		//_root.test+="pressIcon()\n"
		this.checkDragInterval = setInterval(this,"checkDrag",25)
		this.dragPoint = { x:this.path._xmouse, y:this.path._ymouse }
	}
	
	function checkDrag(){
		//_root.test+="---\n"
		var dx = this.path._xmouse - this.dragPoint.x
		var dy = this.path._ymouse - this.dragPoint.y
		var dist = Math.sqrt( dx*dx + dy*dy )
		if( dist > this.dragDistMin ){
			this.createDragIcon();
			clearInterval(this.checkDragInterval);
			delete this.checkDragInterval;
		}
	}
	
	
	function createDragIcon(mc){
		//_root.test+="createDragIcon()\n"
		if(!this.moving){
			_global.createDragIcon(this,this.path._xmouse_saved,this.path._ymouse_saved);
			this.path._visible = false;
		}
	}

	function onMoveError(){
		this.moving = false;
		this.path._alpha = 100;
	}

	function onEndDrag(){
		this.path._visible = true;
		dragEnd = getTimer();
	}
	
	function onAccess(){
		this.access = _global.servTime.toFormat("prog_server");
		this.path.onAccess(this.access);
	}
	
	function onKill(){
		if(this.type == "contact" && this.name.indexOf("@") < 0){
			_global.mainCnx.strace(this.name,this,false);
		}
		_global.fileMng.removeListener(this.uid,this);
	}

	// Only called if the current icon is an internal contact
	function onStatusObj(obj){
		if(obj == undefined) return;
		
		this.fbouille = obj.fbouille;
		this.status = obj.status;
		this.presence = obj.presence;
		
		if(this.path != undefined){
			this.path.onStatusObj(obj);
		}
	}
	
	function onDrop(ico){
		if(this.type == "folder"){
			var destUid = this.uid;
		}else{
			if(this.parent != undefined){
				var destUid = this.parent;
			}else{
				_global.debug("I'm not a folder, I don't know who's my father, what can I do ??");
				return;
			}
		}
		
		if(ico.uid == "new"){
			_global.fileMng.make(ico,destUid);
		}else{
			if(Key.isDown(Key.CONTROL)){
				_global.fileMng.copy(ico.uid,destUid);
			}else{
				_global.fileMng.move(ico.uid,destUid);
			}
		}
	}
	
	function onPath(){
		if(this.path == undefined) return;
		if(this.fbouille == undefined || this.presence == undefined) return;
		
		this.path.onStatusObj({
			fbouille: this.fbouille,
			status: this.status,
			presence: this.presence
		});
	}
//{
}
