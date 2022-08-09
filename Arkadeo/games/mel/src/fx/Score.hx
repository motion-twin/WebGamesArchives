package fx;

import flash.text.TextField;
using mt.gx.Ex;

class Score extends flash.display.Sprite
{
	var tfs :  Array<TextField>;
	
	public function new( msg : String, create : String -> TextField ) 
	{
		super();
		tfs = [];
		var msgs : Array<String> = msg.split("|");
		
		for ( m in msgs )
		{
			var tf;
			tfs.pushBack( tf = create( m ) );
			addChild( tf );
		}
	}
	
	
}