package fx;
import mt.fx.Fx;
import mt.pix.Element;
import mt.Timer;
import Types;


class EmitNotes extends Fx
{
	var notes : Pool < ElementEx >;
	var g:Grid;
	var di :DepInfos;
	var par : Element;
	
	static var c = 60;
	public function new(g,di) 
	{
		super();
		this.g = g;
		this.di = di;
		this.par = di.ent.te.el;
		notes = new Pool(function() {
			var el = Data.getElement( "FX_NOTES");
			
			par.addChild( el );
			return el;
		});
	}
	
	var sp = 0;
	public override function update()
	{
		sp--;
		if (sp <= 0)
		{
			var el = notes.create();
			
			el.goto(Std.random(2), "FX_NOTES");
			
			el.visible = true;
			el.data.life = 0;
			el.data.maxLife = c + Dice.roll( -c>>2, c>>1);
			
			var a = Dice.rollF( 0, Math.PI);
			var ci = 8;
			el.x = 0 + Math.cos( a ) * ci;
			el.y = -10 + Math.sin( a ) * ci;
			
			sp = Dice.roll(c-20,c);
		}
		
		for ( p in notes.used)
		{
			var m = 1.3;
			p.y -= .25*m;
			p.x += .125*m;
			
			p.data.life++;
			if ( p.data.life > p.data.maxLife)
			{
				notes.destroy( p);
				p.visible = false;
			}
		}
	}
	
}