import Types;

class WinAppLog extends WinApp {
	var history		: List<HistoryLine>;
	var abandon		: MCField;

	public function new(t) {
		super(t);
		history = new List();
		setTitle("hacker_log");
	}

	override public function start() {
		super.start();
		term.hideLog();
		if ( term.fs!=null )
			term.fs.lock();

		scrollUp._visible = false;
		scrollDown._visible = false;
		addButton( sdm, wid-100, 5, Lang.get.OptSettings, onOptions, false );
		abandon = addButton( sdm, wid-100, 30, Lang.get.OptAbandon, onAbandonFirst, false );
		Tutorial.play( Tutorial.get.second, "showLog3" );
	}

	override public function stop() {
		super.stop();
		if ( term.fs!=null )
			term.fs.unlock();
		term.showLog();
		Tutorial.play( Tutorial.get.second, "showLog4" );
	}

	function onOptions() {
		stop();
		var a = new WinAppOptions(term);
		a.start();
	}

	function onAbandon() {
		stop();
		term.abandon();
	}

	function onAbandonFirst() {
		term.startAnim( A_Blink, abandon );
		term.startAnim(A_Text, abandon, Lang.get.OptConfirm);
		abandon.onRelease = onAbandon;
	}

	public function showLog(h:Array<HistoryLine>) {
		// inversion de l'historique
		history = new List();
		for (line in h)
			history.push(line);

		// affichage
		var y = 0;
		for (l in history) {
			var mc : MCField = cast sdm.attach("logLine",Data.DP_TOP);
			mc.field.text = l.str;
			mc.field.textColor = l.col;
			mc.field._y = y;
			y += Math.round(mc.field.textHeight);
		}

	}

	override public function update() {
		super.update();
		if ( Tutorial.at(Tutorial.get.second,"showLog3" ) )
			Tutorial.point(dm, win.close._x+10, win.close._y+30, 180);
	}
}