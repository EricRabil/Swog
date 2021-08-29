# Swog
Apple, I got a bone to pick with you

Swog is an opionated wrapper around OSLog that uses internal APIs (that frankly should be public since they allowed you to pass an array of CVarArg and a DSOHandle, working around the artificial limitations they leave).

It is mostly inlinable, and aims to be as lightweight of an abstraction as possible. You shouldn't have to type out hieroglyphics to get decent logging, and you shouldn't need to support iOS 14 and up to get logging systems we should've had at iOS 8.

Swog has a driver approach, allowing you to connect it to multiple outlets. It comes with an OSLog and Console driver, but you're welcome to add your own.

## OSLogInterpolation
Swog has backported OSLogInterpolation/OSLogMessage to allow its usage before Big Sur. This is also supported for the Console driver, and it allows privacy specifier enforcement when printing to stdout
