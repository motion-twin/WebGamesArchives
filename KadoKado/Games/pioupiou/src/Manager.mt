class Manager { //}

	static var root_mc : MovieClip;
	static var mode : { main : void -> void, destroy : void -> void };

	static function init( mc ) {
		if( !KKApi.available() )
			return;
		root_mc = mc;
		if ( KKApi.available() )
		  mode = new Game(root_mc);
		Log.setColor(0x00FF00);
		downcast(root_mc)._quality = "medium" ;
	}

	static function main() {
		Timer.update();
		mode.main();
	}
	
	/* GFX
		x explosotions des bonus verts : quand on les prends et quand ils sont écrasés
		x nuage de plumes gameover
		x couleurs des bonus ( x3 : normal, chanceux, rare )

		- réduire le temps des paillettes bonus
		- pour la mort, je verrais vraiment plus un effet "plumes" (particules plus grosses et moins rapides)
	*/
	
	/* PRG
		x Mettre une marge pour les bords jaunes du terrains ( le bonhomme rentre dedans )
		x nuage de plumes gameover
		x couleurs des bonus ( x3 : normal, chanceux, rare )
		x loop infini
		x hittest bonuses
	*/	
	
//{
}