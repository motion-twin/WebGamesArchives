class win.Advance extends WinStandard{//}

	var dp_pluginHigh =		1100;
	var dp_infoBut = 		164;
	var dp_resizeArrow = 		30;
	var dp_pluginLow =		25;
	var dp_inline = 		20;
	var dp_outline = 		10;	
	
	var flTabable:Boolean;
	var flShadow:Boolean;
	var shadowCount:Number;
	
	var resizeArrow:MovieClip;
	var mcOutline:MovieClip;
	var mcInline:MovieClip;
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		super.init();
		// MAJ TOPICONLIST
		this.shadowCount=0
		this.flShadow = false;
		if(this.flTabable==undefined)this.flTabable=true;
		if(this.flTabable){
			this.topIconList.push(
				{link:"butGroup", param:{
								link:"WinTop",
								frame:2,
								buttonAction:{onPress:[{obj:this,method:"putInTab"}]}
							}
				}
			);
		}
		//
		//this.style=Standard.getWinStyle()
			
			
	}
	
	/*-----------------------------------------------------------------------
		Function: checkShadow()
	 ------------------------------------------------------------------------*/	
	function checkShadow(){
		if(this.shadowCount and !this.flShadow){
			this.summonShadow();
		}
		if(!this.shadowCount and this.flShadow){
			this.unSummonShadow();
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: summonShadow()
	 ------------------------------------------------------------------------*/	
	function summonShadow(){
		this.flShadow = true
		createEmptyMovieClip("mcOutline",this.dp_outline)
		createEmptyMovieClip("mcInline",this.dp_inline)
		this.mcOutline.initDraw();
		this.mcInline.initDraw();
		this.drawInterface();
	}
	
	/*-----------------------------------------------------------------------
		Function: unSummonShadow()
	 ------------------------------------------------------------------------*/	
	function unSummonShadow(){
		this.flShadow = false
		this.mcOutline.removeMovieClip("");
		this.mcInline.removeMovieClip("");
		this.drawInterface();
	}

	/*-----------------------------------------------------------------------
		Function: drawInterface()
	 ------------------------------------------------------------------------*/	
	function drawInterface(){
			
		if(this.flShadow){
			var out = 1
			var i = 2
			var c = 10
			var col = this.style.global.color[0]
			//_root.test+=">>>"+this.pos.w+"\n"
			var pos = {x:0,y:0,w:this.pos.w,h:this.pos.h};
			
			
			
			if(out>0){
				this.mcOutline.clear();
				this.mcOutline.drawSmoothSquare(	{x:pos.x-out,	y:pos.y-out,	w:pos.w+out*2,	h:pos.h+out*2	},col.darkest,	c+out 	);
			}
			if(i>0){
				this.mcInline.clear();
				this.mcInline.drawSmoothSquare(		{x:pos.x,	y:pos.y,	w:pos.w,	h:pos.h		},col.shade,	c	);
			}
			this.mcInterface.clear();
			this.dropShadow();
			this.mcInterface.drawSmoothSquare(		{x:pos.x+i,	y:pos.y+i,	w:pos.w-i*2,	h:pos.h-i*2	},col.main,	c-i	);		
		}else{
			super.drawInterface();
		}
		
	}

	/*-----------------------------------------------------------------------
		Function: initDesktopMode()
	 ------------------------------------------------------------------------*/	
	function initDesktopMode(){
		super.initDesktopMode();
		//this.interface.removeMovieClip("");
	}
	
	/*-----------------------------------------------------------------------
		Function: initTabMode()
	 ------------------------------------------------------------------------*/	
	function initTabMode(){
		super.initTabMode();
		
		if(this.flShadow){
			this.unSummonShadow();
			this.flShadow = false;
			this.shadowCount=0;
		}
	}

	/*-----------------------------------------------------------------------
		Function: startResizeAnim()
	 ------------------------------------------------------------------------*/	
	function startResizeAnim(){

		var s = 18
		var col = this.style.global.color[0]
		
		if(this.resizeArrow._visible){
		
		}else{
			this.shadowCount++;
			this.checkShadow();		
			
			this.createEmptyMovieClip("resizeArrow",this.dp_resizeArrow)
			this.resizeArrow.initDraw();
			
			this.resizeArrow.drawOval({x:-s,y:-s,w:s,h:s},col.shade)
			this.resizeArrow.drawOval({x:2-s,y:2-s,w:s-4,h:s-4},col.main)
			
			this.resizeArrow.animList = animList;
			this.resizeArrow.attach = function(){
				if(this.icon==undefined){
					this.attachMovie("resizeIcon","icon",1,{_x:-s/2, _y:-s/2})
					this.icon._xscale = 0;
					this.icon._yscale = 0;
					this.animList.addResize("resizeIcon",this.icon)
				}
				this.icon.pos={xscale:100,yscale:100}
			}
			
			this.resizeArrow.outline = this.mcOutline.addMovieClip("resizeArrow")
			this.resizeArrow.outline.initDraw()
			this.resizeArrow.outline.drawOval({x:-(s+1),y:-(s+1),w:s+2,h:s+2},col.darkest)
			this.resizeArrow.followList = [this.resizeArrow.outline]
			this.resizeArrow._x = this.pos.w-s;
			this.resizeArrow._y = this.pos.h-s;
			this.resizeArrow.outline._x = this.resizeArrow._x;
			this.resizeArrow.outline._y = this.resizeArrow._y;
			this.resizeArrow._xscale = 0;
			this.resizeArrow._yscale = 0;	
		}
		var endCall = {obj:this.resizeArrow,method:"attach"}
		this.resizeArrow.pos = {
			x:pos.w+s/2,
			y:pos.h+s/2,
			xscale:100,
			yscale:100
		}
		this.animList.addSlide("resizeArrowMove",this.resizeArrow,endCall,2)
		this.animList.addResize("resizeArrowSize",this.resizeArrow)
	}
	
	/*-----------------------------------------------------------------------
		Function: endResizeAnim()
	 ------------------------------------------------------------------------*/	
	function endResizeAnim(){

		var s = 18
		var callBack = { obj:this,method:"removeResizeArrow" }
		this.resizeArrow.pos = {x:pos.w-20,y:pos.h-20,xscale:0,yscale:0}
		this.animList.addSlide("resizeArrowMove",resizeArrow,callBack)
		this.animList.addResize("resizeArrowSize",resizeArrow)
	}

	/*-----------------------------------------------------------------------
		Function: removeResizeArrow()
	 ------------------------------------------------------------------------*/	
	function removeResizeArrow(){
		this.animList.remove("resizeIcon");
		this.resizeArrow.removeMovieClip()
		this.shadowCount--;
		this.checkShadow();
	}

	
//{
}


