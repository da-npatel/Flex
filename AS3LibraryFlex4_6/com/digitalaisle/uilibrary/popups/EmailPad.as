package com.digitalaisle.uilibrary.popups
{
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.managers.KioskServiceManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.uilibrary.components.ClearableTextInput;
	import com.digitalaisle.uilibrary.components.buttons.DAButton;
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.events.EmailPadEvent;
	import com.digitalaisle.uilibrary.keypads.Keyboard;
	import com.digitalaisle.uilibrary.skins.EmailPadSkin;
	import com.digitalaisle.uilibrary.supportClasses.ContainerBase;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	import mx.events.ValidationResultEvent;
	import mx.managers.IFocusManagerContainer;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.states.State;
	import mx.validators.EmailValidator;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import spark.components.Label;
	import spark.components.RichText;
	import spark.primitives.BitmapImage;
	
	/**
	 *  Module state using the Module Loader
	 */
	[SkinState("email")]
	
	/**
	 *  Product page state using the ProductPage
	 */
	[SkinState("confirm")]
	
	/**
	 *  SWF/Image/Video state using the AssetContainer see#AssetContainer
	 */
	[SkinState("success")]
	
	/**
	 *  SWF/Image/Video state using the AssetContainer see#AssetContainer
	 */
	[SkinState("fail")]
	
	[Style(name="closeButtonStyleName", type="String", inherit="yes")]
	
	[Style(name="inputFieldStyleName", type="String", inherit="yes")]
	
	[Style(name="sentImageBitmap", type="flash.dispaly.Bitmap", inherit="yes")]
	
	[Style(name="failedImageBitmap", type="flash.dispaly.Bitmap", inherit="yes")]
	
	/*[Style(name="emailVerificationStyleName", type="String", inherit="yes")]*/
	
	[Style(name="primaryColor",type="uint",format="Color",inherit="yes")]
	
	[Style(name="secondaryColor",type="uint",format="Color",inherit="yes")]
	
	public class EmailPad extends ContainerBase implements IFocusManagerContainer
	{
		public var itemId:int = 0;
		public var message:String;
		public var subject:String;
		public var from:String;
		[Bindable]
		public var headerImageBitmap:Bitmap;
		
		/** Skin Parts **/
		[SkinPart(required="true")]
		public var closeBtn:DASimpleButton;
		[SkinPart(required="true")]
		public var sendBtn:DAButton;
		[SkinPart(required="true")]
		public var tryAgainBtn:DAButton;
		[SkinPart(required="true")]
		public var confirmBtn:DAButton;
		[SkinPart(required="true")]
		public var inputField:ClearableTextInput;
		[SkinPart(required="true")]
		public var keypad:Keyboard;
		[SkinPart(required="true")]
		public var infoMessage:RichText;
		[SkinPart(required="true")]
		public var emailFeedbackImage:BitmapImage;
		[SkinPart(required="true")]
		public var okButton:DAButton;
		[SkinPart(required="true")]
		public var emailVerificationLabel:Label;
		
		private var _emailVaildator:EmailValidator = new EmailValidator();
		[Bindable]
		private var _enteredEmailAddress:String;
		[Bindable]
		private var _emailFeedbackBitmap:Bitmap;
		
		public function EmailPad()
		{
			super();
			addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onCurrentStateChange, false, 0, true);
			setStyle("skinClass", EmailPadSkin);
			currentState = "email";
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			states.push(new State({name:"email"}));
			states.push(new State({name:"confirm"}));
			states.push(new State({name:"success"}));
			states.push(new State({name:"fail"}));
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
				case keypad:
					keypad.inputField = inputField;
					break;
				case sendBtn:
					if(getStyle("inputBackgroundBitmap"))
						headerImageBitmap = createBitmapFromClass(getStyle("inputBackgroundBitmap"));
					verifyPopulateStyleName(sendBtn, getStyle("sendButtonStyleName"));
					sendBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
					sendBtn.addEventListener(FlexEvent.ADD, onElementAdd);
					break;
				case closeBtn:
					verifyPopulateStyleName(closeBtn, getStyle("closeButtonStyleName"));
					closeBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case tryAgainBtn:
					verifyPopulateStyleName(tryAgainBtn, getStyle("tryAgainButtonStyleName"));
					tryAgainBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case confirmBtn:
					verifyPopulateStyleName(confirmBtn, getStyle("confirmButtonStyleName"));
					confirmBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case inputField:
					_emailVaildator.enabled = true;
					_emailVaildator.source = inputField;
					_emailVaildator.property = "text";
					_emailVaildator.addEventListener(ValidationResultEvent.VALID, onEmailValidationValid, false, 0, true);
					_emailVaildator.addEventListener(ValidationResultEvent.INVALID, onEmailValidationInvalid, false, 0, true);
					inputField.addEventListener(Event.CHANGE, onInputChange);
					verifyPopulateStyleName(inputField, getStyle("inputFieldStyleName"));
					break;
				case infoMessage:
					infoMessage.text = "Please Confirm The Email Address Provided Is Correct";
					verifyPopulateStyleName(infoMessage, getStyle("titleMessageStyleName"));
					break;
				case emailFeedbackImage:
					emailFeedbackImage.source = _emailFeedbackBitmap;
					break;
				case emailVerificationLabel:
					verifyPopulateStyleName(emailVerificationLabel, getStyle("emailVerificationStyleName"));
					emailVerificationLabel.addEventListener(FlexEvent.ADD, onElementAdd);
					emailVerificationLabel.text = _enteredEmailAddress;
					break;
				case okButton:
					okButton.addEventListener(MouseEvent.CLICK, onButtonClick);
					break;
			}

		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case sendBtn:
					sendBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case closeBtn:
					closeBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case tryAgainBtn:
					tryAgainBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case confirmBtn:
					confirmBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
					break;
				case inputField:
					_emailVaildator.removeEventListener(ValidationResultEvent.VALID, onEmailValidationValid);
					_emailVaildator.removeEventListener(ValidationResultEvent.INVALID, onEmailValidationInvalid);
					inputField.removeEventListener(Event.CHANGE, onInputChange);
					break;
				case emailVerificationLabel:
					emailVerificationLabel.removeEventListener(FlexEvent.ADD, onElementAdd);
					break;
			}
		}
		
		
		override protected function onAdded(e:FlexEvent):void
		{
			super.onAdded(e);
		}
		
		private function verifyPopulateStyleName(instance:Object, styleName:Object):void
		{
			if(styleName)
			{
				try{
					instance.styleName = styleName;
				}catch(errorObject:Error){
					MonsterDebugger.trace(this, "Warning: The following style, " + getStyle("sendButtonStyleName") + " , does not exist.  Please double check the spelling and/or existence of this style name.", MonsterDebugger.COLOR_WARNING);
				}
			}
		}
		
		private function createBitmapFromClass(BtnClass:Class):Bitmap
		{
			var btnBitmap:Bitmap = new BtnClass();
			btnBitmap.smoothing = true;
			return btnBitmap;
		}
		
		private function onButtonClick(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case sendBtn:
					_enteredEmailAddress = inputField.text;
					currentState = "confirm";
					break;
				case tryAgainBtn:
					currentState = "email";
					break;
				case confirmBtn:
					if(currentState == "confirm")
					{
						confirmBtn.enabled = tryAgainBtn.enabled = false;
						var recipients:Array = [_enteredEmailAddress];
						ApplicationUtil.updateSession(itemId, ActionType.EMAIL, new Point(confirmBtn.x, confirmBtn.y), recipients[0] + ";");
						KioskServiceManager.getInstance().sendEmail(new ArrayCollection(recipients), subject, message, from, onEmailSent, onEmailFailed);
					}
					break;
				case closeBtn:
					PopUpManager.removePopUp(this);
					break;
				case okButton:
					PopUpManager.removePopUp(this);
					break;
			}
		}
		
		private function onElementAdd(e:FlexEvent):void
		{
			switch(e.target)
			{
				case sendBtn:
					sendBtn.enabled = false;
					break;
				case emailVerificationLabel:
					emailVerificationLabel.text = _enteredEmailAddress;
					break;
				
			}
		}
		
		
		private function onCurrentStateChange(e:StateChangeEvent):void
		{
			if(e.newState == "confirm"){
				if(emailVerificationLabel)
					emailVerificationLabel.text = _enteredEmailAddress;
			}
				
		}
		
		private function onEmailValidationValid(e:ValidationResultEvent):void
		{
			sendBtn.enabled = true;
		}
		
		private function onEmailValidationInvalid(e:ValidationResultEvent):void
		{
			sendBtn.enabled = false;
		}
		
		private function onEmailSent(e:ResultEvent):void
		{
			currentState = "success";
			_emailFeedbackBitmap = null;
			if(getStyle("sentImageBitmap"))
				_emailFeedbackBitmap = createBitmapFromClass(getStyle("sentImageBitmap"));
			
			ApplicationUtil.topLevel.dispatchEvent(new EmailPadEvent(EmailPadEvent.EMAIL_SENT));
		}
		
		private function onEmailFailed(e:FaultEvent):void
		{
			
			currentState = "fail";
			_emailFeedbackBitmap = null;
			if(getStyle("failedImageBitmap"))
				_emailFeedbackBitmap = createBitmapFromClass(getStyle("failedImageBitmap"));
			
			ApplicationUtil.topLevel.dispatchEvent(new EmailPadEvent(EmailPadEvent.EMAIL_FAILED));
		}
		
		private function onInputChange(e:Event):void
		{
			_emailVaildator.validate();
		}

	}
}