package com.digitalaisle.uilibrary.components
{
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.uilibrary.containers.ProductPage;
	import com.digitalaisle.uilibrary.skins.PromoViewSkin;
	import com.digitalaisle.uilibrary.supportClasses.ItemFlowBase;
	import com.digitalaisle.uilibrary.supportClasses.PromoBase;
	
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	import mx.states.State;
	
	import org.casalib.util.ObjectUtil;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	/**
	 *  Promo state
	 */
	[SkinState("promo")]
	
	/**
	 *  Promo items state
	 */
	[SkinState("promoItems")]
	
	/**
	 *  Promo item state
	 */
	[SkinState("promoItem")]
	
	public class PromoView extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var promo:PromoBase;
		[SkinPart(required="true")]
		public var promoPage:ProductPage;
		[SkinPart(required="false")]
		public var promoItemsFlow:ItemFlowBase;
		
		private var _projectContentItem:ProjectContentItem;
		private var _dataChanged:Boolean = false;
		
		public function PromoView()
		{
			super();
			addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onCurrentStateChange, false, 0, true);
			setStyle("skinClass", PromoViewSkin);
			
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			states.push(new State({name:"promo"}));
			states.push(new State({name:"promoItems"}));
			states.push(new State({name:"promoItem"}));
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
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			instance.addEventListener(FlexEvent.ADD, onElementAdd);
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			instance.removeEventListener(FlexEvent.ADD, onElementAdd);
		}
		
		
		private function onElementAdd(e:FlexEvent):void
		{
			projectContentItem = _projectContentItem;
			/*switch(e.currentTarget)
			{
				case promo:
					promo.projectContentItem = projectContentItem;
					break;
				case promoPage:
					promoPage.projectContentItem = projectContentItem;
					break;
				case promoItemsFlow:
					promoItemsFlow.projectContentItem = projectContentItem;
					break;
			}*/
		}
		
		private function onCurrentStateChange(e:StateChangeEvent):void
		{
			
		}

		public function get projectContentItem():ProjectContentItem
		{
			return _projectContentItem;
		}

		public function set projectContentItem(value:ProjectContentItem):void
		{
			if(value)
			{
				_projectContentItem = value;
				
				if(projectContentItem.relatedItems.length > 0)
				{
					if(projectContentItem.relatedItems.length > 1)
					{
						if(currentState != "promoItems")
							currentState = "promoItems";
						if(promoItemsFlow){
							promoItemsFlow.projectContentItem = projectContentItem;
						}
							
					}else
					{
						var relatedItem:ProjectContentItem = DataManager.getInstance().fetchProjectContentItemById(projectContentItem.relatedItems[0].relatedItemId);
						if(ObjectUtil.contains(projectContentItem.additionalProperties, projectContentItem.additionalProperties.usePromoSkin))
						{
							currentState = "promo";
							if(promo)
								promo.projectContentItem = relatedItem;
						}else
						{
							currentState = "promoItem";	
							if(promoPage)
								promoPage.projectContentItem = relatedItem;
						}		
					}
				}
			}
			
		}
	}
}