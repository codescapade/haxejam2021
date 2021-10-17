// sample script component code

// definition of the component data, passed as `self` to the callback methods
typedef HelloData = {
	// fields with @property annotation will show up in the editor
	@property(9000) var power:Int;
}

// component class that defines the callback methods
// after compiling Haxe, the `Hello.script` will appear in the Defold project that can be attached to game objects
class Hello extends defold.support.Script<HelloData> {
	// the `init` callback method
	override function init(self:HelloData) {
		trace('Haxe is over ${self.power}!'); // will be printed to the debug console
	}
}
