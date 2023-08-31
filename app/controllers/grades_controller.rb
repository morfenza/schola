# frozen_string_literal: true

class GradesController < ApplicationController
  before_action :set_grade, only: %i[show edit update destroy]

  def index
    @grades = Grade.all.includes(enrollment: :student, exam: :subject)
  end

  def show; end

  def new
    @grade = Grade.new
  end

  def edit; end

  def create
    @grade = Grade.new(grade_params)

    if @grade.save
      redirect_to @grade, notice: I18n.t('flash.grade.success.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @grade.update(grade_params)
      redirect_to @grade, notice: I18n.t('flash.grade.success.update'), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @grade.destroy
    redirect_to grades_url, notice: I18n.t('flash.grade.success.destroy'), status: :see_other
  end

  private

  def set_grade
    @grade = Grade.find(params[:id])
  end

  def grade_params
    params.require(:grade).permit(:value, :enrollment_code, :exam_id)
  end
end
