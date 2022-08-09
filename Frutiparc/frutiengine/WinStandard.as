class WinStandard extends Window {//}

	
	var dp_ghost =			1400;
	//dp_pluginHigh =		1100;
	var dp_frameSet = 		200;	var dp_frameSetMax = 800; //var dp_frameSetList = new DepthList(800);
	//dp_infoBut = 			164;
	var dp_butResize =		160;
	var dp_frameBg =		112;
	var dp_interface =		100;
	//dp_resizeArrow = 		30;
	//dp_inline = 			20;
	//dp_pluginLow =		25;	
	//dp_outline = 			10;	
	
	var flTrace:Boolean;
	
	var dp_frameSetList:DepthList;
	
	var frameSet:Frame;
	var main:Frame;
	var style:Object;
	var flMoveAnim:Boolean
	
	var margin:Object;
	var minimum:Object;
	var animList:AnimList;
	var regular:Object;
	var flResizable:Boolean;
	var topIconList:Array;
	//var iconLabel:String;
	
	var mouseListener:Object;
	var box:Object;
	var pos:Object;
	var tab:Object;
	
	var gel:Number;
	var title:String; 
	
	//MovieClip
	var winGhost:MovieClip;
	var frameBg:MovieClip;
	var mcInterface:MovieClip;
	var butResize:MovieClip;
	
	// HACK SKOOL
	var flInterface:Boolean;
	
	function windowStandardClass(){};
	function init(){
		
		if(this.flInterface==undefined)this.flInterface=true;
		super.init();
		
		this.margin = new Object();
		this.minimum = new Object();
		
		this.tab = new Object();
		if(this.pos == undefined) this.pos = {x:0, y:0, w:0, h:0};
		if(this.minimum == undefined) this.minimum = {w:0,h:0};
		
		if(this.style==undefined)this.style = Standard.getWinStyle();	
		this.animList = new AnimList();
		this.dp_frameSetList = new DepthList(this.dp_frameSetMax);
		
		// HACK SKOOL
		if(this.flInterface){
			this.genTopIconList();
			this.initFrameBg();
			this.initFrameSet();
			this.initInterface();
			
		};
	};

	/*-----------------------------------------------------------------------
		Function: endInit()
		Indique la fin d'initialisation des données graphiques et lance 
		les fonctions d'updates graphiques appropriées.
		Doit être appelé à la fin de la fonction init pour chaque classe
		finale.
	 ------------------------------------------------------------------------*/
	function endInit(){
		if( this.flMoveAnim == undefined ) this.flMoveAnim = _global.userPref.getPref("win_flMoveAnim");
		if( this.flResizable == undefined ) this.flResizable = true;
		this.onChangeMode();
	};
	
	/*-----------------------------------------------------------------------
		Function: initResize()
	 ------------------------------------------------------------------------*/	
	function initResize(){
		attachMovie("winGhost","winGhost",this.dp_ghost,{pos:FEObject.clone(this.pos)})
		this.winGhost.decalSizeX = this.pos.w-this._xmouse
		this.winGhost.decalSizeY = this.pos.h-this._ymouse
		this.winGhost.updateSize();
		var w = this.minimum.w;
		var h = this.minimum.h;
		this.winGhost.anim = setInterval(this.winGhost,"watchSize",25,w,h)
	};
	
	/*-----------------------------------------------------------------------
		Function: endResize()
	 ------------------------------------------------------------------------*/		
	function endResize(){
		clearInterval(this.winGhost.anim);
		this.applyGhost()
		//this.updateDeskPos();
		//this.updateDeskSize();
		this.update();	
	};
	
	/*-----------------------------------------------------------------------
		Function: initDrag()
	 ------------------------------------------------------------------------*/		
	function initDrag(){
		this.attachMovie("winGhost","winGhost",this.dp_ghost,{pos:FEObject.clone(pos)})
		//_root.test+=">"+this.pos.x+","+this.pos.y+","+this.pos.w+","+this.pos.h+"\n"
		this.winGhost.updateSize();
		this.winGhost.decalx = this._xmouse
		this.winGhost.decaly = this._ymouse
		
		this.mouseListener = {fen:this}
		
		this.mouseListener.onMouseMove = function(){
			this.fen.winGhost.pos.x = 	this.fen.pos.x + this.fen._xmouse - this.fen.winGhost.decalx;
			this.fen.winGhost.pos.y = 	this.fen.pos.y + this.fen._ymouse - this.fen.winGhost.decaly;
			this.fen.winGhost._x =		this.fen._xmouse - this.fen.winGhost.decalx;
			this.fen.winGhost._y =		this.fen._ymouse - this.fen.winGhost.decaly;
		};	
		this.mouseListener.onMouseMove();
		Mouse.addListener(this.mouseListener);	
	};
	
	/*-----------------------------------------------------------------------
		Function: endDrag()
	 ------------------------------------------------------------------------*/		
	function endDrag(){
		//_root.test+="+\n"
		Mouse.removeListener(this.mouseListener);
		this.applyGhost();
		this.updateDeskPos();
	};
	
	/*-----------------------------------------------------------------------
		Function applyGhost()
		remplace la pos de la fenetre par le pos du ghost
	 ------------------------------------------------------------------------*/	
	function applyGhost(){
		this.pos = FEObject.clone(this.winGhost.pos);
		this.winGhost.removeMovieClip();
	};

	/*-----------------------------------------------------------------------
		Function: update()
		met a jour l'affichage de la fenetre
	 ------------------------------------------------------------------------*/		
	function update(){
		this.updateSize();
		//if(this.flTrace)_root.test+="pos(x:"+this.pos.x+",y:"+this.pos.y+",w:"+this.pos.w+",h:"+this.pos.h+",)\n"
		this.updatePos();
	}
	
	/*------------------------------------------------------------------------
		Function: updatePos()
		met a jour la position de la fenetre
	 ------------------------------------------------------------------------*/	
	function updatePos(){
		if(this.box.mode=="desktop"){
			this.updateDeskPos();
		}else if(this.box.mode=="tab"){
			this.updateTabPos()
		}	
	}
	
	/*------------------------------------------------------------------------
		Function: updateSize()
		met a jour la taille de la fenetre
	 ------------------------------------------------------------------------*/	
	function updateSize(){
		if(this.box.mode=="desktop"){
			this.updateDeskSize();
		}else if(this.box.mode=="tab"){
			this.updateTabSize();
		}
		//this.frameBg.clear();
		//if(this.flTrace)_root.test+="[WinStandard]update() -pos.h("+this.pos.h+") \n"
		this.frameSet.update();
		this.drawInterface();	
		//
	}
	
	/*------------------------------------------------------------------------
		Function: updateDeskPos()
		met a jour la position de la fenetre en mode desktop
	 ------------------------------------------------------------------------*/	
	function updateDeskPos(){
		this.recal()
		this.moveToPos();
		/*
		this._x = this.pos.x
		this._y = this.pos.y
		*/
		// A Replacer dans une classe frutiparc
		/*
		if(this.regular){
			this.regular.x = this.pos.x
			this.regular.y = this.pos.y
		}
		*/
	}
	
	/*------------------------------------------------------------------------
		Function: updateDeskSize()
		met a jour la taille de la fenetre en mode desktop
	 ------------------------------------------------------------------------*/	
	function updateDeskSize(){
		this.frameSet.pos.w = this.pos.w
		this.frameSet.pos.h = this.pos.h		

		//_root.test="updateDeskSize frameSet.minInt.w: "+this.frameSet.minInt.w+"\n"
		
		this.minimum.w = this.frameSet.minInt.w
		this.minimum.h = this.frameSet.minInt.h
		
		// A Replacer dans une classe frutiparc
		this.butResize._x = this.pos.w - 20;
		this.butResize._y = this.pos.h - 20;
		
	}
	
	/*------------------------------------------------------------------------
		Function: updateTabPos()
		met a jour la position de la fenetre en mode tab
	 ------------------------------------------------------------------------*/
	function updateTabPos(){
		this._x = _global.main.cornerX;
		this._y = _global.main.cornerY;	
	}
	
	/*------------------------------------------------------------------------
		Function: updateTabSize()
		met a jour la taille de la fenetre en mode tab
	 ------------------------------------------------------------------------*/
	function updateTabSize(){
		this.tab.w = _global.mcw-_global.main.cornerX;
		this.tab.h = _global.mch-_global.main.cornerY;
		this.frameSet.pos.w = this.tab.w;
		this.frameSet.pos.h = this.tab.h;
	}
	
	/*------------------------------------------------------------------------
		Function: recal()
		modifie l'objet pos si la fenetre est hors-desktop
	
		Returns :
		- true si l'objet pos a était modifié, false si il est inchangé.
	 ------------------------------------------------------------------------*/
	function recal(){
		// HACK
		if(_global.frameMode) return false;
		//var oldPos = FEObject.clone(this.pos);
		
		//if(this.flTrace)_root.test+="beforeRecal:"+this.pos.x+","+this.pos.y+"(minimum("+this.minimum.w+","+this.minimum.h+"))\n";

		var oldPos = {x:this.pos.x, y:this.pos.y, w:this.pos.w, h:this.pos.h }
// 		this.pos.w = Math.min( Math.max( this.minimum.w,	this.pos.w),			_global.mcw-_global.main.cornerX	);
// 		this.pos.h = Math.min( Math.max( this.minimum.h,	this.pos.h),			_global.mch-_global.main.cornerY	);
// 		this.pos.x = Math.max( Math.min( this.pos.x ,		_global.mcw-this.pos.w ), 	_global.main.cornerX			);
// 		this.pos.y = Math.max( Math.min( this.pos.y ,		_global.mch-this.pos.h ), 	_global.main.cornerY			);
		this.pos.w = Math.max( Math.min( _global.mcw-_global.main.cornerX,	this.pos.w),	this.minimum.w		);
		this.pos.h = Math.max( Math.min( _global.mch-_global.main.cornerY,	this.pos.h),	this.minimum.h		);
		this.pos.x = Math.max( Math.min( this.pos.x ,		_global.mcw-this.pos.w ), 	_global.main.cornerX	);
		this.pos.y = Math.max( Math.min( this.pos.y ,		_global.mch-this.pos.h ), 	_global.main.cornerY	);		
		
		
		//_root.test+="afterRecal:"+this.pos.x+","+this.pos.y+"\n"
		
		return ( oldPos.x!=this.pos.x or oldPos.y!=this.pos.y or oldPos.w!=this.pos.w or oldPos.h!=this.pos.h );
		
	}
	
	/*------------------------------------------------------------------------
		Function: resize(w,h)
		Défini une nouvelle taille pour l'objet.
		
		Parameters :
		- w : largeur de la fenêtre
		- h : hauteur de la fenêtre
	 ------------------------------------------------------------------------*/	
	function resize(w,h){
		this.pos.w = w;
		this.pos.h = h;
		this.recal();
		this.update()
	}
	
	/*------------------------------------------------------------------------
		Function: onChangeMode()
		Appelé a chaque modification de box.mode
	------------------------------------------------------------------------*/	
	function onChangeMode(){
		if(this.box.mode=="desktop"){
			this.initDesktopMode();
		}else{
		// TODO: gérer le cas où ce n'est ni desktop ni tab, il faudrait donc connaitre l'ancien mode et avoir des fonction à appeler pour supprimer ce que les initXMode créent

			this.initTabMode();
		}
		this.update();
	}
	
	/*------------------------------------------------------------------------
		Function: initDesktopMode()
		initalise le mode desktop :
		- attache la barre du haut
		- ajoute le bouton resize si la fenetre est resizable
	------------------------------------------------------------------------*/	
	function initDesktopMode(){
		
		this.margin.top.newElement({name:"winTopBar", link:"winTopBar",type:"compo"},0)
		
		// BUTRESIZE		
		if(this.flResizable){
			this.attachMovie("transp","butResize",this.dp_butResize)
			this.butResize._xscale=30;
			this.butResize._yscale=30;
			/*
			_root.test+="< this.butResize ("+this.butResize+") getDepth("+this.butResize.getDepth()+")\n"
			this.butResize.removeMovieClip()
			_root.test+="> this.butResize ("+this.butResize+")\n"
			*/
			this.butResize.onRollOver = function(){
				_parent.startResizeAnim()
			}
			this.butResize.onRollOut = function(){
				_parent.endResizeAnim()
			}
			this.butResize.onPress = function(){
				_parent.initResize();
				_parent.box.activate();
			}	
			this.butResize.onReleaseOutside = function(){
				_parent.endResize();
				_parent.endResizeAnim()
			}
			this.butResize.onRelease = function(){
				_parent.endResize();
			}
			this.butResize.useHandCursor = false;
		}
	};
	
	/*------------------------------------------------------------------------
		Function: initTabMode()
		initalise le mode tab :
		- detache la barre du haut.
		- détruit toutes les anims en cours.
	------------------------------------------------------------------------*/	
	function initTabMode(){
		this.margin.top.removeElement("winTopBar")
		this.butResize._visible=false;	//this.butResize.removeMovieClip(); // NE MARCHE PAS : BUTRESIZE == INDESTRUCTIBLE
		//_root.test+="this.butResize("+this.butResize+")\n"
		this.animList.removeAll()
	};
	
	/*------------------------------------------------------------------------
		Function: putInTab()
		place la fenêtre en tab.
		Joue une anim de slide avant, si le la touche controle n'est pas
		appuyée.
	
	------------------------------------------------------------------------*/	
	function putInTab(){
		if(Key.isDown(17)){
			this.box.putInTab(true)
		}else{
			this.pos.y = -(this.pos.h+100)
			
			this.moveToPos(false,{obj:this.box, method:"putInTab", args:false})
			//this.animList.addSlide("slide",this,{obj:this.box, method:"putInTab", args:false})
		}
	}

	/*------------------------------------------------------------------------
		Function: onStageResize()
	------------------------------------------------------------------------*/	
	function onStageResize(){
		this.update();
	}
	
	/*------------------------------------------------------------------------
		Function: setTitle(title)
	
		Returns:
		- title : devine...
	------------------------------------------------------------------------*/	
	function setTitle(title){
		this.title = title
	}
	
	/*------------------------------------------------------------------------
		Function: gelatine()
		gelatinise la fenetre
	------------------------------------------------------------------------*/	
	function gelatine(){
		this.gel= (this.gel+_global.tmod*10)%628
		this._xscale = 100+Math.cos(this.gel/100)*4
		this._yscale = 100+Math.sin(this.gel/100)*4
	}
	
	/*------------------------------------------------------------------------
		Function: initFrameSet()
		créé le systeme basic de frame d'une fenetre.
	------------------------------------------------------------------------*/	
	function initFrameSet(){
		//_root.test+="winStandard initFrameSet\n"
		
		this.frameSet = new Frame(		{ name:"frameSet",	type:"w", 	root:this,	win:this	})
		
		this.frameSet.newElement(		{ name:"top",		type:"w",	min:{w:0,h:6}			})
		this.frameSet.newElement(		{ name:"center",	type:"h"					})
		this.frameSet.newElement(		{ name:"bottom",	type:"w", 	min:{w:0,h:6}			})
		
		this.frameSet.center.newElement(	{ name:"left",		type:"w", 	min:{w:6,h:0}			})
		this.frameSet.center.newElement(	{ name:"center",	type:"w"					})
		this.frameSet.center.newElement(	{ name:"right",		type:"w", 	min:{w:6,h:0}			})
		
		this.frameSet.bigFrame = 	this.frameSet.center;
		this.frameSet.center.bigFrame = this.frameSet.center.center;
		
		this.margin.left =		this.frameSet.center.left;
		this.margin.right =		this.frameSet.center.right;
		this.margin.top =		this.frameSet.top;
		this.margin.bottom =		this.frameSet.bottom;
		
		this.main = 			this.frameSet.center.center
		
		this.frameSet.pos.x = 0;
		this.frameSet.pos.y = 0;
	
		this.frameSet.onUpdate = function(){	// A REMETTRE DANS FRAME
			this.win.onFrameSetUpdate();
		}
	}
	
	/*------------------------------------------------------------------------
		Function: onFrameSetUpdate()
		appelé a chaque update du frameSet
	------------------------------------------------------------------------*/	
	function onFrameSetUpdate(){
		
		this.minimum.w = this.frameSet.minInt.w
		this.minimum.h = this.frameSet.minInt.h
		//_root.test+="onFrameSetUpdate("+this.minimum.h+")\n"
		//_root.test+="this.win.recal() = "+this.win.recal()+"\n"
		if(this.recal()){
			this.update()
		}		
	}
		
	/*------------------------------------------------------------------------
		Function: initFrameSet()
		créé le systeme basic de frame d'une fenetre.
	------------------------------------------------------------------------*/	
	function initFrameBg(){
		this.createEmptyMovieClip("frameBg",this.dp_frameBg)
		this.frameBg.depth=0;
	}
	
	/*------------------------------------------------------------------------
		Function: initInterface()
		initialise mcInterface
	------------------------------------------------------------------------*/	
	function initInterface(){
		this.createEmptyMovieClip("mcInterface",this.dp_interface)
		this.mcInterface.onPress = function(){_parent.box.activate()}

		this.mcInterface.useHandCursor=false
		this.mcInterface.dropBox = this.box;
		this.mcInterface.initDraw()
	}
	
	/*------------------------------------------------------------------------
		Function: genTopIconList()
		génere la topIconList. 
	------------------------------------------------------------------------*/
	function genTopIconList(){
		
		this.topIconList = [
			{link:"butGroup", 
				param:{
					link:"WinTop",
					frame:1,
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"tryToClose"
						}]
					}
				}
			}
		];
		
		
		//this.topIconList = new Array();
		
	};
	
	/*------------------------------------------------------------------------
		Function: drawInterface()
		dessine l'interface 
	------------------------------------------------------------------------*/	
	function drawInterface(){
		
		//_root.test+="drawInterface\n"
		this.mcInterface.clear();
		
		// SHADOW
		this.dropShadow();
		
		
		// INTERFACE
		var out = 1
		var i = 2
		var c = 10		
		/*
		var gradient = {
			type:"linear",
			colors:[ 0xE7EEDD, 0xF0FFEE ],
			alphas:[ 100, 100 ],
			ratios:[ 0, 0xFF ],
			matrix:{ matrixType:"box", x:0, y:0, w:pos.w, h:20, r:3.14/2}
		}
		*/
		
		var info ={
			outline:out,
			inline:i,	
			curve:c,
			color:{
				main:		this.style.global.color[0].main,
				inline:		this.style.global.color[0].shade,
				outline:	this.style.global.color[0].darkest
			}
		}
		
		if(this.box.mode == "desktop"){
			var p = {x:0,y:0,w:pos.w,h:pos.h};
			FEMC.drawCustomSquare(this.mcInterface,p,info,true)
			
		}else if(this.box.mode == "tab"){	// TODO trad -> new style system
			var col = this.style.global.color[0]
			var p = {x:0,	y:-out,	w:tab.w,	h:out};
			FEMC.drawSquare( this.mcInterface,p, col.darkest)
			var p = {x:0,	y:0,	w:tab.w,	h:i};
			FEMC.drawSquare( this.mcInterface, p, col.shade)
			var p = {x:0,	y:i,	w:tab.w,	h:tab.h-i};
			//_root.test+="col.main("+col.main+")\n"
			FEMC.drawSquare( this.mcInterface, p, col.main)
		}
		
		
		
	}

	function dropShadow(){
		//_root.test+="graph\n"
		var ray = 17//18
		var inside = 10
		var colIn = 0 //0xFFFFFF 0x5E8921
		var colOut = 0 //0xFFFFFF 
		var alphaIn = 50
		var alphaOut = 0		
		var pos = {
			x: inside,
			y: inside,
			w: this.pos.w - inside,
			h: this.pos.h - inside
		}
		var g = {
			type:"radial",
			colors:[ colIn, colOut ],
			alphas:[ alphaIn, alphaOut ],
			ratios:[ 0, 0xFF ]
		}
		// CORNER A :
		var matrix={ matrixType:"box", x:pos.x-ray, y:pos.y-ray, w:2*ray, h:2*ray, r:0}
		this.mcInterface.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.mcInterface.moveTo(	pos.x,	pos.y-ray	)
		this.mcInterface.lineTo(	pos.x,	pos.y	)
		this.mcInterface.lineTo(	pos.x-ray,	pos.y	)
		this.mcInterface.lineTo(	pos.x-ray,	pos.y-ray	)
		this.mcInterface.endFill();
		// CORNER B :
		var matrix={ matrixType:"box", x:pos.w-ray, y:pos.y-ray, w:2*ray, h:2*ray, r:0}
		this.mcInterface.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.mcInterface.moveTo(	pos.w,		pos.y-ray	)
		this.mcInterface.lineTo(	pos.w,		pos.y	)
		this.mcInterface.lineTo(	pos.w+ray,	pos.y	)
		this.mcInterface.lineTo(	pos.w+ray,	pos.y-ray	)
		this.mcInterface.endFill();		
		// CORNER C :
		var matrix={ matrixType:"box", x:pos.w-ray, y:pos.h-ray, w:2*ray, h:2*ray, r:0}
		this.mcInterface.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.mcInterface.moveTo(	pos.w,		pos.h	)
		this.mcInterface.lineTo(	pos.w,		pos.h+ray	)
		this.mcInterface.lineTo(	pos.w+ray,	pos.h+ray	)
		this.mcInterface.lineTo(	pos.w+ray,	pos.h	)
		this.mcInterface.endFill();
		// CORNER D :
		var matrix={ matrixType:"box", x:pos.x-ray, y:pos.h-ray, w:2*ray, h:2*ray, r:0}
		this.mcInterface.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.mcInterface.moveTo(	pos.x-ray,	pos.h		)
		this.mcInterface.lineTo(	pos.x,		pos.h		)
		this.mcInterface.lineTo(	pos.x,		pos.h+ray	)
		this.mcInterface.lineTo(	pos.x-ray,	pos.h+ray	)
		this.mcInterface.endFill();

		var g = {
			type:"linear",
			colors:[ colOut, colIn ],
			alphas:[  alphaOut, alphaIn ],
			ratios:[ 0, 0xFF ]
		}
		// LINE A :
		var matrix={ matrixType:"box", x:pos.x, y:pos.y-ray, w:pos.w, h:ray, r:Math.PI/2 }
		this.mcInterface.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.mcInterface.moveTo(	pos.x,		pos.y-ray	)
		this.mcInterface.lineTo(	pos.w,		pos.y-ray	)
		this.mcInterface.lineTo(	pos.w,		pos.y	)
		this.mcInterface.lineTo(	pos.x,		pos.y	)
		this.mcInterface.endFill();
		// LINE B :
		var matrix={ matrixType:"box", x:pos.w, y:pos.y, w:ray, h:pos.h, r:Math.PI }
		this.mcInterface.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.mcInterface.moveTo(	pos.w,		pos.y		)
		this.mcInterface.lineTo(	pos.w+ray,	pos.y		)
		this.mcInterface.lineTo(	pos.w+ray,	pos.h		)
		this.mcInterface.lineTo(	pos.w,		pos.h		)
		this.mcInterface.endFill();		
		// LINE C :
		var matrix={ matrixType:"box", x:pos.x, y:pos.h, w:pos.w, h:ray, r:-Math.PI/2 }
		this.mcInterface.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.mcInterface.moveTo(	pos.x,		pos.h		)
		this.mcInterface.lineTo(	pos.w,		pos.h		)
		this.mcInterface.lineTo(	pos.w,		pos.h+ray		)
		this.mcInterface.lineTo(	pos.x,		pos.h+ray		)
		this.mcInterface.endFill();		
		// LINE D :
		var matrix={ matrixType:"box", x:pos.x-ray, y:pos.y, w:ray, h:pos.h, r:0 }
		this.mcInterface.beginGradientFill	(g.type,	g.colors,	g.alphas,	g.ratios,	matrix	)
		this.mcInterface.moveTo(	pos.x-ray,		pos.y		)
		this.mcInterface.lineTo(	pos.x,		pos.y		)
		this.mcInterface.lineTo(	pos.x,		pos.h		)
		this.mcInterface.lineTo(	pos.x-ray,		pos.h		)
		this.mcInterface.endFill();			
	}
	
	/*------------------------------------------------------------------------
		Function: initComeFromNowhereMove()
		initialise l'animation faisant "tomber" la fenetre depuis la barre 
	------------------------------------------------------------------------*/	
	function initComeFromNowhereMove(){
		this.pos.y = -this.pos.h + 100
		this.moveToPos()
		//this.animList.addSlide("slide",this)
	}
	
	/*------------------------------------------------------------------------
		Function: onClose()
	------------------------------------------------------------------------*/	
	function onClose(){
		//super.onClose()
		this.animList.removeAll()
	}
	
	/*------------------------------------------------------------------------
		Function: tryToClose()
	------------------------------------------------------------------------*/	
	function tryToClose(){
		this.box.tryToClose();
	}

	/*-----------------------------------------------------------------------
		Function: moveToPos()
	 ------------------------------------------------------------------------*/	
	function moveToPos(flDirect, callback){
		if(this.flMoveAnim){
			this.animList.addSlide("slide",this,callback)
		}else{
			this._x = this.pos.x
			this._y = this.pos.y
			if( callback != undefined ) callback.obj[callback.method](callback.args);
		}
	}

	/*-----------------------------------------------------------------------
		Function: removeResizeArrow()
	 ------------------------------------------------------------------------*/	
	function moveToCenter(){
		this.pos.x = ( _global.mcw - ( _global.main.cornerX + this.pos.w ) ) / 2;
		this.pos.y = ( _global.mch - ( _global.main.cornerY + this.pos.h ) ) / 2;
		this.recal();
		this.moveToPos();
	}	
	
//{	
}





















