package com.digitalaisle.uilibrary.components.buttons
{
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	
	public class DAButton extends Button
	{
		/**
		 *  @private
		 *  Storage for the selected property 
		 */
		private var _selected:Boolean;
		
		[Bindable]
		
		/**
		 *  Contains <code>true</code> if the button is in the down state, 
		 *  and <code>false</code> if it is in the up state.
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */    
		public function get selected():Boolean
		{
			return _selected;
			
		}
		
		/**
		 *  @private
		 */    
		public function set selected(value:Boolean):void
		{
			if (value == _selected)
				return;
			// TODO: Might need to disable the button upon selected
			_selected = value;            
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			invalidateSkinState();
		}
		
		private var _toggle:Boolean;
		
		[Bindable]
		public function get toggleEnabled():Boolean
		{
			return _toggle;
		}
		
		public function set toggleEnabled(value:Boolean):void
		{
			_toggle = value;
		}
		
		public function DAButton()
		{
			super();
		}
		
		/**
		 *  @private
		 */ 
		override protected function getCurrentSkinState():String
		{	
			if(toggleEnabled)
			{
				if(selected)
					return "down";
				else
					return "up";
			}else
			{
				if (!selected){
					return super.getCurrentSkinState();
				}else
					return "down";
			}
		}
		
		/**
		 *  @private
		 */ 
		override protected function buttonReleased():void
		{
			if(toggleEnabled)
			{
				super.buttonReleased();
				selected = !selected;
				dispatchEvent(new Event(Event.CHANGE));
			}else
			{
				if(!_selected)
				{
					super.buttonReleased();
					dispatchEvent(new Event(Event.CHANGE));
				}
			}
		}
	}
}