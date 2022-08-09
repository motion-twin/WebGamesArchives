class Hq extends Ally{//}

	var range:float
	var view:float
	var damage:float


	
	function new(mc){
		type = 10
		
		super(mc)
		hpMax = 100
		ray = 24
		mass = 0
		flSelectable = false;
		root.onPress = null
		root.useHandCursor = false;
		
		
	};
	
	function update(){
		super.update();
	};
	
	
//{
}