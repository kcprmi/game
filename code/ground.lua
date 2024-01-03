Ground = Entity:extend()

function Ground:new(x, y)
    Ground.super.new(self, x, y, "/images/ground.png")
end


function Ground:draw()
    love.graphics.draw(self.image, self.x, self.y)
end