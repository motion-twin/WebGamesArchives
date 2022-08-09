// 
// $Id: Callback.as,v 1.3 2004/06/24 11:42:39  Exp $
//

class grapiz.Callback 
{
    private var object;
    private var method : Function;

    public function Callback(o, m:Function)
    {
        this.object = o;
        this.method = m;
    }

    public function execute() : Void
    {
        this.method.call(this.object);
    }

    public function execute_1(param) : Void
    {
        this.method.call(this.object, param);
    }
}

//EOF
