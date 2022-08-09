import mt.bumdum9.Lib;
class Exemple extends Game{//}

	// dm:mt.DepthManager;

	// dif   					 0.0-1.0		--> determine la difficulté du jeu
	// setWin(true/false)
	
	override function init(dif:Float){
		gameTime = 400-dif*200;				// precise le temps du jeu
		super.init(dif);
		
		
		
		// 1ere façon d'attacher un MC
		var star = new FxRainbowStar();
		addChild(star);
		
		// 2eme façon d'attacher un MC	( avec depthManager pour gerer les profondeur )
		var star = new FxRainbowStar();
		dm = new mt.DepthManager(this);
		dm.add(star, 0);
		
		// manipulation du MovieClip
		star.x = 8;
		star.scaleX = 0.1; // 0.0 - 1.0
		star.alpha = 0; //0.0 - 1.0

		// PHYS
		var p = new Phys( star );
		p.vx = 3
		p.frict = 0.95;
		
		// BG
		var bg = new McBgMikado();
		addChild(bg);
		
	}

	
	override function update(){
		super.update();


	}





//{
}

