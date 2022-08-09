

package mt.kiroukou.lang;

class IterateFloatRange<Float>
{
    var min: Float;
    var max: Float;
    var step: Float;
    var count: Float;
    public function new ( min_: Float, max_: Float, step_: Float )
        {
        min = min_;
        max = max_;
        step = step_;
        count = min_- step_;
        }
        public function iterator ():Iterator<Float> { 
                return this;                 
        }
    public function hasNext(): Bool {
                 return count < max;
        }
    public function next(): Float
    {
        count += step;
        return count;
    }
}