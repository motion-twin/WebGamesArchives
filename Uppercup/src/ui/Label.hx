package ui;

class Label extends mt.deepnight.mui.Label {
	public function new(p,str) {
		super(p,str);

		setFont(m.Global.ME.getFont().id, m.Global.ME.getFont().size*2);
	}
}
