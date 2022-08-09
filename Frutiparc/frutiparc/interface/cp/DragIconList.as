class cp.DragIconList extends Component{//}

	// CONSTANTES
	
	// VARIABLES
	var gridSpace:Number
	var flEmpty:Boolean;
	var xMax:Number;
	var yMax:Number;
	var list:Array;
	var mcList:Array;
	var markerList:Array;
	var grid:Array;
	var animList:AnimList;
	var textColor:Number;

	var depthRun:Number
	
	function DragIconList(){
		this.init();
	}
	
	function init(){
		this.gridSpace = _global.displayParameters.icon.size.large+4
		super.init();
		this.flEmpty = true;
		this.mcList = new Array();
		this.animList = new AnimList();
		this.depthRun = 0
		// DEBUG
		this.markerList = new Array();
	}
	
	function setList(list){
		
		this.clean();
		
		this.list = list
		
		this.initGrid()
		this.fitInGrid()
		
		for(var i=0; i<this.list.length; i++){
			this.attachIcon(i)
		}
		
		this.updateIcons();
		
	};
	
	function addToList(box){
		//_root.test+=" addToList("+box+")\n"
		var n = this.list.length
		this.list.push(box)
		this.attachIcon(n)
		this.fitInGrid();
		this.updateIcons();
		//this.updateSize();
		//this.setList(this.list)
	};
	
	function removeFromList(box){			// TODO : MAJ DE LA GRID
		for( var i=0; i<this.list.length; i++){
			var o = this.list[i]
			if( o.param == box ){
				//_root.test+="--> drop("+o.path+")\n"
				o.path.removeMovieClip();
				this.list.splice(i,1)
			}
			
			
		}
	};
		
	function initGrid(){
		//_root.test+="[DragIconList] initGrid() this.width("+this.width+") this.height("+this.height+") ("+this.extWidth+")\n"
		this.grid = new Array();
		this.xMax = Math.floor( this.width / this.gridSpace );
		this.yMax = Math.floor( this.height / this.gridSpace );
		for( var x=0; x<this.xMax; x++){
			this.grid[x] = new Array();
			for( var y=0; y<this.yMax; y++){
				this.grid[x][y] = false
			}
		}
	}
	
	function fitInGrid(){
		//_root.test+="[DragIconList] fitInGrid()\n"
		var recalList =new Array();
		for(var i=0; i<this.list.length; i++){
			var o = this.list[i];
			if( o.pos != undefined ){
				
				var xm = (this.xMax-1)*this.gridSpace
				var ym = (this.yMax-1)*this.gridSpace
				
				if( o.pos.x > xm || o.pos.y > ym ){
					recalList.push({o:o,basePos:{x:o.pos.x, y:o.pos.y}})
					while( o.pos.x > xm ) o.pos.x -= this.gridSpace;
					while( o.pos.y > ym ) o.pos.y -= this.gridSpace;
					
				}else{
					this.addToGrid(o)
				}

			}else{
				o.pos = this.getNextAvailablePos()
				this.addToGrid(o)
			}
		}
		
		for(var i=0; i<recalList.length; i++ ){
			o = recalList[i].o
			o.pos = this.findNear(o.pos)
			if(!o.pos) o.pos = recalList[i].basePos
			this.addToGrid(o)
		}
		
		/* MARKER
		while(this.markerList.length>0)this.markerList.pop().removeMovieClip();
		for( var x=0; x<this.xMax; x++){
			for( var y=0; y<this.yMax; y++){
				if( this.grid[x][y] != false ){
					this.content.attachMovie("marker","marker"+x+"_"+y,1000+x*100+y)
					var mc = this.content["marker"+x+"_"+y]
					mc._x = x*this.gridSpace;
					mc._y = y*this.gridSpace;
					mc._xscale = this.gridSpace
					mc._yscale = this.gridSpace
					mc._alpha = this.grid[x][y].length*100
					this.markerList.push(mc)
				}
			}
		}
		//*/
		
	}
	
	function addToGrid(o){
		var gx = Math.round( o.pos.x / this.gridSpace )
		var gy = Math.round( o.pos.y / this.gridSpace )	
		if( this.grid[gx][gy] == false ) this.grid[gx][gy] = new Array();
		this.grid[gx][gy].push(o);	
	}
	
	function attachIcon(id){
		
		
		
		var o = this.list[id]
		o.param.id = id;
		o.param.textColor = this.textColor
		o.param.width = _global.displayParameters.icon.size.large
		o.param.height = _global.displayParameters.icon.size.large

		o.param.info = o
		o.param.iconList = this;
		this.depthRun++
		this.content.attachMovie(o.link,"icon"+this.depthRun,this.depthRun,o.param)
		o.path = this.content["icon"+this.depthRun];
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
	
	}
	
	function clean(){
		while(this.mcList.length>0)this.mcList.pop().removeMovieClip();
	}
	
	function updateSize(){
		//_root.test = "> [DragIconList] updateSize() <\n"
		super.updateSize();
		this.initGrid()
		this.fitInGrid(this.list)
		this.updateIcons();
	};
	
	function updateIcons(){
		//var dx = margin.x.min * margin.x.ratio;
		//var dy = margin.y.min * margin.y.ratio;
		for(var i=0; i<this.mcList.length; i++){
			var mc = this.mcList[i];
			mc._x = mc.info.pos.x // + dx; 
			mc._y = mc.info.pos.y // + dy;
		}
	}	
	
	function isFreePos(){
	
	}
	
	function getNextAvailablePos(){
		for( var y=0; y<this.yMax; y++){
			for( var x=0; x<this.xMax; x++){
				if( !this.grid[x][y] ){
					//_root.test+="GNAP("+x+","+y+")\n"
					return { x:x*this.gridSpace, y:y*this.gridSpace }
				}
			}
		}
	}
	/*
	function getNearest(pos){
		//_root.test+="getNearest ("+pos.x+","+pos.y+") ----> "
		var gx = Math.round( pos.x / this.gridSpace )
		var gy = Math.round( pos.y / this.gridSpace )	
		var to = 10
		var d = 0
		while ( true ){
			d++
			for(var x=gx+d; x>=gx-d; x--){
				for(var y=gy+d; y>gy-d; y--){
					if(this.grid[x][y] == false ){
						//_root.test+="("+x*this.gridSpace+","+y*this.gridSpace+")\n"
						return {x:x*this.gridSpace,y:y*this.gridSpace}
					}
				}			
			}
			if(to--<=0){
				_root.test+="[DragIconList] getNearest() loop infinie désamorçée, commandant Bumdum !\n"
				_root.test+=" nothing\n"
				return pos;
			}
			
		}
	}
	*/
 	
	function findNear(pos){
	
		var mark = new Array();
		for( var x=0; x<this.xMax; x++){
			mark[x] = new Array();
			for( var y=0; y<this.yMax; y++){
				mark[x][y] = false
			}
		}
		var x = Math.floor(pos.x/this.gridSpace)
		var y = Math.floor(pos.y/this.gridSpace)
		var result = findNearRec(x,y,0,10,mark)
		if(result==null) return false;
		return {x:result.x*this.gridSpace,y:result.y*this.gridSpace}
	}
	
	function findNearRec(x,y,d,dmax,mark) {  
		//_root.test+="("+x+","+y+","+d+")\n"
		if( this.grid[x][y] == false )  
			return { x : x, y : y, d : d }; 
		mark[x][y] = true;  
		d++;
		if( d >= dmax )
			return null;
		var min = null;  
		var o = null; 
		if( !mark[x+1][y] && x < this.xMax )  {
			min = this.findNearRec(x+1,y,d,dmax,mark); 
			if( min != null )
				dmax = Math.min(dmax,min.d);
		}
		if( !mark[x-1][y] && x > 0 ) {  
			o = findNearRec(x-1,y,d,dmax,mark); 
			if( o != null && (min == null || o.d < min.d) )  {
				min = o; 
				dmax = Math.min(dmax,min.d);
			}
		} 
		if( !mark[x][y+1] && y < this.yMax ) {  
			o = this.findNearRec(x,y+1,d,dmax,mark); 
			if( o != null && (min == null || o.d < min.d) )  {
				min = o; 
				dmax = Math.min(dmax,min.d);			
			}
		}
		if( !mark[x][y-1] && y > 0 ) {  
			o = this.findNearRec(x,y-1,d,dmax,mark); 
			if( o != null && (min == null || o.d < min.d) )  {
				min = o; 
				dmax = Math.min(dmax,min.d);
			}
		}	
	
		return min;  
	
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

