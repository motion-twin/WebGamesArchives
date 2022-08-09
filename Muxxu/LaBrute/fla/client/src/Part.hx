class Part extends Phys{//}


	public var fadeType:Int;
	public var fadeLimit:Int;
	public var timer:Float;
	public var bhl:Array<Int>;



	public function new(?mc) {
		super(mc) ;
		fadeLimit = 10;
		alpha = 1;

	}


	override function update() {
		super.update() ;
		if(timer!=null){
			timer -= mt.Timer.tmod;
			if( timer < fadeLimit ){
				var c = timer/fadeLimit;

				switch(fadeType){
					case 0:
						root._xscale = c*scale;
						root._yscale = c*scale;
					default:
						root._alpha = alpha*c*100;
						this.shade._alpha = Sprite.SHADOW_ALPHA*c;

				}
			}
			if(timer<=0)kill();
		}



	}




//{
}