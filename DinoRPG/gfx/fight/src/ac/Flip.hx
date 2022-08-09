package ac ;

import Fighter.Mode ;
import Fight ;
class Flip extends State {

	var a : Fighter ;
	public function new(f : Fighter ) {
		super();
		this.a = f ;
		addActor(a);
	}

	override function init() {
		//ancien code, ne fonctinnait pas tres bien
		//a.setSide(!a.side);
		//a.setSens(1);
		//a.backToDefault();
		
		//regroupe le code ci dessus mais avec une meilleure gestion du scale du skin
		a.flip();
		//donner une tempo
		releaseCasting(10);
		
		//fonctionne mais pour les dialogues, le player se retourne à nouveau car il n'appartient pas au side voulu
		//a.setSens( -1 * a.sens );
		end();
	}
	
	/*
	public override function update() {
		super.update();
		if(castingWait)return;

		a.updateMove(coef);
		if(coef==1 ){
			a.backToDefault();
			end();
		}
	}
	*/

}