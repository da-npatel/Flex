package com.digitalaisle.uilibrary.supportClasses
{
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.enums.ControlType;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.states.State;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	
	/**
	 *  Items state of the Item flow
	 */
	[SkinState("items")]
	
	/**
	 *  Item state of the Item flow
	 */
	[SkinState("item")]
	
	public class ItemFlowBase extends SkinnableComponent
	{
		/** Skin Parts **/
		[SkinPart(required="false")]
		public var backgroundImage:Image;
		
		private var _projectContentItem:ProjectContentItem;
		private var _projectContentItems:ArrayCollection;
		private var _selectedProjectContentItem:ProjectContentItem;
		
		public function ItemFlowBase()
		{
			super();
		}
		
		public override function initialize():void
		{
			super.initialize();
			states.push(new State({name:"items"}));
			states.push(new State({name:"item"}));
		}
		
		
		override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void
		{
			super.stateChanged(oldState, newState, recursive);
			invalidateSkinState();
		}
		
		protected override function getCurrentSkinState():String
		{
			return currentState;
		}
		
		public function next(selectedId:int):ProjectContentItem
		{
			if(selectedId)
			{
				selectedProjectContentItem = DataManager.getInstance().fetchProjectContentItemById(selectedId);
				currentState = "item";
				return selectedProjectContentItem;
			}else
				return null;
		}
		
		public function prev():void
		{
			currentState = "items";
		}

		
		public function get projectContentItem():ProjectContentItem
		{
			return _projectContentItem;
		}

		public function set projectContentItem(value:ProjectContentItem):void
		{
			if(projectContentItem === value){
				currentState = "items";
				return;
			}

			_projectContentItem = value;
			if(backgroundImage)
				backgroundImage.source = projectContentItem.fetchBinaryContentByType(BinaryType.BACKGROUND_IMAGE);
			projectContentItems = DataManager.getInstance().fetchRelatedItemsByOwnerId(projectContentItem.id);
			currentState = "items";
		}

		[Bindable]
		public function get projectContentItems():ArrayCollection
		{
			return _projectContentItems;
		}

		public function set projectContentItems(value:ArrayCollection):void
		{
			_projectContentItems = value;
		}
		
		[Bindable]
		public function get selectedProjectContentItem():ProjectContentItem
		{
			return _selectedProjectContentItem;
		}

		public function set selectedProjectContentItem(value:ProjectContentItem):void
		{
			_selectedProjectContentItem = value;
		}


	}
}