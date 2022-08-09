class inv.Slot extends inv.Item{//}
	
	
	function new(){
		super()
		onPress = click
		
	}
	

	function addItem( n, from ){
		
		super.addItem( n, from );
		inv.trgMsg( this, item.getInfoMsg() )
		
	}
	
	function click(){
		
		// PAS DE MANIP DE FEE EN FIN DE MATCH
		if( item.type == 30 && item.fi !=null && inv.extraList !=null && !Key.isDown(Key.SPACE) ) return;
		
		if( item!=null && inv.hand==null ){
			//*
			if(item.type == 30 && Key.isDown(Key.SPACE) && !flExtra && ( item.fi.fs.$mission==null || item.fi == null ) ){
				var c = Cm.getCurrentFaerie();
				var toInsert = null
				if(c!=null){
					toInsert = c
					Cm.card.$current = null
					inv.updateCurrent();
				}
				
				var fi = item.fi
				if( fi!=null ){
					Cm.card.$current = Cm.getFaerieIndex(fi.fs)
					inv.updateCurrent();
					removeFaerie(fi);
				}
				
				if( toInsert != null ) addFaerie(toInsert);
				
				
				inv.trgMsg( this, item.getInfoMsg() )
				return;
			}

			take();
			return;

		}
		
		if( inv.hand!=null && item==null ){
			if( faerie == null || inv.hand.item.flEquip ){
				put();
			}
			return;
		}
		
		
		if( inv.hand!=null && item!=null ){		// BRICOLAGE
			swap();
		}
		
	}
	

	//
	function put(){
		addItem(inv.hand.item.type,inv.hand)
		inv.clearHand();
	}
	
	function take(){
		inv.setHand(this);
		removeItem();
	}
	
	function swap(){
		//if( faerie == null )r 
		
		
		var ht = inv.hand.item.type
		var mit = inv.hand.item
		/*
		var fi0 = item.fi
		var fi1 = inv.hand.item.fi
		*/
		if( (faerie == null || mit.flEquip) && (inv.hand.faerie == null || item.flEquip) ){
			
			item.fi.fs.$pos = inv.hand.index
			mit.fi.fs.$pos = index
			
			inv.hand.removeItem();
			inv.hand.addItem(item.type,Std.cast("plouch"))
			
			removeItem();
			addItem(ht,Std.cast("plouch"))
			
						
			
		}
		
		
	}
	
	function removeItem(){
		super.removeItem();
		inv.trgMsg( this, null )
	}


	
//{
}





















