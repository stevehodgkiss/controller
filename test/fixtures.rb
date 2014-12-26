require 'lotus/router'
require 'lotus/action/glue'

HTTP_TEST_STATUSES = {
  100 => 'Continue',
  101 => 'Switching Protocols',
  102 => 'Processing',
  103 => 'Checkpoint',
  122 => 'Request-URI too long',
  200 => 'OK',
  201 => 'Created',
  202 => 'Accepted',
  203 => 'Non-Authoritative Information',
  204 => 'No Content',
  205 => 'Reset Content',
  206 => 'Partial Content',
  207 => 'Multi-Status',
  208 => 'Already Reported',
  226 => 'IM Used',
  300 => 'Multiple Choices',
  301 => 'Moved Permanently',
  302 => 'Found',
  303 => 'See Other',
  304 => 'Not Modified',
  305 => 'Use Proxy',
  307 => 'Temporary Redirect',
  308 => 'Permanent Redirect',
  400 => 'Bad Request',
  401 => 'Unauthorized',
  402 => 'Payment Required',
  403 => 'Forbidden',
  404 => 'Not Found',
  405 => 'Method Not Allowed',
  406 => 'Not Acceptable',
  407 => 'Proxy Authentication Required',
  408 => 'Request Timeout',
  409 => 'Conflict',
  410 => 'Gone',
  411 => 'Length Required',
  412 => 'Precondition Failed',
  413 => 'Payload Too Large',
  414 => 'URI Too Long',
  415 => 'Unsupported Media Type',
  416 => 'Range Not Satisfiable',
  417 => 'Expectation Failed',
  418 => 'I\'m a teapot',
  420 => 'Enhance Your Calm',
  422 => 'Unprocessable Entity',
  423 => 'Locked',
  424 => 'Failed Dependency',
  426 => 'Upgrade Required',
  428 => 'Precondition Required',
  429 => 'Too Many Requests',
  431 => 'Request Header Fields Too Large',
  444 => 'No Response',
  449 => 'Retry With',
  450 => 'Blocked by Windows Parental Controls',
  451 => 'Wrong Exchange server',
  499 => 'Client Closed Request',
  500 => 'Internal Server Error',
  501 => 'Not Implemented',
  502 => 'Bad Gateway',
  503 => 'Service Unavailable',
  504 => 'Gateway Timeout',
  505 => 'HTTP Version Not Supported',
  506 => 'Variant Also Negotiates',
  507 => 'Insufficient Storage',
  508 => 'Loop Detected',
  510 => 'Not Extended',
  511 => 'Network Authentication Required',
  598 => 'Network read timeout error',
  599 => 'Network connect timeout error'
}

module Test
  class Index
    include Lotus::Action
    expose :xyz

    def call(params)
      @xyz = params[:name]
    end
  end
end

class CallAction
  include Lotus::Action

  def call(params)
    self.status  = 201
    self.body    = 'Hi from TestAction!'
    self.headers.merge!({ 'X-Custom' => 'OK' })
  end
end

class ErrorCallAction
  include Lotus::Action

  def call(params)
    raise
  end
end

class ErrorCallWithSymbolMethodNameAsHandlerAction
  include Lotus::Action

  handle_exception StandardError => :handler

  def call(params)
    raise StandardError
  end

  private
  def handler(exception)
    status 501, 'Please go away!'
  end
end

class ErrorCallWithStringMethodNameAsHandlerAction
  include Lotus::Action

  handle_exception StandardError => 'standard_error_handler'

  def call(params)
    raise StandardError
  end

  private
  def standard_error_handler(exception)
    status 502, exception.message
  end
end

class ErrorCallWithUnsetStatusResponse
  include Lotus::Action

  handle_exception ArgumentError => 'arg_error_handler'

  def call(params)
    raise ArgumentError
  end

  private
  def arg_error_handler(exception)
  end
end

class ErrorCallWithSpecifiedStatusCodeAction
  include Lotus::Action

  handle_exception StandardError => 422

  def call(params)
    raise StandardError
  end
end

class ExposeAction
  include Lotus::Action

  expose :film, :time

  def call(params)
    @film = '400 ASA'
  end
end

class XMiddleware
  def self.call(env)
    env['X-Middleware'] = 'OK'
  end
end

class UseAction
  include Lotus::Action

  use XMiddleware

  def call(params)
    headers['X-Middleware'] = params.env.fetch('X-Middleware')
  end
end

class BeforeMethodAction
  include Lotus::Action

  expose :article
  before :set_article, :reverse_article

  def call(params)
  end

  private
  def set_article
    @article = 'Bonjour!'
  end

  def reverse_article
    @article.reverse!
  end
end

class SubclassBeforeMethodAction < BeforeMethodAction
  before :upcase_article

  private
  def upcase_article
    @article.upcase!
  end
end

class ParamsBeforeMethodAction < BeforeMethodAction
  expose :exposed_params

  private
  def set_article(params)
    @exposed_params = params
    @article = super() + params[:bang]
  end
end

class ErrorBeforeMethodAction < BeforeMethodAction
  private
  def set_article
    raise
  end
end

class BeforeBlockAction
  include Lotus::Action

  expose :article
  before { @article = 'Good morning!' }
  before { @article.reverse! }

  def call(params)
  end
end

class YieldBeforeBlockAction < BeforeBlockAction
  expose :yielded_params
  before {|params| @yielded_params = params }
end

class AfterMethodAction
  include Lotus::Action

  expose :egg
  after  :set_egg, :scramble_egg

  def call(params)
  end

  private
  def set_egg
    @egg = 'Egg!'
  end

  def scramble_egg
    @egg = 'gE!g'
  end
end

class SubclassAfterMethodAction < AfterMethodAction
  after :upcase_egg

  private
  def upcase_egg
    @egg.upcase!
  end
end

class ParamsAfterMethodAction < AfterMethodAction
  private
  def scramble_egg(params)
    @egg = super() + params[:question]
  end
end

class ErrorAfterMethodAction < AfterMethodAction
  private
  def set_egg
    raise
  end
end

class AfterBlockAction
  include Lotus::Action

  expose :egg
  after { @egg = 'Coque' }
  after { @egg.reverse! }

  def call(params)
  end
end

class YieldAfterBlockAction < AfterBlockAction
  expose :meaning_of_life_params
  before {|params| @meaning_of_life_params = params }
end

class SessionAction
  include Lotus::Action
  include Lotus::Action::Session

  def call(params)
  end
end

class RedirectAction
  include Lotus::Action

  def call(params)
    redirect_to '/destination'
  end
end

class StatusRedirectAction
  include Lotus::Action

  def call(params)
    redirect_to '/destination', status: 301
  end
end

class GetCookiesAction
  include Lotus::Action
  include Lotus::Action::Cookies

  def call(params)
    self.body = cookies[:foo]
  end
end

class SetCookiesAction
  include Lotus::Action
  include Lotus::Action::Cookies

  def call(params)
    self.body = 'yo'
    cookies[:foo] = 'yum!'
  end
end

class SetCookiesWithOptionsAction
  include Lotus::Action
  include Lotus::Action::Cookies

  def call(params)
    cookies[:kukki] = { value: 'yum!', domain: 'lotusrb.org', path: '/controller', expires: params[:expires], secure: true, httponly: true }
  end
end

class RemoveCookiesAction
  include Lotus::Action
  include Lotus::Action::Cookies

  def call(params)
    cookies[:rm] = nil
  end
end

class ThrowCodeAction
  include Lotus::Action

  def call(params)
    halt params[:status]
  end
end

class CatchAndThrowSymbolAction
  include Lotus::Action

  def call(params)
    return_value = catch :done do
      throw :done, 1
      raise "This code shouldn't be reachable"
    end
  end
end

class ThrowBeforeMethodAction
  include Lotus::Action

  before :authorize!
  before :set_body

  def call(params)
    self.body = 'Hello!'
  end

  private
  def authorize!
    halt 401
  end

  def set_body
    self.body = 'Hi!'
  end
end

class ThrowBeforeBlockAction
  include Lotus::Action

  before { halt 401 }
  before { self.body = 'Hi!' }

  def call(params)
    self.body = 'Hello!'
  end
end

class ThrowAfterMethodAction
  include Lotus::Action

  after :raise_timeout!
  after :set_body

  def call(params)
    self.body = 'Hello!'
  end

  private
  def raise_timeout!
    halt 408
  end

  def set_body
    self.body = 'Later!'
  end
end

class ThrowAfterBlockAction
  include Lotus::Action

  after { halt 408 }
  after { self.body = 'Later!' }

  def call(params)
    self.body = 'Hello!'
  end
end

class RecordNotFound < StandardError
end

class HandledExceptionAction
  include Lotus::Action
  handle_exception RecordNotFound => 404

  def call(params)
    raise RecordNotFound.new
  end
end

class DomainLogicException < StandardError
end

Lotus::Controller.class_eval do
  configure do
    handle_exception DomainLogicException => 400
  end
end

class GlobalHandledExceptionAction
  include Lotus::Action

  def call(params)
    raise DomainLogicException.new
  end
end

Lotus::Controller.unload!

class UnhandledExceptionAction
  include Lotus::Action

  def call(params)
    raise RecordNotFound.new
  end
end

class ParamsAction
  include Lotus::Action

  def call(params)
    self.body = params.to_h.inspect
  end
end

class WhitelistedParamsAction
  class Params < Lotus::Action::Params
    param :id, Integer
  end

  include Lotus::Action
  params Params

  def call(params)
    self.body = params.to_h.inspect
  end
end

class WhitelistedDslAction
  include Lotus::Action

  params do
    param :username, String
  end

  def call(params)
    self.body = params.to_h.inspect
  end
end

class ParamsValidationAction
  include Lotus::Action

  params do
    param :email, String, presence: true
  end

  def call(params)
    halt 400 unless params.valid?
  end
end

class Root
  include Lotus::Action

  def call(params)
    self.body = params.to_h.inspect
    headers.merge!({'X-Test' => 'test'})
  end
end

module About
  class Team < Root
  end

  class Contacts
    include Lotus::Action

    def call(params)
      self.body = params.to_h.inspect
    end
  end
end

module Identity
  class Action
    include Lotus::Action

    def call(params)
      self.body = params.to_h.inspect
    end
  end

  Show    = Class.new(Action)
  New     = Class.new(Action)
  Create  = Class.new(Action)
  Edit    = Class.new(Action)
  Update  = Class.new(Action)
  Destroy = Class.new(Action)
end

module Flowers
  class Action
    include Lotus::Action

    def call(params)
      self.body = params.to_h.inspect
    end
  end

  Index   = Class.new(Action)
  Show    = Class.new(Action)
  New     = Class.new(Action)
  Create  = Class.new(Action)
  Edit    = Class.new(Action)
  Update  = Class.new(Action)
  Destroy = Class.new(Action)
end

module Dashboard
  class Index
    include Lotus::Action
    include Lotus::Action::Session
    before :authenticate!

    def call(params)
    end

    private
    def authenticate!
      halt 401 unless loggedin?
    end

    def loggedin?
      session.has_key?(:user_id)
    end
  end
end

module Sessions
  class Create
    include Lotus::Action
    include Lotus::Action::Session

    def call(params)
      session[:user_id] = 23
      redirect_to '/'
    end
  end

  class Destroy
    include Lotus::Action
    include Lotus::Action::Session

    def call(params)
      session[:user_id] = nil
    end
  end
end

class StandaloneSession
  include Lotus::Action
  include Lotus::Action::Session

  def call(params)
    session[:age] = Time.now.year - 1982
  end
end

class ArtistNotFound < StandardError
end

module App
  class CustomError < StandardError
  end

  class StandaloneAction
    include Lotus::Action
    handle_exception App::CustomError => 400

    def call(params)
      raise App::CustomError
    end
  end
end

module App2
  class CustomError < StandardError
  end

  module Standalone
    class Index
      include Lotus::Action
      configuration.handle_exception App2::CustomError => 400

      def call(params)
        raise App2::CustomError
      end
    end
  end
end

module MusicPlayer
  Controller = Lotus::Controller.dupe
  Action     = Lotus::Action.dup

  Controller.module_eval do
    configuration.reset!
    configure do
      handle_exception ArgumentError => 400
      action_module    MusicPlayer::Action

      prepare do
        include Lotus::Action::Cookies
        include Lotus::Action::Session
        include MusicPlayer::Controllers::Authentication
      end
    end
  end

  module Controllers
    module Authentication
      def self.included(action)
        action.class_eval { expose :current_user }
      end

      private
      def current_user
        'Luca'
      end
    end

    class Dashboard
      class Index
        include MusicPlayer::Action

        def call(params)
          self.body = 'Muzic!'
        end
      end

      class Show
        include MusicPlayer::Action

        def call(params)
          raise ArgumentError
        end
      end
    end

    module Artists
      class Index
        include MusicPlayer::Action

        def call(params)
          self.body = current_user
        end
      end

      class Show
        include MusicPlayer::Action

        handle_exception ArtistNotFound => 404

        def call(params)
          raise ArtistNotFound
        end
      end
    end
  end

  class StandaloneAction
    include MusicPlayer::Action

    def call(params)
      raise ArgumentError
    end
  end
end

class VisibilityAction
  include Lotus::Action
  include Lotus::Action::Cookies
  include Lotus::Action::Session

  self.configuration.handle_exceptions false

  def call(params)
    self.body   = 'x'
    self.status = 201
    self.format = :json

    self.headers.merge!('X-Custom' => 'OK')
    headers.merge!('Y-Custom'      => 'YO')

    # PRIVATE
    # self.configuration
    # self.finish

    # PROTECTED
    self.response
    self.cookies
    self.session

    response
    cookies
    session
  end
end

module FullStack
  Controller = Lotus::Controller.duplicate(self) do
    handle_exceptions false

    prepare do
      include Lotus::Action::Glue
      include Lotus::Action::Session
    end
  end

  module Controllers
    module Home
      class Index
        include FullStack::Action
        expose :greeting

        def call(params)
          @greeting = 'Hello'
        end
      end
    end

    module Books
      class Index
        include FullStack::Action

        def call(params)
        end
      end

      class Create
        include FullStack::Action

        params do
          param :title, String, presence: true
        end

        def call(params)
          params.valid?

          redirect_to '/books'
        end
      end
    end

    module Poll
      class Start
        include FullStack::Action

        def call(params)
          redirect_to '/poll/1'
        end
      end

      class Step1
        include FullStack::Action

        def call(params)
          if @_env['REQUEST_METHOD'] == 'GET'
            flash[:notice] = "Start the poll"
          else
            flash[:notice] = "Step 1 completed"
            redirect_to '/poll/2'
          end
        end
      end

      class Step2
        include FullStack::Action

        def call(params)
          if @_env['REQUEST_METHOD'] == 'POST'
            flash[:notice] = "Poll completed"
            redirect_to '/'
          end
        end
      end
    end
  end

  class Renderer
    def render(env, response)
      action = env.delete('lotus.action')

      if response[0] == 200
        response[2] = "#{ action.class.name } #{ action.exposures }"
      end

      response
    end
  end

  class Application
    def initialize
      resolver = Lotus::Routing::EndpointResolver.new(namespace: FullStack::Controllers)
      routes   = Lotus::Router.new(resolver: resolver) do
        get '/', to: 'home#index'
        resources :books, only: [:index, :create]

        get '/poll', to: 'poll#start'

        namespace 'poll' do
          get  '/1', to: 'poll#step1'
          post '/1', to: 'poll#step1'
          get  '/2', to: 'poll#step2'
          post '/2', to: 'poll#step2'
        end
      end

      @renderer   = Renderer.new
      @middleware = Rack::Builder.new do
        use Rack::Session::Cookie, secret: SecureRandom.hex(16)
        run routes
      end
    end

    def call(env)
      @renderer.render(env, @middleware.call(env))
    end
  end
end
