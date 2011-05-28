class Lolita::I18nController < ApplicationController
  include Lolita::Controllers::UserHelpers
  before_filter :authenticate_lolita_user!

  layout "lolita/application"

  def index
    @translations=if ::I18n.backend.respond_to?(:store)
      ::I18n.backend.store
    else
      {}
    end 
  end

  def edit
    @translation=Lolita::I18n::Backend.get(params[:id])
  end

  def next
    next_key=Lolita::I18n::Backend.next(params[:id],params[:from])
    redirect_to :action=>:edit, :id=>next_key
  end

  def update
    Lolita::I18n::Backend.set(params[:id],params[:i18n])
    next_key=Lolita::I18n::Backend.next(params[:id],Lolita::I18n::Backend.locale(params[:id]))
    redirect_to :action=>:edit,:id=>next_key
  end

end