require 'java'
require 'libs/gdx.jar'
require 'src/GameScreen'

java_import com.badlogic.gdx.Gdx
java_import com.badlogic.gdx.Input::Keys
java_import com.badlogic.gdx.graphics.g2d.Animation
java_import com.badlogic.gdx.graphics.g2d.SpriteBatch
java_import com.badlogic.gdx.graphics.g2d.TextureRegion
java_import com.badlogic.gdx.graphics.g2d.TextureAtlas
java_import com.badlogic.gdx.maps.tiled.TiledMap
java_import com.badlogic.gdx.maps.tiled.TiledMapTileLayer
java_import com.badlogic.gdx.maps.tiled.TiledMapTileLayer::Cell
java_import com.badlogic.gdx.maps.tiled.renderers.OrthogonalTiledMapRenderer

class Player

  attr_accessor :position, :velocity, :width, :height
  
  GRAVITY = -2.5
  DAMPING = 0.87
  MAX_VEL, JUMP_VEL = 10, 40
  
  Standing, Walking, Jumping = 0, 1, 2
  
  def initialize(gameScreen)
    
    @gameScreen = gameScreen
    @position = Vector2.new
    @velocity = Vector2.new
    @state = Standing
    @stateTime = 0
    @facingRight = true
    @grounded = false
    
    @stand = Animation.new(0, @gameScreen.atlas.findRegion("kuwalioStand"))
    @jump = Animation.new(0, @gameScreen.atlas.findRegion("kuwalioJump"))
    
    @walk = Animation.new(
      0.15, 
      @gameScreen.atlas.findRegion("kuwalioWalk1"), 
      @gameScreen.atlas.findRegion("kuwalioWalk2"), 
      @gameScreen.atlas.findRegion("kuwalioWalk3")
    )
    
    @walk.setPlayMode(Animation::LOOP_PINGPONG)
  
  end
  
  
  def update(delta)

    @stateTime += delta
    
    if Gdx.input.isKeyPressed(Keys::SPACE) && @grounded
      
      @velocity.y += JUMP_VEL
      @grounded = false
      @state = Jumping
      
    end
    
    if Gdx.input.isKeyPressed(Keys::LEFT) || Gdx.input.isKeyPressed(Keys::A)
      
      @facingRight = false
      @velocity.x = -MAX_VEL
      
      if @grounded
        @state = Walking
      end
      
    end
    
    if Gdx.input.isKeyPressed(Keys::RIGHT) || Gdx.input.isKeyPressed(Keys::D)
          
      @facingRight = true
      @velocity.x = MAX_VEL
      
      if @grounded
        @state = Walking
      end
      
    end
    
    @velocity.add(0, GRAVITY)
    
    if @velocity.x.abs > MAX_VEL
      @velocity.x = (@velocity.x <=> 0) * MAX_VEL
    end
    
    if @velocity.x.abs < 1
      
      @velocity.x = 0
      
      if @grounded
        @state = Standing
      end
    
    end
    
    @velocity.scl(delta)
    
    playerRect = @gameScreen.rectPool.obtain
    playerRect.set(@position.x, @position.y, @width, @height)
    
    if @velocity.x > 0
      startX = endX = (@position.x + @width + @velocity.x).to_i
    else
      startX = endX = (@position.x + @velocity.x).to_i
    end 
    
    startY = @position.y.to_i
    endY = (@position.y + @height).to_i
    
    @gameScreen.getTiles(startX, startY, endX, endY)
    
    playerRect.x += @velocity.x
    
    @gameScreen.tiles.each do |tile|
      
      if playerRect.overlaps(tile)
        
        @velocity.x = 0
        break
        
      end
      
    end
    
    playerRect.x = @position.x
    
    
    if @velocity.y > 0
      startY = endY = (@position.y + @height + @velocity.y).to_i
    else
      startY = endY = (@position.y + @velocity.y).to_i
    end
    
    startX = @position.x.to_i
    endX = (@position.x + @width).to_i
    
    @gameScreen.getTiles(startX, startY, endX, endY)
    
    playerRect.y += @velocity.y
    
    @gameScreen.tiles.each do |tile|
      
      if playerRect.overlaps(tile)
        
        if @velocity.y > 0
          
          @position.y = tile.y - @height
          
          layer = @gameScreen.map.getLayers.get(0)
          layer.setCell(tile.x.to_i, tile.y.to_i, nil)
        
        else
          
          @position.y = tile.y + tile.height
          @grounded = true
          
        end
        
        @velocity.y = 0
        break
        
      end

    end
    
    @gameScreen.rectPool.free(playerRect)
    
    @position.add(@velocity)
    @velocity.scl(1 / delta)
    
    @velocity.x *= DAMPING
    
  end
  
  
  def render(renderer)
    
    frame = nil
    
    case @state
      
      when Standing
        frame = @stand.getKeyFrame(@stateTime)
      when Walking
        frame = @walk.getKeyFrame(@stateTime)
      when Jumping
        frame = @jump.getKeyFrame(@stateTime)
        
    end
    
    batch = renderer.getSpriteBatch
    
    batch.begin
    
      if @facingRight
        batch.draw(frame, @position.x, @position.y, @width, @height)
      else
        batch.draw(frame, @position.x + @width, @position.y, -@width, @height)
      end
      
    batch.end
    
    
  end

end
