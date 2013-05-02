package com.digitalaisle.frontend.components
{
	import com.adobe.utils.ArrayUtil;
	import com.digitalaisle.frontend.controls.StaticScrollbar;
	import com.digitalaisle.frontend.core.DAPanel;
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.enums.PanelType;
	import com.digitalaisle.frontend.events.PanelEvent;
	import com.digitalaisle.frontend.events.UserTouchEvent;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.uilibrary.components.panels.*;
	import com.digitalaisle.uilibrary.data.PanelObject;
	import com.digitalaisle.uilibrary.events.DAContentScrollerEvent;
	import com.digitalaisle.uilibrary.skins.ListPanelSkin;
	import com.digitalaisle.uilibrary.supportClasses.PanelBase;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import com.gskinner.utils.Janitor;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	import mx.collections.ArrayCollection;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Image;
	import spark.core.SpriteVisualElement;
	import spark.events.ElementExistenceEvent;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.skins.spark.ImageSkin;
	

	
	/**
	 *  Dispatched when the user presses any given Panel. Note: the press will 
	 * need to go through a press qualification.
	 *
	 *  @eventType com.digitalaisle.events.PanelEvent.SINGLE_CLICK
	 */
	[Event(name="singleClick", type="com.digitalaisle.frontend.events.PanelEvent")]
	
	/**
	 *  Dispatched when the user presses an already selected Panel as it is consider
	 * a "Double Click". Note: the press will need to go through a press qualification.
	 *
	 *  @eventType com.digitalaisle.events.PanelEvent.DOUBLE_CLICK
	 */
	[Event(name="doubleClick", type="com.digitalaisle.frontend.events.PanelEvent")]
	
	/**
	 *  Dispatched when the user presses any given Panel. Note: the press will need to go through a press qualification.
	 *
	 *  @eventType com.digitalaisle.events.PanelEvent.CLICK
	 */
	[Event(name="panelClick", type="com.digitalaisle.frontend.events.PanelEvent")]
	
	[Style(name="panelSkinClass", type="Class", inherit="no")]
	[Style(name="panelButtonStyle", type="String", inherit="no")]
	
	
	// TODO: BUG FIX DEALING WITH THE SELECTED OF THE FOOTER NOT MATCHING OF THE SELECTED PRESS OF THE LIVE PANELS
	public class DAPanelSlider extends Group
	{
		private static var TOUCH_BUFFER:Number = 0.15;
		
		private var _dataProvider:ArrayCollection = new ArrayCollection();
		private var _multiSelectEnabled:Boolean = false;
		private var _maxSelect:int = 0;
		private var _selectedItem:ProjectContentItem;
		private var _selectedItems:ArrayCollection = new ArrayCollection();
		private var _items:ArrayCollection = new ArrayCollection();
	
		public var isContinuous:Boolean = false;
		public var easeSpeed:Number = .5;
		// TODO: if string, try to load and/or sound, try to play 
		public var clickSound:Sound;	
		public var zoomSound:String;
		public var autoResetPosition:Boolean = true;
		private var _showScrollbar:Boolean = true;
		
		// READ/WRITE (INSPECTABLE)		// Could these be public
		public var visiblePanels:int = 3;					// Total number of visible panels
		private var _scrollPosition:String = "horizontal";	// Type of scroll positioning - "vertical" or "horizontal"					
		public var panelHeight:Number = 180;					// Height of each panel object
		public var panelWidth:Number = 300;					// Width of each panel object
		private var _panelSpacing:int = 10;					// Spacing between each panel
		private var _panelType:String = PanelType.TITLED;		// Type of panel being use - See com.digitalaisle.core.enums.PanelType.as
		private var _resetPosition:Boolean = true;	
		
		private var _totalPanels:int = 0;						// Total number of panels
		private var _totalPanelHeight:int;					// Height of all of the panels when assembled
		private var _totalPanelWidth:int;					// Width of all of the panels when assembled
		private var _totalViewableHeight:int;				// Height of all of the panels		// TODO: Possibly not needed on a global scale 
		private var _totalViewableWidth:int;				// Width of all of the panels		// TODO: Possibly not needed on a global scale 
		private var _prevPanel:PanelBase;					// TODO: Possibly not needed on a global scale 
		protected var mirrorPanel:DAPanel;
		
		private var _scrollSize:int;						// Size used to determined each panel's scroll size //TODO: Create getter
		private var _totalScrollSize:int;					// Total size of the scrolling area
		private var _totalViewableSize:int;					// Total size of the scroll viewable area
		private var _scrollProperty:String;					// Scrolling property	
		private var _mouseDownPos:Number = 0;
		
		private var _additionalCount:int = 0;				// IF isContinuous, this value represents the additional panel items to pull off effect
		
		private var _topMostPosition:Number = 0;				// Pamel group's bottom most position
		
		private var _mouseDownPoint:Point;
		private var _mouseUpPoint:Point;
		private var _lastMouseDownPoint:Point;
		
		// TODO: Change this to styles 
		/** Scrollbar Properties **/
		protected var scrollBarElement:SpriteVisualElement;
		protected var defaultScrollbarWidth:int = 6;
		protected var defaultScrollbarHeight:int = 160;

		protected var touchPanelGroup:Group;				// 
		protected var _panelContentScroller:DAContentScroller;
		private var _janitor:Janitor;						// Local instance of a Janitor
		
		private var _selectedID:int = 0;
		private var _selectedIndex:int = -1;
		
		
		// Sound Management
		private var _sndChannel:SoundChannel;
		private var _clickSoundClip:Sound;
		
		private var _increment:int;		// TODO: Possibly not needed on a global scale
		private var _point:Point;
		
		private var _initialData:Boolean = true;
		
		private var _dataChanged:Boolean = false;
		
		public var enablePagination:Boolean = false;
		private var _isLoading:Boolean = false;
		public var itemsPerPage:int = 10;
		private var _clickedPanel:PanelBase;
		private var _loadingPanel:PanelBase;
		private var _prevButton:Button;
		private var _nextButton:Button;
		private var _loadMore:Boolean = false;
		private var _dragNDropEnabled:Boolean = false;
		
		public var positionID:int;
		
		public function DAPanelSlider()
		{
			super();
			
			addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, onElementRemoved, false, 0, true);
			addEventListener(FlexEvent.ADD, onComponentEnable, false, 0, true);
			addEventListener(FlexEvent.SHOW, onComponentEnable, false, 0, true);
			addEventListener(FlexEvent.HIDE, onComponentDisable, false, 0, true);
			addEventListener(FlexEvent.REMOVE, onComponentDisable, false, 0, true);
			
			_janitor = new Janitor(this);
			// Assigns both the click and zoom sound objects
			assignSoundObjects();
		}
		
		public function reset():void
		{
			for(var i:int = 0; i < _items.length; i++) {
				(_items.getItemAt(i) as PanelBase).selected = false;
			}
			
			_selectedID = _selectedIndex = 0;
		}
		
		public function destroy():void
		{
			// Remove any tweens (if any)
			TweenLite.killTweensOf(touchPanelGroup);
			removeAllElements();
			_janitor.cleanUpEventListeners();
			dataProvider.removeAll();
		}
		
		public function setSelectedPanel(index:int):void
		{
			if(_dataProvider.length < index)
			{
				
			}
		}
		
		public function prevPanel():void
		{
			// If DragTimer exist then stop it
			// Calculate the current incrment, here as opposed to every frame   I think I might need to update 
			// Move both press functionality with here as opposed to separate functions
			
			if(!isTouchDisabled)
			{
				if(_increment != determineClosestPanel())
				{
					_increment = determineClosestPanel();
					_increment--;
				}else
				{
					_increment--;
				}
				
				tweenToPanel(_increment);
				
				if(clickSound)
					clickSound.play();
				
				// NOTE: I NEED THE ID OF THE (DOES THIS EVEN TO BE DISPATCHED
				dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.SCROLL, localToGlobal(new Point(this.mouseX, this.mouseY)),"", false, false));
			}
		}
		
		
		public function nextPanel():void
		{
			if(!isTouchDisabled)
			{
				if(_increment != determineClosestPanel())
				{
					_increment = determineClosestPanel();
					_increment++;
				}else
				{
					_increment++;
				}
				tweenToPanel(_increment);
				if(clickSound)
					clickSound.play();
				
				// NOTE: I NEED THE ID OF THE 
				dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.SCROLL, localToGlobal(new Point(this.mouseX, this.mouseY)),"", false, false));
			}
		}
		
		
		private function disableScrollFunctionality():void		// TODO: Implement
		{
			
		}
		
		
		
		protected function populateTweenObject(position:Number):Object
		{
			var tweenObject:Object = new Object();
			tweenObject[_scrollProperty] = position;
			tweenObject.onComplete = onTweenEnd;
			tweenObject.onUpdate = onTweenUpdate;
			return tweenObject;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();

			touchPanelGroup = new Group();
			addElement(touchPanelGroup);
			
			//panelContentScroller = new DAContentScroller();
			//touchPanelGroup.addElement(panelContentScroller);

		}
		
		
		override protected function commitProperties():void
		{
			super.commitProperties();	

			if(_dataProvider.length > 0 && _dataChanged)
			{
				_totalPanels = _dataProvider.length;
				
				if(isContinuous && !isTouchDisabled)
				{
					// Define header and footer counts
					_additionalCount = visiblePanels;
					_increment = 0;
				}else
					_increment = visiblePanels;
				
				// APPLY scroll positioning requirements
				// SETTING width/height of draggable area 
				switch(_scrollPosition)			// ScrollPosition can also be an Enum Class
				{
					case "horizontal":
						_scrollProperty = "x";
						_scrollSize = panelWidth;
						_totalViewableHeight = _totalPanelHeight = panelHeight;
						_totalViewableWidth = _totalViewableSize = ((panelWidth + _panelSpacing) * visiblePanels) - _panelSpacing; 
						_totalPanelWidth = _totalScrollSize = (panelWidth + _panelSpacing) * (_totalPanels + _additionalCount);
						break;
					case "vertical":
						_scrollProperty = "y";
						_scrollSize = panelHeight;
						_totalViewableHeight = _totalViewableSize = ((panelHeight + _panelSpacing) * visiblePanels) - _panelSpacing;
						_totalViewableWidth = _totalPanelWidth = panelWidth;
						_totalPanelHeight = _totalScrollSize = (panelHeight + _panelSpacing) * (_totalPanels + _additionalCount);
						break;
				}
				
				// Defines the top and bottom most positions
				//_bottomMostPosition = ((_scrollSize + _panelSpacing) * _totalPanels) - _panelSpacing ;
			}
		}
		
		
		override protected function measure():void
		{
			super.measure();
			measuredMinWidth = panelWidth;
			measuredMinHeight= panelHeight;
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var itemsToBeRendered:int = 0;
			var startingPoint:int = 0;
			
			if(_dataProvider.length > 0 && _dataChanged)
			{
				
				_items.removeAll();
				var panelContentScroller:DAContentScroller = new DAContentScroller();
				panelContentScroller.gap = panelSpacing;
				panelContentScroller.width = _totalViewableWidth;
				panelContentScroller.height = _totalViewableHeight;
				panelContentScroller.scrollDirection = scrollPosition;
				panelContentScroller.autoResetPosition = true;
				_panelContentScroller = panelContentScroller;
				_panelContentScroller.showScrollbar = showScrollbar;
				touchPanelGroup.addElement(panelContentScroller);
				itemsToBeRendered = enablePagination && (itemsPerPage < dataProvider.length) ? itemsPerPage : dataProvider.length;
				
				if(enablePagination && scrollPosition == DAContentScroller.VERTICAL && dataProvider.length > itemsPerPage )
				{
					// Create loading panel
					var loadingPanel:LoadingPanel = new LoadingPanel();
					loadingPanel.height = panelHeight;
					loadingPanel.width = panelWidth;					
					_janitor.addEventListener(loadingPanel, MouseEvent.CLICK, onLoadMoreClick, false, true);
					panelContentScroller.addContent(loadingPanel);
					_loadingPanel = loadingPanel;
				}
				
				enable();
				//TODO: disable enable buttons
					
				//_dataChanged = false; 
			}
			
			if(_loadMore)
			{
				startingPoint = totalItemsShown;
				if((totalItemsShown + itemsPerPage) < dataProvider.length)
					itemsToBeRendered = itemsPerPage + totalItemsShown;
				else
					itemsToBeRendered = dataProvider.length - totalItemsShown;
				_loadMore = false;
			}
			
			// Create panel items as they are needed
			for(var i:int = startingPoint; i < itemsToBeRendered; i++)
			{
				if(dataProvider[i] is ProjectContentItem){
					var panelObj:PanelBase = createPanelByType(i, _panelType, dataProvider[i]);
					if(getStyle("panelSkinClass")) {
						var panelSkinClass:Class = getStyle("panelSkinClass") as Class;
						panelObj.setStyle("skinClass", panelSkinClass);
					}
					
					if(_loadingPanel)
						panelContentScroller.addContentAt(panelObj, panelContentScroller.numContents  - 1);
					else
						panelContentScroller.addContent(panelObj);
					
					_items.addItem(panelObj);
				}else{
					
					//  throw warning/error
					dataProvider.removeItemAt(i);
					i--;
				}
			}
			
			if(_dataChanged)
			{
				_dataChanged = false;
				//panelContentScroller.autoResetPosition = false;
			}
			
			if(itemsToBeRendered > 0)
			{
				if(_loadingPanel)
					_loadingPanel.currentState = "normal";
				dispatchEvent(new Event(Event.CHANGE));
			}else if(itemsToBeRendered == 0 && _dataProvider.length < 0)
			{
				panelContentScroller.removeContent(_loadingPanel);
			}
			
			
			
		}
		
		private function resetScrollbar():void
		{
			var staticScrollbar:StaticScrollbar = scrollBarElement.getChildByName("scrollbar") as StaticScrollbar;
		}

		private function determineLayoutBase():LayoutBase
		{
			var layout:LayoutBase;
			if(_scrollPosition == "vertical"){
				layout = new VerticalLayout();
				VerticalLayout(layout).gap = _panelSpacing;
			}else{
				layout = new HorizontalLayout();
				HorizontalLayout(layout).gap = _panelSpacing;
			}
			return layout;
		}
		
		private function createPanelByType(increment:int, type:String, pci:ProjectContentItem):PanelBase
		{
			var panel:PanelBase;
			switch(type)
			{
				case PanelType.TITLED:
					panel = new TitledPanel();
					break;
				case PanelType.LIST:
					panel = new ListPanel();
					break;
				case PanelType.SIMPLE:
					panel = new SimplePanel();
					break;
				case PanelType.IMAGE:
					panel = new ImageList();
					break;
			}
			
			panel.width = panelWidth;
			panel.height = panelHeight;
			panel.settings = createPanelObject(pci);
			panel.id = "panel" + (increment + 1);
			panel.index = increment;
			_janitor.addEventListener(panel, MouseEvent.MOUSE_DOWN, onPanelMouseDown, false, true);
			_janitor.addEventListener(panel, MouseEvent.MOUSE_UP, onPanelMouseUp, false, true);
			return panel;
		}	
		
		private function assignSoundObjects():void
		{
			//Create a new SoundChannel Object
			_sndChannel = new SoundChannel();
			
			_janitor.addSoundChannel(_sndChannel);

			/*if(!clickSound)
			{
				// Load click sound
				_clickSoundClip = new Sound();
				_clickSoundClip.load(new URLRequest(clickSound));
				_clickSoundClip.addEventListener(Event.COMPLETE, onSoundLoaded, false, 0, true);
			}*/
		}
		
		private function createPanelObject(pci:ProjectContentItem):PanelObject
		{
			var panelObj:PanelObject = new PanelObject();
			panelObj.uid = String(pci.id);
			panelObj.labelText = pci.name;
			panelObj.descriptionText = pci.shortDescription;
			panelObj.upStateAsset = pci.fetchBinaryContentByType(BinaryType.BUTTON_IDLE_STATE);
			panelObj.downStateAsset = pci.fetchBinaryContentByType(BinaryType.BUTTON_DOWN_STATE);
			//panelObj.disabledStateAsset = fetchBinaryContentByType(projectContentItems[i], BinaryType.BUTTON_IDLE_STATE);
			panelObj.thumbnailAsset = pci.fetchBinaryContentByType(BinaryType.THUMBNAIL);
			panelObj.imageurl=pci.fetchBinaryContentByType(BinaryType.IMAGE);
			panelObj.itemSeqNo = pci.itemSeqNo;
			if(getStyle("panelButtonStyle"))
				panelObj.buttonStyleName = getStyle("panelButtonStyle");
			return panelObj;
		}
		
		private function enable():void
		{
			if(!touchPanelGroup.hasEventListener(MouseEvent.MOUSE_UP))
				touchPanelGroup.addEventListener(MouseEvent.MOUSE_UP, onTouchMouseUp, false, 0, true);
			
			if(!touchPanelGroup.hasEventListener(MouseEvent.MOUSE_DOWN))
				touchPanelGroup.addEventListener(MouseEvent.MOUSE_DOWN, onTouchMouseDown, false, 0, true);
			
			if(_panelContentScroller)
			{
				if(!_panelContentScroller.hasEventListener(DAContentScrollerEvent.SCROLL_STOPPED))
					_panelContentScroller.addEventListener(DAContentScrollerEvent.SCROLL_STOPPED, onScrollStopped, false, 0, true);
			}
		}
		
		private function disable():void
		{
			if(touchPanelGroup)
			{
				touchPanelGroup.removeEventListener(MouseEvent.MOUSE_UP, onTouchMouseUp);
				touchPanelGroup.removeEventListener(MouseEvent.MOUSE_DOWN, onTouchMouseDown);
			}
			if(_panelContentScroller)
				_panelContentScroller.removeEventListener(DAContentScrollerEvent.SCROLL_STOPPED, onScrollStopped);
		}

		
		// EVENT HANDLERS ----------------- 
		
		private function onTouchMouseDown(e:MouseEvent):void
		{
			// Removes any Tweenlite process that may be running
			TweenLite.killTweensOf(touchPanelGroup);
			
			// get some initial properties
			_mouseDownPoint = new Point(e.stageX, e.stageY);
			_lastMouseDownPoint = new Point(e.stageX, e.stageY);
			_point = new Point(e.stageX, e.stageY);
			_mouseDownPos = touchPanelGroup[_scrollProperty];
		}
		
		
	
		private function onTouchMouseUp(e:MouseEvent):void
		{

		}
		
		
		private function onPanelMouseDown(e:MouseEvent):void
		{
			_clickedPanel = e.currentTarget as PanelBase;
			// Removes any Tweenlite process that may be running
			TweenLite.killTweensOf(touchPanelGroup);		// whY??
			
			if (_dragNDropEnabled == true) {
				var dragSrc:DragSource = new DragSource();
				dragSrc.addData(_clickedPanel.uid, "ProjectContentItemId");			
				DragManager.doDrag(e.currentTarget as IUIComponent, dragSrc, e, _clickedPanel.panelButton, 0, 0, 0.75);
			}
		}
		
		
		private function onPanelMouseUp(e:MouseEvent):void
		{
			var isClicked:Boolean = false;
			
			if(_clickedPanel == e.currentTarget)
			{	
				_mouseUpPoint = new Point(e.stageX, e.stageY);
				
				var positionalDifference:Number = _mouseDownPoint[_scrollProperty] - _mouseUpPoint[_scrollProperty];
				if(Math.abs(positionalDifference) < _scrollSize * TOUCH_BUFFER)
					isClicked = true;
				else
					return;
				
				
				if(isClicked)
				{
					if(clickSound)
						clickSound.play();
					
					/*if(!_multiSelectEnabled)
					{
						if(_prevPanel)
							_prevPanel.selected = false;
						e.currentTarget.selected = true;
					}else
					{
						e.currentTarget.selected = !e.currentTarget.selected;
						if(e.currentTarget.selected)
						{
							// NOTE: NOT FINISHED I need to handle limitiing the amount to a certain count
							if(_multiSelectEnabled)
							{
								if(_maxSelect != 0 && selectedItems.length > _maxSelect)
								{	e.currentTarget.selected = false;	
									return;
								}
									
							}
						}
					}*/
					
					selectedIndex = e.currentTarget.index;
					
					//_selectedIndex = e.currentTarget.index;		// Can _selectedIndex update along with selected Id
					/*_selectedID = e.currentTarget.uid;
					_selectedItem = _dataProvider[_selectedIndex];
					_prevPanel = e.currentTarget as PanelBase;*/
					
					//dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, _dataProvider[_selectedIndex].id, ActionType.CLICK, localToGlobal(new Point(this.mouseX, this.mouseY))));
					//dispatchEvent(new PanelEvent(PanelEvent.CLICK));
				}
			}
		}
		
		private function onScrollStopped(e:DAContentScrollerEvent):void
		{
			tweenToPanel(determineClosestPanel());
		}
		
		private function onSoundLoaded(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, onSoundLoaded);
			
		}
		
		private function onTweenStart():void
		{
			_clickedPanel.labelDisplay
		}
		public function selectedPanelStyle():void{
			if(_prevPanel!=null){
				_prevPanel.labelDisplay.setStyle("color","#000000");
				_prevPanel.skin.invalidateDisplayList();
				
			}
			
			if(_clickedPanel!=null){
			_clickedPanel.labelDisplay.setStyle("color","#ffffff");
			_clickedPanel.skin.invalidateDisplayList();
			}
		}
		
		private function onTweenEnd():void
		{
			if(isContinuous){
				if(_increment == _totalPanels){
					_increment = 1;
					touchPanelGroup[_scrollProperty] = _topMostPosition;
				}
				//touchPanelGroup[_scrollProperty] = _topMostPosition;
			}
			//updateScrollbarPosition();
		}
		
		private function onTweenUpdate():void
		{
			//updateScrollbarPosition();
		}
		
		
		private function determineClosestPanel():int
		{
			var tScrollSize:int = _scrollSize + _panelSpacing;
			var closestPanel:int = Math.round((-_panelContentScroller.scrollPosition[_scrollProperty])/(tScrollSize));
			return closestPanel;
		}
		
		private function tweenToPanel(position:int):void
		{
			positionID = position + visiblePanels;
			if( positionID <= (_totalPanels + _additionalCount))
			{
				_increment = determineClosestPanel();
				var nextPos:Number = -((positionID - visiblePanels) * (_scrollSize + _panelSpacing));
				_panelContentScroller.tweenTo(nextPos, .6);
			}
			
			dispatchEvent(new Event("PANEL_CLICK"));
			
		}
		private function tweenForSlide(position:int):void
		{
			positionID = position + visiblePanels;
			if( position <= (_totalPanels + _additionalCount))
			{
				_increment = determineClosestPanel();
				var nextPos:Number = -((positionID - visiblePanels) * (_scrollSize + _panelSpacing));
				_panelContentScroller.tweenTo(nextPos, .6);
			}
			
			dispatchEvent(new Event("PANEL_CLICK"));
			invalidateDisplayList();
		}
		
		
		private function onComponentChange(e:Event):void
		{
			if(!_loadMore && enablePagination)
			{
				
			}
		}
		
		private function onComponentEnable(e:FlexEvent):void
		{
			enable();
		}
		
		private function onComponentDisable(e:FlexEvent):void
		{
			disable();
		}
		
		private function onElementRemoved(e:ElementExistenceEvent):void
		{
			// Remove any tweens (if any)
			TweenLite.killTweensOf(touchPanelGroup);
			_janitor.cleanUpEventListeners();
			_janitor.cleanUpSoundChannels();
			disable();
			//removeAllElements();
			dataProvider.removeAll();
			_items.removeAll();
			
		}
		
		private function onNavigationClick(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case _nextButton:
					nextPanel();
					break;
				case _prevButton:
					prevPanel();
					break;
			}
		}
		
		private function onLoadMoreClick(e:MouseEvent):void
		{
			_loadMore = true;
			invalidateDisplayList();
		}
		//both method are specially build for VB-4 
		// to make it general remove listpanel and replace that with  panelbase
		public function changeCurrent(index:int):void{
			(_items[index] as PanelBase).richTextDisplay.setStyle("color","#ffffff");
			(_items[index] as ListPanel).labelDisplay1.setStyle("color","#ffffff");
		}
		public function changeBoth(prevIndex:int,currentIndex:int):void
		{
			(_items[currentIndex] as PanelBase).richTextDisplay.setStyle("color","#ffffff");
			(_items[currentIndex] as ListPanel).labelDisplay1.setStyle("color","#ffffff");
			(_items[prevIndex] as PanelBase).richTextDisplay.setStyle("color","#676767");
			(_items[prevIndex] as ListPanel).labelDisplay1.setStyle("color","#676767");
		}
		public function slide(value:int):void{
			tweenToPanel(value);
		}
		public function get panelSpacing():int
		{
			return _panelSpacing;
		}

		public function set panelSpacing(value:int):void
		{
			_panelSpacing = value;
		}

		public function get scrollPosition():String
		{
			return _scrollPosition;
		}

		public function set scrollPosition(value:String):void
		{
			_scrollPosition = value;
		}
		

		public function get selectedID():int
		{
			return _selectedID;
		}

		public function get panelType():String
		{
			return _panelType;
		}

		public function set panelType(value:String):void
		{
			_panelType = value;
		}

		public function get resetPosition():Boolean
		{
			return _resetPosition;
		}

		public function set resetPosition(value:Boolean):void
		{
			_resetPosition = value;
		}

		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		public function set selectedIndex(value:int):void
		{
			/*if(_selectedIndex == value) {
				return;
			}else {*/
				if(_items.length < 1)
					return;
				
				_selectedIndex = value;
				_selectedID = _dataProvider[_selectedIndex].id;
				_selectedItem = _dataProvider[_selectedIndex];
				
				
				if(!_multiSelectEnabled)
				{
					if(_prevPanel)
						_prevPanel.selected = false;
					_items[_selectedIndex].selected = true;
				}else
				{
					_items[_selectedIndex].selected = !_items[_selectedIndex].selected;
					if(_items[_selectedIndex].selected)
					{
						// NOTE: NOT FINISHED I need to handle limitiing the amount to a certain count
						if(_multiSelectEnabled)
						{
							if(_maxSelect != 0 && selectedItems.length > _maxSelect)
							{	_items[_selectedIndex].selected = false;	
								return;
							}
							
						}
					}
				}
				
				_prevPanel = _items[_selectedIndex] as PanelBase;
				
				dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, _selectedID, ActionType.CLICK, localToGlobal(new Point(this.mouseX, this.mouseY))));
				dispatchEvent(new PanelEvent(PanelEvent.CLICK));
			//}
		}

		public function get maxSelect():int
		{
			return _maxSelect;
		}

		public function set maxSelect(value:int):void
		{
			_maxSelect = value;
		}

		public function get selectedItem():PanelObject
		{
			return _dataProvider[_selectedIndex];
		}
		
		public function get selectedItems():ArrayCollection
		{
			var selected:Array = new Array();
			for(var i:int = 0; i < _items.length; i++)
			{
				if(_items[i].selected)
					selected.push(dataProvider[i]);
					
			}
			return new ArrayCollection(selected);
		}

		public function get multiSelectEnabled():Boolean
		{
			return _multiSelectEnabled;
		}

		public function set multiSelectEnabled(value:Boolean):void
		{
			_multiSelectEnabled = value;
		}
		
		[Bindable]
		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}
		
		
		public function set dataProvider(value:ArrayCollection):void
		{
			if(dataProvider === value)
				return;
				
			if(!value)
				return;
			
			_items.removeAll();
			_dataProvider = value;
			_dataChanged = true;
			_janitor.cleanUpEventListeners();
			disable();
			//TEMP: Look into more on a preferred ceanup
			if(touchPanelGroup)
				touchPanelGroup.removeAllElements();
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();	
		}
		
		
		public function get totalItems():int
		{
			return dataProvider.length;
		}
		
		public function get totalItemsShown():int
		{
			if(_panelContentScroller)
				return _panelContentScroller.numContents;
			else return 0;
		}

		public function get prevButton():Button
		{
			return _prevButton;
		}

		public function set prevButton(value:Button):void
		{
			if(_prevButton == value)
				return;
			_prevButton = value;
			if(!_prevButton.hasEventListener(MouseEvent.CLICK))
				_prevButton.addEventListener(MouseEvent.CLICK, onNavigationClick, false, 0, true);
		}

		public function get nextButton():Button
		{
			return _nextButton;
		}

		public function set nextButton(value:Button):void
		{
			if(_nextButton == value)
				return;
			_nextButton = value;
			if(!_nextButton.hasEventListener(MouseEvent.CLICK))
				_nextButton.addEventListener(MouseEvent.CLICK, onNavigationClick, false, 0, true);
		}
		
		public function get isTouchDisabled():Boolean
		{
			return totalItems <= visiblePanels ? true : false;	
		}

		public function get showScrollbar():Boolean
		{
			return _showScrollbar;
		}

		public function set showScrollbar(value:Boolean):void
		{
			_showScrollbar = value;
			if(_panelContentScroller)
				_panelContentScroller.showScrollbar = value;
		}

		public function get dragNDropEnabled():Boolean
		{
			return _dragNDropEnabled;
		}
		
		public function set dragNDropEnabled(value:Boolean):void
		{
			_dragNDropEnabled = value;
		}
	}
}