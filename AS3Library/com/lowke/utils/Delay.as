///
//	Delay v 1.4 for ActionScript 3
//	Russell Lowke, May 8th 2009
// 
//	Copyright (c) 2009 Russell Lowke
//	see http://www.lowkemedia.com for more information
// 
//	Permission is hereby granted, free of charge, to any person obtaining a 
//	copy of this software and associated documentation files (the "Software"), 
//	to deal in the Software without restriction, including without limitation 
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//	and/or sell copies of the Software, and to permit persons to whom the 
//	Software is furnished to do so, subject to the following conditions:
// 
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
// 
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
//	IN THE SOFTWARE. 
//
//

//
//	The very useful Delay class
//
//	Tells ActionScript to call a function just once after a specified interval.
//
//	Usage:
//
//		import com.lowke.utils.Delay;
//		Delay.delay(delay, funct, ...args);
//
//	Where the function funct will be called and any args passed to it after	 
//	delay milliseconds.
//
//	For example,
//	To call method afterASecond() after one second and pass it two arguments,
//
//		import com.lowke.utils.Delay;
//	
//		public function triggerDelay():void {
//			Delay.delay(1000, afterASecond, "hello", 12345);
//		}
//
//		public function afterASecond(arg1:String, arg2:Number):void {
//			trace("after a second (1000 milliseconds)");
//			trace("Got arg1:" + arg1 + "  and got arg2:" + arg2);
//		}
//
//
//	delay() should be used in preference to the deprecated 
//	flash.utils.setTimeout(), which doesn't clear from memory, requiring a 
//	subsequent clearTimeout() call. Unlike setTimeout(), delay() will clear 
//	itself from memory once finished.
//
//	Note: Adobe would prefer you to listen to an event from the Timer class, 
//	which is safer but much more cumbersome. delay() is a great convenience, 
//	just be sure your function is still valid when it comes time for it to
//	be called.
//

package com.lowke.utils {

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class Delay {
		
		//
		// member variables
		private var _funct:Function;	// function to be called
		private var _args:Array;		// arguments to be sent to function
		private var _timer:Timer;		// flash timer used to delay the call
		
		//
		// constructor
		public function Delay(delay:Number, funct:Function, args:Array) {
			_funct = funct;
			_args  = args;
			
			// delay must be positive
			if (delay < 0) {
				delay = 0;
			}
			_timer = new Timer(delay, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, trigger);
			_timer.start();
		}
		
		public function trigger(evt:TimerEvent):void {
			
			// remove the listener
			close();
			
			// call the function, passing into it args
			if (_funct != null) {
				_funct.apply(null, _args);
			}
		}
		
		//
		// stop timer and remove the listener
		public function close():void {
			
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, trigger);
			_timer = null;
		}
		
		public static function delay(delay:Number, funct:Function, ... args):Delay {
			return new Delay(delay, funct, args);
		}
	}
}