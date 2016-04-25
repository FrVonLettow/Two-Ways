package 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.space.Space;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.AssetManager;
	import nape.phys.BodyType;
	/**
	 * The Ball class is the main character in the game.
	 * It should be able to be moved by an AI or a Player.
	 * It can fall from the Playform and will decreasize its size in that moment.
	 * It depends also on forces that are applied to it.
	 * 
	 * @param radius It is the current radius of the ball.
	 * @param originalRadius It is the original radius of the ball.
	 * @param originalSize It is the original size of the ball.
	 * @param id It is the id that represents the ball in the game.
	 * @param ballImage It is the represented image of the ball.
	 * @param position It is the coordinates of the ball.
	 * @param force It is the applied force in the next frame for the ball.
	 * @param body It is the physics representation of the ball.
	 * @param inPlatform It is the boolean that checks if the ball is in the platform.
	 * @param inGame It is the boolean that checks if the ball is in the Game.
	 * @param baseforce It is an static Number that determines the baseforce of every Ball.
	 * 
	 * @author MiguelCasquero
	 */
	
	public class Ball extends Sprite
	{
		protected var radius:Number;
		protected var originalRadius:Number = 20;
		protected var originalSize:Number;
		protected var id:int;
		protected var ballImage:Image;
		protected var position:Point;
		protected var force:Vec2;
		protected var body:Body;
		protected var inPlatform:Boolean;
		protected var inGame:Boolean;
		protected static var baseforce:Number = 10;
		
		/**
		 * The Constructor assigns the initial values passed by.
		 * it also initializes the physics of the body.
		 */
		
		public function Ball(id:int, colour:String, position:Point, space:Space, assetManager:AssetManager) 
		{
			
			this.id = id;
			this.ballImage = new Image(assetManager.getTexture(colour));
			this.position = position;
			this.radius = originalRadius;
			this.originalSize = ballImage.width;
			ballImage.x = position.x;
			ballImage.y = position.y;
			ballImage.alignPivot( "center", "center");
			ballImage.scaleX = ballImage.scaleY = 1 * ((radius)*2/ballImage.width);
			this.inPlatform = true;
			this.inGame = true;
			this.force = Vec2.weak();
			this.force.length = baseforce;
			
			this.body = new Body(BodyType.DYNAMIC);
			body.shapes.add(new Circle(radius));
			body.position.setxy(ballImage.x, ballImage.y);
			body.angularVel = 0;
			body.space = space;
			
			force = new Vec2(0, 0);
			
			addChild(ballImage);
		}
		
		/**
		 * checkFall determines if the Ball is still on the platform or not.
		 * If it is true, it disables the ball movement and its physics. 
		 * 
		 * @return Boolean
		 */	
		public function checkFall(platform:Platform):Boolean {
			var distance:Number = Point.distance(this.position, platform.getPosition());
			if (distance > this.radius / 2 + platform.getRadius()) {
				body.allowMovement = false;
				body.disableCCD = false;
				inPlatform = false;
				return false;
			}
			return true;

		}
		
		/**
		 * updateForces will check the actual force and apply it to the ball.
		 * If the velocity value is higher than 200, it will maintain it at that speed.
		 * If there is no force to be applied, it reduces
		 * the velocity of the ball by 0.5.
		 * Finally it updates the Image to the body.
		 * 
		 * @see updateImage()
		 */
		public function updateForces() {
			if (body.velocity.length > 200) {
				body.velocity.length = 200;
			}
			
			if ((force.x != 0 || force.y != 0)) {
				body.applyImpulse(force);
			}
			
			if (this.body.velocity.length >= 0.5 && force.x == 0 && force.y == 0) {
				this.body.velocity.length -= 0.5;
			}
			
			updateImage();
		}
		
		/**
		 * decreaseSize will decrease the size of the Ball.
		 * It will depend on the time that has passed and the original Radius.
		 * If the radius is 0 or less, it will make it disappear from the game.
		 */
		public function decreaseSize(secondsPassed:Number) {
			if (this.radius > 0){
				this.radius -= ((originalRadius) * (secondsPassed / 2));
			}
			else {
				body.space = null;
				this.inGame = false;
			}
			ballImage.scaleX = ballImage.scaleY = 1 * ((radius) * 2 / originalSize);
		}
		
		/**
		 * updateImage will just adjust the coordinates of position and the Image
		 * to the actual body.
		 */
		public function updateImage() {
			position = new Point(body.position.x, body.position.y);
			ballImage.x = position.x;
			ballImage.y = position.y;
		}
		
		/**
		 * Indicates whether or not the Ball is in the Platform
		 */
		public function isInPlatform():Boolean {
			return inPlatform;
		}
		
		/**
		 * Indicates whether or not the Ball is in the Game
		 */
		public function isInGame():Boolean {
			return inGame;
		}
		
		/**
		 * Returns the actual velocity of the Ball.
		 */
		public function getVelocity():Vec2 {
			return body.velocity;
		}
		
		/**
		 * Returns the actual position of the Ball.
		 */
		public function getPosition():Point { 
			return position;
		}
	}

}