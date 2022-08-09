package en.it;
import api.AKProtocol;
import api.AKConst;

class KPoint extends en.Item {
	var pk			: SecureInGamePrizeTokens;
	var minScore	: AKConst;
	
	public function new(x,y, pk:SecureInGamePrizeTokens) {
		super(5,5);
		
		minScore = pk.score;
		cx = x;
		cy = y;
		this.pk = pk;
		zsortable = !api.AKApi.isLowQuality();
		
		sprite.swap(game.char, "kpoint", pk.frame-1);
		sprite.setCenter(0.5, 0.8);
		
		zsortable = true;
		
		if( pk.score.get()>api.AKApi.getScore() )
			deactivate();
	}
	
	override private function onPickUp() {
		super.onPickUp();
		api.AKApi.takePrizeTokens(pk);
		var n = pk.amount.get();
		var str = n<=1 ? Lang.KPoint({_n:n}) : Lang.KPoints({_n:n});
		fx.pop(xx,yy, str, 0xBFF04F, 2, true );
		fx.pickUp(xx,yy, 0xBFF04F);
	}
	
	override function update() {
		super.update();
		if( !active && game.time%30==0 && api.AKApi.getScore()>=minScore.get() )
			activate();
	}
}
