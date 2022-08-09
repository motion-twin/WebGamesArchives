class cp.IconList extends Component{//}

	// PARAMS
	var flExpand:Boolean;
	
	// VARIABLES
	
	var list:Array;
	var mcList:Array;
	var struct:Object;
	var callBack:Object;
	var actualWidth:Number;
	var actualHeight:Number;
	
	
	
	function IconList(){
	
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//_root.test+="newIconList("+this.struct+") struct.order("+this.struct.order+")\n"
		super.init();
		if( this.flExpand == undefined ) this.flExpand = false;
		if(this.list==undefined)this.list = new Array();
		this.mcList = new Array();
	}
	
	/*-----------------------------------------------------------------------
		Function: build()
	 ------------------------------------------------------------------------*/	
	function build(){
		//_root.test+="build("+this.template+")\n"
		for(var i=0; i<this.list.length; i++){
			this.attachIcon(i);
		}

		
	}
	
	/*-----------------------------------------------------------------------
		Function: isNot(s)
	 ------------------------------------------------------------------------*/	
	function isNot(s){
		if(s=="x")return "y";
		if(s=="y")return "x";
	}
	
	/*-----------------------------------------------------------------------
		Function: updateStruct(s)
	 ------------------------------------------------------------------------*/	
	function updateStruct(s){
		
		//_root.test+=" Et hop là ! Update de Struct("+this.struct+")\n"
		
		if(s=="x"){
			var s2="w";
			var s3="width";
		}
		if(s=="y"){
			var s2="h";
			var s3="height";
		}
		
		var long = this[s3]-this.struct[s].margin*2
		var size = this.struct[s].size+this.struct[s].space
		var max = Math.floor(long/size)						//was Math.floor(long/size)
		//_root.test+="max("+max+")\n"
		var extra = long-((max*this.struct[s].size)+((max-1)*this.struct[s].space))
		
		while(extra>size){
			max++
			extra-=size;
		}
		
		if(this.struct[s].align=="start" or this.struct[s].align=="null"){
			var corner = this.struct[s].margin;
		}else if(this.struct[s].align=="center"){
			var corner = this.struct[s].margin + extra/2;
		}else if(this.struct[s].align=="end"){
			var corner = this.struct[s].margin + extra;
		}	
		
		this.struct[s].max = max;
		this.struct[s].corner = corner;
	}
	
	/*-----------------------------------------------------------------------
		Function: alignIcon()(s)
	 ------------------------------------------------------------------------*/	
	function alignIcon(){
		//_root.test+="alignIcon("+this.struct+")\n"
		
		var id=0;
		var s = this.struct.order
		var ns = this.isNot(s)
		var maj = this.struct[s]
		var min = this.struct[ns]
		
		if(maj.sens==1){
			maj.start=0;
			maj.end=Math.max(maj.max-1,0);	
		}else{
			maj.start=maj.max-1;
			maj.end=0;
		}
		if(min.sens==1){
			min.start=0;
			min.end=min.max-1;	
		}else{
			min.start=min.max-1;
			min.end=0;
		}

		var b=0
		var posMax={x:0,y:0}
		
		if(maj.end>=0){
			while( (b*min.sens<=min.max or !this.struct.limit) and id<this.list.length ){
				var aMax=0
				for(var a=maj.start; a*maj.sens<=maj.end; a+=maj.sens){
					var pos=new Object()
					pos[s]=a;
					pos[ns]=b;
					var corner = new Object()
					corner[s]=maj.corner;
					corner[ns]=min.corner;
					
					var mc = this.list[id].path
					this.moveIcon(mc, pos, corner);
					
					
					
					id++;
					aMax++
					posMax[s] = Math.max( aMax, posMax[s] )
					//_root.test+="posMax["+s+"] = Math.max( "+aMax+", "+posMax[s]+" )\n"
					if(id==this.list.length)break;
					if(id>400){
						_root.test+="boucle infinie id:"+id+" this.list.length : "+this.list.length+"\n";
						return;
					}
				}
				posMax[ns]++;
				b+=min.sens;
				if(id==this.list.length)break;
			}
		}else{
			_root.test+=" maj.start: "+maj.start+" maj.end:"+maj.end+" sens:"+maj.sens+"\n"
			
		}
		
		this.updateActualSize(posMax);
		
	}	
		
	/*-----------------------------------------------------------------------
		Function: attachIcon(id)
	 ------------------------------------------------------------------------*/	
	function attachIcon(id){
		
		//_root.test+="attachIcon\n"
		
		var o = this.list[id]
		this.content.attachMovie(o.link,"icon"+id,id,o.param)
		o.path = this.content["icon"+id];
		//_root.test+="attachIcon("+o.param.text+")\n"
		if(o.path.flResizable){
			o.path.width = this.struct.x.size
			o.path.height = this.struct.y.size
			o.path.updateSize();
		}
		this.mcList.push(o.path)
		if(this.callBack){
			// C'est bien o.path qu'il faut passer ? Pasque y'avait "mc", mais y'a pas de variable mc par ici...
			this.callBack.obj[this.callBack.method](o.path,id);
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: moveIcon(mc,pos,corner)
	 ------------------------------------------------------------------------*/	
	function moveIcon(mc,pos,corner){
		mc._x = corner.x + pos.x*(this.struct.x.size+this.struct.x.space)
		mc._y = corner.y + pos.y*(this.struct.y.size+this.struct.y.space)
	}

	/*-----------------------------------------------------------------------
		Function: updateActualSize(pos)
	 ------------------------------------------------------------------------*/	
	function updateActualSize(pos){
		//_root.test+="updateActualSize pos("+pos.x+","+pos.y+")\n"
		this.actualWidth =	(pos.x*this.struct.x.size + (pos.x-1)*this.struct.x.space) + this.struct.x.margin*2;
		this.actualHeight =	(pos.y*this.struct.y.size + (pos.y-1)*this.struct.y.space) + this.struct.y.margin*2;
		if(this.flExpand){
			//_root._alpha= 50;
			this.min = {w:this.actualWidth, h:this.actualHeight}
		}
	}

	/*-----------------------------------------------------------------------
		Function: updateSize()
	 ------------------------------------------------------------------------*/	
	function updateSize(){
		//_global.debug("IconList.updateSize()");
	
		super.updateSize();
		this.updateStruct("x")
		this.updateStruct("y")
		this.alignIcon();
		this.checkScrollBar()
	}

	/*-----------------------------------------------------------------------
		Function: updateList()
	 ------------------------------------------------------------------------*/	
	function updateList(list){
		if(this.flWait)this.removeWait();
		this.clean();
		this.list = list;
		//this.template = template
		this.build();
	}
	
	/*-----------------------------------------------------------------------
		Function: clean()
	 ------------------------------------------------------------------------*/	
	function clean(){
		while(this.mcList.length>0)this.mcList.pop().removeMovieClip();
		/*
		for(var i=0; i<this.list.length; i++){
			this.content["icon"+i].removeMovieClip("")
		}
		*/
	}
	
	/*-----------------------------------------------------------------------
		Function: getContentBounds()
	 ------------------------------------------------------------------------*/	
	function getContentBounds(){
		return { xMin:0, xMax:this.actualWidth, yMin:0, yMax:this.actualHeight }	
	}
	
//{
}

