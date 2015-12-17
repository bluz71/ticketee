class TicketsController < ApplicationController
  before_action :find_project
  before_action :find_ticket, only: [:show, :edit, :update, :destroy]

  def new
    @ticket = @project.tickets.build
    authorize @ticket, :create?
    @ticket.attachments.build
  end

  def create
    @ticket = @project.tickets.build(ticket_params)
    @ticket.author = current_user
    authorize @ticket, :create?

    if @ticket.save
      flash[:notice] = "Ticket has been created."
      redirect_to [@project, @ticket]
    else
      flash.now[:alert] = "Ticket has not been created."
      render "new"
    end
  end

  def show
    authorize @ticket, :show?
    @comment = @ticket.comments.build
  end

  def edit
    authorize @ticket, :update?
  end

  def update
    authorize @ticket, :update?

    if @ticket.update(ticket_params)
      flash[:notice] = "Ticket has been updated."
      redirect_to [@project, @ticket]
    else
      flash.now[:alert] = "Ticket has not been updated."
      render "edit"
    end
  end

  def destroy
    authorize @ticket, :destroy?

    @ticket.destroy

    flash[:notice] = "Ticket has been deleted."
    redirect_to @project
  end

  private

    def ticket_params
      params.require(:ticket).permit(:name, :description,
                                  attachments_attributes: [:file, :file_cache])
    end

    def find_project
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The project you are looking for could not be found."
      redirect_to projects_path
    end

    def find_ticket
      @ticket = @project.tickets.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The ticket you are looking for could not be found."
      redirect_to project_tickets_path
    end
end
