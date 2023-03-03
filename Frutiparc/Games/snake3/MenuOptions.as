import snake3.Const;
import snake3.Manager;

class snake3.MenuOptions extends snake3.BackgroundFX {

	var mc;
	var background;
	var panel;
	var music;
	var sound;
	var format;
	var returnMenu;

	function close() {
		super.close();
		panel.removeMovieClip();
		background.removeMovieClip();
	}

	function MenuOptions( mc ) {
		super(mc,4);
		this.mc = mc;
		background = Std.attachMC(mc,"menuBackground",0);
		panel = Std.attachMC(mc,"optionPanel",1);
		panel._x = (Const.WIDTH - panel._width) / 2;
		panel._y = (Const.HEIGHT - panel._height) / 2;

		music = Std.getVar(panel,"music");
		sound = Std.getVar(panel,"sound");
		format = Std.getVar(panel,"format");
		returnMenu = Std.getVar(panel,"returnMenu");

		format._visible = false;// HACK

		var me = this;
		function on_click() {
			return me.on_click(Std.cast(this));
		};
		music.onPress = on_click;
		sound.onPress = on_click;
		format.onPress = on_click;
		returnMenu.onPress = on_click;
		update();
	}

	function update() {
		music.text = Manager.music?"activée":"desactivée";
		sound.text = Manager.sounds?"activés":"désactivés";
	}

	function on_click(but) {
		if( but == music )
			Manager.toggleMusic();
		if( but == sound )
			Manager.toggleSounds();
		if( but == format ) {
			// TODO
		}			
		if( but == returnMenu ) {
			Manager.savePrefs();
			Manager.returnMenu();
		}
		update();
	}

	function main() {
		super.main();
	}

}