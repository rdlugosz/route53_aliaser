Route53Aliaser::Engine.routes.draw do
  root to: 'aliaser#update', via: [:get, :head]
end
