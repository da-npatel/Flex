package com.digitalaisle.uilibrary.components.panels
{
	import com.digitalaisle.uilibrary.data.PanelObject;
	import com.digitalaisle.uilibrary.skins.LoadingPanelSkin;
	import com.digitalaisle.uilibrary.supportClasses.PanelBase;
	
	import mx.events.FlexEvent;
	import mx.states.State;
	
	import spark.core.SpriteVisualElement;
	
	/**
	 *  Normal state
	 */
	[SkinState("normal")]
	
	/**
	 *  Loading state
	 */
	[SkinState("loading")]
	
	public class LoadingPanel extends PanelBase
	{
		[Bindable]
		public static var LOAD_MORE:String = "Load More";
		[Bindable]
		public static var LOADING:String = "Loading";
		
		public var spinningLoader:SpriteVisualElement;
		
		public function LoadingPanel()
		{
			super();
			setStyle("skinClass", LoadingPanelSkin);
		
		}
		override public function initialize():void
		{
			super.initialize();
			
			states.push(new State({name:"normal"}));
			states.push(new State({name:"loading"}));
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
		
		override protected function applySettings(settingsObj:PanelObject):void
		{
			
		}
		
		override protected function onPanelAdded(e:FlexEvent):void
		{
			super.onPanelAdded(e);
			currentState = "normal";
		}
	}
}