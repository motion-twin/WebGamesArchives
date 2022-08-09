class cp.IconListFile extends cp.IconList{//}
	
	//var dp_wait:Number = 4152;
	
	//var struct;
	//var flWait:Boolean;
	var animList:AnimList;
	var template:String;
	var templateInfo:Object;
	var textColor:Number;
	
	
	
	/*-----------------------------------------------------------------------
		Function: IconListFile()
		constructeur
	 ------------------------------------------------------------------------*/	
	function IconListFile(){
		//_global.debug("Je reçois cette list: "+this.list);
		//this.flWait=true;
		this.init();
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//_root.test+="IconListFile init\n"
		if(this.struct==undefined){
			this.struct = Standard.getStruct();
			this.struct.x.margin = 100;
			this.struct.y.margin = 100;
		}
		super.init();
		this.animList = new AnimList();
		/*
		if( this.textColor == undefined )
			this.textColor = _global.wallPaper.txtColor;
		*/
		if( this.textColor == undefined ) this.textColor = this.win.style[this.mainStyleName].color[0].darkest;
		
	}
	

	function updateSize(){
		this.clear();
		super.updateSize();
		
		if( this.template == "mail" ){
			this.struct.x.size = this.width-(40+this.struct.x.margin*2);
			this.templateInfo.bonus = this.width - this.templateInfo.total
			
			//_root.test+="this.struct.x.size("+this.struct.x.size+")\n"
			// TRACAGE DES limites
			
			var inc = this.struct.y.size + this.struct.y.space
			var h = ( this.struct.y.margin + inc ) - 2
			while(h<this.height){
				var pos = { x:0, y:h, w:this.width, h:1}
				FEMC.drawSquare(this,pos,this.style.color[0].shade)
				h += inc
			}
			
			var index = 0
			var w = this.templateInfo.supList[0].min
			
			while(w<this.width and index<this.templateInfo.supList.length){
				var pos = { x:w, y:0, w:1, h:this.height}
				FEMC.drawSquare(this,pos,this.style.color[0].shade)
				index++
				var info = this.templateInfo.supList[index]
				w += info.min
				if(info.big)w+=this.templateInfo.bonus;
			}
			
			for(var i=0; i<this.mcList.length; i++){
				var mc = this.mcList[i];
				mc.display();
			}

			
			
		}
		
		
		
		
	}

	/*-----------------------------------------------------------------------
		Function: attachIcon(id)
	 ------------------------------------------------------------------------*/	
	function attachIcon(id){
		
		

		var o = this.list[id]
		o.param.id = id;
		o.param.textColor = this.textColor
		o.param.width = this.struct.x.size
		o.param.height = this.struct.y.size
		//_root.test+="o.link("+o.link+")\n"
		// 
		o.param.iconList = this;
		this.content.attachMovie(o.link,"icon"+id,id,o.param)
		o.path = this.content["icon"+id];
		o.param.path = o.path;		// ? ca sert  a quoi ? ; Réponse: ça me fait arriver le path dans un objet ailleurs... faudra nettoyer ça un jour...
		this.mcList.push(o.path)
		//_root.test+="attachFileIcon("+o.link+")\n"
		
		o.path.setButtonMethod("onRelease",o.param,"click");
		o.path.setButtonMethod("onPress",o.param,"pressIcon",o.param);
		//o.path.setButtonMethod("onDragOut",o.param,"createDragIcon",o.param);
		
		if(o.path.flButton){
			if(o.path.flSaveMousePos){
				o.path.setButtonMethod("onPress",FEMC,"saveMousePos",o.path);
			}
			o.path.setButtonMethod("onRollOver",this,"playAnimRollOver",o.path);
			o.path.setButtonMethod("onRollOut",this,"playAnimRollOut",o.path);
			o.path.setButtonMethod("onDragOut",this,"playAnimRollOut",o.path);
			o.path.setButtonMethod("onRelease",this,"playAnimRollOut",o.path);
		}
	
		if(o.param.moving){
			o.path._alpha = 50;
		}
	
		if(this.callBack){
			// C'est bien o.path qu'il faut passer ? Pasque y'avait "mc", mais y'a pas de variable mc par ici...
			this.callBack.obj[this.callBack.method](o.path,id);
		}
	}

	/*-----------------------------------------------------------------------
		Function: updateList()
	 ------------------------------------------------------------------------*/	
	function updateList(list,template,templateInfo){
		this.template = template;
		this.templateInfo = templateInfo;
		if(this.template=="normal"){
			this.struct.x.size= _global.displayParameters.icon.size.large;
			this.struct.x.space=8;
			this.struct.x.margin=10;
			this.struct.y.size= _global.displayParameters.icon.size.large;
			this.struct.y.space=8;
			this.struct.y.margin=10;
		}else if(this.template=="small"){
			this.struct.x.size=18;
			this.struct.x.space=4;
			this.struct.x.margin=10;
			this.struct.y.size=100;
			this.struct.y.space=8;
			this.struct.y.margin=10;
		}else if(this.template=="mail"){
			//this.struct.x.size=400;
			this.struct.x.size = 400//this.width-this.struct.x.margin*2;
			this.struct.x.space=8;
			this.struct.x.margin=4;
			this.struct.y.size=18;
			this.struct.y.space=4;
			this.struct.y.margin=4;
			
			var total = 0;
			for(var i=0; i<this.templateInfo.supList.length; i++)total+=this.templateInfo.supList[i].min;
			this.templateInfo.total = total
			
			
	
		}
		
		
		//_root.test+="list("+list+")\n"
		
		super.updateList(list);
	}

	/*-----------------------------------------------------------------------
		Function: playAnimRollOver(mc)
	 ------------------------------------------------------------------------*/	
	function playAnimRollOver(mc){
		this.animList.addPlayFrame("move_"+mc.id,mc.ico.s1.s2,{end: 8,sens: 1,speed: 2});
	};

	/*-----------------------------------------------------------------------
		Function: playAnimRollOut(mc)
	 ------------------------------------------------------------------------*/	
	function playAnimRollOut(mc){
		this.animList.addPlayFrame("move_"+mc.id,mc.ico.s1.s2,{end: 1,sens: -1,speed: 2});
	};

	/*-----------------------------------------------------------------------
		Function: playAnimDragRollOver(mc)
	 ------------------------------------------------------------------------*/	
	function playAnimDragRollOver(mc){
		this.animList.addPlayFrame("move_"+mc.id,mc.ico.s1.s2,{end: 15,sens: 1,speed: 2});
	};

	


	
	
	
	
//{
}


