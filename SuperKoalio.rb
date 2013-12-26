include Java

require 'src/GameScreen'

Dir["libs/\*.jar"].each {|jar| require jar}

java_import com.badlogic.gdx.Game
java_import com.badlogic.gdx.backends.lwjgl.LwjglApplication

class SuperKoalio < Game
  
  def create()
    setScreen(GameScreen.new)
  end
  
end

LwjglApplication.new(SuperKoalio.new, "Super Koalio", 800, 600, true)