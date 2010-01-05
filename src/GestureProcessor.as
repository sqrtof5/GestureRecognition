package {

	import flash.display.Sprite;
	import flash.geom.Point;

	/*
	
	Part of a very simple gesture recognition engine
	Written by Arnaud Icard
	http://www.sqrtof5.com/
	Project page and basic explanations:
	http://blog.sqrtof5.com/?p=173
	
	This class is responsible to process user input,
	prep the data to be matched against entries
	in GestureDictionary.
	
	*/

	public class GestureProcessor {
		
		private const numPts	:int = 36;
		
		private var _raw		:Vector.<Point>;
		private var _copy		:Vector.<Point>;
		private var _simplified	:Vector.<Point>;
		
		function GestureProcessor() {
			//!			
		}
		
		public function process(dataPoints:Vector.<Point>):Vector.<Point> {
			
			_raw = dataPoints;
	
			_copy = _raw.concat();
			
			//calculate raw path length
				var _length:Number = calcLength(_raw);

			//simplify/normalize
			//last segment will not be normalized and will be discarded
			//since it is not necessary for the gesture to be complete
			//in order to be recognized.
				_simplified = new Vector.<Point>();
				_simplified.push(_copy[0]);
				var _target_segment_length:Number = _length/numPts;
				doProcess(1, _simplified[0], _target_segment_length);
			
			//! COMMENT OUT TO COMPARE TO RAW PATH
				scalePath(_simplified);
			return (_simplified);
			
		}
		
		private function calcLength(_path:Vector.<Point>):Number {
			
			var _length:Number = 0;
			
			for (var i:uint=1; i<_path.length; i++) {
				_length += Point.distance(_path[int(i-1)], _path[i]);
			}
			
			return _length;
			
		}
		
		private function scalePath(_path:Vector.<Point>):void {
			
			var _scaled:Vector.<Point> = _path.concat();
			
			_scaled.sort(sortOnX);
			// get leftmost point
			var _left:Point = new Point(_scaled[0].x, _scaled[0].y);
			// get rightmost point
			var _right:Point = new Point(_scaled[_scaled.length-1].x, _scaled[_scaled.length-1].y);
			
			_scaled.sort(sortOnY);
			// get topmost point
			var _top:Point = new Point(_scaled[0].x, _scaled[0].y);
			// get bottom-most point
			var _bottom:Point = new Point(_scaled[_scaled.length-1].x, _scaled[_scaled.length-1].y);
			
			var _width:Number = _right.x - _left.x;
			var _height:Number = _bottom.y - _top.y;
			
			var _ratio:Number;
			if (_width > _height) {
				// get scale ratio based on width
				_ratio = 1/_width;
			} else {
				// get scale ratio based on height
				_ratio = 1/_height;
			}
			
			for (var i:uint=0; i<_path.length; i++) {
				_path[i].x -= _left.x;
				_path[i].y -= _top.y;
				_path[i].x *= _ratio;
				_path[i].y *= _ratio;
			}
			
			//return _scaled;
			
		}
		
		private function doProcess(_startIndex:uint, _center:Point, _r:Number):void {
			
			var startIndex:uint = _startIndex;
			var center:Point = new Point(_center.x, _center.y);
			var r:Number = _r;
			var p1:Point;
			
			/*
			
			find closest intersections with path
			and circle of radius r
			imperfect method, since r is based on length of initial path
			and the simplified path is likely to be shorter
			
			uses heavily line segment/circle intersection algorithm
			by Paul Bourke:
			http://local.wasp.uwa.edu.au/~pbourke/geometry/sphereline/
			
			*/
			
			for (var n:uint=1; n < numPts; n++) {
				
				for (var i:uint=startIndex; i<_copy.length; i++) {
				
					//var p1:Point = new Point(center.x, center.y);
					if (! p1) p1 = new Point(center.x, center.y);
					var p2:Point = _copy[i];
					var ip:Point;
				
					var dx:Number = p2.x - p1.x;
					var dy:Number = p2.y - p1.y;
					var a:Number = dx*dx + dy*dy;
					var b:Number = (dx*(p1.x-center.x)+dy*(p1.y-center.y))*2;
					var c:Number = (center.x*center.x)+(center.y*center.y)+(p1.x*p1.x)+(p1.y*p1.y)-((center.x*p1.x+center.y*p1.y)*2)-(r*r);
				
					var d:Number = b*b-4*a*c;
				
					if (d >= 0) {
						if (d > 0) {
							//two potential solutions:
							var u1:Number = (-b + Math.sqrt((b*b)-4*a*c))/(2*a);
							var u2:Number = (-b - Math.sqrt((b*b)-4*a*c))/(2*a);
							var i1_x:Number = p1.x + u1*(p2.x - p1.x);
							var i1_y:Number = p1.y + u1*(p2.y - p1.y);
							var i2_x:Number = p1.x + u2*(p2.x - p1.x);
							var i2_y:Number = p1.y + u2*(p2.y - p1.y);
							if (u1 >= 0 && u1 <= 1) ip = new Point(i1_x, i1_y);
							if (u2 >= 0 && u2 <= 1) ip = new Point(i2_x, i2_y);
						} else {
							//one solution at the tangent
							var u:Number = (-b)/(2*a);
							var i_x:Number = p1.x + u*(p2.x - p1.x);
							var i_y:Number = p1.y + u*(p2.y - p1.y);
							if (u >= 0 && u <= 1) ip = new Point(i_x, i_y);
						}
					}
				
					if (ip) {
						startIndex = i;
						center.x = ip.x;
						center.y = ip.y;
						_simplified.push(ip);
						ip = null;
						p1 = null;
						break;
					} else {
						p1 = new Point(p2.x, p2.y);
					}
				
				}
				
			}
			
		}
		
		private function sortOnX(a:Point, b:Point):Number {
			if (a.x < b.x) {
				return -1;
			} else if (a.x > b.x) {
				return 1;
			} else {
				return 0;
			}
		}
		
		private function sortOnY(a:Point, b:Point):Number {
			if (a.y < b.y) {
				return -1;
			} else if (a.y > b.y) {
				return 1;
			} else {
				return 0;
			}
		}
		
	}

}