class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]
  before_action :index, only: %i[create destroy]

  # GET /messages or /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1 or /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
    if @message
      p "hitting the edit action edit_message_#{@message.id}"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
          "edit_message_#{@message.id}", partial: "form", locals:{message: @message}
          )
        end
          format.html { render :edit, status: :ok }
          format.json { render json: message, status: :ok }
      end
    else
          format.html { render :edit, status: :ok }
          format.json { render json: message, status: :ok }
    end
  end

  # POST /messages or /messages.json
  def create
    @message = Message.new(message_params)

    respond_to do |format|
      if @message.save
        format.turbo_stream  do
          render turbo_stream: [
          turbo_stream.update('new_message', partial: "form", locals:{message: Message.new}),
          turbo_stream.update('messages_counter', @messages.length),
          turbo_stream.prepend('messages', partial: "message", locals:{message: @message})
          ]
        end

        format.html { redirect_to message_url(@message), notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @message }
      else
        format.turbo_stream  {render turbo_stream: turbo_stream.update('new_message', partial: "form", locals:{message: @message})}
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
          @message, partial: "message", locals:{message: @message}
          )
        end
        format.html { redirect_to message_url(@message), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@message),
          turbo_stream.update("messages_counter", @messages.length)
        ]
      end
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:body)
    end
end
