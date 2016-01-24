class ClassroomsController < ApplicationController
  def show
    @classroom = Classroom.find(params[:id])
    gon.classroom_id = @classroom.id
  end
end
