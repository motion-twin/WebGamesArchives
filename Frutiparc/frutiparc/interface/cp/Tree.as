class cp.Tree extends Component{//}
	
	//CONSTANTES
	var lineSpace:Number = 14;
	
	
	//VARIABLES
	var flTreeReady:Boolean;
	var list:Array;
	var physList:Array;
	var pointer:Object;
	var def:Object;
	var bulletName:String;
	var bulletSize:Number;
	var last:MovieClip;
	
	var animList:AnimList;
	
	var marginLeft:Number;
	var offset:Number;
	var space:Number;
	
	var treeStyle:Object;
	//var depthList:DepthList;
	var depth:Number;
	
	/*-----------------------------------------------------------------------
		Format de list
			- text : String
			- list : Array
			- bulletFrame : Number ou String
			- bulletLink : String
			- action : CallBack Object
	 ------------------------------------------------------------------------*/		
	
	function Tree(){
		this.init();
	};
	
	function init(){
		//this.flTrace=true;
		this.scrollInfo = {
			link:"sbRound",
			param:{
				margin:{side:4, top:4},
				marginInside:1,
				//mainStyleName:"content",
				size:8
			}
		}		
		
		super.init();
		
		this.animList = new AnimList();
		
		this.flTreeReady=false;
		//this.depthList = new DepthList(200)
		this.depth = 0;
		
		if(this.treeStyle==undefined)this.treeStyle = Standard.getTreeStyle();
		if( this.marginLeft == undefined )	this.marginLeft = 3;
		if( this.offset == undefined )		this.offset = 8;
		if( this.space == undefined )		this.space = 1;
		if( this.bulletSize == undefined )	this.bulletSize = 10;
		
		if(this.list!=undefined){
			this.buildPhysList();
		}
		
		//_root.test+="color("+this.style.color[0]+")\n"
		
	};

	function buildPhysList(){
		this.flTreeReady=true;
		this.physList = new Array();
		for(var i=0; i<this.list.length; i++){
			//_root.test+="tree : addPhysElement("+this.list[i]+")\n"
			this.addPhysElement(this.list[i])
		}
	}
	
	function addPhysElement(box,parent){
		//_root.test+="addPhys text:"+box.text+"\n"
		//var d = this.depthList.giveDepth();
		var d = this.depth++;
		if(parent!=undefined){
			var level = parent.getLevel()+1;
		}else{
			var level = 0;
		}
		var decal = level*this.offset;
		if(box.list!=undefined)var type = "Dir"; else var type = "Exe";
		var initObj = {
			box:box,
			tree:this,
			width:this.width-(decal+this.marginLeft),
			parent:parent
		}
		this.content.attachMovie("caps"+type,"caps"+d,80000-d,initObj);
		var mc = this.content["caps"+d];
		mc.pos.x = decal + this.marginLeft;
		mc._x = mc.pos.x;
		mc._y = this.last._y+this.last.height/2
		//mc.nextY = mc._y
		if(this.last!=undefined){
			mc.moveTo(this.last.pos.y + this.last.height)
			mc.fadeIn();
			mc.id = this.last.id+1;
		}else{
			mc.moveTo(0)
			mc.id=0;
		}
		this.physList.splice(mc.id,0,mc)
		this.last = mc;
			
		// DOSSIER
		if(box.list!=undefined){
			// Ajoute les sous-elements de la liste
			if(box.flOpen){
				this.pointer.level++;
				for(var i=0; i<box.list.length; i++){
					var child = this.addPhysElement( box.list[i], mc )
					//if( i==box.list.length-1 )child.height += this.lineSpace;
				}
				this.pointer.level--;
			}
		}
		
		return mc
		
	}
	
	function toggleDir(mc){
		if(mc.box.flOpen){
			this.closeDir(mc)
		}else{
			this.openDir(mc)
		}
	}
	
	function openDir(mc){
		//_root.test+="OpenDir\n"
		this.last = mc
		
		for(var i=0; i<mc.box.list.length; i++){
			var child = this.addPhysElement(mc.box.list[i],mc)
			//if( i==mc.box.list.length-1 )child.height += this.lineSpace;			
		}

		this.recalList();
		
		mc.box.flOpen=true;
		
	}
	
	function closeDir(mc){
		//_root.test+="CloseDir("+mc.box.list.length+")\n"
		this.last = mc
		for(var i=0; i<mc.box.list.length; i++){
			this.desintegrate(this.last.id+1)
		}		
		this.recalList();
		
		mc.box.flOpen=false;
	}
	
	function desintegrate(index){
		var mc = this.physList[index]
		
		if(mc.box.flOpen){
			for(var i=0; i<mc.box.list.length; i++){
				this.desintegrate(index+1)
			}
		}		
		
		mc.kill();
		this.physList.splice(index,1)	
	}

	function recalList(){

		for(var i=last.id+1; i<this.physList.length; i++){
			var mc = this.physList[i]
			//mc._y  = this.last._y + this.last.height
			mc.moveTo( this.last.pos.y + this.last.height )
			mc.id = this.last.id+1
			this.last = mc
		}			

	}
		
	function setList(list){
		//_global.debug("setList OK, list: "+list);
		//_root.test+="[Tree] setList("+list+") this.flTreeReady("+this.flTreeReady+")\n"
		if(this.flTreeReady){
			this.cleanAll();
		}
		this.list = list;
		if(this.list != undefined){
			this.buildPhysList();
		}
	}
	
	function cleanAll(){
		//_root.test+="[Tree] cleanAll() this.physList.length:"+this.physList.length+"\n"
		while(this.physList.length>0){
			//_root.test+="[Tree] cleanAll() clean --> "+this.physList[this.physList.length-1]+"\n"
			//this.physList[this.physList.length-1].path.removeMovieClip();
			this.physList.pop().kill();
		}
		delete this.last;
	
	}
	
	function updateSize(){
		super.updateSize();
		//_root.test+="[cpTree] updateSize() width:"+this.width+" extWidth:"+this.extWidth+"\n"
	}

	
	/*
	function genTree(){
		
		this.currentLevel = 0;
		this.mark = 0
		this.physPointer = 0;
		this.addElementList(this.list)
		
	};
	
	function addElementList(l){
		for(var i=0; i<l.length; i++){
			this.addElement(l[i])
			
		}	
	}
	
	
	function addElement(o){
		
		// DOSSIER
		if( o.list != undefined ){
			this.addCapsule(o,"Dir")
			if(o.flOpen){
				this.level++
				this.addElementList(o.list)
			}
		
		// EXECUTABLE
		}else{
			this.addCapsule(o,"Exe");
		}		
	};
	
	function addCapsule(o,type){
		
		var d = this.depthList.giveDepth();
		this.content.attachMovie("capsule"+type,"caps"+d,d,{box:o,tree:this})
		var mc = this.content["caps"+d];
		mc._x = this.currentLevel*this.offset;
		mc._y = this.mark;
		

		// le mc est ajouté a la liste physique
		this.physList.splice(this.physPointer,0,mc)
		this.physPointer++;

		//Met le mark a jour
		this.mark = mc.getNextMark();
		
	};
	
	function openElement(o){
		this.mark = this.physList[o.id].getNextMark();
		this.physPointer = o.id+1
		this.addElementList(o.list);
		
	}
	
	function closeElement(o){
	}
	*/
	
	/*
	function getDirHeight(o){
		var h=0
		for(var i=0; i<o.list.length; i++){
			var obj = o.list[i];
			if(obj.ts.textFormat)
		
		}
		
	}
	*/
	
	
//{	
}

























