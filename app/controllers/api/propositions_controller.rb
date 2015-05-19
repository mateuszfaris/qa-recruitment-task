module Api
  class PropositionsController < ApplicationController

    before_action :restrict_wrong_owner, only: [:update]

    def create
      render json: PropositionRepresenter.new(current_user.propositions_as_owner.create(proposition_params)).basic
    end

    def update
      proposition = proposition_from_params
      if proposition.update(proposition_params)
        render json: PropositionRepresenter.new(proposition).basic
      else
        render json: { errors: proposition.errors.messages }, status: 422
      end
    end

    def choose
      proposition = Proposition.find(params[:proposition_id])
      proposition.update_attributes(year_chosen_in: Time.now.year)
      render json: PropositionRepresenter.new(proposition).basic
    end

    def vote
      proposition = Proposition.find(params[:proposition_id])
      vote = proposition.votes.create user: current_user

      render json: vote
    end

    def unvote
      proposition = Proposition.find(params[:proposition_id])
      vote = proposition.votes.find_by_user_id(current_user.id)
      vote.destroy

      head 200
    end

  private
    def proposition_from_params
      proposition ||= Proposition.find(params[:id])
    end

    def restrict_wrong_owner
      proposition = proposition_from_params
      head :unauthorized if current_user.id != proposition.owner_id
    end

    def proposition_params
      params.require(:proposition).permit(:celebrant_id, :description, :title, :value, :year_chosen_in)
    end
  end
end
