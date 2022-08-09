import swapou2.Data

class swapou2.Fruit extends MovieClip {

	//  public var x,y ;
	public var t;
	public var flags;
	public var save_t;
	public var save_flags;

	public var has_armure; // optimize

	public var dbg;
	public var combo;

	public var sub ; // MCs

	function init( ftype, flags ) {
		this.flags = flags;
		save_t = ftype;
		if( (flags & Data.FLAG_ARMURE) != 0 ) {
			has_armure = true;
			t = -1;
		} else {
			has_armure = false;
			t = ftype;
		}
		updateSkin();
	}

	function updateSkin() {
		if ( (flags & Data.FLAG_NOSWAP) != 0 )
			this.sub.gotoAndStop( string(save_t+Data.METAL_FRAME) ) ;
		else {
			if ( (flags & Data.FLAG_ARMURE) != 0 )
				this.sub.gotoAndStop( string(save_t+Data.FROZEN_FRAME) ) ;
			else {
				if( (flags & Data.FLAG_STAR) != 0 )
					this.sub.gotoAndStop( string(save_t+Data.STAR_FRAME) ) ;
				else
					this.sub.gotoAndStop( string(save_t+1) ) ;
			}
		}
		if ( Data.lod < Data.HIGH || Data.gameMode != Data.CHALLENGE )
			this.sub.shine.gotoAndStop(1) ;
	}


	function canSwap() {
		return (flags & Data.FLAG_NOSWAP) == 0;
	}

	function peteArmure() {
		t = save_t;
		has_armure = false;
		flags &= (0xFFFF - Data.FLAG_ARMURE);
		updateSkin();
	}

	function destroy() {
		this.removeMovieClip();
	}

}