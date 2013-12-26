require 'java'
require 'libs/gdx-tools.jar'

java_import com.badlogic.gdx.tools.imagepacker.TexturePacker2

class TextureSetup
  
  def initialize()
    
    TexturePacker2.process("assets/gfx", "assets/gfx", "graphics.pack")
    
  end
  
end
