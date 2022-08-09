/*
$Id: Frame.as,v 1.42 2004/07/20 15:02:20  Exp $

Class: Frame
*/
dynamic class Frame{//}

	var flWallpaper:Boolean;
	var flRestart:Boolean;
	var flBackground:Boolean;
	//var bgInfo:Object;
	//var mainStyleName:String;
	var style:Object;
	
	var mainStyleName:String;
	var pos:Object;
	var list:Array;
	var minInt:Object;
	var min:Object;
	var margin:Object;
	var marginInt:Object;
	var bigFrame:Frame;
	var path:MovieClip;
	var type:String;
	var root:MovieClip;
	var parent:Frame;
	var win:MovieClip;
	var args:Object;
	var name:String;
	var dropBox:Object;
	
	var decalx;
	var decaly;
	
	var bg:MovieClip;
	
	var flTrace:Boolean;
	
	/*-----------------------------------------------------------------------
		Function: Frame()
	------------------------------------------------------------------------*/	
	function Frame(params){
		this.init(params);
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/		
	function init(params){
		//if(this.flTrace)_root.test+="initTrace\n";
		
		FEObject.addObject(this,params);
		
		// Background de la frame
		if(this.flBackground==undefined){
			this.flBackground=false;
		}
		if(this.mainStyleName==undefined)this.mainStyleName="frDef";
		this.style = this.win.style[this.mainStyleName];
		root.test+="aaa\n"

		if(this.dropBox==undefined)this.dropBox = this.win.box;
		if(this.args==undefined)this.args=new Object();
		
		this.pos = new Object();
		this.list = new Array();
		this.minInt = {w:0,h:0};
		//determine un taille minimum par defaut
		if(this.min == undefined ){
			this.min = {w:0,h:0};
		}
		//determine une marge par defaut
		if( this.margin == undefined ){
			this.margin = Standard.getMargin();
		}	
		if( this.marginInt == undefined ){
			this.marginInt = Standard.getMargin();
		}
	}

	/*-----------------------------------------------------------------------
		Function: newElement(e,index)
		Cr�� une nouvelle frame a l'interieur de la frame actuelle.
		Cette frame sera positionn�e en fonction de l'index.
		Arguments:
		- e: objet regroupant les infos necessaire a la cr�ation
		- index: Number    -> Place la frame a l'index indiqu�
			 String    -> Place la frame juste apres la frame nomm�e.
			 undefined -> Place la frame a la fin de la liste.
	 ------------------------------------------------------------------------*/		
	function newElement(e,index){

		e.root = this.root
		e.parent = this
		e.win = this.win
		
		var frame = new Frame(e);
		this[e.name] = frame;
		if(index==undefined){
			this.list.push(frame)
		}else if(typeof index == "number"){
			this.list.pushAt(index,frame)
		}else if(typeof index == "string"){
			this.list.pushAt(this.getIndex(index)+1,frame) // Skool: tient, �a avait pas �t� test� �a :) le ",frame" avait �t� oubli�
		}
		frame.display();
		return frame.path;
	};
	
	/*-----------------------------------------------------------------------
		Function: addElement(frame,index)
		Ajoute une frame d�j� pre-existante.
		Arguments:
		- frame: Objet Frame a placer
		- index: positionnement de la Frame dans la liste.
	 ------------------------------------------------------------------------*/		
	function addElement(frame,index){
		this[frame.name] = frame
		if(index==undefined){
			this.list.push(frame)
		}else if(typeof index == "number"){
			this.list.pushAt(index,frame)
		}else if(typeof index == "string"){
			this.list.pushAt(this.getIndex(index)+1,frame)
		}
	}

	/*-----------------------------------------------------------------------
		Function: removeElement(name)
		D�truit la frame nomm�e.
		Arguments:
		- name: nom de la frame
	 ------------------------------------------------------------------------*/		
	function removeElement(name){
		var frame = this[name];
		if(frame.flBackground){
			//_root.test+="removeBg("+frame.bg+")\n"
			frame.bg.removeMovieClip("");
		}
		if(frame!=undefined){
			var index = this.getIndex(name)
			frame.removeAll();
			if(this.bigFrame == frame)this.bigFrame=undefined;
			this.list.splice(index,1)
			delete this[name];
		}

	}
	
	/*-----------------------------------------------------------------------
		Function: removeAll()
		D�truit toutes les frames internes.
	 ------------------------------------------------------------------------*/		
	function removeAll(){
		if(this.type == "compo"){
			this.path.kill();
		}else{
			for(var i=0; i<this.list.length; i++){
				this.list[i].removeAll();
			}
		}
	}

	/*-----------------------------------------------------------------------
		Function: applyAll(action)
		Applique une action particuliere pour chaque frame interne
		Arguments:
		- action: String definissant une action.
	 ------------------------------------------------------------------------*/		
	function applyAll(action){
		for(var i=0; i<this.list.length; i++){
			this.list[i][action]();
		}
	};

	/*-----------------------------------------------------------------------
		Function: display()
		affiche le contenu d'une frame
		- action: String definissant une action.
	 ------------------------------------------------------------------------*/		
	function display(){
		if(this.flBackground){
			this.initBackground();
		}
		if(this.type == "compo"){
			var d = this.root.dp_frameSetList.giveDepth();
			this.args.frame = this;
			this.args.win = this.win;
			this.root.attachMovie( this.link, "component"+d, this.root.dp_frameSet+d, this.args );
			this.path = this.root["component"+d];
		}else{
			this.applyAll("display")
		}
	};
		
	/*-----------------------------------------------------------------------
		Function: getIndex(name)
		Arguments:
		- name: String definissant le nom de la frame cibl�e.
		Returns:
		L'index de la frame nomm�e <name>
	 ------------------------------------------------------------------------*/		
	function getIndex(name){
		for(var i=0; i<this.list.length; i++){
			var frame = this.list[i]
			if(frame.name==name){
				return i;
			}
		}	
		return -1;
	}	
			
	/*-----------------------------------------------------------------------
		Function: update()
		met � jour les tailles et position des frames internes 	
	 ------------------------------------------------------------------------*/		
	function update(){
		this.flRestart = false;
		//if(this.flTrace)_root.test+="updateMinInt\n";
		this.updateMinInt();			// Met a jour la taille minimum de chaque frame en fonction de ses fils
		if(this.flRestart){
			this.update();
			return;
		}
		//if(this.flTrace)_root.test+="updateSize\n";
		this.updateSize(this.win.flTrace);	// Met a jour la taille de chaque frame en fonction de ses parents et de sa taille minimum
		if(this.flRestart){
			//_root.test+="RESTART!!\n"
			this.update();
			return;
		}
		//if(this.flTrace)_root.test+="updatePos\n";
		this.updatePos();			// Met a jour les positions des frames
		if(this.flRestart){
			this.update();
			return;
		}
		this.onUpdate();
		//_root.test+="flBg:"+this.flBackground+"\n"
	}

	/*-----------------------------------------------------------------------
		Function: updateMinInt()
		Met a jour la taille minimum de la frame en fonction de ses fils
	 ------------------------------------------------------------------------*/		
	function updateMinInt(){
		if(this.type=="compo"){
			this.minInt.w = Math.max(this.path.min.w, this.min.w) + this.margin.x.min + this.marginInt.x.min
			this.minInt.h = Math.max(this.path.min.h, this.min.h) + this.margin.y.min + this.marginInt.y.min
		}else{
			var wMax = 0;
			var hMax = 0;
			for(var i=0; i<this.list.length; i++){
				var frame = this.list[i]
				frame.updateMinInt()
				if(this.type == "w"){
					wMax = Math.max(wMax,frame.minInt.w);
					hMax += frame.minInt.h;
				}else{
					hMax = Math.max(hMax,frame.minInt.h);
					wMax += frame.minInt.w;
				}
			};
			this.minInt.w = Math.max(this.min.w, wMax) + this.margin.x.min + this.marginInt.x.min;
			this.minInt.h = Math.max(this.min.h, hMax) + this.margin.y.min + this.marginInt.y.min;
		}
	}

	/*-----------------------------------------------------------------------
		Function: updateSize()
		Met a jour la taille de chaque frame en fonction de ses parents
		et de sa taille minimum
	 ------------------------------------------------------------------------*/		
	function updateSize(flTrace){
		if(this.type=="compo"){
			this.path.extWidth = this.pos.w - ( this.margin.x.min + this.marginInt.x.min );
			this.path.extHeight = this.pos.h - ( this.margin.y.min + this.marginInt.y.min );
			this.path.updateSize();
		}else{
			var max=0;
			for(var i=0; i<this.list.length; i++){
				var frame = this.list[i]
				if(this.type=="w"){
					frame.pos.w = Math.max(this.pos.w - (this.margin.x.min+this.marginInt.x.min), frame.minInt.w);
					frame.pos.h = frame.minInt.h;
					var sens = "h";
				}else{
					frame.pos.h = Math.max(this.pos.h - (this.margin.y.min+this.marginInt.y.min), frame.minInt.h);
					frame.pos.w = frame.minInt.w;			
					var sens = "w";
				}
				// MARGE
				//frame.pos.w -= this.margin.x.min;
				//frame.pos.h -= this.margin.y.min;
				
				max+=frame.pos[sens];
				
				if(frame!=this.bigFrame){
					frame.updateSize(flTrace);
				};
			};
			if(/*this.pos[sens]>max and*/this.bigFrame!=undefined){
				if(sens=="w")var s="x"; else var s="y";
				var bonus = this.pos[sens]-(max+this.margin[s].min+this.marginInt[s].min);
				this.bigFrame.pos[sens] += bonus;
				this.bigFrame.updateSize(flTrace);
			}
		};	
	}
	
	/*-----------------------------------------------------------------------
		Function: updatePos()
		Met a jour les positions des frames
	 ------------------------------------------------------------------------*/		
	function updatePos(){
		if(this.type=="compo"){
			this.decalx = this.pos.w-(this.path.extWidth+this.margin.x.min+this.marginInt.x.min)
			this.decaly = this.pos.h-(this.path.extHeight+this.margin.y.min+this.marginInt.y.min)		
			this.path._x = this.pos.x + (this.margin.x.min*this.margin.x.ratio) + (this.marginInt.x.min*this.marginInt.x.ratio) + (this.decalx*this.margin.x.align);
			this.path._y = this.pos.y + (this.margin.y.min*this.margin.y.ratio) + (this.marginInt.y.min*this.marginInt.y.ratio) + (this.decaly*this.margin.y.align);
		}else{
			var dx = 0;
			var dy = 0;
			for(var i=0; i<this.list.length; i++){
				var frame = this.list[i]
				frame.pos.x = this.pos.x+dx+(this.margin.x.min*this.margin.x.ratio)+(this.marginInt.x.min*this.marginInt.x.ratio)//+ dx*this.margin.x.align
				frame.pos.y = this.pos.y+dy+(this.margin.y.min*this.margin.y.ratio)+(this.marginInt.y.min*this.marginInt.y.ratio)//+ dy*this.margin.y.align
				frame.updatePos();
				
				if(this.type == "w"){
					dy+=frame.pos.h
				}else{
					dx+=frame.pos.w
				}
			};
		}
		if(this.flBackground){
			this.drawBackground();
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: initBackground()
	 ------------------------------------------------------------------------*/		
	function initBackground(){
		var d = this.win.frameBg.depth++
		this.win.frameBg.createEmptyMovieClip("bg"+d,d);
		this.bg = this.win.frameBg["bg"+d]
		//_root.test+=" initBackground this.dropBox"+this.dropBox+"\n"
		this.bg.dropBox = this.dropBox;
		
	}
	
	/*-----------------------------------------------------------------------
		Function: drawBackground()
	 ------------------------------------------------------------------------*/		
	function drawBackground(){
		this.bg.clear();
		//this.background.clear();
		//_root.test+="this.drawBackground("+flTest+")\n"
		var p = {
			x:this.pos.x + (this.margin.x.min*this.margin.x.ratio),
			y:this.pos.y + (this.margin.y.min*this.margin.y.ratio),
			w:this.pos.w - this.margin.x.min,
			h:this.pos.h - this.margin.y.min
		};
		
		var info = {
			inline:2,
			outline:2,
			curve:3,
			color:{
				main:		this.style.color[0].main,
				inline:		this.style.color[0].shade,
				outline:	this.win.style.global.color[0].shade
			}	
		}
		var s = this.style;
		if(s.bgInfo!=undefined){
			for(var elem in s.bgInfo){
				info[elem] = s.bgInfo[elem]
			}
		}

		//this.bg.drawCustomSquare(p,info);
		FEMC.drawCustomSquare(this.bg,p,info,true)	

		if( this.flWallpaper && this.bg.wp._width>0 ){
			p.x += info.inline;
			p.y += info.inline;
			p.w -= info.inline*2;
			p.h -= info.inline*2;
			// MASK
			this.bg.wpMask.clear()
			FEMC.drawSmoothSquare( this.bg.wpMask, p, 0xFFFF0000, 3)
			// POS BG
			this.bg.wp._x = p.x
			this.bg.wp._y = p.y
			
			//*
			var c1 = p.w/this.bg.wp.img._width
			var c2 = p.h/this.bg.wp.img._height
			
			var c = Math.max( c1, c2 )
			
			this.bg.wp._xscale = c*100
			this.bg.wp._yscale = c*100
			//*/
			
			
		}
		
	}
		
	function setWallpaper( url, prc ){
		//_root.test += "[Frame] setWallpaper("+url+","+prc+")\n"
		//prc = 90
		
		if( url == undefined ){
			this.bg.wp.removeMovieClip()
			this.bg.wpMask.removeMovieClip()
			this.flWallpaper = false;
			return;
		}
		
		this.flWallpaper = true;
		this.bg.createEmptyMovieClip("wp",10)
		this.bg.createEmptyMovieClip("wpMask",11)
		this.bg.wp.createEmptyMovieClip("img",1)
		this.bg.wp.setMask(this.bg.wpMask)
		
		
		//*
		
		var mcl = new MovieClipLoader();
		var listener = new Object();
		listener.me = this;
		/*
		listener.onLoadInit = function (mc){_root.test+="WallPaper mcl init()\n"}
		listener.onLoadError = function (mc,error){_root.test+="WallPaper mcl error("+error+")\n"}
		*/
		listener.onLoadComplete = function (mc){
			
			this.flComplete = true
			if(this.flInit)this.me.wallpaperReady();
		}
		listener.onLoadInit = function (mc){
			
			this.flInit = true
			if(this.flComplete)this.me.wallpaperReady();
		}		
		
		mcl.addListener( listener )
		mcl.loadClip( url, this.bg.wp.img )
		
		
		// TEINTE
		FEMC.setPColor( this.bg.wp, this.style.color[0].main, (100-prc) )
		
		//*/
	}
	
	function wallpaperReady(){
		this.bg.wp.img.dropBox = this.win.box;
		this.drawBackground();
	}
	
	/*-----------------------------------------------------------------------
		Function: traceList(niv) *DEBUG*
		Trace l'arborescence d'une liste de frame de maniere recurcive
		Arguments :
		- niv : Number - decalage de la ligne de trace en nb d'espace
	------------------------------------------------------------------------*/		
	function traceList(niv){
		_root.test+=niv+" "+this.name+" : \n"
		for(var i=0; i<this.list.length; i++){
			this.list[i].traceList(niv+"--")
		}
	}	
//{
}

	// Wallpaper miniwave mini-star $wpMinistar 15 Mini-Wave 


