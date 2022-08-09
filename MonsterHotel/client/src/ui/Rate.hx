package ui;

import com.GameData;
import com.Protocol;
import com.*;
import Data;
import mt.deepnight.Lib;
import mt.MLib;

class Rate extends ui.Question {
	public function new() {
		super(false);

		autoClose = false;

		#if connected
		mt.device.EventTracker.view("ui.Rate");
		#end

		addTitle( Lang.t._("Tell us what you think!") );
		addText(Lang.t._("We really need your help to make things better: what do you think of our game so far?"));

		var ctx = addEmptyFrame(150);
		for(n in 0...5) {
			var w = maxWid/5;
			var i = new h2d.Interactive(w,w, ctx);
			i.x = w*n;
			i.onClick = function(_) rate(ctx, w, n);
			var s = Assets.tiles.h_get("rateStarOff",0, 0,0, true, i);
			s.constraintSize(w);
		}

		addSeparator();
		addButton(Lang.t._("Ask me later"), onLater);
		addButton(Lang.t._("Never ask me again"), onNever);
	}

	function track(id:String) {
		#if connected
		mt.device.EventTracker.track("ui.rate", id);
		#end
	}

	function rate(ctx:h2d.Sprite, w:Float, n:Int) {
		if( cd.has("rated") )
			return;
		cd.set("rated", 9999);

		track("star"+(n+1));

		Game.ME.runSolverCommand( DoRate(false) );

		for(n in 0...n+1) {
			var s = Assets.tiles.h_get("rateStarOn",0, 0,0, true, ctx);
			s.constraintSize(w);
			s.x = w*n;
			s.visible = false;
			delayer.add( function() {
				s.visible = true;
				Game.ME.uiFx.rate(wrapper.x+(ctx.x+s.x+w*0.5)*wrapper.scaleX, wrapper.y+(ctx.y+w*0.5)*wrapper.scaleY, getScale());
			}, n*70);
		}

		delayer.add( function() {
			clearContent();
			if( n+1>=4 ) {
				// redirect to store
				addText(Lang.t._("Thank you! Your feedbacks are REALLY important to us."));
				addText(Lang.t._("Would you like to rate our game on the store too?"));
				addButton(Lang.t._("YES! :)"), function() {
					#if mBase
					mtnative.device.Device.showStoreProduct();
					#end
					destroy();
				});
				addSeparator();
				addButton(Lang.t._("Not now, thanks"), function() {
					destroy();
				});
				//destroy();
			}
			else {
				addText(Lang.t._("Thanks for your honest answer! Did you encounter any PROBLEM while playing?"));
				addButton(Lang.t._("I didn't like the game"), onReport.bind("dislike"));
				addButton(Lang.t._("I encountered a bug"), onReport.bind("bug"));
				addButton(Lang.t._("The game is slow on my device"), onReport.bind("slow"));
				addButton(Lang.t._("The game requires an internet connection"), onReport.bind("reqConnect"));
				addSeparator();
				addButton(Lang.t._("Nothing, thanks for asking :)"), function() {
					track("noReason");
					destroy();
				});
			}
		}, 1500);
	}


	function onReport(reason:String) {
		clearContent();
		track(reason);

		if( reason=="bug" ) {
			var desc = "";
			addText(Lang.t._("Oh, sorry to hear about that :("));
			addText(Lang.t._("If you tell us WHAT happened and WHERE, we will fix it in the next update, promise!"));
			addInput(desc, true, function(s) desc = s);
			addButton(Lang.t._("Finish"), function() {
				destroy();
			});
		}
		else {
			addText(Lang.t._("Thank you for reporting! We will do our best to make this game better (yes, seriously)."));
			addCancel(Lang.t._("You're welcome :)"));
		}
	}


	function onLater() {
		if( cd.has("rated") )
			return;

		track("askLater");
		Game.ME.runSolverCommand( DoRate(true) );
		destroy();
	}

	function onNever() {
		if( cd.has("rated") )
			return;

		track("never");
		Game.ME.runSolverCommand( DoRate(false) );
		destroy();
	}


	override function onCancel() {
		destroy();
	}

}
