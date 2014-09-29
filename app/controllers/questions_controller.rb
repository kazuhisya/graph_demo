class QuestionsController < ApplicationController
  include ActionController::Live

  before_action :set_question, only: [:stream, :show, :edit, :update, :destroy, :increment]

  def stream
    response.headers['Content-Type'] = 'text/event-stream'

    100.times do |i|
      ActiveRecord::Base.connection_pool.with_connection do
        Question.uncached do
          set_question
        end
      end

      res = [
        {label: @question.q_1, value: @question.q_1_count},
        {label: @question.q_2, value: @question.q_2_count},
        {label: @question.q_3, value: @question.q_3_count},
        {label: @question.q_4, value: @question.q_4_count},
      ]

      response.stream.write("event: message\n")
      response.stream.write("data: #{res.to_json}\n\n")
      sleep 3
    end

    response.stream.write("event: done\n")
    response.stream.write("data: done\n\n")
  ensure
    response.stream.close
  end

  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.all
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render action: 'show', status: :created, location: @question }
      else
        format.html { render action: 'new' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url }
      format.json { head :no_content }
    end
  end

  def increment
    @question.increment!(params[:q])
    render json: {success: true}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :q_1, :q_1_count, :q_2, :q_2_count, :q_3, :q_3_count, :q_4, :q_4_count)
    end
end
