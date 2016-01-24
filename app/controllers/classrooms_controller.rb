class ClassroomsController < ApplicationController
  def show
    @classroom = Classroom.find(params[:id])
    gon.classroom_id = @classroom.id
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
