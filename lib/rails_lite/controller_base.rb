require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
#require 'debugger'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
    
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    @res.content_type = type
    @res.body = content
    
    #set the cookie
    session
    raise if @already_built_response == true
    @already_built_response = true
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    @res.status = 302
    @res.header["location"] = url
    
    #set the cookie
    session
    raise if @already_built_response == true
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = "views/#{self.class.to_s.underscore}/#{template_name.to_s}.html.erb"

    template = ERB.new(File.read(path)).result(binding)
    render_content(template, 'text/html')
  end

  # method exposing a `Session` object
  #!!!!!!!!!!!!!!!!!!!!!!!!!
  #!!!!!!!!!!!!!!!!!!!!!!!!!!
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
    nil
  end
end
