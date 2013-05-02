package com.digitalaisle.uilibrary.containers
{
	import com.digitalaisle.frontend.components.DAContentScroller;
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.managers.AvatarManager;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.managers.SessionManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectEventItem;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectProductItem;
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.projectContent.ProjectRecipeItem;
	import com.digitalaisle.uilibrary.skins.ItemPageSkin;
	import com.digitalaisle.uilibrary.supportClasses.ContainerBase;
	import com.digitalaisle.uilibrary.supportClasses.PrintTemplateBase;
	import com.digitalaisle.utils.PrintUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//Change MX Image to Spark Image - Start
	//import mx.controls.Image;
	import spark.components.Image;
	//End
	import flashx.textLayout.conversion.TextConverter;
	
	import mx.controls.Text;
	import mx.events.FlexEvent;
	import mx.events.VideoEvent;
	import mx.states.State;
	
	import org.casalib.util.LocationUtil;
	import org.casalib.util.StringUtil;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayerState;
	

	import spark.components.RichText;
	import spark.components.TextInput;
	import spark.components.VideoPlayer;

	[SkinState("stateImage")]
	[SkinState("stateVideo")]
	[SkinState("normal")]
	[SkinState("disabled")]
	
	
	public class ProductPage extends ContainerBase
	{					
		public static const VIDEO:String = "video";
		public static const IMAGE:String = "image";
		public static const BOTH:String = "both";
		
		public static const PRODUCT:String = "product";
		public static const EVENT:String = "event";
		public static const RECIPE:String = "recipe";
		public static const DEFAULT:String = "default";
		
		[SkinPart(required="false")]
		public var txtTitle:RichText;
		[SkinPart(required="false")]
		public var txtSubTitle:RichText;
		[SkinPart(required="false")]
		public var btnPrint:DASimpleButton;
		[SkinPart(required="false")]
		public var btnEmail:DASimpleButton;
		[SkinPart(required="false")]
		public var btnTextMessage:DASimpleButton;
		[SkinPart(required="true")]
		public var image:Image;
		[SkinPart(required="true")]
		public var video:VideoPlayer;
		[SkinPart(required="false")]
		public var contentScroller:DAContentScroller;
		[SkinPart(required="false")]
		//Change MX Text to Spark RichText - Start
		//public var bodyText:Text;
		public var bodyText:RichText;
		//End
		[SkinPart(required="false")]
		public var printTemplate:PrintTemplateBase;
		
		private var _productViewMode:String = VIDEO;
		private var _projectContentItem:ProjectContentItem;
		private var _tempTextInput:TextInput = new TextInput();
		
		[Bindable] 
		private var _imageSource:String;
		[Bindable] 
		private var _videoSource:String;
		private var _dataChanged:Boolean;
		private var _itemViewSource:String;
		public var parentId:int;
		public var footerText:String = "";
		
		public function ProductPage()
		{
			super();
			setStyle("skinClass", ItemPageSkin);
		}
		
		public override function initialize():void
		{
			super.initialize();
			states.push(new State({name:"normal"}));
			states.push(new State({name:"disabled"}));
			states.push(new State({name:"stateImage"}));
			states.push(new State({name:"stateVideo"}));
			
			DataManager.globalDictionary["productPageShown"] = true;
		}
		
		
		override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void
		{
			super.stateChanged(oldState, newState, recursive);
			invalidateSkinState();
			if(newState == "stateImage" && LocationUtil.isAirApplication()) {
				SessionManager.getInstance().resumeSession();
			}
				
		}
		
		protected override function getCurrentSkinState():String
		{
			return currentState;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case btnPrint:
					btnPrint.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case btnEmail:
					btnEmail.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case image:
					image.addEventListener(FlexEvent.ADD, onComponentAdd);
					image.addEventListener(FlexEvent.REMOVE, onComponentRemove);
					break;
				case video:
					video.addEventListener(FlexEvent.ADD, onComponentAdd);
					video.addEventListener(FlexEvent.REMOVE, onComponentRemove);
					video.addEventListener(TimeEvent.COMPLETE, onVideoPlayerComplete, false, 0, true);
					break;
				case printTemplate:
					printTemplate.visible = false;
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case txtTitle:
					break;
				case txtSubTitle:
					break;
				case btnPrint:
					btnPrint.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case btnEmail:
					btnEmail.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case image:
					image.removeEventListener(FlexEvent.ADD, onComponentAdd);
					image.removeEventListener(FlexEvent.REMOVE, onComponentRemove);
					break;
				case video:
					video.removeEventListener(FlexEvent.ADD, onComponentAdd);
					video.removeEventListener(FlexEvent.REMOVE, onComponentRemove);
					video.removeEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onVideoPlayerStateChange);
					break;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(_dataChanged)
			{
				if(projectContentItem is ProjectProductItem)
					type = PRODUCT;
				else if(projectContentItem is ProjectEventItem)
					type = EVENT;
				else if(projectContentItem is ProjectRecipeItem)
					type = RECIPE;
				
				if(txtTitle)
					txtTitle.text = projectContentItem.name;
				if(txtSubTitle)
					txtSubTitle.text = projectContentItem.shortDescription;
				if(printTemplate)
					printTemplate.projectContentItem = projectContentItem;
				if(bodyText)
					//Use Spark Rich Text - Start
					//bodyText.htmlText = projectContentItem.longDescription;
					bodyText.textFlow = TextConverter.importToFlow(projectContentItem.longDescription, TextConverter.TEXT_FIELD_HTML_FORMAT);
					//End
				
				_itemViewSource = DataManager.getInstance().fetchBinaryContentByType(_projectContentItem, BinaryType.VIDEO);
				if(_itemViewSource != "")
				{
					if(AvatarManager.getInstance().defaultAvatarPlayer)
						AvatarManager.getInstance().defaultAvatarPlayer.pause();
					if(currentState != "stateVideo")
						currentState = "stateVideo";
					if(video)
						video.source = _itemViewSource;
				}
				else
				{
					_itemViewSource = DataManager.getInstance().fetchBinaryContentByType(_projectContentItem, BinaryType.IMAGE);
					if(_itemViewSource != "")
					{
						if(currentState != "stateImage")
							currentState = "stateImage";
						if(image)
							image.source = _itemViewSource;
						
					}
				}
				_dataChanged = false;
			}
		}
		
		override protected function onRemoved(e:FlexEvent):void
		{
			super.onRemoved(e);
			if(LocationUtil.isAirApplication()) {
				SessionManager.getInstance().resumeSession();
			}
		}
		
		public function print():void
		{
			if(printTemplate)
				PrintUtil.doPrint(printTemplate);
			
			ApplicationUtil.updateSession(projectContentItem.id, ActionType.PRINT, 
				localToGlobal(new Point(this.mouseX,this.mouseY)));
		}
		
		public function email():void
		{
			ApplicationUtil.email("Info for the " + projectContentItem.name, 
				StringUtil.replace(projectContentItem.longDescription, '<a href="event:', '<a href="') + footerText,
				"do_not_reply@digitalaisle.com", projectContentItem.id);
		}
		
		private function onComponentAdd(e:FlexEvent):void
		{
			switch(e.target)
			{
				case image:
					image.source = _itemViewSource;
					break;
				case video:
					video.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onVideoPlayerStateChange, false, 0, true);
					video.source = _itemViewSource;
					break;
			}
		}
		
		private function onComponentRemove(e:FlexEvent):void
		{
			if(e.target == video)
				video.removeEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onVideoPlayerStateChange);
		}
		
		private function onVideoPlayerStateChange(e:MediaPlayerStateChangeEvent):void
		{
			switch(e.state)
			{
				case MediaPlayerState.PLAYING:
					if(currentState == "stateVideo" && LocationUtil.isAirApplication())
						SessionManager.getInstance().pauseSession();
					break;
				case MediaPlayerState.PAUSED:
				case MediaPlayerState.PLAYBACK_ERROR:
					if(currentState == "stateVideo" && LocationUtil.isAirApplication())
						SessionManager.getInstance().resumeSession();
					break;
			}
		}
		
		private function onVideoPlayerComplete(e:TimeEvent):void
		{
			if(LocationUtil.isAirApplication()) {
				SessionManager.getInstance().resumeSession();
			}
		}
		
		[Bindable]
		public function get projectContentItem():ProjectContentItem { 
			return _projectContentItem; 
		}
		
		public function set projectContentItem(value:ProjectContentItem):void {
			
			if(_projectContentItem)
			{
				if(_projectContentItem === value)
					return;
			}
			
			_projectContentItem = value;
			_dataChanged = true;
			invalidateDisplayList();
			dispatchEvent(new Event("itemChange"));
			
			
			/*if(value is ProjectProductItem)
			{
				type = PRODUCT;
				
			}else if(value is ProjectEventItem){
				type = EVENT;
			}*/
										
			/*if(txtTitle)
				txtTitle.text = value.name;
			
			if(txtSubTitle)
				txtSubTitle.text = value.shortDescription;
			
			if(printTemplate)
				printTemplate.projectContentItem = projectContentItem;
			
			if(bodyText)
				bodyText.htmlText = value.longDescription;*/
			
			//getBinaryContent();
			
		}
		/*public function get productViewMode():String { return _productViewMode;}
		public function set productViewMode(value:String):void
		{
			_productViewMode = value;
			getBinaryContent();
		}*/
		
		/*private function getBinaryContent():void
		{
			switch(_productViewMode)
			{ 
				case VIDEO:
					_videoSource = DataManager.getInstance().fetchBinaryContentByType(_projectContentItem, BinaryType.VIDEO);
					if(_videoSource != "")
					{
						currentState = "stateVideo";
						if(video)
							video.source = _videoSource;
					}else{
						productViewMode = IMAGE;
						return;
					}
					break;
				case IMAGE:
					_imageSource = DataManager.getInstance().fetchBinaryContentByType(_projectContentItem, BinaryType.IMAGE);
					currentState = "stateImage";
						if(image)
							image.source = _imageSource;
					break;
			}	
		}*/
			
		private function onButtonClick(e:MouseEvent):void
		{
			switch(e.target)
			{
				case btnPrint:
					print();
					break;
				case btnEmail:
					email();
					break;
			}
		}		

	}
}