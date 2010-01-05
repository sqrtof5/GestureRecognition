package {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	
	import flash.geom.Point;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/*
	
	Part of a very simple gesture recognition engine
	Written by Arnaud Icard
	http://www.sqrtof5.com/
	Project page and basic explanations:
	http://blog.sqrtof5.com/?p=173
	
	This is an example that puts the Gesture recognition
	engine together.
	Well. Engine is a pretty big word for what this is.
	Oh. and it uses StrokeRenderer to do some kind of
	effect whil the user is drawing.
	
	This requires lib/lib.swc to compile.
	Using the SDK, one could compile this using something like:

	mxmlc -target-player 10.0.0 src/GestureRecognition.as -library-path lib/lib.swc -output bin/GestureRecognition.swf 

	*/
	
	[ SWF (width=500, height=411, backgroundColor=0xAEAEAE, frameRate=31) ]
	public class GestureRecognition extends Sprite {
	
		private var gesturesIcons		:MovieClip;
		private var select				:MovieClip;
		private var iconsWidth			:Number = 75;
		
		private var drawPoints			:Vector.<Point>;
		private var dataPoints			:Vector.<Point>;

		private var strokeRenderer		:StrokeRenderer;
		private var gestureProcessor	:GestureProcessor;
		private var gestureDictionary	:GestureDictionary;
		
		private var isDrawing			:Boolean;
		
		private var bitmap:Bitmap;
		
	
		public function GestureRecognition() {
			
			stage.scaleMode = "noScale";
			
			//icons
			gesturesIcons = new gestures_icons();
			addChild(gesturesIcons);
			
			select = new hilight();
			select.width = select.height = iconsWidth;
			select.blendMode = "add";
			addChild(select);

			var count:int = 1;

			for (var i:uint=0; i<5; i++) {
				for (var j:uint=0; j<3; j++) {
					var _icon:MovieClip = gesturesIcons.getChildByName("gesture_" + count) as MovieClip;
					_icon.width = _icon.height = iconsWidth;
					_icon.x = 14 + j*(iconsWidth+2);
					_icon.y = 14 + i*(iconsWidth+2);
					_icon.alpha = .8;
					count++;
				}
			}
			
			resetHilight();
			
			//stroke render, gesture handling
			
			bitmap = new Bitmap(new BitmapData(800, 600, true, 0), "auto", true);
			bitmap.blendMode = "add";
			addChild(bitmap);
			
			strokeRenderer = new StrokeRenderer(bitmap);
			gestureProcessor = new GestureProcessor();
			gestureDictionary = new GestureDictionary();
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
			addEventListener(Event.ENTER_FRAME, doRenderStroke);
			
			
		}
		
		private function handleMouseEvents(evt:MouseEvent):void {

			switch(evt.type) {
				case MouseEvent.MOUSE_DOWN:
					if (evt.currentTarget == stage) {
						drawPoints = new Vector.<Point>();
						dataPoints = new Vector.<Point>();
						stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvents);
					}
					isDrawing = true;
					break;
				case MouseEvent.MOUSE_UP:
					//drawPoints = new Vector.<Point>();
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvents);
					if (dataPoints && dataPoints.length > 0) {
						var gesturePoints:Vector.<Point> = gestureProcessor.process(dataPoints);
						var _index:int = int(gestureDictionary.findMatch(gesturePoints).matchingIndex);
						resetHilight();
						select.x = gesturesIcons.getChildByName("gesture_"+(_index+1)).x;
						select.y = gesturesIcons.getChildByName("gesture_"+(_index+1)).y;
						gesturesIcons.getChildByName("gesture_"+(_index+1)).alpha = 1;
						select.visible = true;
					}
					isDrawing = false;
					dataPoints = new Vector.<Point>();
					break;
				case MouseEvent.MOUSE_MOVE:
					drawPoints.push(new Point(mouseX, mouseY));
					dataPoints.push(new Point(mouseX, mouseY));
					break;
			}

		}
		
		
		private function doRenderStroke(evt:Event):void {
			if (drawPoints) {
				strokeRenderer.draw(drawPoints);
				if (!isDrawing) {
					drawPoints.shift();
				} else {
					if (drawPoints.length > 6) drawPoints.shift();
				}
			}
		}
		
		private function resetHilight():void {
			for (var i:uint=1; i<=15; i++) {
				var _icon:MovieClip = gesturesIcons.getChildByName("gesture_"+i) as MovieClip;
				_icon.alpha = .7;
			}
			select.visible = false;
		}
	
	}

}