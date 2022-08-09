class inv.Item extends MovieClip{//}
	
	static var DP_ITEM = 2
	
	
	var flExtra:bool;
	
	var item:It;
	var faerie:FaerieInfo;	// PROPRIO DU SLOT
	//var fi:FaerieInfo;	// DANS LE SLOT
	var index:int;

	
	
	
	var dm:DepthManager;
	var inv:Inventory;
	
	var pic:MovieClip;
	
	
	function new(){
		flExtra = false;
		dm = new DepthManager(this);
		
	}
	
	function addItem( n, from ){
		item = Item.newIt(n);
		pic = item.getPic(dm,DP_ITEM);
		pic._xscale = 90
		pic._yscale = 90
		
		if(from!=null){
			from.item.fi.fs.$pos = index
			from.setCardPos(null)
			setCardPos(n);
		}
		//*
		if( n == 30 ){	// CHERCHE LA FEE QUI VA DANS LA FLASK SI BESOIN
			var list = Cm.card.$faerie
			for( var i=0; i<list.length; i++){
				var fs = list[i]
				if( fs.$pos == index && flExtra!=true){
					var fi = Cm.getFaerie( fs );
					addFaerie(fi);
				}
			}
		}
		//*/
		
	
		
		//
		
		
	}
	
	function setCardPos(n:int){
		
		if( faerie != null ){
			faerie.fs.$inv[index] = n
			if( faerie.fs == Cm.getCurrentFaerie().fs ){
				inv.updateFace();
			}			
		}else if( flExtra ) {
			inv.extraList[inv.extraIndex+index] = n
		}else{
			Cm.card.$inv[index] = n
		}
	}
		
	
	//*
	function addFaerie(fi){

		fi.fs.$pos = index;
		//item.addFaerie(fi);
		item.fi = fi;
		item.updatePic(pic);
	}
	
	function removeFaerie(fi){
		fi.fs.$pos = null;
		//fi = null
		item.fi = null;
		//item.removeFaerie()
		item.updatePic(pic);
	}
	//*/
	
	function removeItem(){
		pic.removeMovieClip();
		item = null;	
	}
	
	
//{	
}