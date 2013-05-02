package com.digitalaisle.desktop.popups
{
	import com.digitalaisle.desktop.components.ApplicationContent;
	import com.digitalaisle.desktop.skins.SearchPadSkin;
	import com.digitalaisle.desktop.utils.DesktopApplicationUtil;
	import com.digitalaisle.frontend.components.DAPanelSlider;
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.enums.ControlType;
	import com.digitalaisle.frontend.enums.ItemType;
	import com.digitalaisle.frontend.events.PanelEvent;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.frontend.valueObjects.entityObjects.TemplateItem;
	import com.digitalaisle.uilibrary.components.ClearableTextInput;
	import com.digitalaisle.uilibrary.components.buttons.DAButton;
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.keypads.Keyboard;
	import com.digitalaisle.uilibrary.supportClasses.ContainerBase;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerContainer;
	import mx.managers.PopUpManager;
	import mx.states.State;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 *  Search state where the keyboard is present for input
	 */
	[SkinState("normal")]
	
	/**
	 *  Results state showing the results of the keyword entered
	 */
	[SkinState("results")]
	
	/**
	 *  No Results state displayed no results are returned
	 */
	[SkinState("noresults")]
	
	[Style(name="closeButtonStyleName", type="String", inherit="yes")]
	
	[Style(name="sendButtonFontSize", type="Number", inherit="yes")]
	
	[Style(name="inputFieldFontSize", type="Number", inherit="yes")]
	
	[Style(name="resultNameFontSize", type="Number", inherit="yes")]
	
	[Style(name="resultDescriptionFontSize", type="Number", inherit="yes")]
	
	public class SearchPad extends ContainerBase implements IFocusManagerContainer
	{
		/** Skin Parts **/
		[SkinPart(required="true")]
		public var inputField:ClearableTextInput;
		[SkinPart(required="true")]
		public var searchButton:DAButton;
		[SkinPart(required="true")]
		public var keypad:Keyboard;
		[SkinPart(required="true")]
		public var resultsPanelSlider:DAPanelSlider;
		[SkinPart(required="true")]
		public var closeButton:DASimpleButton;
		
		[Bindable]
		private var _keywords:ArrayCollection = new ArrayCollection();
		public var targetTemplateItemId:int;
		
		private var _qualifiedItems:ArrayCollection = new ArrayCollection();
		private var _resultsList:ArrayCollection = new ArrayCollection();
		private var _allRelatedSearchItems:Array = new Array();
		private var _itemsDict:Dictionary = new Dictionary(true);
		private var _searchProjectContentItem:ProjectContentItem;
		
		public function SearchPad()
		{
			super();
			setStyle("skinClass", SearchPadSkin);
			currentState = "normal";
			addEventListener(FlexEvent.PREINITIALIZE, onPreinitialize, false, 0, true);
			
			_keywords = new ArrayCollection(
				[
					{ "name":"HP"},
					{ "name":"HP Mini"},
					{ "name":"HP Pavilion"},
					{ "name":"Aquamarine"},
					{ "name":"Compaq"},
					{ "name":"Compaq Presario"},
					{ "name":"HP Photosmart"},
					{ "name":"Monitor"},
					{ "name":"Ink"},
					{ "name":"Widescreen"},
					{ "name":"HP Envy"},
					{ "name":"Photo"},
					{ "name":"All-in-One"},
					{ "name":"HD"},
					{ "name":"Officjet"},
					{ "name":"Mini"},
					{ "name":"Printer" },
					{ "name":"Custom"}
				]);
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			states.push(new State({name:"results"}));
			states.push(new State({name:"noresults"}));
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
			
			switch(instance)
			{
				case searchButton:
					if(getStyle("sendButtonFontSize"))
						searchButton.setStyle("fontSize", getStyle("sendButtonFontSize"));
					searchButton.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case resultsPanelSlider:
					//resultsPanelSlider.dataProvider = _resultsList;
					resultsPanelSlider.addEventListener(PanelEvent.CLICK, onResultsClick, false, 0, true);
					resultsPanelSlider.addEventListener(FlexEvent.ADD, onComponentAdd, false, 0, true);
					break;
				case inputField:
					if(getStyle("inputFieldFontSize"))
						inputField.setStyle("fontSize", getStyle("inputFieldFontSize"));
					//inputField.addEventListener(Event.CHANGE, onAutoCompleteChange, false, 0, true);
					inputField.addEventListener(MouseEvent.CLICK, onInputClick, false, 0, true);
					inputField.addEventListener(Event.CLEAR, onInputClear, false, 0, true);
					break;
				case keypad:
					keypad.inputField = inputField;
					break;
				case closeButton:
					if(getStyle("closeButtonStyleName"))
						closeButton.styleName = getStyle("closeButtonStyleName");
					closeButton.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case searchButton:
					searchButton.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case resultsPanelSlider:
					resultsPanelSlider.removeEventListener(FlexEvent.ADD, onComponentAdd);
					resultsPanelSlider.removeEventListener(PanelEvent.CLICK, onResultsClick);
					break;
				case inputField:
					inputField.removeEventListener(Event.CHANGE, onAutoCompleteChange);
					inputField.removeEventListener(Event.CLEAR, onInputClear);
					break;
				case closeButton:
					closeButton.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
			}
		}
		
		
		private function search():void
		{
			_resultsList.removeAll();
		
			var selectedTerm:String = inputField.text;
			var qualifiedItems:Array = new Array();
			var searchItems:Array = new Array();
			
			if(targetTemplateItemId) {
				searchItems = _itemsDict[targetTemplateItemId];
			}else {
				searchItems = _allRelatedSearchItems;
			}
			
			if(searchItems) {
				for(var i:int = 0; i < searchItems.length; i++) {
					var projectItem:ProjectContentItem = searchItems[i];
					var frequency:int = projectItem.qualifySearch(selectedTerm);
					if(frequency > 0) {
						searchItems[i].searchFrequency = frequency;
						qualifiedItems.push(searchItems[i]);
					}
				}
				
				qualifiedItems.sort(sortSearchItems, Array.NUMERIC|Array.DESCENDING);
				_resultsList = new ArrayCollection(qualifiedItems);
				/*var frequencySort:Sort = new Sort();
				frequencySort.fields = [new SortField("searchFrequency", false, true, true)];
				_resultsList.sort = frequencySort;*/
				_resultsList.refresh();
			}
			
			ApplicationUtil.updateSession(_searchProjectContentItem.id, ActionType.SEARCH, new Point(0,0), "searchTerm=" + selectedTerm + ";");
			
			if(_resultsList.length > 0) {
				currentState = "results";
			} else {
				currentState = "noresults";
			}
			
		}
		
		private function close():void
		{
			PopUpManager.removePopUp(this);
		}
		
		private function onPreinitialize(e:FlexEvent):void
		{
			// Initial filter of the qualified ProjectContentItems of the related data items
			
			var allProjectItems:Array = DataManager.getInstance().allProjectContentItems;
			var searchTemplateItem:TemplateItem;
			for(var i:int = 0; i < allProjectItems.length; i++) {
				
				var templateItem:TemplateItem = DataManager.getInstance().fetchTemplateItemById(allProjectItems[i].templateItemId);
				if(templateItem.controlType == ControlType.SEARCH && templateItem.itemType == ItemType.WIDGET) {
					_searchProjectContentItem = allProjectItems[i];
					searchTemplateItem = templateItem;
					break;
				}
			}
			
			if(searchTemplateItem) {
				var searchItemsDict:Dictionary = new Dictionary(true);
				
				for(i = 0; i < searchTemplateItem.dataItems.length; i++) {
					_itemsDict[templateItem.dataItems[i]] = new Array();
					for(var j:int = 0; j < allProjectItems.length; j++) {
						
						if(searchTemplateItem.dataItems[i] == allProjectItems[j].templateItemId) {
							// Store the item with a separate key used to retrieve results upon targeted template id
							_itemsDict[templateItem.dataItems[i]].push(allProjectItems[j]);
							
							// If a key does not exist then store item in its own key using it's ID
							if(!searchItemsDict[allProjectItems[j].id]) {
								searchItemsDict[allProjectItems[j].id] = allProjectItems[j];
								_allRelatedSearchItems.push(allProjectItems[j]);
							}
						}
					}
				}
			}else
				MonsterDebugger.trace(this, "Search is not available for this project.", MonsterDebugger.COLOR_WARNING);
		}
		
		private function sortSearchItems(itemA:Object, itemB:Object):Number
		{
			if(itemA.searchFrequency > itemB.searchFrequency) {
				return 1;
			} else if(itemA.searchFrequency < itemB.searchFrequency) {
				return -1;
			} else  {
				return 0;
			}
		}
		
		private function removeDuplicates(arr:Array):void
		{
			var i:int;
			var j: int;
			for (i = 0; i < arr.length - 1; i++){
				for (j = i + 1; j < arr.length; j++) {
					if (arr[i] === arr[j]){
						arr.splice(j, 1);
					}
				}
			}
		}
		
		private function onButtonClick(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case searchButton:
					search();
					break;
				case closeButton:
					close();
					break;
			}
		}
		
		private function onComponentAdd(e:FlexEvent):void
		{
			switch(e.target)
			{
				case resultsPanelSlider:
					resultsPanelSlider.dataProvider = _resultsList;
					break;
			}
		}
		
		private function onResultsClick(e:PanelEvent):void
		{
			// Load content that has been clicked
			DesktopApplicationUtil.loadContent(ApplicationContent.PRODUCT, resultsPanelSlider.selectedID);
			close();
		}

		private function onAutoCompleteChange(e:Event):void
		{
				
		}
		
		private function onInputClick(e:MouseEvent):void
		{
			currentState = "normal";
			inputField.text = keypad.inputValue = "";
		}
		
		private function onInputClear(e:Event):void
		{
			keypad.inputValue = "";
		}
	}
}