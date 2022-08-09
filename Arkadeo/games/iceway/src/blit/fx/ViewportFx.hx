package blit.fx;

/**
 * ...
 * @author Thomas
 */

interface ViewportFx
{
	
	public function before( viewport : blit.BitmapViewport ):Void;
	
	public function after( viewport : blit.BitmapViewport ):Void;
}