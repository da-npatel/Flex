///
//	DoLater v 1.4 for ActionScript 3 (AS3)
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
//	The very useful DoLater class
//
//	Unlike traditional programming languages, ActionScript is executed within 
//	the Flash Player. Flash is based on the movie concept of a timeline, where 
//	symbols and code can be placed on various frames and Flash movies run at 
//	specified frame rates. Flash updates the visuals (color, object placement, 
//	size, etc.) at the end of the frame. This gives the ActionScript in the 
//	frame a chance to execute and set up the visual changes.
//	
//	The doLater() method, as defined in the Flex mx.core.UIObject, allows you to 
//	queue a function to be called after the frame has been updated. A function 
//	might need to be called in the next update to allow the rest of the code 
//	scheduled for the current update to be executed.
//
//	Paradoxically, regular Flash Actionscript 3 has no inbuilt doLater() function 
//	like the Flex UIObject component (Flex mx.core.UIObject). 
// 
//	This DoLater Class fills that gap.
//
//
//	Usage:
//
//		DoLater.doLater(funct, ... args);
//
//	Where the function funct will be called and args passed to it *after* the 
//	next Event.ENTER_FRAME, once the frame has updated and actionscript on the 
//	frame has been executed.
//
//
//	There is also a doNext() function,
//
//		DoLater.doNext(funct, ... args);
//
//	Where the function funct will be called and args passed to it *on* the next 
//	Event.ENTER_FRAME, which is before actionscript on the frame has been 
//	executed.
//
		
package com.lowke.utils {

	import flash.display.Sprite;
	import flash.events.Event;

	public class DoLater {
		
		// a static _sprite is used to listen for ENTER_FRAME events,
		//	this is an assured way of getting access to stage.
		private static var _sprite:Sprite = new Sprite();
		
		//
		// member variables
		private var _funct:Function;		// function to be called later
		private var _args:Array;			// arguments to be sent to function
		private var _ready:Boolean;			// wait one ENTER_FRAME to ensure the whole frame has loaded
		
		//
		// constructor
		public function DoLater(funct:Function, args:Array) {
			_ready = false;
			_funct = funct;
			_args  = args;
			
			// Note: this listener must be a hard listener and not soft
			//	as it is intended to be the only reference to the DoLater object
			_sprite.addEventListener(Event.ENTER_FRAME, trigger);
		}
		
		public function trigger(evt:Event):void {
			
			if (_ready) {
				
				// remove the listener
				close();
				
				// call the function, passing into it args
				if (_funct != null) {
					_funct.apply(null, _args);
				}
				
			} else {
				
				// wait one ENTER_FRAME to ensure the frame has loaded
				//	and trigged Actionscript on the frame.
				_ready = true;
			}
		}
		
		public function close():void {
			
			// remove the event listener, clearing DoLater.
			//	This listener is the main reference to the DoLater object,
			//	removing it should dispose the object, so long as
			//	the main app also disposes of any reference.
			_sprite.removeEventListener(Event.ENTER_FRAME, trigger);
		}
		
		public function set ready(val:Boolean):void {
			_ready = val;
		}
		
		// usually you want the function to trigger after the
		//	frame has updated and all items/code on various MovieClips
		//	have been fully executed, so use doLater().
		public static function doLater(funct:Function, ... args):DoLater {
			return new DoLater(funct, args);
		}
		
		// ...but sometimes it is advantagious to have the function
		//	trigger before the frame has fully updated, so use doNext().
		public static function doNext(funct:Function, ... args):DoLater {
			var obj:DoLater = new DoLater(funct, args);
			obj.ready = true;
			return obj;
		}
	}
}