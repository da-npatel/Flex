///
//	RegularButton v 1.7 for ActionScript 3 (AS3)
//	Russell Lowke, April 7th 2009
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
//	The very useful RegularButton class
//
//	RegularButton extends the Flash SimpleButton class and caters for extra 
//	control that is often needed with buttons, such as selected and disabled 
//	states, click sounds, click simulations, and keyboard shortcuts.
//
//	RegularButton also fixes an annoying bug in SimpleButton which sometimes 
//	(though not always) occurs, where the button's up frame appears ("flickers") 
//	for an instant between the over frame and the down frame when the user 
//	clicks the button.
//
//	RegularButton is intended to be used as a Flash AS3 base class that's linked 
//	to a SimpleButton Flash symbol. See the example RegularButton.fla to see 
//	exactly how this works.
//
//
//	After browsing over this Class, please take time to read the full 
//	instructions at the end of the document.
//
//
//	Note: RegularButton is dependent on the helper classes com.lowke.utils.Delay 
//	and com.lowke.utils.DoLater
//

package com.lowke.utils {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.utils.getTimer;
	
	import com.lowke.utils.Delay;
	import com.lowke.utils.DoLater;
	
	public class RegularButton extends SimpleButton {
		
		//
		// dispatched events
		public static const UNPRESS_EVENT:String = "regularButton_unpress";
		
		private var _upGraphic:DisplayObject;				// up display graphic, separate from actual upState frame of SimpleButton
		private var _overGraphic:DisplayObject;				// over display graphic, separate from actual overState frame of SimpleButton
		private var _downGraphic:DisplayObject;				// down display graphic, separate from actual downState frame of SimpleButton
		private var _hitTestGraphic:DisplayObject;			// hitTest display graphic, not to be confused with actual hitTestState of SimpleButton
		private var _disabledGraphic:DisplayObject;			// disabled display graphic, must be passed in using set disabledGraphic or setButton
		private var _enabled:Boolean = true;				// if false then button disabled and non-functional
		private var _selected:Boolean = false;				// if true then button flagged as selected and will show as its down frame
		private var _rolled:Boolean = false;				// true if the mouse over the button (read only)
		private var _pressed:Boolean = false;				// true if the button is pressed (read only)
		private var _timeOfMouseDown:uint = 0;				// clock time when mouseDownEvent recieved, if 0 then mouse is up
		private var _pressDuration:int = 150;				// minimum clickEvent duration, in milliseconds
		private var _tempDuration:int = -1;					// sometimes a temporary pressDuration is used
		private var _disabledAlpha:Number = 0.35;			// alpha value used on the button when disabled if no _disabledGraphic
		private var _keyCodes:Array = new Array();			// list of keyCodes this button listens for
		private var _clickSound:Sound;						// sound triggered when button clicked
		private var _rollOverSound:Sound;					// sound triggered on rollOver
		private var _rollOutSound:Sound;					// sound triggered on rollOut
		private var _id:int;
		
		public function RegularButton() {
			super();
			
			// save the frame graphics of the Simple Button
			_upGraphic		 = this.upState;
			_overGraphic	 = this.overState;
			_downGraphic	 = this.downState;
			_hitTestGraphic	 = this.hitTestState;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
		}
		
		private function addedToStage(evt:Event):void {
			
			// start listening for mouse events
			addEventListener(MouseEvent.CLICK, clickEvent, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent, false, 0, true);
			addEventListener(MouseEvent.ROLL_OVER, rollOverEvent, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, rollOutEvent, false, 0, true);
			
			// start listening to the stage for keyboard events
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownEvent, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, stageKeyUpEvent, false, 0, true);
			
			// make sure the button displays correctly
			update();
			
			// Flash MovieClip timeline buttons are often added non-programmatically.
			//	it can be very useful to inform the MovieClip parent that 
			//	this button has been added
			if (this.parent is MovieClip) {
				try {
					(this.parent as MovieClip).buttonAdded(this);
				} catch (err:Error) {}	
			}
		}
		
		private function removedFromStage(evt:Event):void {
			
			// ensure all listeners are also removed
			removeEventListener(MouseEvent.CLICK, clickEvent);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent);
			removeEventListener(MouseEvent.ROLL_OVER, rollOverEvent);
			removeEventListener(MouseEvent.ROLL_OUT, rollOutEvent);
			
			// in particular, remove keyboard listeners from stage
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownEvent);
			stage.removeEventListener(KeyboardEvent.KEY_UP, stageKeyUpEvent);
			
			// ensure button not shown as rolled if added back later
			_rolled = false;
			
			// Flash MovieClip timeline buttons are often added non-programmatically.
			//	it can be very useful to inform the MovieClip parent that 
			//	this button has been removed
			if (this.parent is MovieClip) {
				try {
					(this.parent as MovieClip).buttonRemoved(this);
				} catch (err:Error) {}	
			}
		}
		
		//
		// update the button according to _rolled, _selected and _enabled
		public function update():void {
			
			// restore the button
			if (_rolled) {
				// this fixes a glitch in SimpleButton
				//	where the upState appears ("flickers") for an instant 
				//	when the user clicks the button
				this.upState = _overGraphic;
			} else {
				this.upState = _upGraphic;
			}
			
			this.overState = _overGraphic;
			this.downState = _downGraphic;
			this.hitTestState = _hitTestGraphic;
			
			if (_selected || _pressed) {
				this.upState = _downGraphic;
				this.overState = _downGraphic;
			}
			
			if (! _enabled) {

				// disable button by taking away its hot spot
				this.hitTestState = null;
				
				// and show as disabled
				
				// use disbaled image if one available
				if (_disabledGraphic) {
					this.upState = _disabledGraphic;
				} else {
					// otherwise use the disabled alpha
					this.alpha = _disabledAlpha;
				}
			}
		}
		
		private function rollOverEvent(evt:MouseEvent):void {
			_rolled = true;
			if (_rollOverSound) {
				_rollOverSound.play();
			}
			
			update();
		}
		
		private function rollOutEvent(evt:MouseEvent):void {
			_rolled = false;
			if (_rollOutSound) {
				_rollOutSound.play();
			}
			
			update();
		}
		
		private function mouseDownEvent(evt:MouseEvent):void {
			
			// press the button in and record time of press
			_timeOfMouseDown = getTimer();
			_pressed = true;
			update();
			
			// listen for sneaky mouse out
			addEventListener(MouseEvent.ROLL_OUT, unpress, false, 0, true);
		}
		
		private function clickEvent(evt:MouseEvent):void {
			
			if (_clickSound) {
				_clickSound.play();
			}
			
			// ensure button remains pressed for pressDuration
			var durationOfClick:int = getTimer() - _timeOfMouseDown;
			var waitTime:int = ((_tempDuration > -1) ? _tempDuration : _pressDuration) - durationOfClick;
			Delay.delay(waitTime, unpress);
			_timeOfMouseDown = 0;
			_tempDuration = -1;
			
			// return listers to normal
			removeEventListener(MouseEvent.ROLL_OUT, unpress);
		}
		
		private function unpress(evt:MouseEvent = null):void {
			_pressed = false;
			update();
			dispatchEvent(new Event(UNPRESS_EVENT));
		}
		
		private function stageKeyDownEvent(evt:KeyboardEvent):void {
			if (_keyCodes.indexOf(evt.keyCode) > -1 &&
				! _pressed && _enabled && this.visible) {
					
				// have the button dispatch a mouse down event for emulation
				dispatchEvent(new MouseEvent(flash.events.MouseEvent.MOUSE_DOWN));
			}
		}
		
		private function stageKeyUpEvent(evt:KeyboardEvent):void {
			if (_keyCodes.indexOf(evt.keyCode) > -1) {
				finishClickButton();
			}
		}
		
		//
		// simulate a button click
		public function clickButton(pressDuration:int = -1):void {
			
			_tempDuration = pressDuration;
			
			if (! _pressed && _enabled && this.visible) {
			
				// have the button dispatch a mouse down event for emulation
				dispatchEvent(new MouseEvent(flash.events.MouseEvent.MOUSE_DOWN));
				
				// wait a frame to ensure button shown as down
				DoLater.doLater(finishClickButton);
			}
		}
		private function finishClickButton():void {
			if (_pressed && _enabled && this.visible) {
				dispatchEvent(new MouseEvent(flash.events.MouseEvent.CLICK));
				dispatchEvent(new MouseEvent(flash.events.MouseEvent.MOUSE_UP));
			}
		}
		
		public function addKey(key:String):void {
			addKeyCode((key).charCodeAt(0));
		}
		
		public function removeKey(key:String):void {
			removeKeyCode((key).charCodeAt(0));
		}
		
		public function addKeyCode(keyCode:int):void {
			_keyCodes.push(keyCode);
		}
		
		public function removeKeyCode(keyCode:int):void {
			var index:int = _keyCodes.indexOf(keyCode);
			if (index > -1) {
				_keyCodes.splice(index, 1);
			} else {
				throw new Error("KeyCode:" + keyCode + " does not exist on button \"" + this.name + "\"");
			}
		}
		
		public function clearKeys():void {
			_keyCodes = new Array();
		}
		
		
		//
		// accessors and mutators
		
		public override function set enabled(val:Boolean):void {
			if (val != _enabled) {
				_enabled = val;
				if (_enabled) {
					// returning the alpha to 1 done here rather
					// than in update() so to be less destructive,
					// the user might be using a custom alpha
					if (! _disabledGraphic) {
						this.alpha = 1.0;
					}
				}
				update();
			}
		}
		
		public function set selected(val:Boolean):void {
			if (val != _selected) {
				_selected = val;
				update();
			}
		}
		
		public function set upGraphic(val:DisplayObject):void		{ _upGraphic = val;				update(); }
		public function set overGraphic(val:DisplayObject):void		{ _overGraphic = val;			update(); }
		public function set downGraphic(val:DisplayObject):void		{ _downGraphic = val;			update(); }
		public function set hitTestGraphic(val:DisplayObject):void	{ _hitTestGraphic = val;		update(); }
		public function set disabledGraphic(val:DisplayObject):void { _disabledGraphic = val;		update(); }
		public function set disabledAlpha(val:Number):void			{ _disabledAlpha = val;			update(); }
		public function set pressDuration(val:int):void				{ _pressDuration = val; }
		public function set clickSound(val:Sound):void				{ _clickSound = val; }
		public function set rollOverSound(val:Sound):void			{ _rollOverSound = val; }
		public function set rollOutSound(val:Sound):void			{ _rollOutSound = val; }
		
		
		public override function get enabled():Boolean				{ return _enabled; }
		public function get selected():Boolean						{ return _selected; }
		public function get disabledAlpha():Number					{ return _disabledAlpha; }
		public function get rolled():Boolean						{ return _rolled; }
		public function get pressed():Boolean						{ return _pressed; }
		public function get pressDuration():int						{ return _pressDuration; }
		public function get timeOfMouseDown():uint					{ return _timeOfMouseDown; }
		public function get upGraphic():DisplayObject				{ return _upGraphic; }
		public function get overGraphic():DisplayObject				{ return _overGraphic; }
		public function get downGraphic():DisplayObject				{ return _downGraphic; }
		public function get hitTestGraphic():DisplayObject			{ return _hitTestGraphic; }
		public function get disabledGraphic():DisplayObject			{ return _disabledGraphic; }
		public function get clickSound():Sound						{ return _clickSound; }
		public function get rollOverSound():Sound					{ return _rollOverSound; }
		public function get rollOutSound():Sound					{ return _rollOutSound; }

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
		}


	}
}


//		
//	The very useful RegularButton Class
//
//	RegularButton also caters for various fundamental controls that are often 
//	needed with buttons, such as:
//
//
//	1) SHOWING THE BUTTON AS SELECTED
//
//	You can show the button as selected by setting the selected parameter to 
//	true. This is useful for multiple choice questioners or surveys where the 
//	user can select multiple answers. 
//
//		// will cause button to show "pressed in," as selected.
//		myBtnInstance.selected = true;
//
//	It's often desirable to have the button toggle the selected parameter, 
//	like so,
//
//		myBtnInstance.addEventListener(MouseEvent.CLICK, toggleSelect);
//
//		public function toggleSelect(evt:Event):void {
//			myBtnInstance.selected = ! myBtnInstance.selected;
//		}
//
//
//	2) DISABLING THE BUTTON
//
//	If a button is set to enabled = false it will automatically disable
//	visually with a "gray out" alpha. 
//	
//		// will cause button to disable and become grayed out.
//		myBtnInstance.enabled = false;
//
//	The default alpha value for graying out a button is 0.35, you can tweak 
//	this alpha by setting the disabledAlpha parameter
//
//		myBtnInstance.disabledAlpha = 0.5;		// default is 0.35
//
//	To ignore this effect you can set the disabledAlpha to 1, or, 
//	if you need more control, you can assign the button its own disabled  
//	graphic to be used to disable the button, in which case the disabledAlpha
//	parameter is ignored.
//
//		// where myBtnDisabledGraphic is a DisplayObject
//		myBtnInstance.disabledGraphic = myBtnDisabledGraphic;
//		myBtnInstance.enabled = false;
//
//
//	3) ASSIGNING CLICK AND ROLL SOUNDS
//	
//	The button can have a click sound associated with it which plays 
//	automatically when the button is clicked.
//
//		// where myClickSound is of type Sound
//		myBtnInstance.clickSound = myClickSound;
//
//	Sounds can also be assigned for roll over and roll out,
// 
//		myBtnInstance.rollOverSound = myRollOverSound;
//		myBtnInstance.rollOutSound = myRollOutSound;
//
//
//	4) DON'T FORGET AUTOMATIC TAB ORDER
//
//	The Flash Player has an automatic tab order that responds to user 
//	presses of the Tab, Arrow, and Enter keys to change focus when
//	in a browser. Automatic tab order includes the following objects:
//	  - Instances of TextField on the display list and have their
//		type variable set to TextFieldType.INPUT.
//	  - Instances of Sprite or MovieClip that are on the display list 
//		and have their buttonMode or tabEnabled variable set to true.
//	  - Instances of SimpleButton.
//	As RegularButton extends SimpleButton it will be included in the
//	automatic tab order.
//	
//	To exclude RegularButton from automatic tab order you need to
//	set its tabEnabled to false. There is also a focusRect variable
//	that you might also want to disable,
//
//		// turn off pesky tabEnabled and focusRect
//		myBtnInstance.tabEnabled = false;
//		myBtnInstance.focusRect = false;
//
//	Fortunately, you can disable automatic tab order for all buttons
//	by setting the stage instance's tabChildren variable to false
//
//		// turn off automatic tabbing and focus rectangles
//		stage.tabChildren = false;
//		stage.stageFocusRect = false;
//
//
//	5) RESPONDING TO KEYS
//
//	RegularButton can automatically respond to key strokes as a keyboard 
//	shortcut. Use of assigned keys will make the button click.
//
//		myBtnInstance.addKeyCode(13);	// respond to enter/return
//		myBtnInstance.addKeyCode(32);	// respond to space
//
//	other useful keyCodes:		 16;	// Shift
//								 27;	// ESC
//								 37;	// Left Arrow
//								 38;	// Up Arrow
//								 39;	// Right Arrow
//								 40;	// Down Arrow
//
//	Key codes may also be set using the addKey() function, such as,
// 
//		// button responds to 'A' or 'a'
//		myBtnInstance.addKey('A');
//
//		// button also responds to space,
//		myBtnInstance.addKey(' ');
//		//	this is the same as, myBtnInstance.addKeyCode(32);
//
//	addKey() simply delegates to addKeyCode(), so they are 
//	effectively the same call.
//
//	Use removeKey() or removeKeyCode() to remove assigned keys,
//
//		myBtnInstance.removeKey('A');
//		myBtnInstance.removeKeyCode(32);
//
//	Similarly, removeKey() delegates to removeKeyCode().
//
//	Use clearKeys() to remove all assign keyCodes.
//
//		myBtnInstance.clearKeys();
//
//	Use keyCodes with great caution as they might conflict with other elements.
//	For instance, if you have an editable text field on the stage as well as a 
//	button that responds to the 'A' key, the button will trigger every time 
//	the user presses 'A' while typing into the text field.
//	In such cases you will have to remove the button's 'A' keyCode while the 
//	text field has focus, and add it back when the text field loses focus.
//
//	RegularButton, being a SimpleButton, is automatically added to the automatic 
//	tab order, and so automatically responds to Tab, Enter and arrow key input
//	when in a browser (see 4. above). If you assign Tab, Enter or arrow keyCodes 
//	you probably want to turn the automatic tab order off.
//
//
//	6) PRESS DURATION
//
//	A minimum press duration may be set,
//
//		// pressDuration in milliseconds, the default is 150
//		myBtnInstance.pressDuration = 500;	
//
//	Also, you can listen for when a button becomes unpressed by listening for
//	RegularButton.UNPRESS_EVENT, e.g.
//
//		myBtnInstance.addEventListener(RegularButton.UNPRESS_EVENT, funct);
//
//
//	7) SIMULATING BUTTON CLICKS
//
//	You can tell the button to click using the clickButton() method,
//
//		myBtnInstance.clickButton();
//
//	In which case the button will behave as though it were just clicked	 
//	and will dispatch the usual MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP 
//	and MouseEvent.CLICK events.
//
//	You may also specify a pressDuration to use with the button press, this
//	is useful for tutorials where you want to emphasize the button click, say,
//	for half a second, e.g.
//
//		myBtnInstance.clickButton(500);
//
//
//	8) BUTTONADDED AND BUTTONREMOVED METHODS
//
//	Buttons on a MovieClip timeline are often added or removed 
//	non-programmatically by the timeline. It can be very helpful for 
//	RegularButton to inform its MovieClip parent that it has been added or 
//	removed.
//
//	If RegularButton detects that its parent is a MovieClip it will 
//	try to call the parent when the button is added or removed with,
//
//		buttonAdded(buttonInstance);		// when the button is added 
//		buttonRemoved(buttonInstance);		// when the button is removed.
//
//	This is very useful in Flash timeline situations where the timeline 
//	dictates when and where buttons are added or removed rather than code.
//
//	buttonAdded() and buttonRemoved() methods are not required, and if not
//	found will not affect RegularButton or cause an error to be thrown.
//