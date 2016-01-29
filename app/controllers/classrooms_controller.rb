class ClassroomsController < ApplicationController
  def show
    @classroom = Classroom.find(params[:id])
    gon.classroom_id = @classroom.id
    gon.client_id = SecureRandom.uuid
    gon.lang = @classroom.language
    gon.language = @classroom.language_name
    gon.classroom_name = @classroom.name
  end

  def create
    room = Classroom.create!(classroom_params)
    redirect_to room
  end

  private
    def classroom_params
      params.require(:classroom).permit(:language, :name)
    end
end
