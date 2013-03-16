DummyRails32Api::Application.routes.draw do
  match 'members/list', to: 'members#show'
end
