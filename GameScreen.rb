require 'java'
require 'libs/gdx.jar'
require 'src/Player'
require 'src/util/TextureSetup'

java_import com.badlogic.gdx.Gdx
java_import com.badlogic.gdx.Screen
java_import com.badlogic.gdx.graphics.GL20
java_import com.badlogic.gdx.graphics.OrthographicCamera
java_import com.badlogic.gdx.graphics.g2d.SpriteBatch
java_import com.badlogic.gdx.graphics.g2d.TextureRegion
java_import com.badlogic.gdx.graphics.g2d.TextureAtlas
java_import com.badlogic.gdx.maps.tiled.TiledMap
java_import com.badlogic.gdx.maps.tiled.TiledMapTileLayer
java_import com.badlogic.gdx.maps.tiled.TiledMapTileLayer::Cell
java_import com.badlogic.gdx.maps.tiled.TmxMapLoader
java_import com.badlogic.gdx.maps.tiled.renderers.OrthogonalTiledMapRenderer
java_import com.badlogic.gdx.math.Rectangle
java_import com.badlogic.gdx.math.Vector2
java_import com.badlogic.gdx.utils.Pool

class GameScreen
  java_implements Screen
  
  attr_accessor :tiles, :map, :atlas, :rectPool
  
  def show()
    
    TextureSetup.new
    
    @tiles = com.badlogic.gdx.utils.Array.new
    @atlas = TextureAtlas.new(Gdx.files.internal("assets/gfx/graphics.pack"))

    @rectPool = Class.new(Pool) do
          
      def newObject()
        return Rectangle.new  
      end
      
    end.new
    
    @player = Player.new(self)
    @player.position.set(6, 12)
    @player.width = 1 / 32.0 * @atlas.findRegion("kuwalioStand").getRegionWidth
    @player.height = 1 / 32.0 * @atlas.findRegion("kuwalioStand").getRegionHeight
    
    @map = TmxMapLoader.new.load("assets/maps/level1.tmx")
    @renderer = OrthogonalTiledMapRenderer.new(@map, 1 / 32.0)
    
    @cam = OrthographicCamera.new
    @cam.setToOrtho(false, 20, 15)
    @cam.update

  end
  
    
  def render(delta)
    
    Gdx.gl.glClearColor(0.6, 0.6, 1.0, 1)
    Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)
    
    @player.update(delta)
    
    @cam.position.x = @player.position.x
    @cam.update
    
    @renderer.setView(@cam)
    @renderer.render
    
    @player.render(@renderer)
    
  end
  
  
  def getTiles(startX, startY, endX, endY)
      
    layer = @map.getLayers.get(0)
    @rectPool.freeAll(@tiles)
    @tiles.clear
    
    for y in startY..endY
      for x in startX..endX
    
        cell = layer.getCell(x, y)
        
        unless cell.nil?
          
          rect = @rectPool.obtain
          rect.set(x, y, 1, 1)
          @tiles.add(rect)
          
        end
        
      end
      
    end
    
  end

  
  def resize(width, height)
  end
  
  def hide()
    Gdx.input.setInputProcessor(nil)
  end
  
  def pause()
  end
  
  def resume()
  end
  
  def dispose()
    Gdx.input.setInputProcessor(nil)
  end
  
end
