package com.digitalaisle.frontend.components {
	
	import com.digitalaisle.frontend.drawing.DynamicShape;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Label;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.core.SpriteVisualElement;
	import spark.primitives.BitmapImage;
	
	public class DATicker extends Group 
	{		
		private var _source:ArrayCollection = new ArrayCollection();
		private var _data:Object;
		private var _speed:int = 4;			// Pixels per frame		
		private var _border:int = 5;
		private var _width:int = 1280;
		private var _height:int = 60;
		private var _backgroundColor:uint = 0xffffff;
		private var _backgroundAlpha:Number = 0;
		private var _gap:int = 50;	
		//private var lbl:TextField;
		//private var tf:TextFormat;
		//private var bg:Sprite;
		//private var maskmc:Sprite;
		//private var messages:Sprite;
		//private var msgmc:Sprite;
		//private var msgmc2:Sprite;
		
		
		// Display Objects
		private var _maskElement:SpriteVisualElement;
		private var _hasContentChanged:Boolean = false;
		private var _messagesGroup:Group;
		private var _messages:HGroup;
		private var _message:HGroup;
		private var _messageFooter:HGroup;
		private var _background:BitmapImage;
		private var _tickerTextStyle:String;
		private var _isAnimating:Boolean = false;
		private var _scrollTimer:Timer = new Timer(40);
		
		public function DATicker() {			
			super();
			_scrollTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_messages = new HGroup();
			_messagesGroup = new Group();
			_maskElement = new SpriteVisualElement();
			_message = new HGroup();
			_messageFooter = new HGroup();
			
			// Define messages mask
			var maskShape:DynamicShape = new DynamicShape();
			maskShape.doDrawRect(width - (_border * 4), height - (_border * 2));
			
			_messagesGroup.addElement(_messages);
			_maskElement.addChild(maskShape);
			_messagesGroup.mask = _maskElement;
			//_message.addEventListener(FlexEvent.DATA_CHANGE, onLabelDataChange);
			
			addElement(_messagesGroup);
			
		}
		
		override protected function commitProperties():void {			
			super.commitProperties();			
		}
		
		override protected function measure():void
		{
			super.measure();
			
			minWidth = 200;
			minHeight = 50;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(_hasContentChanged)
			{
				// Clean up needed
				
				_messages.addElement(_message);
				_messages.addElement(_messageFooter);
				
				for(var i:int=0; i < _source.length; i++)
				{
					if(_source[i] is ProjectContentItem)
					{						
						_message.addElement(createMessageElement(_source[i], _tickerTextStyle));
						_messageFooter.addElement(createMessageElement(_source[i], _tickerTextStyle));
												
						//messageLabel.x = messageFooterLabel.x = _message.width + _gap;
					}
				}
				
				if(_source.length > 0)
				{
					addEventListener(Event.ENTER_FRAME, enterFrame);
				}
				
				_hasContentChanged = false;
				trace("Message = " + _message.width);
			}

			//this.verticalCenter = 5;
			
		}
		
		protected function createMessageElement(msgSrc:ProjectContentItem, textStyle:String):IVisualElement
		{
			var messageLabel:Label = new Label();
			if(textStyle)
			{
				try{
					messageLabel.styleName = textStyle;
				} catch(e:Error){
					trace("Warning: Ticker Text Style Name Does Not Exist!");
				}
			}
			
			
			messageLabel.text = msgSrc.shortDescription;
			
			return messageLabel;
		}
		
		private function enterFrame(event:Event):void
		{
			if(_messages.width > 0)
			{
				onLabelDataChange();
				removeEventListener(Event.ENTER_FRAME, enterFrame);
				
			}
		}
		
		/*protected function buildText():void {
			
			
			maskmc = new Sprite();
			maskmc.graphics.beginFill(0xff00ff, 0);
			maskmc.graphics.drawRect(0,0, _width - _border * 4, _height - _border * 2);
			maskmc.graphics.endFill();
			maskmc.x = _border;
			maskmc.y = _border;
			addChild(maskmc);
			
			messages = new Sprite()
			msgmc = new Sprite();
			msgmc2 = new Sprite();
			
			bg = new Sprite();			
			addChild(bg);
			
			tf = new TextFormat();			
			if(fm.hasFont("Myriad Pro")){ 
				tf.font = "Myriad Pro";								
			} else {				
				tf.font = "Arial";				
			}
			tf.color = "0xFFFFFF";
			tf.size = 25;
			
			
			
			
			
			
			var msgw:int = -_gap;
			for(var i:int=0; i < _data.length; i++){				
				lbl = new TextField();
				lbl.embedFonts = true;				
				lbl.defaultTextFormat = tf;
				lbl.setTextFormat(tf);
				lbl.height = 60;
				try {
					lbl.text = _data[i].message;
					lbl.autoSize = TextFieldAutoSize.LEFT;
				} catch(e:Error) { trace("DATicker "+e); }
				lbl.x = msgw + _gap * i;								
				msgmc.addChild(lbl);				
				lbl = new TextField();
				lbl.embedFonts = true;				
				lbl.defaultTextFormat = tf;
				lbl.setTextFormat(tf);
				lbl.height = 60;
				try {
					lbl.text = _data[i].message;
					lbl.autoSize = TextFieldAutoSize.LEFT;
				} catch(e:Error) { trace("DATicker "+e); }
				lbl.x = msgw + _gap * i;
				msgmc2.addChild(lbl);
				msgw += lbl.textWidth;
			}			
			msgmc.y = msgmc2.y = 30 - msgmc.height/2;
			msgmc.x = maskmc.width;
			messages.addChild(msgmc);			
			msgmc2.x = msgmc.x + msgw + _gap * (_data.length + 1);
			messages.addChild(msgmc2);
			messages.mask = maskmc;
			addChild(messages);			
						
			animate();
			
			dispatchEvent(new Event("templateitemready"));
		}*/
		
		protected function animate():void {
			//addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			_scrollTimer.start();
			//TweenLite.to(_messages, 1, {x:
			_isAnimating = true;
		}
		
		protected function onEnterFrame(e:Event):void {
			
			var pos:Number = _messages.x - _speed;
			//_message.x = _messageFooter.x -= _speed;
			//_messages.x = pos;
			//trace(_messages.x);
			
			var end:int;
			/*if(_message.x < -_message.width){
				end = _messageFooter.x + _messageFooter.width;
				if(end > width) {
					_message.x = end + _gap; 
				} else {
					_message.x = width;
				}				
			}*/
			/*if(_messageFooter.x < -_messageFooter.width){
				end = _message.x + _message.width;
				if(end > _width) {
					_messageFooter.x = end + _gap;
				} else {
					_messageFooter.x = _width;
				}
			}*/
			
		/*	msgmc.x -= _speed;
			msgmc2.x -= _speed;
			var end:int;
			if(msgmc.x < -msgmc.width){
				end = msgmc2.x + msgmc2.width;
				if(end > _width) {
					msgmc.x = end + _gap; 
				} else {
					msgmc.x = _width;
				}				
			}
			if(msgmc2.x < -msgmc2.width){
				end = msgmc.x + msgmc.width;
				if(end > _width) {
					msgmc2.x = end + _gap;
				} else {
					msgmc2.x = _width;
				}
			}*/
			
		}
				
			
		private function onTimerTick(e:TimerEvent):void
		{
			var pos:Number = _messages.x - _speed;
			_messages.x = pos;
			var end:Number;
			
			if(_message.width != 0)
			{
				if(_messages.x < -_message.width)
				{
					_messages.x = 0;
				}
			}
		}
		
		private function onCreationComplete(e:FlexEvent):void
		{
			
		}
		
		
		private function onLabelDataChange():void
		{
			if(_message.width > width)
			{
				animate();
			}else
			{
				//temp solution
				_messageFooter.visible = false;
			}
			
			trace(_message.width);
			trace(_messages.width);
		}
		
		/*override protected function measure():void {			
			measuredWidth = measuredHeight = _width;
			measuredMinWidth = measuredMinHeight = _height;	
		}*/
		
		
		// Getters & Setters ========================================================================================		
		
		/*public function get data():Object { return _data; }
		public function set data(value:Object):void { _data = value; buildText(); } */
		public function get speed():int	{ return _speed; }
		public function set speed(value:int):void {	_speed = value;	}
		public function get w():int	{ return _width; }
		public function set w(value:int):void {	_width = value;	}
		public function get h():int { return _height; }
		public function set h(value:int):void { _height = value; }
		public function get gap():int {	return _gap; }
		public function set gap(value:int):void	{ _gap = value; }

		public function get source():ArrayCollection
		{
			return _source;
		}

		[Bindable]
		public function set source(value:ArrayCollection):void
		{
			_hasContentChanged = true;
			_source = value;
			invalidateDisplayList();
		}

		public function get tickerTextStyle():String
		{
			return _tickerTextStyle;
		}

		public function set tickerTextStyle(value:String):void
		{
			_tickerTextStyle = value;
		}


	}
}