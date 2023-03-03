import snake3.Const;

class snake3.bonus.PotionRouge extends snake3.bonus.TimedSlot {//}

	var save_f;

	static var FRUITS_ROUGES = [2,3,11,13,27,37,45,50,51,53,57,74,79,80,82,83,93,98,103,107,116,119,124,131,140,143,149,156,159,167,182,186,199,200,201,203,214,220,226,230,235,240,251,258,262,263,266,267,269,272,281,296];

	function PotionRouge( game : snake3.Game ) {
		super(game,3,Const.TIME_POTIONROUGE);
		save_f = game.gen_fruit_id;

		var me = this;
		function f() {
			return me.gen_fruit_id();
		};
		game.gen_fruit_id = f;
	}

	function gen_fruit_id() {
		return FRUITS_ROUGES[random(FRUITS_ROUGES.length)];
	}

	function close() {
		game.gen_fruit_id = save_f;
		super.close();
	}

//{
}