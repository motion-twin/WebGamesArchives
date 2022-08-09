import swapou2.Manager;
import swapou2.Data;

class swapou2.Pause {

	var dmanager : asml.DepthManager;
	var key_flag;
	var flag;
	var pauseBox;
	var toggles;
	var xOffset ;

	function Pause(dman, toggles, xOffset) {
		this.toggles = toggles;
		dmanager = dman;
		flag = false;
		key_flag = false;
		this.xOffset = xOffset ;
	}

	function activated() {
		return flag;
	}

	function togglesVisible(b) {
		var i;
		for(i=0;i<toggles.length;i++)
			toggles[i].setVisible(b);
	}

	function main() {

		if( flag ) {
			if( !Manager.client.forcePause && Key.isDown(Key.ESCAPE) ) {
				if( !key_flag ) {
					togglesVisible(true);
					pauseBox.removeMovieClip() ;
					flag = false;
					key_flag = true;
					return false;
				}
			} else
				key_flag = false;
			return true;
		}

		if( Manager.client.forcePause || Key.isDown(Key.ESCAPE) )  {
			if( !key_flag ) {
				var ct = {
					ra : 50,
					rb : 30,
					ga : 70,
					gb : 0,
					ba : 50,
					bb : 30,
					aa : 100,
					ab : 0
				};				
				key_flag = true;
				flag = true;
				togglesVisible(false);
				pauseBox = dmanager.attach("pauseBox", Data.DP_INTERFTOP ) ;
				pauseBox._x = Data.DOCWIDTH/2 + xOffset ;
				pauseBox._y = Data.DOCHEIGHT/2 ;
				return true;
			}
		} else
			key_flag = false;

		return false;
	}
}