class mb2.Card {

	var $challenge;
	var $classic;
	var $items;
	var $dungeons : Array;
	var $dungeons_done : Array;
	var $courses : Array;
	var $classic_score;
	var $dtimes : Array;
	var $records : Array;
	
	static function times_cpu(t1,t2,t3) {
		return [
			{ $t : t1, $c : true },
			{ $t : t2, $c : true },
			{ $t : t3, $c : true }
		];
	}

	static function time(m,s) {
		return (m * 60 + s) * 100;
	}

	static function scoreDonjon(c : mb2.Card, score ) {
		var id = mb2.Manager.play_mode_param;
		var old = c.$dtimes[id];
		if( old == undefined )
			old = 0;
		if( old < score ) {
			c.$dtimes[id] = score;
			mb2.Manager.client.saveSlot(0);
			return old;
		}
		return old;
	}

	function Card() {
		$items = [];
		$challenge = true;
		$classic = true;
		$dungeons = [true,true,true,true];
		$dungeons_done = [];
		$courses = [true];
		$classic_score = 0;
		$dtimes = [];
		$records = [
			times_cpu( time(3,00), time(3,40), time(4,20) ),
			times_cpu( time(4,00), time(4,40), time(5,20) ),
			times_cpu( time(4,30), time(5,15), time(6,00) ),
			times_cpu( time(2,30), time(3,00), time(3,30) ),
			times_cpu( time(3,00), time(3,30), time(4,00) ),
			times_cpu( time(4,00), time(4,40), time(5,20) ),
			times_cpu( time(4,00), time(4,40), time(5,20) )
		];
	};
}
