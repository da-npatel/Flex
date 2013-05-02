package com.digitalaisle.uilibrary.keypads
{
	import com.digitalaisle.uilibrary.skins.DefaultKeyboardSkin;
	import com.digitalaisle.uilibrary.skins.EmailKeyboardSkin;
	import com.digitalaisle.uilibrary.skins.EmailKeypadSkin;
	import com.digitalaisle.uilibrary.supportClasses.KeyboardBase;
	
	import mx.events.FlexEvent;
	import mx.states.State;

	/**
	 *  Letter state of the keyboard
	 */
	[SkinState("letter")]
	
	/**
	 *  Numeric state of the keyboard
	 */
	[SkinState("numeric")]
	
	/**
	 *  Normal state of the keyboard
	 */
	[SkinState("normal")]
	
	/**
	 *  Disabled state of the keyboard
	 */
	[SkinState("disabled")]
	
	public class Keyboard extends KeyboardBase
	{
		public static const DEFAULT:String = "default";
		public static const EMAIL:String = "email"
		public static const EMAIL_PAD:String = "emailPad";
			
		public function Keyboard()
		{
			super();
			type = DEFAULT;
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			states.push(new State({name:"letter"}));
			states.push(new State({name:"numeric"}));
			states.push(new State({name:"normal"}));
			states.push(new State({name:"disabled"}));
		}
		
		override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void
		{
			super.stateChanged(oldState, newState, recursive);
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			return currentState;
		}
		
		override protected function toggleKeyboardLayouts():void
		{
			switch(currentState)
			{
				case "letter":
					currentState = "numeric";
					break;
				case "numeric":
					currentState = "letter";
					break;
			}
		}
		
		override protected function onCreationComplete(e:FlexEvent):void
		{
			super.onCreationComplete(e);
			currentState = "letter";
		}
		
		override public function set type(value:String):void
		{
			super.type = value;
			switch(value)
			{
				case DEFAULT:
					setStyle("skinClass", DefaultKeyboardSkin);
					break;
				case EMAIL:
					setStyle("skinClass", EmailKeyboardSkin);
					break;
				case EMAIL_PAD:
					setStyle("skinClass", EmailKeypadSkin);
					break;
				default:
					setStyle("skinClass", DefaultKeyboardSkin);
					break;
			}
		}
	}
}