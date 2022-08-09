class inter.Face extends Inter{//}

	var depthRun:int;
	var nextLimit:int;

	
	var align:float;
	var fi:FaerieInfo;
	var mcNext:MovieClip;
	var pieceList:Array<MovieClip>
	var fadePrc:float
	
	
	var cadre:MovieClip;
	var pic:MovieClip;
	var pse:MovieClip;
	
	function new(b){
		width = 100
		height = 70
		align = 0.75//0.5
		depthRun = 0;
		super(b);
		pieceList = new Array();
	}
	
	function init(){
		link = "interFace";
		super.init();
		
		// SEE NEXT
		
		updateImage();
		// IMAGE

	}
	
	function setFaerie(f){
		fi = f
		fi.intFace = this;
		
		var nl = Math.floor(fi.carac[Cs.WISDOM]*0.5)
		if( nl > 0 ){
			align = 1;
			mcNext = Std.attachMC(skin,"mcNext",1);
			mcNext._xscale = mcNext._yscale = height;
			nextLimit = nl
		}
		
		pic = downcast(Std.attachMC( downcast(skin).cadre.pic, "picFace", 10 ))
		Mc.setPic(pic,fi.skin)
		updateImage();
	}
	
	function supaMorph(){
		//
		downcast(skin).cadre._visible = false;
		//
		mcNext = Std.attachMC(skin,"mcNext",1);
		mcNext._xscale = mcNext._yscale = height*1.2;
		nextLimit = 3
		//
		
	}
	
	function updateImage(){
		var mc = downcast(skin).cadre;
		mc._xscale = mc._yscale = height;
		mc._x = (width-height)*align;
		setSkin(null);
	}
	
	function update(){
		super.update();
		// MOVE PIECE
		var ec = 100/(pieceList.length+1)
		for( var i=0; i<pieceList.length; i++ ){
			var mc = pieceList[i];
			var dy = (i+1)*ec - mc._y
			mc._y += dy*0.1*Timer.tmod
		}
		
		// PIECE SPELL EFFECT
		if( pse != null ){
			var n = pse._currentframe - 1
			switch(n){
				case 1:
					break;
				default:
					var d = 0.2
					pse._x = ( pse._x + d*Timer.tmod )%18 
					pse._y = ( pse._y + d*Timer.tmod )%18
					break;
				
			}
			
		} 
		// FADE
		if( fadePrc!=null){
			fadePrc *= Math.pow(0.95,Timer.tmod)
			if( fadePrc < 0.1 ){
				fadePrc = 0
			}
			Mc.setPercentColor(pic,100-fadePrc,0xE3E0ED)
			if( fadePrc == 0 )fadePrc = null;
		}
		
		
		
	}
	
	
	// SEE NEXT
	
	function newPiece(index){
		depthRun++
		var piece = Std.createEmptyMC( downcast(mcNext).zone, 10+depthRun  )
		piece._x = 18;
		piece._y = 120;
		var list = base.game.nextList[index]
		var size = 10
		for(var i=0; i<list.length; i++ ){
			var ei = list[i]
			var mc = Std.createEmptyMC( piece, i );
			mc._x = ei.x*size;
			mc._y = ei.y*size;
			ei.e.setSkin( Std.attachMC( mc, ei.e.link, 1 ) )
			ei.e.setScale(size)
			ei.e.updateSkin();
			ei.e.x = -0.5*size;
			ei.e.y = -0.5*size;
			ei.e.update();
		}
		pieceList.push(piece);
	}

	function removeNext(){
		var mc = pieceList.shift();
		mc.removeMovieClip();
		while(pieceList.length<nextLimit){
			newPiece(pieceList.length)
		}
		
	}

	function setColor(mc,col){
		var c = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		}
		var color = new Color(mc)
		var  o = {
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:c.r-255,
			gb:c.g-255,
			bb:c.b-255,
			ab:0,
		}
		color.setTransform(o)
	}
	
	//
	function setSkin(n){
		if(n!=null)skinFrame = n;
		mcNext.gotoAndStop(string(skinFrame));
		downcast(skin).cadre.gotoAndStop(string(skinFrame));
		
	}
	
	
	// FX
	function setPieceSpellEffect(n){
		if( pse == null ){
			pse = Std.attachMC( downcast(mcNext).zone, "mcPieceSpellEffect", 1 )
		}
		pse.gotoAndStop(string(n+1))
		switch(n){
			case 0:
				pse._alpha = 20
				break;
		}		
	}
	
	function removePieceSpellEffect(n){
		//Manager.log("removePieceSpellEffect(n)")
		if( pse._currentframe - 1 == n ){
				//Manager.log("remove")
			pse.removeMovieClip();
			pse = null;
		}
		
	}
	
	
	//
	function fadeToDeath(){
		Manager.log("fadeToDeath!")
		fadePrc = 100
		
		downcast(mcNext).zone._visible = false;
		
	}
	
	//AB9CC9
	
	
	
	
	
	
//{	
}