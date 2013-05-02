package com.digitalaisle.frontend.components {
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.events.UserTouchEvent;
	import com.digitalaisle.frontend.valueObjects.DASpindleObject;
	import com.greensock.TweenLite;
	
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	//Change MX controls to Spark Controls - Start
	//import mx.controls.Image;
	//import mx.controls.Label;
	import spark.components.Image;
	import spark.components.Label;
	//End
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.VGroup;

	public class DASpindle extends BorderContainer {
		
	//	public var itemStyleDec:CSSStyleDeclaration = new CSSStyleDeclaration("{fontSize : 18; color : #ff0000;}");
		
		private const ITEM_HEIGHT:Number = 45;
		[Bindable]
		private var _selectedItem:DASpindleObject;
		[Bindable]
		private var _selectedIndex:int;
		[Bindable]
		private var _selectedID:int;
		
		public var loops:Boolean = false;
		private var numberOfItemsNeededToLoop:int = 7;
		
		//data collection needs to come from parent
		private var _dataProvider:ArrayCollection;			
		
		//main item display group
		private var cellContainer:VGroup = new VGroup();
		private var cellContainerClone:VGroup = new VGroup();
		private var cellContainerBeingUsed:VGroup = new VGroup();
		private var topContainer:VGroup = cellContainer;
		private var bottomContainer:VGroup = cellContainerClone;
		private const offscreenBuffer:Number = 50;
		
		//vars for motion controls			
		private const FRICTION:Number = .5;
		private const DOWN:Number = -1;
		private const UP:Number = 1;
		private var direction:Number = UP;
		//these two vars are used to get a delta.  Delta over time is velocity.
		private var y1:Number;
		private var y2:Number;
		private var velocity:Number = 0;
		
		//THESE VARS SET IN invalidateConstraints()
		private var highConstraint:Number;
		private var lowConstraint:Number;
		
		private var contentMask:BorderContainer = new BorderContainer();
		private var contentMask2:BorderContainer = new BorderContainer();
		
		private var _bgImg:Image = new Image();
		private var _selectedImg:Image = new Image();
		private var _selectedImage:String;
		private var _bgImage:String;
		
		public function DASpindle() {
			super();
			cellContainer.gap = 0;
			cellContainerClone.gap = 0;
			this._selectedImg.mouseEnabled = false;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			_bgImg.width = 418;
			_bgImg.addEventListener(Event.COMPLETE, onImageComplete, false, 0, true);
			this.addElement(_bgImg);
			_selectedImg.width = 418;
			_selectedImg.addEventListener(Event.COMPLETE, onImageComplete, false, 0, true);
			_selectedImg.addEventListener(FlexEvent.UPDATE_COMPLETE, fixit, false, 0, true);
			this.addElement(_selectedImg);
			_selectedImg.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown_cellContainer, false, 0, true);
			_selectedImg.addEventListener(MouseEvent.MOUSE_UP, onMouseUp_cellContainer, false, 0, true);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false, 0, true);
		}
		
		private function onMouseDown_cellContainer(evt:MouseEvent):void{
			dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.FLICK, new Point(evt.stageX, evt.stageY),"spindle")); 
			
			if(this.hasEventListener(Event.ENTER_FRAME)){
				this.removeEventListener(Event.ENTER_FRAME, oef_cellContainerWithVelocity);
				this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			TweenLite.killTweensOf(this.cellContainer);
			TweenLite.killTweensOf(this.cellContainerClone);
			invalidateConstraints();
			var container:VGroup;
			if(cellContainerClone.hitTestPoint(evt.stageX, evt.stageY)){
				container = cellContainerClone;
			}else{
				container = cellContainer;
			}
				
			
			this.cellContainerBeingUsed = container;
			if(!(container == cellContainer) && !(container == cellContainerClone)){
				throw new Error("spindle broke");
			}
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp_cellContainer, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, onMouseUp_cellContainer, false, 0, true);
			
			this.y1 = this.mouseY;
			this.y2 = this.mouseY;
			container.startDrag(false, new Rectangle(0, highConstraint, 0, lowConstraint-highConstraint));
		}
		private function onMouseUp_cellContainer(evt:MouseEvent):void{
			if(evt.type == MouseEvent.MOUSE_OUT){
				if(this.hitTestPoint(evt.stageX, evt.stageY)){
					return;
				}
			}
			
			var container:UIComponent = this.cellContainerBeingUsed;
			this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	//		this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp_cellContainer);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseUp_cellContainer);
			
			container.stopDrag();
			this.addEventListener(Event.ENTER_FRAME, oef_cellContainerWithVelocity, false, 0, true);
			y1 > y2 ? direction = DOWN : direction = UP;
			this.velocity = y1-y2;
		}
		private function onMouseMove(evt:MouseEvent):void{
			if(constraintsAreViolated() && !loops){
				return;
			}
			var container:VGroup;
			var slaveContainer:VGroup;
			if(cellContainerClone.hitTestPoint(evt.stageX, evt.stageY)){
				container = cellContainerClone;
				slaveContainer = cellContainer
			}else{
				container = cellContainer;
				slaveContainer = cellContainerClone;
			}
			
			this.y2 = this.y1;
			this.y1 = this.mouseY;
			this.moveFirstContainerToBottomOfSecondContainer(slaveContainer, container);
		}
		private function oef_cellContainerWithVelocity(evt:Event):void{
			if(velocity > 50){
				velocity = 50;
			}
			if(velocity < -50){
				velocity = -50;
			}
			cellContainer.y += velocity;
			cellContainerClone.y += velocity;
			velocity += FRICTION * direction;
			
			if(this.velocity > -1 && this.velocity < 1){
				//final tween and stop
				this.removeEventListener(Event.ENTER_FRAME, oef_cellContainerWithVelocity);
				comeToRest();
			}
			//if ((constraints are violated, AND (we aren't looping OR don't have enough items to loop)).
			if(constraintsAreViolated() && (!loops || this.dataProvider.length <= numberOfItemsNeededToLoop)){
				this.removeEventListener(Event.ENTER_FRAME, oef_cellContainerWithVelocity);
				comeToRest();
			}
			
			this.moveFirstContainerToBottomOfSecondContainer(bottomContainer, topContainer);
			
			//if the container on top is off the screen and direction is up, move it to the bottom
			if( (topContainer.y < -1 * (topContainer.height + offscreenBuffer)) && direction == UP){
				this.moveFirstContainerToBottomOfSecondContainer(topContainer, bottomContainer);
			}
			if((bottomContainer.y > this.height + offscreenBuffer) && (direction == DOWN)){
				this.moveFirstContainerToTopOfSecondContainer(bottomContainer, topContainer);
			}
			
		}
		private function comeToRest():void{
			//ONE BILLION PIXELS!
			var scoreToBeat:Number = 1000000000;
			var winningNodeDiff:Number = 1000000000;
			var winningNode:UIComponent;
			var winningIndex:Number = 0;
			var winnerIsInCloneSet:Boolean = false;
			
			for(var i:int = 0; i < this.cellContainer.numElements; i++){
				var node:UIComponent = this.cellContainer.getElementAt(i) as UIComponent;
				var yCoord:Number = cellContainer.y + node.y;
				var diff:Number = this._selectedImg.y - yCoord;
				var wasNeg:Boolean = false;
				
				if(diff < 0){
					diff *= -1;
					wasNeg = true;
				}
				if(diff	< scoreToBeat){
					scoreToBeat = diff;
					winningNode = node;
					winningIndex = i;
					wasNeg ? winningNodeDiff = diff * -1 : winningNodeDiff = diff;
				}else{
				}
			}
			if(loops){
				//same loop but for clone set
				for(var j:int = 0; j < this.cellContainerClone.numElements; j++){
					var node2:UIComponent = this.cellContainerClone.getElementAt(j) as UIComponent;
					var yCoord2:Number = cellContainerClone.y + node2.y;
					var diff2:Number = this._selectedImg.y - yCoord2;
					var wasNeg2:Boolean = false;
					
					if(diff2 < 0){
						diff2 *= -1;
						wasNeg2 = true;
					}
					if(diff2 < scoreToBeat){
						scoreToBeat = diff2;
						winningNode = node2;
						winningIndex = j;
						wasNeg2 ? winningNodeDiff = diff2 * -1 : winningNodeDiff = diff2;
						winnerIsInCloneSet = true;
					}else{
					}
				}
			}
			
			this._selectedIndex = winningIndex;
			this._selectedItem = this.dataProvider.getItemAt(this._selectedIndex) as DASpindleObject;
			this._selectedID = this._selectedItem.uid;
			
			var changeEvent:Event = new Event(Event.CHANGE);
			this.dispatchEvent(changeEvent);
			
			var dest:Number = this.cellContainerClone.y + winningNodeDiff;
			TweenLite.to(this.cellContainerClone, 1, {y:dest});
			var dest2:Number = this.cellContainer.y + winningNodeDiff;
			TweenLite.to(this.cellContainer, 1, {y:dest2});
			dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.CLICK, new Point(this.x, this.y),this._selectedItem.text)); 
			
		}
		
		private function invalidateConstraints():void{
			highConstraint = -1 * (this.cellContainer.height - (this._bgImg.height * .45));
			lowConstraint = this._bgImg.height * .55;
			
			if(loops && this.dataProvider.length > 7){
				highConstraint = -2 * this.cellContainer.height;
				lowConstraint = 4 * this.cellContainer.height;
			}
			
		}
		private function constraintsAreViolated():Boolean{
			invalidateConstraints();
			//high constraint is a negative number and low constraint is a positive number
			if(this.cellContainer.y > lowConstraint || this.cellContainer.y < highConstraint){
				return true;
			}
			return false;
		}
		
		private function createCells():void{
			this.numberOfItemsNeededToLoop = Math.ceil(this._bgImg.height / this.dataProvider.length)+2;
			
			for(var i:int = 0; i < this._dataProvider.length; i++){
				var node:DASpindleObject = this._dataProvider.getItemAt(i) as DASpindleObject;
				if(node.type == DASpindleObject.CONTENT_TYPE_TEXT){
					var cell:Group = new Group();
					cell.height = ITEM_HEIGHT;
					cell.width = this.width;
					
					var myLabel:Label = new Label();
					myLabel.text = String(node.text);
					myLabel.horizontalCenter = myLabel.verticalCenter = 0;
					myLabel.styleName = "spindleLabel";
					cell.addElement(myLabel);
					cellContainer.addElement(cell);
					
				}else if(node.type == DASpindleObject.CONTENT_TYPE_IMAGE){
					//TODO: make it work
					//cellContainer.addChild(node as Image);
				}
			}
			this.addElement(cellContainer);
			this.invalidateConstraints();
			this.cellContainer.mask = contentMask;
			this.cellContainerClone.mask = contentMask2;
			this.cellContainer.y = 123;
			
			//create a second cell container just like the first. 
			if(loops && this.dataProvider.length > 7){
				for(var j:int = 0; j < this._dataProvider.length; j++){
					var node2:DASpindleObject = this._dataProvider.getItemAt(j) as DASpindleObject;
					if(node2.type == DASpindleObject.CONTENT_TYPE_TEXT){
						var cell2:Group = new Group();
						cell2.height = ITEM_HEIGHT;
						cell2.width = this.width;
						
						var myLabel2:Label = new Label();
						myLabel2.text = String(node2.text);
						myLabel2.styleName = "spindleLabel";
						myLabel2.horizontalCenter = myLabel2.verticalCenter = 0;
						cell2.addElement(myLabel2);
						cellContainerClone.addElement(cell2);
						
					}else if(node2.type == DASpindleObject.CONTENT_TYPE_IMAGE){
						//TODO: make it work
						//cellContainer.addChild(node as Image);
					}
				}
				this.addElement(cellContainerClone);
				cellContainerClone.y = 500;
				this.invalidateConstraints();
				//comeToRest();
			}
			this._selectedIndex = 0;
			this._selectedItem = this.dataProvider.getItemAt(this._selectedIndex) as DASpindleObject;
			this._selectedID = this._selectedItem.uid;
		}
		private function moveFirstContainerToBottomOfSecondContainer(first:VGroup, second:VGroup):void{
			if(first === cellContainer){
		//		trace("cellContainer to bottom of cellContainerClone");	
			}else{
		//		trace("cellContainerClone to bottom of cellContainer");	
			}
			if(TweenLite.masterList[first] != null){
				return;
			}
			//if this is what is being dragged(also this is a horrible way to learn this information);
			if(first.hasEventListener(MouseEvent.MOUSE_MOVE)){
				this.moveFirstContainerToTopOfSecondContainer(second, first);
				return;
			}
			
			var coord:Number = second.y + second.height;
			first.y = coord;
			this.topContainer = second;
			this.bottomContainer = first;
		}
		private function moveFirstContainerToTopOfSecondContainer(first:VGroup, second:VGroup):void{
			if(first === cellContainer){
	//			trace("cellContainer to top of cellContainerClone");	
			}else{
	//			trace("cellContainerClone to top of cellContainer");	
			}
			TweenLite.killTweensOf(first);
			
			var coord:Number = second.y - first.height;
			first.y = coord;
			this.topContainer = first;
			this.bottomContainer = second;
		}
		public function reset():void{
			//this.cellContainer.y = this._selectedImg.y;
			//this.moveFirstContainerToTopOfSecondContainer(cellContainerClone, cellContainer);
			//comeToRest();
			TweenLite.to(this.cellContainer, .5, {y:this._selectedImg.y, onComplete:comeToRest});
		}
		
		//////////////////HANDLERS/////////////////////////////////
		private function onCreationComplete(evt:FlexEvent):void{
			cellContainer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown_cellContainer, false, 0, true);
			cellContainer.addEventListener(MouseEvent.MOUSE_UP, onMouseUp_cellContainer, false, 0, true);
			cellContainerClone.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown_cellContainer, false, 0, true);
			cellContainerClone.addEventListener(MouseEvent.MOUSE_UP, onMouseUp_cellContainer, false, 0, true);
			
			
			contentMask.width = this.width;
			contentMask.height = this.height;
			contentMask.backgroundFill = new SolidColor(0xff0000);
			contentMask2.width = this.width;
			contentMask2.height = this.height;
			contentMask2.backgroundFill = new SolidColor(0xff0000);
			this.addElement(contentMask);
			this.addElement(contentMask2);
			trace("DASPINDLE CREATION COMPLETE");
		}
		
		private function onImageComplete(e:Event):void{
			var img:Image = e.currentTarget as Image;
			if(img.content != null)img.content.width = img.width;
			img.y = (img.parent.height / 2)-(img.content.height/2);
		}
		private function onImgIOE(evt:IOErrorEvent):void{
			Alert.show(evt.text, "Err");
		}
		
		///////////////////////GETTERS AND SETTERS////////////////////////
		public function get dataProvider():ArrayCollection{
			return this._dataProvider;
		}
		public function set dataProvider(val:ArrayCollection):void{
			for(var i:int = 0; i < val.length; i++){
				//if NOT
				if(!(val.getItemAt(i) is DASpindleObject)){
					throw new Error("DASPindle only accepts DASPindleObjects as items in DP");	
				}
			}
			this._dataProvider = val;
			createCells();
		}
		
		private function onBgImgUpdateComplete(evt:FlexEvent):void{
			this.addElement(_selectedImg);
			//_selectedImg.verticalCenter = 0;
		}
		
		[Bindable]
		public function get selectedImage():String
		{
			return _selectedImage;
		}
		
		public function set selectedImage(url:String):void{
			if(selectedImage == url){
				return;
			}
			_selectedImage = url;
			this._selectedImg.load(url);
			this.addElement(_selectedImg);
		}
		public function get selectedItem():DASpindleObject{
			return this._selectedItem;
		}
		public function set selectedItem(val:DASpindleObject):void{
			for(var i:int = 0; i < this.dataProvider.length; i++){
				if(this.dataProvider.getItemAt(i) == val){
					this.selectedIndex = i;
					break;
				}
			}
		}
		public function get selectedIndex():int{
			return this._selectedIndex;
		}
		public function set selectedIndex(val:int):void{
			if(this.dataProvider.length < val + 1){
				throw new Error("specified index is out of range");
			}
			var node:DASpindleObject = this.dataProvider.getItemAt(val) as DASpindleObject;
			if(node != null){
				this._selectedIndex = val;
				this._selectedItem = node;
				this._selectedID = node.uid;
				
				this.cellContainer.y = this._selectedImg.y - (this._selectedIndex * this.ITEM_HEIGHT);
				comeToRest();
			}else{
				throw new Error("DASpindle could not find a data node for the specified index.");
			}
		}
		public function get selectedID():int{
			return this._selectedID;
		}
		public function set selectedID(val:int):void{
			for(var i:int = 0; i < this.dataProvider.length; i++){
				if((this.dataProvider.getItemAt(i) as DASpindleObject).uid == val){
					this.selectedIndex = i;
					break;
				}
			}
		}
		
		public function fixit(evt:FlexEvent):void{
			_selectedImg.y = (_bgImg.height / 2)-(_selectedImg.content.height/2);
			this._bgImg.y = 0;
		}

		public function get bgImage():String
		{
			return _bgImage;
		}

		public function set bgImage(value:String):void
		{
			if(bgImage == value)
				return;
			
			_bgImage = value;
			this._bgImg.addEventListener(FlexEvent.UPDATE_COMPLETE , onBgImgUpdateComplete, false, 0, true);
			this._bgImg.load(value);
			this.addElement(_bgImg);
			if(this._selectedImg != null){
				this.addElement(this._selectedImg);
			}
		}

	}
}
